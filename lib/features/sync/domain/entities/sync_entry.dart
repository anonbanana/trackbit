import 'package:equatable/equatable.dart';

class SyncEntry extends Equatable {
  final int id;
  final String entityTable;
  final String recordId;
  final String operation;
  final String? payloadJson;
  final String status;
  final String? deviceId;
  final DateTime createdAt;
  final DateTime? syncedAt;

  const SyncEntry({
    required this.id,
    required this.entityTable,
    required this.recordId,
    required this.operation,
    this.payloadJson,
    this.status = 'PENDING',
    this.deviceId,
    required this.createdAt,
    this.syncedAt,
  });

  @override
  List<Object?> get props => [id, entityTable, recordId, operation, status];
}

class SyncPeer extends Equatable {
  final String id;
  final String deviceId;
  final String deviceName;
  final String? ipAddress;
  final DateTime lastSeen;
  final bool isActive;

  const SyncPeer({
    required this.id,
    required this.deviceId,
    required this.deviceName,
    this.ipAddress,
    required this.lastSeen,
    this.isActive = false,
  });

  @override
  List<Object?> get props => [id, deviceId, deviceName, isActive];
}
