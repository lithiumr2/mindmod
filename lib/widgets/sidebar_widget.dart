import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/project_provider.dart';
import '../models/project_file.dart';

class SidebarWidget extends ConsumerWidget {
  const SidebarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectState = ref.watch(projectProvider);
    final projectNotifier = ref.read(projectProvider.notifier);

    return Container(
      width: 250,
      color: const Color(0xFF141418),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.centerLeft,
            child: const Text(
              'Archivos del Mod',
              style: TextStyle(
                color: Color(0xFFFBC02D),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFF303038)),
          Expanded(
            child: ListView.builder(
              itemCount: projectState.files.length,
              itemBuilder: (context, index) {
                final file = projectState.files[index];
                final isActive = file.name == projectState.activeFileName;

                return ListTile(
                  dense: true,
                  selected: isActive,
                  selectedTileColor: const Color(0xFF202026),
                  leading: Icon(
                    file.isImage ? Icons.image : Icons.description,
                    color: isActive ? const Color(0xFFFBC02D) : Colors.grey,
                    size: 18,
                  ),
                  title: Text(
                    file.name,
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey[300],
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: file.name == 'mod.json'
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close, size: 16, color: Colors.redAccent),
                          onPressed: () => projectNotifier.deleteFile(file.name),
                        ),
                  onTap: () => projectNotifier.selectFile(file.name),
                );
              },
            ),
          ),
          const Divider(height: 1, color: Color(0xFF303038)),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFBC02D),
                foregroundColor: Colors.black,
                minimumSize: const Size.fromHeight(40),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Nuevo Archivo'),
              onPressed: () => _showNewFileDialog(context, projectNotifier),
            ),
          ),
        ],
      ),
    );
  }

  void _showNewFileDialog(BuildContext context, ProjectNotifier notifier) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF202026),
        title: const Text('Nuevo Elemento', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'ej: mega-wall.hjson',
            hintStyle: TextStyle(color: Colors.grey),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                var name = controller.text.trim().toLowerCase();
                if (!name.endsWith('.hjson')) name += '.hjson';
                notifier.addFile(
                  name,
                  FileType.hjson,
                  content: '{\n  type: "Wall"\n  health: 300\n  size: 1\n}',
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }
}
