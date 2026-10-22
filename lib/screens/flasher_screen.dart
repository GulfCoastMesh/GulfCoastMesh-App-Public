import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/l10n.dart';

class FlasherScreen extends StatelessWidget {
  const FlasherScreen({super.key});

  Future<void> _launchWebFlasher(BuildContext context) async {
    final Uri url = Uri.parse('https://flasher.meshcore.co.uk');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.flasher_launchFailed)),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.flasher_launchError(e.toString())),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.flasher_title)),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.usb_rounded, size: 80, color: colorScheme.primary),
              const SizedBox(height: 24),
              Text(
                context.l10n.flasher_heading,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.flasher_description,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              _buildStep(
                context,
                number: '1',
                title: 'Connect your device',
                description:
                    'Use a high-quality data USB-C cable (often via a USB OTG adapter) to connect your node to your phone or computer.',
              ),
              _buildStep(
                context,
                number: '2',
                title: 'Open the Web Flasher',
                description:
                    'Tap the button below to open the official flasher in your browser (e.g., Chrome, Edge).',
              ),
              _buildStep(
                context,
                number: '3',
                title: 'Select device & flash',
                description:
                    'Choose your specific hardware model and firmware version (Stable is recommended), then click Flash. It may take 1-3 minutes.',
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => _launchWebFlasher(context),
                icon: const Icon(Icons.open_in_browser),
                label: Text(context.l10n.flasher_openWebFlasher),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.flasher_note,
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(
    BuildContext context, {
    required String number,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
