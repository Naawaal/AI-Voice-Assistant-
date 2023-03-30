import 'package:flutter/material.dart';
import 'package:voice_assistant/const/colors.dart';

class FeatureBox extends StatelessWidget {
  final String text;
  final String descriptionText;
  final Color color;
  const FeatureBox({
    super.key,
    required this.color,
    required this.text,
    required this.descriptionText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 35, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              text,
              style: const TextStyle(
                color: Pallete.blackColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              descriptionText,
              style: const TextStyle(
                color: Pallete.blackColor,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
