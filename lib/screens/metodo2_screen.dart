import 'package:flutter/material.dart';
import 'metodo2teclado_screen.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../constants/concatenacion_screen.dart'; // Importa el archivo donde está definida la función
import '../constants/constants.dart'; // Importar las funciones globales
import '../constants/custombar_screen.dart'; // Importa el nuevo CustomBar
import 'package:uuid/uuid.dart'; // Importar la biblioteca uuid

class Metodo2Screen extends StatefulWidget {
  const Metodo2Screen({Key? key}) : super(key: key);

  @override
  _Metodo2ScreenState createState() => _Metodo2ScreenState();
}

class _Metodo2ScreenState extends State<Metodo2Screen> {
  final FlutterTts flutterTts = FlutterTts(); // Instancia de Flutter TTS
  String _letraSeleccionada = "";
  
  // Lista de bloques con identificadores únicos
  List<Map<String, dynamic>> bloquesContenedor2 = [];
  List<Map<String, dynamic>> bloquesContenedor1 = [];

  // Mapa para almacenar los colores de los bloques
  Map<String, BlockColor> coloresBloques = {};
  
  // Generador de UUIDs
  final Uuid _uuid = Uuid();

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
          // Contenedor 1 (Azul) con restricciones y botón de PLAY
          Expanded(
            flex: 1,
            child: Stack(
              children: [
                // Área de DragTarget para el contenedor completo
                DragTarget<Map<String, dynamic>>(
                  onWillAccept: (data) {
                    // Aceptar bloques verdes del teclado o cualquier bloque del mismo contenedor 1
                    // o bloques verdes del contenedor 2
                    return data?['color'] == BlockColor.green || data?['origen'] == 'contenedor1';
                  },
                  onAccept: (data) {
                    setState(() {
                      final bloque = data['contenido']!;
                      final origen = data['origen'] ?? '';
                      final id = data['id'];
                      
                      // Si el bloque viene del mismo contenedor 1, reordenar (mover al final)
                      if (origen == 'contenedor1') {
                        // Buscar y remover el bloque por su ID
                        final index = bloquesContenedor1.indexWhere((b) => b['id'] == id);
                        if (index != -1) {
                          final bloqueMovido = bloquesContenedor1.removeAt(index);
                          // Añadirlo al final
                          bloquesContenedor1.add(bloqueMovido);
                        }
                      } 
                      // Si el bloque viene del contenedor 2 y es verde (palabra válida)
                      else if (origen == 'contenedor2' && data['color'] == BlockColor.green) {
                        // Agregar al contenedor 1
                        bloquesContenedor1.add({
                          'id': _uuid.v4(),
                          'texto': bloque,
                        });
                        
                        // Eliminar del contenedor 2
                        bloquesContenedor2.removeWhere((b) => b['id'] == id);
                      }
                      // Si viene del teclado, agregar como nuevo
                      else {
                        bloquesContenedor1.add({
                          'id': _uuid.v4(),
                          'texto': bloque,
                        });
                      }
                      
                      // Cerrar el teclado secundario
                      _letraSeleccionada = "";
                    });
                  },
                  builder: (context, candidateData, rejectedData) {
                    return Container(
                      width: screenWidth * 0.98,
                      margin: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.02,
                        vertical: screenHeight * 0.01,
                      ),
                      constraints: BoxConstraints(
                        minHeight: screenHeight * 0.2,
                      ),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(0, 0, 255, 0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: [
                          // Botón de PLAY como el primer bloque
                          Chip(
                            label: GestureDetector(
                              onTap: () async {
                                final texto = bloquesContenedor1.map((b) => b['texto']).join(' ');
                                if (texto.isNotEmpty) {
                                  await flutterTts.speak(texto);
                                }
                              },
                              child: Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                              ),
                            ),
                            backgroundColor: Colors.green,
                          ),

                          // Bloques del contenedor 1
                          ...bloquesContenedor1.map((bloque) {
                            return GestureDetector(
                              onTap: () {
                                decirTexto(bloque['texto']);
                              },
                              child: DragTarget<Map<String, dynamic>>(
                                onWillAccept: (data) {
                                  // Solo aceptar bloques del mismo contenedor para intercambio
                                  return data?['origen'] == 'contenedor1';
                                },
                                onAccept: (data) {
                                  setState(() {
                                    // Intercambiar bloques
                                    final draggedId = data['id'];
                                    final targetId = bloque['id'];
                                    
                                    if (draggedId != targetId) { // Evitar intercambio consigo mismo
                                      // Encontrar índices
                                      final draggedIndex = bloquesContenedor1.indexWhere((b) => b['id'] == draggedId);
                                      final targetIndex = bloquesContenedor1.indexWhere((b) => b['id'] == targetId);
                                      
                                      if (draggedIndex != -1 && targetIndex != -1) {
                                        // Guardar temporalmente
                                        final bloqueTemp = bloquesContenedor1[draggedIndex];
                                        // Swap
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
                                          style: TextStyle(fontSize: 16, color: Colors.white),
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    ),
                                    childWhenDragging: Opacity(
                                      opacity: 0.5,
                                      child: Chip(
                                        label: Text(
                                          bloque['texto'],
                                          style: TextStyle(fontSize: 16, color: Colors.white),
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    ),
                                    child: Chip(
                                      label: Text(
                                        bloque['texto'],
                                        style: TextStyle(fontSize: 16, color: Colors.white),
                                      ),
                                      // Solo usar el shade300 cuando realmente hay un candidato sobre el bloque
                                      backgroundColor: candidateData != null && candidateData.isNotEmpty
                                          ? Colors.green.shade300  
                                          : Colors.green,
                                    ),
                                  );
                                },
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    );
                  },
                ),
              ],
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
                      final id = details.data['id'];
                      final origen = details.data['origen'] ?? '';

                      // Si el bloque proviene del mismo contenedor 2, reordenar en lugar de duplicar
                      if (origen == 'contenedor2') {
                        // Buscar el bloque por su ID
                        final index = bloquesContenedor2.indexWhere((b) => b['id'] == id);
                        if (index != -1) {
                          // Remover el bloque de su posición actual
                          final bloqueMovido = bloquesContenedor2.removeAt(index);
                          // Añadirlo al final de la lista
                          bloquesContenedor2.add(bloqueMovido);
                        }
                      } 
                      // Si el bloque viene del contenedor 1, eliminarlo de allí y añadirlo aquí
                      else if (origen == 'contenedor1') {
                        // Agregar el bloque al contenedor 2
                        bloquesContenedor2.add({
                          'id': _uuid.v4(),
                          'texto': bloque,
                        });
                        coloresBloques[bloque] = color;
                        
                        // Eliminar el bloque del contenedor 1
                        bloquesContenedor1.removeWhere((b) => b['id'] == id);
                      } 
                      // Si proviene del teclado, simplemente añadirlo como nuevo
                      else {
                        // Si proviene de otra fuente (teclado), añadir como nuevo
                        bloquesContenedor2.add({
                          'id': _uuid.v4(),
                          'texto': bloque,
                        });
                        coloresBloques[bloque] = color;
                      }

                      // Validar los bloques restantes inmediatamente
                      _validarBloquesRestantes();

                      // Cerrar el teclado secundario
                      _letraSeleccionada = "";
                    });
                  },
                  builder: (context, candidateData, rejectedData) {
                    return Container(
                      width: screenWidth * 0.98,
                      margin: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.02,
                        vertical: screenHeight * 0.002,
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
                                  decirTexto(bloque['texto']); // Leer el texto al tocar el bloque
                                },
                                child: DragTarget<Map<String, dynamic>>(
                                  onWillAccept: (data) => true,
                                  onAccept: (data) {
                                    setState(() {
                                      // Concatenar los bloques utilizando la función `concatenarBloques`
                                      final resultado = concatenarBloques(bloque['texto'], data['contenido']);
                                      final nuevaCadena = resultado['cadena'];
                                      final nuevoColor = resultado['color'];

                                      // Eliminar los bloques originales (usando ID)
                                      bloquesContenedor2.removeWhere((b) => b['id'] == bloque['id']);
                                      
                                      // Encontrar y eliminar el otro bloque por su ID
                                      if (data['origen'] == 'contenedor2') {
                                        bloquesContenedor2.removeWhere((b) => b['id'] == data['id']);
                                      }
                                      
                                      // Agregar el bloque concatenado con un nuevo ID
                                      bloquesContenedor2.add({
                                        'id': _uuid.v4(),
                                        'texto': nuevaCadena,
                                      });

                                      // Actualizar el color del bloque concatenado
                                      coloresBloques[nuevaCadena] = nuevoColor;

                                      // Leer el bloque resultante
                                      decirTexto(nuevaCadena);
                                    });
                                  },
                                  builder: (context, candidateData, rejectedData) {
                                    return Draggable<Map<String, dynamic>>(
                                      data: {
                                        'id': bloque['id'],
                                        'contenido': bloque['texto'],
                                        'color': coloresBloques[bloque['texto']], // Pasar el color actual
                                        'origen': 'contenedor2', // Identificar origen
                                      },
                                      feedback: Material(
                                        color: Colors.transparent,
                                        child: Chip(
                                          label: Text(
                                            bloque['texto'],
                                            style: TextStyle(fontSize: 16, color: Colors.white),
                                          ),
                                          backgroundColor: _getColor(coloresBloques[bloque['texto']]),
                                        ),
                                      ),
                                      childWhenDragging: Opacity(
                                        opacity: 0.5,
                                        child: Chip(
                                          label: Text(
                                            bloque['texto'],
                                            style: TextStyle(fontSize: 16, color: Colors.white),
                                          ),
                                          backgroundColor: _getColor(coloresBloques[bloque['texto']]),
                                        ),
                                      ),
                                      child: Chip(
                                        label: Text(
                                          bloque['texto'],
                                          style: TextStyle(fontSize: 16, color: Colors.white),
                                        ),
                                        backgroundColor: _getColor(coloresBloques[bloque['texto']]),
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
                        // Eliminar el bloque arrastrado usando su ID
                        final String id = data['id'];
                        final String origen = data['origen'] ?? '';
                        
                        if (origen == 'contenedor1') {
                          // Eliminar del contenedor 1
                          bloquesContenedor1.removeWhere((b) => b['id'] == id);
                        } else if (origen == 'contenedor2') {
                          // Eliminar del contenedor 2
                          bloquesContenedor2.removeWhere((b) => b['id'] == id);
                        }

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
                setState(() {
                  bloquesContenedor2.add({
                    'id': _uuid.v4(),
                    'texto': silaba,
                  }); // Agregar la sílaba al contenedor 2
                  _validarBloquesRestantes(); // Validar los bloques restantes inmediatamente
                });
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
      final bloqueLimpio = bloque['texto'].trim().toUpperCase(); // Asegurar formato consistente
      if (palabrasValidas.contains(bloqueLimpio)) {
        coloresBloques[bloque['texto']] = BlockColor.green; // Palabra válida
      } else if (_esSilabaDeLista(bloqueLimpio)) {
        coloresBloques[bloque['texto']] = BlockColor.blue; // Sílaba válida
      } else if (IniciosDePalabras.contains(bloqueLimpio)) {
        coloresBloques[bloque['texto']] = BlockColor.orange; // Inicio de palabra válido
      } else {
        coloresBloques[bloque['texto']] = BlockColor.red; // Bloque inválido
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