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
  String selectedFolder = 'blocks';

  @override
  Widget build(BuildContext context) {
    final projectState = ref.watch(projectProvider);
    final files = projectState.files;

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
                      dense: true,
                      contentPadding: const EdgeInsets.only(left: 32.0, right: 16.0),
                      leading: const Icon(Icons.add_circle_outline, color: Colors.green, size: 16),
                      title: const Text('New Script (.js)', style: TextStyle(color: Colors.green, fontSize: 12)),
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Soporte para JS próximamente'))),
                    )
                  ],
                ),
                ExpansionTile(
                  leading: const Icon(Icons.folder, color: Colors.blue, size: 18),
                  title: const Text('sprites', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  initiallyExpanded: selectedFolder == 'sprites',
                  onExpansionChanged: (exp) {
                     if (exp) setState(() => selectedFolder = 'sprites');
                  },
                  children: [
                    ...files.where((f) => f.isImage).map((file) => ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.only(left: 32.0, right: 16.0),
                          leading: const Icon(Icons.image, color: Colors.purpleAccent, size: 16),
                          title: Text(file.name.replaceAll('.hjson', ''), style: const TextStyle(color: Colors.white, fontSize: 12)),
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
                      title: const Text('New Sprite', style: TextStyle(color: Colors.amber, fontSize: 12)),
                      onTap: () {
                        setState(() => selectedFolder = 'sprites');
                        _showNewItemDialog(context, ref, 'sprites');
                      },
                    ),
                  ],
                ),
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
      
      if (folderKey == 'items') return f.type == FileType.item;
      if (folderKey == 'liquids') return f.type == FileType.liquid;
      if (folderKey == 'units') return f.type == FileType.unit;
      if (folderKey == 'status') return f.type == FileType.status;
      if (folderKey == 'blocks') return f.type == FileType.block;
      return false;
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
              title: Text(file.name.replaceAll('.hjson', ''), style: const TextStyle(color: Colors.white, fontSize: 12)),
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
          title: Text('New ' + (folderKey == 'items' ? 'Item' : folderKey == 'liquids' ? 'Liquid' : folderKey == 'units' ? 'Unit' : folderKey == 'status' ? 'Status' : folderKey == 'blocks' ? 'Block' : folderKey), style: const TextStyle(color: Colors.amber, fontSize: 12)),
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
          ProjectFile(
            name: fileName,
            type: FileType.image,
            content: base64Image,
          ),
        );
      }
      return;
    }

    String defaultName = 'copper-wall';
    String title = 'Create New Block';
    String defaultContent = '{\n  name: "copper-wall"\n  type: "Wall"\n  health: 200\n  size: 1\n}';

    if (folder == 'items') {
      defaultName = 'custom-item';
      title = 'Create New Item';
      defaultContent = '{\n  name: "custom-item"\n  cost: 1\n}';
    } else if (folder == 'liquids') {
      defaultName = 'custom-liquid';
      title = 'Create New Liquid';
      defaultContent = '{\n  name: "custom-liquid"\n  color: "ff0000"\n}';
    } else if (folder == 'units') {
      defaultName = 'custom-unit';
      title = 'Create New Unit';
      defaultContent = '{\n  name: "custom-unit"\n  type: "flying"\n  health: 150\n}';
    } else if (folder == 'status') {
      defaultName = 'custom-status';
      title = 'Create New Status';
      defaultContent = '{\n  name: "custom-status"\n  damage: 0.5\n}';
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
          decoration: const InputDecoration(hintText: 'filename', hintStyle: TextStyle(color: Colors.white54)),
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
                
                FileType determinedType = FileType.block;
                if (folder == 'items') determinedType = FileType.item;
                if (folder == 'liquids') determinedType = FileType.liquid;
                if (folder == 'units') determinedType = FileType.unit;
                if (folder == 'status') determinedType = FileType.status;

                ref.read(projectProvider.notifier).addFile(
                  ProjectFile(
                    name: controller.text.trim().endsWith('.hjson') ? controller.text.trim() : '${controller.text.trim()}.hjson',
                    type: determinedType,
                    content: defaultContent
                        .replaceAll('copper-wall', baseName)
                        .replaceAll('custom-item', baseName)
                        .replaceAll('custom-liquid', baseName)
                        .replaceAll('custom-unit', baseName)
                        .replaceAll('custom-status', baseName),
                  ),
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
