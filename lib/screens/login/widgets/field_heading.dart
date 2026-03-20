import 'package:flutter/material.dart';

class FieldHeading extends StatelessWidget {
  const FieldHeading({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF111827),
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
