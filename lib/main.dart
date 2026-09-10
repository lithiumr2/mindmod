import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/main_screen.dart';

void main()
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart'; // O el archivo donde definas tu StatelessWidget principal (MyApp)

void main() async {
  // 1. Obligatorio para asegurar los enlaces de Flutter antes de llamadas nativas
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Bloquea la orientación de la pantalla exclusivamente en horizontal (Landscape)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // 3. Inicia la aplicación con ProviderScope para el manejo de estados
  runApp(const ProviderScope(child: MyApp()));
}
{
  runApp(
    const ProviderScope(
      child: MindmodApp(),
    ),
  );
}

class MindmodApp extends StatelessWidget {
  const MindmodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mindmod IDE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF18181C),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFBC02D),
          surface: Color(0xFF202026),
        ),
      ),
      home: const MainScreen(),
    );
  }
}
