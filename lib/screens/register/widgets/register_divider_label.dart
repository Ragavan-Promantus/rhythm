import 'package:flutter/material.dart';

class RegisterDividerLabel extends StatelessWidget {
  const RegisterDividerLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: Color(0xFFD9D4EC), thickness: 1.2)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18),
          child: Text(
            'Or continue with',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(child: Divider(color: Color(0xFFD9D4EC), thickness: 1.2)),
      ],
    );
  }
}
