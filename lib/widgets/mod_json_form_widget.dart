import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/project_provider.dart';
import '../services/hjson_engine.dart';

class ModJsonFormWidget extends ConsumerWidget {
  const ModJsonFormWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFile = ref.watch(projectProvider).activeFile;
    if (activeFile == null) {
      return const Center(
        child: Text('No hay archivo seleccionado', style: TextStyle(color: Colors.white)),
      );
    }

    final parsedData = HjsonEngine.parse(activeFile.content);

    return Container(
      color: const Color(0xFF18181C),
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          const Text(
            'Configuración del Mod (mod.json)',
            style: TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: parsedData['name']?.toString() ?? '',
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Nombre del Mod',
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
            ),
            onChanged: (val) {
              parsedData['name'] = val;
              ref.read(projectProvider.notifier).updateActiveFileContent(HjsonEngine.stringify(parsedData));
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: parsedData['version']?.toString() ?? '1.0',
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Versión',
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
            ),
            onChanged: (val) {
              parsedData['version'] = val;
              ref.read(projectProvider.notifier).updateActiveFileContent(HjsonEngine.stringify(parsedData));
            },
          ),
        ],
      ),
    );
  }
}
