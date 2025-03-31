// lib/screens/metodo2teclado_screen.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../constants/constants.dart'; // Importar las funciones globales y silabasPorLetra

class Metodo2Teclado extends StatelessWidget {
  final Function(String) onLetterPressed;
  final String letraSeleccionada;
  final VoidCallback onClosePressed; // Nuevo parámetro para manejar el cierre
  final Function(String) onSilabaDragged; // Nuevo parámetro para manejar el arrastre de sílabas

  Metodo2Teclado({
    Key? key,
    required this.onLetterPressed,
    required this.letraSeleccionada,
    required this.onClosePressed, // Asegúrate de marcarlo como requerido
    required this.onSilabaDragged, // Asegúrate de marcarlo como requerido
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        // Teclado Principal
        _buildTecladoPrincipal(screenWidth, screenHeight),

        // Teclado Secundario (Flotante)
        if (letraSeleccionada.isNotEmpty)
          Positioned.fill(
            child: Stack(
              children: [
                // Fondo semi-transparente
                Container(
                  color: Colors.black.withOpacity(0),
                ),

                // Contenido del teclado secundario
                Center(
                  child: Container(
                    width: screenWidth * 0.9, // Cambia este valor para ajustar el ancho del teclado
                    height: screenHeight * 0.42, // Cambia este valor para ajustar el alto del teclado
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10), // Bordes redondeados del teclado
                    ),
                    child: GridView.builder(
                      padding: EdgeInsets.all(8),
                      physics: NeverScrollableScrollPhysics(), // Desactivar el scroll interno del GridView
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6, // Número de columnas
                        crossAxisSpacing: 8, // Espaciado horizontal entre bloques
                        mainAxisSpacing: 8, // Espaciado vertical entre bloques
                        childAspectRatio: 1.2, // Cambia este valor para ajustar la proporción (ancho:alto)
                      ),
                      itemCount: silabasPorLetra[letraSeleccionada]?.length ?? 0,
                      itemBuilder: (context, index) {
                        final silaba = silabasPorLetra[letraSeleccionada]![index];
                        final esSilabaEspecial = silabasEspeciales.contains(silaba);

                        return GestureDetector(
                          onTap: () {
                            // Leer la sílaba al tocar el bloque
                            flutterTts.speak(silaba);
                          },
                          child: Draggable<Map<String, String>>(
                            data: {
                              'id': const Uuid().v4(),
                              'contenido': silaba,
                            },
                            feedback: Material(
                              child: Container(
                                width: screenWidth * 0.15, // Ajusta el ancho
                                height: (screenWidth * 0.15) / 1.2, // Mantiene la proporción 1.2 (ancho:alto)
                                decoration: BoxDecoration(
                                  color: esSilabaEspecial ? Colors.green : Colors.blue,
                                  borderRadius: BorderRadius.circular(10), // Bordes redondeados
                                ),
                                child: Center(
                                  child: Text(
                                    silaba,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: screenWidth * 0.04, // Ajusta el tamaño del texto
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.8, // Ajusta la opacidad si lo deseas
                              child: Container(
                                width: screenWidth * 0.15, // Ajusta el ancho
                                height: (screenWidth * 0.15) / 1.2, // Ajusta el alto para mantener la proporción (1.2 es el childAspectRatio)
                                decoration: BoxDecoration(
                                  color: esSilabaEspecial ? Colors.green : Colors.blue,
                                  borderRadius: BorderRadius.circular(10), // Bordes redondeados
                                ),
                                child: Center(
                                  child: Text(
                                    silaba,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: screenWidth * 0.04, // Ajusta el tamaño del texto
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            onDragCompleted: () {
                              // Llama a la función para cerrar el teclado secundario
                              onClosePressed();
                            },
                            child: Container(
                              width: screenWidth * 0.15,
                              height: screenWidth * 0.15,
                              decoration: BoxDecoration(
                                color: esSilabaEspecial ? Colors.green : Colors.blue,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  silaba,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: screenWidth * 0.04,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Botón de cerrar
                Positioned(
                  bottom: 25, // Distancia desde abajo
                  right: 25, // Distancia desde la derecha
                  child: FloatingActionButton(
                    onPressed: onClosePressed, // Llamar directamente al callback de cierre
                    backgroundColor: Colors.red, // Color del botón
                    child: Icon(Icons.close, color: Colors.white), // Ícono de cerrar
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // Construye el teclado principal
  Widget _buildTecladoPrincipal(double screenWidth, double screenHeight) {
    final List<String> letras = [
      'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
      'N', 'Ñ', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
    ];

    return Container(
      width: screenWidth,
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: screenHeight * 0.02,
      ),
      color: Colors.grey[200],
      child: GridView.builder(
        padding: EdgeInsets.all(screenWidth * 0.02),
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: screenWidth * 0.02,
          mainAxisSpacing: screenHeight * 0.01,
          childAspectRatio: 1.3,
        ),
        itemCount: letras.length,
        itemBuilder: (context, index) {
          final letra = letras[index];
          return GestureDetector(
            onTap: () => onLetterPressed(letra),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                letra,
                style: TextStyle(
                  fontSize: screenHeight * 0.025,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}