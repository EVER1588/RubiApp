import 'package:flutter/material.dart';
import 'metodo2teclado_screen.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../constants/concatenacion_screen.dart'; // Importa el archivo donde está definida la función

class Metodo2Screen extends StatefulWidget {
  const Metodo2Screen({Key? key}) : super(key: key);

  @override
  _Metodo2ScreenState createState() => _Metodo2ScreenState();
}

class _Metodo2ScreenState extends State<Metodo2Screen> {
  final FlutterTts flutterTts = FlutterTts();
  String _letraSeleccionada = "";
  
  // Lista de bloques del contenedor 2
  List<String> bloquesContenedor2 = [];

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
            child: Container(
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
                child: Text(
                  'Contenedor 1',
                  style: TextStyle(fontSize: 18, color: Colors.blue),
                ),
              ),
            ),
          ),

          // Contenedor 2 (Verde) con DragTarget utilizando onAcceptWithDetails
          Expanded(
            flex: 2,
            child: DragTarget<Map<String, dynamic>>(
              onWillAcceptWithDetails: (details) => true,
              onAcceptWithDetails: (details) {
                setState(() {
                  // Extraer el contenido del bloque arrastrado desde details.data
                  final bloque = details.data['contenido']!;
                  bloquesContenedor2.add(bloque);
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
                  // Alineamos el contenido en la parte superior izquierda
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: bloquesContenedor2.map((bloque) {
                          return DragTarget<Map<String, dynamic>>(
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

                                // Actualizar el color del bloque (opcional, si se usa visualización de color)
                                // Esto depende de cómo quieras manejar los colores en la interfaz.
                              });
                            },
                            builder: (context, candidateData, rejectedData) {
                              return Draggable<Map<String, dynamic>>(
                                data: {'contenido': bloque},
                                feedback: Material(
                                  color: Colors.transparent,
                                  child: Chip(
                                    label: Text(
                                      bloque,
                                      style: TextStyle(fontSize: 16, color: Colors.white),
                                    ),
                                    backgroundColor: Colors.green, // Cambiar según el estado
                                  ),
                                ),
                                childWhenDragging: Opacity(
                                  opacity: 0.5,
                                  child: Chip(
                                    label: Text(
                                      bloque,
                                      style: TextStyle(fontSize: 16, color: Colors.white),
                                    ),
                                    backgroundColor: Colors.green, // Cambiar según el estado
                                  ),
                                ),
                                child: Chip(
                                  label: Text(
                                    bloque,
                                    style: TextStyle(fontSize: 16, color: Colors.white),
                                  ),
                                  backgroundColor: Colors.green, // Cambiar según el estado
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                );
              },
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
}