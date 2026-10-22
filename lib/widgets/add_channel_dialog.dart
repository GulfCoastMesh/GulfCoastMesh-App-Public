import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../connector/meshcore_connector.dart';
import '../helpers/channel_region_scope_prompt.dart';
import '../helpers/channel_slot_helper.dart';
import '../l10n/l10n.dart';
import '../models/channel.dart';
import '../models/community.dart';
import '../screens/channel_invite_qr_scanner_screen.dart';
import '../screens/community_qr_scanner_screen.dart';
import '../storage/community_store.dart';
import 'qr_code_display.dart';

/// Full add/join channel flow (private, public, hashtag, community QR/create).
Future<void> showAddChannelDialog(BuildContext context) async {
  final anchorContext = context;
  final connector = anchorContext.read<MeshCoreConnector>();
  if (!anchorContext.mounted) return;

  final nextIndex = firstAvailableChannelIndex(
    connector.channels,
    connector.maxChannels,
  );
  if (nextIndex == null) {
    ScaffoldMessenger.of(anchorContext).showSnackBar(
      SnackBar(content: Text(anchorContext.l10n.channels_channelSlotsFull)),
    );
    return;
  }
  final hasPublicChannel = connector.channels.any((c) => c.isPublicChannel);
  final communityStore = CommunityStore();
  int? selectedOption;
  bool addCommunityPublicChannel = true;
  final nameController = TextEditingController();
  final pskController = TextEditingController();
  final hashtagController = TextEditingController();

  Future<bool> addChannel(
    String name,
    Uint8List psk, {
    String? successMessage,
  }) async {
    try {
      await connector.setChannel(nextIndex, name, psk);
    } catch (error) {
      if (anchorContext.mounted) {
        ScaffoldMessenger.of(anchorContext).showSnackBar(
          SnackBar(
            content: Text(
              anchorContext.l10n.channels_channelAddFailed(error.toString()),
            ),
            backgroundColor: Theme.of(anchorContext).colorScheme.error,
          ),
        );
      }
      return false;
    }
    if (!anchorContext.mounted) return true;
    ScaffoldMessenger.of(anchorContext).showSnackBar(
      SnackBar(
        content: Text(
          successMessage ?? anchorContext.l10n.channels_channelAdded(name),
        ),
      ),
    );
    return true;
  }

  await showDialog(
    context: anchorContext,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setDialogState) {
        Widget buildOptionTile({
          required int optionIndex,
          required IconData icon,
          required String title,
          required String subtitle,
          bool enabled = true,
        }) {
          final isSelected = selectedOption == optionIndex;
          final colorScheme = Theme.of(dialogContext).colorScheme;
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: enabled
                  ? (isSelected ? colorScheme.primaryContainer : null)
                  : colorScheme.outlineVariant.withValues(alpha: 0.2),
              child: Icon(
                icon,
                color: enabled
                    ? (isSelected ? colorScheme.primary : null)
                    : colorScheme.outline,
              ),
            ),
            title: Text(
              title,
              style: TextStyle(color: enabled ? null : colorScheme.outline),
            ),
            subtitle: Text(
              subtitle,
              style: TextStyle(color: enabled ? null : colorScheme.outline),
            ),
            trailing: enabled ? const Icon(Icons.chevron_right) : null,
            selected: isSelected,
            onTap: enabled
                ? () {
                    setDialogState(() {
                      selectedOption = optionIndex;
                      nameController.clear();
                      pskController.clear();
                      hashtagController.clear();
                    });
                  }
                : null,
          );
        }

        Widget? buildExpandedContent() {
          switch (selectedOption) {
            case 0: // Create Private Channel
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: dialogContext.l10n.channels_channelName,
                        border: const OutlineInputBorder(),
                      ),
                      maxLength: 31,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: () async {
                              final name = nameController.text.trim();
                              if (name.isEmpty) {
                                ScaffoldMessenger.of(
                                  dialogContext,
                                ).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      dialogContext
                                          .l10n
                                          .channels_enterChannelName,
                                    ),
                                  ),
                                );
                                return;
                              }
                              final random = Random.secure();
                              final psk = Uint8List(16);
                              for (int i = 0; i < 16; i++) {
                                psk[i] = random.nextInt(256);
                              }
                              Navigator.pop(dialogContext);
                              final added = await addChannel(name, psk);
                              if (!added || !anchorContext.mounted) return;
                              await promptChannelRegionScope(
                                anchorContext,
                                channelIndex: nextIndex,
                              );
                            },
                            child: Text(dialogContext.l10n.common_create),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );

            case 1: // Join Private Channel
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: dialogContext.l10n.channels_channelName,
                        border: const OutlineInputBorder(),
                      ),
                      maxLength: 31,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: TextField(
                      controller: pskController,
                      decoration: InputDecoration(
                        labelText: dialogContext.l10n.channels_pskHex,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: () async {
                              final name = nameController.text.trim();
                              final pskHex = pskController.text.trim();
                              if (name.isEmpty) {
                                ScaffoldMessenger.of(
                                  dialogContext,
                                ).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      dialogContext
                                          .l10n
                                          .channels_enterChannelName,
                                    ),
                                  ),
                                );
                                return;
                              }
                              Uint8List psk;
                              try {
                                psk = Channel.parsePskHex(pskHex);
                              } on FormatException {
                                ScaffoldMessenger.of(
                                  dialogContext,
                                ).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      dialogContext
                                          .l10n
                                          .channels_pskMustBe32Hex,
                                    ),
                                  ),
                                );
                                return;
                              }
                              Navigator.pop(dialogContext);
                              await addChannel(name, psk);
                            },
                            child: Text(dialogContext.l10n.common_add),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );

            case 2: // Join Public Channel
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () async {
                          final psk = Channel.parsePskHex(
                            Channel.publicChannelPsk,
                          );
                          Navigator.pop(dialogContext);
                          await addChannel(
                            'Public',
                            psk,
                            successMessage:
                                anchorContext.l10n.channels_publicChannelAdded,
                          );
                        },
                        child: Text(dialogContext.l10n.common_add),
                      ),
                    ),
                  ],
                ),
              );

            case 3: // Join Hashtag Channel
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: TextField(
                      controller: hashtagController,
                      decoration: InputDecoration(
                        labelText: dialogContext.l10n.channels_enterHashtag,
                        hintText: dialogContext.l10n.channels_hashtagHint,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.tag),
                      ),
                      maxLength: 31,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: () async {
                              var hashtag = hashtagController.text.trim();
                              if (hashtag.isEmpty) {
                                ScaffoldMessenger.of(
                                  dialogContext,
                                ).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      dialogContext
                                          .l10n
                                          .channels_enterChannelName,
                                    ),
                                  ),
                                );
                                return;
                              }

                              if (hashtag.startsWith('#')) {
                                hashtag = hashtag.substring(1);
                              }
                              final channelName = '#$hashtag';
                              final psk = Channel.derivePskFromHashtag(hashtag);

                              Navigator.pop(dialogContext);
                              await addChannel(channelName, psk);
                            },
                            child: Text(dialogContext.l10n.common_add),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );

            case 4: // Scan channel invite QR
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () async {
                          Navigator.pop(dialogContext);
                          if (anchorContext.mounted) {
                            await Navigator.push(
                              anchorContext,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const ChannelInviteQrScannerScreen(),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.qr_code_scanner),
                        label: Text(dialogContext.l10n.channels_scanQrCode),
                      ),
                    ),
                  ],
                ),
              );

            case 5: // Scan community QR
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          if (!anchorContext.mounted) return;
                          Navigator.push<Community>(
                            anchorContext,
                            MaterialPageRoute(
                              builder: (_) => const CommunityQrScannerScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.qr_code_scanner),
                        label: Text(dialogContext.l10n.community_scanQr),
                      ),
                    ),
                  ],
                ),
              );

            case 6: // Create a community
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: dialogContext.l10n.community_name,
                        hintText: dialogContext.l10n.community_enterName,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.groups),
                      ),
                      maxLength: 31,
                    ),
                  ),
                  CheckboxListTile(
                    value: addCommunityPublicChannel,
                    onChanged: (value) {
                      setDialogState(() {
                        addCommunityPublicChannel = value ?? true;
                      });
                    },
                    title: Text(dialogContext.l10n.community_addPublicChannel),
                    subtitle: Text(
                      dialogContext.l10n.community_addPublicChannelHint,
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: () async {
                              final name = nameController.text.trim();
                              if (name.isEmpty) {
                                ScaffoldMessenger.of(
                                  dialogContext,
                                ).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      dialogContext.l10n.community_enterName,
                                    ),
                                  ),
                                );
                                return;
                              }
                              final community = Community.create(
                                id: const Uuid().v4(),
                                name: name,
                              );
                              // Resolve everything that needs a context
                              // before the first await.
                              final alsoAddChannel = addCommunityPublicChannel;
                              final createdMessage = anchorContext.l10n
                                  .community_created(name);
                              final qrTitle =
                                  anchorContext.l10n.community_qrTitle;
                              final qrInstructions = anchorContext.l10n
                                  .community_qrInstructions(name);

                              await communityStore.addCommunity(community);
                              if (dialogContext.mounted) {
                                Navigator.pop(dialogContext);
                              }
                              if (alsoAddChannel) {
                                // Reuse addChannel so a failed slot write is
                                // reported, and let it carry the one message.
                                final added = await addChannel(
                                  '$name Public',
                                  community.deriveCommunityPublicPsk(),
                                  successMessage: createdMessage,
                                );
                                if (!added) return;
                              } else if (anchorContext.mounted) {
                                ScaffoldMessenger.of(
                                  anchorContext,
                                ).showSnackBar(
                                  SnackBar(content: Text(createdMessage)),
                                );
                              }
                              if (!anchorContext.mounted) return;
                              await QrCodeShareDialog.show(
                                context: anchorContext,
                                data: community.toQrJson(),
                                title: qrTitle,
                                instructions: qrInstructions,
                                embeddedImage: Image.asset(
                                  'assets/images/gulf_coast_mesh_logo.png',
                                  width: 40,
                                  height: 40,
                                ),
                              );
                            },
                            child: Text(dialogContext.l10n.common_create),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );

            default:
              return null;
          }
        }

        return AlertDialog(
          title: Text(dialogContext.l10n.channels_addChannel),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildOptionTile(
                    optionIndex: 0,
                    icon: Icons.add,
                    title: dialogContext.l10n.channels_createPrivateChannel,
                    subtitle:
                        dialogContext.l10n.channels_createPrivateChannelDesc,
                  ),
                  if (selectedOption == 0) buildExpandedContent()!,
                  const Divider(height: 1),
                  buildOptionTile(
                    optionIndex: 1,
                    icon: Icons.lock,
                    title: dialogContext.l10n.channels_joinPrivateChannel,
                    subtitle:
                        dialogContext.l10n.channels_joinPrivateChannelDesc,
                  ),
                  if (selectedOption == 1) buildExpandedContent()!,
                  if (!hasPublicChannel) ...[
                    const Divider(height: 1),
                    buildOptionTile(
                      optionIndex: 2,
                      icon: Icons.public,
                      title: dialogContext.l10n.channels_joinPublicChannel,
                      subtitle:
                          dialogContext.l10n.channels_joinPublicChannelDesc,
                    ),
                    if (selectedOption == 2) buildExpandedContent()!,
                  ],
                  const Divider(height: 1),
                  buildOptionTile(
                    optionIndex: 3,
                    icon: Icons.tag,
                    title: dialogContext.l10n.channels_joinHashtagChannel,
                    subtitle:
                        dialogContext.l10n.channels_joinHashtagChannelDesc,
                  ),
                  if (selectedOption == 3) buildExpandedContent()!,
                  const Divider(height: 1),
                  buildOptionTile(
                    optionIndex: 4,
                    icon: Icons.qr_code_scanner,
                    title: dialogContext.l10n.channels_scanQrCode,
                    subtitle: dialogContext.l10n.channels_scanQrCodeDesc,
                  ),
                  if (selectedOption == 4) buildExpandedContent()!,
                  const Divider(height: 1),
                  buildOptionTile(
                    optionIndex: 5,
                    icon: Icons.groups,
                    title: dialogContext.l10n.community_scanQr,
                    subtitle: dialogContext.l10n.community_join,
                  ),
                  if (selectedOption == 5) buildExpandedContent()!,
                  const Divider(height: 1),
                  buildOptionTile(
                    optionIndex: 6,
                    icon: Icons.group_add,
                    title: dialogContext.l10n.community_create,
                    subtitle: dialogContext.l10n.community_createDesc,
                  ),
                  if (selectedOption == 6) buildExpandedContent()!,
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(dialogContext.l10n.common_close),
            ),
          ],
        );
      },
    ),
  );
}
