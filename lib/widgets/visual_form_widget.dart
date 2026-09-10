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
      return const Center(child: Text('No file selected', style: TextStyle(color: Colors.white54)));
    }

    if (activeFile.isImage) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.image, size: 64, color: Colors.purpleAccent),
            const SizedBox(height: 12),
            Text(
              activeFile.name,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sprite graphic file (Binary format)',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ],
        ),
      );
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
              'Recommended Properties:',
              style: TextStyle(color: Color(0xFFFBC02D), fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: suggestedProps.map((prop) {
                return ActionChip(
                  backgroundColor: const Color(0xFF202026),
                  side: const BorderSide(color: Color(0xFF303038)),
                  label: Text('+ $prop', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  onPressed: () {
                    data[prop] = '';
                    _saveData(data);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Divider(color: Color(0xFF303038)),
            const SizedBox(height: 8),
          ],
          ...data.entries.map((entry) {
            return _PropertyRow(
              propertyKey: entry.key,
              initialValue: entry.value.toString(),
              onChanged: (newVal) {
                dynamic val = newVal;
                if (int.tryParse(newVal) != null) val = int.parse(newVal);
                if (newVal == 'true') val = true;
                if (newVal == 'false') val = false;
                data[entry.key] = val;
                _saveData(data);
              },
              onDeleted: () {
                data.remove(entry.key);
                _saveData(data);
              },
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

class _PropertyRow extends StatefulWidget {
  final String propertyKey;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final VoidCallback onDeleted;

  const _PropertyRow({
    required this.propertyKey,
    required this.initialValue,
    required this.onChanged,
    required this.onDeleted,
  });

  @override
  State<_PropertyRow> createState() => _PropertyRowState();
}

class _PropertyRowState extends State<_PropertyRow> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant _PropertyRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue && _controller.text != widget.initialValue) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF141418),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF303038)),
              ),
              child: Text(
                widget.propertyKey,
                style: const TextStyle(color: Color(0xFFFBC02D), fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: const Color(0xFF202026),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF303038)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF303038)),
                ),
              ),
              onChanged: widget.onChanged,
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
            onPressed: widget.onDeleted,
          ),
        ],
      ),
    );
  }
}
