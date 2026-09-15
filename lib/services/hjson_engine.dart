class HjsonEngine {
  /// Formatea un mapa de datos de Dart a sintaxis Hjson limpia y con tipado estricto
  static String stringify(Map<String, dynamic> data) {
    final buffer = StringBuffer();
    buffer.writeln('{');
    data.forEach((key, value) {
      if (value == null) return;
      final cleanK = _cleanKey(key);
      if (value is String && value.trim().isEmpty && cleanK != 'name' && cleanK != 'description') return;
      
      final formatted = _formatValue(cleanK, value, indentLevel: 1);
      buffer.writeln('  $cleanK: $formatted');
    });
    buffer.writeln('}');
    return buffer.toString();
  }

  static String _cleanKey(String raw) {
    var k = raw.trim();
    while (k.startsWith('"') && k.endsWith('"') && k.length >= 2) {
      k = k.substring(1, k.length - 1).trim();
    }
    return k;
  }

  /// Desinfecta cualquier acumulación de barras invertidas o comillas recursivas
  static String cleanEscapedString(String str) {
    var val = str.trim();
    if (val.endsWith(',')) {
      val = val.substring(0, val.length - 1).trim();
    }
    while (true) {
      final prev = val;
      if (val.startsWith('"') && val.endsWith('"') && val.length >= 2) {
        val = val.substring(1, val.length - 1);
      }
      val = val.replaceAll(r'\"', '"').replaceAll(r'\\', r'\');
      if (val.startsWith(r'\"') && val.endsWith(r'\"') && val.length >= 4) {
        val = val.substring(2, val.length - 2);
      }
      val = val.replaceAll(RegExp(r'\\+$'), '').replaceAll(RegExp(r'^\\+'), '');
      if (val == prev) break;
    }
    return val.trim();
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
        final subKey = _cleanKey(k.toString());
        mapBuffer.writeln('$indent  $subKey: ${_formatValue(subKey, v, indentLevel: indentLevel + 1)}');
      });
      mapBuffer.write('$indent}');
      return mapBuffer.toString();
    }
    final rawStr = value.toString().trim();
    final strVal = cleanEscapedString(rawStr);

    // Verificación de número estricto si no es un campo textual obligatorio
    if (key != 'name' && key != 'displayName' && key != 'description' && key != 'type' && key != 'category' && key != 'shootSound' && key != 'version' && key != 'minGameVersion' && key != 'author') {
      if (int.tryParse(strVal) != null) return int.parse(strVal).toString();
      if (double.tryParse(strVal) != null) return double.parse(strVal).toString();
      if (strVal.toLowerCase() == 'true') return 'true';
      if (strVal.toLowerCase() == 'false') return 'false';
    }
    // Comillas para strings con caracteres especiales o espacios
    if (strVal.contains(' ') || strVal.contains('{') || strVal.contains('}') || strVal.contains(':') || strVal.contains('[') || strVal.contains(']') || strVal.contains('#') || strVal.contains(',') || strVal.contains('"')) {
      final escaped = strVal.replaceAll(r'\', r'\\').replaceAll('"', r'\"');
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
        if (char == '"') {
          int backslashCount = 0;
          int p = c - 1;
          while (p >= 0 && line[p] == r'\') {
            backslashCount++;
            p--;
          }
          if (backslashCount % 2 == 0) {
            inQuote = !inQuote;
          }
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

  /// Parser con soporte de números, booleanos, listas, mapas anidados y estructuras
  static Map<String, dynamic> parse(String content) {
    var text = content.trim();
    if (text.startsWith('{') && text.endsWith('}') && text.length >= 2) {
      text = text.substring(1, text.length - 1).trim();
    }
    return _parseBlock(text);
  }

  static Map<String, dynamic> _parseBlock(String blockText) {
    final Map<String, dynamic> result = {};
    final lines = blockText.split('\n');
    int i = 0;
    while (i < lines.length) {
      final line = lines[i];
      final trimmed = line.trim();
      i++;
      if (trimmed.isEmpty || trimmed.startsWith('#') || trimmed.startsWith('//')) continue;
      if (trimmed == '{' || trimmed == '}') continue;

      final colonIndex = trimmed.indexOf(':');
      if (colonIndex != -1) {
        final key = _cleanKey(trimmed.substring(0, colonIndex));
        var rawVal = trimmed.substring(colonIndex + 1).trim();

        // Si empieza un bloque/objeto con {
        if (rawVal.startsWith('{')) {
          if (rawVal.endsWith('}') && rawVal.length >= 2) {
            result[key] = _parseBlock(rawVal.substring(1, rawVal.length - 1));
          } else {
            final objLines = <String>[];
            final firstPart = rawVal.substring(1).trim();
            if (firstPart.isNotEmpty && firstPart != '}') {
              objLines.add(firstPart);
            }
            int depth = 1;
            while (i < lines.length && depth > 0) {
              final nextLine = lines[i];
              i++;
              for (int c = 0; c < nextLine.length; c++) {
                final ch = nextLine[c];
                if (ch == '{') depth++;
                if (ch == '}') depth--;
              }
              if (depth == 0) {
                final closeIdx = nextLine.lastIndexOf('}');
                final beforeClose = nextLine.substring(0, closeIdx).trim();
                if (beforeClose.isNotEmpty) objLines.add(beforeClose);
                break;
              } else {
                objLines.add(nextLine);
              }
            }
            result[key] = _parseBlock(objLines.join('\n'));
          }
          continue;
        }

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
    return _parseScalar(raw);
  }

  static dynamic _parseScalar(String rawVal) {
    final cleaned = cleanEscapedString(rawVal);
    if (cleaned == 'true') return true;
    if (cleaned == 'false') return false;
    if (int.tryParse(cleaned) != null) return int.parse(cleaned);
    if (double.tryParse(cleaned) != null) return double.parse(cleaned);
    return cleaned;
  }
}
