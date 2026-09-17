import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/module_schema.dart';
import '../providers/module_registry_provider.dart';

/// Pantalla completa de edición y creación de Módulos Dinámicos
class ModuleEditorScreen extends ConsumerStatefulWidget {
  final CustomModule? module;

  const ModuleEditorScreen({super.key, this.module});

  @override
  ConsumerState<ModuleEditorScreen> createState() => _ModuleEditorScreenState();
}

class _ModuleEditorScreenState extends ConsumerState<ModuleEditorScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controladores de Pestaña 1 (Info General)
  late TextEditingController _idController;
  late TextEditingController _nameController;
  late TextEditingController _authorController;
  late TextEditingController _versionController;
  late TextEditingController _descController;
  bool _enabled = true;

  // Estado Pestaña 2 (Tipos Personalizados)
  List<CustomTypeSchema> _customTypes = [];
  int _selectedTypeIndex = 0;

  // Estado Pestaña 4 (Inyecciones Globales)
  List<String> _customItems = [];
  List<String> _customLiquids = [];
  List<String> _customCategories = [];

  final TextEditingController _itemInputCtrl = TextEditingController();
  final TextEditingController _liquidInputCtrl = TextEditingController();
  final TextEditingController _categoryInputCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    final m = widget.module;
    if (m != null) {
      _idController = TextEditingController(text: m.id);
      _nameController = TextEditingController(text: m.name);
      _authorController = TextEditingController(text: m.author);
      _versionController = TextEditingController(text: m.version);
      _descController = TextEditingController(text: m.description);
      _enabled = m.enabled;
      _customTypes = m.customTypes.map((t) => t.copyWith()).toList();
      _customItems = List<String>.from(m.globalInjections.customItems);
      _customLiquids = List<String>.from(m.globalInjections.customLiquids);
      _customCategories = List<String>.from(m.globalInjections.customCategories);
    } else {
      final now = DateTime.now().millisecondsSinceEpoch;
      _idController = TextEditingController(text: 'custom_plugin_$now');
      _nameController = TextEditingController(text: 'Mi Módulo Personalizado');
      _authorController = TextEditingController(text: 'Modder');
      _versionController = TextEditingController(text: '1.0.0');
      _descController = TextEditingController(text: '');
      _customTypes = [
        CustomTypeSchema(
          typeId: 'custom-crafter',
          displayName: 'Crafter Avanzado',
          category: CustomTypeCategory.block,
          properties: [
            const PropertyDefinition(
              key: 'processTime',
              label: 'Tiempo de Proceso',
              type: PropertyDataType.numberFloat,
              defaultValue: 60.0,
            ),
          ],
        ),
      ];
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _idController.dispose();
    _nameController.dispose();
    _authorController.dispose();
    _versionController.dispose();
    _descController.dispose();
    _itemInputCtrl.dispose();
    _liquidInputCtrl.dispose();
    _categoryInputCtrl.dispose();
    super.dispose();
  }

  void _saveModule() {
    final id = _idController.text.trim();
    final name = _nameController.text.trim();

    if (id.isEmpty) {
      _showToast('El ID del módulo no puede estar vacío');
      _tabController.animateTo(0);
      return;
    }

    final idRegex = RegExp(r'^[a-zA-Z0-9_\-]+$');
    if (!idRegex.hasMatch(id)) {
      _showToast('El ID solo puede contener letras, números, guiones y guiones bajos');
      _tabController.animateTo(0);
      return;
    }

    if (name.isEmpty) {
      _showToast('El Nombre del módulo es obligatorio');
      _tabController.animateTo(0);
      return;
    }

    final updatedModule = CustomModule(
      id: id,
      name: name,
      author: _authorController.text.trim().isEmpty ? 'Anónimo' : _authorController.text.trim(),
      version: _versionController.text.trim().isEmpty ? '1.0.0' : _versionController.text.trim(),
      description: _descController.text.trim(),
      enabled: _enabled,
      customTypes: _customTypes,
      globalInjections: GlobalRegistryInjection(
        customItems: _customItems,
        customLiquids: _customLiquids,
        customCategories: _customCategories,
      ),
    );

    if (widget.module != null) {
      ref.read(moduleRegistryProvider.notifier).updateModule(updatedModule);
    } else {
      ref.read(moduleRegistryProvider.notifier).registerModule(updatedModule);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF238636),
        content: Text('Módulo "${updatedModule.name}" guardado correctamente.'),
      ),
    );

    Navigator.pop(context);
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text(msg),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.module != null ? 'Editar: ${widget.module!.name}' : 'Crear Nuevo Módulo',
          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF238636),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              icon: const Icon(Icons.check, size: 16, color: Colors.white),
              label: const Text('Guardar Módulo', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              onPressed: _saveModule,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF58A6FF),
          indicatorWeight: 3,
          labelColor: const Color(0xFF58A6FF),
          unselectedLabelColor: Colors.white54,
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          tabs: const [
            Tab(icon: Icon(Icons.info_outline, size: 16), text: 'Info General'),
            Tab(icon: Icon(Icons.category_outlined, size: 16), text: 'Tipos'),
            Tab(icon: Icon(Icons.tune_outlined, size: 16), text: 'Propiedades'),
            Tab(icon: Icon(Icons.add_link_outlined, size: 16), text: 'Inyecciones'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGeneralTab(),
          _buildTypesTab(),
          _buildPropertiesTab(),
          _buildInjectionsTab(),
        ],
      ),
    );
  }

  // --- PESTAÑA 1: INFO GENERAL ---
  Widget _buildGeneralTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Identificación del Módulo'),
          const SizedBox(height: 12),
          _inputField(
            controller: _idController,
            label: 'ID Único / Slug',
            hint: 'ej: multilib_extension',
            helper: 'Identificador único sin espacios (a-z, 0-9, guiones y guiones bajos).',
            enabled: widget.module == null,
          ),
          const SizedBox(height: 12),
          _inputField(
            controller: _nameController,
            label: 'Nombre del Módulo',
            hint: 'ej: MultiLib Custom Blocks',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _inputField(
                  controller: _authorController,
                  label: 'Autor / Creador',
                  hint: 'ej: Anuke o MultiLib Team',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _inputField(
                  controller: _versionController,
                  label: 'Versión',
                  hint: 'ej: 1.0.0',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _inputField(
            controller: _descController,
            label: 'Descripción de la Extensión',
            hint: 'Describe qué añade esta extensión y para qué librerías está diseñada...',
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Estado Habilitado por Defecto', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                    Text('Si está activo, sus tipos e inyecciones aparecerán en el editor.', style: TextStyle(color: Colors.white38, fontSize: 11)),
                  ],
                ),
                Switch(
                  value: _enabled,
                  activeColor: const Color(0xFF7EE787),
                  onChanged: (val) => setState(() => _enabled = val),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- PESTAÑA 2: TIPOS PERSONALIZADOS ---
  Widget _buildTypesTab() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF238636),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Añadir Tipo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: _showAddEditTypeDialog,
      ),
      body: _customTypes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.category_outlined, size: 48, color: Colors.white24),
                  const SizedBox(height: 12),
                  const Text('No hay tipos personalizados definidos en este módulo.', style: TextStyle(color: Colors.white54, fontSize: 13)),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF238636)),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('Crear Primer Tipo', style: TextStyle(color: Colors.white)),
                    onPressed: _showAddEditTypeDialog,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _customTypes.length,
              itemBuilder: (context, idx) {
                final ct = _customTypes[idx];
                final isSelected = _selectedTypeIndex == idx;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161B22),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF58A6FF) : Colors.white12,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF21262D),
                      child: Icon(
                        ct.category == CustomTypeCategory.unit ? Icons.smart_toy_outlined : Icons.view_in_ar,
                        color: const Color(0xFF58A6FF),
                        size: 18,
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(ct.displayName, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFF21262D),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            ct.category.name.toUpperCase(),
                            style: const TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      'typeId: ${ct.typeId} • ${ct.properties.length} propiedades',
                      style: const TextStyle(color: Colors.white38, fontSize: 11, fontFamily: 'monospace'),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.tune, color: Color(0xFF58A6FF), size: 18),
                          tooltip: 'Editar Propiedades',
                          onPressed: () {
                            setState(() => _selectedTypeIndex = idx);
                            _tabController.animateTo(2);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: Colors.white70, size: 18),
                          tooltip: 'Editar Tipo',
                          onPressed: () => _showAddEditTypeDialog(existingIndex: idx),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                          tooltip: 'Eliminar Tipo',
                          onPressed: () {
                            setState(() {
                              _customTypes.removeAt(idx);
                              if (_selectedTypeIndex >= _customTypes.length) {
                                _selectedTypeIndex = _customTypes.isEmpty ? 0 : _customTypes.length - 1;
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      setState(() => _selectedTypeIndex = idx);
                      _tabController.animateTo(2);
                    },
                  ),
                );
              },
            ),
    );
  }

  void _showAddEditTypeDialog({int? existingIndex}) {
    final isEdit = existingIndex != null;
    final initial = isEdit ? _customTypes[existingIndex] : null;

    final typeIdCtrl = TextEditingController(text: initial?.typeId ?? '');
    final nameCtrl = TextEditingController(text: initial?.displayName ?? '');
    CustomTypeCategory category = initial?.category ?? CustomTypeCategory.block;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF161B22),
          title: Text(
            isEdit ? 'Editar Tipo Personalizado' : 'Añadir Tipo Personalizado',
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _inputField(
                  controller: typeIdCtrl,
                  label: 'ID de Tipo (typeId)',
                  hint: 'ej: multilib-multi-crafter',
                  helper: 'Este es el valor exacto que se guardará en la clave "type" de Mindustry.',
                ),
                const SizedBox(height: 12),
                _inputField(
                  controller: nameCtrl,
                  label: 'Nombre Visible',
                  hint: 'ej: Multi Crafter (MultiLib)',
                ),
                const SizedBox(height: 12),
                const Text('Categoría de Entidad', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                DropdownButtonFormField<CustomTypeCategory>(
                  value: category,
                  dropdownColor: const Color(0xFF21262D),
                  decoration: _dialogInputDecoration(),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  items: CustomTypeCategory.values.map((c) {
                    return DropdownMenuItem(
                      value: c,
                      child: Text(c.name.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => category = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF238636)),
              onPressed: () {
                final tid = typeIdCtrl.text.trim();
                final tname = nameCtrl.text.trim();
                if (tid.isEmpty || tname.isEmpty) {
                  return;
                }
                setState(() {
                  if (isEdit) {
                    _customTypes[existingIndex] = _customTypes[existingIndex].copyWith(
                      typeId: tid,
                      displayName: tname,
                      category: category,
                    );
                  } else {
                    _customTypes.add(
                      CustomTypeSchema(
                        typeId: tid,
                        displayName: tname,
                        category: category,
                        properties: [],
                      ),
                    );
                    _selectedTypeIndex = _customTypes.length - 1;
                  }
                });
                Navigator.pop(ctx);
              },
              child: const Text('Guardar Tipo', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // --- PESTAÑA 3: CREADOR DE PROPIEDADES ---
  Widget _buildPropertiesTab() {
    if (_customTypes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, color: Colors.white38, size: 40),
            const SizedBox(height: 12),
            const Text('Primero crea un Tipo en la Pestaña "Tipos" para definir sus propiedades.', style: TextStyle(color: Colors.white54, fontSize: 13)),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF21262D)),
              onPressed: () => _tabController.animateTo(1),
              child: const Text('Ir a Tipos', style: TextStyle(color: Color(0xFF58A6FF))),
            ),
          ],
        ),
      );
    }

    if (_selectedTypeIndex >= _customTypes.length) {
      _selectedTypeIndex = 0;
    }
    final activeType = _customTypes[_selectedTypeIndex];

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF238636),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nueva Propiedad', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () => _showAddEditPropertyDialog(activeTypeIndex: _selectedTypeIndex),
      ),
      body: Column(
        children: [
          // Selector de tipo activo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFF161B22),
            child: Row(
              children: [
                const Text('Tipo activo:', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButton<int>(
                    value: _selectedTypeIndex,
                    dropdownColor: const Color(0xFF21262D),
                    isExpanded: true,
                    style: const TextStyle(color: Color(0xFF58A6FF), fontSize: 13, fontWeight: FontWeight.bold),
                    items: List.generate(_customTypes.length, (i) {
                      return DropdownMenuItem(
                        value: i,
                        child: Text('${_customTypes[i].displayName} (${_customTypes[i].typeId})'),
                      );
                    }),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedTypeIndex = val);
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: activeType.properties.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.tune_outlined, size: 44, color: Colors.white24),
                        const SizedBox(height: 10),
                        Text(
                          'El tipo "${activeType.displayName}" aún no tiene propiedades.',
                          style: const TextStyle(color: Colors.white54, fontSize: 13),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF238636)),
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: const Text('Añadir Primera Propiedad', style: TextStyle(color: Colors.white)),
                          onPressed: () => _showAddEditPropertyDialog(activeTypeIndex: _selectedTypeIndex),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: activeType.properties.length,
                    itemBuilder: (context, propIdx) {
                      final prop = activeType.properties[propIdx];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF161B22),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                          title: Row(
                            children: [
                              Text(prop.label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 6),
                              Text('(${prop.key})', style: const TextStyle(color: Colors.white38, fontSize: 11, fontFamily: 'monospace')),
                              if (prop.isRequired) ...[
                                const SizedBox(width: 4),
                                const Text('*', style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ],
                          ),
                          subtitle: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF21262D),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  prop.type.name,
                                  style: const TextStyle(color: Color(0xFF58A6FF), fontSize: 10, fontFamily: 'monospace'),
                                ),
                              ),
                              if (prop.defaultValue != null) ...[
                                const SizedBox(width: 8),
                                Text(
                                  'default: ${prop.defaultValue}',
                                  style: const TextStyle(color: Colors.white30, fontSize: 10),
                                ),
                              ],
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 16, color: Colors.white70),
                                onPressed: () => _showAddEditPropertyDialog(
                                  activeTypeIndex: _selectedTypeIndex,
                                  existingPropIndex: propIdx,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
                                onPressed: () {
                                  setState(() {
                                    final currentProps = List<PropertyDefinition>.from(activeType.properties);
                                    currentProps.removeAt(propIdx);
                                    _customTypes[_selectedTypeIndex] = activeType.copyWith(properties: currentProps);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showAddEditPropertyDialog({required int activeTypeIndex, int? existingPropIndex}) {
    final activeType = _customTypes[activeTypeIndex];
    final isEdit = existingPropIndex != null;
    final initial = isEdit ? activeType.properties[existingPropIndex] : null;

    final keyCtrl = TextEditingController(text: initial?.key ?? '');
    final labelCtrl = TextEditingController(text: initial?.label ?? '');
    final defaultCtrl = TextEditingController(text: initial?.defaultValue?.toString() ?? '');
    final optionsCtrl = TextEditingController(text: initial?.options?.join(', ') ?? '');
    final tooltipCtrl = TextEditingController(text: initial?.tooltip ?? '');
    PropertyDataType type = initial?.type ?? PropertyDataType.text;
    bool isRequired = initial?.isRequired ?? false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF161B22),
          title: Text(
            isEdit ? 'Editar Propiedad' : 'Añadir Propiedad a ${activeType.displayName}',
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          content: SizedBox(
            width: 440,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _inputField(
                    controller: keyCtrl,
                    label: 'Clave JSON (key)',
                    hint: 'ej: craftTime o outputItem',
                    helper: 'Clave exacta que se escribirá en el HJSON.',
                  ),
                  const SizedBox(height: 10),
                  _inputField(
                    controller: labelCtrl,
                    label: 'Etiqueta UI (label)',
                    hint: 'ej: Tiempo de Fabricación',
                  ),
                  const SizedBox(height: 10),
                  const Text('Tipo de Dato (PropertyDataType)', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  DropdownButtonFormField<PropertyDataType>(
                    value: type,
                    dropdownColor: const Color(0xFF21262D),
                    decoration: _dialogInputDecoration(),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    items: PropertyDataType.values.map((p) {
                      return DropdownMenuItem(
                        value: p,
                        child: Text(p.name),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => type = val);
                    },
                  ),
                  const SizedBox(height: 10),
                  _inputField(
                    controller: defaultCtrl,
                    label: 'Valor por Defecto (opcional)',
                    hint: 'ej: 60.0 o true o copper',
                  ),
                  if (type == PropertyDataType.enumDropdown) ...[
                    const SizedBox(height: 10),
                    _inputField(
                      controller: optionsCtrl,
                      label: 'Opciones de Dropdown (separadas por coma)',
                      hint: 'ej: normal, rapido, sobrecargado',
                    ),
                  ],
                  const SizedBox(height: 10),
                  _inputField(
                    controller: tooltipCtrl,
                    label: 'Tooltip explicativo (opcional)',
                    hint: 'Texto de ayuda al pasar el cursor...',
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('¿Es campo obligatorio?', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      Switch(
                        value: isRequired,
                        activeColor: const Color(0xFF58A6FF),
                        onChanged: (val) => setDialogState(() => isRequired = val),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF238636)),
              onPressed: () {
                final k = keyCtrl.text.trim();
                final l = labelCtrl.text.trim();
                if (k.isEmpty || l.isEmpty) return;

                dynamic parsedDefault;
                final rawDef = defaultCtrl.text.trim();
                if (rawDef.isNotEmpty) {
                  if (type == PropertyDataType.numberInt) {
                    parsedDefault = int.tryParse(rawDef);
                  } else if (type == PropertyDataType.numberFloat) {
                    parsedDefault = double.tryParse(rawDef);
                  } else if (type == PropertyDataType.boolean) {
                    parsedDefault = rawDef.toLowerCase() == 'true';
                  } else {
                    parsedDefault = rawDef;
                  }
                }

                List<String>? parsedOpts;
                if (type == PropertyDataType.enumDropdown && optionsCtrl.text.isNotEmpty) {
                  parsedOpts = optionsCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
                }

                final newProp = PropertyDefinition(
                  key: k,
                  label: l,
                  type: type,
                  defaultValue: parsedDefault,
                  options: parsedOpts,
                  isRequired: isRequired,
                  tooltip: tooltipCtrl.text.trim().isEmpty ? null : tooltipCtrl.text.trim(),
                );

                setState(() {
                  final props = List<PropertyDefinition>.from(activeType.properties);
                  if (isEdit) {
                    props[existingPropIndex] = newProp;
                  } else {
                    props.add(newProp);
                  }
                  _customTypes[activeTypeIndex] = activeType.copyWith(properties: props);
                });

                Navigator.pop(ctx);
              },
              child: const Text('Guardar Propiedad', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // --- PESTAÑA 4: INYECCIONES GLOBALES ---
  Widget _buildInjectionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Inyecciones a Registros Globales de Mindustry'),
          const SizedBox(height: 6),
          const Text(
            'Los elementos añadidos aquí se fusionarán automáticamente con los selectores nativos de toda la aplicación (recetas, torretas, crafters, requerimientos) sin modificar el núcleo estático.',
            style: TextStyle(color: Colors.white38, fontSize: 11),
          ),
          const SizedBox(height: 18),

          // 1. Custom Items
          _buildChipInjectionSection(
            title: 'Ítems Personalizados (Custom Items)',
            subtitle: 'Ej: purified-sand, refined-phase, titanium-alloy',
            icon: Icons.inventory_2_outlined,
            color: const Color(0xFFFFA657),
            controller: _itemInputCtrl,
            items: _customItems,
            onAdd: (val) {
              if (val.isNotEmpty && !_customItems.contains(val)) {
                setState(() => _customItems.add(val));
              }
            },
            onRemove: (idx) {
              setState(() => _customItems.removeAt(idx));
            },
          ),
          const SizedBox(height: 18),

          // 2. Custom Liquids
          _buildChipInjectionSection(
            title: 'Líquidos Personalizados (Custom Liquids)',
            subtitle: 'Ej: heavy-oil, super-cryo, molten-phase',
            icon: Icons.water_drop_outlined,
            color: const Color(0xFF79C0FF),
            controller: _liquidInputCtrl,
            items: _customLiquids,
            onAdd: (val) {
              if (val.isNotEmpty && !_customLiquids.contains(val)) {
                setState(() => _customLiquids.add(val));
              }
            },
            onRemove: (idx) {
              setState(() => _customLiquids.removeAt(idx));
            },
          ),
          const SizedBox(height: 18),

          // 3. Custom Categories
          _buildChipInjectionSection(
            title: 'Categorías de Bloques (Custom Categories)',
            subtitle: 'Ej: multilib-crafting, nuclear-tech, logistics-v2',
            icon: Icons.grid_view_outlined,
            color: const Color(0xFFD2A8FF),
            controller: _categoryInputCtrl,
            items: _customCategories,
            onAdd: (val) {
              if (val.isNotEmpty && !_customCategories.contains(val)) {
                setState(() => _customCategories.add(val));
              }
            },
            onRemove: (idx) {
              setState(() => _customCategories.removeAt(idx));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChipInjectionSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required TextEditingController controller,
    required List<String> items,
    required ValueChanged<String> onAdd,
    required ValueChanged<int> onRemove,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 11)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace'),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Nuevo identificador...',
                    hintStyle: const TextStyle(color: Colors.white24, fontSize: 11),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    filled: true,
                    fillColor: const Color(0xFF21262D),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  onFieldSubmitted: (v) {
                    final t = v.trim();
                    if (t.isNotEmpty) {
                      onAdd(t);
                      controller.clear();
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: color.withValues(alpha: 0.2),
                  foregroundColor: color,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                icon: const Icon(Icons.add, size: 14),
                label: const Text('Añadir', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                onPressed: () {
                  final t = controller.text.trim();
                  if (t.isNotEmpty) {
                    onAdd(t);
                    controller.clear();
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (items.isEmpty)
            const Text('Ningún elemento inyectado todavía.', style: TextStyle(color: Colors.white24, fontSize: 11, fontStyle: FontStyle.italic))
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: List.generate(items.length, (i) {
                return Chip(
                  backgroundColor: const Color(0xFF21262D),
                  side: BorderSide(color: color.withValues(alpha: 0.4)),
                  label: Text(items[i], style: TextStyle(color: color, fontSize: 11, fontFamily: 'monospace')),
                  deleteIcon: const Icon(Icons.close, size: 14, color: Colors.white54),
                  onDeleted: () => onRemove(i),
                );
              }),
            ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(color: Color(0xFF58A6FF), fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.3),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? helper,
    bool enabled = true,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          enabled: enabled,
          maxLines: maxLines,
          style: TextStyle(color: enabled ? Colors.white : Colors.white38, fontSize: 12),
          decoration: InputDecoration(
            isDense: true,
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24, fontSize: 11),
            helperText: helper,
            helperStyle: const TextStyle(color: Colors.white30, fontSize: 10),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            filled: true,
            fillColor: enabled ? const Color(0xFF161B22) : const Color(0xFF0F1318),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Colors.white12)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Colors.white12)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFF58A6FF))),
          ),
        ),
      ],
    );
  }

  InputDecoration _dialogInputDecoration() {
    return InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      filled: true,
      fillColor: const Color(0xFF21262D),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Colors.white10)),
    );
  }
}
