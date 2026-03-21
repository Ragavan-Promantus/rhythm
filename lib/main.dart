import 'package:flutter/material.dart';

import 'screens/library/library_screen.dart';
import 'screens/login/login_screen.dart';
import 'services/session_service.dart';

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
      home: const AppBootstrap(),
    );
  }
}

class AppBootstrap extends StatelessWidget {
  const AppBootstrap({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: SessionService.hasSession(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return snapshot.data! ? const LibraryScreen() : const LoginScreen();
      },
    );
  }
}
