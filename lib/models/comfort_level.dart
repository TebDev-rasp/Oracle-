class ComfortLevel {
  final String status;

  const ComfortLevel({
    this.status = 'Comfortable',
  });

  static String getStatus(double value) {
    if (value <= 79.9) {
      return 'Comfortable';
    }
    return '';
  }
}
