import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../connector/meshcore_connector.dart';
import '../helpers/contact_advert_uri.dart';
import '../l10n/l10n.dart';
import '../widgets/adaptive_app_bar_title.dart';
import '../widgets/qr_scanner_widget.dart';

/// Scan a `meshcore://<hex>` contact advert QR and add the contact.
class ContactQrScannerScreen extends StatefulWidget {
  const ContactQrScannerScreen({super.key});

  @override
  State<ContactQrScannerScreen> createState() => _ContactQrScannerScreenState();
}

class _ContactQrScannerScreenState extends State<ContactQrScannerScreen> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AdaptiveAppBarTitle(context.l10n.contacts_scanQrCode),
        centerTitle: true,
      ),
      body: _isProcessing
          ? const Center(child: CircularProgressIndicator())
          : QrScannerWidget(
              onScanned: (data) => _handleScannedData(context, data),
              validator: ContactAdvertUri.isContactAdvert,
              onValidationFailed: (_) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.l10n.contacts_invalidContactQr),
                  ),
                );
              },
              instructions: context.l10n.contacts_scanQrCodeDesc,
            ),
    );
  }

  Future<void> _handleScannedData(BuildContext context, String data) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    final hexString = ContactAdvertUri.contactHexFromUri(data);
    if (hexString == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.contacts_invalidContactQr)),
      );
      setState(() => _isProcessing = false);
      return;
    }

    final connector = context.read<MeshCoreConnector>();
    try {
      final accepted = await connector.importContactAdvert(data);
      if (!context.mounted) return;
      if (accepted) {
        setState(() => _isProcessing = false);
        Navigator.pop(context, hexString);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.contacts_contactImportFailed),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        setState(() => _isProcessing = false);
      }
    } on FormatException {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.contacts_invalidContactQr)),
      );
      setState(() => _isProcessing = false);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.contacts_contactImportFailed),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      setState(() => _isProcessing = false);
    }
  }
}
