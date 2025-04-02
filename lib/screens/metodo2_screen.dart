import 'package:flutter/material.dart';
import 'metodo2teclado_screen.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../constants/concatenacion_screen.dart'; // Importa el archivo donde está definida la función
import '../constants/constants.dart'; // Importar las funciones globales
import '../constants/custombar_screen.dart'; // Importa el nuevo CustomBar

class Metodo2Screen extends StatefulWidget {
  const Metodo2Screen({Key? key}) : super(key: key);

  @override
  _Metodo2ScreenState createState() => _Metodo2ScreenState();
}

class _Metodo2ScreenState extends State<Metodo2Screen> {
  final FlutterTts flutterTts = FlutterTts(); // Instancia de Flutter TTS
  String _letraSeleccionada = "";
  
  // Lista de bloques del contenedor 2
  List<String> bloquesContenedor2 = [];
  List<String> bloquesContenedor1 = [];

  // Mapa para almacenar los colores de los bloques
  Map<String, BlockColor> coloresBloques = {};

  @override
  void initState() {
    super.initState();
    configurarFlutterTts(); // Configurar Flutter TTS al iniciar la pantalla
  }

  // Configurar Flutter TTS
  void _configurarFlutterTts() async {
    await flutterTts.setLanguage("es-ES"); // Configurar el idioma a español
    await flutterTts.setPitch(1.0); // Configurar el tono
    await flutterTts.setSpeechRate(0.5); // Configurar la velocidad de habla
    await flutterTts.awaitSpeakCompletion(true); // Esperar a que termine de hablar
  }

  // Método para reproducir la letra seleccionada
  Future<void> _decirLetra(String letra) async {
    await flutterTts.speak(letra); // Decir la letra en voz alta
  }

  @override
  Widget build(BuildContext context) {
    // Obtener el ancho y alto de la pantalla
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: CustomBar(
        title: 'Método 2',
        onBackPressed: () {
          Navigator.pop(context); // Acción al presionar el botón de retroceso
        },
      ),
      body: Column(
        children: [
          // Contenedor 1 (Azul) con restricciones
          Expanded(
            flex: 1,
            child: DragTarget<Map<String, dynamic>>(
              onWillAccept: (data) {
                // Solo aceptar bloques verdes (palabras válidas)
                return data?['color'] == BlockColor.green;
              },
              onAccept: (data) {
                setState(() {
                  final bloque = data['contenido']!;
                  // Agregar el bloque al contenedor 1
                  bloquesContenedor1.add(bloque);
                });
              },
              builder: (context, candidateData, rejectedData) {
                return Container(
                  width: screenWidth * 0.95,
                  margin: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.02,
                  ),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(0, 0, 255, 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: bloquesContenedor1.map((bloque) {
                      return Draggable<Map<String, dynamic>>(
                        data: {
                          'contenido': bloque,
                          'color': BlockColor.green,
                        },
                        feedback: Material(
                          color: Colors.transparent,
                          child: Chip(
                            label: Text(
                              bloque,
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                            backgroundColor: Colors.green,
                          ),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.5,
                          child: Chip(
                            label: Text(
                              bloque,
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                            backgroundColor: Colors.green,
                          ),
                        ),
                        child: Chip(
                          label: Text(
                            bloque,
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),

          // Contenedor 2 (Verde) con DragTarget utilizando onAcceptWithDetails
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                // Contenedor principal (verde)
                DragTarget<Map<String, dynamic>>(
                  onWillAcceptWithDetails: (details) => true,
                  onAcceptWithDetails: (details) {
                    setState(() {
                      final bloque = details.data['contenido']!;
                      final color = details.data['color'] ?? BlockColor.blue;

                      // Agregar el bloque al contenedor 2 con su color correspondiente
                      bloquesContenedor2.add(bloque);
                      coloresBloques[bloque] = color;
                    });
                  },
                  builder: (context, candidateData, rejectedData) {
                    return Container(
                      width: screenWidth * 0.95,
                      margin: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.05,
                        vertical: screenHeight * 0.02,
                      ),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(0, 128, 0, 0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Wrap(
                            spacing: 8.0,
                            runSpacing: 4.0,
                            children: bloquesContenedor2.map((bloque) {
                              return GestureDetector(
                                onTap: () {
                                  decirTexto(bloque); // Leer el texto al tocar el bloque
                                },
                                child: DragTarget<Map<String, dynamic>>(
                                  onWillAccept: (data) => true,
                                  onAccept: (data) {
                                    setState(() {
                                      // Concatenar los bloques utilizando la función `concatenarBloques`
                                      final resultado = concatenarBloques(bloque, data['contenido']);
                                      final nuevaCadena = resultado['cadena'];
                                      final nuevoColor = resultado['color'];

                                      // Reemplazar los bloques con el bloque concatenado
                                      bloquesContenedor2.remove(bloque);
                                      bloquesContenedor2.remove(data['contenido']);
                                      bloquesContenedor2.add(nuevaCadena);

                                      // Actualizar el color del bloque concatenado
                                      coloresBloques.remove(bloque);
                                      coloresBloques.remove(data['contenido']);
                                      coloresBloques[nuevaCadena] = nuevoColor;

                                      // Leer el bloque resultante
                                      decirTexto(nuevaCadena);
                                    });
                                  },
                                  builder: (context, candidateData, rejectedData) {
                                    return Draggable<Map<String, dynamic>>(
                                      data: {
                                        'contenido': bloque,
                                        'color': coloresBloques[bloque], // Pasar el color actual
                                      },
                                      feedback: Material(
                                        color: Colors.transparent,
                                        child: Chip(
                                          label: Text(
                                            bloque,
                                            style: TextStyle(fontSize: 16, color: Colors.white),
                                          ),
                                          backgroundColor: _getColor(coloresBloques[bloque]),
                                        ),
                                      ),
                                      childWhenDragging: Opacity(
                                        opacity: 0.5,
                                        child: Chip(
                                          label: Text(
                                            bloque,
                                            style: TextStyle(fontSize: 16, color: Colors.white),
                                          ),
                                          backgroundColor: _getColor(coloresBloques[bloque]),
                                        ),
                                      ),
                                      child: Chip(
                                        label: Text(
                                          bloque,
                                          style: TextStyle(fontSize: 16, color: Colors.white),
                                        ),
                                        backgroundColor: _getColor(coloresBloques[bloque]),
                                      ),
                                    );
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Botón de borrar en la esquina inferior derecha
                Positioned(
                  bottom: 25, // Ajusta la posición vertical
                  right: 29,  // Ajusta la posición horizontal
                  child: DragTarget<Map<String, dynamic>>(
                    onWillAccept: (data) => true,
                    onAccept: (data) {
                      setState(() {
                        // Eliminar el bloque arrastrado
                        final bloque = data['contenido']!;
                        bloquesContenedor2.remove(bloque);
                        coloresBloques.remove(bloque);

                        // Validar los bloques restantes
                        _validarBloquesRestantes();
                      });
                    },
                    builder: (context, candidateData, rejectedData) {
                      return Container(
                        width: 70, // Tamaño del botón
                        height: 70, // Tamaño del botón
                        decoration: BoxDecoration(
                          color: Colors.red, // Color del botón
                          borderRadius: BorderRadius.circular(10), // Esquinas redondeadas
                        ),
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      );
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
              onLetterPressed: (letra) async {
                decirTexto(letra); // Leer la letra seleccionada
                await Future.delayed(Duration(milliseconds: 10));
                setState(() {
                  _letraSeleccionada = letra;
                });
              },
              letraSeleccionada: _letraSeleccionada,
              onClosePressed: () {
                setState(() {
                  _letraSeleccionada = ""; // Cerrar el teclado secundario
                });
              },
              onSilabaDragged: (silaba) {
                decirTexto(silaba); // Leer la sílaba arrastrada
              },
            ),
          ),
        ],
      ),
    );
  }

  // Función para obtener el color correspondiente a un estado
  Color _getColor(BlockColor? color) {
    switch (color) {
      case BlockColor.green:
        return Colors.green;
      case BlockColor.orange:
        return Colors.orange;
      case BlockColor.red:
        return Colors.red;
      default:
        return Colors.blue; // Estado inicial
    }
  }

  void _validarBloquesRestantes() {
    for (var bloque in bloquesContenedor2) {
      // Validar y asignar el color correspondiente
      if (palabrasValidas.contains(bloque)) {
        coloresBloques[bloque] = BlockColor.green; // Palabra válida
      } else if (_esSilabaDeLista(bloque)) {
        coloresBloques[bloque] = BlockColor.blue; // Bloque de una sola sílaba o sílaba válida
      } else if (IniciosDePalabras.contains(bloque)) {
        coloresBloques[bloque] = BlockColor.orange; // Inicio de palabra válido
      } else {
        coloresBloques[bloque] = BlockColor.red; // Bloque inválido
      }
    }
  }

  // Función para verificar si un bloque está en silabasPorLetra
  bool _esSilabaDeLista(String bloque) {
    for (var lista in silabasPorLetra.values) {
      if (lista.contains(bloque)) {
        return true; // El bloque está en la lista de sílabas
      }
    }
    return false; // El bloque no está en ninguna lista de sílabas
  }
}