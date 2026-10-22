typedef BatteryVoltageRange = ({int minMv, int maxMv});

BatteryVoltageRange batteryVoltageRange(String chemistry, {int cellCount = 1}) {
  final BatteryVoltageRange perCell;
  switch (chemistry) {
    case 'lifepo4':
      perCell = (minMv: 2600, maxMv: 3650);
      break;
    case 'lipo':
    case 'nmc':
    default:
      perCell = (minMv: 3000, maxMv: 4200);
  }
  return (minMv: perCell.minMv * cellCount, maxMv: perCell.maxMv * cellCount);
}

int estimateBatteryPercentFromMillivolts(
  int millivolts,
  String chemistry, {
  int cellCount = 1,
}) {
  final range = batteryVoltageRange(chemistry, cellCount: cellCount);
  if (millivolts <= range.minMv) return 0;
  if (millivolts >= range.maxMv) return 100;
  return (((millivolts - range.minMv) * 100) / (range.maxMv - range.minMv))
      .round();
}

int estimateBatteryPercentFromVolts(
  double volts,
  String chemistry, {
  int cellCount = 1,
}) {
  final millivolts = (volts * 1000).round();
  return estimateBatteryPercentFromMillivolts(
    millivolts,
    chemistry,
    cellCount: cellCount,
  );
}
