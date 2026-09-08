import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/project_file.dart';
import '../services/hjson_engine.dart';

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

  ProjectState copyWith({
    List<ProjectFile>? files,
    String? activeFileName,
  }) {
    return ProjectState(
      files: files ?? this.files,
      activeFileName: activeFileName ?? this.activeFileName,
    );
  }
}

class ProjectNotifier extends StateNotifier<ProjectState> {
  ProjectNotifier() : super(ProjectState(files: [])) {
    _initDefaultProject();
  }

  void _initDefaultProject() {
    final modJson = ProjectFile(
      name: 'mod.json',
      content: '''{
  name: "nuevo-mod"
  displayName: "Mi Super Mod"
  author: "Creador"
  description: "Un mod increíble para Mindustry"
  version: "1.0"
  minGameVersion: "146"
}''',
      type: FileType.hjson,
    );

    state = ProjectState(files: [modJson], activeFileName: 'mod.json');
  }

  void selectFile(String fileName) {
    state = state.copyWith(activeFileName: fileName);
  }

  void updateActiveFileContent(String newContent) {
    if (state.activeFileName == null) return;

    final updatedFiles = state.files.map((file) {
      if (file.name == state.activeFileName) {
        return ProjectFile(
          name: file.name,
          content: newContent,
          binaryContent: file.binaryContent,
          type: file.type,
        );
      }
      return file;
    }).toList();

    state = state.copyWith(files: updatedFiles);
  }

  void addFile(String name, FileType type, {String content = ''}) {
    final newFile = ProjectFile(name: name, content: content, type: type);
    state = state.copyWith(
      files: [...state.files, newFile],
      activeFileName: name,
    );
  }

  void deleteFile(String name) {
    if (name == 'mod.json') return; // Archivo protegido
    final updatedFiles = state.files.where((f) => f.name != name).toList();
    final nextActive = updatedFiles.isNotEmpty ? updatedFiles.first.name : null;
    state = state.copyWith(files: updatedFiles, activeFileName: nextActive);
  }
}

final projectProvider = StateNotifierProvider<ProjectNotifier, ProjectState>((ref) {
  return ProjectNotifier();
});
