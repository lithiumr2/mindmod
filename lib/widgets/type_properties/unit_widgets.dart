import 'package:flutter/material.dart';
import 'common_form_helpers.dart';

/// Subpanel de Movimiento Aéreo
class FlyingPropertiesWidget extends StatelessWidget {
  final Map<String, dynamic> properties;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const FlyingPropertiesWidget({
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
    final engineOffset = double.tryParse(properties['engineOffset']?.toString() ?? '') ?? 6.0;
    final engineSize = double.tryParse(properties['engineSize']?.toString() ?? '') ?? 2.5;
    final lowAltitude = properties['lowAltitude'] == true;
    final circleTarget = properties['circleTarget'] == true;

    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.lightBlueAccent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.flight, size: 14, color: Colors.lightBlueAccent),
              SizedBox(width: 6),
              Text(
                "Propiedades de Vuelo (Flying)",
                style: TextStyle(color: Colors.lightBlueAccent, fontWeight: FontWeight.bold, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: MindustryFloatField(
                  label: "Desplazamiento Propulsor (engineOffset)",
                  value: engineOffset,
                  hint: "ej: 6.0",
                  onChanged: (v) => _update('engineOffset', v),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MindustryFloatField(
                  label: "Tamaño Llama Propulsor (engineSize)",
                  value: engineSize,
                  hint: "ej: 2.5",
                  onChanged: (v) => _update('engineSize', v),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: MindustryBoolField(
                  label: "Baja Altitud (lowAltitude)",
                  subtitle: "Vuela más cerca del suelo",
                  value: lowAltitude,
                  onChanged: (v) => _update('lowAltitude', v),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MindustryBoolField(
                  label: "Orbitar Objetivo (circleTarget)",
                  subtitle: "Maniobra circular constante en combate",
                  value: circleTarget,
                  onChanged: (v) => _update('circleTarget', v),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Subpanel de Movimiento Bípedo / Mech
class MechPropertiesWidget extends StatelessWidget {
  final Map<String, dynamic> properties;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const MechPropertiesWidget({
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
    final mechStepParticles = properties['mechStepParticles'] != false;
    final stepShake = double.tryParse(properties['stepShake']?.toString() ?? '') ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1A15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.deepOrangeAccent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.directions_walk, size: 14, color: Colors.deepOrangeAccent),
              SizedBox(width: 6),
              Text(
                "Propiedades de Bípedo / Mecanismo (Mech)",
                style: TextStyle(color: Colors.deepOrangeAccent, fontWeight: FontWeight.bold, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          MindustryBoolField(
            label: "Partículas de Pasos (mechStepParticles)",
            subtitle: "Efecto de polvo al apoyar las patas mecánicas",
            value: mechStepParticles,
            onChanged: (v) => _update('mechStepParticles', v),
          ),
          MindustryFloatField(
            label: "Temblor de Pantalla al Pisar (stepShake)",
            value: stepShake,
            hint: "ej: 0.5 (0 = sin temblor)",
            onChanged: (v) => _update('stepShake', v),
          ),
        ],
      ),
    );
  }
}

/// Subpanel de Movimiento con Patas Arácnidas / Oruga (Legs)
class LegsPropertiesWidget extends StatelessWidget {
  final Map<String, dynamic> properties;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const LegsPropertiesWidget({
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
    final legCount = int.tryParse(properties['legCount']?.toString() ?? '') ?? 4;
    final legLength = double.tryParse(properties['legLength']?.toString() ?? '') ?? 12.0;
    final legSpeed = double.tryParse(properties['legSpeed']?.toString() ?? '') ?? 0.15;
    final hovering = properties['hovering'] == true;
    final allowLegStep = properties['allowLegStep'] != false;

    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF161F1A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.pest_control, size: 14, color: Colors.greenAccent),
              SizedBox(width: 6),
              Text(
                "Propiedades de Patas Arácnidas (Legs)",
                style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: MindustryIntField(
                  label: "Cantidad de Patas (legCount)",
                  value: legCount,
                  hint: "ej: 4 o 6",
                  onChanged: (v) => _update('legCount', v),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MindustryFloatField(
                  label: "Longitud de Pata (legLength)",
                  value: legLength,
                  hint: "ej: 12.0 px",
                  onChanged: (v) => _update('legLength', v),
                ),
              ),
            ],
          ),
          MindustryFloatField(
            label: "Velocidad de Movimiento de Pata (legSpeed)",
            value: legSpeed,
            hint: "ej: 0.15",
            onChanged: (v) => _update('legSpeed', v),
          ),
          Row(
            children: [
              Expanded(
                child: MindustryBoolField(
                  label: "Levitación / Flotación (hovering)",
                  subtitle: "Cruza por encima de lagos o líquidos",
                  value: hovering,
                  onChanged: (v) => _update('hovering', v),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MindustryBoolField(
                  label: "Caminar sobre Estructuras (allowLegStep)",
                  subtitle: "Permite pisar edificios sin chocar",
                  value: allowLegStep,
                  onChanged: (v) => _update('allowLegStep', v),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Subpanel de Movimiento Naval
class NavalPropertiesWidget extends StatelessWidget {
  final Map<String, dynamic> properties;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const NavalPropertiesWidget({
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
    final trailLength = int.tryParse(properties['trailLength']?.toString() ?? '') ?? 20;
    final waterVision = properties['waterVision'] != false;

    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF141924),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.directions_boat, size: 14, color: Colors.cyanAccent),
              SizedBox(width: 6),
              Text(
                "Propiedades Navales (Naval)",
                style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: MindustryIntField(
                  label: "Longitud Estela de Agua (trailLength)",
                  value: trailLength,
                  hint: "ej: 25 puntos",
                  onChanged: (v) => _update('trailLength', v),
                ),
              ),
            ],
          ),
          MindustryBoolField(
            label: "Visión Fluvial (waterVision)",
            subtitle: "Optimiza la navegación y visión en agua profunda",
            value: waterVision,
            onChanged: (v) => _update('waterVision', v),
          ),
        ],
      ),
    );
  }
}

/// Submódulo interactivo de Armamento de Unidad (weapons)
class UnitWeaponsWidget extends StatelessWidget {
  final List<dynamic>? weapons;
  final ValueChanged<List<dynamic>?> onChanged;

  const UnitWeaponsWidget({
    super.key,
    required this.weapons,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final weaponsList = weapons != null ? List<Map<String, dynamic>>.from(
      weapons!.map((w) => w is Map ? Map<String, dynamic>.from(w) : <String, dynamic>{})
    ) : <Map<String, dynamic>>[];

    void saveWeapons() {
      onChanged(weaponsList.isEmpty ? null : weaponsList);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Armamento de la Unidad (weapons):",
              style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12),
            ),
            TextButton.icon(
              style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
              icon: const Icon(Icons.add, size: 14, color: Colors.amber),
              label: const Text("Añadir Arma", style: TextStyle(color: Colors.amber, fontSize: 11)),
              onPressed: () {
                weaponsList.add({
                  'name': 'weapon-${weaponsList.length + 1}',
                  'x': 4.0,
                  'y': 2.0,
                  'reload': 20.0,
                  'mirror': true,
                  'rotate': false,
                  'bullet': {
                    'damage': 15.0,
                    'speed': 4.0,
                    'lifetime': 45.0,
                    'splashDamage': 0.0,
                  }
                });
                saveWeapons();
              },
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (weaponsList.isEmpty)
          const Text("La unidad no tiene armas equipadas.", style: TextStyle(color: Colors.white30, fontSize: 11))
        else
          ...weaponsList.asMap().entries.map((entry) {
            final idx = entry.key;
            final weapon = entry.value;

            final name = weapon['name']?.toString() ?? "weapon-${idx + 1}";
            final x = double.tryParse(weapon['x']?.toString() ?? '') ?? 0.0;
            final y = double.tryParse(weapon['y']?.toString() ?? '') ?? 0.0;
            final reload = double.tryParse(weapon['reload']?.toString() ?? '') ?? 20.0;
            final mirror = weapon['mirror'] == true;
            final rotate = weapon['rotate'] == true;
            final bullet = weapon['bullet'] is Map
                ? Map<String, dynamic>.from(weapon['bullet'] as Map)
                : <String, dynamic>{'damage': 12.0, 'speed': 3.5, 'lifetime': 50.0};

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF18181F),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.gps_fixed, size: 14, color: Colors.amber),
                          const SizedBox(width: 6),
                          Text("Arma #${idx + 1}: $name", style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 11)),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                        onPressed: () {
                          weaponsList.removeAt(idx);
                          saveWeapons();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: MindustryStringField(
                          label: "Nombre / Sprite (name)",
                          value: name,
                          hint: "ej: blaster",
                          onChanged: (val) {
                            weapon['name'] = val;
                            saveWeapons();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: MindustryFloatField(
                          label: "Cadencia (reload)",
                          value: reload,
                          hint: "ej: 20.0 ticks",
                          onChanged: (val) {
                            weapon['reload'] = val ?? 20.0;
                            saveWeapons();
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: MindustryFloatField(
                          label: "Posición X (x)",
                          value: x,
                          hint: "ej: 4.5 px",
                          onChanged: (val) {
                            weapon['x'] = val ?? 0.0;
                            saveWeapons();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: MindustryFloatField(
                          label: "Posición Y (y)",
                          value: y,
                          hint: "ej: 2.0 px",
                          onChanged: (val) {
                            weapon['y'] = val ?? 0.0;
                            saveWeapons();
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: MindustryBoolField(
                          label: "Espejo (mirror)",
                          subtitle: "Duplica el arma al lado opuesto",
                          value: mirror,
                          onChanged: (val) {
                            weapon['mirror'] = val;
                            saveWeapons();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: MindustryBoolField(
                          label: "Rotación Independiente (rotate)",
                          subtitle: "Gira para apuntar",
                          value: rotate,
                          onChanged: (val) {
                            weapon['rotate'] = val;
                            saveWeapons();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  BulletTypeSubform(
                    title: "Proyectil de $name",
                    bullet: bullet,
                    onChanged: (newBullet) {
                      weapon['bullet'] = newBullet;
                      saveWeapons();
                    },
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}

/// Widget maestro para Unidades de Mindustry (UnitBasePropertiesWidget)
class UnitBasePropertiesWidget extends StatelessWidget {
  final Map<String, dynamic> properties;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const UnitBasePropertiesWidget({
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
    final speed = double.tryParse(properties['speed']?.toString() ?? '') ?? 1.2;
    final hitSize = double.tryParse(properties['hitSize']?.toString() ?? '') ?? 8.0;
    final health = double.tryParse(properties['health']?.toString() ?? '') ?? 150.0;
    final armor = double.tryParse(properties['armor']?.toString() ?? '') ?? 2.0;
    final itemCapacity = int.tryParse(properties['itemCapacity']?.toString() ?? '') ?? 30;
    final rotateSpeed = double.tryParse(properties['rotateSpeed']?.toString() ?? '') ?? 5.0;
    final isEnemy = properties['isEnemy'] == true;

    // Movement type selector: "flying", "mech", "legs", "naval"
    final unitType = properties['type']?.toString().replaceAll('"', '').toLowerCase() ?? "flying";
    final rawWeapons = properties['weapons'] is List ? properties['weapons'] as List : null;

    return TypeCardContainer(
      title: "Configuración de Unidad (UnitType)",
      subtitle: "Atributos de combate, físicas de movimiento y armamento montado",
      icon: Icons.smart_toy,
      accentColor: Colors.purpleAccent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: MindustryFloatField(
                  label: "Velocidad Desplazamiento (speed)",
                  value: speed,
                  hint: "ej: 1.2 px/tick",
                  onChanged: (v) => _update('speed', v),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MindustryFloatField(
                  label: "Radio de Colisión (hitSize)",
                  value: hitSize,
                  hint: "ej: 9.0 px",
                  onChanged: (v) => _update('hitSize', v),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: MindustryFloatField(
                  label: "Salud / Vida (health)",
                  value: health,
                  hint: "ej: 200.0 HP",
                  onChanged: (v) => _update('health', v),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MindustryFloatField(
                  label: "Armadura / Blindaje (armor)",
                  value: armor,
                  hint: "ej: 3.0",
                  onChanged: (v) => _update('armor', v),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: MindustryIntField(
                  label: "Capacidad de Ítems (itemCapacity)",
                  value: itemCapacity,
                  hint: "ej: 30",
                  onChanged: (v) => _update('itemCapacity', v),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MindustryFloatField(
                  label: "Velocidad de Giro (rotateSpeed)",
                  value: rotateSpeed,
                  hint: "ej: 5.0 deg/tick",
                  onChanged: (v) => _update('rotateSpeed', v),
                ),
              ),
            ],
          ),
          MindustryBoolField(
            label: "Pertenece al Enemigo (isEnemy)",
            subtitle: "La IA solo generará esta unidad en el bando agresor",
            value: isEnemy,
            onChanged: (v) => _update('isEnemy', v),
          ),

          const Divider(color: Colors.white12, height: 20),

          // Sub-paneles de movimiento
          const Text(
            "Físicas Específicas de Locomoción:",
            style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          if (unitType.contains("flying") || properties['flying'] == true)
            FlyingPropertiesWidget(properties: properties, onChanged: onChanged),
          if (unitType.contains("mech") || unitType.contains("ground"))
            MechPropertiesWidget(properties: properties, onChanged: onChanged),
          if (unitType.contains("legs") || unitType.contains("crawl"))
            LegsPropertiesWidget(properties: properties, onChanged: onChanged),
          if (unitType.contains("naval") || unitType.contains("water"))
            NavalPropertiesWidget(properties: properties, onChanged: onChanged),

          // Si no coincidió con ninguna palabra clave, mostramos todos colapsables o seleccionables
          if (!unitType.contains("flying") && !unitType.contains("mech") && !unitType.contains("legs") && !unitType.contains("naval")) ...[
            FlyingPropertiesWidget(properties: properties, onChanged: onChanged),
            MechPropertiesWidget(properties: properties, onChanged: onChanged),
          ],

          const Divider(color: Colors.white12, height: 20),

          // Armamento de unidad
          UnitWeaponsWidget(
            weapons: rawWeapons,
            onChanged: (newWeapons) => _update('weapons', newWeapons),
          ),
        ],
      ),
    );
  }
}
