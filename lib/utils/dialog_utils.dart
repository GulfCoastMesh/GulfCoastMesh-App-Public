import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../connector/meshcore_connector.dart';
import '../l10n/l10n.dart';
import '../models/contact.dart';

const String kKofiUrl = 'https://ko-fi.com/gulfcoastmesh';

/// Shows a confirmation dialog before disconnecting from the device.
/// Returns true if user confirmed and disconnect completed, false otherwise.
Future<bool> showDisconnectDialog(
  BuildContext context,
  MeshCoreConnector connector,
) async {
  final l10n = context.l10n;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.dialog_disconnect),
      content: Text(l10n.dialog_disconnectConfirm),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.common_cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(l10n.common_disconnect),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    await connector.disconnect();
    return true;
  }
  return false;
}

/// Shows a confirmation dialog before deleting a channel.
/// Returns true if the user confirmed deletion.
Future<bool> showDeleteChannelDialog(BuildContext context, String name) async {
  final l10n = context.l10n;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.channels_deleteChannel),
      content: Text(l10n.channels_deleteChannelConfirm(name)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.common_cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(l10n.common_delete),
        ),
      ],
    ),
  );
  return confirmed == true;
}

/// Shows a dialog to set or clear a local nickname for [contact]. The
/// nickname only changes how the contact appears in this app — it is never
/// sent over the mesh.
Future<void> showRenameContactDialog(
  BuildContext context,
  MeshCoreConnector connector,
  Contact contact,
) async {
  final l10n = context.l10n;
  final controller = TextEditingController(text: contact.nickname ?? '');
  final result = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.contacts_nickname),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(hintText: contact.name),
        onSubmitted: (value) => Navigator.pop(context, value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.common_cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: Text(l10n.common_save),
        ),
      ],
    ),
  );
  controller.dispose();
  if (result == null) return;
  await connector.setContactNickname(contact, result);
}

/// Shows a warning dialog before flashing a custom, unverified firmware
/// file. Returns true if the user chose to continue.
Future<bool> showLocalFirmwareWarningDialog(BuildContext context) async {
  final l10n = context.l10n;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.ota_localFirmwareWarningTitle),
      content: Text(l10n.ota_localFirmwareWarningBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.common_cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(l10n.common_continue),
        ),
      ],
    ),
  );
  return confirmed == true;
}

/// One-time "support the community" dialog shown 24h after first launch.
Future<void> showSupportPromptDialog(BuildContext context) async {
  final l10n = context.l10n;
  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.supportPrompt_title),
      content: Text(l10n.supportPrompt_message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.supportPrompt_dismiss),
        ),
        FilledButton(
          onPressed: () async {
            Navigator.pop(context);
            await launchUrl(
              Uri.parse(kKofiUrl),
              mode: LaunchMode.externalApplication,
            );
          },
          child: Text(l10n.supportPrompt_kofiButton),
        ),
      ],
    ),
  );
}
