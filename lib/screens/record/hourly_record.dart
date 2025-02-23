import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import '../../models/hourly_record.dart';
import 'heat_index_table.dart';
import '../../widgets/record_settings_buttons.dart';

class HourlyRecordView extends StatefulWidget {
  const HourlyRecordView({super.key});

  @override
  State<HourlyRecordView> createState() => _HourlyRecordViewState();
}

class _HourlyRecordViewState extends State<HourlyRecordView> {
  bool _isCelsius = true;
  String _timeFilter = 'All';
  final ScrollController _scrollController = ScrollController();
  final FirebaseService _firebaseService = FirebaseService();

  TextStyle _createTextStyle({
    required double fontSize,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: Colors.black87,  // You can adjust the color as needed
    );
  }

  @override
  void initState() {
    super.initState();
    // Remove the hasScrolled check to ensure scroll happens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentTime();
    });
  }

  void _scrollToCurrentTime() {
    if (!mounted) return;

    // Increase delay to ensure table is fully rendered
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      final currentHour = DateTime.now().hour;
      // Adjust calculations based on actual measurements
      final rowHeight = 42.0; // Reduced row height
      final headerOffset = 140.0; // Increased header offset to account for all headers
      
      final targetPosition = (currentHour * rowHeight) + headerOffset;

      _scrollController.animateTo(
        targetPosition,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<HourlyRecord> _getFilteredRecords(List<HourlyRecord> records) {
    if (_timeFilter == 'All') return records;
    
    return records.where((record) {
      final hour = int.parse(record.time.split(':')[0]);
      switch (_timeFilter) {
        case 'Morning':
          return hour >= 6 && hour < 12;
        case 'Afternoon':
          return hour >= 12 && hour < 17;
        case 'Evening':
          return hour >= 17 && hour < 20;
        case 'Night':
          return hour >= 20 || hour < 6;
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Adjust these values to make buttons smaller
    final buttonSize = screenWidth * 0.035;      // Decreased from 0.045
    final buttonPadding = screenWidth * 0.015;   // Decreased from 0.02
    final buttonSpacing = screenWidth * 0.015;   // Space between buttons
    final titleFontSize = screenWidth * 0.05;    // Keep title size same

    final headerPadding = EdgeInsets.fromLTRB(
      screenWidth * 0.04,
      screenHeight * 0.02,
      screenWidth * 0.04,
      screenHeight * 0.01
    );

    return StreamBuilder<List<HourlyRecord>>(
      stream: _firebaseService.getHourlyRecords(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final records = snapshot.data ?? [];
        final filteredRecords = _getFilteredRecords(records);

        return Column(
          children: [
            Padding(
              padding: headerPadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hourly Records',
                    style: _createTextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  RecordSettingsButtons(
                    isCelsius: _isCelsius,
                    onTemperatureUnitChanged: () {
                      setState(() {
                        _isCelsius = !_isCelsius;
                      });
                    },
                    records: filteredRecords,
                    currentTimeFilter: _timeFilter,
                    onTimeFilterChanged: (value) {
                      setState(() {
                        _timeFilter = value;
                      });
                    },
                    // Add these new properties
                    buttonSize: buttonSize,
                    buttonPadding: buttonPadding,
                    buttonSpacing: buttonSpacing,
                  ),
                ],
              ),
            ),
            Expanded(
              child: HeatIndexTable(
                records: filteredRecords,
                isCelsius: _isCelsius,
              ),
            ),
          ],
        );
      },
    );
  }
}