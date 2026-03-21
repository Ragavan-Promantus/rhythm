import 'package:flutter/material.dart';

import 'screens/login/login_screen.dart';

void main() {
  runApp(const RhythmApp());
}

class RhythmApp extends StatelessWidget {
  const RhythmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rhythm',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F4FF),
        fontFamily: 'Roboto',
      ),
      home: const LoginScreen(),
    );
  }
}
