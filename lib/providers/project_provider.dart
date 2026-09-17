import 'dart:io';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/project_file.dart';
import '../services/storage_service.dart';

class ProjectState {
  final List<ProjectFile> files;
  final String? activeFileName;

  ProjectState({
    required this.files,
    this.activeFileName,
  });

  ProjectFile? get activeFile {
    if (activeFileName == null) return null;
    try {
      return files.firstWhere((f) => f.name == activeFileName);
    } catch (_) {
      return null;
    }
  }

  ProjectState copyWith({List<ProjectFile>? files, String? activeFileName}) {
    return ProjectState(
      files: files ?? this.files,
      activeFileName: activeFileName ?? this.activeFileName,
    );
  }
}

class ProjectNotifier extends StateNotifier<ProjectState> {
  final String projectId;

  ProjectNotifier(this.projectId) : super(ProjectState(files: [], activeFileName: 'mod.json')) {
    _loadFromDisk();
  }

  Future<void> _loadFromDisk() async {
    final modsDir = await StorageService.getModsDirectory();
    final projectDir = Directory('${modsDir.path}/$projectId');
    
    if (!await projectDir.exists()) {
      await projectDir.create(recursive: true);
      await _ensureModStructureAndJson(projectDir);
      return;
    }

    final List<ProjectFile> loadedFiles = [];
    final entities = projectDir.listSync(recursive: true);
    for (var entity in entities) {
      if (entity is File) {
        final relativePath = entity.path.replaceFirst('${projectDir.path}/', '').replaceAll(Platform.pathSeparator, '/');
        final type = StorageService.getTypeFromPath(relativePath);
        final name = relativePath.split('/').last;
        
        // Load text files into content, or encode images to base64
        String content = '';
        if (type != FileType.image) {
          try {
            content = await entity.readAsString();
          } catch (_) {}
        } else {
          try {
            final bytes = await entity.readAsBytes();
            content = base64Encode(bytes);
          } catch (_) {}
        }
        
        loadedFiles.add(ProjectFile(
          name: type == FileType.image && relativePath.startsWith('sprites/') ? relativePath : name,
          type: type,
          content: content,
        ));
      }
    }
    
    // Ensure mod.json exists on disk and in memory
    if (!loadedFiles.any((f) => f.name == 'mod.json' || f.name == 'mod.hjson')) {
      await _ensureModStructureAndJson(projectDir);
      return;
    }

    state = state.copyWith(
      files: loadedFiles,
      activeFileName: loadedFiles.any((f) => f.name == 'mod.json') 
          ? 'mod.json' 
          : loadedFiles.first.name,
    );
  }

  Future<void> _ensureModStructureAndJson(Directory projectDir) async {
    final subdirs = [
      'scripts',
      'sprites',
      'content',
      'content/blocks',
      'content/items',
      'content/liquids',
      'content/units',
      'content/status',
      'content/sectors',
      'content/weathers',
    ];
    for (var sub in subdirs) {
      final d = Directory('${projectDir.path}/$sub');
      if (!await d.exists()) {
        await d.create(recursive: true);
      }
    }

    final modJsonFile = File('${projectDir.path}/mod.json');
    String content = '{\n  "name": "$projectId",\n  "displayName": "$projectId",\n  "author": "Creator",\n  "description": "An awesome Mindustry mod",\n  "version": "1.0",\n  "minGameVersion": "146"\n}';
    if (await modJsonFile.exists()) {
      try {
        content = await modJsonFile.readAsString();
      } catch (_) {}
    } else {
      await modJsonFile.writeAsString(content);
    }

    final file = ProjectFile(
      name: 'mod.json',
      type: FileType.modJson,
      content: content,
    );

    state = state.copyWith(files: [file], activeFileName: 'mod.json');
  }

  Future<void> _saveFileToDisk(ProjectFile file) async {
    final modsDir = await StorageService.getModsDirectory();
    final relativePath = StorageService.getRelativePathForType(file);
    final physicalFile = File('${modsDir.path}/$projectId/$relativePath');
    await physicalFile.parent.create(recursive: true);
    
    if (!file.isImage) {
      await physicalFile.writeAsString(file.content);
    }
  }

  Future<void> _deleteFileFromDisk(ProjectFile file) async {
    final modsDir = await StorageService.getModsDirectory();
    final relativePath = StorageService.getRelativePathForType(file);
    final physicalFile = File('${modsDir.path}/$projectId/$relativePath');
    if (await physicalFile.exists()) {
      await physicalFile.delete();
    }
  }

  // Re-read file directly from physical disk to guarantee zero data loss between changes
  Future<void> reloadFileFromDisk(String fileName) async {
    try {
      final modsDir = await StorageService.getModsDirectory();
      final file = state.files.firstWhere((f) => f.name == fileName);
      final relativePath = StorageService.getRelativePathForType(file);
      final physicalFile = File('${modsDir.path}/$projectId/$relativePath');
      if (await physicalFile.exists()) {
        if (file.isImage) {
          final bytes = await physicalFile.readAsBytes();
          final base64Content = base64Encode(bytes);
          final updatedFiles = state.files.map((f) => f.name == fileName ? f.copyWith(content: base64Content) : f).toList();
          state = state.copyWith(files: updatedFiles);
        } else {
          final content = await physicalFile.readAsString();
          final updatedFiles = state.files.map((f) => f.name == fileName ? f.copyWith(content: content) : f).toList();
          state = state.copyWith(files: updatedFiles);
        }
      }
    } catch (_) {}
  }

  Future<void> selectFile(String fileName) async {
    await reloadFileFromDisk(fileName);
    state = state.copyWith(activeFileName: fileName);
  }

  void setActiveFile(ProjectFile file) {
    selectFile(file.name);
  }

  Future<void> updateFileContent(String fileName, String newContent) async {
    final updatedFiles = state.files.map((file) {
      if (file.name == fileName) {
        final newFile = file.copyWith(content: newContent);
        _saveFileToDisk(newFile);
        return newFile;
      }
      return file;
    }).toList();
    state = state.copyWith(files: updatedFiles);
  }

  void updateActiveFileContent(String newContent) {
    if (state.activeFileName == null) return;
    updateFileContent(state.activeFileName!, newContent);
  }

  Future<void> addFile(ProjectFile file) async {
    final updatedFiles = [...state.files.where((f) => f.name != file.name), file];
    state = state.copyWith(files: updatedFiles, activeFileName: file.name);
    await _saveFileToDisk(file);
  }

  Future<void> createNewFile(String name, FileType type, {String content = ''}) async {
    await addFile(ProjectFile(name: name, type: type, content: content));
  }

  Future<void> renameFile(String oldName, String newName) async {
    if (oldName == newName) return;
    
    String finalName = newName;
    if (oldName.startsWith('sprites/') && !newName.startsWith('sprites/')) {
        finalName = 'sprites/' + newName;
    }
    
    final fileToRename = state.files.firstWhere((f) => f.name == oldName);
    
    // Delete old
    await _deleteFileFromDisk(fileToRename);
    
    // Create new
    final renamedFile = fileToRename.copyWith(name: finalName);
    await _saveFileToDisk(renamedFile);

    final updatedFiles = state.files.map((f) {
      if (f.name == oldName) return renamedFile;
      return f;
    }).toList();
    
    String? nextActive = state.activeFileName;
    if (state.activeFileName == oldName) {
      nextActive = finalName;
    }
    
    state = state.copyWith(files: updatedFiles, activeFileName: nextActive);
  }

  Future<void> deleteFile(String fileName) async {
    final fileToDelete = state.files.firstWhere((f) => f.name == fileName);
    await _deleteFileFromDisk(fileToDelete);

    final updatedFiles = state.files.where((f) => f.name != fileName).toList();
    String? nextActive = state.activeFileName;
    if (state.activeFileName == fileName) {
      nextActive = updatedFiles.isNotEmpty ? updatedFiles.first.name : null;
    }

    state = state.copyWith(files: updatedFiles, activeFileName: nextActive);
  }
}

final currentProjectIdProvider = StateProvider<String?>((ref) => null);

final projectsListProvider = StateNotifierProvider<ProjectsListNotifier, List<Map<String, String>>>((ref) {
  return ProjectsListNotifier();
});

class ProjectsListNotifier extends StateNotifier<List<Map<String, String>>> {
  ProjectsListNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final modsDir = await StorageService.getModsDirectory();
    final entities = modsDir.listSync();
    
    List<Map<String, String>> projects = [];
    for (var entity in entities) {
      if (entity is Directory) {
        final id = entity.path.split(Platform.pathSeparator).last;
        String name = id;
        
        // Try to read mod.json for display name
        final modJson = File('${entity.path}/mod.json');
        if (await modJson.exists()) {
          try {
            final content = await modJson.readAsString();
            final parsed = jsonDecode(content);
            if (parsed['displayName'] != null && parsed['displayName'].toString().trim().isNotEmpty) {
              name = parsed['displayName'].toString();
            }
          } catch (_) {}
        }
        
        projects.add({'id': id, 'name': name});
      }
    }
    
    // Si no hay mods en el directorio, el estado queda vacío tal como solicita el usuario
    state = projects;
  }

  Future<String> createProject(String rawName) async {
    final cleanName = rawName.trim();
    String id = cleanName.toLowerCase().replaceAll(RegExp(r'\s+'), '_').replaceAll(RegExp(r'[^a-z0-9_-]'), '');
    if (id.isEmpty) {
      id = 'mod_${DateTime.now().millisecondsSinceEpoch}';
    }

    final modsDir = await StorageService.getModsDirectory();
    final projectDir = Directory('${modsDir.path}/$id');
    if (!await projectDir.exists()) {
      await projectDir.create(recursive: true);
    }

    // Crear las carpetas scripts, sprites y content vacías sin jsons
    final subdirs = [
      'scripts',
      'sprites',
      'content',
      'content/blocks',
      'content/items',
      'content/liquids',
      'content/units',
      'content/status',
      'content/sectors',
      'content/weathers',
    ];
    for (var sub in subdirs) {
      final d = Directory('${projectDir.path}/$sub');
      if (!await d.exists()) {
        await d.create(recursive: true);
      }
    }

    // Crear el archivo mod.json inicial
    final modJsonFile = File('${projectDir.path}/mod.json');
    if (!await modJsonFile.exists()) {
      final initialData = {
        "name": id,
        "displayName": cleanName,
        "author": "Creator",
        "description": "An awesome Mindustry mod",
        "version": "1.0",
        "minGameVersion": "146"
      };
      const encoder = JsonEncoder.withIndent('  ');
      await modJsonFile.writeAsString(encoder.convert(initialData));
    }

    if (!state.any((p) => p['id'] == id)) {
      state = [...state, {'id': id, 'name': cleanName}];
    }
    return id;
  }

  String addProject(String name) {
    createProject(name);
    return name.toLowerCase().replaceAll(RegExp(r'\s+'), '_').replaceAll(RegExp(r'[^a-z0-9_-]'), '');
  }

  void renameProject(String id, String newName) {
    state = state.map((p) {
      if (p['id'] == id) return {'id': id, 'name': newName};
      return p;
    }).toList();
  }

  Future<void> deleteProject(String id) async {
    final modsDir = await StorageService.getModsDirectory();
    final projectDir = Directory('${modsDir.path}/$id');
    if (await projectDir.exists()) {
      await projectDir.delete(recursive: true);
    }
    state = state.where((p) => p['id'] != id).toList();
  }
}

final projectProvider = StateNotifierProvider<ProjectNotifier, ProjectState>((ref) {
  final projectId = ref.watch(currentProjectIdProvider);
  return ProjectNotifier(projectId ?? 'default');
});
