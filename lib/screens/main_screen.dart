import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/sidebar_widget.dart';
import '../widgets/visual_form_widget.dart';
import '../widgets/code_editor_widget.dart';
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
    
    // Evitamos que mod.json intente renderizarse en el formulario visual de bloques
    final bool isModJson = activeFile?.name == 'mod.json';
    final bool forceCodeView = _isCodeView || isModJson;

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
              // Si es mod.json, forzamos que el selector marque "Código" y deshabilitamos el "Visual"
              isSelected: [!forceCodeView, forceCodeView],
              onPressed: (index) {
                if (!isModJson) {
                  setState(() {
                    _isCodeView = index == 1;
                  });
                }
              },
              color: Colors.white54,
              selectedColor: Colors.black,
              fillColor: isModJson ? Colors.grey : const Color(0xFFFBC02D),
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
        // SOLUCIÓN 1: Obliga a los widgets hijos a ocupar exactamente el 100% de la pantalla disponible.
        // Esto elimina el error de altura de CodeEditorWidget y VisualFormWidget.
        crossAxisAlignment: CrossAxisAlignment.stretch, 
        children: [
          // SOLUCIÓN 2: Enjaulamos la barra lateral en un ancho fijo de 260px para evitar un colapso horizontal.
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
                // SOLUCIÓN 3: Renderiza con seguridad. Si es mod.json, inyecta siempre el CodeEditorWidget.
                : (forceCodeView && !activeFile.isImage
                    ? const CodeEditorWidget()
                    : const VisualFormWidget()),
          ),
        ],
      ),
    );
  }
}
