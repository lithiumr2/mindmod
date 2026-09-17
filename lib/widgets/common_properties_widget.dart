import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/project_file.dart';

/// Contenedor unificado de propiedades comunes para Bloques y Unidades
/// Organizado en pares compactos (2 por fila) para máxima densidad visual.
class CommonPropertiesContainer extends StatelessWidget {
  final String fileId;
  final FileType type;
  final Map<String, dynamic> properties;
  final Function(String, dynamic) onChanged;

  const CommonPropertiesContainer({
    super.key,
    required this.fileId,
    required this.type,
    required this.properties,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (type == FileType.block) {
      return CommonBlockPropertiesWidget(
        fileId: fileId,
        properties: properties,
        onChanged: onChanged,
      );
    } else if (type == FileType.unit) {
      return CommonUnitPropertiesWidget(
        fileId: fileId,
        properties: properties,
        onChanged: onChanged,
      );
    }
    return const SizedBox.shrink();
  }
}

/// Helper para crear tarjetas agrupadas con encabezado
Widget _buildGroupCard({
  required String title,
  required IconData icon,
  required List<Widget> children,
  Color accentColor = const Color(0xFF58A6FF),
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: const Color(0xFF161B22),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.white12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.1),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(7),
              topRight: Radius.circular(7),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 15, color: accentColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: accentColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    ),
  );
}

/// Widget para inputs de texto o numéricos con estilo oscuro compacto
Widget _buildInputField({
  required String label,
  required String valueKey,
  required dynamic initialValue,
  required Function(dynamic) onChanged,
  bool isNumeric = false,
  bool isInteger = false,
  int maxLines = 1,
  String? hint,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
      ),
      const SizedBox(height: 4),
      TextFormField(
        key: ValueKey(valueKey),
        initialValue: initialValue?.toString() ?? '',
        maxLines: maxLines,
        keyboardType: isNumeric
            ? TextInputType.numberWithOptions(decimal: !isInteger, signed: true)
            : TextInputType.text,
        inputFormatters: isNumeric
            ? [
                FilteringTextInputFormatter.allow(
                  isInteger ? RegExp(r'^-?[0-9]*') : RegExp(r'^-?[0-9]*\.?[0-9]*'),
                ),
              ]
            : null,
        style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace'),
        decoration: InputDecoration(
          isDense: true,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white24, fontSize: 11),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          filled: true,
          fillColor: const Color(0xFF21262D),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Colors.white10),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Colors.white10),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Color(0xFF58A6FF)),
          ),
        ),
        onChanged: (val) {
          if (val.trim().isEmpty) {
            onChanged(null);
            return;
          }
          if (isNumeric) {
            if (isInteger) {
              final n = int.tryParse(val);
              onChanged(n);
            } else {
              final n = double.tryParse(val);
              onChanged(n);
            }
          } else {
            onChanged(val);
          }
        },
      ),
    ],
  );
}

/// Widget compacto para switches booleanos
Widget _buildCompactSwitch({
  required String label,
  required bool value,
  required Function(bool) onChanged,
  String? subtitle,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xFF21262D),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: Colors.white10),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white38, fontSize: 9),
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        Transform.scale(
          scale: 0.75,
          child: Switch(
            value: value,
            activeColor: const Color(0xFF58A6FF),
            activeTrackColor: const Color(0xFF1F6FEB).withValues(alpha: 0.5),
            inactiveThumbColor: Colors.white38,
            inactiveTrackColor: Colors.white10,
            onChanged: onChanged,
          ),
        ),
      ],
    ),
  );
}

/// Widget dropdown compacto
Widget _buildDropdownField({
  required String label,
  required String valueKey,
  required String? currentValue,
  required List<String> items,
  required Function(String?) onChanged,
}) {
  final actualVal = items.contains(currentValue) ? currentValue : (items.isNotEmpty ? items.first : null);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
      ),
      const SizedBox(height: 4),
      Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF21262D),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white10),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: actualVal,
            isExpanded: true,
            dropdownColor: const Color(0xFF21262D),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white54, size: 18),
            style: const TextStyle(color: Colors.white, fontSize: 12),
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    ],
  );
}

/// ---------------------------------------------------------------------------
/// PROPIEDADES COMUNES DE BLOQUES
/// ---------------------------------------------------------------------------
class CommonBlockPropertiesWidget extends StatelessWidget {
  final String fileId;
  final Map<String, dynamic> properties;
  final Function(String, dynamic) onChanged;

  const CommonBlockPropertiesWidget({
    super.key,
    required this.fileId,
    required this.properties,
    required this.onChanged,
  });

  static const List<String> categories = [
    'distribution',
    'liquid',
    'power',
    'production',
    'defense',
    'turret',
    'units',
    'effect',
    'logic',
    'crafting',
  ];

  static const List<String> standardItems = [
    'copper', 'lead', 'metaglass', 'graphite', 'sand', 'coal', 'titanium',
    'thorium', 'scrap', 'silicon', 'plastanium', 'phase-fabric', 'surge-alloy',
    'spore-pod', 'blast-compound', 'pyratite', 'beryllium', 'tungsten',
    'oxide', 'carbide', 'fissile-matter', 'dormant-cyst'
  ];

  @override
  Widget build(BuildContext context) {
    final hasItems = properties['hasItems'] == true;
    final hasLiquids = properties['hasLiquids'] == true;
    final hasPower = properties['hasPower'] == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Identificación y Dimensiones
        _buildGroupCard(
          title: "Identificación y Dimensiones",
          icon: Icons.info_outline,
          accentColor: const Color(0xFF58A6FF),
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildInputField(
                    label: "Nombre para Mostrar (localizedName)",
                    valueKey: "${fileId}_localizedName",
                    initialValue: properties['localizedName'] ?? properties['name'],
                    onChanged: (v) => onChanged('localizedName', v),
                    hint: "Mi Gran Bloque",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: _buildInputField(
                    label: "Tamaño (size en tiles)",
                    valueKey: "${fileId}_size",
                    initialValue: properties['size'] ?? 1,
                    isNumeric: true,
                    isInteger: true,
                    onChanged: (v) => onChanged('size', v),
                    hint: "1, 2, 3, 4...",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildInputField(
              label: "Descripción (description)",
              valueKey: "${fileId}_description",
              initialValue: properties['description'],
              maxLines: 2,
              onChanged: (v) => onChanged('description', v),
              hint: "Descripción del bloque en el juego...",
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildDropdownField(
                    label: "Categoría de Construcción (category)",
                    valueKey: "${fileId}_category",
                    currentValue: properties['category']?.toString(),
                    items: categories,
                    onChanged: (v) => onChanged('category', v),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInputField(
                    label: "Árbol Tecnológico (research)",
                    valueKey: "${fileId}_research",
                    initialValue: properties['research'] ?? properties['requirements'] != null ? 'core-shard' : null,
                    onChanged: (v) => onChanged('research', v),
                    hint: "ej: duo, core-shard",
                  ),
                ),
              ],
            ),
          ],
        ),

        // 2. Vitalidad y Construcción
        _buildGroupCard(
          title: "Vitalidad y Construcción",
          icon: Icons.favorite_border,
          accentColor: const Color(0xFFF778BA),
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    label: "Vida / Salud (health)",
                    valueKey: "${fileId}_health",
                    initialValue: properties['health'] ?? 100,
                    isNumeric: true,
                    isInteger: true,
                    onChanged: (v) => onChanged('health', v),
                    hint: "100",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInputField(
                    label: "Mult. Tiempo Const. (buildCostMultiplier)",
                    valueKey: "${fileId}_buildCostMultiplier",
                    initialValue: properties['buildCostMultiplier'] ?? 1.0,
                    isNumeric: true,
                    onChanged: (v) => onChanged('buildCostMultiplier', v),
                    hint: "1.0",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildCompactSwitch(
                    label: "Siempre Desbloqueado",
                    subtitle: "alwaysUnlocked",
                    value: properties['alwaysUnlocked'] == true,
                    onChanged: (v) => onChanged('alwaysUnlocked', v ? true : null),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildCompactSwitch(
                    label: "Sólido (Bloquea paso)",
                    subtitle: "solid",
                    value: properties['solid'] != false,
                    onChanged: (v) => onChanged('solid', v ? null : false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: _buildCompactSwitch(
                    label: "Destructible",
                    subtitle: "destructible",
                    value: properties['destructible'] != false,
                    onChanged: (v) => onChanged('destructible', v ? null : false),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildCompactSwitch(
                    label: "Objetivo Enemigo",
                    subtitle: "targetable",
                    value: properties['targetable'] != false,
                    onChanged: (v) => onChanged('targetable', v ? null : false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: _buildCompactSwitch(
                    label: "Acelerable por Overdrive",
                    subtitle: "canOverdrive",
                    value: properties['canOverdrive'] != false,
                    onChanged: (v) => onChanged('canOverdrive', v ? null : false),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildCompactSwitch(
                    label: "Actualizar Tick (update)",
                    subtitle: "update",
                    value: properties['update'] != false,
                    onChanged: (v) => onChanged('update', v ? null : false),
                  ),
                ),
              ],
            ),
          ],
        ),

        // 3. Capacidades y Energía
        _buildGroupCard(
          title: "Capacidades y Energía",
          icon: Icons.flash_on,
          accentColor: const Color(0xFFE3B341),
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildCompactSwitch(
                    label: "Almacena Ítems (hasItems)",
                    value: hasItems,
                    onChanged: (v) => onChanged('hasItems', v ? true : false),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInputField(
                    label: "Capacidad Ítems (itemCapacity)",
                    valueKey: "${fileId}_itemCapacity",
                    initialValue: properties['itemCapacity'] ?? 10,
                    isNumeric: true,
                    isInteger: true,
                    onChanged: (v) => onChanged('itemCapacity', v),
                    hint: "10",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildCompactSwitch(
                    label: "Almacena Líquidos (hasLiquids)",
                    value: hasLiquids,
                    onChanged: (v) => onChanged('hasLiquids', v ? true : false),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInputField(
                    label: "Capacidad Líquidos (liquidCapacity)",
                    valueKey: "${fileId}_liquidCapacity",
                    initialValue: properties['liquidCapacity'] ?? 10.0,
                    isNumeric: true,
                    onChanged: (v) => onChanged('liquidCapacity', v),
                    hint: "10.0",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildCompactSwitch(
                    label: "Usa Energía (hasPower)",
                    value: hasPower,
                    onChanged: (v) => onChanged('hasPower', v ? true : false),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildCompactSwitch(
                    label: "Emite Energía (outputsPower)",
                    value: properties['outputsPower'] == true,
                    onChanged: (v) => onChanged('outputsPower', v ? true : null),
                  ),
                ),
              ],
            ),
          ],
        ),

        // 4. Requisitos de Construcción (requirements)
        _buildRequirementsCard(
          fileId: fileId,
          requirements: properties['requirements'],
          availableItems: standardItems,
          onChanged: (newReqs) => onChanged('requirements', newReqs),
        ),
      ],
    );
  }

  Widget _buildRequirementsCard({
    required String fileId,
    required dynamic requirements,
    required List<String> availableItems,
    required Function(dynamic) onChanged,
  }) {
    List<Map<String, dynamic>> reqList = [];
    if (requirements is List) {
      for (var item in requirements) {
        if (item is Map) {
          reqList.add(Map<String, dynamic>.from(item));
        } else if (item is String) {
          // Si viene en formato Mindustry "copper/10"
          final parts = item.split('/');
          if (parts.length == 2) {
            reqList.add({'item': parts[0], 'amount': int.tryParse(parts[1]) ?? 10});
          }
        }
      }
    }

    return _buildGroupCard(
      title: "Requisitos de Construcción (requirements)",
      icon: Icons.inventory_2_outlined,
      accentColor: const Color(0xFF7EE787),
      children: [
        if (reqList.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Text(
              "Sin costes asignados (gratuito o bloque de entorno).",
              style: TextStyle(color: Colors.white38, fontSize: 11, fontStyle: FontStyle.italic),
            ),
          )
        else
          ...List.generate(reqList.length, (index) {
            final entry = reqList[index];
            final currentItem = entry['item']?.toString() ?? 'copper';
            final amount = entry['amount']?.toString() ?? '10';

            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF21262D),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: availableItems.contains(currentItem) ? currentItem : availableItems.first,
                        dropdownColor: const Color(0xFF21262D),
                        isDense: true,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                        items: availableItems.map((it) {
                          return DropdownMenuItem(value: it, child: Text(it));
                        }).toList(),
                        onChanged: (newItem) {
                          if (newItem != null) {
                            reqList[index]['item'] = newItem;
                            onChanged(reqList);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      key: ValueKey("${fileId}_req_${index}_$amount"),
                      initialValue: amount,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                        hintText: "Cant.",
                        hintStyle: TextStyle(color: Colors.white24, fontSize: 11),
                      ),
                      onChanged: (v) {
                        final val = int.tryParse(v) ?? 1;
                        reqList[index]['amount'] = val;
                        onChanged(reqList);
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.redAccent, size: 16),
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      reqList.removeAt(index);
                      onChanged(reqList.isEmpty ? null : reqList);
                    },
                  ),
                ],
              ),
            );
          }),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              backgroundColor: const Color(0xFF21262D),
            ),
            icon: const Icon(Icons.add, size: 14, color: Color(0xFF7EE787)),
            label: const Text(
              "Añadir Ítem",
              style: TextStyle(color: Color(0xFF7EE787), fontSize: 11, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              reqList.add({'item': 'copper', 'amount': 10});
              onChanged(reqList);
            },
          ),
        ),
      ],
    );
  }
}

/// ---------------------------------------------------------------------------
/// PROPIEDADES COMUNES DE UNIDADES
/// ---------------------------------------------------------------------------
class CommonUnitPropertiesWidget extends StatelessWidget {
  final String fileId;
  final Map<String, dynamic> properties;
  final Function(String, dynamic) onChanged;

  const CommonUnitPropertiesWidget({
    super.key,
    required this.fileId,
    required this.properties,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Identificación y Atributos Básicos
        _buildGroupCard(
          title: "Identificación y Dimensiones de Unidad",
          icon: Icons.badge_outlined,
          accentColor: const Color(0xFF58A6FF),
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildInputField(
                    label: "Nombre de Unidad (localizedName)",
                    valueKey: "${fileId}_localizedName",
                    initialValue: properties['localizedName'] ?? properties['name'],
                    onChanged: (v) => onChanged('localizedName', v),
                    hint: "Dardo Alfa",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: _buildInputField(
                    label: "Tamaño de Colisión (hitSize)",
                    valueKey: "${fileId}_hitSize",
                    initialValue: properties['hitSize'] ?? 8.0,
                    isNumeric: true,
                    onChanged: (v) => onChanged('hitSize', v),
                    hint: "8.0, 12.0...",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildInputField(
              label: "Descripción (description)",
              valueKey: "${fileId}_description",
              initialValue: properties['description'],
              maxLines: 2,
              onChanged: (v) => onChanged('description', v),
              hint: "Rol o características de la unidad...",
            ),
          ],
        ),

        // 2. Blindaje, Salud y Maniobrabilidad
        _buildGroupCard(
          title: "Estadísticas de Supervivencia y Movimiento",
          icon: Icons.shield_outlined,
          accentColor: const Color(0xFFF778BA),
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    label: "Salud Máxima (health)",
                    valueKey: "${fileId}_health",
                    initialValue: properties['health'] ?? 150,
                    isNumeric: true,
                    isInteger: true,
                    onChanged: (v) => onChanged('health', v),
                    hint: "150",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInputField(
                    label: "Blindaje Base (armor)",
                    valueKey: "${fileId}_armor",
                    initialValue: properties['armor'] ?? 0.0,
                    isNumeric: true,
                    onChanged: (v) => onChanged('armor', v),
                    hint: "0.0",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    label: "Velocidad de Avance (speed)",
                    valueKey: "${fileId}_speed",
                    initialValue: properties['speed'] ?? 1.2,
                    isNumeric: true,
                    onChanged: (v) => onChanged('speed', v),
                    hint: "1.2",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInputField(
                    label: "Velocidad de Giro (rotateSpeed)",
                    valueKey: "${fileId}_rotateSpeed",
                    initialValue: properties['rotateSpeed'] ?? 5.0,
                    isNumeric: true,
                    onChanged: (v) => onChanged('rotateSpeed', v),
                    hint: "5.0",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    label: "Aceleración (accel)",
                    valueKey: "${fileId}_accel",
                    initialValue: properties['accel'] ?? 0.5,
                    isNumeric: true,
                    onChanged: (v) => onChanged('accel', v),
                    hint: "0.5",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInputField(
                    label: "Fricción / Inercia (drag)",
                    valueKey: "${fileId}_drag",
                    initialValue: properties['drag'] ?? 0.05,
                    isNumeric: true,
                    onChanged: (v) => onChanged('drag', v),
                    hint: "0.05",
                  ),
                ),
              ],
            ),
          ],
        ),

        // 3. Capacidades de Trabajo y Utilidad
        _buildGroupCard(
          title: "Minería, Construcción e Inventario",
          icon: Icons.build_circle_outlined,
          accentColor: const Color(0xFFE3B341),
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    label: "Velocidad Minado (mineSpeed)",
                    valueKey: "${fileId}_mineSpeed",
                    initialValue: properties['mineSpeed'] ?? 0.0,
                    isNumeric: true,
                    onChanged: (v) => onChanged('mineSpeed', v),
                    hint: "0.0",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInputField(
                    label: "Nivel Minado (mineTier)",
                    valueKey: "${fileId}_mineTier",
                    initialValue: properties['mineTier'] ?? 0,
                    isNumeric: true,
                    isInteger: true,
                    onChanged: (v) => onChanged('mineTier', v),
                    hint: "1, 2, 3...",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    label: "Velocidad Const. (buildSpeed)",
                    valueKey: "${fileId}_buildSpeed",
                    initialValue: properties['buildSpeed'] ?? 0.0,
                    isNumeric: true,
                    onChanged: (v) => onChanged('buildSpeed', v),
                    hint: "0.0, 1.0...",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInputField(
                    label: "Capacidad Ítems (itemCapacity)",
                    valueKey: "${fileId}_itemCapacity",
                    initialValue: properties['itemCapacity'] ?? 20,
                    isNumeric: true,
                    isInteger: true,
                    onChanged: (v) => onChanged('itemCapacity', v),
                    hint: "20",
                  ),
                ),
              ],
            ),
          ],
        ),

        // 4. Banderas de Control y Comportamiento
        _buildGroupCard(
          title: "Banderas de Control y Comportamiento",
          icon: Icons.toggle_on_outlined,
          accentColor: const Color(0xFF7EE787),
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildCompactSwitch(
                    label: "Unidad Voladora (flying)",
                    value: properties['flying'] == true,
                    onChanged: (v) => onChanged('flying', v ? true : null),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildCompactSwitch(
                    label: "Baja Altitud (lowAltitude)",
                    value: properties['lowAltitude'] == true,
                    onChanged: (v) => onChanged('lowAltitude', v ? true : null),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: _buildCompactSwitch(
                    label: "Objetivo Enemigo (targetable)",
                    value: properties['targetable'] != false,
                    onChanged: (v) => onChanged('targetable', v ? null : false),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildCompactSwitch(
                    label: "Controlable por Jugador",
                    subtitle: "playerControllable",
                    value: properties['playerControllable'] != false,
                    onChanged: (v) => onChanged('playerControllable', v ? null : false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: _buildCompactSwitch(
                    label: "Controlable por Lógica",
                    subtitle: "logicControllable",
                    value: properties['logicControllable'] != false,
                    onChanged: (v) => onChanged('logicControllable', v ? null : false),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildCompactSwitch(
                    label: "Usa Límite de Unidades",
                    subtitle: "useUnitCap",
                    value: properties['useUnitCap'] != false,
                    onChanged: (v) => onChanged('useUnitCap', v ? null : false),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
