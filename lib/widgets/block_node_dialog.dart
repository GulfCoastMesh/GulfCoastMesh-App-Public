import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../models/contact.dart';
import '../services/blocked_nodes_service.dart';

/// Asks the user to confirm blocking [contact]; on confirm blocks it and
/// offers an Undo snackbar. Shared by the Contacts and Map screens.
Future<void> confirmBlockNode(BuildContext context, Contact contact) async {
  final service = context.read<BlockedNodesService>();
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  final name = contact.displayName;
  final colorScheme = Theme.of(context).colorScheme;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.blockedNodes_blockConfirmTitle(name)),
      content: Text(l10n.blockedNodes_blockConfirmBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(l10n.common_cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(
            l10n.blockedNodes_blockConfirmButton,
            style: TextStyle(color: colorScheme.error),
          ),
        ),
      ],
    ),
  );
  if (confirmed != true) return;

  final key = contact.publicKeyHex;
  await service.block(publicKeyHex: key, name: name, type: contact.type);
  messenger.showSnackBar(
    SnackBar(
      content: Text(l10n.blockedNodes_blocked(name)),
      action: SnackBarAction(
        label: l10n.blockedNodes_undo,
        onPressed: () => service.unblock(key),
      ),
    ),
  );
}
