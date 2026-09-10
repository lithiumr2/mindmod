import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/project_provider.dart';

class VisualFormWidget extends ConsumerStatefulWidget {
  const VisualFormWidget({super.key});

  @override
  ConsumerState<VisualFormWidget> createState() => _VisualFormWidgetState();
}

class _VisualFormWidgetState extends ConsumerState<VisualFormWidget> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  // Parsear texto HJSON simple a Mapa clave-valor
  Map<String, String> _parseHjson(String content) {
    final Map<String, String> map = {};
    final lines = content.split('\n');
    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('{') || trimmed.startsWith('}') || trimmed.isEmpty) continue;
      final parts = trimmed.split(':');
      if (parts.length >= 2) {
        final key = parts[0].trim();
        final value = parts.sublist(1).join(':').trim().replaceAll('"', '');
        map[key] = value;
      }
    }
    return map;
  }

  // Reconstruir HJSON desde el mapa actual
  String _toHjson(Map<String, String> map) {
    final buffer = StringBuffer('{\n');
    map.forEach((key, value) {
      buffer.writeln('  $key: "$value"');
    });
    buffer.write('}');
    return buffer.toString();
  }

  void _updateProperty(Map<String, String> map, String key, String newValue) {
    map[key] = newValue; // Mantiene la clave con cadena vacía si se borra el texto
    ref.read(projectProvider.notifier).updateActiveFileContent(_toHjson(map));
  }

  void _removeProperty(Map<String, String> map, String key) {
    map.remove(key);
    _controllers[key]?.dispose();
    _controllers.remove(key);
    ref.read(projectProvider.notifier).updateActiveFileContent(_toHjson(map));
  }

  void _addProperty(Map<String, String> map, String key) {
    if (!map.containsKey(key)) {
      map[key] = '';
      ref.read(projectProvider.notifier).updateActiveFileContent(_toHjson(map));
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectState = ref.watch(projectProvider);
    final activeFile = projectState.activeFile;

    if (activeFile == null) {
      return const Center(child: Text('No file selected', style: TextStyle(color: Colors.white54)));
    }

    final properties = _parseHjson(activeFile.content);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sugerencias rápidas
          const Text(
            'Recommended Properties:',
            style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['health', 'size', 'chanceDeflect', 'flashHit'].map((prop) {
              final isAdded = properties.containsKey(prop);
              return ActionChip(
                backgroundColor: isAdded ? Colors.amber.withOpacity(0.2) : const Color(0xFF202026),
                label: Text(
                  '+ $prop',
                  style: TextStyle(
                    color: isAdded ? Colors.amber : Colors.white70,
                    fontSize: 12,
                  ),
                ),
                onPressed: isAdded ? null : () => _addProperty(properties, prop),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Lista de Propiedades Clave-Valor
          ...properties.entries.map((entry) {
            final key = entry.key;
            final value = entry.value;

            // Mantener sincronizado el TextEditingController para no perder foco
            if (!_controllers.containsKey(key)) {
              _controllers[key] = TextEditingController(text: value);
            } else if (_controllers[key]!.text != value && value.isNotEmpty) {
              _controllers[key]!.text = value;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  // Nombre de la Propiedad
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF202026),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        key,
                        style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Valor de la Propiedad (Texto)
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _controllers[key],
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF202026),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      onChanged: (val) => _updateProperty(properties, key, val),
                    ),
                  ),
                  // Botón explícito para Eliminar
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                    onPressed: () => _removeProperty(properties, key),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
