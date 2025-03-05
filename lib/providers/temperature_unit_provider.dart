import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TemperatureUnitProvider extends ChangeNotifier {
  static const String _key = 'temperature_unit_fahrenheit';
  bool _isFahrenheit = false;

  bool get isFahrenheit => _isFahrenheit;

  TemperatureUnitProvider() {
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isFahrenheit = prefs.getBool(_key) ?? false;
    notifyListeners();
  }

  Future<void> setFahrenheit(bool value) async {
    if (_isFahrenheit == value) return;
    _isFahrenheit = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
    notifyListeners();
  }
}