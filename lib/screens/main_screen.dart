import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/project_file.dart';
import '../providers/project_provider.dart';
import '../providers/locale_provider.dart';
import '../services/export_service.dart';
import '../widgets/code_editor_widget.dart';
import '../widgets/visual_form_widget.dart';
import '../widgets/mod_json_form_widget.dart';
import '../widgets/sidebar_widget.dart';

import '../services/hjson_engine.dart';


  void _analyzeMod(BuildContext context, WidgetRef ref) {
    final tr = ref.read(localeProvider.notifier).tr;
    final files = ref.read(projectProvider).files;
    List<String> errors = [];
    List<String> warnings = [];

    // Check mod.json
    final modJson = files.any((f) => f.name == 'mod.json' || f.name == 'mod.hjson');
    if (!modJson) {
      errors.add(tr('err_missing_mod_json'));
    }

    for (var file in files) {
      if (file.isImage) continue;

      // Validate HJSON syntax
      if (file.name.endsWith('.hjson') || file.name.endsWith('.json')) {
         final syntaxErrors = HjsonEngine.validateSyntax(file.content);
         if (syntaxErrors.isNotEmpty) {
           errors.add('${tr('err_syntax_in')} ${file.name}: ${syntaxErrors.first}');
         }
         
         // Parse to check semantics
         try {
           final parsed = HjsonEngine.parse(file.content);
           if (file.type == FileType.block || file.type == FileType.item || file.type == FileType.unit || file.type == FileType.liquid) {
             if (!parsed.containsKey('name')) {
               warnings.add('${file.name}: ${tr('warn_missing_name')}');
             }
             if (file.type == FileType.block && !parsed.containsKey('type')) {
               warnings.add('${file.name}: ${tr('warn_block_no_type')}');
             }
             if (file.type == FileType.block && !parsed.containsKey('requirements')) {
               warnings.add('${file.name}: ${tr('warn_block_no_reqs')}');
             }
           }
         } catch(e) {}
      }

      // Check Sprites for blocks/items
      if (file.type == FileType.block || file.type == FileType.item) {
         final baseName = file.name.replaceAll('.hjson', '').replaceAll('.json', '');
         final hasSprite = files.any((f) => f.isImage && (f.name == '${baseName}.png' || f.name == 'sprites/${baseName}.png'));
         if (!hasSprite) {
           warnings.add('${tr('warn_missing_sprite')} ${file.name}. (${tr('needed')} ${baseName}.png)');
         }
      }
    }

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E24),
        title: Text(tr('analysis_title'), style: const TextStyle(color: Colors.white)),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (errors.isEmpty && warnings.isEmpty)
                  Text(tr('analysis_ok'), style: const TextStyle(color: Colors.greenAccent)),
                
                if (errors.isNotEmpty) ...[
                  Text(tr('analysis_critical'), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...errors.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Icon(Icons.error_outline, color: Colors.redAccent, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(e, style: const TextStyle(color: Colors.white70, fontSize: 13))),
                    ]),
                  )),
                  const SizedBox(height: 16),
                ],

                if (warnings.isNotEmpty) ...[
                  Text(tr('analysis_warnings'), style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...warnings.map((w) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(w, style: const TextStyle(color: Colors.white70, fontSize: 13))),
                    ]),
                  )),
                ]
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: Text(tr('close'), style: const TextStyle(color: Colors.white))),
        ],
      ),
    );
  }


class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  String tr(String key) => ref.read(localeProvider.notifier).tr(key);
  bool _isCodeView = false;

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    final projectState = ref.watch(projectProvider);
    final activeFile = projectState.activeFile;
    final isModJson = activeFile?.name == 'mod.json';

    final topBar = Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: const Color(0xFF18181C),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            activeFile != null ? '${activeFile.name.replaceAll(".hjson", "")}' : tr('select_file_header'),
            style: const TextStyle(color: Colors.amber, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          Row(
            children: [
              if (activeFile != null && !activeFile.isImage && activeFile.type != FileType.script)
                ToggleButtons(
                  isSelected: [!_isCodeView, _isCodeView],
                  onPressed: (index) => setState(() => _isCodeView = index == 1),
                  color: Colors.white54,
                  selectedColor: Colors.black,
                  fillColor: const Color(0xFFFBC02D),
                  constraints: const BoxConstraints(minHeight: 32, minWidth: 50),
                  children: const [
                    Icon(Icons.edit, size: 16),
                    Icon(Icons.code, size: 16),
                  ],
                ),
              ElevatedButton.icon(
                    onPressed: () => _analyzeMod(context, ref),
                    icon: const Icon(Icons.bug_report_outlined, size: 16),
                    label: Text(ref.read(localeProvider.notifier).tr('analyze_mod')),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF222228), foregroundColor: Colors.amber, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  ),
                  const SizedBox(width: 12),
                  PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white70),
                color: const Color(0xFF202026),
                onSelected: (value) async {
                  if (value == 'export_zip') {
                    final path = await ExportService.exportModToZip(projectState.files);
                    if (context.mounted && path != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${tr('mod_exported_to')} $path')),
                      );
                    }
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'export_zip',
                    child: Row(
                      children: [
                        Icon(Icons.download, color: Color(0xFFFBC02D), size: 18),
                        SizedBox(width: 10),
                        Text(tr('export_zip'), style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF18181C),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Row(
          children: [
            const SidebarWidget(),
            Expanded(
              child: Column(
                children: [
                  topBar,
                  Expanded(
                    child: activeFile == null
                        ? Center(child: Text(tr('select_or_create'), style: const TextStyle(color: Colors.white54)))
                        : activeFile.isImage
                            ? 
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    constraints: const BoxConstraints(maxHeight: 300, maxWidth: 300),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white24, width: 2),
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.black26,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Image.memory(activeFile.binaryContent ?? Uint8List(0), fit: BoxFit.contain, filterQuality: FilterQuality.none, errorBuilder: (c,e,s) => Text(tr('img_error'), style: const TextStyle(color: Colors.red))),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Container(
                                    width: 350,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF222228),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.white12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(tr('sprite_config'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Text(tr('linked_to'), style: const TextStyle(color: Colors.white70)),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: TextFormField(
                                                initialValue: activeFile.name.replaceAll('.png', '').replaceAll('sprites/', ''),
                                                style: const TextStyle(color: Colors.amber),
                                                decoration: const InputDecoration(
                                                  isDense: true,
                                                  suffixText: '.png',
                                                  suffixStyle: TextStyle(color: Colors.white54),
                                                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                                                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
                                                ),
                                                onFieldSubmitted: (val) {
                                                  if (val.trim().isNotEmpty) {
                                                    ref.read(projectProvider.notifier).renameFile(activeFile.name, val.trim() + '.png');
                                                  }
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Icon(Icons.info_outline, color: Colors.blueAccent, size: 16),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  tr('sprite_info_tip'),
                                                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              )
                            )

                            : isModJson
                                ? (_isCodeView ? const CodeEditorWidget() : const ModJsonFormWidget())
                                : (activeFile.type == FileType.script || _isCodeView ? const CodeEditorWidget() : const VisualFormWidget()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
