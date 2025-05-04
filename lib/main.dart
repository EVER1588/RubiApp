import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Importa SystemChrome
import 'screens/bienvenida_screen.dart'; // Importa la pantalla inicial
import 'constants/state_manager.dart'; // Agregar esta importación
import 'services/tts_manager.dart'; // Importa TtsManager

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar TtsManager
  final ttsManager = TtsManager();
  await ttsManager.initialize();
  
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Agregar el observador
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Eliminar el observador
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Forzar el modo de pantalla completa al volver a la app
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aprender a Leer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Builder(
        builder: (context) {
          // Calcular el ancho y alto de la pantalla
          final screenWidth = MediaQuery.of(context).size.width;
          final screenHeight = MediaQuery.of(context).size.height;

          // Pasar los valores a BienvenidaScreen
          return BienvenidaScreen(
            screenWidth: screenWidth,
            screenHeight: screenHeight,
          );
        },
      ),
    );
  }
}