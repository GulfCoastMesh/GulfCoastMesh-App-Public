import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/weather_report.dart';
import '../services/weather_api_service.dart';
import '../widgets/weather_radar_panel.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key, required this.isTabActive});
  final bool isTabActive;

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final _zipController = TextEditingController();
  bool _started = false;
  bool _locating = false;
  bool _usesCelsius = false;

  @override
  void initState() {
    super.initState();
    _startIfActive();
  }

  @override
  void didUpdateWidget(covariant WeatherScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isTabActive && widget.isTabActive) _startIfActive();
  }

  void _startIfActive() {
    if (_started || !widget.isTabActive) return;
    _started = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<WeatherApiService>().discover();
    });
  }

  @override
  void dispose() {
    _zipController.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    if (_locating) return;
    setState(() => _locating = true);
    final zip = await context
        .read<WeatherApiService>()
        .zipFromCurrentLocation();
    if (!mounted) return;
    setState(() => _locating = false);
    if (zip == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not find a U.S. ZIP for your current location. Enter one manually.',
          ),
        ),
      );
      return;
    }
    _zipController.text = zip;
    final weather = context.read<WeatherApiService>();
    if (weather.supports(2)) {
      await weather.requestWeather(zip);
    } else {
      await weather.requestCurrent(zip);
    }
  }

  @override
  Widget build(BuildContext context) {
    final weather = context.watch<WeatherApiService>();
    final report = weather.report;
    if (weather.selectedZip != null && _zipController.text.isEmpty) {
      _zipController.text = weather.selectedZip!;
    }
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        cardTheme: CardThemeData(
          elevation: 0,
          color: theme.colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
        ),
      ),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Weather'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Forecast'),
                Tab(text: 'Radar'),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: SegmentedButton<bool>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: false, label: Text('°F')),
                    ButtonSegment(value: true, label: Text('°C')),
                  ],
                  selected: {_usesCelsius},
                  onSelectionChanged: (selected) {
                    setState(() => _usesCelsius = selected.first);
                  },
                ),
              ),
              if (report != null || weather.currentSummary != null)
                IconButton(
                  tooltip: 'Refresh weather',
                  icon: const Icon(Icons.refresh),
                  onPressed: weather.isBusy
                      ? null
                      : () => weather.supports(2)
                            ? weather.requestWeather(_zipController.text)
                            : weather.requestCurrent(_zipController.text),
                ),
            ],
          ),
          body: SafeArea(
            top: false,
            child: Column(
              children: [
                if (weather.isBusy) ...[
                  const LinearProgressIndicator(),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text('Waiting on response'),
                  ),
                ],
                if (weather.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: _InlineError(message: weather.errorMessage!),
                  ),
                if (weather.status == WeatherStatus.unavailable ||
                    weather.status == WeatherStatus.idle ||
                    (weather.status == WeatherStatus.error &&
                        !weather.supports(1) &&
                        !weather.supports(2)))
                  TextButton(
                    onPressed: weather.isBusy ? null : weather.discover,
                    child: const Text('Try again'),
                  ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _WeatherBody(
                        report: report,
                        usesCelsius: _usesCelsius,
                        zipController: _zipController,
                        locating: _locating,
                        busy:
                            weather.isBusy ||
                            (!weather.supports(2) && !weather.supports(1)),
                        onRequest: () => weather.supports(2)
                            ? weather.requestWeather(_zipController.text)
                            : weather.requestCurrent(_zipController.text),
                        onUseLocation: _useCurrentLocation,
                      ),
                      const WeatherRadarPanel(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WeatherBody extends StatelessWidget {
  const _WeatherBody({
    required this.report,
    required this.usesCelsius,
    required this.zipController,
    required this.locating,
    required this.busy,
    required this.onRequest,
    required this.onUseLocation,
  });
  final WeatherReport? report;
  final bool usesCelsius;
  final TextEditingController zipController;
  final bool locating;
  final bool busy;
  final VoidCallback onRequest;
  final VoidCallback onUseLocation;

  @override
  Widget build(BuildContext context) {
    final data = report;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 840),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _ZipPicker(
              controller: zipController,
              locating: locating,
              busy: busy,
              onRequest: onRequest,
              onUseLocation: onUseLocation,
            ),
            if (data != null) ...[
              const SizedBox(height: 16),
              _CurrentHero(report: data, usesCelsius: usesCelsius),
              if (data.alerts.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text('No alerts included in this update.'),
                ),
              if (data.alerts.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Active alerts',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                for (final alert in data.alerts) _AlertCard(alert: alert),
              ],
              if (data.hasMoreAlerts)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    'Some forecast details or alerts could not be shown.',
                  ),
                ),
              if (data.hourly.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  'Hourly outlook',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 210 * MediaQuery.textScalerOf(context).scale(1),
                  child: _HourlyList(report: data, usesCelsius: usesCelsius),
                ),
              ],
            ] else if (context.watch<WeatherApiService>().currentSummary ==
                null) ...[
              const SizedBox(height: 40),
              const Icon(Icons.cloud_outlined, size: 72),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Choose a ZIP code to request weather.',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
            Consumer<WeatherApiService>(
              builder: (context, weather, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextButton.icon(
                    onPressed: weather.isBusy || !weather.supports(1)
                        ? null
                        : () => weather.requestCurrent(
                            data?.zipCode ?? zipController.text,
                          ),
                    icon: const Icon(Icons.description_outlined),
                    label: const Text('More details'),
                  ),
                  if (weather.currentSummary case final summary?
                      when data == null || summary['z'] == data.zipCode)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${summary['l'] ?? 'Current conditions'} • ${summary['z'] ?? ''}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text('${summary['c'] ?? 'Conditions unavailable'}'),
                            if (data == null)
                              Text(
                                'Temperature ${_summaryTemperature(summary['t'], usesCelsius)} • Feels like ${_summaryTemperature(summary['i'], usesCelsius)}',
                              ),
                            if (data == null)
                              Text(
                                'Humidity ${_summaryUnit(summary['h'], '%')} • Wind ${summary['w'] ?? '—'}',
                              ),
                            if (summary['a'] case final List alerts) ...[
                              for (final alert in alerts)
                                Text(_currentAlertText(alert)),
                            ],
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ZipPicker extends StatelessWidget {
  const _ZipPicker({
    required this.controller,
    required this.locating,
    required this.busy,
    required this.onRequest,
    required this.onUseLocation,
  });
  final TextEditingController controller;
  final bool locating, busy;
  final VoidCallback onRequest, onUseLocation;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Weather location',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final field = TextField(
                controller: controller,
                enabled: !busy,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                maxLength: 10,
                onSubmitted: busy ? null : (_) => onRequest(),
                decoration: const InputDecoration(
                  labelText: 'U.S. ZIP code',
                  hintText: 'e.g. 70112',
                  counterText: '',
                  border: OutlineInputBorder(),
                ),
              );
              final button = FilledButton(
                onPressed: busy ? null : onRequest,
                child: const Text('Get weather'),
              );
              if (constraints.maxWidth >= 300 &&
                  MediaQuery.textScalerOf(context).scale(1) <= 1.2) {
                return Row(
                  children: [
                    Expanded(child: field),
                    const SizedBox(width: 12),
                    button,
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [field, const SizedBox(height: 10), button],
              );
            },
          ),
          const SizedBox(height: 6),
          TextButton.icon(
            onPressed: locating || busy ? null : onUseLocation,
            icon: locating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location_outlined),
            label: const Text('Use current location'),
          ),
        ],
      ),
    ),
  );
}

class _CurrentHero extends StatelessWidget {
  const _CurrentHero({required this.report, required this.usesCelsius});
  final WeatherReport report;
  final bool usesCelsius;
  @override
  Widget build(BuildContext context) {
    final current = report.current;
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.brightness == Brightness.dark
            ? const Color(0xff192d3b)
            : const Color(0xffedf6fc),
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ZIP ${report.zipCode}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            weatherCodeLabel(current.weatherCode),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(_weatherIcon(current.weatherCode), size: 72),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  _temperature(current.temperatureF, usesCelsius),
                  style: Theme.of(context).textTheme.displayLarge,
                ),
              ),
            ],
          ),
          Wrap(
            spacing: 18,
            runSpacing: 6,
            children: [
              _Metric(
                icon: Icons.water_drop_outlined,
                label: 'Humidity',
                value: _unit(current.humidityPercent, '%'),
              ),
              _Metric(
                icon: Icons.air,
                label: 'Wind',
                value: _wind(current.windMph, current.windDirectionDegrees),
              ),
              _Metric(
                icon: Icons.thermostat,
                label: 'Feels like',
                value: _temperature(current.apparentTemperatureF, usesCelsius),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Updated ${DateFormat('MMM d, h:mm a').format(report.generatedAt.toLocal())}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label, value;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 18),
      const SizedBox(width: 4),
      Flexible(child: Text('$label $value')),
    ],
  );
}

class _HourlyList extends StatelessWidget {
  const _HourlyList({required this.report, required this.usesCelsius});
  final WeatherReport report;
  final bool usesCelsius;
  @override
  Widget build(BuildContext context) => ListView.separated(
    scrollDirection: Axis.horizontal,
    itemCount: report.hourly.length,
    separatorBuilder: (_, index) => const SizedBox(width: 8),
    itemBuilder: (_, index) {
      final item = report.hourly[index];
      final minutes = item.minutesAfterGenerated;
      final time = minutes == null
          ? null
          : report.generatedAt.add(Duration(minutes: minutes));
      return SizedBox(
        width: 140 * MediaQuery.textScalerOf(context).scale(1),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Text(
                  time == null
                      ? 'Time unavailable'
                      : DateFormat.jm().format(time),
                  style: time == null ? const TextStyle(fontSize: 11) : null,
                ),
                const SizedBox(height: 6),
                Icon(_weatherIcon(item.weatherCode)),
                const SizedBox(height: 5),
                Text(
                  _temperature(item.temperatureF, usesCelsius),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_unit(item.precipitationPercent, '%')} chance of rain or snow',
                  style: const TextStyle(fontSize: 11),
                  textAlign: TextAlign.center,
                ),
                Text(
                  _wind(item.windMph, item.windDirectionDegrees),
                  style: const TextStyle(fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.alert});
  final WeatherAlert alert;
  @override
  Widget build(BuildContext context) {
    final severe = alert.severityCode >= 3;
    return Card(
      color: severe ? Theme.of(context).colorScheme.errorContainer : null,
      child: ListTile(
        leading: Icon(
          severe ? Icons.warning_amber_rounded : Icons.info_outline,
        ),
        title: Text(weatherAlertLabel(alert.alertCode)),
        subtitle: Text(weatherSeverityLabel(alert.severityCode)),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.errorContainer,
    borderRadius: BorderRadius.circular(12),
    child: Padding(padding: const EdgeInsets.all(12), child: Text(message)),
  );
}

IconData _weatherIcon(int code) => switch (code) {
  1 => Icons.wb_sunny_outlined,
  2 || 3 => Icons.cloud_queue_outlined,
  4 => Icons.cloud_outlined,
  5 => Icons.umbrella_outlined,
  6 => Icons.thunderstorm_outlined,
  7 => Icons.ac_unit,
  8 => Icons.foggy,
  9 => Icons.air,
  _ => Icons.cloud_outlined,
};
String _unit(int? value, String suffix) =>
    value == null ? '—' : '$value$suffix';
String _temperature(int? fahrenheit, bool usesCelsius) {
  if (fahrenheit == null) return '—';
  final value = usesCelsius ? ((fahrenheit - 32) * 5 / 9).round() : fahrenheit;
  return '$value°${usesCelsius ? 'C' : 'F'}';
}

String _summaryTemperature(Object? value, bool usesCelsius) => value is num
    ? _temperature(value.round(), usesCelsius)
    : value?.toString() ?? '—';
String _summaryUnit(Object? value, String suffix) =>
    value is num ? '$value$suffix' : value?.toString() ?? '—';
String _wind(int? mph, int? degrees) => mph == null
    ? '—'
    : '$mph mph${degrees == null ? '' : ' ${_compass(degrees)}'}';
String _compass(int degrees) {
  const points = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
  return points[((degrees % 360) / 45).round() % 8];
}

String _currentAlertText(Object? alert) {
  if (alert is String) return alert;
  if (alert is Map) {
    // Display human-readable alert content, never backend field names.
    final parts = [
      alert['event'],
      alert['headline'],
      alert['description'],
      alert['severity'],
    ].whereType<String>().where((value) => value.trim().isNotEmpty).toSet();
    return parts.isEmpty ? 'Weather alert' : parts.join(' • ');
  }
  if (alert is List) {
    final parts = alert.whereType<String>().where(
      (value) => value.trim().isNotEmpty,
    );
    return parts.isEmpty ? 'Weather alert' : parts.join(' • ');
  }
  return 'Weather alert';
}
