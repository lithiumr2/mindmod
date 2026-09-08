import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/project_provider.dart';

class CodeEditorWidget extends ConsumerStatefulWidget {
  const CodeEditorWidget({super.key});

  @override
  ConsumerState<CodeEditorWidget> createState() => _CodeEditorWidgetState();
}

class _CodeEditorWidgetState extends ConsumerState<CodeEditorWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeFile = ref.watch(projectProvider).activeFile;
    if (activeFile != null && _controller.text != activeFile.content) {
      _controller.text = activeFile.content;
    }

    return Container(
      color: const Color(0xFF18181C),
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _controller,
        maxLines: null,
        expands: true,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 14,
          color: Color(0xFFA6E22E),
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
        ),
        onChanged: (val) {
          ref.read(projectProvider.notifier).updateActiveFileContent(val);
        },
      ),
    );
  }
}
