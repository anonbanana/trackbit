import 'package:flutter_test/flutter_test.dart';
import 'package:trackbit/features/sync/data/services/web_socket_sync_service.dart';

void main() {
  group('SyncMessage', () {
    test('serializes to JSON correctly', () {
      final message = SyncMessage(
        type: SyncMessageType.syncRequest,
        deviceId: 'device-123',
        entries: [
          {
            'id': 1,
            'entityTable': 'products',
            'recordId': 'rec-1',
            'operation': 'UPSERT',
          },
        ],
      );

      final json = message.toJson();
      expect(json['type'], 'syncRequest');
      expect(json['deviceId'], 'device-123');
      expect(json['entries'], hasLength(1));
      expect(json['entries'][0]['entityTable'], 'products');
    });

    test('deserializes from JSON correctly', () {
      final json = {
        'type': 'syncResponse',
        'deviceId': 'device-456',
        'entries': [
          {'entityTable': 'customers', 'recordId': 'c-1'},
        ],
      };

      final message = SyncMessage.fromJson(json);
      expect(message.type, SyncMessageType.syncResponse);
      expect(message.deviceId, 'device-456');
      expect(message.entries, hasLength(1));
    });

    test('handles error message type', () {
      final json = {
        'type': 'error',
        'deviceId': 'device-789',
        'error': 'Something went wrong',
      };

      final message = SyncMessage.fromJson(json);
      expect(message.type, SyncMessageType.error);
      expect(message.errorMessage, 'Something went wrong');
    });

    test('defaults to error type for unknown type', () {
      final json = {
        'type': 'unknown_type',
        'deviceId': 'device-000',
      };

      final message = SyncMessage.fromJson(json);
      expect(message.type, SyncMessageType.error);
    });

    test('serializes with error field', () {
      const message = SyncMessage(
        type: SyncMessageType.error,
        deviceId: 'device-err',
        errorMessage: 'Connection failed',
      );

      final json = message.toJson();
      expect(json['error'], 'Connection failed');
      expect(json['entries'], isNull);
    });

    test('syncAck has no entries', () {
      const message = SyncMessage(
        type: SyncMessageType.syncAck,
        deviceId: 'device-ack',
      );

      final json = message.toJson();
      expect(json['type'], 'syncAck');
      expect(json['entries'], isNull);
      expect(json['error'], isNull);
    });
  });

  group('WebSocketSyncService', () {
    late WebSocketSyncService service;

    setUp(() {
      service = WebSocketSyncService();
    });

    tearDown(() {
      service.dispose();
    });

    test('starts disconnected', () {
      expect(service.isConnected, isFalse);
    });

    test('connects to unreachable address', () async {
      final result = await service.connect('192.0.2.1', 99999)
          .timeout(const Duration(seconds: 3), onTimeout: () => false);
      expect(result, isFalse);
      expect(service.isConnected, isFalse);
    });
  });
}
