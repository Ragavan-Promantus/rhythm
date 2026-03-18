import 'package:flutter/material.dart';

class RegisterTopBar extends StatelessWidget {
  const RegisterTopBar({required this.onBackPressed, super.key});

  final VoidCallback onBackPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: onBackPressed,
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 28,
              ),
              splashRadius: 22,
              padding: EdgeInsets.zero,
            ),
          ),
          const Text(
            'Create Account',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
    );
  }
}
