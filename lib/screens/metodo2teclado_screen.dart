// lib/screens/metodo2teclado_screen.dart
import 'package:flutter/material.dart';
import '../constants/constants.dart'; // Importar las funciones globales y silabasClasificadas
import '../constants/concatenacion_screen.dart'; // Importar BlockColor y concatenar bloques

class Metodo2Teclado extends StatefulWidget {
  final Function(String) onLetterPressed;
  final String letraSeleccionada;
  final VoidCallback onClosePressed;
  final Function(String) onSilabaDragged;
  final Function(bool) onAutoCerrarChanged;
  final double gridAspectRatio; // Nuevo parámetro

  const Metodo2Teclado({
    required this.onLetterPressed,
    required this.letraSeleccionada,
    required this.onClosePressed,
    required this.onSilabaDragged,
    required this.onAutoCerrarChanged,
    this.gridAspectRatio = KEYBOARD_GRID_ASPECT_RATIO, // Valor por defecto
  });

  @override
  _Metodo2TecladoState createState() => _Metodo2TecladoState();
}

class _Metodo2TecladoState extends State<Metodo2Teclado> {
  String _categoriaSeleccionada = "comunes"; // Categoría seleccionada por defecto
  List<String> _silabasActuales = []; // Lista de sílabas actuales
  bool _modoAcentuado = false; // Modo acentuado desactivado por defecto
  bool _cerrarAutomaticamente = true; // Estado inicial del check

  @override
  void didUpdateWidget(Metodo2Teclado oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Actualizar las sílabas cuando se selecciona una letra
    if (oldWidget.letraSeleccionada != widget.letraSeleccionada) {
      setState(() {
        _categoriaSeleccionada = "comunes"; // Restablecer a "comunes"
        _modoAcentuado = false; // Restablecer modo acentuado
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
    final keyboardWidth = screenWidth * KEYBOARD_WIDTH_FACTOR;
    final buttonWidth = (keyboardWidth - (8 * 6)) / 5; // Cambiar 24 a 8

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
                    childAspectRatio: widget.gridAspectRatio, // Usar parámetro
                  ),
                  itemCount: silabasPorLetra.keys.length, // Número de letras
                  itemBuilder: (context, index) {
                    final letra = silabasPorLetra.keys.elementAt(index);
                    return Draggable<Map<String, dynamic>>(
                      data: {
                        'contenido': letra,
                        'color': BlockColor.blue,
                        'origen': 'teclado'
                      },
                      feedback: Material(
                        color: Colors.transparent,
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: BLOCK_BLUE,
                            borderRadius: BorderRadius.circular(CONTAINER_BORDER_RADIUS),
                          ),
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
                      child: GestureDetector(
                        onTap: () {
                          widget.onLetterPressed(letra);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: BLOCK_BLUE,
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
              color: Colors.black.withOpacity(0), // Fondo transparente
              child: Center(
                child: Container(
                  width: screenWidth * KEYBOARD_WIDTH_FACTOR, // Usar constante
                  height: screenHeight * KEYBOARD_HEIGHT_FACTOR, // Usar constante
                  margin: EdgeInsets.only(bottom: 15, top: 4),
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
                        padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 16.0),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Título a la izquierda
                            Text(
                              "Sílabas con ${widget.letraSeleccionada.toUpperCase()}",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            // Botón de check a la derecha
                            Row(
                              children: [
                                Text(
                                  "Cerrar auto",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(width: 4),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                  icon: Icon(
                                    _cerrarAutomaticamente ? Icons.check_box : Icons.check_box_outline_blank,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _cerrarAutomaticamente = !_cerrarAutomaticamente;
                                      widget.onAutoCerrarChanged(_cerrarAutomaticamente); // Notificar el cambio
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
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
                        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0), // Cambiar 12.0 a 8.0
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              "Mixtas", // Cambiado de posición
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
                              "Trabadas", // Cambiado de posición
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
                              "Tíldes",
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
                              () {
                                setState(() {
                                  _modoAcentuado = false; // Restablecer modo acentuado
                                });
                                widget.onClosePressed();
                              },
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
    return SizedBox(
      width: width,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BUTTON_BORDER_RADIUS),
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: icon ?? Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: BUTTON_TEXT_SIZE,
            ),
          ),
        ),
      ),
    );
  }
}