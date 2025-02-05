import 'package:flutter/material.dart';
import '../widgets/sidebar_menu.dart';

class RecordScreen extends StatelessWidget {
  const RecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      drawer: const SidebarMenu(),
      appBar: AppBar(
        title: const Text('Record'),
        backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFFAFAFA),
      ),
      body: const Center(
        child: Text('Record Screen'),
      ),
    );
  }
}