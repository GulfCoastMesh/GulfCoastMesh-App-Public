import '../connector/meshcore_connector.dart';
import '../models/channel.dart';
import 'atak_channel_helper.dart';

const String wardrivingChannelDisplayName = '#wardriving';

Channel? findWardrivingChannel(List<Channel> channels) {
  return findHashtagChannel(channels, 'wardriving');
}

Future<Channel?> joinWardrivingChannel(MeshCoreConnector connector) async {
  return joinHashtagChannel(connector, 'wardriving');
}

double powerWattsFromDbm(int? txPowerDbm) {
  if (txPowerDbm == null) return 0.3;
  if (txPowerDbm <= 10) return 0.1;
  if (txPowerDbm <= 14) return 0.3;
  if (txPowerDbm <= 20) return 1.0;
  return 2.0;
}
