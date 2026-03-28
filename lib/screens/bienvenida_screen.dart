import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'menu_screen.dart';
import '../constants/custombar_screen.dart';
import '../services/tts_manager.dart';
import '../services/music_manager.dart';

class BienvenidaScreen extends StatefulWidget {
  const BienvenidaScreen({Key? key}) : super(key: key);

  @override
  State<BienvenidaScreen> createState() => _BienvenidaScreenState();
}

class _BienvenidaScreenState extends State<BienvenidaScreen> {

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: CustomBar(
        onBackPressed: () {
          Navigator.pop(context);
        },
        onSettingsPressed: () => mostrarAjustesGlobales(context),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Contenido principal
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Hola',
                      style: TextStyle(
                        fontSize: screenHeight * 0.08, // Tamaño relativo al alto
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    Text(
                      'Aprendamos a leer',
                      style: TextStyle(
                        fontSize: screenHeight * 0.04, // Tamaño relativo al alto
                        color: Colors.deepPurple[800],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.1), // Espaciado relativo
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MenuScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: EdgeInsets.symmetric(
                          horizontal: isLandscape ? screenWidth * 0.15 : screenWidth * 0.1, // Más ancho en horizontal
                          vertical: isLandscape ? screenHeight * 0.04 : screenHeight * 0.02, // Más alto en horizontal
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        'Comencemos',
                        style: TextStyle(
                          fontSize: isLandscape ? screenHeight * 0.05 : screenHeight * 0.03, // Más grande en horizontal
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}