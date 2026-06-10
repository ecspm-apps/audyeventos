import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/inicio_inmersivo_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: 'AUDY Eventos',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFADC6FF),
        scaffoldBackgroundColor: const Color(0xFF131313),
        useMaterial3: true,
      ),
      home: const InicioInmersivoScreen(hasEvents: true),
    );
  }
}
