import 'package:flutter/material.dart';
import 'metodo1_screen.dart';
import 'metodo2_screen.dart';
import 'metodo3_screen.dart';
import 'configuracion_screen.dart';
import '../constants/custombar_screen.dart'; // Importa el nuevo CustomBar

class MenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomBar(
        
        onBackPressed: () {
          Navigator.pop(context); // Acción al presionar el botón de retroceso
        },
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildBotonMetodo(
                  context,
                  'Aprende Sílabas',
                  Colors.deepPurple,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Metodo1Screen(),
                      ),
                    );
                  },
                ),
                SizedBox(height: 20),
                _buildBotonMetodo(
                  context,
                  'Describe la Imagen',
                  Colors.teal,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Metodo3Screen(),
                      ),
                    );
                  },
                ),
                SizedBox(height: 20),
                _buildBotonMetodo(
                  context,
                  'Formando Palabras',
                  Colors.deepOrange,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Metodo2Screen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Positioned(
            right: 20,
            bottom: 20,
            child: _buildBotonInferior(
              Icons.settings,
              Colors.grey,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConfiguracionScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotonMetodo(
    BuildContext context,
    String texto,
    Color color,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height: 80,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          texto,
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildBotonInferior(IconData icon, Color color, VoidCallback onPressed) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: color,
      child: Icon(icon, color: Colors.white),
    );
  }
}
