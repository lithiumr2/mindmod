import 'package:flutter/material.dart';
import 'common_form_helpers.dart';
import 'list_builders.dart';

const List<String> _crafterEffects = ["none", "smeltsmoke", "smoke", "smokeCloud", "steam", "purify", "fire", "spark", "bubbles", "magmasmoke"];

class GenericCrafterPropertiesWidget extends StatelessWidget {
  final Map<String, dynamic> properties;
  final List<String> availableItems;
  final List<String> availableLiquids;
  final ValueChanged<Map<String, dynamic>> onChanged;
  
  const GenericCrafterPropertiesWidget({super.key, required this.properties, required this.availableItems, required this.availableLiquids, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TypeCardContainer(
      title: "Producción: Fábrica (GenericCrafter)",
      icon: Icons.factory,
      accentColor: Colors.orange,
      child: Column(
        children: [
          MindustryFloatField(label: 'craftTime', value: properties['craftTime'], onChanged: (v) { properties['craftTime'] = v; onChanged(properties); }),
          MindustryDropdownField(label: 'craftEffect', value: properties['craftEffect']?.toString(), items: _crafterEffects, onChanged: (v) { properties['craftEffect'] = v; onChanged(properties); }),
          MindustryDropdownField(label: 'updateEffect', value: properties['updateEffect']?.toString(), items: _crafterEffects, onChanged: (v) { properties['updateEffect'] = v; onChanged(properties); }),
          ItemsListBuilder(
            title: 'outputItems',
            items: properties['outputItems'] is List ? properties['outputItems'] : [],
            availableItems: availableItems,
            onUpdate: (v) { properties['outputItems'] = v; onChanged(properties); },
          ),
          LiquidsListBuilder(
            title: 'outputLiquids',
            items: properties['outputLiquids'] is List ? properties['outputLiquids'] : [],
            availableLiquids: availableLiquids,
            onUpdate: (v) { properties['outputLiquids'] = v; onChanged(properties); },
          ),
          ConsumesSubmodule(
            consumes: properties['consumes'] is Map ? (properties['consumes'] as Map).cast<String, dynamic>() : {},
            availableItems: availableItems,
            availableLiquids: availableLiquids,
            onChanged: (v) { properties['consumes'] = v; onChanged(properties); }
          )
        ]
      )
    );
  }
}

class HeatCrafterPropertiesWidget extends StatelessWidget {
  final Map<String, dynamic> properties;
  final List<String> availableItems;
  final List<String> availableLiquids;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const HeatCrafterPropertiesWidget({super.key, required this.properties, required this.availableItems, required this.availableLiquids, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TypeCardContainer(
      title: "Producción de Calor (HeatCrafter/Producer)",
      icon: Icons.whatshot,
      accentColor: Colors.deepOrange,
      child: Column(
        children: [
          MindustryFloatField(label: 'craftTime', value: properties['craftTime'], onChanged: (v) { properties['craftTime'] = v; onChanged(properties); }),
          MindustryFloatField(label: 'heatRequirement', value: properties['heatRequirement'], onChanged: (v) { properties['heatRequirement'] = v; onChanged(properties); }),
          MindustryFloatField(label: 'maxEfficiency', value: properties['maxEfficiency'], onChanged: (v) { properties['maxEfficiency'] = v; onChanged(properties); }),
          MindustryFloatField(label: 'heatOutput', value: properties['heatOutput'], onChanged: (v) { properties['heatOutput'] = v; onChanged(properties); }),
          MindustryBoolField(label: 'overheatDestroys', value: properties['overheatDestroys'], onChanged: (v) { properties['overheatDestroys'] = v; onChanged(properties); }),
          ConsumesSubmodule(
            consumes: properties['consumes'] is Map ? (properties['consumes'] as Map).cast<String, dynamic>() : {},
            availableItems: availableItems,
            availableLiquids: availableLiquids,
            onChanged: (v) { properties['consumes'] = v; onChanged(properties); }
          )
        ]
      )
    );
  }
}

class SeparatorPropertiesWidget extends StatelessWidget {
  final Map<String, dynamic> properties;
  final List<String> availableItems;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const SeparatorPropertiesWidget({super.key, required this.properties, required this.availableItems, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TypeCardContainer(
      title: "Separador (Separator)",
      icon: Icons.call_split,
      accentColor: Colors.orangeAccent,
      child: Column(
        children: [
          MindustryFloatField(label: 'craftTime', value: properties['craftTime'], onChanged: (v) { properties['craftTime'] = v; onChanged(properties); }),
          ItemsListBuilder(
            title: 'results',
            items: properties['results'] is List ? properties['results'] : [],
            availableItems: availableItems,
            onUpdate: (v) { properties['results'] = v; onChanged(properties); },
          ),
        ]
      )
    );
  }
}

class IncineratorPropertiesWidget extends StatelessWidget {
  final Map<String, dynamic> properties;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const IncineratorPropertiesWidget({super.key, required this.properties, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TypeCardContainer(
      title: "Incinerador (Incinerator)",
      icon: Icons.delete_forever,
      accentColor: Colors.red,
      child: Column(
        children: [
          MindustryHexColorField(label: 'flameColor', value: properties['flameColor']?.toString() ?? "ffb855", onChanged: (v) { properties['flameColor'] = v; onChanged(properties); }),
          MindustryDropdownField(label: 'effect', value: properties['effect']?.toString(), items: _crafterEffects, onChanged: (v) { properties['effect'] = v; onChanged(properties); }),
        ]
      )
    );
  }
}
