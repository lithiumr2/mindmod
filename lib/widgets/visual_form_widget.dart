import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/project_provider.dart';
import '../services/hjson_engine.dart';

class VisualFormWidget extends ConsumerStatefulWidget {
  const VisualFormWidget({super.key});

  @override
  ConsumerState<VisualFormWidget> createState() => _VisualFormWidgetState();
}

class _VisualFormWidgetState extends ConsumerState<VisualFormWidget> {
  static const Map<String, List<String>> _propertyDictionary = {
    'Turret': ['range', 'reload', 'recoil', 'shootCone', 'inaccuracy', 'rotateSpeed', 'targetAir', 'targetGround'],
    'GenericCrafter': ['craftTime', 'outputItem', 'outputLiquid', 'itemCapacity', 'liquidCapacity'],
    'Drill': ['tier', 'drillTime', 'liquidBoostIntensity', 'hardnessDrill'],
    'Pump': ['pumpAmount', 'result'],
    'Wall': ['health', 'size', 'chanceDeflect', 'flashHit'],
  };

  @override
  Widget build(BuildContext context) {
    final activeFile = ref.watch(projectProvider).activeFile;
    if (activeFile == null) {
      return const Center(child: Text('Sin archivo seleccionado', style: TextStyle(color: Colors.white)));
    }

    final data = HjsonEngine.parse(activeFile.content);
    final currentType = data['type']?.toString() ?? 'Wall';
    final suggestedProps = (_propertyDictionary[currentType] ?? [])
        .where((prop) => !data.containsKey(prop))
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (suggestedProps.isNotEmpty) ...[
            const Text(
              'Propiedades recomendadas:',
              style: TextStyle(color: Color(0xFFFBC02D), fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: suggestedProps.map((prop) {
                return ActionChip(
                  backgroundColor: const Color(0xFF202026),
                  side: const BorderSide(color: Color(0xFF303038)),
                  label: Text('+ $prop', style: const TextStyle(color: Colors.white, fontSize: 12)),
                  onPressed: () {
                    data[prop] = '';
                    _saveData(data);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
          ...data.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 130,
                    child: Text('${entry.key}:', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child: TextField(
                      controller: TextEditingController(text: entry.value.toString())
                        ..selection = TextSelection.collapsed(offset: entry.value.toString().length),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: const Color(0xFF202026),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(color: Color(0xFF303038)),
                        ),
                      ),
                      onChanged: (newVal) {
                        dynamic val = newVal;
                        if (int.tryParse(newVal) != null) val = int.parse(newVal);
                        if (newVal == 'true') val = true;
                        if (newVal == 'false') val = false;
                        data[entry.key] = val;
                        _saveData(data);
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                    onPressed: () {
                      data.remove(entry.key);
                      _saveData(data);
                    },
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _saveData(Map<String, dynamic> data) {
    final newHjson = HjsonEngine.stringify(data);
    ref.read(projectProvider.notifier).updateActiveFileContent(newHjson);
  }
}
