// lib/screens/metodo2teclado_screen.dart
import 'package:flutter/material.dart';
import '../constants/constants.dart'; // Importar las funciones globales y silabasClasificadas
import '../constants/concatenacion_screen.dart'; // Importar BlockColor y concatenar bloques

class Metodo2Teclado extends StatefulWidget {
  final Function(String) onLetterPressed;
  final String letraSeleccionada;
  final VoidCallback onClosePressed;
  final Function(String) onSilabaDragged;

  Metodo2Teclado({
    Key? key,
    required this.onLetterPressed,
    required this.letraSeleccionada,
    required this.onClosePressed,
    required this.onSilabaDragged,
  }) : super(key: key);

  @override
  _Metodo2TecladoState createState() => _Metodo2TecladoState();
}

class _Metodo2TecladoState extends State<Metodo2Teclado> {
  String _categoriaSeleccionada = "comunes"; // Categoría seleccionada por defecto
  List<String> _silabasActuales = []; // Lista de sílabas actuales
  bool _modoAcentuado = false; // Modo acentuado desactivado por defecto

  @override
  void didUpdateWidget(Metodo2Teclado oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Actualizar las sílabas cuando se selecciona una letra
    if (oldWidget.letraSeleccionada != widget.letraSeleccionada) {
      setState(() {
        _categoriaSeleccionada = "comunes"; // Restablecer a "comunes"
        _actualizarSilabas(widget.letraSeleccionada, _categoriaSeleccionada);
      });
    }
  }

  void _actualizarSilabas(String letra, String categoria) {
    setState(() {
      // Obtener las sílabas base de la categoría seleccionada
      List<String> silabas = silabasClasificadas[letra.toUpperCase()]?[categoria] ?? [];
      
      // Si el modo acentuado está activo, convertir las sílabas a sus versiones acentuadas
      if (_modoAcentuado) {
        _silabasActuales = silabas.map((silaba) {
          // Usar la función acentuarSilaba para obtener la versión acentuada
          return acentuarSilaba(silaba);
        }).toList();
      } else {
        // Modo normal, usar las sílabas originales
        _silabasActuales = silabas;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final buttonWidth = screenWidth * 0.18;

    return Stack(
      children: [
        // Teclado Principal (siempre visible)
        Positioned.fill(
          child: Column(
            children: [
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.all(BLOCK_PADDING),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: BLOCK_SPACING,
                    mainAxisSpacing: BLOCK_SPACING,
                    childAspectRatio: KEYBOARD_GRID_ASPECT_RATIO, // Usar constante
                  ),
                  itemCount: silabasPorLetra.keys.length, // Número de letras
                  itemBuilder: (context, index) {
                    final letra = silabasPorLetra.keys.elementAt(index);
                    return GestureDetector(
                      onTap: () {
                        widget.onLetterPressed(letra); // Seleccionar letra
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: BLOCK_BLUE, // Usar constante de color
                          borderRadius: BorderRadius.circular(CONTAINER_BORDER_RADIUS),
                        ),
                        child: Center(
                          child: Text(
                            letra,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // Teclado Secundario (superpuesto)
        if (widget.letraSeleccionada.isNotEmpty)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0), // Fondo semi-transparente
              child: Center(
                child: Container(
                  width: screenWidth * KEYBOARD_WIDTH_FACTOR, // Usar constante
                  height: screenHeight * KEYBOARD_HEIGHT_FACTOR, // Usar constante
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(KEYBOARD_BORDER_RADIUS), // Usar constante
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(1),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: Offset(0,8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Container para el título
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            "Sílabas con ${widget.letraSeleccionada.toUpperCase()}",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Stack(
                          children: [
                            // Grid de sílabas
                            Container(
                              height: screenHeight * 0.45, // Reducido de 0.5 a 0.45
                              child: GridView.builder(
                                padding: EdgeInsets.all(8),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 5,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                  childAspectRatio: 1.6, // Relación de aspecto ajustada
                                ),
                                itemCount: _silabasActuales.length,
                                itemBuilder: (context, index) {
                                  final silaba = _silabasActuales[index];
                                  final esPalabraValida = silabasEspeciales.contains(silaba.toUpperCase());
                                  
                                  return GestureDetector(
                                    onTap: () {
                                      flutterTts.speak(silaba); // Leer la sílaba
                                    },
                                    child: Draggable<Map<String, dynamic>>(
                                      // Aquí es donde modificamos el data para incluir el color adecuado
                                      data: {
                                        'contenido': silaba,
                                        'color': esPalabraValida ? BlockColor.green : BlockColor.blue,
                                      },
                                      feedback: Material(
                                        child: Container(
                                          padding: EdgeInsets.all(18),
                                          decoration: BoxDecoration(
                                            color: esPalabraValida ? Colors.green.shade700 : Colors.blue.shade700,
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                          child: Center(
                                            child: Text(
                                              silaba,
                                              style: TextStyle(
                                                color: const Color.fromARGB(255, 255, 255, 255),
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      child: Container(
                                        padding: EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: esPalabraValida ? Colors.green : Colors.blue,
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                        child: Center(
                                          child: Text(
                                            silaba,
                                            style: TextStyle(
                                              color: const Color.fromARGB(255, 255, 255, 255),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Botones inferiores - código modificado
                      Padding(
                        padding: EdgeInsets.only(bottom: 12.0, top: 8.0), // Margen inferior y superior
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildRoundedButton(
                              "Comunes",
                              _categoriaSeleccionada == "comunes" ? Colors.blue : Colors.grey,
                              () {
                                setState(() {
                                  _categoriaSeleccionada = "comunes";
                                  _actualizarSilabas(widget.letraSeleccionada, _categoriaSeleccionada);
                                });
                              },
                              buttonWidth,
                            ),
                            _buildRoundedButton(
                              "Trabadas",
                              _categoriaSeleccionada == "trabadas" ? Colors.blue : Colors.grey,
                              () {
                                setState(() {
                                  _categoriaSeleccionada = "trabadas";
                                  _actualizarSilabas(widget.letraSeleccionada, _categoriaSeleccionada);
                                });
                              },
                              buttonWidth,
                            ),
                            _buildRoundedButton(
                              "Mixtas",
                              _categoriaSeleccionada == "mixtas" ? Colors.blue : Colors.grey,
                              () {
                                setState(() {
                                  _categoriaSeleccionada = "mixtas";
                                  _actualizarSilabas(widget.letraSeleccionada, _categoriaSeleccionada);
                                });
                              },
                              buttonWidth,
                            ),
                            _buildRoundedButton(
                              "Acentuadas",
                              _modoAcentuado ? Colors.orange : Colors.grey,
                              () {
                                setState(() {
                                  _modoAcentuado = !_modoAcentuado; // Activar o desactivar el modo acentuado
                                  _actualizarSilabas(widget.letraSeleccionada, _categoriaSeleccionada);
                                });
                              },
                              buttonWidth,
                            ),
                            _buildRoundedButton(
                              "",
                              Colors.red,
                              widget.onClosePressed,
                              buttonWidth,
                              icon: Icon(Icons.close, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Método para construir botones redondeados
  Widget _buildRoundedButton(String text, Color color, VoidCallback onPressed, double width, {Icon? icon}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.0), // Espacio horizontal entre botones
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: BUTTON_PADDING_VERTICAL), // Usar constante
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BUTTON_BORDER_RADIUS), // Usar constante
          ),
          fixedSize: Size(width - 8, 50), // Ancho ajustado para el margen
        ),
        child: icon ?? Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: BUTTON_TEXT_SIZE, // Usar constante
          ),
        ),
      ),
    );
  }
}