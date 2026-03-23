import 'package:flutter/material.dart';
import 'aprendesilabas_screen.dart';
import 'formandopalabras_screen.dart';
import 'metodo3_screen.dart';
import 'bienvenida_screen.dart';
import '../constants/custombar_screen.dart';

class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  // Caché de pantallas para preservar estado
  Metodo1Screen? _metodo1;
  Metodo3Screen? _metodo3;
  Metodo2Screen? _metodo2;

  void _abrirPantalla(Widget Function() crear, Widget? cached, void Function(dynamic) setCached) {
    if (cached == null) {
      cached = crear();
      setCached(cached);
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => cached!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomBar(
        onBackPressed: () {
          Navigator.pop(context);
        },
        onSettingsPressed: () => mostrarAjustesGlobales(context),
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
                  'lib/utils/images/escuela.jpeg',
                  () {
                    _metodo1 ??= Metodo1Screen();
                    Navigator.push(context, MaterialPageRoute(builder: (_) => _metodo1!));
                  },
                ),
                SizedBox(height: 20),
                _buildBotonMetodo(
                  context,
                  'Describe la Imagen',
                  Colors.teal,
                  'lib/utils/images/animales.jpeg',
                  () {
                    _metodo3 ??= Metodo3Screen();
                    Navigator.push(context, MaterialPageRoute(builder: (_) => _metodo3!));
                  },
                ),
                SizedBox(height: 20),
                _buildBotonMetodo(
                  context,
                  'Formando Palabras',
                  Colors.deepOrange,
                  'lib/utils/images/familia.jpeg',
                  () {
                    _metodo2 ??= Metodo2Screen();
                    Navigator.push(context, MaterialPageRoute(builder: (_) => _metodo2!));
                  },
                ),
              ],
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
    String imagePath,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.85,
      height: 120,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.4), blurRadius: 10, offset: Offset(0, 5)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: color),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        color.withOpacity(0.85),
                        color.withOpacity(0.4),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    texto,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(blurRadius: 6, color: Colors.black54, offset: Offset(1, 2)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}