import 'package:flutter/material.dart';
import '../widgets/sidebar_menu.dart';
import 'real_time_tab.dart';  
import 'hourly_tab.dart';     

class RecordScreen extends StatelessWidget {
  const RecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: const SidebarMenu(),
        appBar: AppBar(
          title: const Text('Record'),
          backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFFAFAFA),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Real Time Data'),
              Tab(text: 'Hourly Data'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            RealTimeTab(),
            HourlyTab(),
          ],
        ),
      ),
    );
  }
}