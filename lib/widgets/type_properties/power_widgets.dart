import 'package:flutter/material.dart';
import 'common_form_helpers.dart';

class PowerNodePropertiesWidget extends StatelessWidget {
  final Map<String, dynamic> properties;
  final ValueChanged<Map<String, dynamic>> onChanged;
  const PowerNodePropertiesWidget({super.key, required this.properties, required this.onChanged});
  @override Widget build(BuildContext context) {
    return TypeCardContainer(
      title: "Nodo de Energía (PowerNode/BeamNode)", icon: Icons.hub, accentColor: Colors.yellow,
      child: Column(children: [
        MindustryIntField(label: 'maxNodes', value: properties['maxNodes'], onChanged: (v) { properties['maxNodes'] = v; onChanged(properties); }),
        MindustryFloatField(label: 'laserRange', value: properties['laserRange'], onChanged: (v) { properties['laserRange'] = v; onChanged(properties); }),
        MindustryHexColorField(label: 'laserColor1', value: properties['laserColor1']?.toString(), onChanged: (v) { properties['laserColor1'] = v; onChanged(properties); }),
        MindustryHexColorField(label: 'laserColor2', value: properties['laserColor2']?.toString(), onChanged: (v) { properties['laserColor2'] = v; onChanged(properties); }),
      ])
    );
  }
}

class BatteryPropertiesWidget extends StatelessWidget {
  final Map<String, dynamic> properties;
  final ValueChanged<Map<String, dynamic>> onChanged;
  const BatteryPropertiesWidget({super.key, required this.properties, required this.onChanged});
  @override Widget build(BuildContext context) {
    return TypeCardContainer(
      title: "Batería (Battery)", icon: Icons.battery_charging_full, accentColor: Colors.greenAccent,
      child: Column(children: [
        MindustryHexColorField(label: 'emptyLightColor', value: properties['emptyLightColor']?.toString(), onChanged: (v) { properties['emptyLightColor'] = v; onChanged(properties); }),
        MindustryHexColorField(label: 'fullLightColor', value: properties['fullLightColor']?.toString(), onChanged: (v) { properties['fullLightColor'] = v; onChanged(properties); }),
      ])
    );
  }
}

class ConsumeGeneratorPropertiesWidget extends StatelessWidget {
  final Map<String, dynamic> properties;
  final List<String> availableItems;
  final List<String> availableLiquids;
  final ValueChanged<Map<String, dynamic>> onChanged;
  const ConsumeGeneratorPropertiesWidget({super.key, required this.properties, required this.availableItems, required this.availableLiquids, required this.onChanged});
  @override Widget build(BuildContext context) {
    return TypeCardContainer(
      title: "Generador (Consume/Thermal/Solar)", icon: Icons.bolt, accentColor: Colors.orange,
      child: Column(children: [
        MindustryFloatField(label: 'powerProduction', value: properties['powerProduction'], onChanged: (v) { properties['powerProduction'] = v; onChanged(properties); }),
        MindustryFloatField(label: 'itemDuration', value: properties['itemDuration'], onChanged: (v) { properties['itemDuration'] = v; onChanged(properties); }),
        MindustryDropdownField(label: 'generateEffect', value: properties['generateEffect']?.toString(), items: const ['none', 'smeltsmoke', 'steam', 'fire'], onChanged: (v) { properties['generateEffect'] = v; onChanged(properties); }),
        ConsumesSubmodule(
          consumes: properties['consumes'] is Map ? (properties['consumes'] as Map).cast<String, dynamic>() : {},
          availableItems: availableItems,
          availableLiquids: availableLiquids,
          onChanged: (v) { properties['consumes'] = v; onChanged(properties); }
        )
      ])
    );
  }
}

class NuclearReactorPropertiesWidget extends StatelessWidget {
  final Map<String, dynamic> properties;
  final ValueChanged<Map<String, dynamic>> onChanged;
  const NuclearReactorPropertiesWidget({super.key, required this.properties, required this.onChanged});
  @override Widget build(BuildContext context) {
    return TypeCardContainer(
      title: "Reactor Nuclear/Impacto", icon: Icons.warning, accentColor: Colors.red,
      child: Column(children: [
        MindustryFloatField(label: 'powerProduction', value: properties['powerProduction'], onChanged: (v) { properties['powerProduction'] = v; onChanged(properties); }),
        MindustryFloatField(label: 'heating', value: properties['heating'], onChanged: (v) { properties['heating'] = v; onChanged(properties); }),
        MindustryFloatField(label: 'smokeThreshold', value: properties['smokeThreshold'], onChanged: (v) { properties['smokeThreshold'] = v; onChanged(properties); }),
        MindustryFloatField(label: 'flashThreshold', value: properties['flashThreshold'], onChanged: (v) { properties['flashThreshold'] = v; onChanged(properties); }),
        MindustryIntField(label: 'explosionRadius', value: properties['explosionRadius'], onChanged: (v) { properties['explosionRadius'] = v; onChanged(properties); }),
        MindustryFloatField(label: 'explosionDamage', value: properties['explosionDamage'], onChanged: (v) { properties['explosionDamage'] = v; onChanged(properties); }),
        MindustryFloatField(label: 'warmupSpeed', value: properties['warmupSpeed'], onChanged: (v) { properties['warmupSpeed'] = v; onChanged(properties); }),
      ])
    );
  }
}
