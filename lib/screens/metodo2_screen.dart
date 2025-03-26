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
  final double blockWidth = 60.0;  // Ancho estándar del bloque
  final double blockHeight = 40.0; // Alto estándar del bloque
  final double blockSpacing = 8.0; // Espacio entre bloques

  void _eliminarElemento(String id) {
    setState(() {
      elementosArrastradosContenedor1.removeWhere((bloque) => bloque.id == id);
      elementosArrastradosContenedor2.removeWhere((bloque) => bloque.id == id);
    });
  }

  Future<void> _procesarConcatenacion(Bloque bloqueBase, String contenidoNuevo, int indexBase) async {
    final resultadoConcatenacion = bloqueBase.contenido + contenidoNuevo;

    // 1. Verificar si forma una palabra válida
    if (palabrasValidas.contains(resultadoConcatenacion)) {
      setState(() {
        // Crear nuevo bloque verde
        elementosArrastradosContenedor2[indexBase] = Bloque(
          contenido: resultadoConcatenacion,
          color: Colors.green,
          posicion: bloqueBase.posicion,
        );
        // Eliminar el bloque arrastrado por su ID
        elementosArrastradosContenedor2.removeWhere(
          (b) => b.contenido == contenidoNuevo && b.id != bloqueBase.id
        );
      });
      return;
    }

    // 2. Si no forma palabra válida, mostrar en rojo y separar
    setState(() {
      elementosArrastradosContenedor2[indexBase] = Bloque(
        contenido: resultadoConcatenacion,
        color: Colors.red,
        posicion: bloqueBase.posicion,
      );
    });

    await Future.delayed(const Duration(seconds: 2));

    // 3. Restaurar estado original
    setState(() {
      elementosArrastradosContenedor2[indexBase] = bloqueBase;
    });
  }

  Offset _calcularNuevaPosicion() {
    if (elementosArrastradosContenedor2.isEmpty) {
      return Offset(8.0, 8.0); // Margen inicial
    }

    // Ordenar bloques por posición
    final bloques = [...elementosArrastradosContenedor2];
    bloques.sort((a, b) {
      if (a.posicion.dy == b.posicion.dy) {
        return a.posicion.dx.compareTo(b.posicion.dx);
      }
      return a.posicion.dy.compareTo(b.posicion.dy);
    });

    final ultimoBloque = bloques.last;
    final nextX = ultimoBloque.posicion.dx + blockWidth + blockSpacing;
    final containerWidth = MediaQuery.of(context).size.width * 0.95;

    // Si hay espacio en la línea actual
    if (nextX + blockWidth < containerWidth) {
      return Offset(nextX, ultimoBloque.posicion.dy);
    }
    
    // Si no hay espacio, comenzar nueva línea
    return Offset(8.0, ultimoBloque.posicion.dy + blockHeight + blockSpacing);
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
                  elementosArrastradosContenedor1.add(Bloque(contenido: data, posicion: Offset.zero));
                });
              },
            ),
          ),
          // Contenedor 2 (Verde)
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                DragTarget<Map<String, String>>(
                  builder: (context, candidateData, rejectedData) {
                    return _buildContainer(screenWidth, screenHeight, Colors.green.withOpacity(0.3), elementosArrastradosContenedor2);
                  },
                  onWillAccept: (data) => true,
                  onAcceptWithDetails: (details) {
                    final contenidoArrastrado = details.data['contenido']!;
                    final idArrastrado = details.data['id']!;
                    // Buscar si hay un bloque exactamente en la posición donde se soltó
                    final indexBase = _buscarIndicePorPosicion(details.offset);

                    if (indexBase != null) {
                      // Si se soltó sobre otro bloque, intentar concatenar
                      final bloqueBase = elementosArrastradosContenedor2[indexBase];
                      _procesarConcatenacion(bloqueBase, contenidoArrastrado, indexBase);
                    } else {
                      // Si se soltó en un espacio vacío, agregar nuevo bloque
                      setState(() {
                        final nuevaPosicion = _calcularNuevaPosicion();
                        elementosArrastradosContenedor2.add(Bloque(
                          contenido: contenidoArrastrado,
                          color: Colors.blue,
                          posicion: nuevaPosicion,
                        ));
                      });
                    }
                  },
                ),
                Positioned(
                  bottom: screenHeight * 0.025,
                  right: screenWidth * 0.06,
                  child: DragTarget<Map<String, String>>(
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
                    onWillAccept: (data) => true, // Permitir que cualquier bloque sea aceptado
                    onAccept: (data) {
                      _eliminarElemento(data['id']!);
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
      child: Stack(
        children: bloques.map((bloque) {
          final esEspecial = silabasEspeciales.contains(bloque.contenido);
          final esInicioDePalabra = 
              iniciosDePalabras3Silabas.contains(bloque.contenido) ||
              iniciosDePalabras4Silabas.contains(bloque.contenido);
          final esPalabraValida = palabrasValidas.contains(bloque.contenido);

          return Positioned(
            left: bloque.posicion.dx,
            top: bloque.posicion.dy,
            child: Draggable<Map<String, String>>(
              data: bloque.dragData,
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
                  labelPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
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
                  labelPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
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
                labelPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Actualizar el método _buscarIndicePorPosicion para ser más preciso
  int? _buscarIndicePorPosicion(Offset position) {
    const double margenDeteccion = 10.0; // Margen de tolerancia para la detección

    for (int i = 0; i < elementosArrastradosContenedor2.length; i++) {
      final bloque = elementosArrastradosContenedor2[i];
      final Rect bloqueArea = Rect.fromLTWH(
        bloque.posicion.dx - margenDeteccion,
        bloque.posicion.dy - margenDeteccion,
        blockWidth + (margenDeteccion * 2),
        blockHeight + (margenDeteccion * 2)
      );
      
      if (bloqueArea.contains(position)) {
        return i;
      }
    }
    return null;
  }
}

// Clase Bloque
class Bloque {
  final String id;
  final String contenido;
  final Color color;
  final Offset posicion;

  Bloque({
    required this.contenido,
    this.color = Colors.blue,
    required this.posicion,
  }) : id = const Uuid().v4();

  Map<String, String> get dragData => {
    'id': id,
    'contenido': contenido,
  };
}