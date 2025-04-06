// lib/screens/metodo2teclado_screen.dart
import 'package:flutter/material.dart';
import '../constants/constants.dart'; // Importar las funciones globales y silabasClasificadas

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
    // Declara buttonWidth aquí, a nivel de método
    final buttonWidth = screenWidth * 0.18;

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
                    childAspectRatio: 1.3, // Relación de aspecto ajustada
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
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(10),
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
              color: Colors.black.withOpacity(0.5), // Fondo semi-transparente
              child: Center(
                child: Container(
                  width: screenWidth * 0.9,
                  height: screenHeight * 0.6,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            // Grid de sílabas
                            Container(
                              height: screenHeight * 0.5, // Define una altura específica
                              child: GridView.builder(
                                padding: EdgeInsets.all(8),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 5,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                  childAspectRatio: 1.3, // Relación de aspecto ajustada
                                ),
                                itemCount: _silabasActuales.length,
                                itemBuilder: (context, index) {
                                  final silaba = _silabasActuales[index];
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
                                          padding: EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade700,
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                          child: Center(
                                            child: Text(
                                              silaba,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
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

                      // Botones inferiores
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _categoriaSeleccionada = "comunes";
                                _actualizarSilabas(widget.letraSeleccionada, _categoriaSeleccionada);
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _categoriaSeleccionada == "comunes"
                                  ? Colors.blue
                                  : Colors.grey,
                              fixedSize: Size(buttonWidth, 50), // Usar el ancho calculado
                            ),
                            child: Text("Comunes"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _categoriaSeleccionada = "trabadas";
                                _actualizarSilabas(widget.letraSeleccionada, _categoriaSeleccionada);
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _categoriaSeleccionada == "trabadas"
                                  ? Colors.blue
                                  : Colors.grey,
                              fixedSize: Size(buttonWidth, 50), // Usar el ancho calculado
                            ),
                            child: Text("Trabadas"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _categoriaSeleccionada = "mixtas";
                                _actualizarSilabas(widget.letraSeleccionada, _categoriaSeleccionada);
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _categoriaSeleccionada == "mixtas"
                                  ? Colors.blue
                                  : Colors.grey,
                              fixedSize: Size(buttonWidth, 50), // Usar el ancho calculado
                            ),
                            child: Text("Mixtas"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _modoAcentuado = !_modoAcentuado; // Activar o desactivar el modo acentuado
                                _actualizarSilabas(widget.letraSeleccionada, _categoriaSeleccionada);
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _modoAcentuado ? Colors.orange : Colors.grey,
                              fixedSize: Size(buttonWidth, 50), // Usar el ancho calculado
                            ),
                            child: Text("Acentuadas"),
                          ),
                          ElevatedButton(
                            onPressed: widget.onClosePressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              fixedSize: Size(buttonWidth, 50), // Usar el ancho calculado
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