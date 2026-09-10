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
  ProjectNotifier() : super(ProjectState(files: [], activeFileName: 'mod.json')) {
    _loadFromPrefs();
  }

  static const String _storageKey = 'mindmod_project_files';

  // Cargar datos al iniciar
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

    // Datos iniciales por defecto si es la primera vez que abre la app
    _loadDefaultFiles();
  }

  void _loadDefaultFiles() {
    final defaults = [
      ProjectFile(
        name: 'mod.json',
        type: FileType.json,
        content: '{\n  "name": "nuevo-mod",\n  "displayName": "Mi Super Mod",\n  "author": "Creador",\n  "description": "Un mod increíble para Mindustry",\n  "version": "1.0",\n  "minGameVersion": "146"\n}',
      ),
      ProjectFile(
        name: 'copper-wall.hjson',
        type: FileType.hjson,
        content: '{\n  name: "copper-wall"\n  type: "Wall"\n  health: 200\n  size: 1\n}',
      ),
    ];
    state = state.copyWith(files: defaults, activeFileName: 'copper-wall.hjson');
    _saveToPrefs();
  }

  // Guardar datos
  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedData = jsonEncode(state.files.map((f) => f.toJson()).toList());
    await prefs.setString(_storageKey, encodedData);
  }

  void selectFile(String fileName) {
    state = state.copyWith(activeFileName: fileName);
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

  void addFile(String name, FileType type, {String content = ''}) {
    final newFile = ProjectFile(name: name, type: type, content: content);
    final updatedFiles = [...state.files, newFile];
    state = state.copyWith(files: updatedFiles, activeFileName: name);
    _saveToPrefs();
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

final projectProvider = StateNotifierProvider<ProjectNotifier, ProjectState>((ref) {
  return ProjectNotifier();
});
