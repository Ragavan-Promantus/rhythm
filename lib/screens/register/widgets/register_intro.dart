import 'package:flutter/material.dart';

class RegisterIntro extends StatelessWidget {
  const RegisterIntro({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Join the Rhythm',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 38,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.4,
            height: 1.05,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Start your musical journey today',
          style: TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 19,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
