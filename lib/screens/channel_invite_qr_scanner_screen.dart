import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../connector/meshcore_connector.dart';
import '../helpers/channel_invite_uri.dart';
import '../helpers/channel_region_scope_prompt.dart';
import '../helpers/channel_slot_helper.dart';
import '../l10n/l10n.dart';
import '../models/mesh_region.dart';
import '../storage/known_regions_store.dart';
import '../widgets/adaptive_app_bar_title.dart';
import '../widgets/qr_scanner_widget.dart';

/// Scan a `meshcore://channel/add` invite QR and add the channel.
class ChannelInviteQrScannerScreen extends StatefulWidget {
  const ChannelInviteQrScannerScreen({super.key});

  @override
  State<ChannelInviteQrScannerScreen> createState() =>
      _ChannelInviteQrScannerScreenState();
}

class _ChannelInviteQrScannerScreenState
    extends State<ChannelInviteQrScannerScreen> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AdaptiveAppBarTitle(context.l10n.channels_scanQrCode),
        centerTitle: true,
      ),
      body: _isProcessing
          ? const Center(child: CircularProgressIndicator())
          : QrScannerWidget(
              onScanned: (data) => _handleScannedData(context, data),
              validator: ChannelInviteUri.isChannelInvite,
              onValidationFailed: (_) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.l10n.channels_invalidInviteQr),
                  ),
                );
              },
              instructions: context.l10n.channels_scanQrCodeDesc,
            ),
    );
  }

  Future<void> _handleScannedData(BuildContext context, String data) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    final ChannelInvite invite;
    try {
      invite = ChannelInviteUri.parse(data);
    } on FormatException {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.channels_invalidInviteQr)),
      );
      setState(() => _isProcessing = false);
      return;
    }

    final connector = context.read<MeshCoreConnector>();
    final nextIndex = firstAvailableChannelIndex(
      connector.channels,
      connector.maxChannels,
    );
    if (nextIndex == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.channels_channelSlotsFull)),
      );
      setState(() => _isProcessing = false);
      return;
    }

    try {
      await connector.setChannel(nextIndex, invite.name, invite.secretBytes);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.channels_channelAddFailed(error.toString()),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      setState(() => _isProcessing = false);
      return;
    }

    final suggested = invite.regionScope;
    if (suggested != null && MeshRegion.isValidRegionName(suggested)) {
      try {
        await connector.setChannelRegionScope(nextIndex, suggested);
        await KnownRegionsStore().add(suggested);
      } catch (_) {
        // The channel itself was added successfully. Let the scope picker
        // repair optional local region metadata instead of treating the QR as
        // invalid and inviting a duplicate scan.
      }
    }

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.channels_channelAdded(invite.name))),
    );

    await promptChannelRegionScope(
      context,
      channelIndex: nextIndex,
      suggestedScope: suggested,
    );

    if (!context.mounted) return;
    Navigator.pop(context, invite);
  }
}
