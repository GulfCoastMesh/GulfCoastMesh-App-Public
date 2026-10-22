import 'dart:typed_data';

import 'package:gulf_coast_mesh_app/connector/meshcore_protocol.dart';
import 'package:gulf_coast_mesh_app/models/contact.dart';

Contact blockingTestContact(
  String name, {
  int seed = 1,
  int type = advTypeChat,
  bool hasLocation = false,
}) => Contact(
  publicKey: Uint8List.fromList(List.filled(32, seed)),
  name: name,
  type: type,
  pathLength: 0,
  path: Uint8List(0),
  latitude: hasLocation ? 30.0 : null,
  longitude: hasLocation ? -89.0 : null,
  lastSeen: DateTime.utc(2026, 1, 1),
);
