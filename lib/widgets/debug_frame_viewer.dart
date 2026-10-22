import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import '../connector/meshcore_protocol.dart';
import '../helpers/frame_redaction.dart';

/// Debug widget to show the hex dump of a frame
class DebugFrameViewer {
  static void showFrameDebug(
    BuildContext context,
    Uint8List frame,
    String title,
  ) {
    final safeFrame = redactSensitiveFrame(frame);
    final hexString = safeFrame
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join(' ');

    final details = StringBuffer();
    details.writeln(context.l10n.debugFrame_length(safeFrame.length));
    details.writeln('');
    details.writeln(
      context.l10n.debugFrame_command(
        safeFrame[0].toRadixString(16).padLeft(2, '0'),
      ),
    );

    // Companion CLI/DM format: [cmd][txt_type][attempt][ts x4][prefix x6][text…]
    if (safeFrame[0] == cmdSendTxtMsg && safeFrame.length > 13) {
      final txtType = safeFrame[1];
      details.writeln('');
      details.writeln(context.l10n.debugFrame_textMessageHeader);
      details.writeln(
        context.l10n.debugFrame_destinationPubKey(
          pubKeyToHex(safeFrame.sublist(7, 13)),
        ),
      );
      details.writeln(
        context.l10n.debugFrame_timestamp(readUint32LE(safeFrame, 3)),
      );
      final typeLabel = txtType == txtTypeCliData
          ? context.l10n.debugFrame_textTypeCli
          : context.l10n.debugFrame_textTypePlain;
      details.writeln(context.l10n.debugFrame_textType(txtType, typeLabel));
      final textBytes = safeFrame.sublist(13);
      final nullIdx = textBytes.indexOf(0);
      final text = utf8.decode(
        nullIdx >= 0 ? textBytes.sublist(0, nullIdx) : textBytes,
        allowMalformed: true,
      );
      details.writeln(context.l10n.debugFrame_text(text));
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                details.toString(),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
              const Divider(),
              Text(
                context.l10n.debugFrame_hexDump,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                hexString,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.common_close),
          ),
        ],
      ),
    );
  }
}
