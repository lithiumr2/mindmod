import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/project_file.dart';
import '../providers/project_provider.dart';
import '../services/export_service.dart';
import '../widgets/code_editor_widget.dart';
import '../widgets/visual_form_widget.dart';
import '../widgets/mod_json_form_widget.dart';
import '../widgets/sidebar_widget.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  bool _isCodeView = false;

    @override
  Widget build(BuildContext context) {
    final projectState = ref.watch(projectProvider);
    final activeFile = projectState.activeFile;
    final isModJson = activeFile?.name == 'mod.json';

    final topBar = Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: const Color(0xFF18181C),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            activeFile != null ? '${activeFile.name.replaceAll(".hjson", "")}' : 'Selecciona un archivo',
            style: const TextStyle(color: Colors.amber, fontSize: 14),
          ),
          Row(
            children: [
              if (activeFile != null && !activeFile.isImage)
                ToggleButtons(
                  isSelected: [!_isCodeView, _isCodeView],
                  onPressed: (index) => setState(() => _isCodeView = index == 1),
                  color: Colors.white54,
                  selectedColor: Colors.black,
                  fillColor: const Color(0xFFFBC02D),
                  constraints: const BoxConstraints(minHeight: 32, minWidth: 50),
                  children: const [
                    Icon(Icons.edit, size: 16),
                    Icon(Icons.code, size: 16),
                  ],
                ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white70),
                color: const Color(0xFF202026),
                onSelected: (value) async {
                  if (value == 'export_zip') {
                    final path = await ExportService.exportModToZip(projectState.files);
                    if (context.mounted && path != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Mod exportado en: $path')),
                      );
                    }
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'export_zip',
                    child: Row(
                      children: [
                        Icon(Icons.download, color: Color(0xFFFBC02D), size: 18),
                        SizedBox(width: 10),
                        Text('Exportar ZIP', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF18181C),
      body: SafeArea(
        child: Row(
          children: [
            const SidebarWidget(),
            Expanded(
              child: Column(
                children: [
                  topBar,
                  Expanded(
                    child: activeFile == null
                        ? const Center(child: Text('Selecciona o crea un archivo', style: TextStyle(color: Colors.white54)))
                        : activeFile.isImage
                            ? Center(child: Image.memory(base64Decode(activeFile.content), fit: BoxFit.contain, errorBuilder: (c,e,s) => const Text('Error al cargar imagen', style: TextStyle(color: Colors.red))))
                            : isModJson
                                ? (_isCodeView ? const CodeEditorWidget() : const ModJsonFormWidget())
                                : (_isCodeView ? const CodeEditorWidget() : const VisualFormWidget()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

