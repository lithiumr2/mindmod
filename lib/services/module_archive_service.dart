import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import '../models/module_schema.dart';

/// Excepción personalizada para errores durante la importación o validación de módulos
class ModuleArchiveException implements Exception {
  final String message;
  const ModuleArchiveException(this.message);

  @override
  String toString() => 'ModuleArchiveException: $message';
}

/// Servicio singleton/estático para empaquetar y desempaquetar módulos en formato .zip o .mmodpkg
class ModuleArchiveService {
  ModuleArchiveService._();

  /// Versión actual del formato de esquema de manifiesto
  static const String currentSchemaVersion = '1.0';

  /// Exporta un [CustomModule] como archivo binario ZIP con manifest.json y estructura limpia
  static Uint8List exportModuleToZip(CustomModule module) {
    try {
      final archive = Archive();

      // Preparamos el payload del manifiesto enriquecido con metadatos de empaquetado
      final manifestMap = {
        'schemaVersion': currentSchemaVersion,
        'generator': 'MindMod Dynamic Schema Engine',
        'exportedAt': DateTime.now().toIso8601String(),
        'module': module.toJson(),
      };

      final manifestJson = const JsonEncoder.withIndent('  ').convert(manifestMap);
      final manifestBytes = utf8.encode(manifestJson);

      archive.addFile(
        ArchiveFile('manifest.json', manifestBytes.length, manifestBytes),
      );

      // Creamos marcador para futuras texturas o assets si la extensión lo requiere
      final readmeContent = utf8.encode(
        '# ${module.name}\n\n'
        'Autor: ${module.author}\n'
        'Versión: ${module.version}\n\n'
        '${module.description}\n\n'
        'Módulo compatible con MindMod Schema Engine v${currentSchemaVersion}.\n',
      );
      archive.addFile(
        ArchiveFile('README.md', readmeContent.length, readmeContent),
      );

      final zipData = ZipEncoder().encode(archive);
      if (zipData == null) {
        throw const ModuleArchiveException('Error al comprimir el archivo ZIP del módulo.');
      }

      return Uint8List.fromList(zipData);
    } catch (e) {
      if (e is ModuleArchiveException) rethrow;
      throw ModuleArchiveException('Fallo al exportar el módulo: $e');
    }
  }

  /// Importa y valida rigurosamente un [CustomModule] desde los bytes de un archivo ZIP
  static CustomModule importModuleFromZip(List<int> bytes) {
    if (bytes.isEmpty) {
      throw const ModuleArchiveException('El archivo ZIP está vacío o dañado.');
    }

    Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(bytes);
    } catch (e) {
      throw ModuleArchiveException('No se pudo descomprimir el archivo binario: $e');
    }

    // Buscamos manifest.json en la raíz o en una subcarpeta
    ArchiveFile? manifestFile;
    for (final file in archive) {
      if (file.isFile && (file.name == 'manifest.json' || file.name.endsWith('/manifest.json'))) {
        manifestFile = file;
        break;
      }
    }

    if (manifestFile == null) {
      throw const ModuleArchiveException(
        'El archivo ZIP no contiene un "manifest.json" válido de módulo MindMod.',
      );
    }

    String jsonString;
    try {
      jsonString = utf8.decode(manifestFile.content as List<int>);
    } catch (e) {
      throw ModuleArchiveException('El archivo manifest.json no tiene codificación UTF-8 válida: $e');
    }

    dynamic rawJson;
    try {
      rawJson = jsonDecode(jsonString);
    } catch (e) {
      throw ModuleArchiveException('Error de sintaxis JSON en manifest.json: $e');
    }

    if (rawJson is! Map<String, dynamic>) {
      throw const ModuleArchiveException('La raíz de manifest.json debe ser un objeto JSON.');
    }

    // Comprobación de compatibilidad y extracción del objeto module
    Map<String, dynamic> moduleData;
    if (rawJson.containsKey('module') && rawJson['module'] is Map<String, dynamic>) {
      moduleData = rawJson['module'] as Map<String, dynamic>;
    } else {
      // Compatibilidad con manifiestos planos
      moduleData = rawJson;
    }

    // Validación estricta de campos obligatorios
    final id = moduleData['id']?.toString().trim();
    if (id == null || id.isEmpty) {
      throw const ModuleArchiveException('El módulo carece de un "id" identificador único.');
    }

    // Sanitización y verificación de ID
    final idRegex = RegExp(r'^[a-zA-Z0-9_\-]+$');
    if (!idRegex.hasMatch(id)) {
      throw ModuleArchiveException(
        'El ID del módulo "$id" contiene caracteres no válidos. Solo se permiten letras, números, guiones y guiones bajos.',
      );
    }

    final name = moduleData['name']?.toString().trim();
    if (name == null || name.isEmpty) {
      throw const ModuleArchiveException('El módulo debe contener un "name" descriptivo.');
    }

    final version = moduleData['version']?.toString().trim() ?? '1.0.0';

    // Validación de nombres de clave en tipos personalizados para evitar inyecciones maliciosas o corruptas
    if (moduleData['customTypes'] is List) {
      final typesList = moduleData['customTypes'] as List;
      for (final rawType in typesList) {
        if (rawType is Map<String, dynamic>) {
          final typeId = rawType['typeId']?.toString().trim();
          if (typeId == null || typeId.isEmpty) {
            throw const ModuleArchiveException('Un CustomTypeSchema carece de "typeId".');
          }

          if (rawType['properties'] is List) {
            final props = rawType['properties'] as List;
            final Set<String> seenKeys = {};
            for (final rawProp in props) {
              if (rawProp is Map<String, dynamic>) {
                final key = rawProp['key']?.toString().trim();
                if (key == null || key.isEmpty) {
                  throw ModuleArchiveException('Una propiedad en el tipo "$typeId" no tiene clave ("key").');
                }
                if (seenKeys.contains(key)) {
                  throw ModuleArchiveException('Clave duplicada "$key" detectada en el tipo "$typeId".');
                }
                seenKeys.add(key);
              }
            }
          }
        }
      }
    }

    try {
      return CustomModule.fromJson(moduleData);
    } catch (e) {
      throw ModuleArchiveException('Error al deserializar la estructura del módulo: $e');
    }
  }
}
