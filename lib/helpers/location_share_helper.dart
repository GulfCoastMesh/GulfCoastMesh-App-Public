import 'package:flutter/material.dart';

import '../l10n/l10n.dart';

Future<bool> confirmPublicLocationShare(
  BuildContext context,
  String channelLabel,
) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(context.l10n.map_publicLocationShare),
      content: Text(context.l10n.map_publicLocationShareConfirm(channelLabel)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(context.l10n.common_cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(context.l10n.common_share),
        ),
      ],
    ),
  );
  return result ?? false;
}
