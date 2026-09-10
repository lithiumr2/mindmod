import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/visual_form_widget.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF18181C),
      appBar: AppBar(
        title: const Text('Mindmod IDE', style: TextStyle(color: Color(0xFFFBC02D))),
        backgroundColor: const Color(0xFF202026),
        elevation: 0,
      ),
      body: const Row(
        children: [
          // Aquí irá tu barra lateral (Sidebar) cuando la conectes
          Expanded(
            child: VisualFormWidget(),
          ),
        ],
      ),
    );
  }
}
