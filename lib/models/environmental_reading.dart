class EnvironmentalReading {
  final double temperature;
  final double humidity;
  final double heatIndex;

  EnvironmentalReading({
    required this.temperature,
    required this.humidity,
    required this.heatIndex,
  });

  Map<String, dynamic> toMap() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'heat_index': heatIndex,
    };
  }

  factory EnvironmentalReading.fromMap(Map<String, dynamic> map) {
    return EnvironmentalReading(
      temperature: map['temperature']?.toDouble() ?? 0.0,
      humidity: map['humidity']?.toDouble() ?? 0.0,
      heatIndex: map['heat_index']?.toDouble() ?? 0.0,
    );
  }
}
