import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../utils/pdf_generator.dart';
import 'dart:io';

class ExportDataButton extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final bool isCelsius;
  final Widget tableWidget;

  const ExportDataButton({
    super.key,
    required this.data,
    required this.isCelsius,
    required this.tableWidget,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showExportOptions(context),
      backgroundColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2),
      ),
      child: const Icon(Icons.download),
    );
  }

  void _showExportOptions(BuildContext context) {
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
                onTap: () {
                  Navigator.pop(context);
                  _exportToPdf(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Export as PNG'),
                onTap: () {
                  Navigator.pop(context);
                  _exportToPng(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _exportToPdf(BuildContext context) async {
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
  }

  Future<void> _exportToPng(BuildContext context) async {
    try {
      final screenshotController = ScreenshotController();
      final bytes = await screenshotController.captureFromWidget(tableWidget);
      
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/environmental_data_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);
      
      await Share.shareXFiles([XFile(file.path)], text: 'Environmental Data Screenshot');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export PNG: $e')),
        );
      }
    }
  }
}