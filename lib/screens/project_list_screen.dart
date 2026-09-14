import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/project_provider.dart';
import '../providers/locale_provider.dart';
import 'package:file_picker/file_picker.dart' as fp;
import 'package:archive/archive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/project_file.dart';
import 'dart:typed_data';
import 'main_screen.dart';

String _getTr(WidgetRef ref, String key) => ref.read(localeProvider.notifier).tr(key);



  Future<void> _importModZip(BuildContext context, WidgetRef ref) async {
    try {
      fp.FilePickerResult? result = await fp.FilePicker.platform.pickFiles(
        type: fp.FileType.custom,
        allowedExtensions: ['zip'],
        withData: true,
      );
      if (result != null && result.files.single.bytes != null) {
        final bytes = result.files.single.bytes!;
        final archive = ZipDecoder().decodeBytes(bytes);
        
        String projName = result.files.single.name.replaceAll('.zip', '');
        final newId = ref.read(projectsListProvider.notifier).addProject(projName);
        
        List<ProjectFile> files = [];
        for (final file in archive) {
          if (file.isFile) {
            final filename = file.name;
            // Ignore Mac OS metadata
            if (filename.contains('__MACOSX')) continue;
            
            FileType type = FileType.other;
            if (filename.endsWith('.hjson') || filename.endsWith('.json')) {
               if (filename.contains('blocks/')) type = FileType.block;
               else if (filename.contains('items/')) type = FileType.item;
               else if (filename.contains('liquids/')) type = FileType.liquid;
               else if (filename.contains('units/')) type = FileType.unit;
               else if (filename.contains('status/')) type = FileType.status;
               else if (filename.contains('sectors/')) type = FileType.sector;
               else if (filename.contains('weather/')) type = FileType.weather;
               else if (filename.endsWith('mod.json') || filename.endsWith('mod.hjson')) type = FileType.modJson;
               
               final contentStr = utf8.decode(file.content as List<int>);
               files.add(ProjectFile(name: filename.split('/').last, type: type, content: contentStr));
            } else if (filename.endsWith('.png')) {
               final base64Str = base64Encode(file.content as List<int>);
               files.add(ProjectFile(name: filename.split('/').last, type: FileType.other, content: base64Str));
            }
          }
        }
        
        if (files.isEmpty) {
          files.add(ProjectFile(name: 'mod.json', type: FileType.modJson, content: '{\n  "name": "imported-mod"\n}'));
        }
        
        final prefs = await SharedPreferences.getInstance();
        final encodedData = jsonEncode(files.map((f) => f.toJson()).toList());
        await prefs.setString('mindmod_project_files_$newId', encodedData);
        
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${_getTr(ref, 'import_success')}: $projName')));
      }
    } catch(e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${_getTr(ref, 'import_error')}: $e')));
    }
  }


  void _showRenameDialog(BuildContext context, WidgetRef ref, String id, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E24),
        title: Text(_getTr(ref, 'rename_project'), style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: _getTr(ref, 'hint_project_name'),
            hintStyle: const TextStyle(color: Colors.white24),
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: Text(_getTr(ref, 'cancel'), style: const TextStyle(color: Colors.white54))),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                 final notifier = ref.read(projectsListProvider.notifier);
                 // Unfortunately, ProjectsListNotifier doesn't have a rename method. Let's just update the list.
                 notifier.renameProject(id, controller.text.trim());
                 // It won't save automatically unless we add a method, but we can't easily without editing the provider.
                 // Actually, we can add renameProject to project_provider.dart
                 Navigator.pop(c);
              }
            },
            child: Text(_getTr(ref, 'save'), style: const TextStyle(color: Colors.amber)),
          ),
        ],
      ),
    );
  }


void _showSettingsDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Consumer(
          builder: (context, ref, child) {
            final lang = ref.watch(localeProvider);
            final tr = ref.read(localeProvider.notifier).tr;
            
            return AlertDialog(
              backgroundColor: const Color(0xFF222228),
              title: Text(tr('general_settings'), style: const TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tr('language'), style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 10),
                  DropdownButton<String>(
                    value: lang == 'es' || lang == 'en' || lang == 'ru' ? lang : 'system',
                    dropdownColor: const Color(0xFF2A2A35),
                    isExpanded: true,
                    style: const TextStyle(color: Colors.white),
                    items: [
                      DropdownMenuItem(value: 'system', child: Text(tr('system'))),
                      DropdownMenuItem(value: 'en', child: Text(tr('english'))),
                      DropdownMenuItem(value: 'es', child: Text(tr('spanish'))),
                      DropdownMenuItem(value: 'ru', child: Text(tr('russian'))),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(localeProvider.notifier).setLocale(val);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(tr('close'), style: const TextStyle(color: Colors.amber)),
                ),
              ],
            );
          },
        );
      },
    );
  }

class ProjectListScreen extends ConsumerWidget {
  const ProjectListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectsListProvider);
    final tr = ref.read(localeProvider.notifier).tr;

    return Scaffold(
      backgroundColor: const Color(0xFF18181C),
      appBar: AppBar(
        title: Text(ref.read(localeProvider.notifier).tr('title'), style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF202026),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white70),
            onPressed: () => _showSettingsDialog(context, ref),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tr('recent_projects'),
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        _importModZip(context, ref);
                      },
                      icon: const Icon(Icons.upload_file),
                      label: Text(tr('import_mod')),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.amber,
                        side: const BorderSide(color: Colors.amber),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () => _showCreateProjectDialog(context, ref),
                      icon: const Icon(Icons.add),
                      label: Text(tr('new_project')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 32),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                ),
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  final proj = projects[index];
                  return Card(
                    color: const Color(0xFF202026),
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: InkWell(
                      onTap: () {
                        ref.read(currentProjectIdProvider.notifier).state = proj['id'];
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const MainScreen()));
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Icon(Icons.folder_special, color: Colors.amber, size: 32),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                                  onPressed: () {
                                    ref.read(projectsListProvider.notifier).deleteProject(proj['id']!);
                                  },
                                )
                              ],
                            ),
                            const Spacer(),
                            Text(
                              proj['name'] ?? tr('unnamed'),
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'ID: ${proj['id']}',
                              style: const TextStyle(color: Colors.white54, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateProjectDialog(BuildContext context, WidgetRef ref) {
    final tr = ref.read(localeProvider.notifier).tr;
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF202026),
        title: Text(tr('new_project'), style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: tr('mod_name'),
            hintStyle: const TextStyle(color: Colors.white54),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr('cancel'), style: const TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref.read(projectsListProvider.notifier).addProject(controller.text.trim());
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
            child: Text(tr('create')),
          ),
        ],
      ),
    );
  }
}
