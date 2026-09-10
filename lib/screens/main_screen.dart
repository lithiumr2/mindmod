import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import '../widgets/sidebar_widget.dart';
import '../widgets/visual_form_widget.dart';
import '../widgets/code_editor_widget.dart';
import '../widgets/mod_json_form_widget.dart';
import '../providers/project_provider.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  bool _isCodeView = false;

  @override
  Widget build(BuildContext context) {
    final activeFile = ref.watch(projectProvider).activeFile;
    
    final bool isModJson = activeFile?.name == 'mod.json';

    return Scaffold(
      backgroundColor: const Color(0xFF18181C),
      appBar: AppBar(
        title: Text(
          activeFile != null ? 'Mindmod IDE - ${activeFile.name}' : 'Mindmod IDE',
          style: const TextStyle(color: Color(0xFFFBC02D), fontSize: 16),
        ),
        backgroundColor: const Color(0xFF202026),
        elevation: 0,
        actions: [
          if (activeFile != null && !activeFile.isImage)
            ToggleButtons(
              isSelected: [!_isCodeView, _isCodeView],
              onPressed: (index) {
                setState(() {
                  _isCodeView = index == 1;
                });
              },
              color: Colors.white54,
              selectedColor: Colors.black,
              fillColor: const Color(0xFFFBC02D),
              constraints: const BoxConstraints(minHeight: 32, minWidth: 64),
              children: const [
                Icon(Icons.edit_outlined, size: 18),
                Icon(Icons.code, size: 18),
              ],
            ),
          const SizedBox(width: 12),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch, 
        children: [
          const SizedBox(
            width: 260,
            child: SidebarWidget(),
          ),
          Expanded(
            child: activeFile == null
                ? const Center(
                    child: Text(
                      'No file selected',
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                : activeFile.isImage
                    ? Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF202026),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(activeFile.name, style: const TextStyle(color: Colors.white70)),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 200,
                                child: Image.memory(
                                  base64Decode(activeFile.content),
                                  errorBuilder: (context, error, stackTrace) => const Text(
                                    'Error al cargar imagen',
                                    style: TextStyle(color: Colors.redAccent),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : isModJson
                        ? (_isCodeView ? const CodeEditorWidget() : const ModJsonFormWidget())
                        : (_isCodeView ? const CodeEditorWidget() : const VisualFormWidget()),
          ),
        ],
      ),
    );
  }
}
