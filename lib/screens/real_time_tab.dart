import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../widgets/environmental_data_table.dart';
import '../widgets/temperature_controls.dart';
import '../widgets/clear_history_button.dart';
import '../services/firebase_data_service.dart';
import '../providers/historical_data_provider.dart';
import '../utils/pdf_generator.dart';

class RealTimeTab extends StatefulWidget {
  const RealTimeTab({super.key});

  @override
  State<RealTimeTab> createState() => _RealTimeTabState();
}

class _RealTimeTabState extends State<RealTimeTab> {
  final FirebaseDataService _dataService = FirebaseDataService();

  bool isSignificantChange(Map<String, dynamic> currentData, List<Map<String, dynamic>> historicalData) {
    if (historicalData.isEmpty) return true;
    
    const threshold = 0.5;
    final lastRecord = historicalData.last;
    
    final currentHeatIndex = currentData['raw']['heatIndex'];
    final lastHeatIndex = lastRecord['raw']['heatIndex'];
    
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

  void _showExportOptions(
    BuildContext context,
    List<Map<String, dynamic>> data,
    bool isCelsius,
    Widget tableWidget,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Export Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: const Text('Export as PDF'),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    final file = await PDFGenerator.generateEnvironmentalReport(data, isCelsius);
                    await Share.shareXFiles([XFile(file.path)], text: 'Environmental Data Report');
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to export PDF: $e')),
                      );
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Export as PNG'),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    final screenshotController = ScreenshotController();
                    
                    // Create a widget specifically for screenshot
                    final screenshotWidget = Container(
                      width: 800,
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? const Color(0xFF1A1A1A) 
                          : Colors.white,
                      padding: const EdgeInsets.all(16),
                      child: EnvironmentalDataTable(
                        data: data,
                        isCelsius: isCelsius,
                      ),
                    );

                    // Capture the widget
                    final bytes = await screenshotController.captureFromWidget(
                      MediaQuery(
                        data: const MediaQueryData(),
                        child: Material(
                          color: Colors.transparent,
                          child: Theme(
                            data: Theme.of(context),
                            child: screenshotWidget,
                          ),
                        ),
                      ),
                      context: context,
                      delay: const Duration(milliseconds: 100),
                      pixelRatio: 3.0,
                    );
                    
                    if (bytes.isEmpty) {
                      throw Exception('Failed to capture screenshot');
                    }

                    // Save to downloads directory for easier access
                    final directory = await getApplicationDocumentsDirectory();
                    final timestamp = DateTime.now().millisecondsSinceEpoch;
                    final filePath = '${directory.path}/environmental_data_$timestamp.png';
                    final file = File(filePath);
                    await file.writeAsBytes(bytes);
                    
                    if (await file.exists()) {
                      await Share.shareXFiles(
                        [XFile(file.path)],
                        text: 'Environmental Data Screenshot',
                        subject: 'Environmental Data Export'
                      );
                    } else {
                      throw Exception('Failed to save screenshot file');
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to export PNG: $e')),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
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

            if (historicalDataProvider.checkSignificantChange(
                rawSnapshot.data!['heat_index']['celsius'])) {
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
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          onPressed: () => _showExportOptions(
                            context,
                            allData,
                            isCelsius,
                            EnvironmentalDataTable(
                              data: allData,
                              isCelsius: isCelsius,
                            ),
                          ),
                          icon: const Icon(Icons.download, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      const SizedBox(height: 8),
                      EnvironmentalDataTable(
                        data: allData,
                        isCelsius: isCelsius,
                      ),
                      const SizedBox(height: 80),
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