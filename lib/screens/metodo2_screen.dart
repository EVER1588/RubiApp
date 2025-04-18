import 'package:flutter/material.dart';
import 'metodo2teclado_screen.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../constants/concatenacion_screen.dart'; // Importa el archivo donde está definida la función
import '../constants/constants.dart'; // Importar las funciones globales
import '../constants/custombar_screen.dart'; // Importa el nuevo CustomBar
import 'package:uuid/uuid.dart'; // Importar la biblioteca uuid
import 'dart:math'; // Importar la biblioteca math para generar números aleatorios
import '../constants/state_manager.dart';


class Metodo2Screen extends StatefulWidget {
  @override
  _Metodo2ScreenState createState() => _Metodo2ScreenState();
}

class _Metodo2ScreenState extends State<Metodo2Screen> {
  @override
  Widget build(BuildContext context) {
    return _Metodo2ScreenContent();
  }
}

class _Metodo2ScreenContent extends StatefulWidget {
  @override
  _Metodo2ScreenContentState createState() => _Metodo2ScreenContentState();
}

class _Metodo2ScreenContentState extends State<_Metodo2ScreenContent> {
  final FlutterTts flutterTts = FlutterTts(); // Instancia de Flutter TTS
  final StateManager stateManager = StateManager();
  String _letraSeleccionada = "";
  bool _cerrarAutomaticamente = true; // Mover la variable aquí
  
  // Lista de bloques con identificadores únicos
  List<Map<String, dynamic>> bloquesContenedor2 = [];
  List<Map<String, dynamic>> bloquesContenedor1 = [];

  // Mapa para almacenar los colores de los bloques
  Map<String, BlockColor> coloresBloques = {};
  
  // Generador de UUIDs
  final Uuid uuid = Uuid();

  @override
  void initState() {
    super.initState();
    // Recuperar el estado guardado
    bloquesContenedor2 = List.from(stateManager.bloquesContenedor2M2);
    bloquesContenedor1 = List.from(stateManager.bloquesContenedor1M2);
    coloresBloques = Map.from(stateManager.coloresBloquesM2);
    _letraSeleccionada = stateManager.letraSeleccionadaM2;
    _cerrarAutomaticamente = stateManager.cerrarAutomaticamenteM2;
    configurarFlutterTts();
  }

  @override
  void dispose() {
    // Guardar el estado actual
    stateManager.bloquesContenedor2M2 = List.from(bloquesContenedor2);
    stateManager.bloquesContenedor1M2 = List.from(bloquesContenedor1);
    stateManager.coloresBloquesM2 = Map.from(coloresBloques);
    stateManager.letraSeleccionadaM2 = _letraSeleccionada;
    stateManager.cerrarAutomaticamenteM2 = _cerrarAutomaticamente;
    super.dispose();
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: CustomBar(
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              isLandscape 
                ? 'lib/utils/images/metodo3-por_defecto-horizontal.png'
                : 'lib/utils/images/metodo3-por_defecto-vertical.png'
            ),
            fit: BoxFit.cover,
            opacity: 0.8, // Aumentar de 0.2 a 0.5 (50% de opacidad)
          ),
        ),
        child: isLandscape 
          ? Row( // Layout horizontal
              children: [
                // Contenedores a la izquierda
                Expanded(
                  flex: 48,
                  child: Column(
                    children: [
                      Expanded(
                        flex: 50, // Aumentar de 30 a 40 para dar más espacio al contenedor 1
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 8.0), // Agregar padding inferior
                          child: _buildContenedor1(screenWidth, screenHeight),
                        ),
                      ),
                      Expanded(
                        flex: 90, // Reducir de 70 a 60 para quitar espacio al contenedor 2
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 16.0), // Agregar padding inferior
                          child: _buildContenedor2(screenWidth, screenHeight),
                        ),
                      ),
                    ],
                  ),
                ),
                // Teclados a la derecha
                Expanded(
                  flex: 50,
                  child: _buildTeclados(screenWidth, screenHeight),
                ),
              ],
            )
          : Column( // Layout vertical (original)
              children: [
                Expanded(
                  flex: 15,
                  child: _buildContenedor1(screenWidth, screenHeight),
                ),
                SizedBox(height: 8),
                Expanded(
                  flex: 36,
                  child: _buildContenedor2(screenWidth, screenHeight),
                ),
                Expanded(
                  flex: 56,
                  child: _buildTeclados(screenWidth, screenHeight),
                ),
              ],
            ),
      ),
    );
  }

  Widget _buildContenedor1(double screenWidth, double screenHeight) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    // Calcular el máximo de bloques según la orientación
    final maxBloques = isLandscape 
      ? ((screenWidth * 0.45) ~/ 80) * 2  // Para modo horizontal (2 filas)
      : ((screenWidth * 0.98) ~/ 80) * 2; // Para modo vertical (2 filas)

    return Stack(
      children: [
        DragTarget<Map<String, dynamic>>(
          onWillAccept: (data) {
            // Comprobar límite de bloques
            if (bloquesContenedor1.length >= maxBloques && data?['origen'] != 'contenedor1') {
              return false;
            }
            return data?['color'] == BlockColor.green || data?['origen'] == 'contenedor1';
          },
          onAccept: (data) {
            setState(() {
              final bloque = data['contenido']!;
              final origen = data['origen'] ?? '';
              final id = data['id'];
              if (origen == 'contenedor1') {
                final index = bloquesContenedor1.indexWhere((b) => b['id'] == id);
                if (index != -1) {
                  final bloqueMovido = bloquesContenedor1.removeAt(index);
                  bloquesContenedor1.add(bloqueMovido);
                }
              } else if (origen == 'contenedor2' && data['color'] == BlockColor.green) {
                bloquesContenedor1.add({
                  'id': uuid.v4(),
                  'texto': bloque,
                });
                bloquesContenedor2.removeWhere((b) => b['id'] == id);
              } else {
                bloquesContenedor1.add({
                  'id': uuid.v4(),
                  'texto': bloque,
                });
              }
              // Solo cerrar el teclado si _cerrarAutomaticamente es true
              if (_cerrarAutomaticamente) {
                _letraSeleccionada = "";
              }
            });
          },
          builder: (context, candidateData, rejectedData) {
            return Container(
              width: isLandscape ? screenWidth * 0.45 : screenWidth * 0.98,
              margin: EdgeInsets.only(
                top: 10,
                left: isLandscape ? screenWidth * 0.01 : screenWidth * 0.02,
                right: isLandscape ? screenWidth * 0.01 : screenWidth * 0.02,
                bottom: 0,
              ),
              height: CONTAINER_1_HEIGHT,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 171, 207, 255).withOpacity(0.8), // Ajustar opacidad
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 3,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: isLandscape ? screenWidth * 0.43 : screenWidth * 0.95,
                        child: Wrap(
                          spacing: CHIP_SPACING,
                          runSpacing: CHIP_RUN_SPACING,
                          alignment: WrapAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                final texto = bloquesContenedor1.map((b) => b['texto']).join(' ');
                                if (texto.isNotEmpty) {
                                  await flutterTts.speak(texto);
                                }
                              },
                              child: Container(
                                width: ROUND_BUTTON_SIZE,
                                height: ROUND_BUTTON_SIZE,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 63, 186, 243),
                                  borderRadius: BorderRadius.circular(ROUND_BUTTON_BORDER_RADIUS),
                                  border: Border.all(
                                    color: Colors.black.withOpacity(0.3), // Agregar transparencia al borde
                                    width: ROUND_BUTTON_BORDER_WIDTH,
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.play_arrow,
                                    color: Colors.white,
                                    size: ROUND_BUTTON_ICON_SIZE,
                                  ),
                                ),
                              ),
                            ),
                            ...bloquesContenedor1.map((bloque) {
                              return GestureDetector(
                                onTap: () {
                                  decirTexto(bloque['texto']);
                                },
                                child: DragTarget<Map<String, dynamic>>(
                                  onWillAccept: (data) {
                                    return data?['origen'] == 'contenedor1';
                                  },
                                  onAccept: (data) {
                                    setState(() {
                                      final draggedId = data['id'];
                                      final targetId = bloque['id'];
                                      if (draggedId != targetId) {
                                        final draggedIndex = bloquesContenedor1.indexWhere((b) => b['id'] == draggedId);
                                        final targetIndex = bloquesContenedor1.indexWhere((b) => b['id'] == targetId);
                                        if (draggedIndex != -1 && targetIndex != -1) {
                                          final bloqueTemp = bloquesContenedor1[draggedIndex];
                                          bloquesContenedor1[draggedIndex] = bloquesContenedor1[targetIndex];
                                          bloquesContenedor1[targetIndex] = bloqueTemp;
                                        }
                                      }
                                    });
                                  },
                                  builder: (context, candidateData, rejectedData) {
                                    return Draggable<Map<String, dynamic>>(
                                      data: {
                                        'id': bloque['id'],
                                        'contenido': bloque['texto'],
                                        'color': BlockColor.green,
                                        'origen': 'contenedor1',
                                      },
                                      feedback: Material(
                                        color: Colors.transparent,
                                        child: Chip(
                                          label: Text(
                                            bloque['texto'],
                                            style: TextStyle(fontSize: CHIP_FONT_SIZE, color: Colors.white),
                                          ),
                                          labelPadding: EdgeInsets.symmetric(
                                            horizontal: CHIP_HORIZONTAL_PADDING,
                                            vertical: CHIP_VERTICAL_PADDING,
                                          ),
                                          padding: EdgeInsets.all(CHIP_INTERNAL_PADDING),
                                          backgroundColor: Colors.green,
                                        ),
                                      ),
                                      childWhenDragging: Opacity(
                                        opacity: 0.5,
                                        child: Chip(
                                          label: Text(
                                            bloque['texto'],
                                            style: TextStyle(fontSize: CHIP_FONT_SIZE, color: Colors.white),
                                          ),
                                          labelPadding: EdgeInsets.symmetric(
                                            horizontal: CHIP_HORIZONTAL_PADDING,
                                            vertical: CHIP_VERTICAL_PADDING,
                                          ),
                                          padding: EdgeInsets.all(CHIP_INTERNAL_PADDING),
                                          backgroundColor: Colors.green,
                                        ),
                                      ),
                                      child: Chip(
                                        label: Text(
                                          bloque['texto'],
                                          style: TextStyle(fontSize: CHIP_FONT_SIZE, color: Colors.white),
                                        ),
                                        labelPadding: EdgeInsets.symmetric(
                                          horizontal: CHIP_HORIZONTAL_PADDING,
                                          vertical: CHIP_VERTICAL_PADDING,
                                        ),
                                        padding: EdgeInsets.all(CHIP_INTERNAL_PADDING),
                                        backgroundColor: Colors.green,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(CHIP_BORDER_RADIUS),
                                          side: BorderSide(
                                            color: Colors.black,
                                            width: CHIP_BORDER_WIDTH,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 5,
                    right: 5,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          bloquesContenedor1.clear();
                        });
                      },
                      child: Container(
                        width: ROUND_BUTTON_SIZE,
                        height: ROUND_BUTTON_SIZE,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(ROUND_BUTTON_BORDER_RADIUS),
                          border: Border.all(
                            color: Colors.black.withOpacity(0.3), // Mismo valor de transparencia
                            width: ROUND_BUTTON_BORDER_WIDTH,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.cleaning_services,
                            color: Colors.white,
                            size: ROUND_BUTTON_ICON_SIZE,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (bloquesContenedor1.length >= maxBloques - 1)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.warning,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildContenedor2(double screenWidth, double screenHeight) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Container(
      padding: EdgeInsets.only(top: 0),
      child: Stack(
        children: [
          DragTarget<Map<String, dynamic>>(
            onWillAcceptWithDetails: (details) {
              // Aceptar bloques de cualquier origen
              return true;
            },
            onAcceptWithDetails: (details) {
              setState(() {
                final bloque = details.data['contenido']!;
                final color = details.data['color'] ?? BlockColor.blue;
                final id = details.data['id'];
                final origen = details.data['origen'] ?? '';

                if (origen == 'contenedor1') {
                  // Remover del contenedor 1 y agregar al contenedor 2
                  bloquesContenedor1.removeWhere((b) => b['id'] == id);
                  bloquesContenedor2.add({
                    'id': uuid.v4(),
                    'texto': bloque,
                  });
                  coloresBloques[bloque] = color;
                } else if (origen == 'teclado' || origen == '') {
                  bloquesContenedor2.add({
                    'id': uuid.v4(),
                    'texto': bloque,
                  });
                  coloresBloques[bloque] = color;
                  stateManager.actualizarContadores(nuevaSilaba: true);
                }
                _validarBloquesRestantes();
                if (_cerrarAutomaticamente) {
                  setState(() {
                    _letraSeleccionada = "";
                  });
                }
              });
            },
            builder: (context, candidateData, rejectedData) {
              return Container(
                width: screenWidth * 0.98,
                margin: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.02,
                  vertical: 0,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.green[100]?.withOpacity(0.8), // Ajustar opacidad
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      spreadRadius: 3,
                      blurRadius: 3,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                constraints: BoxConstraints(
                  minHeight: screenHeight * 0.3,
                ),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0, bottom: 8.0),
                    child: Wrap(
                      alignment: WrapAlignment.start,
                      spacing: CHIP_SPACING,
                      runSpacing: CHIP_RUN_SPACING,
                      children: bloquesContenedor2.map((bloque) {
                        return AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: GestureDetector(
                            onTap: () {
                              decirTexto(bloque['texto']);
                            },
                            child: DragTarget<Map<String, dynamic>>(
                              onWillAccept: (data) {
                                final compatibles = _sonCompatibles(bloque['texto'], data?['contenido'] ?? '');
                                setState(() {
                                  bloque['resaltado'] = compatibles;
                                });
                                return true;
                              },
                              onAccept: (data) {
                                final resultado = concatenarBloques(bloque['texto'], data['contenido']);
                                final nuevaCadena = resultado['cadena'];
                                final nuevoColor = resultado['color'];
                                setState(() {
                                  bloquesContenedor2.removeWhere((b) => b['id'] == bloque['id']);
                                  if (data['origen'] == 'contenedor2') {
                                    bloquesContenedor2.removeWhere((b) => b['id'] == data['id']);
                                  }
                                  bloquesContenedor2.add({
                                    'id': uuid.v4(),
                                    'texto': nuevaCadena,
                                  });
                                  coloresBloques[nuevaCadena] = nuevoColor;
                                  decirTexto(nuevaCadena);
                                  _letraSeleccionada = "";
                                });
                                if (resultado['color'] == BlockColor.green) {
                                  final palabra = resultado['cadena'];
                                  validarPalabra(palabra);
                                }
                              },
                              builder: (context, candidateData, rejectedData) {
                                return Draggable<Map<String, dynamic>>(
                                  data: {
                                    'id': bloque['id'],
                                    'contenido': bloque['texto'],
                                    'color': coloresBloques[bloque['texto']],
                                    'origen': 'contenedor2',
                                  },
                                  feedback: Material(
                                    color: Colors.transparent,
                                    child: Chip(
                                      label: Text(
                                        bloque['texto'],
                                        style: TextStyle(fontSize: CHIP_FONT_SIZE, color: Colors.white),
                                      ),
                                      labelPadding: EdgeInsets.symmetric(
                                        horizontal: CHIP_HORIZONTAL_PADDING,
                                        vertical: CHIP_VERTICAL_PADDING,
                                      ),
                                      padding: EdgeInsets.all(CHIP_INTERNAL_PADDING),
                                      backgroundColor: _getColor(coloresBloques[bloque['texto']]),
                                    ),
                                  ),
                                  childWhenDragging: Opacity(
                                    opacity: 0.5,
                                    child: Chip(
                                      label: Text(
                                        bloque['texto'],
                                        style: TextStyle(fontSize: CHIP_FONT_SIZE, color: Colors.white),
                                      ),
                                      labelPadding: EdgeInsets.symmetric(
                                        horizontal: CHIP_HORIZONTAL_PADDING,
                                        vertical: CHIP_VERTICAL_PADDING,
                                      ),
                                      padding: EdgeInsets.all(CHIP_INTERNAL_PADDING),
                                      backgroundColor: _getColor(coloresBloques[bloque['texto']]),
                                    ),
                                  ),
                                  child: Chip(
                                    label: Text(
                                      bloque['texto'],
                                      style: TextStyle(fontSize: CHIP_FONT_SIZE, color: Colors.white),
                                    ),
                                    labelPadding: EdgeInsets.symmetric(
                                      horizontal: CHIP_HORIZONTAL_PADDING,
                                      vertical: CHIP_VERTICAL_PADDING,
                                    ),
                                    padding: EdgeInsets.all(CHIP_INTERNAL_PADDING),
                                    backgroundColor: _getColor(coloresBloques[bloque['texto']]),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(CHIP_BORDER_RADIUS),
                                      side: BorderSide(
                                        color: Colors.black,
                                        width: CHIP_BORDER_WIDTH,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              );
            },
          ),
          // Botón de borrar (rojo)
          Positioned(
            bottom: isLandscape ? 5 : 5,
            right: isLandscape ? 23 : 13,
            child: DragTarget<Map<String, dynamic>>(
              onWillAccept: (data) => true,
              onAccept: (data) {
                setState(() {
                  final String id = data['id'];
                  final String origen = data['origen'] ?? '';
                  if (origen == 'contenedor1') {
                    bloquesContenedor1.removeWhere((b) => b['id'] == id);
                  } else if (origen == 'contenedor2') {
                    bloquesContenedor2.removeWhere((b) => b['id'] == id);
                  }
                  _validarBloquesRestantes();
                });
              },
              builder: (context, candidateData, rejectedData) {
                return Container(
                  width: DELETE_BUTTON_SIZE,
                  height: DELETE_BUTTON_SIZE,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(ROUND_BUTTON_BORDER_RADIUS),
                    border: Border.all(
                      color: Colors.black.withOpacity(0.3),
                      width: ROUND_BUTTON_BORDER_WIDTH,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: ROUND_BUTTON_ICON_SIZE,
                    ),
                  ),
                );
              },
            ),
          ),
          // Botón de limpiar (naranja)
          Positioned(
            bottom: isLandscape ? 5 : 5,
            right: isLandscape ? 98 : 85,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  bloquesContenedor2.clear();
                  coloresBloques.clear();
                });
              },
              child: Container(
                width: ROUND_BUTTON_SIZE,
                height: ROUND_BUTTON_SIZE,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(ROUND_BUTTON_BORDER_RADIUS),
                  border: Border.all(
                    color: Colors.black.withOpacity(0.3),
                    width: ROUND_BUTTON_BORDER_WIDTH,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.cleaning_services,
                    color: Colors.white,
                    size: ROUND_BUTTON_ICON_SIZE,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeclados(double screenWidth, double screenHeight) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    
    // Calcular aspect ratio dinámicamente
    double calculatedAspectRatio;
    if (isLandscape) {
      final availableWidth = screenWidth * 0.5; // 50% del ancho en modo horizontal
      final blockSize = (availableWidth - (6 * BLOCK_SPACING)) / 5; // 5 bloques por fila
      calculatedAspectRatio = blockSize / (blockSize * 0.6); // altura es 80% del ancho
    } else {
      calculatedAspectRatio = KEYBOARD_GRID_ASPECT_RATIO; // Mantener ratio original en vertical
    }
    
    return Metodo2Teclado(
      gridAspectRatio: calculatedAspectRatio,
      onLetterPressed: (letra) async {
        decirTexto(letra);
        await Future.delayed(Duration(milliseconds: 10));
        setState(() {
          _letraSeleccionada = letra;
        });
      },
      letraSeleccionada: _letraSeleccionada,
      onClosePressed: () {
        setState(() {
          _letraSeleccionada = "";
        });
      },
      onSilabaDragged: (silaba) {
        decirTexto(silaba);
        agregarSilaba(silaba);
      },
      onAutoCerrarChanged: (bool value) {
        setState(() {
          _cerrarAutomaticamente = value;
        });
      },
    );
  }

  Color _getColor(BlockColor? color) {
    switch (color) {
      case BlockColor.green:
        return BLOCK_GREEN;
      case BlockColor.orange:
        return BLOCK_ORANGE;
      case BlockColor.red:
        return BLOCK_RED;
      default:
        return BLOCK_BLUE;
    }
  }

  void _validarBloquesRestantes() {
    for (var bloque in bloquesContenedor2) {
      final bloqueLimpio = bloque['texto'].trim().toUpperCase();
      if (palabrasValidas.contains(bloqueLimpio)) {
        coloresBloques[bloque['texto']] = BlockColor.green;
      } else if (_esSilabaDeLista(bloqueLimpio)) {
        coloresBloques[bloque['texto']] = BlockColor.blue;
      } else if (IniciosDePalabras.contains(bloqueLimpio)) {
        coloresBloques[bloque['texto']] = BlockColor.orange;
      } else {
        coloresBloques[bloque['texto']] = BlockColor.red;
      }
    }
  }

  bool _esSilabaDeLista(String bloque) {
    for (var lista in silabasPorLetra.values) {
      if (lista.contains(bloque)) {
        return true;
      }
    }
    return false;
  }

  bool _esPalabraValida(String palabra) {
    if (palabrasValidas.contains(palabra.toUpperCase())) {
      return true;
    }
    for (String palabraValida in palabrasValidas) {
      if (palabraValida.startsWith(palabra.toUpperCase())) {
        return true;
      }
    }
    return false;
  }

  bool _sonCompatibles(String bloque1, String bloque2) {
    if (bloque1.isEmpty || bloque2.isEmpty) return false;
    final combinacion = bloque1 + bloque2;
    if (palabrasValidas.contains(combinacion.toUpperCase())) {
      return true;
    }
    for (String palabra in palabrasValidas) {
      if (palabra.toUpperCase().startsWith(combinacion.toUpperCase())) {
        return true;
      }
    }
    return false;
  }

  void agregarSilaba(String silaba) {
    setState(() {
      bloquesContenedor2.add({
        'id': uuid.v4(),
        'texto': silaba,
      });
      _validarBloquesRestantes();
      stateManager.actualizarContadores(nuevaSilaba: true);
    });
  }

  void validarPalabra(String palabra) {
    if (_esPalabraValida(palabra)) {
      stateManager.actualizarContadores(nuevaPalabra: palabra);
    }
  }
}