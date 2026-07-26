import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/app_database.dart' as db;
import '../../domain/entities/sync_entry.dart';
import 'peer_discovery_service.dart';
import 'web_socket_sync_service.dart';

class SyncService {
  final db.AppDatabase _database;
  final PeerDiscoveryService _peerDiscovery;
  final WebSocketSyncService _webSocketService;
  StreamSubscription<SyncMessage>? _syncSubscription;
  final _uuid = const Uuid();

  SyncService(this._database)
    : _peerDiscovery = PeerDiscoveryService(),
      _webSocketService = WebSocketSyncService();

  PeerDiscoveryService get peerDiscovery => _peerDiscovery;
  WebSocketSyncService get webSocketService => _webSocketService;

  static const _syncableTables = [
    'categories',
    'category_attributes',
    'products',
    'product_attributes',
    'stock_movements',
    'customers',
    'orders',
    'order_items',
    'payments',
    'invoices',
    'invoice_items',
    'expenses',
    'employees',
  ];

  Future<void> initialize(String deviceId, String deviceName) async {
    await _peerDiscovery.startDiscovery(deviceId, deviceName);
    _listenForIncomingSync();
  }

  Future<void> dispose() async {
    await _syncSubscription?.cancel();
    _syncSubscription = null;
    await _peerDiscovery.stopDiscovery();
    _webSocketService.dispose();
  }

  void _listenForIncomingSync() {
    _syncSubscription?.cancel();
    _syncSubscription = _webSocketService.messageStream.listen((message) async {
      switch (message.type) {
        case SyncMessageType.syncRequest:
          await _handleSyncRequest(message);
          break;
        case SyncMessageType.syncResponse:
          await _handleSyncResponse(message);
          break;
        case SyncMessageType.syncAck:
          debugPrint('Sync acknowledged by ${message.deviceId}');
          break;
        case SyncMessageType.error:
          debugPrint('Sync error: ${message.errorMessage}');
          break;
      }
    });
  }

  Future<void> syncWithPeer(SyncPeer peer) async {
    if (peer.ipAddress == null) return;

    final connected = await _webSocketService.connect(
      peer.ipAddress!,
      AppConstants.mdnSServicePort,
    );

    if (!connected) return;

    final pendingEntries = await _getPendingEntries();
    if (pendingEntries.isNotEmpty) {
      final domainEntries = pendingEntries
          .map(
            (row) => SyncEntry(
              id: row.id,
              entityTable: row.entityTable,
              recordId: row.recordId,
              operation: row.operation,
              payloadJson: row.payloadJson,
              status: row.status,
              deviceId: row.deviceId,
              createdAt: row.createdAt,
              syncedAt: row.syncedAt,
            ),
          )
          .toList();

      _webSocketService.sendSyncRequest(_getDeviceId(), domainEntries);
    }
  }

  Future<void> _handleSyncRequest(SyncMessage message) async {
    try {
      for (final entryData in message.entries ?? []) {
        await _applyRemoteEntry(entryData);
      }
      _webSocketService.sendSyncAck(_getDeviceId());
    } catch (e) {
      _webSocketService.sendError(_getDeviceId(), e.toString());
    }
  }

  Future<void> _handleSyncResponse(SyncMessage message) async {
    try {
      for (final entryData in message.entries ?? []) {
        await _applyRemoteEntry(entryData);
      }

      final pendingEntries = await _getPendingEntries();
      for (final entry in pendingEntries) {
        await _database.customStatement(
          'UPDATE sync_queue SET status = ?, synced_at = ? WHERE id = ?',
          ['SYNCED', DateTime.now().toIso8601String(), entry.id],
        );
      }
    } catch (e) {
      debugPrint('Error applying sync response: $e');
    }
  }

  Future<void> _applyRemoteEntry(Map<String, dynamic> entryData) async {
    final entityTable = entryData['entityTable'] as String?;
    final operation = entryData['operation'] as String?;
    final payloadJson = entryData['payloadJson'] as String?;
    final recordId = entryData['recordId'] as String?;

    if (entityTable == null ||
        operation == null ||
        !_syncableTables.contains(entityTable))
      return;
    if (payloadJson == null || recordId == null) return;

    final payload = jsonDecode(payloadJson) as Map<String, dynamic>;

    switch (operation) {
      case 'UPSERT':
        await _upsertRecord(entityTable, recordId, payload);
        break;
      case 'DELETE':
        await _deleteRecord(entityTable, recordId);
        break;
    }
  }

  Future<void> _upsertRecord(
    String table,
    String id,
    Map<String, dynamic> payload,
  ) async {
    final sanitizedEntries = payload.entries.where((e) {
      final key = e.key;
      return RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]*$').hasMatch(key);
    }).toList();

    if (sanitizedEntries.isEmpty) return;

    final columns = sanitizedEntries.map((e) => e.key).toList();
    final values = sanitizedEntries.map((e) => e.value).toList();
    final placeholders = List.generate(columns.length, (_) => '?').join(', ');
    final columnNames = columns.join(', ');

    await _database.customStatement(
      'INSERT OR REPLACE INTO $table (id, $columnNames) VALUES (?, $placeholders)',
      [id, ...values],
    );
  }

  Future<void> _deleteRecord(String table, String id) async {
    await _database.customStatement('DELETE FROM $table WHERE id = ?', [id]);
  }

  Future<List<db.SyncQueueData>> _getPendingEntries() async {
    return await (_database.select(_database.syncQueue)
          ..where((t) => t.status.equals('PENDING'))
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]))
        .get();
  }

  String _getDeviceId() {
    return _uuid.v4();
  }

  Future<void> addSyncEntry({
    required String entityTable,
    required String recordId,
    required String operation,
    Map<String, dynamic>? payload,
  }) async {
    if (!_syncableTables.contains(entityTable)) return;

    await _database
        .into(_database.syncQueue)
        .insert(
          db.SyncQueueCompanion(
            entityTable: Value(entityTable),
            recordId: Value(recordId),
            operation: Value(operation),
            payloadJson: Value(payload != null ? jsonEncode(payload) : '{}'),
            status: const Value('PENDING'),
            deviceId: Value(_getDeviceId()),
            createdAt: Value(DateTime.now()),
          ),
        );
  }
}
