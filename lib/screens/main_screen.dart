import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/sidebar_widget.dart';
import '../widgets/visual_form_widget.dart';
import '../widgets/code_editor_widget.dart';
import '../providers/project_provider.dart';
import '../services/export_service.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  bool isVisualMode = true;

  @override
  Widget build(BuildContext context) {
    final projectState = ref.watch(projectProvider);
    final activeFile = projectState.activeFile;

    return Scaffold(
      backgroundColor: const Color(0xFF18181C),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Mindmod IDE',
          style: TextStyle(
            color: Color(0xFFFBC02D),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu, color: Colors.white),
            color: const Color(0xFF202026),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Color(0xFF303038)),
            ),
            onSelected: (value) async {
              if (value == 'toggle_mode') {
                setState(() => isVisualMode = !isVisualMode);
              } else if (value == 'export_zip') {
                final path = await ExportService.exportModToZip(projectState.files);
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
                      isVisualMode ? Icons.code : Icons.tune,
                      color: const Color(0xFFFBC02D),
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      isVisualMode ? 'Ver Código' : 'Ver Formulario',
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
      body: Padding(
        padding: const EdgeInsets.only(top: 56.0),
        child: Row(
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
                  : (activeFile.name == 'mod.json'
                      ? const CodeEditorWidget()
                      : (isVisualMode && !activeFile.isImage
                          ? const VisualFormWidget()
                          : const CodeEditorWidget())),
            ),
          ],
        ),
      ),
    );
  }
}
