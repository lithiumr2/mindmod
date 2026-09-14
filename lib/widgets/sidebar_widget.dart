import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart' as filePicker;
import 'dart:convert';

import '../providers/project_provider.dart';
import '../providers/locale_provider.dart';
import '../models/project_file.dart';

class SidebarWidget extends ConsumerStatefulWidget {
  const SidebarWidget({super.key});

  @override
  ConsumerState<SidebarWidget> createState() => _SidebarWidgetState();
}

class _SidebarWidgetState extends ConsumerState<SidebarWidget> {
  String tr(String key) => ref.read(localeProvider.notifier).tr(key);
  String selectedFolder = 'blocks';

  @override
  Widget build(BuildContext context) {
    final projectState = ref.watch(projectProvider);
    final files = projectState.files;

    return Container(
      width: 210,
      color: const Color(0xFF141418),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(tr('workspace'), style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13)),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.settings, color: Colors.white54, size: 18),
                  color: const Color(0xFF222228),
                  onSelected: (value) {
                    if (value == 'import') {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('import_soon'))));
                    } else if (value == 'data') {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('data_config_soon'))));
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'import',
                      child: Text(tr('import_mod'), style: const TextStyle(color: Colors.white)),
                    ),
                    PopupMenuItem(
                      value: 'data',
                      child: Text(tr('data_config'), style: const TextStyle(color: Colors.white)),
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
                _buildSubFolderCategory(files, projectState, 'scripts', 'scripts', Icons.code, Colors.green),
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
                          contentPadding: const EdgeInsets.only(left: 20.0, right: 8.0),
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
                      contentPadding: const EdgeInsets.only(left: 20.0, right: 8.0),
                      leading: const Icon(Icons.add_circle_outline, color: Colors.amber, size: 16),
                      title: Text(tr('new_sprite'), style: const TextStyle(color: Colors.amber, fontSize: 12)),
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
      if (folderKey == 'scripts') return f.type == FileType.script;
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
              contentPadding: const EdgeInsets.only(left: 20.0, right: 8.0),
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
          contentPadding: const EdgeInsets.only(left: 20.0, right: 8.0),
          leading: const Icon(Icons.add_circle_outline, color: Colors.amber, size: 16),
          title: Text(tr(folderKey == 'items' ? 'new_item' : folderKey == 'liquids' ? 'new_liquid' : folderKey == 'units' ? 'new_unit' : folderKey == 'status' ? 'new_status' : folderKey == 'scripts' ? 'new_script' : folderKey == 'blocks' ? 'new_block' : 'new_project'), style: const TextStyle(color: Colors.amber, fontSize: 12)),
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

    final tr = ref.read(localeProvider.notifier).tr;
    String defaultName = 'copper-wall';
    String title = tr('new_block');
    String defaultContent = '{\n  name: "copper-wall"\n  type: "Wall"\n  health: 200\n  size: 1\n}';

    if (folder == 'items') {
      defaultName = 'custom-item';
      title = tr('new_item');
      defaultContent = '{\n  name: "custom-item"\n  cost: 1\n}';
    } else if (folder == 'liquids') {
      defaultName = 'custom-liquid';
      title = tr('new_liquid');
      defaultContent = '{\n  name: "custom-liquid"\n  color: "ff0000"\n}';
    } else if (folder == 'units') {
      defaultName = 'custom-unit';
      title = tr('new_unit');
      defaultContent = '{\n  name: "custom-unit"\n  type: "flying"\n  health: 150\n}';
    } else if (folder == 'status') {
      defaultName = 'custom-status';
      title = tr('new_status');
      defaultContent = '{\n  name: "custom-status"\n  damage: 0.5\n}';
    } else if (folder == 'scripts') {
      defaultName = 'script.js';
      title = tr('new_script');
      defaultContent = '// Main script file\n';
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
          decoration: InputDecoration(hintText: tr('filename_hint'), hintStyle: TextStyle(color: Colors.white54)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr('cancel'), style: const TextStyle(color: Colors.grey)),
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
                if (folder == 'scripts') determinedType = FileType.script;

                ref.read(projectProvider.notifier).addFile(
                  ProjectFile(
                    name: (folder == 'scripts') 
                        ? (controller.text.trim().endsWith('.js') ? controller.text.trim() : '${controller.text.trim()}.js') 
                        : (controller.text.trim().endsWith('.hjson') ? controller.text.trim() : '${controller.text.trim()}.hjson'),
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
            child: Text(tr('create')),
          ),
        ],
      ),
    );
  }
}
