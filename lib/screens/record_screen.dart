import 'package:flutter/material.dart';
import 'package:oracle/services/heat_index_monitor.dart';
import '../widgets/sidebar_menu.dart';
import 'record/hourly_record.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    HeatIndexMonitor.startMonitoring();
  }

  @override
  void dispose() {
    HeatIndexMonitor.stopMonitoring();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        HeatIndexMonitor.startMonitoring();
        break;
      case AppLifecycleState.paused:
        // Keep monitoring in background
        break;
      case AppLifecycleState.detached:
        HeatIndexMonitor.stopMonitoring();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SidebarMenu(),
      appBar: AppBar(
        title: const Text('Record'),
      ),
      body: const HourlyRecordView(),
    );
  }
}