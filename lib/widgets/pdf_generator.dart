import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import '../models/hourly_record.dart';

class PdfGenerator {
  static Future<pw.Document> generateDocument(List<HourlyRecord> records) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4, // Changed to portrait
        margin: const pw.EdgeInsets.all(10), // Reduced margins
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            pw.SizedBox(height: 8),
            _buildTable(records),
          ],
        ),
      ),
    );

    return pdf;
  }

  static pw.Widget _buildHeader() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey200,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Text(
        'Hourly Weather Records',
        style: pw.TextStyle(
          fontSize: 24,
          fontWeight: pw.FontWeight.bold,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _buildTable(List<HourlyRecord> records) {
    return pw.Center(  // Added Center widget
      child: pw.Table(
        border: pw.TableBorder.all(color: PdfColors.grey400),
        columnWidths: {
          0: const pw.FlexColumnWidth(0.8),  // Time - made smaller
          1: const pw.FlexColumnWidth(1.0),  // Temperature
          2: const pw.FlexColumnWidth(1.0),  // Heat Index
          3: const pw.FlexColumnWidth(0.7),  // Humidity - made smaller
          4: const pw.FlexColumnWidth(0.8),  // Status - made smaller
        },
        defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
        children: [
          _buildHeaderRow(),
          ...records.map(_buildDataRow),
        ],
      ),
    );
  }

  static pw.TableRow _buildHeaderRow() {
    return pw.TableRow(
      decoration: const pw.BoxDecoration(color: PdfColors.grey200),
      children: [
        _buildHeaderCell('Time'),
        _buildHeaderCell('Temperature\n(°C/°F)'),
        _buildHeaderCell('Heat Index\n(°C/°F)'),
        _buildHeaderCell('Humidity\n(%)'),
        _buildHeaderCell('Status'),
      ],
    );
  }

  static pw.TableRow _buildDataRow(HourlyRecord record) {
    final tempF = (record.temperatureCelsius * 9/5) + 32;
    final heatIndexF = (record.heatIndexCelsius * 9/5) + 32;
    
    return pw.TableRow(
      children: [
        _buildCell(_formatTime(record.time)),
        _buildCell('${record.temperatureCelsius.toStringAsFixed(1)}°C\n${tempF.toStringAsFixed(1)}°F'),
        _buildCell('${record.heatIndexCelsius.toStringAsFixed(1)}°C\n${heatIndexF.toStringAsFixed(1)}°F'),
        _buildCell('${record.humidity.toStringAsFixed(1)}%'),
        _buildCell(_getHeatIndexStatus(record.heatIndexCelsius)),
      ],
    );
  }

  static pw.Widget _buildHeaderCell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _buildCell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(4), // Reduced padding
      alignment: pw.Alignment.center,
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 8), // Smaller font size
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static String _formatTime(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '${hour12.toString().padLeft(2, '0')}:$minute $period';
  }

  static String _getHeatIndexStatus(double heatIndex) {
    if (heatIndex < 27) return 'Normal';
    if (heatIndex < 32) return 'Caution';
    if (heatIndex < 41) return 'Extreme Caution';
    if (heatIndex < 54) return 'Danger';
    return 'Extreme Danger'; 
  }  
}
