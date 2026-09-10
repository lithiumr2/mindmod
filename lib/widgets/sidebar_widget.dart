import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/project_provider.dart';
import '../models/project_file.dart';

class SidebarWidget extends ConsumerStatefulWidget {
  const SidebarWidget({super.key});

  @override
  ConsumerState<SidebarWidget> createState() => _SidebarWidgetState();
}

class _SidebarWidgetState extends ConsumerState<SidebarWidget> {
  String selectedFolder = 'blocks'; // 'blocks', 'items', 'liquids', 'sprites'

  @override
  Widget build(BuildContext context) {
    final projectState = ref.watch(projectProvider);

    // Determinar etiqueta dinámica para el botón inferior según la carpeta activa
    String buttonLabel = 'New Block';
    if (selectedFolder == 'items') buttonLabel = 'New Item';
    if (selectedFolder == 'liquids') buttonLabel = 'New Liquid';
    if (selectedFolder == 'sprites') buttonLabel = 'New Sprite';

    return Container(
      width: 260,
      color: const Color(0xFF141418),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              'Mod Folders',
              style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.description, color: Color(0xFFFBC02D), size: 18),
                  title: const Text('mod.json', style: TextStyle(color: Colors.white, fontSize: 13)),
                  selected: projectState.activeFileName == 'mod.json',
                  selectedTileColor: const Color(0xFF202026),
                  onTap: () => ref.read(projectProvider.notifier).selectFile('mod.json'),
                ),
                ExpansionTile(
                  leading: const Icon(Icons.folder, color: Color(0xFFFBC02D), size: 18),
                  title: const Text('content', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  children: [
                    _buildSubFolderCategory(projectState, 'blocks', 'blocks', Icons.folder, Colors.blueAccent),
                    _buildSubFolderCategory(projectState, 'items', 'items', Icons.folder, Colors.orangeAccent),
                    _buildSubFolderCategory(projectState, 'liquids', 'liquids', Icons.folder, Colors.cyanAccent),
                  ],
                ),
                ListTile(
                  leading: const Icon(Icons.folder, color: Colors.blue, size: 18),
                  title: const Text('sprites', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  selected: selectedFolder == 'sprites',
                  selectedTileColor: const Color(0xFF202026),
                  onTap: () => setState(() => selectedFolder = 'sprites'),
                ),
                if (selectedFolder == 'sprites')
                  ...projectState.files.where((f) => f.isImage).map((file) => ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.only(left: 32.0, right: 16.0),
                        leading: const Icon(Icons.image, color: Colors.purpleAccent, size: 16),
                        title: Text(file.name, style: const TextStyle(color: Colors.white, fontSize: 12)),
                        selected: projectState.activeFileName == file.name,
                        selectedTileColor: const Color(0xFF202026),
                        onTap: () => ref.read(projectProvider.notifier).selectFile(file.name),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
                          onPressed: () => ref.read(projectProvider.notifier).deleteFile(file.name),
                        ),
                      )),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFBC02D), foregroundColor: Colors.black),
                icon: const Icon(Icons.add, size: 16),
                label: Text(buttonLabel, style: const TextStyle(fontSize: 12)),
                onPressed: () {
                  _showNewItemDialog(context, ref, selectedFolder);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubFolderCategory(dynamic projectState, String title, String folderKey, IconData icon, Color iconColor) {
    final files = projectState.files.where((f) {
      if (f.name == 'mod.json' || f.isImage) return false;
      if (folderKey == 'items') return f.name.contains('item') || f.content.contains('type: "Item"');
      if (folderKey == 'liquids') return f.name.contains('liquid') || f.content.contains('type: "Liquid"');
      return !f.name.contains('item') && !f.name.contains('liquid') && !f.content.contains('type: "Item"') && !f.content.contains('type: "Liquid"');
    }).toList();

    return ExpansionTile(
      leading: Icon(icon, color: iconColor, size: 18),
      title: Text(title, style: TextStyle(color: selectedFolder == folderKey ? const Color(0xFFFBC02D) : Colors.white70, fontSize: 13)),
      onExpansionChanged: (_) => setState(() => selectedFolder = folderKey),
      children: files.map((file) => ListTile(
            dense: true,
            contentPadding: const EdgeInsets.only(left: 32.0, right: 16.0),
            leading: const Icon(Icons.insert_drive_file, color: Colors.amber, size: 16),
            title: Text(file.name, style: const TextStyle(color: Colors.white, fontSize: 12)),
            selected: projectState.activeFileName == file.name,
            selectedTileColor: const Color(0xFF202026),
            onTap: () => ref.read(projectProvider.notifier).selectFile(file.name),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
              onPressed: () => ref.read(projectProvider.notifier).deleteFile(file.name),
            ),
          )).toList(),
    );
  }

  void _showNewItemDialog(BuildContext context, WidgetRef ref, String folder) {
    String defaultName = 'copper-wall.hjson';
    String title = 'Create New Block';
    String defaultContent = '{\n  name: "copper-wall"\n  type: "Wall"\n  health: 200\n  size: 1\n}';

    if (folder == 'items') {
      defaultName = 'custom-item.hjson';
      title = 'Create New Item';
      defaultContent = '{\n  name: "custom-item"\n  cost: 1\n}';
    } else if (folder == 'liquids') {
      defaultName = 'custom-liquid.hjson';
      title = 'Create New Liquid';
      defaultContent = '{\n  name: "custom-liquid"\n  color: "ff0000"\n}';
    } else if (folder == 'sprites') {
      return;
    }

    final controller = TextEditingController(text: defaultName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF202026),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(hintText: 'filename.hjson', hintStyle: TextStyle(color: Colors.white54)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFBC02D), foregroundColor: Colors.black),
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(projectProvider.notifier).addFile(
                      controller.text.trim(),
                      FileType.hjson,
                      content: defaultContent.replaceAll('custom-item', controller.text.split('.').first).replaceAll('copper-wall', controller.text.split('.').first).replaceAll('custom-liquid', controller.text.split('.').first),
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
