import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/project_file.dart';
import '../providers/project_provider.dart';
import '../services/export_service.dart';
import '../widgets/code_editor_widget.dart';
import '../widgets/visual_form_widget.dart';
import '../widgets/mod_json_form_widget.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  bool _isCodeView = false;
  String _activeCategory = 'items';

  String get _buttonLabel {
    switch (_activeCategory) {
      case 'blocks':
        return '+ New Block';
      case 'liquids':
        return '+ New Liquid';
      case 'items':
      default:
        return '+ New Item';
    }
  }

  FileType get _activeFileType {
    switch (_activeCategory) {
      case 'blocks':
        return FileType.block;
      case 'liquids':
        return FileType.liquid;
      case 'items':
      default:
        return FileType.item;
    }
  }

  void _createNewFile() {
    final TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF222228),
        title: Text('Crear en $_activeCategory', style: const TextStyle(color: Colors.amber)),
        content: TextField(
          controller: nameController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Nombre del archivo (ej. custom-item)',
            hintStyle: TextStyle(color: Colors.white38),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFBC02D)),
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                final fileName = nameController.text.trim().endsWith('.hjson')
                    ? nameController.text.trim()
                    : '${nameController.text.trim()}.hjson';
                
                ref.read(projectProvider.notifier).addFile(
                  ProjectFile(
                    name: fileName,
                    content: '{\n  name: "${nameController.text.trim()}"\n}',
                    type: _activeFileType,
                  ),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Crear', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final projectState = ref.watch(projectProvider);
    final activeFile = projectState.activeFile;
    final isModJson = activeFile?.name == 'mod.json';

    return Scaffold(
      backgroundColor: const Color(0xFF18181C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF18181C),
        elevation: 0,
        title: Text(
          activeFile != null ? 'Mindmod IDE - ${activeFile.name}' : 'Mindmod IDE',
          style: const TextStyle(color: Colors.amber, fontSize: 16),
        ),
        actions: [
          if (activeFile != null && !activeFile.isImage)
            ToggleButtons(
              isSelected: [!_isCodeView, _isCodeView],
              onPressed: (index) => setState(() => _isCodeView = index == 1),
              color: Colors.white54,
              selectedColor: Colors.black,
              fillColor: const Color(0xFFFBC02D),
              constraints: const BoxConstraints(minHeight: 32, minWidth: 50),
              children: const [
                Icon(Icons.edit, size: 16),
                Icon(Icons.code, size: 16),
              ],
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white70),
            onSelected: (value) async {
              if (value == 'export_zip') {
                final path = await ExportService.exportModToZip(projectState.files);
                if (context.mounted && path != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Mod exportado en: $path')),
                  );
                }
              }
            },
            itemBuilder: (context) => [
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
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          // PANEL LATERAL IZQUIERDO
          Container(
            width: 250,
            decoration: const BoxDecoration(
              color: Color(0xFF121214),
              border: Border(right: BorderSide(color: Colors.white12, width: 1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    'Mod Folders',
                    style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                ListTile(
                  dense: true,
                  selected: activeFile?.name == 'mod.json',
                  selectedTileColor: Colors.white10,
                  leading: const Icon(Icons.insert_drive_file, color: Colors.amber, size: 18),
                  title: const Text('mod.json', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    final modFile = projectState.files.firstWhere(
                      (f) => f.name == 'mod.json',
                      orElse: () => ProjectFile(name: 'mod.json', content: '{}', type: FileType.modJson),
                    );
                    ref.read(projectProvider.notifier).setActiveFile(modFile);
                  },
                ),
                const Divider(color: Colors.white12),
                Expanded(
                  child: ListView(
                    children: [
                      ExpansionTile(
                        initiallyExpanded: true,
                        leading: const Icon(Icons.folder, color: Colors.amber, size: 18),
                        title: const Text('content', style: TextStyle(color: Colors.white)),
                        childrenPadding: const EdgeInsets.only(left: 12),
                        children: [
                          _buildFolderTile('blocks', Icons.square_outlined, Colors.blue, projectState),
                          _buildFolderTile('items', Icons.hexagon_outlined, Colors.orange, projectState),
                          _buildFolderTile('liquids', Icons.water_drop_outlined, Colors.cyan, projectState),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFBC02D),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: _createNewFile,
                      child: Text(
                        _buttonLabel,
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // VISTA PRINCIPAL DERECHA
          Expanded(
            child: activeFile == null
                ? const Center(child: Text('Selecciona o crea un archivo', style: TextStyle(color: Colors.white54)))
                : activeFile.isImage
                    ? const Center(child: Text('Vista previa de imagen no soportada', style: TextStyle(color: Colors.white54)))
                    : isModJson
                        ? (_isCodeView ? const CodeEditorWidget() : const ModJsonFormWidget())
                        : (_isCodeView ? const CodeEditorWidget() : const VisualFormWidget()),
          ),
        ],
      ),
    );
  }

  Widget _buildFolderTile(String folderName, IconData icon, Color iconColor, ProjectState projectState) {
    final isCategoryActive = _activeCategory == folderName;
    FileType targetType;
    if (folderName == 'blocks') {
      targetType = FileType.block;
    } else if (folderName == 'liquids') {
      targetType = FileType.liquid;
    } else {
      targetType = FileType.item;
    }

    final categoryFiles = projectState.files.where((f) => f.type == targetType).toList();

    return ExpansionTile(
      dense: true,
      initiallyExpanded: isCategoryActive,
      leading: Icon(icon, color: iconColor, size: 18),
      title: Text(folderName, style: const TextStyle(color: Colors.white70)),
      onExpansionChanged: (expanded) {
        if (expanded) {
          setState(() {
            _activeCategory = folderName;
          });
        }
      },
      children: categoryFiles.map((file) {
        final isFileActive = projectState.activeFile?.name == file.name;
        return ListTile(
          dense: true,
          contentPadding: const EdgeInsets.only(left: 36, right: 12),
          selected: isFileActive,
          selectedTileColor: Colors.amber.withOpacity(0.15),
          title: Text(
            file.name,
            style: TextStyle(
              color: isFileActive ? Colors.amber : Colors.white60,
              fontSize: 13,
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.close, size: 14, color: Colors.white24),
            onPressed: () {
              ref.read(projectProvider.notifier).deleteFile(file.name);
            },
          ),
          onTap: () {
            ref.read(projectProvider.notifier).selectFile(file.name);
          },
        );
      }).toList(),
    );
  }
}
