import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'common_form_helpers.dart';

class DrawerBuilderWidget extends ConsumerStatefulWidget {
  final Map<String, dynamic> blockProperties;
  final List<String> availableLiquids;
  final ValueChanged<Map<String, dynamic>?> onChanged;

  const DrawerBuilderWidget({
    super.key,
    required this.blockProperties,
    required this.availableLiquids,
    required this.onChanged,
  });

  @override
  ConsumerState<DrawerBuilderWidget> createState() => _DrawerBuilderWidgetState();
}

class _DrawerBuilderWidgetState extends ConsumerState<DrawerBuilderWidget> {
  List<Map<String, dynamic>> _drawers = [];

  final List<String> _layerTypes = [
    "DrawRegion",
    "DrawLiquidTile",
    "DrawLiquidRegion",
    "DrawSmelt",
    "DrawArcSmelt",
    "DrawFlame",
    "DrawGlowRegion",
    "DrawPistons",
    "DrawBlurSpin"
  ];

  @override
  void initState() {
    super.initState();
    _initDrawers();
  }

  @override
  void didUpdateWidget(covariant DrawerBuilderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Para simplificar, la fuente principal de la verdad es el propio estado del widget
    // No resincronizaremos intensivamente a menos que properties['drawer'] cambie radicalmente.
  }

  int _keyCounter = 0;

  void _initDrawers() {
    final drawerProp = widget.blockProperties['drawer'];
    _drawers = [];
    if (drawerProp is Map && drawerProp['type'] == 'DrawMulti' && drawerProp['drawers'] is List) {
       for (var d in drawerProp['drawers']) {
         if (d is Map) {
           final copy = Map<String, dynamic>.from(d);
           copy['_key'] = _keyCounter++;
           _drawers.add(copy);
         }
       }
    } else if (drawerProp is Map && drawerProp['type'] != null) {
      final copy = Map<String, dynamic>.from(drawerProp);
      copy['_key'] = _keyCounter++;
      _drawers.add(copy);
    }
    
    if (_drawers.isEmpty || _drawers.first['type'] != 'DrawDefault') {
       _drawers.insert(0, {'type': 'DrawDefault', '_key': _keyCounter++});
    }
  }

  void _save() {
    // Strip _key before saving
    final cleanDrawers = _drawers.map((d) {
      final copy = Map<String, dynamic>.from(d);
      copy.remove('_key');
      return copy;
    }).toList();

    widget.onChanged({
      'type': 'DrawMulti',
      'drawers': cleanDrawers,
    });
  }

  void _addLayer(String type) {
    setState(() {
      _drawers.add({'type': type, '_key': _keyCounter++});
    });
    _save();
  }

  void _confirmDeleteLayer(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF222228),
        title: const Text("Eliminar Capa", style: TextStyle(color: Colors.white)),
        content: const Text("¿Estás seguro de que deseas eliminar esta capa visual?", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Cancelar", style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _drawers.removeAt(index);
              });
              _save();
            },
            child: const Text("Eliminar", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _showAddLayerModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E24),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Añadir Nueva Capa Visual", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _layerTypes.length,
                  itemBuilder: (context, i) {
                    final t = _layerTypes[i];
                    return ListTile(
                      title: Text(t, style: const TextStyle(color: Colors.amber, fontSize: 14)),
                      trailing: const Icon(Icons.add_circle_outline, color: Colors.amber),
                      onTap: () {
                        Navigator.of(ctx).pop();
                        _addLayer(t);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLayerProperties(int index, Map<String, dynamic> layer) {
    final type = layer['type']?.toString() ?? '';
    final hasLiquids = widget.blockProperties['hasLiquids'] == true;

    List<Widget> children = [];

    if ((type == 'DrawLiquidTile' || type == 'DrawLiquidRegion') && !hasLiquids) {
      children.add(
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.redAccent.withOpacity(0.1),
            border: Border.all(color: Colors.redAccent),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: const [
              Icon(Icons.warning_amber, color: Colors.redAccent, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text("Advertencia: Este bloque tiene 'hasLiquids: false', la capa de líquido no se mostrará en el juego.", style: TextStyle(color: Colors.redAccent, fontSize: 11)),
              ),
            ],
          ),
        )
      );
    }

    void updateProp(String key, dynamic value) {
      setState(() {
        if (value == null || (value is String && value.isEmpty)) {
          layer.remove(key);
        } else {
          layer[key] = value;
        }
      });
      _save();
    }

    String sanitizeSuffix(String? val) {
      if (val == null || val.isEmpty) return "";
      var trimmed = val.trim();
      if (!trimmed.startsWith('-')) {
        trimmed = '-$trimmed';
      }
      return trimmed;
    }

    if (type == 'DrawRegion') {
      children.addAll([
        MindustryStringField(
          label: "Sufijo (suffix)",
          value: layer['suffix']?.toString() ?? '',
          hint: "-rotator",
          onChanged: (v) => updateProp('suffix', sanitizeSuffix(v)),
        ),
        MindustryBoolField(
          label: "Girar Textura (spinSprite)",
          value: layer['spinSprite'] == true,
          onChanged: (v) => updateProp('spinSprite', v),
        ),
        Row(
          children: [
            Expanded(child: MindustryFloatField(label: "Vel. Giro (rotateSpeed)", value: double.tryParse(layer['rotateSpeed']?.toString() ?? ''), onChanged: (v) => updateProp('rotateSpeed', v))),
            const SizedBox(width: 8),
            Expanded(child: MindustryFloatField(label: "Despl. X (x)", value: double.tryParse(layer['x']?.toString() ?? ''), onChanged: (v) => updateProp('x', v))),
            const SizedBox(width: 8),
            Expanded(child: MindustryFloatField(label: "Despl. Y (y)", value: double.tryParse(layer['y']?.toString() ?? ''), onChanged: (v) => updateProp('y', v))),
          ]
        )
      ]);
    }
    
    if (type == 'DrawLiquidTile') {
      children.addAll([
        MindustryDropdownField(
          label: "Líquido (drawLiquid)",
          value: layer['drawLiquid']?.toString() ?? (widget.availableLiquids.isNotEmpty ? widget.availableLiquids.first : 'water'),
          items: widget.availableLiquids,
          onChanged: (v) => updateProp('drawLiquid', v),
        ),
        MindustryFloatField(
          label: "Recorte (padding)",
          value: double.tryParse(layer['padding']?.toString() ?? ''),
          hint: "ej: 2.0",
          onChanged: (v) => updateProp('padding', v),
        ),
      ]);
    }

    if (type == 'DrawLiquidRegion') {
      children.addAll([
        MindustryStringField(
          label: "Sufijo de Máscara (suffix)",
          value: layer['suffix']?.toString() ?? '',
          hint: "-liquid",
          onChanged: (v) => updateProp('suffix', sanitizeSuffix(v)),
        ),
        MindustryDropdownField(
          label: "Líquido (drawLiquid)",
          value: layer['drawLiquid']?.toString() ?? (widget.availableLiquids.isNotEmpty ? widget.availableLiquids.first : 'water'),
          items: widget.availableLiquids,
          onChanged: (v) => updateProp('drawLiquid', v),
        ),
      ]);
    }

    if (type == 'DrawSmelt' || type == 'DrawArcSmelt') {
      children.addAll([
        Row(
          children: [
            Expanded(child: MindustryHexColorField(label: "Color Fuego (flameColor)", value: layer['flameColor']?.toString() ?? 'ffc999', onChanged: (v) => updateProp('flameColor', v))),
            const SizedBox(width: 8),
            Expanded(child: MindustryHexColorField(label: "Color Centro (midColor)", value: layer['midColor']?.toString() ?? 'ffeaad', onChanged: (v) => updateProp('midColor', v))),
          ]
        )
      ]);
    }

    if (type == 'DrawFlame') {
      children.addAll([
        MindustryHexColorField(label: "Color Llama (flameColor)", value: layer['flameColor']?.toString() ?? 'ffc999', onChanged: (v) => updateProp('flameColor', v)),
        Row(
          children: [
            Expanded(child: MindustryFloatField(label: "Radio Base (flameRadius)", value: double.tryParse(layer['flameRadius']?.toString() ?? ''), onChanged: (v) => updateProp('flameRadius', v))),
            const SizedBox(width: 8),
            Expanded(child: MindustryFloatField(label: "Escala (flameRadiusScl)", value: double.tryParse(layer['flameRadiusScl']?.toString() ?? ''), onChanged: (v) => updateProp('flameRadiusScl', v))),
            const SizedBox(width: 8),
            Expanded(child: MindustryFloatField(label: "Mag. Palpitación (flameRadiusMag)", value: double.tryParse(layer['flameRadiusMag']?.toString() ?? ''), onChanged: (v) => updateProp('flameRadiusMag', v))),
          ]
        )
      ]);
    }

    if (type == 'DrawGlowRegion') {
      children.addAll([
        MindustryStringField(
          label: "Sufijo (suffix)",
          value: layer['suffix']?.toString() ?? '',
          hint: "-glow",
          onChanged: (v) => updateProp('suffix', sanitizeSuffix(v)),
        ),
        Row(
          children: [
            Expanded(child: MindustryHexColorField(label: "Color Brillo (color)", value: layer['color']?.toString() ?? 'ff0000', onChanged: (v) => updateProp('color', v))),
            const SizedBox(width: 8),
            Expanded(child: MindustryFloatField(label: "Vel. Palpitación (glowScale)", value: double.tryParse(layer['glowScale']?.toString() ?? ''), onChanged: (v) => updateProp('glowScale', v))),
          ]
        )
      ]);
    }

    if (type == 'DrawPistons') {
      children.addAll([
        MindustryStringField(
          label: "Sufijo Pistón (suffix)",
          value: layer['suffix']?.toString() ?? '',
          hint: "-piston",
          onChanged: (v) => updateProp('suffix', sanitizeSuffix(v)),
        ),
        Row(
          children: [
            Expanded(child: MindustryIntField(label: "Cantidad (sides)", value: int.tryParse(layer['sides']?.toString() ?? ''), hint: "ej: 4", onChanged: (v) => updateProp('sides', v))),
            const SizedBox(width: 8),
            Expanded(child: MindustryFloatField(label: "Dist. Centro (sideOffset)", value: double.tryParse(layer['sideOffset']?.toString() ?? ''), onChanged: (v) => updateProp('sideOffset', v))),
          ]
        ),
        Row(
          children: [
            Expanded(child: MindustryFloatField(label: "Recorrido (sinMag)", value: double.tryParse(layer['sinMag']?.toString() ?? ''), onChanged: (v) => updateProp('sinMag', v))),
            const SizedBox(width: 8),
            Expanded(child: MindustryFloatField(label: "Velocidad (sinScl)", value: double.tryParse(layer['sinScl']?.toString() ?? ''), onChanged: (v) => updateProp('sinScl', v))),
          ]
        )
      ]);
    }

    if (type == 'DrawBlurSpin') {
      children.addAll([
        MindustryStringField(
          label: "Sufijo Rotor (suffix)",
          value: layer['suffix']?.toString() ?? '',
          hint: "-rotator",
          onChanged: (v) => updateProp('suffix', sanitizeSuffix(v)),
        ),
        Row(
          children: [
            Expanded(child: MindustryFloatField(label: "Umbral Borroso (blurThresh)", value: double.tryParse(layer['blurThresh']?.toString() ?? ''), hint: "ej: 0.01", onChanged: (v) => updateProp('blurThresh', v))),
            const SizedBox(width: 8),
            Expanded(child: MindustryFloatField(label: "Velocidad Giro (rotateSpeed)", value: double.tryParse(layer['rotateSpeed']?.toString() ?? ''), onChanged: (v) => updateProp('rotateSpeed', v))),
          ]
        )
      ]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _buildLayerTile(int index, Map<String, dynamic> layer) {
    final type = layer['type']?.toString() ?? 'Unknown';
    final isDefault = index == 0 && type == 'DrawDefault';
    final itemKey = layer['_key'] ?? index; // fallback

    return Container(
      key: ValueKey("drawer_id_$itemKey"),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C24),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDefault ? Colors.white24 : Colors.amber.withOpacity(0.3)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: !isDefault,
          leading: Icon(isDefault ? Icons.image : Icons.layers, color: isDefault ? Colors.white54 : Colors.amber),
          title: Text(type, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isDefault)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                  onPressed: () => _confirmDeleteLayer(index),
                ),
              if (!isDefault)
                ReorderableDragStartListener(
                  index: index,
                  child: const Icon(Icons.drag_handle, color: Colors.white54),
                )
              else
                const Icon(Icons.lock_outline, color: Colors.white24, size: 18),
            ],
          ),
          children: [
            if (isDefault)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text("Capa base del bloque. Renderiza el sprite principal sin modificaciones.", style: TextStyle(color: Colors.white54, fontSize: 11)),
              )
            else
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
                child: _buildLayerProperties(index, layer),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TypeCardContainer(
      title: "Jerarquía Visual (Drawer)",
      subtitle: "Configura las capas de renderizado del bloque en orden (Z-Index)",
      icon: Icons.layers,
      accentColor: Colors.deepPurpleAccent,
      actions: [
        TextButton.icon(
          style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
          icon: const Icon(Icons.add, size: 13, color: Colors.deepPurpleAccent),
          label: const Text("Añadir Capa", style: TextStyle(color: Colors.deepPurpleAccent, fontSize: 11)),
          onPressed: _showAddLayerModal,
        ),
      ],
      child: ReorderableListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _drawers.length,
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (newIndex > oldIndex) newIndex -= 1;
            if (oldIndex == 0) return; // Protect DrawDefault
            if (newIndex == 0) newIndex = 1; // Protect index 0
            final item = _drawers.removeAt(oldIndex);
            _drawers.insert(newIndex, item);
          });
          _save();
        },
        itemBuilder: (context, index) {
          return _buildLayerTile(index, _drawers[index]);
        },
      ),
    );
  }
}
