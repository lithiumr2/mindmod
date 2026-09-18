import 'package:flutter/material.dart';
import 'common_form_helpers.dart';

class LogicBlockPropertiesWidget extends StatelessWidget {
  final Map<String, dynamic> properties;
  final ValueChanged<Map<String, dynamic>> onChanged;
  const LogicBlockPropertiesWidget({super.key, required this.properties, required this.onChanged});
  @override Widget build(BuildContext context) {
    return TypeCardContainer(
      title: "Bloque Lógico", icon: Icons.memory, accentColor: Colors.cyan,
      child: Column(children: [
        MindustryIntField(label: 'maxInstructionsPerTick', value: properties['maxInstructionsPerTick'], onChanged: (v) { properties['maxInstructionsPerTick'] = v; onChanged(properties); }),
        MindustryFloatField(label: 'range', value: properties['range'], onChanged: (v) { properties['range'] = v; onChanged(properties); }),
        MindustryIntField(label: 'memoryCapacity', value: properties['memoryCapacity'], onChanged: (v) { properties['memoryCapacity'] = v; onChanged(properties); }),
        MindustryIntField(label: 'displaySize', value: properties['displaySize'], onChanged: (v) { properties['displaySize'] = v; onChanged(properties); }),
      ])
    );
  }
}

class CorePropertiesWidget extends StatelessWidget {
  final Map<String, dynamic> properties;
  final List<String> availableUnits;
  final ValueChanged<Map<String, dynamic>> onChanged;
  const CorePropertiesWidget({super.key, required this.properties, required this.availableUnits, required this.onChanged});
  @override Widget build(BuildContext context) {
    return TypeCardContainer(
      title: "Núcleo / Almacenamiento", icon: Icons.home, accentColor: Colors.amber,
      child: Column(children: [
        MindustryIntField(label: 'itemCapacity', value: properties['itemCapacity'], onChanged: (v) { properties['itemCapacity'] = v; onChanged(properties); }),
        MindustryDropdownField(label: 'unitType', value: properties['unitType']?.toString(), items: availableUnits, onChanged: (v) { properties['unitType'] = v; onChanged(properties); }),
        MindustryIntField(label: 'unitCapModifier', value: properties['unitCapModifier'], onChanged: (v) { properties['unitCapModifier'] = v; onChanged(properties); }),
        MindustryBoolField(label: 'coreMerge', value: properties['coreMerge'] ?? true, onChanged: (v) { properties['coreMerge'] = v; onChanged(properties); }),
      ])
    );
  }
}
