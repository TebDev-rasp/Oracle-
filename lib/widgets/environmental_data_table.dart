import 'package:flutter/material.dart';

class TableColors {
  static Color getBackground(BuildContext context) {
    return Theme.of(context).cardColor;
  }
  
  static Color getText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? Colors.white 
        : Colors.black;
  }
  
  static Color getLineColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? Colors.white.withAlpha(77)
        : Colors.black.withAlpha(77);
  }
}

class EnvironmentalDataTable extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final bool isCelsius;

  const EnvironmentalDataTable({
    super.key,
    required this.data,
    required this.isCelsius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: TableColors.getBackground(context),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(51), // 0.2 * 255 ≈ 51
            spreadRadius: 0,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          children: [
            Container(
              color: TableColors.getBackground(context),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 50),
                          Text(
                            'Reading',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: TableColors.getText(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildColumnGroup(
                      context,
                      'Temperature (°${isCelsius ? 'C' : 'F'})',
                    ),
                    _buildColumnGroup(
                      context,
                      'Humidity (%)',
                    ),
                    _buildColumnGroup(
                      context,
                      'Heat Index (°${isCelsius ? 'C' : 'F'})',
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Table(
                  columnWidths: const {
                    0: FixedColumnWidth(100),
                    1: FixedColumnWidth(100),
                    2: FixedColumnWidth(100),
                    3: FixedColumnWidth(100),
                    4: FixedColumnWidth(100),
                    5: FixedColumnWidth(100),
                    6: FixedColumnWidth(100),
                    7: FixedColumnWidth(100),
                    8: FixedColumnWidth(100),
                    9: FixedColumnWidth(100),
                    10: FixedColumnWidth(100),
                    11: FixedColumnWidth(100),
                    12: FixedColumnWidth(100),
                  },
                  children: [
                    ...data.map((row) {
                      final isCurrentRow = row['reading'] == 'Current';
                      return TableRow(
                        decoration: isCurrentRow ? BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: TableColors.getLineColor(context),
                              width: 1.0,
                            ),
                          ),
                        ) : null,
                        children: [
                          _buildDataCell(context, row['reading']),
                          _buildDataCell(context, row['raw']?['temp']?.toStringAsFixed(1)),
                          _buildDataCell(context, row['ema']?['temp']?.toStringAsFixed(1)),
                          _buildDataCell(context, row['diff']?['temp']),
                          _buildDataCell(context, row['trend']?['temp']),
                          _buildDataCell(context, row['raw']?['humidity']?.toStringAsFixed(1)),
                          _buildDataCell(context, row['ema']?['humidity']?.toStringAsFixed(1)),
                          _buildDataCell(context, row['diff']?['humidity']),
                          _buildDataCell(context, row['trend']?['humidity']),
                          _buildDataCell(context, row['raw']?['heatIndex']?.toStringAsFixed(1)),
                          _buildDataCell(context, row['ema']?['heatIndex']?.toStringAsFixed(1)),
                          _buildDataCell(context, row['diff']?['heatIndex']),
                          _buildDataCell(context, row['trend']?['heatIndex']),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColumnGroup(BuildContext context, String title) {
    return SizedBox(
      width: 400,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            alignment: Alignment.center,
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: TableColors.getText(context),
              ),
            ),
          ),
          Container(
            color: TableColors.getBackground(context),
            child: Row(
              children: [
                Expanded(child: _SubHeader(text: 'Raw')),
                Expanded(child: _SubHeader(text: 'EMA')),
                Expanded(child: _SubHeader(text: 'Diff')),
                Expanded(child: _SubHeader(text: 'Trend')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataCell(BuildContext context, dynamic content) {
    if (content is Map<String, dynamic>) {
      return Container(
        padding: const EdgeInsets.only(top: 0, bottom: 16),
        alignment: Alignment.center,
        child: Text(
          content['symbol'],
          style: TextStyle(
            color: content['color'],
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      alignment: Alignment.center,
      child: Text(
        content.toString(),
        style: TextStyle(color: TableColors.getText(context)),
      ),
    );
  }
}

class _SubHeader extends StatelessWidget {
  final String text;

  const _SubHeader({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: TableColors.getText(context),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}