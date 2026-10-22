import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../models/analyzer_packet.dart';
import '../services/mesh_analyzer_state.dart';
import '../theme/app_colors.dart';
import 'analyzer_surface.dart';

class AnalyzerPacketLog extends StatelessWidget {
  const AnalyzerPacketLog({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MeshAnalyzerState>(
      builder: (context, state, child) {
        final packets = state.packets;
        final l10n = context.l10n;

        return Column(
          children: [
            _buildHeader(context, state, l10n),
            _buildFilterChips(context, state, l10n),
            Expanded(
              child: packets.isEmpty
                  ? Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.wifi_off,
                              size: 48,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.analyzer_noPackets,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.5),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 8),
                      itemCount: packets.length,
                      findChildIndexCallback: (key) {
                        if (key is! ObjectKey) return null;
                        final index = packets.indexOf(
                          key.value as AnalyzerPacket,
                        );
                        return index < 0 ? null : index;
                      },
                      itemBuilder: (context, index) {
                        final packet = packets[index];
                        return AnalyzerArrival(
                          key: ObjectKey(packet),
                          animate:
                              DateTime.now().difference(packet.timestamp) <
                              const Duration(seconds: 1),
                          child: _PacketTile(packet: packet),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    MeshAnalyzerState state,
    dynamic l10n,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.list_alt,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.analyzer_packets,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${state.totalPacketCount}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: Icon(
              state.isPaused ? Icons.play_arrow : Icons.pause,
              size: 18,
            ),
            tooltip: state.isPaused
                ? l10n.analyzer_resume
                : l10n.analyzer_pause,
            onPressed: state.togglePause,
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18),
            tooltip: l10n.analyzer_clear,
            onPressed: state.clearPackets,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(
    BuildContext context,
    MeshAnalyzerState state,
    dynamic l10n,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FilterChip(
              label: l10n.analyzer_filterAll,
              selected: state.filter == AnalyzerPacketFilter.all,
              onTap: () => state.setFilter(AnalyzerPacketFilter.all),
            ),
            const SizedBox(width: 4),
            _FilterChip(
              label: l10n.analyzer_filterDM,
              selected: state.filter == AnalyzerPacketFilter.dm,
              color: colorScheme.primary,
              onTap: () => state.setFilter(AnalyzerPacketFilter.dm),
            ),
            const SizedBox(width: 4),
            _FilterChip(
              label: l10n.analyzer_filterChannel,
              selected: state.filter == AnalyzerPacketFilter.channel,
              color: context.appColors.connected,
              onTap: () => state.setFilter(AnalyzerPacketFilter.channel),
            ),
            const SizedBox(width: 4),
            _FilterChip(
              label: l10n.analyzer_filterAdvert,
              selected: state.filter == AnalyzerPacketFilter.advert,
              color: colorScheme.tertiary,
              onTap: () => state.setFilter(AnalyzerPacketFilter.advert),
            ),
            const SizedBox(width: 4),
            _FilterChip(
              label: l10n.analyzer_filterDiscovery,
              selected: state.filter == AnalyzerPacketFilter.discovery,
              // Colors.purple: 4th slot of a fixed packet-type legend; not a
              // themed semantic role.
              color: Colors.purple,
              onTap: () => state.setFilter(AnalyzerPacketFilter.discovery),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = color ?? Theme.of(context).colorScheme.primary;
    return Material(
      color: selected ? baseColor.withValues(alpha: 0.15) : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(
              color: selected
                  ? baseColor
                  : Theme.of(context).colorScheme.outlineVariant,
              width: selected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              color: selected
                  ? baseColor
                  : Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }
}

class _PacketTile extends StatefulWidget {
  final AnalyzerPacket packet;

  const _PacketTile({required this.packet});

  @override
  State<_PacketTile> createState() => _PacketTileState();
}

class _PacketTileState extends State<_PacketTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final packet = widget.packet;
    final typeColor = _typeColor(packet.type);
    final typeIcon = _typeIcon(packet.type);
    final timeStr = _formatTime(packet.timestamp);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Theme.of(
                  context,
                ).colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: typeColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(typeIcon, size: 14, color: typeColor),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      packet.senderName.isEmpty ? 'Unknown' : packet.senderName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    timeStr,
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  _buildBadge(
                    packet.payloadTypeLabel,
                    typeColor.withValues(alpha: 0.15),
                    typeColor,
                  ),
                  _buildBadge(
                    packet.routeTypeLabel,
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                    Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  _buildBadge(
                    'SNR ${packet.snr.toStringAsFixed(1)}',
                    _snrColor(packet.snr).withValues(alpha: 0.15),
                    _snrColor(packet.snr),
                  ),
                  _buildBadge(
                    'RSSI ${packet.rssi}',
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                    Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  if (packet.hopCount > 0) ...[
                    _buildBadge(
                      '${packet.hopCount} hop${packet.hopCount == 1 ? '' : 's'}',
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                      Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ],
                ],
              ),
              if (_expanded) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _detailRow(
                        context,
                        'Type',
                        packet.type.name.toUpperCase(),
                      ),
                      _detailRow(context, 'Payload', packet.payloadTypeLabel),
                      _detailRow(context, 'Route', packet.routeTypeLabel),
                      _detailRow(context, 'Hops', '${packet.hopCount}'),
                      if (packet.channelName != null)
                        _detailRow(context, 'Channel', packet.channelName!),
                      if (packet.pathHex.isNotEmpty)
                        _detailRow(context, 'Path', packet.pathHex),
                      const SizedBox(height: 4),
                      Text(
                        'Raw: ${packet.rawHex}',
                        style: TextStyle(
                          fontSize: 10,
                          fontFamily: 'monospace',
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  Widget _detailRow(BuildContext context, String key, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              key,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 10,
                fontFamily: 'monospace',
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _typeColor(AnalyzerPacketType type) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (type) {
      case AnalyzerPacketType.dm:
        return colorScheme.primary;
      case AnalyzerPacketType.channel:
        return context.appColors.connected;
      case AnalyzerPacketType.advert:
        return colorScheme.tertiary;
      case AnalyzerPacketType.discovery:
        // Colors.purple: 4th slot of a fixed packet-type legend; not a
        // themed semantic role.
        return Colors.purple;
    }
  }

  IconData _typeIcon(AnalyzerPacketType type) {
    switch (type) {
      case AnalyzerPacketType.dm:
        return Icons.chat_bubble;
      case AnalyzerPacketType.channel:
        return Icons.forum;
      case AnalyzerPacketType.advert:
        return Icons.campaign;
      case AnalyzerPacketType.discovery:
        return Icons.radar;
    }
  }

  Color _snrColor(double snr) {
    final colorScheme = Theme.of(context).colorScheme;
    if (snr >= 5) return context.appColors.connected;
    if (snr >= 0) return colorScheme.tertiary;
    return colorScheme.error;
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:'
        '${time.second.toString().padLeft(2, '0')}';
  }
}
