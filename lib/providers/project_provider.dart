import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/project_file.dart';

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
    _loadFromPrefs();
  }

  String get _storageKey => 'mindmod_project_files_$projectId';

  // Cargar datos persistentes al iniciar
  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final List<dynamic> decodedList = jsonDecode(jsonString);
        final loadedFiles = decodedList.map((item) => ProjectFile.fromJson(item)).toList();
        state = state.copyWith(
          files: loadedFiles,
          activeFileName: loadedFiles.isNotEmpty ? loadedFiles.first.name : null,
        );
        return;
      } catch (_) {}
    }

    _loadDefaultFiles();
  }

  void _loadDefaultFiles() {
    final defaults = [
      ProjectFile(
        name: 'mod.json',
        type: FileType.modJson,
        content: '{\n  "name": "nuevo-mod",\n  "displayName": "Mi Super Mod",\n  "author": "Creador",\n  "description": "Un mod increíble para Mindustry",\n  "version": "1.0",\n  "minGameVersion": "146"\n}',
      ),
      ProjectFile(
        name: 'copper-wall.hjson',
        type: FileType.block,
        content: '{\n  name: "copper-wall"\n  type: "Wall"\n  health: 200\n  size: 1\n}',
      ),
    ];
    state = state.copyWith(files: defaults, activeFileName: 'copper-wall.hjson');
    _saveToPrefs();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedData = jsonEncode(state.files.map((f) => f.toJson()).toList());
    await prefs.setString(_storageKey, encodedData);
  }

  void selectFile(String fileName) {
    state = state.copyWith(activeFileName: fileName);
  }

  void setActiveFile(ProjectFile file) {
    selectFile(file.name);
  }

    void updateFileContent(String fileName, String newContent) {
    final updatedFiles = state.files.map((file) {
      if (file.name == fileName) {
        return file.copyWith(content: newContent);
      }
      return file;
    }).toList();
    state = state.copyWith(files: updatedFiles);
    _saveToPrefs();
  }

  void updateActiveFileContent(String newContent) {
    if (state.activeFileName == null) return;
    final updatedFiles = state.files.map((file) {
      if (file.name == state.activeFileName) {
        return file.copyWith(content: newContent);
      }
      return file;
    }).toList();

    state = state.copyWith(files: updatedFiles);
    _saveToPrefs();
  }

  void addFile(ProjectFile file) {
    final updatedFiles = [...state.files, file];
    state = state.copyWith(files: updatedFiles, activeFileName: file.name);
    _saveToPrefs();
  }

  void createNewFile(String name, FileType type, {String content = ''}) {
    addFile(ProjectFile(name: name, type: type, content: content));
  }

  void deleteFile(String fileName) {
    final updatedFiles = state.files.where((f) => f.name != fileName).toList();
    String? nextActive = state.activeFileName;
    if (state.activeFileName == fileName) {
      nextActive = updatedFiles.isNotEmpty ? updatedFiles.first.name : null;
    }
    state = state.copyWith(files: updatedFiles, activeFileName: nextActive);
    _saveToPrefs();
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
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString('mindmod_projects_list');
    if (str != null) {
      try {
        final List<dynamic> decoded = jsonDecode(str);
        state = decoded.map((e) => Map<String, String>.from(e)).toList();
      } catch (_) {}
    }
    if (state.isEmpty) {
      state = [{'id': 'default', 'name': 'My First Mod'}];
      _save();
    }
  }
  
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('mindmod_projects_list', jsonEncode(state));
  }
  
  void addProject(String name) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    state = [...state, {'id': id, 'name': name}];
    _save();
  }

  void deleteProject(String id) {
    state = state.where((p) => p['id'] != id).toList();
    _save();
  }
}

final projectProvider = StateNotifierProvider<ProjectNotifier, ProjectState>((ref) {
  final projectId = ref.watch(currentProjectIdProvider);
  return ProjectNotifier(projectId ?? 'default');
});
