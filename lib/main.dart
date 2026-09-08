import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MindmodApp(),
    ),
  );
}

class MindmodApp extends StatelessWidget {
  const MindmodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mindmod IDE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF18181C),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFBC02D),
          surface: Color(0xFF202026),
        ),
      ),
      home: const MainScreen(),
    );
  }
}
