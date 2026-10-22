import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../connector/meshcore_connector.dart';
import '../connector/meshcore_protocol.dart';
import '../l10n/l10n.dart';
import '../models/contact.dart';
import '../theme/app_colors.dart';
import '../utils/dialog_utils.dart';
import '../utils/emoji_utils.dart';
import '../widgets/contact_avatar.dart';
import '../widgets/repeater_login_dialog.dart';
import '../widgets/room_login_dialog.dart';
import '../screens/chat_screen.dart';
import '../screens/repeater_hub_screen.dart';

class ContactDetailPanel extends StatelessWidget {
  final Contact contact;
  final VoidCallback? onShareContact;
  final VoidCallback? onShareZeroHop;

  const ContactDetailPanel({
    super.key,
    required this.contact,
    this.onShareContact,
    this.onShareZeroHop,
  });

  @override
  Widget build(BuildContext context) {
    final connector = context.watch<MeshCoreConnector>();
    final live = connector.contacts.cast<Contact?>().firstWhere(
      (c) => c?.publicKeyHex == contact.publicKeyHex,
      orElse: () => contact,
    )!;
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
        children: [
          Center(
            child: Column(
              children: [
                _buildAvatar(live, size: 88),
                const SizedBox(height: 16),
                Text(
                  live.displayName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  live.typeLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (live.hasLocation) ...[
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: context.appColors.connected,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.contacts_hasLocation,
                        style: TextStyle(
                          color: context.appColors.connected,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 28),
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.45,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _ActionTile(
                  icon: Icons.chat_bubble_outline,
                  label: live.type == advTypeRepeater
                      ? l10n.contacts_manageRepeater
                      : l10n.contacts_sendMessage,
                  onTap: () => _openChat(context, live),
                ),
                const Divider(height: 1),
                _ActionTile(
                  icon: live.isFavorite ? Icons.star : Icons.star_border,
                  iconColor: theme.colorScheme.tertiary,
                  label: live.isFavorite
                      ? l10n.contacts_removeFromFavorites
                      : l10n.contacts_addToFavorites,
                  onTap: () => connector.toggleContactFavorite(live),
                ),
                const Divider(height: 1),
                _ActionTile(
                  icon: Icons.edit_outlined,
                  label: l10n.contacts_nickname,
                  onTap: () =>
                      showRenameContactDialog(context, connector, live),
                ),
                if (onShareContact != null) ...[
                  const Divider(height: 1),
                  _ActionTile(
                    icon: Icons.ios_share_outlined,
                    label: l10n.contacts_ShareContact,
                    onTap: onShareContact!,
                  ),
                ],
                if (onShareZeroHop != null) ...[
                  const Divider(height: 1),
                  _ActionTile(
                    icon: Icons.connect_without_contact,
                    label: l10n.contacts_ShareContactZeroHop,
                    onTap: onShareZeroHop!,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.contacts_infoSection,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.45,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _InfoRow(label: l10n.contacts_nameLabel, value: live.name),
                const Divider(height: 1),
                _InfoRow(
                  label: l10n.contacts_lastAdvert,
                  value: _formatTime(live.lastSeen),
                ),
                const Divider(height: 1),
                _InfoRow(label: 'Key', value: live.shortPubKeyHex),
              ],
            ),
          ),
          if (live.hasLocation) ...[
            const SizedBox(height: 24),
            Text(
              l10n.contacts_locationSection,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 180,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(live.latitude!, live.longitude!),
                    initialZoom: 11,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.none,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'gulf_coast_mesh_app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(live.latitude!, live.longitude!),
                          width: 36,
                          height: 36,
                          child: Icon(
                            Icons.location_on,
                            color: theme.colorScheme.primary,
                            size: 36,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(Contact contact, {double size = 64}) {
    final displayName = contact.displayName;
    final emoji = firstEmoji(displayName);
    if (emoji != null) {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: AppColors.colorForName(displayName),
        child: Text(emoji, style: TextStyle(fontSize: size * 0.4)),
      );
    }
    return ContactAvatar(name: displayName, size: size);
  }

  void _openChat(BuildContext context, Contact contact) {
    if (contact.type == advTypeRepeater) {
      RepeaterLoginDialog.show(
        context,
        repeater: contact,
        onLogin: (password) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  RepeaterHubScreen(repeater: contact, password: password),
            ),
          );
        },
      );
      return;
    }
    if (contact.type == advTypeRoom) {
      showDialog(
        context: context,
        builder: (context) => RoomLoginDialog(
          room: contact,
          onLogin: (password) {
            context.read<MeshCoreConnector>().markContactRead(
              contact.publicKeyHex,
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(contact: contact),
              ),
            );
          },
        ),
      );
      return;
    }
    context.read<MeshCoreConnector>().markContactRead(contact.publicKeyHex);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatScreen(contact: contact)),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon, color: iconColor ?? scheme.primary),
      title: Text(
        label,
        style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
