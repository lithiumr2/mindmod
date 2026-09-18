import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/project_file.dart';
import 'common_form_helpers.dart';

// Helper for simple String Lists (Status Effects affinities/opposites)
class StringListBuilder extends StatelessWidget {
  final String title;
  final List<dynamic> items;
  final List<String> availableOptions;
  final Function(List<dynamic>) onUpdate;

  const StringListBuilder({super.key, required this.title, required this.items, required this.availableOptions, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text('Add'),
                  onPressed: () {
                    final newList = List.from(items)..add(availableOptions.isNotEmpty ? availableOptions.first : 'none');
                    onUpdate(newList);
                  },
                )
              ],
            ),
            ...items.asMap().entries.map((entry) {
              final index = entry.key;
              final val = entry.value.toString();
              return Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButton<String>(
                        value: availableOptions.contains(val) ? val : null,
                        isExpanded: true,
                        items: availableOptions.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 12)))).toList(),
                        onChanged: (v) {
                          if (v != null) {
                            final newList = List.from(items);
                            newList[index] = v;
                            onUpdate(newList);
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red, size: 16),
                      onPressed: () {
                        final newList = List.from(items)..removeAt(index);
                        onUpdate(newList);
                      },
                    )
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class ItemPropertiesWidget extends StatelessWidget {
  final Map<String, dynamic> properties;
  final ValueChanged<Map<String, dynamic>> onChanged;
  
  const ItemPropertiesWidget({super.key, required this.properties, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TypeCardContainer(
      title: "Ítem (Item)",
      icon: Icons.diamond,
      accentColor: Colors.greenAccent,
      child: Column(
        children: [
          const Padding(padding: EdgeInsets.symmetric(vertical: 6), child: Text("Identificación y Visuales", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold))),
          MindustryStringField(label: 'name', value: properties['name']?.toString(), onChanged: (v) { properties['name'] = v; onChanged(properties); }),
          MindustryStringField(label: 'description', value: properties['description']?.toString(), onChanged: (v) { properties['description'] = v; onChanged(properties); }),
          MindustryHexColorField(label: 'color', value: properties['color']?.toString() ?? "ffffff", onChanged: (v) { properties['color'] = v; onChanged(properties); }),
          
          const Padding(padding: EdgeInsets.symmetric(vertical: 6), child: Text("Propiedades Físicas", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold))),
          MindustryIntField(label: 'hardness', value: properties['hardness'], onChanged: (v) { properties['hardness'] = v; onChanged(properties); }),
          MindustryFloatField(label: 'cost', value: properties['cost'], onChanged: (v) { properties['cost'] = v; onChanged(properties); }),
          
          const Padding(padding: EdgeInsets.symmetric(vertical: 6), child: Text("Propiedades Elementales", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold))),
          MindustryFloatField(label: 'radioactivity', value: properties['radioactivity'], onChanged: (v) { properties['radioactivity'] = v; onChanged(properties); }),
          MindustryFloatField(label: 'explosiveness', value: properties['explosiveness'], onChanged: (v) { properties['explosiveness'] = v; onChanged(properties); }),
          MindustryFloatField(label: 'flammability', value: properties['flammability'], onChanged: (v) { properties['flammability'] = v; onChanged(properties); }),
          MindustryFloatField(label: 'charge', value: properties['charge'], onChanged: (v) { properties['charge'] = v; onChanged(properties); }),
          
          const Padding(padding: EdgeInsets.symmetric(vertical: 6), child: Text("Banderas (Flags)", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold))),
          MindustryBoolField(label: 'alwaysUnlocked', value: properties['alwaysUnlocked'], onChanged: (v) { properties['alwaysUnlocked'] = v; onChanged(properties); }),
          MindustryBoolField(label: 'unlockable', value: properties['unlockable'], onChanged: (v) { properties['unlockable'] = v; onChanged(properties); }),
          MindustryBoolField(label: 'hidden', value: properties['hidden'], onChanged: (v) { properties['hidden'] = v; onChanged(properties); }),
          MindustryBoolField(label: 'buildable', value: properties['buildable'] ?? true, onChanged: (v) { properties['buildable'] = v; onChanged(properties); }),
        ]
      )
    );
  }
}

class LiquidPropertiesWidget extends StatelessWidget {
  final Map<String, dynamic> properties;
  final List<String> availableStatus;
  final ValueChanged<Map<String, dynamic>> onChanged;
  
  const LiquidPropertiesWidget({super.key, required this.properties, required this.availableStatus, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TypeCardContainer(
      title: "Líquido (Liquid)",
      icon: Icons.water_drop,
      accentColor: Colors.lightBlueAccent,
      child: Column(
        children: [
          const Padding(padding: EdgeInsets.symmetric(vertical: 6), child: Text("Identificación y Visuales", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold))),
          MindustryStringField(label: 'name', value: properties['name']?.toString(), onChanged: (v) { properties['name'] = v; onChanged(properties); }),
          MindustryStringField(label: 'description', value: properties['description']?.toString(), onChanged: (v) { properties['description'] = v; onChanged(properties); }),
          MindustryHexColorField(label: 'color', value: properties['color']?.toString(), onChanged: (v) { properties['color'] = v; onChanged(properties); }),
          MindustryHexColorField(label: 'lightColor', value: properties['lightColor']?.toString(), onChanged: (v) { properties['lightColor'] = v; onChanged(properties); }),
          
          const Padding(padding: EdgeInsets.symmetric(vertical: 6), child: Text("Termodinámica y Flujo", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold))),
          MindustryFloatField(label: 'temperature (0.5=amb)', value: properties['temperature'], onChanged: (v) { properties['temperature'] = v; onChanged(properties); }),
          MindustryFloatField(label: 'heatCapacity', value: properties['heatCapacity'], onChanged: (v) { properties['heatCapacity'] = v; onChanged(properties); }),
          MindustryFloatField(label: 'viscosity', value: properties['viscosity'], onChanged: (v) { properties['viscosity'] = v; onChanged(properties); }),
          MindustryFloatField(label: 'boilPoint', value: properties['boilPoint'], onChanged: (v) { properties['boilPoint'] = v; onChanged(properties); }),
          
          const Padding(padding: EdgeInsets.symmetric(vertical: 6), child: Text("Reacción y Peligro", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold))),
          MindustryFloatField(label: 'flammability', value: properties['flammability'], onChanged: (v) { properties['flammability'] = v; onChanged(properties); }),
          MindustryFloatField(label: 'explosiveness', value: properties['explosiveness'], onChanged: (v) { properties['explosiveness'] = v; onChanged(properties); }),
          MindustryFloatField(label: 'reactivity', value: properties['reactivity'], onChanged: (v) { properties['reactivity'] = v; onChanged(properties); }),
          MindustryBoolField(label: 'coolant', value: properties['coolant'] ?? true, onChanged: (v) { properties['coolant'] = v; onChanged(properties); }),
          MindustryBoolField(label: 'gas', value: properties['gas'], onChanged: (v) { properties['gas'] = v; onChanged(properties); }),
          MindustryBoolField(label: 'capPuddles', value: properties['capPuddles'] ?? true, onChanged: (v) { properties['capPuddles'] = v; onChanged(properties); }),
          
          const Padding(padding: EdgeInsets.symmetric(vertical: 6), child: Text("Efectos Secundarios", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold))),
          MindustryDropdownField(label: 'effect', value: properties['effect']?.toString(), items: availableStatus, onChanged: (v) { properties['effect'] = v; onChanged(properties); }),
          
          const Padding(padding: EdgeInsets.symmetric(vertical: 6), child: Text("Banderas (Flags)", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold))),
          MindustryBoolField(label: 'unlockable', value: properties['unlockable'], onChanged: (v) { properties['unlockable'] = v; onChanged(properties); }),
          MindustryBoolField(label: 'hidden', value: properties['hidden'], onChanged: (v) { properties['hidden'] = v; onChanged(properties); }),
        ]
      )
    );
  }
}

class StatusEffectPropertiesWidget extends StatelessWidget {
  final Map<String, dynamic> properties;
  final List<String> availableStatus;
  final ValueChanged<Map<String, dynamic>> onChanged;
  
  const StatusEffectPropertiesWidget({super.key, required this.properties, required this.availableStatus, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final effectOptions = ['none', 'burning', 'freezing', 'melting', 'wet', 'muddy', 'tarred', 'overdrive', 'boss', 'shocked', 'blasted']; // Default particles/effects

    return TypeCardContainer(
      title: "Efecto de Estado (StatusEffect)",
      icon: Icons.auto_awesome,
      accentColor: Colors.purpleAccent,
      child: Column(
        children: [
          const Padding(padding: EdgeInsets.symmetric(vertical: 6), child: Text("Identificación y Visuales", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold))),
          MindustryStringField(label: 'name', value: properties['name']?.toString(), onChanged: (v) { properties['name'] = v; onChanged(properties); }),
          MindustryStringField(label: 'description', value: properties['description']?.toString(), onChanged: (v) { properties['description'] = v; onChanged(properties); }),
          MindustryHexColorField(label: 'color', value: properties['color']?.toString(), onChanged: (v) { properties['color'] = v; onChanged(properties); }),
          MindustryDropdownField(label: 'effect (Visual Particle)', value: properties['effect']?.toString(), items: effectOptions, onChanged: (v) { properties['effect'] = v; onChanged(properties); }),
          
          const Padding(padding: EdgeInsets.symmetric(vertical: 6), child: Text("Modificadores de Estadísticas", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold))),
          MindustryFloatField(label: 'damage (per tick)', value: properties['damage'], onChanged: (v) { properties['damage'] = v; onChanged(properties); }),
          MindustryFloatField(label: 'damageMultiplier', value: properties['damageMultiplier'] ?? 1.0, onChanged: (v) { properties['damageMultiplier'] = v; onChanged(properties); }),
          MindustryFloatField(label: 'healthMultiplier', value: properties['healthMultiplier'] ?? 1.0, onChanged: (v) { properties['healthMultiplier'] = v; onChanged(properties); }),
          MindustryFloatField(label: 'speedMultiplier', value: properties['speedMultiplier'] ?? 1.0, onChanged: (v) { properties['speedMultiplier'] = v; onChanged(properties); }),
          MindustryFloatField(label: 'reloadMultiplier', value: properties['reloadMultiplier'] ?? 1.0, onChanged: (v) { properties['reloadMultiplier'] = v; onChanged(properties); }),
          MindustryFloatField(label: 'buildSpeedMultiplier', value: properties['buildSpeedMultiplier'] ?? 1.0, onChanged: (v) { properties['buildSpeedMultiplier'] = v; onChanged(properties); }),
          MindustryFloatField(label: 'dragMultiplier', value: properties['dragMultiplier'] ?? 1.0, onChanged: (v) { properties['dragMultiplier'] = v; onChanged(properties); }),
          
          const Padding(padding: EdgeInsets.symmetric(vertical: 6), child: Text("Estados Mecánicos", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold))),
          MindustryBoolField(label: 'disarm', value: properties['disarm'], onChanged: (v) { properties['disarm'] = v; onChanged(properties); }),
          MindustryBoolField(label: 'reactive', value: properties['reactive'], onChanged: (v) { properties['reactive'] = v; onChanged(properties); }),
          MindustryBoolField(label: 'permanent', value: properties['permanent'], onChanged: (v) { properties['permanent'] = v; onChanged(properties); }),
          
          const Padding(padding: EdgeInsets.symmetric(vertical: 6), child: Text("Relaciones y Transiciones", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold))),
          StringListBuilder(
            title: 'opposite (Anulan el estado)',
            items: properties['opposite'] is List ? properties['opposite'] : [],
            availableOptions: availableStatus,
            onUpdate: (v) { properties['opposite'] = v; onChanged(properties); },
          ),
          StringListBuilder(
            title: 'affinities (Reaccionan con el estado)',
            items: properties['affinities'] is List ? properties['affinities'] : [],
            availableOptions: availableStatus,
            onUpdate: (v) { properties['affinities'] = v; onChanged(properties); },
          ),
        ]
      )
    );
  }
}

class ResourcePropertiesDispatcher extends ConsumerWidget {
  final FileType fileType;
  final Map<String, dynamic> properties;
  final List<String> availableStatus;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const ResourcePropertiesDispatcher({
    super.key,
    required this.fileType,
    required this.properties,
    required this.availableStatus,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (fileType == FileType.item) {
      return ItemPropertiesWidget(properties: properties, onChanged: onChanged);
    } else if (fileType == FileType.liquid) {
      return LiquidPropertiesWidget(properties: properties, availableStatus: availableStatus, onChanged: onChanged);
    } else if (fileType == FileType.status) {
      return StatusEffectPropertiesWidget(properties: properties, availableStatus: availableStatus, onChanged: onChanged);
    }
    
    return const SizedBox.shrink();
  }
}
