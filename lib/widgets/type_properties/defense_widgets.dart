import 'package:flutter/material.dart';
import 'common_form_helpers.dart';

class WallPropertiesWidget extends StatelessWidget {
  final Map<String, dynamic> properties;
  final ValueChanged<Map<String, dynamic>> onChanged;
  const WallPropertiesWidget({super.key, required this.properties, required this.onChanged});
  @override Widget build(BuildContext context) {
    return TypeCardContainer(
      title: "Muro (Wall)", icon: Icons.shield, accentColor: Colors.blueGrey,
      child: Column(children: [
        MindustryFloatField(label: 'chanceDeflect', value: properties['chanceDeflect'], onChanged: (v) { properties['chanceDeflect'] = v; onChanged(properties); }),
        MindustryFloatField(label: 'lightningChance', value: properties['lightningChance'], onChanged: (v) { properties['lightningChance'] = v; onChanged(properties); }),
        MindustryFloatField(label: 'lightningDamage', value: properties['lightningDamage'], onChanged: (v) { properties['lightningDamage'] = v; onChanged(properties); }),
        MindustryBoolField(label: 'insulated', value: properties['insulated'], onChanged: (v) { properties['insulated'] = v; onChanged(properties); }),
        MindustryBoolField(label: 'absorbLasers', value: properties['absorbLasers'], onChanged: (v) { properties['absorbLasers'] = v; onChanged(properties); }),
      ])
    );
  }
}

class ForceProjectorPropertiesWidget extends StatelessWidget {
  final Map<String, dynamic> properties;
  final ValueChanged<Map<String, dynamic>> onChanged;
  const ForceProjectorPropertiesWidget({super.key, required this.properties, required this.onChanged});
  @override Widget build(BuildContext context) {
    return TypeCardContainer(
      title: "Escudo (ForceProjector)", icon: Icons.security, accentColor: Colors.lightBlueAccent,
      child: Column(children: [
        MindustryFloatField(label: 'radius', value: properties['radius'], onChanged: (v) { properties['radius'] = v; onChanged(properties); }),
        MindustryFloatField(label: 'shieldHealth', value: properties['shieldHealth'], onChanged: (v) { properties['shieldHealth'] = v; onChanged(properties); }),
        MindustryFloatField(label: 'cooldownNormal', value: properties['cooldownNormal'], onChanged: (v) { properties['cooldownNormal'] = v; onChanged(properties); }),
        MindustryFloatField(label: 'cooldownLiquid', value: properties['cooldownLiquid'], onChanged: (v) { properties['cooldownLiquid'] = v; onChanged(properties); }),
        MindustryFloatField(label: 'phaseRadiusBoost', value: properties['phaseRadiusBoost'], onChanged: (v) { properties['phaseRadiusBoost'] = v; onChanged(properties); }),
        MindustryFloatField(label: 'phaseShieldBoost', value: properties['phaseShieldBoost'], onChanged: (v) { properties['phaseShieldBoost'] = v; onChanged(properties); }),
      ])
    );
  }
}

class OverdrivePropertiesWidget extends StatelessWidget {
  final Map<String, dynamic> properties;
  final ValueChanged<Map<String, dynamic>> onChanged;
  const OverdrivePropertiesWidget({super.key, required this.properties, required this.onChanged});
  @override Widget build(BuildContext context) {
    return TypeCardContainer(
      title: "Sobrecarga (Overdrive)", icon: Icons.speed, accentColor: Colors.orangeAccent,
      child: Column(children: [
        MindustryFloatField(label: 'range', value: properties['range'], onChanged: (v) { properties['range'] = v; onChanged(properties); }),
        MindustryFloatField(label: 'speedBoost', value: properties['speedBoost'], onChanged: (v) { properties['speedBoost'] = v; onChanged(properties); }),
        MindustryFloatField(label: 'speedBoostPhase', value: properties['speedBoostPhase'], onChanged: (v) { properties['speedBoostPhase'] = v; onChanged(properties); }),
        MindustryFloatField(label: 'useTime', value: properties['useTime'], onChanged: (v) { properties['useTime'] = v; onChanged(properties); }),
      ])
    );
  }
}

class MenderPropertiesWidget extends StatelessWidget {
  final Map<String, dynamic> properties;
  final ValueChanged<Map<String, dynamic>> onChanged;
  const MenderPropertiesWidget({super.key, required this.properties, required this.onChanged});
  @override Widget build(BuildContext context) {
    return TypeCardContainer(
      title: "Reparador (Mender)", icon: Icons.healing, accentColor: Colors.green,
      child: Column(children: [
        MindustryFloatField(label: 'range', value: properties['range'], onChanged: (v) { properties['range'] = v; onChanged(properties); }),
        MindustryFloatField(label: 'reload', value: properties['reload'], onChanged: (v) { properties['reload'] = v; onChanged(properties); }),
        MindustryFloatField(label: 'healPercent', value: properties['healPercent'], onChanged: (v) { properties['healPercent'] = v; onChanged(properties); }),
        MindustryFloatField(label: 'healAmount', value: properties['healAmount'], onChanged: (v) { properties['healAmount'] = v; onChanged(properties); }),
      ])
    );
  }
}
