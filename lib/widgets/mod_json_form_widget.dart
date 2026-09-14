import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/project_provider.dart';
import '../services/hjson_engine.dart';
import '../providers/locale_provider.dart';

class ModJsonFormWidget extends ConsumerWidget {
  const ModJsonFormWidget({super.key});

  void _updateFieldList(WidgetRef ref, Map<String, dynamic> data, String key, String value) {
    if (value.trim().isEmpty) {
      data.remove(key);
    } else {
      data[key] = value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    ref.read(projectProvider.notifier).updateActiveFileContent(HjsonEngine.stringify(data));
  }

  void _updateField(WidgetRef ref, Map<String, dynamic> data, String key, String value) {
    data[key] = value;
    ref.read(projectProvider.notifier).updateActiveFileContent(HjsonEngine.stringify(data));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final tr = ref.read(localeProvider.notifier).tr;
    final activeFile = ref.watch(projectProvider).activeFile;
    if (activeFile == null) return const SizedBox.shrink();

    final parsedData = HjsonEngine.parse(activeFile.content);

    return Container(
      color: const Color(0xFF18181C),
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Text(tr('mod_json_title'), style: const TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 20),
          
          _buildTextField(tr('internal_name'), tr('hint_internal_name'), parsedData['name']?.toString(), 
            (v) => _updateField(ref, parsedData, 'name', v)),
          
          _buildTextField(tr('display_name'), tr('hint_display_name'), parsedData['displayName']?.toString(), 
            (v) => _updateField(ref, parsedData, 'displayName', v)),
          
          _buildTextField(tr('author'), tr('hint_author'), parsedData['author']?.toString(), 
            (v) => _updateField(ref, parsedData, 'author', v)),
          
          _buildTextField(tr('description'), tr('hint_description'), parsedData['description']?.toString(), 
            (v) => _updateField(ref, parsedData, 'description', v), maxLines: 3),
            
          Row(
            children: [
              Expanded(
                child: _buildTextField(tr('version'), tr('hint_version'), parsedData['version']?.toString(), 
                  (v) => _updateField(ref, parsedData, 'version', v)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(tr('min_game_version'), tr('hint_min_game_version'), parsedData['minGameVersion']?.toString(), 
                  (v) => _updateField(ref, parsedData, 'minGameVersion', v)),
              ),
            ],
          ),
          _buildTextField(tr('dependencies'), tr('hint_dependencies'), 
            (parsedData['dependencies'] as List<dynamic>?)?.join(', ') ?? '', 
            (v) => _updateFieldList(ref, parsedData, 'dependencies', v)),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint, String? initial, Function(String) onChanged, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        initialValue: initial ?? '',
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          hintStyle: const TextStyle(color: Colors.white24),
          labelStyle: const TextStyle(color: Colors.white70, fontSize: 13),
          enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white12), borderRadius: BorderRadius.circular(6)),
          focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.amber), borderRadius: BorderRadius.circular(6)),
          filled: true,
          fillColor: const Color(0xFF1C1C24),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
