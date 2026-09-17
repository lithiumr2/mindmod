import 'dart:typed_data';
import 'export_service.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/project_file.dart';
import 'dart:convert';
import 'package:path/path.dart' as p;

class StorageService {
  static Future<String?> saveExportedFile(String fileName, List<int> bytes) async {
    return ExportService.saveFileToDisk(fileName, Uint8List.fromList(bytes));
  }

  static Future<Directory> getModsDirectory() async {
    Directory? baseDir;
    if (Platform.isAndroid) {
      baseDir = await getExternalStorageDirectory();
    } else {
      baseDir = await getApplicationDocumentsDirectory();
    }
    final modsDir = Directory('${baseDir!.path}/mods');
    if (!await modsDir.exists()) {
      await modsDir.create(recursive: true);
    }
    return modsDir;
  }

  static String getRelativePathForType(ProjectFile file) {
    if (file.name == 'mod.json' || file.name == 'mod.hjson') {
      return file.name;
    }
    if (file.isImage) {
      if (file.name.startsWith('sprites/')) return file.name;
      return 'sprites/${file.name}';
    }
    String folder = 'content/blocks/';
    switch (file.type) {
      case FileType.item:
        folder = 'content/items/';
        break;
      case FileType.liquid:
        folder = 'content/liquids/';
        break;
      case FileType.unit:
        folder = 'content/units/';
        break;
      case FileType.status:
        folder = 'content/status/';
        break;
      case FileType.sector:
        folder = 'content/sectors/';
        break;
      case FileType.weather:
        folder = 'content/weathers/';
        break;
      case FileType.script:
        folder = 'scripts/';
        break;
      case FileType.block:
      default:
        folder = 'content/blocks/';
        break;
    }
    return '$folder${file.name.split('/').last}';
  }

  static FileType getTypeFromPath(String relativePath) {
    if (relativePath == 'mod.json' || relativePath == 'mod.hjson') return FileType.modJson;
    if (relativePath.startsWith('sprites/')) return FileType.image;
    if (relativePath.startsWith('scripts/')) return FileType.script;
    
    if (relativePath.contains('content/items/')) return FileType.item;
    if (relativePath.contains('content/liquids/')) return FileType.liquid;
    if (relativePath.contains('content/units/')) return FileType.unit;
    if (relativePath.contains('content/status/')) return FileType.status;
    if (relativePath.contains('content/sectors/')) return FileType.sector;
    if (relativePath.contains('content/weathers/')) return FileType.weather;
    if (relativePath.contains('content/blocks/')) return FileType.block;
    
    return FileType.other;
  }
}
