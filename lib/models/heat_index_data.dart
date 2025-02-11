class HeatIndex {
  final double value;
  final double celsius;

  const HeatIndex({
    this.value = 79.5,
    this.celsius = 0.0,
  });

  String get formattedValue => '${value.toStringAsFixed(1)}°F';
}