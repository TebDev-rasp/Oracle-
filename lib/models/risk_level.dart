class RiskLevel {
  final String status;

  const RiskLevel({
    this.status = 'Normal conditions',
  });

  static String getStatus(double value) {
    if (value <= 79.9) {
      return 'No Risk of Heat Disorders';
    }
    return '';
  }
}
