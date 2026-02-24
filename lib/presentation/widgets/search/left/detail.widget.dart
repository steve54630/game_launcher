import 'package:flutter/material.dart';

class DetailInfo extends StatelessWidget {
  final String label;
  final String value;
  const DetailInfo({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: labelStyle),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

const labelStyle = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.bold,
  color: Colors.white38,
  letterSpacing: 1.2,
);
