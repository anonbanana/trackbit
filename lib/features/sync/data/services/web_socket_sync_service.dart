import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../domain/entities/sync_entry.dart';

enum SyncMessageType { syncRequest, syncResponse, syncAck, error }

class SyncMessage {
  final SyncMessageType type;
  final String deviceId;
  final List<Map<String, dynamic>>? entries;
  final String? errorMessage;

  const SyncMessage({
    required this.type,
    required this.deviceId,
    this.entries,
    this.errorMessage,
  });

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'deviceId': deviceId,
    if (entries != null) 'entries': entries,
    if (errorMessage != null) 'error': errorMessage,
  };

  factory SyncMessage.fromJson(Map<String, dynamic> json) {
    return SyncMessage(
      type: SyncMessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SyncMessageType.error,
      ),
      deviceId: json['deviceId'] ?? '',
      entries: json['entries'] != null
          ? List<Map<String, dynamic>>.from(json['entries'])
          : null,
      errorMessage: json['error'],
    );
  }
}

class WebSocketSyncService {
  WebSocketChannel? _channel;
  final _messageController = StreamController<SyncMessage>.broadcast();
  bool _isConnected = false;

  Stream<SyncMessage> get messageStream => _messageController.stream;
  bool get isConnected => _isConnected;

  Future<bool> connect(String ipAddress, int port) async {
    try {
      final uri = Uri.parse('wss://$ipAddress:$port');
      _channel = WebSocketChannel.connect(uri);

      await _channel!.ready;

      _channel!.stream.listen(
        (data) {
          try {
            final json = jsonDecode(data as String) as Map<String, dynamic>;
            final message = SyncMessage.fromJson(json);
            _messageController.add(message);
          } catch (e) {
            debugPrint('WebSocket message parse error: $e');
          }
        },
        onError: (_) {
          _isConnected = false;
        },
        onDone: () {
          _isConnected = false;
        },
      );

      _isConnected = true;
      return true;
    } catch (_) {
      _isConnected = false;
      return false;
    }
  }

  void sendSyncRequest(String deviceId, List<SyncEntry> entries) {
    if (!_isConnected || _channel == null) return;

    final message = SyncMessage(
      type: SyncMessageType.syncRequest,
      deviceId: deviceId,
      entries: entries
          .map(
            (e) => {
              'id': e.id,
              'entityTable': e.entityTable,
              'recordId': e.recordId,
              'operation': e.operation,
              'payloadJson': e.payloadJson,
              'deviceId': e.deviceId,
              'createdAt': e.createdAt.toIso8601String(),
            },
          )
          .toList(),
    );

    _channel!.sink.add(jsonEncode(message.toJson()));
  }

  void sendSyncAck(String deviceId) {
    if (!_isConnected || _channel == null) return;

    final message = SyncMessage(
      type: SyncMessageType.syncAck,
      deviceId: deviceId,
    );

    _channel!.sink.add(jsonEncode(message.toJson()));
  }

  void sendError(String deviceId, String error) {
    if (!_isConnected || _channel == null) return;

    final message = SyncMessage(
      type: SyncMessageType.error,
      deviceId: deviceId,
      errorMessage: error,
    );

    _channel!.sink.add(jsonEncode(message.toJson()));
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
    _isConnected = false;
  }

  void dispose() {
    disconnect();
    _messageController.close();
  }
}
