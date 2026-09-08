import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/project_provider.dart';
import '../widgets/sidebar_widget.dart';
import '../widgets/code_editor_widget.dart';
import '../widgets/visual_form_widget.dart';
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

    return Scaffold(
      backgroundColor: const Color(0xFF18181C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141418),
        elevation: 0,
        title: const Text('Mindmod IDE', style: TextStyle(color: Color(0xFFFBC02D), fontWeight: FontWeight.bold)),
        actions: [
          TextButton.icon(
            icon: Icon(isVisualMode ? Icons.code : Icons.tune, color: Colors.white, size: 18),
            label: Text(isVisualMode ? 'Ver Código' : 'Ver Formulario', style: const TextStyle(color: Colors.white)),
            onPressed: () => setState(() => isVisualMode = !isVisualMode),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFBC02D), foregroundColor: Colors.black),
            icon: const Icon(Icons.download, size: 18),
            label: const Text('Exportar ZIP'),
            onPressed: () async {
              final path = await ExportService.exportModToZip(projectState.files);
              if (context.mounted && path != null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Mod exportado en: $path')));
              }
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Row(
        children: [
          const SidebarWidget(),
          const VerticalDivider(width: 1, color: Color(0xFF303038)),
          Expanded(
            child: isVisualMode ? const VisualFormWidget() : const CodeEditorWidget(),
          ),
        ],
      ),
    );
  }
}
