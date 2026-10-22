import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../connector/meshcore_connector.dart';
import '../l10n/l10n.dart';
import '../widgets/adaptive_app_bar_title.dart';
import '../widgets/qr_code_display.dart';

/// Request the device's signed self contact advert and show it as a QR code
/// that another device can scan to add this contact.
class MyContactQrScreen extends StatefulWidget {
  const MyContactQrScreen({super.key});

  @override
  State<MyContactQrScreen> createState() => _MyContactQrScreenState();
}

class _MyContactQrScreenState extends State<MyContactQrScreen> {
  String? _uri;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadContactUri();
  }

  Future<void> _loadContactUri() async {
    setState(() {
      _uri = null;
      _error = null;
    });

    final connector = context.read<MeshCoreConnector>();
    try {
      final uri = await connector.exportSelfContactUri();
      if (!mounted) return;
      setState(() => _uri = uri);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AdaptiveAppBarTitle(context.l10n.contacts_myQrCodeTitle),
        centerTitle: true,
      ),
      body: Center(child: _buildBody(context)),
    );
  }

  Widget _buildBody(BuildContext context) {
    final uri = _uri;
    if (uri != null) {
      return SingleChildScrollView(
        child: QrCodeDisplay(
          data: uri,
          size: 260,
          title: context.l10n.contacts_myQrCodeTitle,
          instructions: context.l10n.contacts_myQrCodeInstructions,
          embeddedImage: Image.asset(
            'assets/images/gulf_coast_mesh_logo.png',
            width: 40,
            height: 40,
          ),
        ),
      );
    }

    if (_error != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.contacts_myQrCodeFailed,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _loadContactUri,
            child: Text(context.l10n.common_retry),
          ),
        ],
      );
    }

    return const CircularProgressIndicator();
  }
}
