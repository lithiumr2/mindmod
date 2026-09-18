import 'package:flutter/material.dart';
import 'common_form_helpers.dart';

class ConveyorPropertiesWidget extends StatelessWidget {
  final Map<String, dynamic> properties;
  final ValueChanged<Map<String, dynamic>> onChanged;
  const ConveyorPropertiesWidget({super.key, required this.properties, required this.onChanged});
  @override Widget build(BuildContext context) {
    return TypeCardContainer(
      title: "Cinta Transportadora / Conducto", icon: Icons.linear_scale, accentColor: Colors.grey,
      child: Column(children: [
        MindustryFloatField(label: 'speed', value: properties['speed'], onChanged: (v) { properties['speed'] = v; onChanged(properties); }),
        MindustryFloatField(label: 'displayedSpeed', value: properties['displayedSpeed'], onChanged: (v) { properties['displayedSpeed'] = v; onChanged(properties); }),
      ])
    );
  }
}

class RouterPropertiesWidget extends StatelessWidget {
  final Map<String, dynamic> properties;
  final ValueChanged<Map<String, dynamic>> onChanged;
  const RouterPropertiesWidget({super.key, required this.properties, required this.onChanged});
  @override Widget build(BuildContext context) {
    return TypeCardContainer(
      title: "Enrutador / Distribuidor", icon: Icons.alt_route, accentColor: Colors.blueGrey,
      child: Column(children: [
        MindustryFloatField(label: 'speed', value: properties['speed'], onChanged: (v) { properties['speed'] = v; onChanged(properties); }),
        MindustryBoolField(label: 'invert (Sorters)', value: properties['invert'], onChanged: (v) { properties['invert'] = v; onChanged(properties); }),
      ])
    );
  }
}

class ItemBridgePropertiesWidget extends StatelessWidget {
  final Map<String, dynamic> properties;
  final ValueChanged<Map<String, dynamic>> onChanged;
  const ItemBridgePropertiesWidget({super.key, required this.properties, required this.onChanged});
  @override Widget build(BuildContext context) {
    return TypeCardContainer(
      title: "Puente de Ítems", icon: Icons.alt_route, accentColor: Colors.deepOrange,
      child: Column(children: [
        MindustryIntField(label: 'range', value: properties['range'], onChanged: (v) { properties['range'] = v; onChanged(properties); }),
        MindustryFloatField(label: 'transportTime', value: properties['transportTime'], onChanged: (v) { properties['transportTime'] = v; onChanged(properties); }),
        MindustryBoolField(label: 'pulse', value: properties['pulse'], onChanged: (v) { properties['pulse'] = v; onChanged(properties); }),
      ])
    );
  }
}

class MassDriverPropertiesWidget extends StatelessWidget {
  final Map<String, dynamic> properties;
  final ValueChanged<Map<String, dynamic>> onChanged;
  const MassDriverPropertiesWidget({super.key, required this.properties, required this.onChanged});
  @override Widget build(BuildContext context) {
    return TypeCardContainer(
      title: "Catapulta de Ítems (MassDriver)", icon: Icons.adjust, accentColor: Colors.yellow,
      child: Column(children: [
        MindustryFloatField(label: 'range', value: properties['range'], onChanged: (v) { properties['range'] = v; onChanged(properties); }),
        MindustryFloatField(label: 'reload', value: properties['reload'], onChanged: (v) { properties['reload'] = v; onChanged(properties); }),
        MindustryIntField(label: 'itemCapacity', value: properties['itemCapacity'], onChanged: (v) { properties['itemCapacity'] = v; onChanged(properties); }),
        MindustryFloatField(label: 'bulletSpeed', value: properties['bulletSpeed'], onChanged: (v) { properties['bulletSpeed'] = v; onChanged(properties); }),
        MindustryFloatField(label: 'knockback', value: properties['knockback'], onChanged: (v) { properties['knockback'] = v; onChanged(properties); }),
      ])
    );
  }
}

class UnloaderPropertiesWidget extends StatelessWidget {
  final Map<String, dynamic> properties;
  final ValueChanged<Map<String, dynamic>> onChanged;
  const UnloaderPropertiesWidget({super.key, required this.properties, required this.onChanged});
  @override Widget build(BuildContext context) {
    return TypeCardContainer(
      title: "Descargador (Unloader)", icon: Icons.outbox, accentColor: Colors.brown,
      child: Column(children: [
        MindustryFloatField(label: 'speed', value: properties['speed'], onChanged: (v) { properties['speed'] = v; onChanged(properties); }),
        MindustryBoolField(label: 'allowCoreUnload', value: properties['allowCoreUnload'], onChanged: (v) { properties['allowCoreUnload'] = v; onChanged(properties); }),
      ])
    );
  }
}

class ConduitPropertiesWidget extends StatelessWidget {
  final Map<String, dynamic> properties;
  final ValueChanged<Map<String, dynamic>> onChanged;
  const ConduitPropertiesWidget({super.key, required this.properties, required this.onChanged});
  @override Widget build(BuildContext context) {
    return TypeCardContainer(
      title: "Tubería / Conducto de Líquidos", icon: Icons.water, accentColor: Colors.blue,
      child: Column(children: [
        MindustryFloatField(label: 'liquidCapacity', value: properties['liquidCapacity'], onChanged: (v) { properties['liquidCapacity'] = v; onChanged(properties); }),
        MindustryFloatField(label: 'liquidPressure', value: properties['liquidPressure'], onChanged: (v) { properties['liquidPressure'] = v; onChanged(properties); }),
        MindustryBoolField(label: 'leaks', value: properties['leaks'], onChanged: (v) { properties['leaks'] = v; onChanged(properties); }),
      ])
    );
  }
}

class LiquidRouterPropertiesWidget extends StatelessWidget {
  final Map<String, dynamic> properties;
  final ValueChanged<Map<String, dynamic>> onChanged;
  const LiquidRouterPropertiesWidget({super.key, required this.properties, required this.onChanged});
  @override Widget build(BuildContext context) {
    return TypeCardContainer(
      title: "Logística de Líquidos (Router/Tank)", icon: Icons.waves, accentColor: Colors.lightBlue,
      child: Column(children: [
        MindustryIntField(label: 'range (Bridges)', value: properties['range'], onChanged: (v) { properties['range'] = v; onChanged(properties); }),
        MindustryFloatField(label: 'liquidCapacity', value: properties['liquidCapacity'], onChanged: (v) { properties['liquidCapacity'] = v; onChanged(properties); }),
      ])
    );
  }
}
