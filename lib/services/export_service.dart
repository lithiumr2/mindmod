import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../models/project_file.dart';
import 'hjson_engine.dart';

class ExportService {
  /// Empaqueta el proyecto en un archivo .zip compatible con Mindustry
  static Future<String?> exportModToZip(List<ProjectFile> files) async {
    final archive = Archive();

    for (final file in files) {
      if (file.name == 'mod.json') {
        final bytes = utf8.encode(file.content);
        archive.addFile(ArchiveFile('mod.json', bytes.length, bytes));
      } else if (file.isImage && file.binaryContent != null) {
        final spriteName = file.name.replaceAll('sprites/', '');
        archive.addFile(ArchiveFile('sprites/$spriteName', file.binaryContent!.length, file.binaryContent!));
      } else {
        final parsed = HjsonEngine.parse(file.content);
        final type = (parsed['type']?.toString() ?? 'Block').toLowerCase();

        String folder = 'content/blocks/';
        if (type.contains('item')) {
          folder = 'content/items/';
        } else if (type.contains('liquid')) {
          folder = 'content/liquids/';
        }

        final bytes = utf8.encode(file.content);
        archive.addFile(ArchiveFile('$folder${file.name}', bytes.length, bytes));
      }
    }

    final encoder = ZipEncoder();
    final zipData = encoder.encode(archive);
    if (zipData == null) return null;

    final modJsonFile = files.where((f) => f.name == 'mod.json').firstOrNull;
    String modName = 'mindmod';
    if (modJsonFile != null) {
      final parsedMod = HjsonEngine.parse(modJsonFile.content);
      if (parsedMod['name'] != null) {
        modName = parsedMod['name'].toString().toLowerCase().replaceAll(RegExp(r'\s+'), '-');
      }
    }

    return await _saveFileToDisk('$modName.zip', Uint8List.fromList(zipData));
  }

  /// Genera un archivo de respaldo completo .mindmod
  static Future<String?> exportProjectBackup(List<ProjectFile> files) async {
    final List<Map<String, dynamic>> filesData = [];

    for (final file in files) {
      filesData.add({
        'name': file.name,
        'content': file.content,
        'type': file.type.name,
        'binaryContent': file.binaryContent != null ? base64Encode(file.binaryContent!) : null,
      });
    }

    final projectData = {
      'version': '1.0',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'files': filesData,
    };

    final jsonString = jsonEncode(projectData);
    final bytes = utf8.encode(jsonString);

    return await _saveFileToDisk('proyecto-backup.mindmod', Uint8List.fromList(bytes));
  }

  /// Guarda el archivo directamente en el almacenamiento nativo del sistema
  static Future<String?> _saveFileToDisk(String fileName, Uint8List bytes) async {
    if (Platform.isAndroid || Platform.isIOS) {
      final directory = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      return filePath;
    } else {
      final outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Guardar archivo exportado',
        fileName: fileName,
      );

      if (outputPath != null) {
        final file = File(outputPath);
        await file.writeAsBytes(bytes);
        return outputPath;
      }
    }
    return null;
  }
}
