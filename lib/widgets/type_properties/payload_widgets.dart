import 'package:flutter/material.dart';
import 'common_form_helpers.dart';
import 'list_builders.dart';

class UnitFactoryPropertiesWidget extends StatelessWidget {
  final Map<String, dynamic> properties;
  final List<String> availableItems;
  final List<String> availableUnits;
  final ValueChanged<Map<String, dynamic>> onChanged;
  const UnitFactoryPropertiesWidget({super.key, required this.properties, required this.availableItems, required this.availableUnits, required this.onChanged});
  @override Widget build(BuildContext context) {
    return TypeCardContainer(
      title: "Fábrica de Unidades", icon: Icons.precision_manufacturing, accentColor: Colors.deepPurpleAccent,
      child: Column(children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text('plans (raw JSON)', style: TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        MindustryStringField(label: 'plans', value: properties['plans']?.toString(), onChanged: (v) { properties['plans'] = v; onChanged(properties); }),
      ])
    );
  }
}

class ReconstructorPropertiesWidget extends StatelessWidget {
  final Map<String, dynamic> properties;
  final List<String> availableUnits;
  final ValueChanged<Map<String, dynamic>> onChanged;
  const ReconstructorPropertiesWidget({super.key, required this.properties, required this.availableUnits, required this.onChanged});
  @override Widget build(BuildContext context) {
    return TypeCardContainer(
      title: "Reconstructor", icon: Icons.upgrade, accentColor: Colors.purple,
      child: Column(children: [
        MindustryFloatField(label: 'constructTime', value: properties['constructTime'], onChanged: (v) { properties['constructTime'] = v; onChanged(properties); }),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text('upgrades (raw JSON)', style: TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        MindustryStringField(label: 'upgrades', value: properties['upgrades']?.toString(), onChanged: (v) { properties['upgrades'] = v; onChanged(properties); }),
      ])
    );
  }
}

class UnitAssemblerPropertiesWidget extends StatelessWidget {
  final Map<String, dynamic> properties;
  final List<String> availableItems;
  final List<String> availableUnits;
  final ValueChanged<Map<String, dynamic>> onChanged;
  const UnitAssemblerPropertiesWidget({super.key, required this.properties, required this.availableItems, required this.availableUnits, required this.onChanged});
  @override Widget build(BuildContext context) {
    return TypeCardContainer(
      title: "Ensamblador (UnitAssembler)", icon: Icons.group_work, accentColor: Colors.indigo,
      child: Column(children: [
        MindustryIntField(label: 'dronesCreated', value: properties['dronesCreated'], onChanged: (v) { properties['dronesCreated'] = v; onChanged(properties); }),
        MindustryDropdownField(label: 'droneType', value: properties['droneType']?.toString(), items: availableUnits, onChanged: (v) { properties['droneType'] = v; onChanged(properties); }),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text('plans (raw JSON)', style: TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        MindustryStringField(label: 'plans', value: properties['plans']?.toString(), onChanged: (v) { properties['plans'] = v; onChanged(properties); }),
      ])
    );
  }
}

class PayloadLogisticsPropertiesWidget extends StatelessWidget {
  final Map<String, dynamic> properties;
  final ValueChanged<Map<String, dynamic>> onChanged;
  const PayloadLogisticsPropertiesWidget({super.key, required this.properties, required this.onChanged});
  @override Widget build(BuildContext context) {
    return TypeCardContainer(
      title: "Logística Payload", icon: Icons.local_shipping, accentColor: Colors.blueGrey,
      child: Column(children: [
        MindustryFloatField(label: 'payloadLimit', value: properties['payloadLimit'], onChanged: (v) { properties['payloadLimit'] = v; onChanged(properties); }),
        MindustryFloatField(label: 'moveTime', value: properties['moveTime'], onChanged: (v) { properties['moveTime'] = v; onChanged(properties); }),
        MindustryFloatField(label: 'rotateSpeed', value: properties['rotateSpeed'], onChanged: (v) { properties['rotateSpeed'] = v; onChanged(properties); }),
      ])
    );
  }
}
