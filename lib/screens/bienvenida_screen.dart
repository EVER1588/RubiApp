import 'package:flutter/material.dart';
import 'menu_screen.dart';

class BienvenidaScreen extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;

  BienvenidaScreen({required this.screenWidth, required this.screenHeight});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[100],
      body: SafeArea(
        child: Column(
          children: [
            // Barra de navegación
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.deepPurple),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.more_vert, color: Colors.deepPurple),
                    onPressed: () {
                      _showOptionsDialog(context);
                    },
                  ),
                ],
              ),
            ),
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
                          horizontal: screenWidth * 0.1, // Ancho relativo
                          vertical: screenHeight * 0.02, // Alto relativo
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        'Comencemos',
                        style: TextStyle(
                          fontSize: screenHeight * 0.03, // Tamaño relativo
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

  void _showOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Opciones'),
        content: Text('Aquí van las opciones'),
      ),
    );
  }
}