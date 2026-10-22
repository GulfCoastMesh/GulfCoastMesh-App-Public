import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../connector/meshcore_connector.dart';
import '../l10n/l10n.dart';
import '../models/mesh_region.dart';
import '../screens/region_scope_picker_screen.dart';
import '../storage/known_regions_store.dart';

/// Opens the Gulf Coast region scope picker and saves the result on the channel.
///
/// Soft skip: cancelling leaves the channel unscoped (or keeps [suggestedScope]
/// only if it was already saved by the caller).
Future<void> promptChannelRegionScope(
  BuildContext context, {
  required int channelIndex,
  String? suggestedScope,
  bool showPromptSubtitle = true,
}) async {
  if (!context.mounted) return;
  final connector = context.read<MeshCoreConnector>();
  final l10n = context.l10n;

  final result = await Navigator.push<String?>(
    context,
    MaterialPageRoute(
      builder: (_) => RegionScopePickerScreen(
        initialScope:
            suggestedScope ?? connector.getChannelRegionScope(channelIndex),
        promptSubtitle: showPromptSubtitle
            ? l10n.channels_scopePromptSubtitle
            : null,
      ),
    ),
  );

  if (!context.mounted || result == null) return;

  if (result.isEmpty) {
    await connector.setChannelRegionScope(channelIndex, null);
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.channels_scopeCleared)));
    return;
  }

  await connector.setChannelRegionScope(channelIndex, result);
  if (MeshRegion.isValidRegionName(result)) {
    await KnownRegionsStore().add(result);
  }
  if (!context.mounted) return;
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(l10n.channels_scopeUpdated(result))));
}
