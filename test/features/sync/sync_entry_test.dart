import 'package:flutter_test/flutter_test.dart';
import 'package:trackbit/features/sync/domain/entities/sync_entry.dart';

void main() {
  group('SyncEntry', () {
    test('creates with required fields', () {
      final entry = SyncEntry(
        id: 1,
        entityTable: 'products',
        recordId: 'prod-1',
        operation: 'UPSERT',
        createdAt: DateTime(2024),
      );

      expect(entry.id, 1);
      expect(entry.entityTable, 'products');
      expect(entry.recordId, 'prod-1');
      expect(entry.operation, 'UPSERT');
      expect(entry.status, 'PENDING');
      expect(entry.syncedAt, isNull);
    });

    test('equality based on id, table, record, operation, status', () {
      final e1 = SyncEntry(
        id: 1,
        entityTable: 'products',
        recordId: 'p1',
        operation: 'UPSERT',
        createdAt: DateTime(2024),
      );
      final e2 = SyncEntry(
        id: 1,
        entityTable: 'products',
        recordId: 'p1',
        operation: 'UPSERT',
        createdAt: DateTime(2025),
      );

      expect(e1, equals(e2));
    });

    test('inequality with different status', () {
      final e1 = SyncEntry(
        id: 1,
        entityTable: 'products',
        recordId: 'p1',
        operation: 'UPSERT',
        status: 'PENDING',
        createdAt: DateTime(2024),
      );
      final e2 = SyncEntry(
        id: 1,
        entityTable: 'products',
        recordId: 'p1',
        operation: 'UPSERT',
        status: 'SYNCED',
        createdAt: DateTime(2024),
      );

      expect(e1, isNot(equals(e2)));
    });
  });

  group('SyncPeer', () {
    test('creates with required fields', () {
      final peer = SyncPeer(
        id: 'peer-1',
        deviceId: 'dev-1',
        deviceName: 'TrackBit Office',
        lastSeen: DateTime(2024),
      );

      expect(peer.id, 'peer-1');
      expect(peer.deviceId, 'dev-1');
      expect(peer.deviceName, 'TrackBit Office');
      expect(peer.isActive, isFalse);
      expect(peer.ipAddress, isNull);
    });

    test('equality based on id, deviceId, deviceName, isActive', () {
      final p1 = SyncPeer(
        id: 'p1',
        deviceId: 'd1',
        deviceName: 'Device A',
        ipAddress: '192.168.1.1',
        lastSeen: DateTime(2024),
        isActive: true,
      );
      final p2 = SyncPeer(
        id: 'p1',
        deviceId: 'd1',
        deviceName: 'Device A',
        ipAddress: '10.0.0.1',
        lastSeen: DateTime(2025),
        isActive: true,
      );

      expect(p1, equals(p2));
    });

    test('inequality with different isActive', () {
      final p1 = SyncPeer(
        id: 'p1',
        deviceId: 'd1',
        deviceName: 'Device A',
        lastSeen: DateTime(2024),
        isActive: false,
      );
      final p2 = SyncPeer(
        id: 'p1',
        deviceId: 'd1',
        deviceName: 'Device A',
        lastSeen: DateTime(2024),
        isActive: true,
      );

      expect(p1, isNot(equals(p2)));
    });
  });
}
