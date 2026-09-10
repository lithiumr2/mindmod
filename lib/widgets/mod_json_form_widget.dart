import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/project_provider.dart';
import '../services/hjson_engine.dart';

class ModJsonFormWidget extends ConsumerWidget {
  const ModJsonFormWidget({super.key});

  void _updateField(WidgetRef ref, Map<String, dynamic> data, String key, String value) {
    data[key] = value;
    ref.read(projectProvider.notifier).updateActiveFileContent(HjsonEngine.stringify(data));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFile = ref.watch(projectProvider).activeFile;
    if (activeFile == null) return const SizedBox.shrink();

    final parsedData = HjsonEngine.parse(activeFile.content);

    return Container(
      color: const Color(0xFF18181C),
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          const Text(
            'Configuración General (mod.json)',
            style: TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          
          _buildTextField('Nombre Interno (name)', 'ej. mi-mod-epico', parsedData['name'], 
            (v) => _updateField(ref, parsedData, 'name', v)),
          
          _buildTextField('Nombre Público (displayName)', 'ej. Mi Mod Épico', parsedData['displayName'], 
            (v) => _updateField(ref, parsedData, 'displayName', v)),
          
          _buildTextField('Autor (author)', 'Tu nombre', parsedData['author'], 
            (v) => _updateField(ref, parsedData, 'author', v)),
          
          _buildTextField('Descripción (description)', '¿De qué trata el mod?', parsedData['description'], 
            (v) => _updateField(ref, parsedData, 'description', v), maxLines: 3),
            
          Row(
            children: [
              Expanded(
                child: _buildTextField('Versión', 'ej. 1.0', parsedData['version'], 
                  (v) => _updateField(ref, parsedData, 'version', v)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField('Versión Mín. Juego', 'ej. 146', parsedData['minGameVersion']?.toString(), 
                  (v) => _updateField(ref, parsedData, 'minGameVersion', v)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint, String? initial, Function(String) onChanged, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: initial ?? '',
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white24),
          labelStyle: const TextStyle(color: Colors.white70),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          filled: true,
          fillColor: const Color(0xFF222228),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
