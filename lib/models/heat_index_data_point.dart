class HeatIndexDataPoint {
  final DateTime timestamp;
  final double value;

  HeatIndexDataPoint(this.timestamp, this.value);

  @override
  String toString() => 'HeatIndexDataPoint(timestamp: $timestamp, value: $value)';
}