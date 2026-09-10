import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/project_provider.dart';
import '../models/project_file.dart';

class SidebarWidget extends ConsumerWidget {
  const SidebarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectState = ref.watch(projectProvider);

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
                    ExpansionTile(
                      leading: const Icon(Icons.folder, color: Colors.blueAccent, size: 18),
                      title: const Text('blocks', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      children: projectState.files
                          .where((f) => f.name != 'mod.json' && !f.isImage)
                          .map((file) => ListTile(
                                leading: const Icon(Icons.insert_drive_file, color: Colors.amber, size: 16),
                                title: Text(file.name, style: const TextStyle(color: Colors.white, fontSize: 12)),
                                selected: projectState.activeFileName == file.name,
                                selectedTileColor: const Color(0xFF202026),
                                onTap: () => ref.read(projectProvider.notifier).selectFile(file.name),
                                trailing: file.name != 'mod.json'
                                    ? IconButton(
                                        icon: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
                                        onPressed: () => ref.read(projectProvider.notifier).deleteFile(file.name),
                                      )
                                    : null,
                              ))
                          .toList(),
                    ),
                  ],
                ),
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
                label: const Text('New Block', style: TextStyle(fontSize: 12)),
                onPressed: () {
                  _showNewBlockDialog(context, ref);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNewBlockDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: 'copper-wall.hjson');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF202026),
        title: const Text('Create New Block', style: TextStyle(color: Colors.white, fontSize: 16)),
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
                      content: '{\n  name: "${controller.text.split('.').first}"\n  type: "Wall"\n  health: 200\n  size: 1\n}',
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
