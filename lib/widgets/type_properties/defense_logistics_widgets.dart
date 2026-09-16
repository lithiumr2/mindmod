import 'package:flutter/material.dart';
import 'common_form_helpers.dart';

/// Widget para muros y defensas pasivas (Wall, ShieldWall, Door)
class WallPropertiesWidget extends StatelessWidget {
  final Map<String, dynamic> properties;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const WallPropertiesWidget({
    super.key,
    required this.properties,
    required this.onChanged,
  });

  void _update(String key, dynamic value) {
    final copy = Map<String, dynamic>.from(properties);
    if (value == null) {
      copy.remove(key);
    } else {
      copy[key] = value;
    }
    onChanged(copy);
  }

  @override
  Widget build(BuildContext context) {
    final chanceDeflect = double.tryParse(properties['chanceDeflect']?.toString() ?? '') ?? 0.0;
    final lightningChance = double.tryParse(properties['lightningChance']?.toString() ?? '') ?? 0.0;
    final lightningDamage = double.tryParse(properties['lightningDamage']?.toString() ?? '') ?? 0.0;
    final insulated = properties['insulated'] == true;
    final absorbLasers = properties['absorbLasers'] == true;

    return TypeCardContainer(
      title: "Defensa: Muro Defensivo (Wall)",
      subtitle: "Blindaje contra balas, aislamiento eléctrico y refracción láser",
      icon: Icons.shield,
      accentColor: Colors.blueGrey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: MindustryFloatField(
                  label: "Probabilidad Desviar Balas (chanceDeflect)",
                  value: chanceDeflect,
                  hint: "0.0 a 1.0 (ej: 0.2 = 20%)",
                  onChanged: (v) => _update('chanceDeflect', v),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: MindustryFloatField(
                  label: "Prob. Relámpago Retorno (lightningChance)",
                  value: lightningChance,
                  hint: "ej: 0.1 (10%)",
                  onChanged: (v) => _update('lightningChance', v),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MindustryFloatField(
                  label: "Daño del Relámpago (lightningDamage)",
                  value: lightningDamage,
                  hint: "ej: 25.0",
                  onChanged: (v) => _update('lightningDamage', v),
                ),
              ),
            ],
          ),
          MindustryBoolField(
            label: "Aislado Eléctrico (insulated)",
            subtitle: "Evita la conducción accidental de energía de nodos cercanos",
            value: insulated,
            onChanged: (v) => _update('insulated', v),
          ),
          MindustryBoolField(
            label: "Absorber Láseres (absorbLasers)",
            subtitle: "Detiene rayos continuos y láseres perforantes",
            value: absorbLasers,
            onChanged: (v) => _update('absorbLasers', v),
          ),
        ],
      ),
    );
  }
}

/// Widget para proyectores de escudos de fuerza (ForceProjector, MendProjector, Overdrive)
class ForceProjectorPropertiesWidget extends StatelessWidget {
  final Map<String, dynamic> properties;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const ForceProjectorPropertiesWidget({
    super.key,
    required this.properties,
    required this.onChanged,
  });

  void _update(String key, dynamic value) {
    final copy = Map<String, dynamic>.from(properties);
    if (value == null) {
      copy.remove(key);
    } else {
      copy[key] = value;
    }
    onChanged(copy);
  }

  @override
  Widget build(BuildContext context) {
    final radius = double.tryParse(properties['radius']?.toString() ?? '') ?? 80.0;
    final shieldHealth = double.tryParse(properties['shieldHealth']?.toString() ?? '') ?? 750.0;
    final cooldownNormal = double.tryParse(properties['cooldownNormal']?.toString() ?? '') ?? 1.5;
    final cooldownLiquid = double.tryParse(properties['cooldownLiquid']?.toString() ?? '') ?? 1.0;
    final phaseRadiusBoost = double.tryParse(properties['phaseRadiusBoost']?.toString() ?? '') ?? 40.0;
    final phaseShieldBoost = double.tryParse(properties['phaseShieldBoost']?.toString() ?? '') ?? 250.0;

    return TypeCardContainer(
      title: "Defensa: Campo de Fuerza (ForceProjector)",
      subtitle: "Escudos de energía semiesféricos con regeneración y potencia de fase",
      icon: Icons.security,
      accentColor: Colors.tealAccent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: MindustryFloatField(
                  label: "Radio del Escudo (radius)",
                  value: radius,
                  hint: "ej: 100.0 px",
                  onChanged: (v) => _update('radius', v),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MindustryFloatField(
                  label: "Salud del Domo (shieldHealth)",
                  value: shieldHealth,
                  hint: "ej: 800.0 HP",
                  onChanged: (v) => _update('shieldHealth', v),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: MindustryFloatField(
                  label: "Tasa de Enfriamiento Normal (cooldownNormal)",
                  value: cooldownNormal,
                  hint: "ej: 1.5",
                  onChanged: (v) => _update('cooldownNormal', v),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MindustryFloatField(
                  label: "Enfriamiento con Líquido (cooldownLiquid)",
                  value: cooldownLiquid,
                  hint: "ej: 1.0",
                  onChanged: (v) => _update('cooldownLiquid', v),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: MindustryFloatField(
                  label: "Aumento Radio Fase (phaseRadiusBoost)",
                  value: phaseRadiusBoost,
                  hint: "ej: 40.0 px",
                  onChanged: (v) => _update('phaseRadiusBoost', v),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MindustryFloatField(
                  label: "Aumento Salud Fase (phaseShieldBoost)",
                  value: phaseShieldBoost,
                  hint: "ej: 250.0 HP",
                  onChanged: (v) => _update('phaseShieldBoost', v),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Widget para cintas transportadoras (Conveyor, ArmoredConveyor, StackConveyor, Duct)
class ConveyorPropertiesWidget extends StatelessWidget {
  final Map<String, dynamic> properties;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const ConveyorPropertiesWidget({
    super.key,
    required this.properties,
    required this.onChanged,
  });

  void _update(String key, dynamic value) {
    final copy = Map<String, dynamic>.from(properties);
    if (value == null) {
      copy.remove(key);
    } else {
      copy[key] = value;
    }
    onChanged(copy);
  }

  @override
  Widget build(BuildContext context) {
    final speed = double.tryParse(properties['speed']?.toString() ?? '') ?? 0.08;
    final displayedSpeed = double.tryParse(properties['displayedSpeed']?.toString() ?? '') ?? 8.0;

    return TypeCardContainer(
      title: "Logística: Cinta Transportadora (Conveyor)",
      subtitle: "Velocidad de flujo de ítems en el cinturón logístico",
      icon: Icons.moving,
      accentColor: Colors.greenAccent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: MindustryFloatField(
                  label: "Velocidad Interna de Ítems (speed)",
                  value: speed,
                  hint: "ej: 0.08 ítems/tick",
                  onChanged: (v) => _update('speed', v),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MindustryFloatField(
                  label: "Velocidad Mostrada en UI (displayedSpeed)",
                  value: displayedSpeed,
                  hint: "ej: 8.0 ítems/seg",
                  onChanged: (v) => _update('displayedSpeed', v),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Widget para aceleradores de masa electromagnéticos (MassDriver)
class MassDriverPropertiesWidget extends StatelessWidget {
  final Map<String, dynamic> properties;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const MassDriverPropertiesWidget({
    super.key,
    required this.properties,
    required this.onChanged,
  });

  void _update(String key, dynamic value) {
    final copy = Map<String, dynamic>.from(properties);
    if (value == null) {
      copy.remove(key);
    } else {
      copy[key] = value;
    }
    onChanged(copy);
  }

  @override
  Widget build(BuildContext context) {
    final range = double.tryParse(properties['range']?.toString() ?? '') ?? 400.0;
    final reload = double.tryParse(properties['reload']?.toString() ?? '') ?? 200.0;
    final itemCapacity = int.tryParse(properties['itemCapacity']?.toString() ?? '') ?? 30;
    final bulletSpeed = double.tryParse(properties['bulletSpeed']?.toString() ?? '') ?? 8.0;

    return TypeCardContainer(
      title: "Logística: Conductor de Masa (MassDriver)",
      subtitle: "Disparo electromagnético de paquetes de carga a larga distancia",
      icon: Icons.rocket_launch,
      accentColor: Colors.deepPurpleAccent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: MindustryFloatField(
                  label: "Alcance Máximo de Disparo (range)",
                  value: range,
                  hint: "ej: 440.0 px",
                  onChanged: (v) => _update('range', v),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MindustryFloatField(
                  label: "Tiempo de Disparo/Ciclo (reload)",
                  value: reload,
                  hint: "ej: 200.0 ticks",
                  onChanged: (v) => _update('reload', v),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: MindustryIntField(
                  label: "Capacidad del Paquete (itemCapacity)",
                  value: itemCapacity,
                  hint: "ej: 30 ítems",
                  onChanged: (v) => _update('itemCapacity', v),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MindustryFloatField(
                  label: "Velocidad Proyectil Carga (bulletSpeed)",
                  value: bulletSpeed,
                  hint: "ej: 8.0",
                  onChanged: (v) => _update('bulletSpeed', v),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
