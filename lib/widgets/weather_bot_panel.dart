import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../connector/meshcore_connector.dart';
import '../models/contact.dart';
import '../services/weather_api_service.dart';

class WeatherBotPanel extends StatelessWidget {
  const WeatherBotPanel({super.key, required this.zipController});
  final TextEditingController zipController;

  @override
  Widget build(BuildContext context) {
    final weather = context.watch<WeatherApiService>();
    final contacts = context.watch<MeshCoreConnector>().contacts;
    final busy = weather.isBusy;
    final selected = weather.botContact;
    final result = weather.toolResult;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Weather bot • API2',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Text(
          weather.botIdentity == null
              ? 'No bot discovered on #wx-bot-hidden.'
              : 'Discovered on #wx-bot-hidden: ${weather.botIdentity}',
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: busy ? null : weather.discover,
              icon: const Icon(Icons.search),
              label: const Text('Discover'),
            ),
            OutlinedButton(
              onPressed: busy || !weather.supports(0)
                  ? null
                  : weather.requestHelp,
              child: const Text('Refresh capabilities'),
            ),
            OutlinedButton(
              onPressed: busy || !weather.supports(3)
                  ? null
                  : weather.requestVersion,
              child: const Text('Bot version'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 6,
          children: [
            for (final feature in const {
              0: 'Help',
              1: 'Current',
              2: 'Forecast',
              3: 'Version',
              4: 'Ping',
              5: 'Subscribe',
              6: 'Unsubscribe',
              7: 'Radar',
            }.entries)
              Chip(
                avatar: Icon(
                  weather.supports(feature.key) ? Icons.check : Icons.close,
                  size: 16,
                ),
                label: Text(feature.value),
              ),
          ],
        ),
        const Divider(height: 32),
        Text(
          'Direct-message tools',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const Text(
          'Select the contact belonging to the weather bot discovered above. Ping and report subscriptions use DMs.',
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          key: ValueKey(selected?.publicKeyHex),
          initialValue:
              contacts.any(
                (c) => c.type == 1 && c.publicKeyHex == selected?.publicKeyHex,
              )
              ? selected?.publicKeyHex
              : null,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Weather bot contact',
            border: OutlineInputBorder(),
          ),
          items: [
            for (final contact in contacts.where((c) => c.type == 1))
              DropdownMenuItem(
                value: contact.publicKeyHex,
                child: Text(
                  '${contact.displayName} (${contact.publicKeyHex.substring(0, 8)})',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: busy
              ? null
              : (key) {
                  Contact? contact;
                  for (final item in contacts) {
                    if (item.publicKeyHex == key) contact = item;
                  }
                  weather.selectBotContact(contact);
                },
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: busy || selected == null || !weather.supports(4)
                ? null
                : weather.ping,
            icon: const Icon(Icons.network_ping),
            label: const Text('Ping bot'),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: zipController,
          enabled: !busy,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Report ZIP code',
            hintText: 'e.g. 70112',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            FilledButton(
              onPressed: busy || selected == null || !weather.supports(5)
                  ? null
                  : () => weather.subscribe(zipController.text),
              child: const Text('Subscribe'),
            ),
            OutlinedButton(
              onPressed: busy || selected == null || !weather.supports(6)
                  ? null
                  : weather.unsubscribe,
              child: const Text('Stop all reports'),
            ),
          ],
        ),
        const Text(
          'Automatic reports arrive as ordinary text in your conversation with the bot. “Stop all reports” unsubscribes all ZIP codes for your identity.',
        ),
        if (result != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SelectableText(weatherToolResultText(result)),
            ),
          ),
        const Divider(height: 32),
        const Text(
          'How to use weather',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const Text(
          'Forecast: enter a U.S. ZIP or use your current location. Combined weather includes up to five hours; descriptive conditions are a separate lookup.\n\nRadar: select a point and an hour, then tap Load radar. Each request returns one 50-mile-radius snapshot. Future hours are model guidance, not observations. Map backgrounds use online or cached tiles.\n\nOnly one request runs at a time. If a complete response does not arrive within 60 seconds, use the same action to retry.',
        ),
      ],
    );
  }
}

String weatherToolResultText(
  Map<String, dynamic> result,
) => switch (result['k']) {
  'version' => 'Bot version: ${result['git_commit'] ?? 'Unavailable'}',
  'pong' =>
    'Received (UTC): ${result['received_at'] ?? 'Unavailable'}\nRoute: ${result['path'] ?? 'Unavailable'}${result['approx_direct_miles'] == null ? '' : '\nApproximate direct distance: ${result['approx_direct_miles']} miles (not relay-path distance)'}',
  'report' =>
    result['status'] == 'enabled'
        ? 'Reports enabled for ${result['zip_code'] ?? 'the requested ZIP'}.'
        : result['status'] == 'stopped'
        ? 'Reports stopped. ZIP codes: ${(result['zip_codes'] as List?)?.join(', ').nonEmptyOrNone ?? 'none'}.'
        : 'Subscription status: ${result['status'] ?? 'Unavailable'}',
  'b' =>
    'Capabilities refreshed. Message limits: ${result['lim'] ?? 'Unavailable'}. Units: ${(result['u'] as List?)?.join(', ') ?? 'Unavailable'}.',
  _ => 'Response received.',
};

extension on String {
  String get nonEmptyOrNone => isEmpty ? 'none' : this;
}

String weatherCurrentAlertText(Object? alert) {
  if (alert is Map) {
    return alert.entries.map((e) => '${e.key}: ${e.value}').join(' • ');
  }
  if (alert is List) return alert.join(' • ');
  return alert?.toString() ?? '';
}
