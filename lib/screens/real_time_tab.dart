import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/environmental_data_table.dart';
import '../widgets/temperature_controls.dart';
import '../widgets/clear_history_button.dart';
import '../services/firebase_data_service.dart';
import '../providers/historical_data_provider.dart';

class RealTimeTab extends StatefulWidget {
  const RealTimeTab({super.key});

  @override
  State<RealTimeTab> createState() => _RealTimeTabState();
}

class _RealTimeTabState extends State<RealTimeTab> {
  bool isCelsius = true;
  final FirebaseDataService _dataService = FirebaseDataService();

  bool isSignificantChange(Map<String, dynamic> currentData, List<Map<String, dynamic>> historicalData) {
    if (historicalData.isEmpty) return true;
    
    const threshold = 1.0;
    final lastRecord = historicalData.last;
    
    // Compare the raw values
    final currentHeatIndex = currentData['raw']['heatIndex'];
    final lastHeatIndex = lastRecord['raw']['heatIndex'];
    
    // Check for significant change in sensor data
    return (currentHeatIndex - lastHeatIndex).abs() > threshold;
}
  Map<String, dynamic> getTrend(double rawValue, double emaValue) {
    if (rawValue > emaValue) {
      return {
        'symbol': '↑',
        'color': Colors.red,
      };
    }
    if (rawValue < emaValue) {
      return {
        'symbol': '↓',
        'color': Colors.green,
      };
    }
    return {
      'symbol': '→',
      'color': Colors.blue,
    };
  }

  @override
  Widget build(BuildContext context) {
    final historicalDataProvider = Provider.of<HistoricalDataProvider>(context);
    final isCelsius = historicalDataProvider.isCelsius;

    return StreamBuilder<Map<String, dynamic>>(
      stream: _dataService.getRawData(),
      builder: (context, rawSnapshot) {
        return StreamBuilder<Map<String, dynamic>>(
          stream: _dataService.getSmoothData(),
          builder: (context, smoothSnapshot) {
            if (!rawSnapshot.hasData || !smoothSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final rawTemp = isCelsius 
                ? rawSnapshot.data!['temperature']['celsius']
                : rawSnapshot.data!['temperature']['fahrenheit'];
            final emaTemp = isCelsius 
                ? smoothSnapshot.data!['temperature']['celsius']
                : smoothSnapshot.data!['temperature']['fahrenheit'];
            final tempDiff = (rawTemp - emaTemp).abs().toStringAsFixed(1);

            final rawHumidity = rawSnapshot.data!['humidity'];
            final emaHumidity = smoothSnapshot.data!['humidity'];
            final humidityDiff = (rawHumidity - emaHumidity).abs().toStringAsFixed(1);
            final rawHeatIndex = isCelsius 
                ? rawSnapshot.data!['heat_index']['celsius']
                : rawSnapshot.data!['heat_index']['fahrenheit'];
            final emaHeatIndex = isCelsius 
                ? smoothSnapshot.data!['heat_index']['celsius']
                : smoothSnapshot.data!['heat_index']['fahrenheit'];
            final heatIndexDiff = (rawHeatIndex - emaHeatIndex).abs().toStringAsFixed(1);

            final currentReading = {
              'reading': 'Current',
              'raw': {
                'temp': rawTemp,
                'humidity': rawHumidity,
                'heatIndex': rawHeatIndex,
              },
              'ema': {
                'temp': emaTemp,
                'humidity': emaHumidity,
                'heatIndex': emaHeatIndex,
              },
              'diff': {
                'temp': tempDiff,
                'humidity': humidityDiff,
                'heatIndex': heatIndexDiff,
              },
              'trend': {
                'temp': getTrend(rawTemp, emaTemp),
                'humidity': getTrend(rawHumidity, emaHumidity),
                'heatIndex': getTrend(rawHeatIndex, emaHeatIndex),
              }
            };

            // Only add to historical data if there's an actual sensor reading change
            if (historicalDataProvider.checkSignificantChange(
                rawSnapshot.data!['heat_index']['celsius'])) {  // Always check against Celsius
              final now = DateTime.now();
              final hour = now.hour <= 12 ? now.hour : now.hour - 12;
              final amPm = now.hour < 12 ? 'AM' : 'PM';
              final timestamp = "${hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')} $amPm";
              
              final historicalReading = Map<String, dynamic>.from(currentReading);
              historicalReading['reading'] = timestamp;
              historicalDataProvider.addReading(historicalReading);
            }

            final allData = historicalDataProvider.historicalData.isEmpty 
                ? [currentReading]
                : [currentReading, ...historicalDataProvider.historicalData.reversed.skip(1)];            
            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TemperatureControls(
                        isCelsius: historicalDataProvider.isCelsius,
                        onUnitChanged: (value) {
                          historicalDataProvider.setTemperatureUnit(value);
                        },
                      ),
                      const SizedBox(height: 16),
                      EnvironmentalDataTable(
                        data: allData,
                        isCelsius: isCelsius,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: ClearHistoryButton(
                    onClear: () => historicalDataProvider.clearHistory(),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}