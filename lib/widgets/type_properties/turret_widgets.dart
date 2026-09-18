import 'package:flutter/material.dart';
import 'common_form_helpers.dart';

const List<String> _shootSounds = ["shoot", "shootBig", "shootSnap", "lasershoot", "laser", "laserbig", "artillery"];

class ItemTurretPropertiesWidget extends StatelessWidget {
  final Map<String, dynamic> properties;
  final List<String> availableItems;
  final ValueChanged<Map<String, dynamic>> onChanged;
  const ItemTurretPropertiesWidget({super.key, required this.properties, required this.availableItems, required this.onChanged});
  @override Widget build(BuildContext context) {
    return TypeCardContainer(
      title: "Torreta de Ítems (ItemTurret)", icon: Icons.gps_fixed, accentColor: Colors.redAccent,
      child: Column(children: [
        MindustryFloatField(label: 'range', value: properties['range'], onChanged: (v) { properties['range'] = v; onChanged(properties); }),
        MindustryFloatField(label: 'reload', value: properties['reload'], onChanged: (v) { properties['reload'] = v; onChanged(properties); }),
        MindustryFloatField(label: 'inaccuracy', value: properties['inaccuracy'], onChanged: (v) { properties['inaccuracy'] = v; onChanged(properties); }),
        MindustryFloatField(label: 'recoil', value: properties['recoil'], onChanged: (v) { properties['recoil'] = v; onChanged(properties); }),
        MindustryBoolField(label: 'targetAir', value: properties['targetAir'] ?? true, onChanged: (v) { properties['targetAir'] = v; onChanged(properties); }),
        MindustryBoolField(label: 'targetGround', value: properties['targetGround'] ?? true, onChanged: (v) { properties['targetGround'] = v; onChanged(properties); }),
        MindustryDropdownField(label: 'shootSound', value: properties['shootSound']?.toString(), items: _shootSounds, onChanged: (v) { properties['shootSound'] = v; onChanged(properties); }),
        // Diccionario ammoTypes
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text('ammoTypes (raw JSON)', style: TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        MindustryStringField(label: 'ammoTypes', value: properties['ammoTypes']?.toString(), onChanged: (v) { properties['ammoTypes'] = v; onChanged(properties); }),
      ])
    );
  }
}

class LiquidTurretPropertiesWidget extends StatelessWidget {
  final Map<String, dynamic> properties;
  final List<String> availableLiquids;
  final ValueChanged<Map<String, dynamic>> onChanged;
  const LiquidTurretPropertiesWidget({super.key, required this.properties, required this.availableLiquids, required this.onChanged});
  @override Widget build(BuildContext context) {
    return TypeCardContainer(
      title: "Torreta de Líquidos (LiquidTurret)", icon: Icons.water_damage, accentColor: Colors.blueAccent,
      child: Column(children: [
        MindustryFloatField(label: 'range', value: properties['range'], onChanged: (v) { properties['range'] = v; onChanged(properties); }),
        MindustryFloatField(label: 'reload', value: properties['reload'], onChanged: (v) { properties['reload'] = v; onChanged(properties); }),
        MindustryFloatField(label: 'inaccuracy', value: properties['inaccuracy'], onChanged: (v) { properties['inaccuracy'] = v; onChanged(properties); }),
        MindustryFloatField(label: 'recoil', value: properties['recoil'], onChanged: (v) { properties['recoil'] = v; onChanged(properties); }),
        MindustryBoolField(label: 'targetAir', value: properties['targetAir'] ?? true, onChanged: (v) { properties['targetAir'] = v; onChanged(properties); }),
        MindustryBoolField(label: 'targetGround', value: properties['targetGround'] ?? true, onChanged: (v) { properties['targetGround'] = v; onChanged(properties); }),
        MindustryBoolField(label: 'extinguish', value: properties['extinguish'] ?? true, onChanged: (v) { properties['extinguish'] = v; onChanged(properties); }),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text('ammoTypes (raw JSON)', style: TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        MindustryStringField(label: 'ammoTypes', value: properties['ammoTypes']?.toString(), onChanged: (v) { properties['ammoTypes'] = v; onChanged(properties); }),
      ])
    );
  }
}

class EnergyTurretPropertiesWidget extends StatelessWidget {
  final Map<String, dynamic> properties;
  final ValueChanged<Map<String, dynamic>> onChanged;
  const EnergyTurretPropertiesWidget({super.key, required this.properties, required this.onChanged});
  @override Widget build(BuildContext context) {
    return TypeCardContainer(
      title: "Torreta de Energía/Láser", icon: Icons.flash_on, accentColor: Colors.yellowAccent,
      child: Column(children: [
        MindustryFloatField(label: 'range', value: properties['range'], onChanged: (v) { properties['range'] = v; onChanged(properties); }),
        MindustryFloatField(label: 'reload', value: properties['reload'], onChanged: (v) { properties['reload'] = v; onChanged(properties); }),
        MindustryFloatField(label: 'chargeTime', value: properties['chargeTime'], onChanged: (v) { properties['chargeTime'] = v; onChanged(properties); }),
        MindustryBoolField(label: 'targetAir', value: properties['targetAir'] ?? true, onChanged: (v) { properties['targetAir'] = v; onChanged(properties); }),
        MindustryBoolField(label: 'targetGround', value: properties['targetGround'] ?? true, onChanged: (v) { properties['targetGround'] = v; onChanged(properties); }),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text('shootType (raw JSON)', style: TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        MindustryStringField(label: 'shootType', value: properties['shootType']?.toString(), onChanged: (v) { properties['shootType'] = v; onChanged(properties); }),
      ])
    );
  }
}
