import 'package:flutter/material.dart';

class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 104,
          width: 104,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF7A29FF), Color(0xFF4F11D8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x802D0CC7),
                blurRadius: 24,
                spreadRadius: 2,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: const Icon(
            Icons.music_note_rounded,
            color: Colors.white,
            size: 50,
          ),
        ),
        const SizedBox(height: 26),
        const Text(
          'Rhythm',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.4,
            height: 1,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Your world of music',
          style: TextStyle(
            color: Color(0xFF5814C8),
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
