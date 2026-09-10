import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/project_provider.dart';
import '../services/export_service.dart';
import '../widgets/code_editor_widget.dart';
import '../widgets/visual_form_widget.dart';
import '../widgets/mod_json_form_widget.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: Text(activeFile?.name ?? 'Mindmod IDE'),
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
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'toggle_mode') {
                setState(() => _isCodeView = !_isCodeView);
              } else if (value == 'export_zip') {
                final path = await ExportService.exportModToZip(ref.read(projectProvider).files);
                if (context.mounted && path != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Mod exportado en Descargas: $path')),
                  );
                }
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'toggle_mode',
                child: Row(
                  children: [
                    Icon(
                      !_isCodeView ? Icons.code : Icons.tune,
                      color: const Color(0xFFFBC02D),
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      !_isCodeView ? 'Ver Código' : 'Ver Formulario',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
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
          const SizedBox(width: 12),
        ],
      ),
      body: activeFile == null
          ? const Center(child: Text('Selecciona o crea un archivo', style: TextStyle(color: Colors.white)))
          : activeFile.isImage
              ? const Center(child: Text('Vista de imagen no disponible en este editor', style: TextStyle(color: Colors.white)))
              : isModJson
                  ? (_isCodeView ? const CodeEditorWidget() : const ModJsonFormWidget())
                  : (_isCodeView ? const CodeEditorWidget() : const VisualFormWidget()),
    );
  }
}
