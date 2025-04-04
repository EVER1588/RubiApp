// lib/screens/metodo2teclado_screen.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../constants/constants.dart'; // Importar las funciones globales y silabasPorLetra

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
  String _categoriaSeleccionada = "Directas"; // Categoría seleccionada por defecto
  List<String> _silabasDirectas = [];
  List<String> _silabasMixtas = [];

  @override
  void didUpdateWidget(Metodo2Teclado oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Restablecer la categoría solo si el teclado secundario se abre
    if (oldWidget.letraSeleccionada.isEmpty && widget.letraSeleccionada.isNotEmpty) {
      _categoriaSeleccionada = "Directas"; // Restablecer la categoría a "Directas"
      _actualizarSilabas(widget.letraSeleccionada);
    }
  }

  void _actualizarSilabas(String letra) {
    // Obtener las sílabas correspondientes a la letra seleccionada
    final todasLasSilabas = silabasPorLetra[letra.toUpperCase()] ?? [];

    // Dividir las sílabas en directas y mixtas
    setState(() {
      _silabasDirectas = todasLasSilabas
          .where((silaba) => silaba.length <= 2) // Ejemplo: sílabas directas (1-2 caracteres)
          .toList();
      _silabasMixtas = todasLasSilabas
          .where((silaba) => silaba.length > 2) // Ejemplo: sílabas mixtas (3+ caracteres)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Seleccionar la lista de sílabas según la categoría activa
    final silabasActuales = _categoriaSeleccionada == "Directas"
        ? _silabasDirectas
        : _silabasMixtas;

    return Stack(
      children: [
        // Teclado Principal (siempre visible)
        Positioned.fill(
          child: Column(
            children: [
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.all(8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5, // Número de columnas
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1.3, // Relación de aspecto 1:1 para bloques cuadrados
                  ),
                  itemCount: silabasPorLetra.keys.length, // Número de letras
                  itemBuilder: (context, index) {
                    final letra = silabasPorLetra.keys.elementAt(index);
                    final screenWidth = MediaQuery.of(context).size.width;
                    final blockSize = (screenWidth - (8 * 6)) / 5; // Calcular tamaño del bloque

                    return GestureDetector(
                      onTap: () {
                        widget.onLetterPressed(letra); // Seleccionar letra
                      },
                      child: Container(
                        width: blockSize, // Ancho del bloque
                        height: blockSize, // Alto del bloque
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            letra,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24, // Tamaño del texto
                              fontWeight: FontWeight.bold, // Texto en negrita
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
                  width: screenWidth * 0.9,
                  height: screenHeight * 0.5,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      // Grid de sílabas
                      Expanded(
                        child: GridView.builder(
                          padding: EdgeInsets.all(8),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 1.3, // Relación de aspecto ajustada (cuadrados)
                          ),
                          itemCount: silabasActuales.length,
                          itemBuilder: (context, index) {
                            final silaba = silabasActuales[index];
                            return GestureDetector(
                              onTap: () {
                                flutterTts.speak(silaba); // Leer la sílaba
                              },
                              child: Draggable<Map<String, String>>(
                                data: {
                                  'contenido': silaba,
                                },
                                feedback: Material(
                                  child: Container(
                                    padding: EdgeInsets.all(12), // Aumentar el tamaño del bloque
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade700, // Color más oscuro para el feedback
                                      borderRadius: BorderRadius.circular(15), // Bloques con bordes más redondeados
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 4,
                                          offset: Offset(2, 2), // Sombra para un efecto elevado
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        silaba,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18, // Tamaño de texto más grande
                                          fontWeight: FontWeight.bold, // Texto en negrita
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                childWhenDragging: Opacity(
                                  opacity: 0.5,
                                  child: Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Center(
                                      child: Text(
                                        silaba,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16, // Tamaño del texto cuando se está arrastrando
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                child: Container(
                                  padding: EdgeInsets.all(12), // Ajustar el tamaño del bloque
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(15), // Bordes redondeados
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 4,
                                        offset: Offset(2, 2), // Sombra para un efecto elevado
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      silaba,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16, // Tamaño del texto del bloque principal
                                        fontWeight: FontWeight.bold, // Texto en negrita
                                      ),
                                    ),
                                  ),
                                ),
                                onDragEnd: (details) {
                                  // Cerrar el teclado secundario al finalizar el arrastre
                                  widget.onClosePressed();
                                },
                              ),
                            );
                          },
                        ),
                      ),

                      // Botones de categoría y cerrar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Botón Directas
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _categoriaSeleccionada = "Directas";
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _categoriaSeleccionada == "Directas"
                                  ? Colors.blue
                                  : Colors.grey,
                            ),
                            child: Text("Directas"),
                          ),

                          // Botón Mixtas
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _categoriaSeleccionada = "Mixtas";
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _categoriaSeleccionada == "Mixtas"
                                  ? Colors.blue
                                  : Colors.grey,
                            ),
                            child: Text("Mixtas"),
                          ),

                          // Botón Cerrar
                          ElevatedButton(
                            onPressed: widget.onClosePressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: Icon(Icons.close, color: Colors.white),
                          ),
                        ],
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
}