import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart' as filePicker;
import 'dart:convert';
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
    final files = projectState.files;

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
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Mindmod Workspace',
                  style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.settings, color: Colors.white54, size: 18),
                  color: const Color(0xFF222228),
                  onSelected: (value) {
                    if (value == 'import') {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Importación próximamente...')));
                    } else if (value == 'data') {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Config. de Datos próximamente...')));
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'import',
                      child: Text('Importar Mod', style: TextStyle(color: Colors.white)),
                    ),
                    const PopupMenuItem(
                      value: 'data',
                      child: Text('Configuración de Datos', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
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
                  initiallyExpanded: true,
                  children: [
                    _buildSubFolderCategory(files, projectState, 'blocks', 'blocks', Icons.folder, Colors.blueAccent),
                    _buildSubFolderCategory(files, projectState, 'items', 'items', Icons.folder, Colors.orangeAccent),
                    _buildSubFolderCategory(files, projectState, 'liquids', 'liquids', Icons.folder, Colors.cyanAccent),
                    _buildSubFolderCategory(files, projectState, 'units', 'units', Icons.folder, Colors.redAccent),
                    _buildSubFolderCategory(files, projectState, 'status', 'status', Icons.folder, Colors.purpleAccent),
                  ],
                ),
                ExpansionTile(
                  leading: const Icon(Icons.code, color: Colors.green, size: 18),
                  title: const Text('scripts', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  initiallyExpanded: false,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.add, color: Colors.green, size: 16),
                      title: const Text('New Script (.js)', style: TextStyle(color: Colors.green, fontSize: 12)),
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Soporte para JS próximamente'))),
                    )
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
                  ...files.where((f) => f.isImage).map((file) => ListTile(
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

        ],
      ),
    );
  }

  Widget _buildSubFolderCategory(
    List<ProjectFile> files,
    dynamic projectState,
    String title,
    String folderKey,
    IconData icon,
    Color iconColor,
  ) {
    final categoryFiles = files.where((f) {
      if (f.name == 'mod.json' || f.isImage) return false;
      final content = f.content.toLowerCase();
      if (folderKey == 'items') {
        return f.name.contains('item') || content.contains('type: "item"');
      }
      if (folderKey == 'liquids') {
        return f.name.contains('liquid') || content.contains('type: "liquid"');
      }
      return !f.name.contains('item') && 
             !f.name.contains('liquid') && 
             !content.contains('type: "item"') && 
             !content.contains('type: "liquid"');
    }).toList();

    return ExpansionTile(
      leading: Icon(icon, color: iconColor, size: 18),
      title: Text(
        title,
        style: TextStyle(
          color: selectedFolder == folderKey ? const Color(0xFFFBC02D) : Colors.white70,
          fontSize: 13,
        ),
      ),
      onExpansionChanged: (expanded) {
        if (expanded) {
          setState(() => selectedFolder = folderKey);
        }
      },
      children: [
        ...categoryFiles.map((file) => ListTile(
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
          )),
        ListTile(
          dense: true,
          contentPadding: const EdgeInsets.only(left: 32.0, right: 16.0),
          leading: const Icon(Icons.add_circle_outline, color: Colors.amber, size: 16),
          title: Text('New ${title.substring(0, title.length - 1)}', style: const TextStyle(color: Colors.amber, fontSize: 12)),
          onTap: () {
             setState(() => selectedFolder = folderKey);
            _showNewItemDialog(context, ref, folderKey);
          },
        ),
      ],
    );
  }

  Future<void> _showNewItemDialog(BuildContext context, WidgetRef ref, String folder) async {
    if (folder == 'sprites') {
      filePicker.FilePickerResult? result = await filePicker.FilePicker.platform.pickFiles(
        type: filePicker.FileType.image,
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        final fileName = result.files.single.name;
        final bytes = result.files.single.bytes!;
        final base64Image = base64Encode(bytes);
        
        ref.read(projectProvider.notifier).addFile(
              fileName,
              FileType.image,
              content: base64Image,
            );
      }
      return;
    }

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
                final baseName = controller.text.split('.').first;
                ref.read(projectProvider.notifier).addFile(
                      controller.text.trim(),
                      FileType.hjson,
                      content: defaultContent
                          .replaceAll('copper-wall', baseName)
                          .replaceAll('custom-item', baseName)
                          .replaceAll('custom-liquid', baseName),
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
