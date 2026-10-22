import 'package:flutter/material.dart';
import '../connector/meshcore_connector.dart';
import '../l10n/l10n.dart';
import '../theme/app_colors.dart';

class SNRUi {
  final IconData icon;
  final Color color;
  final String text;
  const SNRUi(this.icon, this.color, this.text);
}

List<double> getSNRfromSF(int spreadingFactor) {
  switch (spreadingFactor) {
    case 7:
      return [4.0, -2.0, -4.0, -6.0];
    case 8:
      return [4.0, -4.0, -6.0, -8.0];
    case 9:
      return [4.0, -6.0, -8.0, -10.0];
    case 10:
      return [4.0, -8.0, -10.0, -13.0];
    case 11:
      return [4.0, -10.0, -12.5, -15.0];
    case 12:
      return [4.0, -12.5, -15.0, -18.0];
    default:
      return []; // Or throw Exception('Invalid SF: $spreadingFactor');
  }
}

SNRUi snrUiFromSNR(BuildContext context, double? snr, int? spreadingFactor) {
  final colorScheme = Theme.of(context).colorScheme;
  if (snr == null ||
      spreadingFactor == null ||
      spreadingFactor < 7 ||
      spreadingFactor > 12) {
    return SNRUi(Icons.signal_cellular_off, colorScheme.outline, '—');
  }

  final snrLevels = getSNRfromSF(spreadingFactor);

  IconData icon;
  Color color;
  String text = '${snr.toStringAsFixed(1)} dB';

  if (snr >= snrLevels[0]) {
    icon = Icons.signal_cellular_alt;
    color = context.appColors.connected;
  } else if (snr >= snrLevels[1]) {
    icon = Icons.signal_cellular_alt;
    color = context.appColors.connected;
  } else if (snr >= snrLevels[2]) {
    icon = Icons.signal_cellular_alt;
    color = colorScheme.tertiary;
  } else if (snr >= snrLevels[3]) {
    icon = Icons.signal_cellular_alt_2_bar;
    color = colorScheme.tertiary;
  } else {
    icon = Icons.signal_cellular_alt_1_bar;
    color = colorScheme.error;
  }

  return SNRUi(icon, color, text);
}

class SNRIndicator extends StatefulWidget {
  final MeshCoreConnector connector;

  const SNRIndicator({super.key, required this.connector});

  @override
  State<SNRIndicator> createState() => _SNRIndicatorState();
}

class _SNRIndicatorState extends State<SNRIndicator> {
  @override
  Widget build(BuildContext context) {
    final directRepeaters = widget.connector.directRepeaters;
    final directBestRepeaters = List.of(directRepeaters)
      ..sort((a, b) => (b.ranking).compareTo(a.ranking));
    final directRepeater = directBestRepeaters.isEmpty
        ? null
        : directBestRepeaters.first;

    final colorScheme = Theme.of(context).colorScheme;
    final snrUi = snrUiFromSNR(
      context,
      directBestRepeaters.isNotEmpty ? directRepeater!.snr : null,
      widget.connector.currentSf,
    );

    return InkWell(
      onTap: () {
        if (directRepeater != null) {
          _showFullPathDialog(context, directBestRepeaters);
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(snrUi.icon, size: 18, color: snrUi.color),
                Text(
                  snrUi.text,
                  style: TextStyle(fontSize: 12, color: snrUi.color),
                ),
              ],
            ),
            if (directRepeater != null)
              Text(
                '${directRepeaters.length}: ${directRepeater.pubkeyFirstByte.toRadixString(16).padLeft(2, '0')}: ${_formatLastUpdated(directRepeater.lastUpdated)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }

  String _formatLastUpdated(DateTime lastSeen) {
    final now = DateTime.now();
    final diff = now.difference(lastSeen);
    if (diff.isNegative) {
      return "0s";
    }
    if (diff.inMinutes < 1) {
      return "${diff.inSeconds}s";
    }
    if (diff.inMinutes < 60) {
      return "${diff.inMinutes}m";
    }
    if (diff.inHours < 24) {
      final hours = diff.inHours;
      return "${hours}h";
    }
    final days = diff.inDays;
    return "${days}d";
  }

  void _showFullPathDialog(
    BuildContext context,
    List<DirectRepeater> directBestRepeaters,
  ) {
    final l10n = context.l10n;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.snrIndicator_nearByRepeaters),
        content: SizedBox(
          child: Scrollbar(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: directBestRepeaters.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final repeater = directBestRepeaters[index];
                final snrUi = snrUiFromSNR(
                  context,
                  repeater.snr,
                  widget.connector.currentSf,
                );

                final name = widget.connector.contacts
                    .where((c) => c.publicKey.first == repeater.pubkeyFirstByte)
                    .map((c) => c.name)
                    .firstOrNull;

                return Column(
                  children: [
                    ListTile(
                      leading: Icon(snrUi.icon, color: snrUi.color),
                      title: Text(
                        name ??
                            repeater.pubkeyFirstByte
                                .toRadixString(16)
                                .padLeft(2, '0'),
                      ),
                      subtitle: Text(
                        'SNR: ${repeater.snr.toStringAsFixed(1)} dB\n${l10n.snrIndicator_lastSeen}: ${_formatLastUpdated(repeater.lastUpdated)}',
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.common_close),
          ),
        ],
      ),
    );
  }
}
