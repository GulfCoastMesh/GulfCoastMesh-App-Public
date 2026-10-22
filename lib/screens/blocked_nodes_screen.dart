import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../connector/meshcore_protocol.dart';
import '../l10n/l10n.dart';
import '../models/blocked_node.dart';
import '../services/blocked_nodes_service.dart';
import '../widgets/adaptive_app_bar_title.dart';

class BlockedNodesScreen extends StatelessWidget {
  const BlockedNodesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final service = context.watch<BlockedNodesService>();
    final entries = service.entries;

    return Scaffold(
      appBar: AppBar(
        title: AdaptiveAppBarTitle(l10n.blockedNodes_title),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: entries.isEmpty
                ? null
                : () => _confirmUnblockAll(context, service),
            child: Text(l10n.blockedNodes_unblockAll),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _HowItWorksCard(),
            const SizedBox(height: 8),
            if (entries.isEmpty)
              const _EmptyState()
            else
              for (final node in entries)
                _BlockedNodeTile(
                  node: node,
                  onUnblock: () {
                    final name = _nodeName(context, node);
                    service.unblock(node.publicKeyHex);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          context.l10n.blockedNodes_unblocked(name),
                        ),
                      ),
                    );
                  },
                ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmUnblockAll(
    BuildContext context,
    BlockedNodesService service,
  ) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.blockedNodes_unblockAll),
        content: Text(l10n.blockedNodes_unblockAllConfirm(service.count)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.common_cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.blockedNodes_unblockAll),
          ),
        ],
      ),
    );
    if (confirmed == true) await service.unblockAll();
  }
}

String _nodeName(BuildContext context, BlockedNode node) {
  final name = node.name.trim();
  return name.isEmpty ? context.l10n.blockedNodes_unknownNode : name;
}

String _typeLabel(BuildContext context, int type) {
  final l10n = context.l10n;
  switch (type) {
    case advTypeChat:
      return l10n.map_chat;
    case advTypeRepeater:
      return l10n.map_repeater;
    case advTypeRoom:
      return l10n.map_room;
    case advTypeSensor:
      return l10n.map_sensor;
    default:
      return l10n.blockedNodes_unknownNode;
  }
}

IconData _typeIcon(int type) {
  switch (type) {
    case advTypeChat:
      return Icons.person;
    case advTypeRepeater:
      return Icons.router;
    case advTypeRoom:
      return Icons.meeting_room;
    case advTypeSensor:
      return Icons.sensors;
    default:
      return Icons.device_unknown;
  }
}

// intentionally fixed: same node type colors as the map markers
Color _typeColor(int type) {
  switch (type) {
    case advTypeChat:
      return Colors.blue;
    case advTypeRepeater:
      return Colors.green;
    case advTypeRoom:
      return Colors.purple;
    case advTypeSensor:
      return Colors.orange;
    default:
      return Colors.grey;
  }
}

class _HowItWorksCard extends StatelessWidget {
  const _HowItWorksCard();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lines = [
      (Icons.visibility_off_outlined, l10n.blockedNodes_infoHidden),
      (Icons.notifications_off_outlined, l10n.blockedNodes_infoMuted),
      (Icons.save_outlined, l10n.blockedNodes_infoKept),
      (Icons.route_outlined, l10n.blockedNodes_infoRelay),
      (Icons.tag, l10n.blockedNodes_infoChannels),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.blockedNodes_howItWorks,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            for (final (icon, text) in lines)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        text,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
      child: Column(
        children: [
          Icon(
            Icons.block,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.blockedNodes_emptyTitle,
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.blockedNodes_emptyHint,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _BlockedNodeTile extends StatelessWidget {
  final BlockedNode node;
  final VoidCallback onUnblock;

  const _BlockedNodeTile({required this.node, required this.onUnblock});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final date = DateFormat.yMMMd(locale).format(node.blockedAt);
    final shortKey = node.publicKeyHex.length > 8
        ? node.publicKeyHex.substring(0, 8)
        : node.publicKeyHex;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _typeColor(node.type),
        child: Icon(_typeIcon(node.type), color: Colors.white, size: 20),
      ),
      title: Text(_nodeName(context, node)),
      subtitle: Text(
        '${_typeLabel(context, node.type)} · $shortKey · '
        '${l10n.blockedNodes_blockedOn(date)}',
      ),
      trailing: TextButton(
        onPressed: onUnblock,
        child: Text(l10n.blockedNodes_unblock),
      ),
    );
  }
}
