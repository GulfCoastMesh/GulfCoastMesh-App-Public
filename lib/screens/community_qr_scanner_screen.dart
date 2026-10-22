import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../connector/meshcore_connector.dart';
import '../helpers/channel_slot_helper.dart';
import '../l10n/l10n.dart';
import '../models/community.dart';
import '../storage/community_store.dart';
import '../theme/app_colors.dart';
import '../widgets/adaptive_app_bar_title.dart';
import '../widgets/qr_scanner_widget.dart';

/// Screen for scanning community QR codes to join communities.
///
/// After successful scan, the user can:
/// 1. Join the community (saves to local storage)
/// 2. Optionally add the Community Public Channel to the device
class CommunityQrScannerScreen extends StatefulWidget {
  const CommunityQrScannerScreen({super.key});

  @override
  State<CommunityQrScannerScreen> createState() =>
      _CommunityQrScannerScreenState();
}

class _CommunityQrScannerScreenState extends State<CommunityQrScannerScreen> {
  final CommunityStore _communityStore = CommunityStore();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AdaptiveAppBarTitle(context.l10n.community_scanQr),
        centerTitle: true,
      ),
      body: _isProcessing
          ? const Center(child: CircularProgressIndicator())
          : QrScannerWidget(
              onScanned: (data) => _handleScannedData(context, data),
              validator: Community.isValidQrData,
              onValidationFailed: (_) => _showInvalidQrError(context),
              instructions: context.l10n.community_scanInstructions,
            ),
    );
  }

  Future<void> _handleScannedData(BuildContext context, String data) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Parse the community data
      final community = Community.fromQrData(const Uuid().v4(), data);

      // Check if this community already exists
      final existing = await _communityStore.findByCommunityId(
        community.communityId,
      );

      if (existing != null) {
        if (context.mounted) {
          _showAlreadyMemberDialog(context, existing);
        }
        return;
      }

      // Show confirmation dialog
      if (context.mounted) {
        await _showJoinConfirmationDialog(context, community);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.community_invalidQrCode),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showInvalidQrError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.community_invalidQrCode),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAlreadyMemberDialog(BuildContext context, Community community) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.community_alreadyMember),
        content: Text(
          context.l10n.community_alreadyMemberMessage(community.name),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            child: Text(context.l10n.common_ok),
          ),
        ],
      ),
    );
  }

  Future<void> _showJoinConfirmationDialog(
    BuildContext context,
    Community community,
  ) async {
    bool addPublicChannel = true;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(context.l10n.community_joinTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.community_joinConfirmation(community.name)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.groups,
                    color: Theme.of(dialogContext).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          community.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'ID: ${community.shortCommunityId}...',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              dialogContext,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // A community QR carries no proof of who issued it, so the
              // decision to trust it is entirely the user's.
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.gpp_maybe_outlined,
                    size: 20,
                    color: Theme.of(dialogContext).colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.l10n.community_joinTrustWarning,
                      style: Theme.of(dialogContext).textTheme.bodySmall
                          ?.copyWith(
                            color: Theme.of(dialogContext).colorScheme.error,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              CheckboxListTile(
                value: addPublicChannel,
                onChanged: (value) {
                  setDialogState(() {
                    addPublicChannel = value ?? true;
                  });
                },
                title: Text(context.l10n.community_addPublicChannel),
                subtitle: Text(context.l10n.community_addPublicChannelHint),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(context.l10n.common_cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(context.l10n.community_join),
            ),
          ],
        ),
      ),
    );

    if (result == true && context.mounted) {
      await _joinCommunity(context, community, addPublicChannel);
    } else if (context.mounted) {
      // User cancelled - go back
      Navigator.pop(context);
    }
  }

  Future<void> _joinCommunity(
    BuildContext context,
    Community community,
    bool addPublicChannel,
  ) async {
    // Save community to local storage
    await _communityStore.addCommunity(community);

    // Optionally add the community public channel to the device
    if (addPublicChannel && context.mounted) {
      final connector = context.read<MeshCoreConnector>();
      final nextIndex = firstAvailableChannelIndex(
        connector.channels,
        connector.maxChannels,
      );

      if (nextIndex != null) {
        final psk = community.deriveCommunityPublicPsk();
        final channelName = '${community.name} Public';
        try {
          await connector.setChannel(nextIndex, channelName, psk);
        } catch (error) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  context.l10n.channels_channelAddFailed(error.toString()),
                ),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.channels_channelSlotsFull)),
        );
      }
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.community_joined(community.name)),
          backgroundColor: context.appColors.connected,
        ),
      );

      // Return to previous screen
      Navigator.pop(context, community);
    }
  }
}
