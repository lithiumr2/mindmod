import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/project_file.dart';
import '../services/storage_service.dart';

class ProjectState {
  final List<ProjectFile> files;
  final String? activeFileName;

  ProjectState({required this.files, this.activeFileName});

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
        final relativePath = entity.path.replaceFirst('${projectDir.path}/', '');
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
            final bytes = await (entity as File).readAsBytes();
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
    
    if (loadedFiles.isEmpty) {
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

  Future<void> selectFile(String fileName) async {
    // Before switching, let's make sure we have the latest content from disk if it's a text file
    try {
      final modsDir = await StorageService.getModsDirectory();
      final file = state.files.firstWhere((f) => f.name == fileName);
      if (!file.isImage) {
        final relativePath = StorageService.getRelativePathForType(file);
        final physicalFile = File('${modsDir.path}/$projectId/$relativePath');
        if (await physicalFile.exists()) {
          final content = await physicalFile.readAsString();
          final updatedFiles = state.files.map((f) {
            if (f.name == fileName) return f.copyWith(content: content);
            return f;
          }).toList();
          state = state.copyWith(files: updatedFiles, activeFileName: fileName);
          return;
        }
      }
    } catch(e) {
      print("Error reading file from disk on switch: $e");
    }
    state = state.copyWith(activeFileName: fileName);
  }

  void setActiveFile(ProjectFile file) {
    selectFile(file.name);
  }
  
  void updateFileContent(String fileName, String newContent) {
    final updatedFiles = state.files.map((file) {
      if (file.name == fileName) {
        final newFile = file.copyWith(content: newContent);
        _saveFileToDisk(newFile); // Async save
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

  void addFile(ProjectFile file) {
    final updatedFiles = [...state.files, file];
    state = state.copyWith(files: updatedFiles, activeFileName: file.name);
    _saveFileToDisk(file);
  }

  void createNewFile(String name, FileType type, {String content = ''}) {
    addFile(ProjectFile(name: name, type: type, content: content));
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
            if (parsed['displayName'] != null) {
              name = parsed['displayName'];
            }
          } catch (_) {}
        }
        
        projects.add({'id': id, 'name': name});
      }
    }
    
    // if (projects.isEmpty) { ... }
    
    state = projects;
  }
  
  Future<String> createProject(String name) async {
    final id = name.toLowerCase().replaceAll(RegExp(r'\s+'), '_');
    state = [...state, {'id': id, 'name': name}];
    // Also create it on disk right now
    final modsDir = await StorageService.getModsDirectory();
    final projectDir = Directory('${modsDir.path}/$id');
    if (!await projectDir.exists()) {
      await projectDir.create(recursive: true);
    }
    return id;
  }

  void renameProject(String id, String newName) {
    // Note: We are not renaming the folder here to keep it simple, just updating the list
    // A proper rename would rename the folder on disk. For now, we just update state 
    // and ideally the mod.json
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
