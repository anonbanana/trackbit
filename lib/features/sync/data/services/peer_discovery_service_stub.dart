import 'dart:async';

import '../../domain/entities/sync_entry.dart';

class PeerDiscoveryService {
  final _peersController = StreamController<List<SyncPeer>>.broadcast();

  Stream<List<SyncPeer>> get peersStream => _peersController.stream;
  List<SyncPeer> get currentPeers => [];

  Future<void> startDiscovery(String deviceId, String deviceName) async {
    // UDP broadcast not available on web - peers must connect manually
  }

  Future<void> stopDiscovery() async {
    _peersController.add([]);
  }
}
