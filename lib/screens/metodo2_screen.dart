// lib/screens/metodo2_screen.dart
import 'package:flutter/material.dart';
import 'metodo2teclado_screen.dart'; // Importar el teclado personalizado
import 'package:flutter_tts/flutter_tts.dart';
import '../constants/constants.dart'; // Importar palabras válidas e inicios

class Metodo2Screen extends StatefulWidget {
  const Metodo2Screen({Key? key}) : super(key: key);

  @override
  _Metodo2ScreenState createState() => _Metodo2ScreenState();
}

class _Metodo2ScreenState extends State<Metodo2Screen> {
  final FlutterTts flutterTts = FlutterTts(); // Instancia de FlutterTts
  String _letraSeleccionada = ""; // Letra seleccionada en el teclado principal
  final List<String> silabasEspeciales = [
    "A", "AL", "DA", "DE", "EL", "EN", "ES", "FE", "HA", "LA",
    "LE", "LAS", "LOS", "LUZ", "ME", "MI", "MAS", "MES", "MIS", "NI",
    "NO", "QUE", "QUI", "SE", "SI", "SU", "TE", "TU", "UN", "VA",
    "VE", "VI", "WEB", "WI", "Y", "YA", "YO",
  ];

  // Lista de elementos arrastrados en el Contenedor 1
  final List<String> elementosArrastradosContenedor1 = [];
  final List<String> elementosArrastradosContenedor2 = [];

  // Función para reproducir una oración usando FlutterTts
  void reproducirOracion() async {
    await flutterTts.setLanguage("es-MX"); // Configura el idioma (español de México)
    await flutterTts.setSpeechRate(1.0); // Velocidad normal
    await flutterTts.setVolume(1.0); // Volumen máximo
    await flutterTts.setPitch(1.0); // Tono normal
    await flutterTts.speak("Esta es una oración de ejemplo."); // Reproduce el texto
  }

  // Función para manejar la selección de una letra en el teclado principal
  void _onLetterPressed(String letra) {
    setState(() {
      _letraSeleccionada = letra; // Actualiza la letra seleccionada
    });
  }

  // Función para eliminar un elemento arrastrado
  void _eliminarElemento(String elemento) {
    setState(() {
      if (elementosArrastradosContenedor2.contains(elemento)) {
        elementosArrastradosContenedor2.remove(elemento); // Eliminar del Contenedor 2 primero
      } else if (elementosArrastradosContenedor1.contains(elemento)) {
        elementosArrastradosContenedor1.remove(elemento); // Luego del Contenedor 1
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Obtener el ancho y alto de la pantalla
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Método 2'),
      ),
      body: Column(
        children: [
          // Contenedor 1 (Azul)
          Expanded(
            flex: 1,
            child: DragTarget<String>(
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
                  child: Center(
                    child: Wrap(
                      spacing: 8.0,
                      children: elementosArrastradosContenedor1.map((elemento) {
                        return Draggable<String>(
                          data: elemento,
                          feedback: Material(
                            child: Chip(
                              label: Text(
                                elemento,
                                style: TextStyle(fontSize: 16, color: Colors.white),
                              ),
                              backgroundColor: silabasEspeciales.contains(elemento)
                                  ? Colors.green
                                  : Colors.blue,
                            ),
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.5,
                            child: Chip(
                              label: Text(
                                elemento,
                                style: TextStyle(fontSize: 16, color: Colors.white),
                              ),
                              backgroundColor: silabasEspeciales.contains(elemento)
                                  ? Colors.green
                                  : Colors.blue,
                            ),
                          ),
                          child: Chip(
                            label: Text(
                              elemento,
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                            backgroundColor: silabasEspeciales.contains(elemento)
                                ? Colors.green
                                : Colors.blue,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
              onWillAccept: (data) {
                // Solo acepta bloques especiales (verdes)
                return silabasEspeciales.contains(data);
              },
              onAccept: (data) {
                setState(() {
                  elementosArrastradosContenedor1.add(data);
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
                      child: Center(
                        child: Wrap(
                          spacing: 8.0,
                          children: elementosArrastradosContenedor2.map((elemento) {
                            final esEspecial = silabasEspeciales.contains(elemento);
                            final esInicioDePalabra = iniciosDePalabrasValidas.contains(elemento);
                            final esPalabraValida = palabrasValidas.contains(elemento);

                            return Draggable<String>(
                              data: elemento,
                              feedback: Material(
                                child: Chip(
                                  label: Text(
                                    elemento,
                                    style: TextStyle(fontSize: 16, color: Colors.white),
                                  ),
                                  backgroundColor: esPalabraValida
                                      ? Colors.green
                                      : esInicioDePalabra
                                          ? Colors.orange
                                          : Colors.blue,
                                ),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.5,
                                child: Chip(
                                  label: Text(
                                    elemento,
                                    style: TextStyle(fontSize: 16, color: Colors.white),
                                  ),
                                  backgroundColor: esPalabraValida
                                      ? Colors.green
                                      : esInicioDePalabra
                                          ? Colors.orange
                                          : Colors.blue,
                                ),
                              ),
                              child: Chip(
                                label: Text(
                                  elemento,
                                  style: TextStyle(fontSize: 16, color: Colors.white),
                                ),
                                backgroundColor: esPalabraValida
                                    ? Colors.green
                                    : esInicioDePalabra
                                        ? Colors.orange
                                        : Colors.blue,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                  onWillAccept: (data) {
                    // Acepta todos los bloques
                    return true;
                  },
                  onAccept: (data) {
                    setState(() {
                      final index = elementosArrastradosContenedor2.indexOf(data);
                      if (index != -1) {
                        final silabaActual = elementosArrastradosContenedor2[index];
                        final nuevaCombinacion = silabaActual + data;

                        // Validar si la combinación resultante es una palabra válida
                        if (palabrasValidas.contains(nuevaCombinacion)) {
                          elementosArrastradosContenedor2[index] = nuevaCombinacion;
                          silabasEspeciales.add(nuevaCombinacion); // Marcar como especial
                        }
                        // Validar si la combinación es el inicio de una palabra válida
                        else if (iniciosDePalabrasValidas.contains(nuevaCombinacion)) {
                          elementosArrastradosContenedor2[index] = nuevaCombinacion;
                        }
                      } else {
                        elementosArrastradosContenedor2.add(data);
                      }
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
              onLetterPressed: _onLetterPressed,
              letraSeleccionada: _letraSeleccionada,
            ),
          ),
        ],
      ),
    );
  }
}