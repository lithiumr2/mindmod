import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart' as fp;
import '../models/module_schema.dart';
import '../providers/module_registry_provider.dart';
import '../services/module_archive_service.dart';
import '../services/storage_service.dart';
import 'module_editor_screen.dart';

/// Pantalla de gestión e inventario de Módulos y Extensiones
class ModuleManagementScreen extends ConsumerStatefulWidget {
  const ModuleManagementScreen({super.key});

  @override
  ConsumerState<ModuleManagementScreen> createState() => _ModuleManagementScreenState();
}

class _ModuleManagementScreenState extends ConsumerState<ModuleManagementScreen> {
  bool _isProcessing = false;

  Future<void> _importZip() async {
    setState(() => _isProcessing = true);
    try {
      final result = await fp.FilePicker.platform.pickFiles(
        type: fp.FileType.custom,
        allowedExtensions: ['zip', 'mmodpkg'],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        final bytes = result.files.single.bytes!;
        final module = ModuleArchiveService.importModuleFromZip(bytes);

        await ref.read(moduleRegistryProvider.notifier).importModule(module);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF238636),
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Módulo "${module.name}" (v${module.version}) importado con éxito.'),
                  ),
                ],
              ),
            ),
          );
        }
      }
    } on ModuleArchiveException catch (mae) {
      if (mounted) {
        _showErrorDialog('Error de Validación en el Módulo', mae.message);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Fallo al importar', 'Ocurrió un error inesperado al leer el archivo: $e');
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _exportZip(CustomModule module) async {
    setState(() => _isProcessing = true);
    try {
      final bytes = ModuleArchiveService.exportModuleToZip(module);
      final fileName = '${module.id}_v${module.version}.zip';

      final savedPath = await StorageService.saveExportedFile(fileName, bytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF1F6FEB),
            content: Text(
              savedPath != null
                  ? 'Módulo exportado en: $savedPath'
                  : 'Módulo exportado con éxito como $fileName',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Error de Exportación', 'No se pudo exportar el módulo: $e');
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _confirmDelete(CustomModule module) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF21262D),
        title: const Text('¿Eliminar módulo?', style: TextStyle(color: Colors.white)),
        content: Text(
          '¿Estás seguro de que deseas eliminar el módulo "${module.name}"? Los esquemas y tipos personalizados que provee dejarán de estar disponibles.',
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(moduleRegistryProvider.notifier).deleteModule(module.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Módulo "${module.name}" eliminado.')),
              );
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF21262D),
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
        content: Text(message, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Entendido', style: TextStyle(color: Color(0xFF58A6FF))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final modules = ref.watch(moduleRegistryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Módulos y Plugins de Extensión',
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Text(
              'Motor dinámico de esquemas UI y registros sin recompilar',
              style: TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ],
        ),
        actions: [
          if (_isProcessing)
            const Padding(
              padding: EdgeInsets.all(14.0),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF58A6FF)),
              ),
            )
          else ...[
            TextButton.icon(
              icon: const Icon(Icons.file_upload_outlined, size: 16, color: Color(0xFF7EE787)),
              label: const Text('Importar .ZIP', style: TextStyle(color: Color(0xFF7EE787), fontSize: 12)),
              onPressed: _importZip,
            ),
            const SizedBox(width: 6),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF238636),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                icon: const Icon(Icons.add, size: 16, color: Colors.white),
                label: const Text('Nuevo Módulo', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ModuleEditorScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
      body: modules.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.extension_off_outlined, size: 54, color: Colors.white24),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay módulos de extensión instalados',
                    style: TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const SizedBox(
                    width: 360,
                    child: Text(
                      'Crea tu propio módulo o importa un archivo .zip para incorporar bibliotecas de mods (como MultiLib), nuevos tipos de bloques/unidades y nuevos ítems.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF238636)),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('Crear Primer Módulo', style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ModuleEditorScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: modules.length,
              itemBuilder: (context, index) {
                final module = modules[index];
                return _buildModuleCard(module);
              },
            ),
    );
  }

  Widget _buildModuleCard(CustomModule module) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: module.enabled ? const Color(0xFF388BFD).withValues(alpha: 0.4) : Colors.white12,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.extension,
                  color: module.enabled ? const Color(0xFF58A6FF) : Colors.white30,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              module.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF21262D),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: Text(
                              'v${module.version}',
                              style: const TextStyle(color: Colors.white54, fontSize: 10, fontFamily: 'monospace'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ID: ${module.id} • Por ${module.author}',
                        style: const TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                // Switch On/Off
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      module.enabled ? 'ACTIVO' : 'INACTIVO',
                      style: TextStyle(
                        color: module.enabled ? const Color(0xFF7EE787) : Colors.white30,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Switch(
                      value: module.enabled,
                      activeColor: const Color(0xFF7EE787),
                      onChanged: (val) {
                        ref.read(moduleRegistryProvider.notifier).toggleModule(module.id);
                      },
                    ),
                  ],
                ),
              ],
            ),
            if (module.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                module.description,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
            const SizedBox(height: 12),
            // Chips de información del módulo
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                _infoChip(
                  Icons.category_outlined,
                  '${module.customTypes.length} Tipos Dinámicos',
                  const Color(0xFF58A6FF),
                ),
                if (module.globalInjections.customItems.isNotEmpty)
                  _infoChip(
                    Icons.inventory_2_outlined,
                    '+${module.globalInjections.customItems.length} Ítems',
                    const Color(0xFFFFA657),
                  ),
                if (module.globalInjections.customLiquids.isNotEmpty)
                  _infoChip(
                    Icons.water_drop_outlined,
                    '+${module.globalInjections.customLiquids.length} Líquidos',
                    const Color(0xFF79C0FF),
                  ),
                if (module.globalInjections.customCategories.isNotEmpty)
                  _infoChip(
                    Icons.grid_view_outlined,
                    '+${module.globalInjections.customCategories.length} Categorías',
                    const Color(0xFFD2A8FF),
                  ),
              ],
            ),
            const Divider(color: Colors.white10, height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white24),
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(Icons.download_outlined, size: 14),
                  label: const Text('Exportar ZIP', style: TextStyle(fontSize: 11)),
                  onPressed: () => _exportZip(module),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF21262D),
                    foregroundColor: const Color(0xFF58A6FF),
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 14),
                  label: const Text('Editar', style: TextStyle(fontSize: 11)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ModuleEditorScreen(module: module),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                  tooltip: 'Eliminar módulo',
                  onPressed: () => _confirmDelete(module),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
