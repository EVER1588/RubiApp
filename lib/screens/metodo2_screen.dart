// Importaciones de paquetes y archivos necesarios
import 'package:flutter/material.dart';
import '../widgets/loading_background_image.dart'; // Widget para mostrar pantalla de carga
import 'metodo2teclado_screen.dart'; // Teclado personalizado
import 'package:flutter_tts/flutter_tts.dart'; // Para funcionalidad de texto a voz
import '../constants/concatenacion_screen.dart'; // Funciones para concatenar bloques
import '../constants/constants.dart'; // Constantes globales
import '../constants/custombar_screen.dart'; // Barra de navegación personalizada
import 'package:uuid/uuid.dart'; // Para generar IDs únicos
import 'dart:math'; // Para funciones matemáticas
import '../constants/state_manager.dart'; // Gestor de estado de la aplicación

// Widget principal de la pantalla Método 2
class Metodo2Screen extends StatefulWidget {
  @override
  _Metodo2ScreenState createState() => _Metodo2ScreenState();
}

// Estado del widget principal
class _Metodo2ScreenState extends State<Metodo2Screen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra superior personalizada con botón de retroceso
      appBar: CustomBar(
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      // Contenido principal envuelto en el widget de carga
      body: LoadingBackgroundImage(
        // Ruta de la imagen de fondo
        imagePath: 'lib/utils/images/metodo2-por_defecto-vertical.png',
        // Contenido principal de la pantalla
        child: Container(
          child: _Metodo2ScreenContent(),
        ),
      ),
    );
  }
}

// Widget interno que contiene la lógica principal de la pantalla
class _Metodo2ScreenContent extends StatefulWidget {
  @override
  _Metodo2ScreenContentState createState() => _Metodo2ScreenContentState();
}

// Estado del contenido principal
class _Metodo2ScreenContentState extends State<_Metodo2ScreenContent> {
  final FlutterTts flutterTts = FlutterTts(); // Motor de texto a voz
  final StateManager stateManager = StateManager(); // Gestor de estado global
  String _letraSeleccionada = ""; // Letra actualmente seleccionada en el teclado
  bool _cerrarAutomaticamente = true; // Indica si el teclado se cierra automáticamente
  
  // Listas para guardar los bloques en cada contenedor
  List<Map<String, dynamic>> bloquesContenedor2 = []; // Contenedor principal de sílabas
  List<Map<String, dynamic>> bloquesContenedor1 = []; // Contenedor de palabras formadas
  
  // Mapa para almacenar los colores de los bloques según su validez
  Map<String, BlockColor> coloresBloques = {};
  
  // Generador de IDs únicos para los bloques
  final Uuid uuid = Uuid();

  @override
  void initState() {
    super.initState();
    // Recuperar el estado guardado de la aplicación
    bloquesContenedor2 = List.from(stateManager.bloquesContenedor2M2);
    bloquesContenedor1 = List.from(stateManager.bloquesContenedor1M2);
    coloresBloques = Map.from(stateManager.coloresBloquesM2);
    _letraSeleccionada = stateManager.letraSeleccionadaM2;
    _cerrarAutomaticamente = stateManager.cerrarAutomaticamenteM2;
    configurarFlutterTts(); // Inicializar el motor de voz
  }

  @override
  void dispose() {
    // Guardar el estado actual antes de cerrar la pantalla
    stateManager.bloquesContenedor2M2 = List.from(bloquesContenedor2);
    stateManager.bloquesContenedor1M2 = List.from(bloquesContenedor1);
    stateManager.coloresBloquesM2 = Map.from(coloresBloques);
    stateManager.letraSeleccionadaM2 = _letraSeleccionada;
    stateManager.cerrarAutomaticamenteM2 = _cerrarAutomaticamente;
    super.dispose();
  }

  // Configuración inicial del motor de texto a voz
  void _configurarFlutterTts() async {
    await flutterTts.setLanguage("es-ES"); // Configurar el idioma a español
    await flutterTts.setPitch(1.0); // Configurar el tono
    await flutterTts.setSpeechRate(0.5); // Configurar la velocidad de habla
    await flutterTts.awaitSpeakCompletion(true); // Esperar a que termine de hablar
  }

  // Método para pronunciar una letra o sílaba
  Future<void> _decirLetra(String letra) async {
    await flutterTts.speak(letra); // Decir la letra/sílaba en voz alta
  }

  @override
  Widget build(BuildContext context) {
    // Obtener dimensiones de la pantalla para diseño responsivo
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    // Diseño diferente según la orientación del dispositivo
    return isLandscape 
      ? Row( // Layout horizontal (para tablets o teléfonos en horizontal)
          children: [
            // Contenedores a la izquierda (ocupa 48% del ancho)
            Expanded(
              flex: 48,
              child: Column(
                children: [
                  // Contenedor 1 (para palabras formadas) - 50% del alto
                  Expanded(
                    flex: 50,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: _buildContenedor1(screenWidth, screenHeight),
                    ),
                  ),
                  // Contenedor 2 (para sílabas) - 90% del alto restante
                  Expanded(
                    flex: 90,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 16.0),
                      child: _buildContenedor2(screenWidth, screenHeight),
                    ),
                  ),
                ],
              ),
            ),
            // Teclados a la derecha (ocupa 50% del ancho)
            Expanded(
              flex: 50,
              child: _buildTeclados(screenWidth, screenHeight),
            ),
          ],
        )
      : Column( // Layout vertical (para teléfonos en modo normal)
          children: [
            // Contenedor 1 arriba (15% del alto)
            Expanded(
              flex: 15,
              child: _buildContenedor1(screenWidth, screenHeight),
            ),
            SizedBox(height: 8),
            // Contenedor 2 en el medio (36% del alto)
            Expanded(
              flex: 36,
              child: _buildContenedor2(screenWidth, screenHeight),
            ),
            // Teclados abajo (56% del alto)
            Expanded(
              flex: 56,
              child: _buildTeclados(screenWidth, screenHeight),
            ),
          ],
        );
  }

  // Construye el contenedor 1 (para palabras formadas)
  Widget _buildContenedor1(double screenWidth, double screenHeight) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    // Calcular el máximo de bloques según la orientación
    final maxBloques = isLandscape 
      ? ((screenWidth * 0.45) ~/ 80) * 2  // Para modo horizontal (2 filas)
      : ((screenWidth * 0.98) ~/ 80) * 2; // Para modo vertical (2 filas)

    return Stack(
      children: [
        // Área donde se pueden soltar los bloques (DragTarget)
        DragTarget<Map<String, dynamic>>(
          // Verificar si se acepta un bloque arrastrado
          onWillAccept: (data) {
            // Comprobar límite de bloques para evitar sobrecarga
            if (bloquesContenedor1.length >= maxBloques && data?['origen'] != 'contenedor1') {
              return false; // No aceptar más bloques
            }
            // Solo aceptar bloques verdes (palabras) o del mismo contenedor
            return data?['color'] == BlockColor.green || data?['origen'] == 'contenedor1';
          },
          // Cuando se acepta un bloque arrastrado
          onAccept: (data) {
            setState(() {
              final bloque = data['contenido']!;
              final origen = data['origen'] ?? '';
              final id = data['id'];
              
              if (origen == 'contenedor1') {
                // Si viene del mismo contenedor, reordenar
                final index = bloquesContenedor1.indexWhere((b) => b['id'] == id);
                if (index != -1) {
                  final bloqueMovido = bloquesContenedor1.removeAt(index);
                  bloquesContenedor1.add(bloqueMovido); // Mover al final
                }
              } else if (origen == 'contenedor2' && data['color'] == BlockColor.green) {
                // Si viene del contenedor 2 y es verde (palabra válida), añadir
                bloquesContenedor1.add({
                  'id': uuid.v4(), // Crear nuevo ID
                  'texto': bloque,
                });
                // Eliminar del contenedor origen
                bloquesContenedor2.removeWhere((b) => b['id'] == id);
              } else {
                // Si viene de otro lugar (teclado), añadir
                bloquesContenedor1.add({
                  'id': uuid.v4(),
                  'texto': bloque,
                });
              }
              
              // Cerrar el teclado si está configurado así
              if (_cerrarAutomaticamente) {
                _letraSeleccionada = "";
              }
            });
          },
          // Construir el contenedor visual
          builder: (context, candidateData, rejectedData) {
            return Container(
              // Dimensiones del contenedor
              width: isLandscape ? screenWidth * 0.45 : screenWidth * 0.98,
              margin: EdgeInsets.only(
                top: 10,
                left: isLandscape ? screenWidth * 0.01 : screenWidth * 0.02,
                right: isLandscape ? screenWidth * 0.01 : screenWidth * 0.02,
                bottom: 0,
              ),
              height: CONTAINER_1_HEIGHT, // Altura constante definida
              // Estilo visual del contenedor
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 65, 183, 230).withOpacity(0.7),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5), // Color del borde
                  width: 1.0, // Grosor del borde
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    spreadRadius: 3,
                    blurRadius: 3,
                    offset: Offset(0, 5), // Sombra hacia abajo
                  ),
                ],
              ),
              // Contenido del contenedor
              child: Stack(
                children: [
                  // Lista horizontal de bloques con scroll
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: isLandscape ? screenWidth * 0.43 : screenWidth * 0.95,
                        // Bloques dispuestos en filas
                        child: Wrap(
                          spacing: CHIP_SPACING,
                          runSpacing: CHIP_RUN_SPACING,
                          alignment: WrapAlignment.start,
                          children: [
                            // Botón para reproducir toda la frase
                            GestureDetector(
                              onTap: () async {
                                final texto = bloquesContenedor1.map((b) => b['texto']).join(' ');
                                if (texto.isNotEmpty) {
                                  await flutterTts.speak(texto); // Leer todo el texto
                                }
                              },
                              // Botón circular de reproducción
                              child: Container(
                                width: ROUND_BUTTON_SIZE,
                                height: ROUND_BUTTON_SIZE,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 63, 186, 243),
                                  borderRadius: BorderRadius.circular(ROUND_BUTTON_BORDER_RADIUS),
                                  border: Border.all(
                                    color: Colors.black.withOpacity(0.3),
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
                            // Lista de bloques en el contenedor 1
                            ...bloquesContenedor1.map((bloque) {
                              return GestureDetector(
                                // Pronunciar al tocar
                                onTap: () {
                                  decirTexto(bloque['texto']);
                                },
                                // Permite reordenar bloques dentro del contenedor
                                child: DragTarget<Map<String, dynamic>>(
                                  onWillAccept: (data) {
                                    return data?['origen'] == 'contenedor1';
                                  },
                                  // Intercambiar posición de bloques al soltar uno encima de otro
                                  onAccept: (data) {
                                    setState(() {
                                      final draggedId = data['id'];
                                      final targetId = bloque['id'];
                                      if (draggedId != targetId) {
                                        final draggedIndex = bloquesContenedor1.indexWhere((b) => b['id'] == draggedId);
                                        final targetIndex = bloquesContenedor1.indexWhere((b) => b['id'] == targetId);
                                        if (draggedIndex != -1 && targetIndex != -1) {
                                          // Intercambiar bloques
                                          final bloqueTemp = bloquesContenedor1[draggedIndex];
                                          bloquesContenedor1[draggedIndex] = bloquesContenedor1[targetIndex];
                                          bloquesContenedor1[targetIndex] = bloqueTemp;
                                        }
                                      }
                                    });
                                  },
                                  // Visualización del bloque arrastrable
                                  builder: (context, candidateData, rejectedData) {
                                    return Draggable<Map<String, dynamic>>(
                                      // Datos transferidos durante el arrastre
                                      data: {
                                        'id': bloque['id'],
                                        'contenido': bloque['texto'],
                                        'color': BlockColor.green,
                                        'origen': 'contenedor1',
                                      },
                                      // Visual mientras se arrastra
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
                                      // Visual en posición original durante arrastre
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
                                      // Visual normal (sin arrastrar)
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
                                        // Agregar borde al chip
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
                  // Botón para limpiar el contenedor
                  Positioned(
                    bottom: 5,
                    right: 5,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          bloquesContenedor1.clear(); // Vaciar el contenedor
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
                  // Indicador de advertencia cuando el contenedor está casi lleno
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

  // Construye el contenedor 2 (para sílabas y formación de palabras)
  Widget _buildContenedor2(double screenWidth, double screenHeight) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Container(
      padding: EdgeInsets.only(top: 0),
      child: Stack(
        children: [
          // Área donde se pueden soltar bloques
          DragTarget<Map<String, dynamic>>(
            onWillAcceptWithDetails: (details) {
              // Aceptar bloques de cualquier origen
              return true;
            },
            // Cuando se acepta un bloque
            onAcceptWithDetails: (details) {
              setState(() {
                final bloque = details.data['contenido']!;
                final color = details.data['color'] ?? BlockColor.blue;
                final id = details.data['id'];
                final origen = details.data['origen'] ?? '';

                if (origen == 'contenedor1') {
                  // Si viene del contenedor 1, mover al contenedor 2
                  bloquesContenedor1.removeWhere((b) => b['id'] == id);
                  bloquesContenedor2.add({
                    'id': uuid.v4(),
                    'texto': bloque,
                  });
                  coloresBloques[bloque] = color;
                } else if (origen == 'teclado' || origen == '') {
                  // Si viene del teclado o es nuevo, agregar
                  bloquesContenedor2.add({
                    'id': uuid.v4(),
                    'texto': bloque,
                  });
                  coloresBloques[bloque] = color;
                  stateManager.actualizarContadores(nuevaSilaba: true); // Actualizar contador de sílabas
                }
                _validarBloquesRestantes(); // Validar colores de los bloques
                if (_cerrarAutomaticamente) {
                  setState(() {
                    _letraSeleccionada = ""; // Cerrar teclado si corresponde
                  });
                }
              });
            },
            // Visualización del contenedor
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
                // Estilo visual del contenedor
                decoration: BoxDecoration(
                  color: Colors.green[100]?.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(15),
                  // Cambiar el borde para que sea igual al del contenedor 1
                  border: Border.all(
                    color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5), // Color del borde igual al contenedor 1
                    width: 1.0, // Grosor del borde igual al contenedor 1
                  ),
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
                // Contenido del contenedor
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0, bottom: 8.0),
                    // Bloques dispuestos en filas
                    child: Wrap(
                      alignment: WrapAlignment.start,
                      spacing: CHIP_SPACING,
                      runSpacing: CHIP_RUN_SPACING,
                      children: bloquesContenedor2.map((bloque) {
                        // Cada bloque es animado
                        return AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: GestureDetector(
                            // Pronunciar al tocar
                            onTap: () {
                              decirTexto(bloque['texto']);
                            },
                            // También es objetivo para concatenar bloques
                            child: DragTarget<Map<String, dynamic>>(
                              onWillAccept: (data) {
                                // Verificar si los bloques son compatibles
                                final compatibles = _sonCompatibles(bloque['texto'], data?['contenido'] ?? '');
                                setState(() {
                                  bloque['resaltado'] = compatibles; // Resaltar si son compatibles
                                });
                                return true;
                              },
                              // Concatenar bloques al soltar uno sobre otro
                              onAccept: (data) {
                                // Obtener resultado de la concatenación
                                final resultado = concatenarBloques(bloque['texto'], data['contenido']);
                                final nuevaCadena = resultado['cadena'];
                                final nuevoColor = resultado['color'];
                                setState(() {
                                  // Eliminar bloques originales
                                  bloquesContenedor2.removeWhere((b) => b['id'] == bloque['id']);
                                  if (data['origen'] == 'contenedor2') {
                                    bloquesContenedor2.removeWhere((b) => b['id'] == data['id']);
                                  }
                                  // Agregar bloque combinado
                                  bloquesContenedor2.add({
                                    'id': uuid.v4(),
                                    'texto': nuevaCadena,
                                  });
                                  coloresBloques[nuevaCadena] = nuevoColor;
                                  decirTexto(nuevaCadena); // Pronunciar nueva combinación
                                  _letraSeleccionada = "";
                                });
                                // Validar si formó una palabra
                                if (resultado['color'] == BlockColor.green) {
                                  final palabra = resultado['cadena'];
                                  validarPalabra(palabra);
                                }
                              },
                              // Visualización del bloque arrastrable
                              builder: (context, candidateData, rejectedData) {
                                return Draggable<Map<String, dynamic>>(
                                  // Datos transferidos durante el arrastre
                                  data: {
                                    'id': bloque['id'],
                                    'contenido': bloque['texto'],
                                    'color': coloresBloques[bloque['texto']],
                                    'origen': 'contenedor2',
                                  },
                                  // Visual mientras se arrastra
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
                                  // Visual en posición original durante arrastre
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
                                  // Visual normal (sin arrastrar)
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
                                    // Agregar borde al chip
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
          // Botón para eliminar bloques (zona de eliminación)
          Positioned(
            bottom: isLandscape ? 5 : 5,
            right: isLandscape ? 23 : 13,
            child: DragTarget<Map<String, dynamic>>(
              onWillAccept: (data) => true, // Aceptar cualquier bloque
              onAccept: (data) {
                // Eliminar el bloque según su origen
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
              // Visualización del botón de eliminación
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
          // Botón para limpiar todo el contenedor
          Positioned(
            bottom: isLandscape ? 5 : 5,
            right: isLandscape ? 98 : 85,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  bloquesContenedor2.clear(); // Vaciar contenedor
                  coloresBloques.clear(); // Limpiar colores
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

  // Construye el área de teclados
  Widget _buildTeclados(double screenWidth, double screenHeight) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    
    // Calcular aspect ratio dinámicamente para adaptarse a la pantalla
    double calculatedAspectRatio;
    if (isLandscape) {
      final availableWidth = screenWidth * 0.5; // 50% del ancho en modo horizontal
      final blockSize = (availableWidth - (6 * BLOCK_SPACING)) / 5; // 5 bloques por fila
      calculatedAspectRatio = blockSize / (blockSize * 0.6); // altura es 80% del ancho
    } else {
      calculatedAspectRatio = KEYBOARD_GRID_ASPECT_RATIO; // Mantener ratio original en vertical
    }
    
    // Usar widget personalizado para el teclado
    return Metodo2Teclado(
      gridAspectRatio: calculatedAspectRatio,
      // Acción al presionar una letra
      onLetterPressed: (letra) async {
        decirTexto(letra);
        await Future.delayed(Duration(milliseconds: 10));
        setState(() {
          _letraSeleccionada = letra;
        });
      },
      letraSeleccionada: _letraSeleccionada,
      // Cerrar el teclado de sílabas
      onClosePressed: () {
        setState(() {
          _letraSeleccionada = "";
        });
      },
      // Cuando se arrastra una sílaba desde el teclado
      onSilabaDragged: (silaba) {
        decirTexto(silaba);
        agregarSilaba(silaba);
      },
      // Cambiar configuración de cierre automático
      onAutoCerrarChanged: (bool value) {
        setState(() {
          _cerrarAutomaticamente = value;
        });
      },
    );
  }

  // Obtener el color según el tipo de bloque
  Color _getColor(BlockColor? color) {
    switch (color) {
      case BlockColor.green:  // Verde para palabras completas válidas
        return BLOCK_GREEN;
      case BlockColor.orange: // Naranja para inicios de palabras
        return BLOCK_ORANGE;
      case BlockColor.red:    // Rojo para combinaciones inválidas
        return BLOCK_RED;
      default:                // Azul para sílabas sueltas
        return BLOCK_BLUE;
    }
  }

  // Validar y actualizar colores de todos los bloques
  void _validarBloquesRestantes() {
    for (var bloque in bloquesContenedor2) {
      final bloqueLimpio = bloque['texto'].trim().toUpperCase();
      if (palabrasValidas.contains(bloqueLimpio)) {
        // Es una palabra completa válida - mantener verde
        coloresBloques[bloque['texto']] = BlockColor.green;
      } else if (IniciosDePalabras.contains(bloqueLimpio)) {
        // Es un inicio válido de palabra - mantener naranja
        coloresBloques[bloque['texto']] = BlockColor.orange;
      } else if (_esSilabaDeLista(bloqueLimpio)) {
        // Es una sílaba válida - mantener azul
        coloresBloques[bloque['texto']] = BlockColor.blue;
      } else {
        // Combinación cualquiera - CAMBIO: ahora será azul en lugar de rojo
        coloresBloques[bloque['texto']] = BlockColor.blue; // Antes era BlockColor.red
      }
    }
  }

  // Verificar si un texto es una sílaba válida
  bool _esSilabaDeLista(String bloque) {
    for (var lista in silabasPorLetra.values) {
      if (lista.contains(bloque)) {
        return true;
      }
    }
    return false;
  }

  // Verificar si un texto es una palabra válida o inicio de palabra
  bool _esPalabraValida(String palabra) {
    if (palabrasValidas.contains(palabra.toUpperCase())) {
      return true; // Es una palabra completa
    }
    for (String palabraValida in palabrasValidas) {
      if (palabraValida.startsWith(palabra.toUpperCase())) {
        return true; // Es inicio de una palabra
      }
    }
    return false;
  }

  // Verificar si dos bloques se pueden combinar para formar una palabra válida
  bool _sonCompatibles(String bloque1, String bloque2) {
    if (bloque1.isEmpty || bloque2.isEmpty) return false;
    final combinacion = bloque1 + bloque2;
    if (palabrasValidas.contains(combinacion.toUpperCase())) {
      return true; // La combinación forma una palabra completa
    }
    for (String palabra in palabrasValidas) {
      if (palabra.toUpperCase().startsWith(combinacion.toUpperCase())) {
        return true; // La combinación es inicio de una palabra
      }
    }
    return false;
  }

  // Agregar una nueva sílaba al contenedor 2
  void agregarSilaba(String silaba) {
    setState(() {
      bloquesContenedor2.add({
        'id': uuid.v4(),
        'texto': silaba,
      });
      _validarBloquesRestantes();
      stateManager.actualizarContadores(nuevaSilaba: true); // Actualizar contadores globales
    });
  }

  // Validar una palabra formada y actualizar contadores
  void validarPalabra(String palabra) {
    if (_esPalabraValida(palabra)) {
      stateManager.actualizarContadores(nuevaPalabra: palabra);
    }
  }
}