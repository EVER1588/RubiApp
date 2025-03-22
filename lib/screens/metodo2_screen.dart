// metodo2_screen.dart
import 'package:flutter/material.dart';
import 'metodo2teclado_screen.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../constants/constants.dart';
import 'package:uuid/uuid.dart'; // Importar paquete para generar UUID

class Metodo2Screen extends StatefulWidget {
  const Metodo2Screen({Key? key}) : super(key: key);

  @override
  _Metodo2ScreenState createState() => _Metodo2ScreenState();
}

class _Metodo2ScreenState extends State<Metodo2Screen> {
  final FlutterTts flutterTts = FlutterTts();
  String _letraSeleccionada = "";
  final List<Bloque> elementosArrastradosContenedor1 = [];
  final List<Bloque> elementosArrastradosContenedor2 = [];

  void _eliminarElemento(String id) {
    setState(() {
      elementosArrastradosContenedor1.removeWhere((bloque) => bloque.id == id);
      elementosArrastradosContenedor2.removeWhere((bloque) => bloque.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: Text('Método 2')),
      body: Column(
        children: [
          // Contenedor 1 (Azul)
          Expanded(
            flex: 1,
            child: DragTarget<String>(
              builder: (context, candidateData, rejectedData) {
                return _buildContainer(screenWidth, screenHeight, Colors.blue.withOpacity(0.3), elementosArrastradosContenedor1);
              },
              onWillAccept: (data) {
                return silabasEspeciales.contains(data);
              },
              onAccept: (data) {
                setState(() {
                  elementosArrastradosContenedor1.add(Bloque(contenido: data));
                });
              },
            ),
          ),
          // Contenedor 2 (Verde)
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                DragTarget<String>(
                  builder: (context, candidateData, rejectedData) {
                    return _buildContainer(screenWidth, screenHeight, Colors.green.withOpacity(0.3), elementosArrastradosContenedor2);
                  },
                  onWillAccept: (data) {
                    return true;
                  },
                  onAccept: (data) {
                    setState(() {
                      elementosArrastradosContenedor2.add(Bloque(contenido: data));
                    });
                  },
                ),
                Positioned(
                  bottom: screenHeight * 0.025,
                  right: screenWidth * 0.06,
                  child: DragTarget<String>(
                    builder: (context, candidateData, rejectedData) {
                      return SizedBox(
                        width: screenWidth * 0.18,
                        height: screenHeight * 0.08,
                        child: FloatingActionButton(
                          onPressed: () {},
                          backgroundColor: Colors.red,
                          child: Icon(Icons.delete, size: 50, color: Colors.white),
                        ),
                      );
                    },
                    onAccept: (data) {
                      _eliminarElemento(data);
                    },
                  ),
                ),
              ],
            ),
          ),
          // Teclado Principal y Secundario
          Expanded(
            flex: 3,
            child: Metodo2Teclado(
              onLetterPressed: (letra) {
                setState(() {
                  _letraSeleccionada = letra;
                });
              },
              letraSeleccionada: _letraSeleccionada,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContainer(double width, double height, Color color, List<Bloque> bloques) {
    return Container(
      width: width * 0.95,
      margin: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: height * 0.02),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
      child: Center(
        child: Wrap(
          spacing: 8.0,
          children: bloques.map((bloque) {
            final esEspecial = silabasEspeciales.contains(bloque.contenido);
            final esInicioDePalabra = iniciosDePalabrasValidas.contains(bloque.contenido) ||
                iniciosDePalabras3Silabas.contains(bloque.contenido) ||
                iniciosDePalabras4Silabas.contains(bloque.contenido);
            final esPalabraValida = palabrasValidas.contains(bloque.contenido);

            return Draggable<String>(
              data: bloque.id, // Pasar el ID único del bloque
              feedback: Material(
                child: Chip(
                  label: Text(
                    bloque.contenido,
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  backgroundColor: esPalabraValida
                      ? Colors.green
                      : esInicioDePalabra
                          ? Colors.orange
                          : esEspecial
                              ? Colors.green
                              : Colors.blue,
                ),
              ),
              childWhenDragging: Opacity(
                opacity: 0.5,
                child: Chip(
                  label: Text(
                    bloque.contenido,
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  backgroundColor: esPalabraValida
                      ? Colors.green
                      : esInicioDePalabra
                          ? Colors.orange
                          : esEspecial
                              ? Colors.green
                              : Colors.blue,
                ),
              ),
              child: Chip(
                label: Text(
                  bloque.contenido,
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                backgroundColor: esPalabraValida
                    ? Colors.green
                    : esInicioDePalabra
                        ? Colors.orange
                        : esEspecial
                            ? Colors.green
                            : Colors.blue,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// Clase Bloque
class Bloque {
  final String id; // Identificador único
  final String contenido; // Contenido del bloque (por ejemplo, "AL")

  Bloque({required this.contenido})
      : id = const Uuid().v4(); // Generar un UUID único para cada bloque
}