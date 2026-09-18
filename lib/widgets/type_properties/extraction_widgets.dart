import 'package:flutter/material.dart';
import 'common_form_helpers.dart';

const List<String> _drillEffects = ["mineBig", "mine", "mineHuge", "none"];

class DrillPropertiesWidget extends StatelessWidget {
  final Map<String, dynamic> properties;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const DrillPropertiesWidget({super.key, required this.properties, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TypeCardContainer(
      title: "Taladro (Drill)",
      icon: Icons.architecture,
      accentColor: Colors.brown,
      child: Column(
        children: [
          MindustryIntField(label: 'tier', value: properties['tier'], onChanged: (v) { properties['tier'] = v; onChanged(properties); }),
          MindustryFloatField(label: 'drillTime', value: properties['drillTime'], onChanged: (v) { properties['drillTime'] = v; onChanged(properties); }),
          MindustryFloatField(label: 'warmupSpeed', value: properties['warmupSpeed'], onChanged: (v) { properties['warmupSpeed'] = v; onChanged(properties); }),
          MindustryFloatField(label: 'liquidBoostIntensity', value: properties['liquidBoostIntensity'], onChanged: (v) { properties['liquidBoostIntensity'] = v; onChanged(properties); }),
          MindustryBoolField(label: 'drawMineItem', value: properties['drawMineItem'], onChanged: (v) { properties['drawMineItem'] = v; onChanged(properties); }),
          MindustryDropdownField(label: 'drillEffect', value: properties['drillEffect']?.toString(), items: _drillEffects, onChanged: (v) { properties['drillEffect'] = v; onChanged(properties); }),
        ]
      )
    );
  }
}

class BeamDrillPropertiesWidget extends StatelessWidget {
  final Map<String, dynamic> properties;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const BeamDrillPropertiesWidget({super.key, required this.properties, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TypeCardContainer(
      title: "Taladro Láser (BeamDrill)",
      icon: Icons.my_location,
      accentColor: Colors.amber,
      child: Column(
        children: [
          MindustryIntField(label: 'range', value: properties['range'], onChanged: (v) { properties['range'] = v; onChanged(properties); }),
          MindustryIntField(label: 'tier', value: properties['tier'], onChanged: (v) { properties['tier'] = v; onChanged(properties); }),
          MindustryFloatField(label: 'drillTime', value: properties['drillTime'], onChanged: (v) { properties['drillTime'] = v; onChanged(properties); }),
          MindustryHexColorField(label: 'sparkColor', value: properties['sparkColor']?.toString(), onChanged: (v) { properties['sparkColor'] = v; onChanged(properties); }),
          MindustryBoolField(label: 'pulse', value: properties['pulse'], onChanged: (v) { properties['pulse'] = v; onChanged(properties); }),
        ]
      )
    );
  }
}

class PumpPropertiesWidget extends StatelessWidget {
  final Map<String, dynamic> properties;
  final List<String> availableLiquids;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const PumpPropertiesWidget({super.key, required this.properties, required this.availableLiquids, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TypeCardContainer(
      title: "Bomba de Líquidos (Pump)",
      icon: Icons.water_drop,
      accentColor: Colors.blueAccent,
      child: Column(
        children: [
          MindustryFloatField(label: 'pumpAmount', value: properties['pumpAmount'], onChanged: (v) { properties['pumpAmount'] = v; onChanged(properties); }),
          MindustryDropdownField(label: 'result (For SolidPump)', value: properties['result']?.toString(), items: availableLiquids, onChanged: (v) { properties['result'] = v; onChanged(properties); }),
        ]
      )
    );
  }
}

class FrackerPropertiesWidget extends StatelessWidget {
  final Map<String, dynamic> properties;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const FrackerPropertiesWidget({super.key, required this.properties, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TypeCardContainer(
      title: "Fracker",
      icon: Icons.vertical_align_bottom,
      accentColor: Colors.deepPurple,
      child: Column(
        children: [
          MindustryFloatField(label: 'pumpAmount', value: properties['pumpAmount'], onChanged: (v) { properties['pumpAmount'] = v; onChanged(properties); }),
          MindustryFloatField(label: 'itemUseTime', value: properties['itemUseTime'], onChanged: (v) { properties['itemUseTime'] = v; onChanged(properties); }),
        ]
      )
    );
  }
}
