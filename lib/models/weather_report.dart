class WeatherReport {
  final String zipCode;
  final DateTime generatedAt;
  final WeatherCurrent current;
  final List<WeatherHourly> hourly;
  final List<WeatherAlert> alerts;
  final bool hasMoreAlerts;

  const WeatherReport({
    required this.zipCode,
    required this.generatedAt,
    required this.current,
    required this.hourly,
    required this.alerts,
    required this.hasMoreAlerts,
  });
}

class WeatherCurrent {
  final int? apparentTemperatureF;
  final int? temperatureF;
  final int weatherCode;
  final int? humidityPercent;
  final int? windDirectionDegrees;
  final int? windMph;

  const WeatherCurrent({
    this.apparentTemperatureF,
    required this.temperatureF,
    required this.weatherCode,
    required this.humidityPercent,
    required this.windDirectionDegrees,
    required this.windMph,
  });
}

class WeatherHourly {
  final int? minutesAfterGenerated;
  final int? temperatureF;
  final int weatherCode;
  final int? windDirectionDegrees;
  final int? windMph;
  final int? precipitationPercent;

  const WeatherHourly({
    required this.minutesAfterGenerated,
    required this.temperatureF,
    required this.weatherCode,
    required this.windDirectionDegrees,
    required this.windMph,
    required this.precipitationPercent,
  });
}

class WeatherAlert {
  final int alertCode;
  final int severityCode;

  const WeatherAlert({required this.alertCode, required this.severityCode});
}

String weatherCodeLabel(int code) => switch (code) {
  1 => 'Clear',
  2 => 'Partly cloudy',
  3 => 'Mostly cloudy',
  4 => 'Cloudy',
  5 => 'Rain',
  6 => 'Thunderstorm',
  7 => 'Snow / ice',
  8 => 'Fog / haze',
  9 => 'Windy',
  _ => 'Conditions unavailable',
};

String weatherAlertLabel(int code) => switch (code) {
  1 => 'Tornado',
  2 => 'Thunder / lightning',
  3 => 'Flood',
  4 => 'Wind',
  5 => 'Winter weather',
  6 => 'Heat',
  7 => 'Hurricane / tropical',
  8 => 'Fire',
  9 => 'Air quality',
  _ => 'Weather alert',
};

String weatherSeverityLabel(int code) => switch (code) {
  1 => 'Minor',
  2 => 'Moderate',
  3 => 'Severe',
  4 => 'Extreme',
  _ => 'Unknown severity',
};
