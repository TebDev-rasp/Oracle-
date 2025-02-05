import 'package:flutter/material.dart';

class HeatIndexContainer extends StatelessWidget {
  const HeatIndexContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Heat-Index',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.white : const Color(0xFF111217),
          ),
        ),
        Container(
          width: double.infinity,
          height: 150,
          margin: const EdgeInsets.only(top: 8, bottom: 24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFFB5EAD7),  // Soft Mint
                Color(0xFF98DDCA),  // Light Sage
              ],
            ),
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                offset: const Offset(0, 1),
                blurRadius: 2,
                spreadRadius: 0.5,
              ),
            ],
          ),
        ),
      ],
    );
  }
}