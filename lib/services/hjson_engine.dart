class HjsonEngine {
  /// Formatea un mapa de datos de Dart a sintaxis Hjson legible por Mindustry
  static String stringify(Map<String, dynamic> data) {
    final buffer = StringBuffer();
    buffer.writeln('{');

    data.forEach((key, value) {
      if (value == null || (value is String && value.isEmpty)) return;
      
      final formattedValue = _formatValue(value, indentLevel: 1);
      buffer.writeln('  $key: $formattedValue');
    });

    buffer.writeln('}');
    return buffer.toString();
  }

  static String _formatValue(dynamic value, {int indentLevel = 1}) {
    final indent = '  ' * indentLevel;

    if (value is String) {
      // Si contiene espacios o caracteres especiales, usa comillas dobles
      if (value.contains(' ') || value.contains('{') || value.contains('}')) {
        return '"$value"';
      }
      return value;
    } else if (value is List) {
      if (value.isEmpty) return '[]';
      final listBuffer = StringBuffer();
      listBuffer.writeln('[');
      for (var item in value) {
        listBuffer.writeln('$indent  ${_formatValue(item, indentLevel: indentLevel + 1)}');
      }
      listBuffer.write('$indent]');
      return listBuffer.toString();
    } else if (value is Map) {
      final mapBuffer = StringBuffer();
      mapBuffer.writeln('{');
      value.forEach((k, v) {
        mapBuffer.writeln('$indent  $k: ${_formatValue(v, indentLevel: indentLevel + 1)}');
      });
      mapBuffer.write('$indent}');
      return mapBuffer.toString();
    }

    return value.toString();
  }

  /// Parser simplificado de líneas Hjson a Mapa de Dart
  static Map<String, dynamic> parse(String content) {
    final Map<String, dynamic> result = {};
    final lines = content.split('\n');

    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#') || trimmed.startsWith('//')) continue;
      if (trimmed == '{' || trimmed == '}') continue;

      final colonIndex = trimmed.indexOf(':');
      if (colonIndex != -1) {
        final key = trimmed.substring(0, colonIndex).trim();
        var rawVal = trimmed.substring(colonIndex + 1).trim();

        // Limpieza de comillas
        if (rawVal.startsWith('"') && rawVal.endsWith('"') && rawVal.length >= 2) {
          rawVal = rawVal.substring(1, rawVal.length - 1);
        }

        // Conversión implícita de tipos
        if (rawVal == 'true') {
          result[key] = true;
        } else if (rawVal == 'false') {
          result[key] = false;
        } else if (int.tryParse(rawVal) != null) {
          result[key] = int.parse(rawVal);
        } else if (double.tryParse(rawVal) != null) {
          result[key] = double.parse(rawVal);
        } else {
          result[key] = rawVal;
        }
      }
    }

    return result;
  }
}
