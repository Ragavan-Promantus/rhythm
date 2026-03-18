import 'package:flutter/material.dart';

class RegisterSocialButton extends StatelessWidget {
  const RegisterSocialButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 66,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF43158E), width: 1.2),
          backgroundColor: const Color(0xFF180D28),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                children: [
                  TextSpan(
                    text: 'G',
                    style: TextStyle(color: Color(0xFFEA4335)),
                  ),
                  TextSpan(
                    text: 'o',
                    style: TextStyle(color: Color(0xFFFBBC05)),
                  ),
                  TextSpan(
                    text: 'o',
                    style: TextStyle(color: Color(0xFF34A853)),
                  ),
                  TextSpan(
                    text: 'g',
                    style: TextStyle(color: Color(0xFF4285F4)),
                  ),
                  TextSpan(
                    text: 'l',
                    style: TextStyle(color: Color(0xFF34A853)),
                  ),
                  TextSpan(
                    text: 'e',
                    style: TextStyle(color: Color(0xFFEA4335)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 18),
            Text(
              'Continue with $label',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
