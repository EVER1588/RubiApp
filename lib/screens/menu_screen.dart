import 'package:flutter/material.dart';
import 'aprendesilabas_screen.dart';
import 'formandopalabras_screen.dart';
import 'describe_la_imagen.dart';
import 'bienvenida_screen.dart';
import '../constants/custombar_screen.dart';
import '../services/music_manager.dart';
import '../modo_historia/mapa_historia_screen.dart';

class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  // Caché de pantallas para preservar estado
  Metodo1Screen? _metodo1;
  Metodo3Screen? _metodo3;
  Metodo2Screen? _metodo2;
  MapaHistoriaScreen? _modoHistoria;

  @override
  void initState() {
    super.initState();
    MusicManager.instance.playForScreen(MusicManager.trackHome);
  }

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
        onSettingsPressed: () => mostrarAjustesGlobales(context),
      ),
      body: Stack(
        children: [
          Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
                // Ajustar altura según orientación
                final buttonHeight = isLandscape ? 85.0 : 120.0;
                final spaceBetween = isLandscape ? 12.0 : 20.0;
                
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ── Modo Historia: botón destacado ──
                    _buildBotonModoHistoria(context, isLandscape ? 100.0 : 140.0),
                    SizedBox(height: spaceBetween),
                    _buildBotonMetodo(
                      context,
                      'Aprende Sílabas',
                      Colors.deepPurple,
                      'lib/utils/images/escuela.jpeg',
                      () {
                        MusicManager.instance.playForScreen(MusicManager.trackSilabas);
                        _metodo1 ??= Metodo1Screen();
                        Navigator.push(context, MaterialPageRoute(builder: (_) => _metodo1!)).then((_) {
                          MusicManager.instance.playForScreen(MusicManager.trackHome);
                        });
                      },
                      buttonHeight,
                    ),
                    SizedBox(height: spaceBetween),
                    _buildBotonMetodo(
                      context,
                      'Describe la Imagen',
                      Colors.teal,
                      'lib/utils/images/animales.jpeg',
                      () {
                        _metodo3 ??= Metodo3Screen();
                        Navigator.push(context, MaterialPageRoute(builder: (_) => _metodo3!)).then((_) {
                          MusicManager.instance.playForScreen(MusicManager.trackHome);
                        });
                      },
                      buttonHeight,
                    ),
                    SizedBox(height: spaceBetween),
                    _buildBotonMetodo(
                      context,
                      'Formando Palabras',
                      Colors.deepOrange,
                      'lib/utils/images/familia.jpeg',
                      () {
                        MusicManager.instance.playForScreen(MusicManager.trackPalabras);
                        _metodo2 ??= Metodo2Screen();
                        Navigator.push(context, MaterialPageRoute(builder: (_) => _metodo2!)).then((_) {
                          MusicManager.instance.playForScreen(MusicManager.trackHome);
                        });
                      },
                      buttonHeight,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotonModoHistoria(BuildContext context, double buttonHeight) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final buttonWidth = isLandscape
        ? MediaQuery.of(context).size.width * 0.60
        : MediaQuery.of(context).size.width * 0.90;

    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: GestureDetector(
        onTap: () {
          _modoHistoria ??= const MapaHistoriaScreen();
          Navigator.push(context, MaterialPageRoute(builder: (_) => _modoHistoria!)).then((_) {
            MusicManager.instance.playForScreen(MusicManager.trackHome);
          });
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF7C4DFF), Color(0xFFE040FB)],
            ),
            boxShadow: [
              BoxShadow(color: const Color(0xFF7C4DFF).withOpacity(0.5), blurRadius: 14, offset: const Offset(0, 6)),
            ],
          ),
          child: Stack(
            children: [
              // Decoración de estrellas
              const Positioned(top: 10, left: 16, child: Text('⭐', style: TextStyle(fontSize: 18))),
              const Positioned(bottom: 10, right: 16, child: Text('🗺️', style: TextStyle(fontSize: 22))),
              const Positioned(top: 8, right: 50, child: Text('✨', style: TextStyle(fontSize: 14))),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'El Viaje de Rubí',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [Shadow(blurRadius: 8, color: Colors.black45, offset: Offset(1, 2))],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Aprende el abecedario paso a paso',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBotonMetodo(
    BuildContext context,
    String texto,
    Color color,
    String imagePath,
    VoidCallback onPressed,
    double buttonHeight,
  ) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final buttonWidth = isLandscape 
        ? MediaQuery.of(context).size.width * 0.55  // Reducir a 55% en landscape
        : MediaQuery.of(context).size.width * 0.85;  // Mantener 85% en portrait
    
    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
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