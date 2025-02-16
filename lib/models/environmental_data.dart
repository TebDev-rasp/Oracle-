class EnvironmentalData {
  final double temp;
  final int humidity;
  final double heatIndex;

  EnvironmentalData({
    required this.temp,
    required this.humidity,
    required this.heatIndex,
  });

  Map<String, dynamic> toMap() {
    return {
      'temp': temp,
      'humidity': humidity,
      'heatIndex': heatIndex,
    };
  }
}
