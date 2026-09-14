class HjsonEngine {
  /// Formatea un mapa de datos de Dart a sintaxis Hjson limpia y con tipado estricto
  static String stringify(Map<String, dynamic> data) {
    final buffer = StringBuffer();
    buffer.writeln('{');
    data.forEach((key, value) {
      if (value == null) return;
      if (value is String && value.trim().isEmpty && key != 'name' && key != 'description') return;
      
      final formatted = _formatValue(key, value, indentLevel: 1);
      buffer.writeln('  $key: $formatted');
    });
    buffer.writeln('}');
    return buffer.toString();
  }

  static String _formatValue(String key, dynamic value, {int indentLevel = 1}) {
    final indent = '  ' * indentLevel;
    if (value is bool) {
      return value ? 'true' : 'false';
    }
    if (value is num) {
      return value.toString();
    }
    if (value is List) {
      if (value.isEmpty) return '[]';
      final listBuffer = StringBuffer();
      listBuffer.writeln('[');
      for (var item in value) {
        listBuffer.writeln('$indent  ${_formatValue("", item, indentLevel: indentLevel + 1)}');
      }
      listBuffer.write('$indent]');
      return listBuffer.toString();
    }
    if (value is Map) {
      final mapBuffer = StringBuffer();
      mapBuffer.writeln('{');
      value.forEach((k, v) {
        mapBuffer.writeln('$indent  $k: ${_formatValue(k.toString(), v, indentLevel: indentLevel + 1)}');
      });
      mapBuffer.write('$indent}');
      return mapBuffer.toString();
    }
    final strVal = value.toString().trim();
    // Verificación de número estricto si no es un campo textual obligatorio
    if (key != 'name' && key != 'description' && key != 'type' && key != 'category' && key != 'shootSound' && key != 'version' && key != 'minGameVersion' && key != 'author') {
      if (int.tryParse(strVal) != null) return int.parse(strVal).toString();
      if (double.tryParse(strVal) != null) return double.parse(strVal).toString();
      if (strVal.toLowerCase() == 'true') return 'true';
      if (strVal.toLowerCase() == 'false') return 'false';
    }
    // Comillas para strings con espacios o sintaxis Hjson
    if (strVal.contains(' ') || strVal.contains('{') || strVal.contains('}') || strVal.contains(':') || strVal.contains('[')) {
      final escaped = strVal.replaceAll('"', r'\"');
      return '"$escaped"';
    }
    return strVal.isEmpty ? '""' : strVal;
  }

  /// Validador léxico y sintáctico de Hjson en segundo plano
  static List<String> validateSyntax(String content) {
    final List<String> errors = [];
    int braceCount = 0;
    int bracketCount = 0;
    bool inQuote = false;
    final lines = content.split('\n');
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final trimmed = line.trim();
      if (trimmed.startsWith('#') || trimmed.startsWith('//')) continue;
      for (int c = 0; c < line.length; c++) {
        final char = line[c];
        if (char == '"' && (c == 0 || line[c - 1] != '\\')) {
          inQuote = !inQuote;
        }
        if (!inQuote) {
          if (char == '{') braceCount++;
          if (char == '}') braceCount--;
          if (char == '[') bracketCount++;
          if (char == ']') bracketCount--;
          if (braceCount < 0) {
            errors.add('Línea ${i + 1}: Llave de cierre \'}\' inesperada.');
            braceCount = 0;
          }
          if (bracketCount < 0) {
            errors.add('Línea ${i + 1}: Corchete de cierre \']\' inesperado.');
            bracketCount = 0;
          }
        }
      }
    }
    if (inQuote) {
      errors.add('Hay comillas dobles abiertas sin cerrar.');
    }
    if (braceCount > 0) {
      errors.add('Faltan $braceCount llave(s) de cierre \'}\'.');
    }
    if (bracketCount > 0) {
      errors.add('Faltan $bracketCount corchete(s) de cierre \']\'.');
    }
    return errors;
  }

  /// Parser con soporte de números, booleanos, listas y estructuras
  static Map<String, dynamic> parse(String content) {
    final Map<String, dynamic> result = {};
    final lines = content.split('\n');
    int i = 0;
    while (i < lines.length) {
      final line = lines[i];
      final trimmed = line.trim();
      i++;
      if (trimmed.isEmpty || trimmed.startsWith('#') || trimmed.startsWith('//')) continue;
      if (trimmed == '{' || trimmed == '}') continue;

      final colonIndex = trimmed.indexOf(':');
      if (colonIndex != -1) {
        final key = trimmed.substring(0, colonIndex).trim();
        var rawVal = trimmed.substring(colonIndex + 1).trim();

        // Si empieza una lista con [
        if (rawVal.startsWith('[')) {
          if (rawVal.endsWith(']') && rawVal.length >= 2) {
            final inner = rawVal.substring(1, rawVal.length - 1).trim();
            if (inner.isEmpty) {
              result[key] = [];
            } else {
              result[key] = inner
                  .split(',')
                  .map((e) => _cleanItem(e))
                  .where((e) => e != null && e.toString().trim().isNotEmpty)
                  .toList();
            }
          } else {
            final list = <dynamic>[];
            final firstPart = rawVal.substring(1).trim();
            if (firstPart.isNotEmpty && firstPart != ']') {
              for (var part in firstPart.split(',')) {
                final cleaned = _cleanItem(part);
                if (cleaned != null && cleaned.toString().trim().isNotEmpty) {
                  list.add(cleaned);
                }
              }
            }
            while (i < lines.length) {
              final nextLine = lines[i].trim();
              i++;
              if (nextLine.isEmpty || nextLine.startsWith('#') || nextLine.startsWith('//')) continue;
              if (nextLine.contains(']')) {
                final beforeBracket = nextLine.substring(0, nextLine.indexOf(']')).trim();
                if (beforeBracket.isNotEmpty) {
                  for (var part in beforeBracket.split(',')) {
                    final cleaned = _cleanItem(part);
                    if (cleaned != null && cleaned.toString().trim().isNotEmpty) {
                      list.add(cleaned);
                    }
                  }
                }
                break;
              } else {
                for (var part in nextLine.split(',')) {
                  final cleaned = _cleanItem(part);
                  if (cleaned != null && cleaned.toString().trim().isNotEmpty) {
                    list.add(cleaned);
                  }
                }
              }
            }
            result[key] = list;
          }
          continue;
        }

        result[key] = _parseScalar(rawVal);
      }
    }
    return result;
  }

  static dynamic _cleanItem(String raw) {
    var val = raw.trim();
    if (val.startsWith('"') && val.endsWith('"') && val.length >= 2) {
      val = val.substring(1, val.length - 1);
    }
    return _parseScalar(val);
  }

  static dynamic _parseScalar(String rawVal) {
    if (rawVal.startsWith('"') && rawVal.endsWith('"') && rawVal.length >= 2) {
      return rawVal.substring(1, rawVal.length - 1);
    }
    if (rawVal == 'true') return true;
    if (rawVal == 'false') return false;
    if (int.tryParse(rawVal) != null) return int.parse(rawVal);
    if (double.tryParse(rawVal) != null) return double.parse(rawVal);
    return rawVal;
  }
}
