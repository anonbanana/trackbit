import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/sync_entry.dart';

class PeerDiscoveryService {
  RawDatagramSocket? _socket;
  Timer? _broadcastTimer;
  final _peers = <String, SyncPeer>{};
  final _peersController = StreamController<List<SyncPeer>>.broadcast();

  Stream<List<SyncPeer>> get peersStream => _peersController.stream;
  List<SyncPeer> get currentPeers => List.unmodifiable(_peers.values);

  Future<void> startDiscovery(String deviceId, String deviceName) async {
    await stopDiscovery();

    try {
      _socket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        AppConstants.mdnSServicePort,
        reuseAddress: true,
      );

      _socket!.listen(
        (event) {
          if (event == RawSocketEvent.read) {
            _handleBroadcast(_socket!.receive());
          }
        },
        onError: (e) {
          debugPrint('Discovery socket error: $e');
        },
      );

      _broadcastDevice(deviceId, deviceName);
      _broadcastTimer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => _broadcastDevice(deviceId, deviceName),
      );
    } catch (e) {
      debugPrint('Failed to start discovery: $e');
    }
  }

  Future<void> stopDiscovery() async {
    _broadcastTimer?.cancel();
    _broadcastTimer = null;
    _socket?.close();
    _socket = null;
    _peers.clear();
    _peersController.add([]);
  }

  void _broadcastDevice(String deviceId, String deviceName) {
    if (_socket == null) return;

    try {
      final message = jsonEncode({
        'type': 'trackbit_discovery',
        'deviceId': deviceId,
        'deviceName': deviceName,
      });

      final bytes = utf8.encode(message);
      _socket!.send(
        bytes,
        InternetAddress('255.255.255.255'),
        AppConstants.mdnSServicePort,
      );
    } catch (e) {
      debugPrint('Failed to broadcast: $e');
    }
  }

  void _handleBroadcast(Datagram? datagram) {
    if (datagram == null) return;

    try {
      final message = utf8.decode(datagram.data);
      final json = jsonDecode(message) as Map<String, dynamic>;

      if (json['type'] != 'trackbit_discovery') return;

      final deviceId = json['deviceId'] as String?;
      final deviceName = json['deviceName'] as String?;
      if (deviceId == null || deviceName == null) return;

      final now = DateTime.now();
      final peer = SyncPeer(
        id: deviceId,
        deviceId: deviceId,
        deviceName: deviceName,
        ipAddress: datagram.address.address,
        lastSeen: now,
        isActive: true,
      );

      _peers[deviceId] = peer;
      _peersController.add(List.unmodifiable(_peers.values));

      _expireOldPeers();
    } catch (_) {}
  }

  void _expireOldPeers() {
    final now = DateTime.now();
    final expired = _peers.entries
        .where((e) => now.difference(e.value.lastSeen).inSeconds > 15)
        .map((e) => e.key)
        .toList();

    for (final id in expired) {
      _peers.remove(id);
    }

    if (expired.isNotEmpty) {
      _peersController.add(List.unmodifiable(_peers.values));
    }
  }
}
