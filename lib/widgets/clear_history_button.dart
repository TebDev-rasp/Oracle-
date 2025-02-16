import 'package:flutter/material.dart';

class ClearHistoryButton extends StatelessWidget {
  final VoidCallback onClear;

  const ClearHistoryButton({
    super.key,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton.icon(
        onPressed: onClear,
        icon: const Icon(Icons.clear_all),
        label: const Text('Clear History'),
        style: TextButton.styleFrom(
          foregroundColor: Colors.red,
        ),
      ),
    );
  }
}
