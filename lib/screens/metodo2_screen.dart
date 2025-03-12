import 'package:flutter/material.dart';
import 'metodo2teclado_screen.dart';

class Metodo2Screen extends StatefulWidget {
  const Metodo2Screen({Key? key}) : super(key: key);

  @override
  _Metodo2ScreenState createState() => _Metodo2ScreenState();
}

class _Metodo2ScreenState extends State<Metodo2Screen> {
  List<String> selectedSilabas = [];
  final List<String> _validWords = [
    "HUMANIDAD", "HUMANO", "PERSONA", "GENTE", "HOMBRE", "MUJER",
    "SÍ", "NO", "GRACIAS"
  ];

  // Función para verificar si una cadena es un prefijo válido
  bool _isValidPrefix(String prefix) {
    return _validWords.any((word) => word.startsWith(prefix));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Método 2'),
      ),
      body: Column(
        children: [
          // Contenedor 1 (Renglón superior)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
            child: Container(
              height: screenHeight * 0.1,
              width: screenWidth * 0.87,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(screenWidth * 0.025),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: screenWidth * 0.005,
                    blurRadius: screenWidth * 0.01,
                    offset: Offset(0, screenHeight * 0.005),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Renglón 1',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          // Contenedor 2 con basurero
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
            child: Container(
              height: screenHeight * 0.3,
              width: screenWidth * 0.87,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(screenWidth * 0.025),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: screenWidth * 0.005,
                    blurRadius: screenWidth * 0.01,
                    offset: Offset(0, screenHeight * 0.005),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  DragTarget<String>(
                    builder: (context, candidateData, rejectedData) {
                      return Container(
                        width: double.infinity,
                        height: double.infinity,
                        child: Wrap(
                          spacing: screenWidth * 0.02,
                          runSpacing: screenWidth * 0.02,
                          children: List.generate(selectedSilabas.length, (index) {
                            final silaba = selectedSilabas[index];
                            return _buildDraggableSyllableBlock(silaba, index, screenWidth, screenHeight);
                          }),
                        ),
                      );
                    },
                    onWillAccept: (data) => true,
                    onAccept: (String silaba) {
                      setState(() => selectedSilabas.add(silaba));
                    },
                  ),
                  Positioned(
                    bottom: screenHeight * 0.005,
                    right: screenWidth * 0.025,
                    child: DragTarget<String>(
                      builder: (context, candidateData, rejectedData) {
                        return Container(
                          height: screenWidth * 0.15,
                          width: screenWidth * 0.15,
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(screenWidth * 0.025),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: screenWidth * 0.005,
                                blurRadius: screenWidth * 0.01,
                                offset: Offset(0, screenHeight * 0.005),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(Icons.delete, color: Colors.white, size: 25),
                          ),
                        );
                      },
                      onWillAccept: (data) => true,
                      onAccept: (String silaba) {
                        setState(() => selectedSilabas.remove(silaba));
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          // Teclado principal
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Metodo2Teclado(
                onSyllableSelected: (silaba) {
                  setState(() => selectedSilabas.add(silaba));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Construye un bloque de sílaba arrastrable
  Widget _buildDraggableSyllableBlock(String silaba, int index, double screenWidth, double screenHeight) {
    // Determinar el color del bloque
    final isValidWord = _validWords.contains(silaba.toUpperCase());
    final isValidPrefix = _isValidPrefix(silaba.toUpperCase());

    return Draggable<String>(
      data: silaba,
      feedback: Material(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.025,
            vertical: screenHeight * 0.005,
          ),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.8),
            borderRadius: BorderRadius.circular(screenWidth * 0.025),
          ),
          child: Text(
            silaba,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.025,
            vertical: screenHeight * 0.005,
          ),
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(screenWidth * 0.025),
          ),
          child: Text(
            silaba,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
      child: DragTarget<String>(
        builder: (context, candidateData, rejectedData) {
          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.025,
              vertical: screenHeight * 0.005,
            ),
            decoration: BoxDecoration(
              color: isValidWord ? Colors.green : (isValidPrefix ? Colors.orange : Colors.grey),
              borderRadius: BorderRadius.circular(screenWidth * 0.025),
            ),
            child: Text(
              silaba,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          );
        },
        onWillAccept: (data) => true,
        onAccept: (String droppedSyllable) {
          setState(() {
            // Concatenar las sílabas
            final combinedWord = '$silaba$droppedSyllable';

            if (_validWords.contains(combinedWord.toUpperCase())) {
              // Fusionar en una palabra válida
              selectedSilabas.removeAt(index); // Eliminar la primera sílaba
              selectedSilabas.remove(droppedSyllable); // Eliminar la segunda sílaba
              selectedSilabas.add(combinedWord); // Agregar la palabra fusionada
            } else if (_isValidPrefix(combinedWord.toUpperCase())) {
              // Fusionar como prefijo válido
              selectedSilabas.removeAt(index); // Eliminar la primera sílaba
              selectedSilabas.remove(droppedSyllable); // Eliminar la segunda sílaba
              selectedSilabas.add(combinedWord); // Agregar el prefijo
            } else {
              // Intercambiar posiciones si no es válido
              final droppedIndex = selectedSilabas.indexOf(droppedSyllable);
              if (droppedIndex != -1) {
                final temp = selectedSilabas[index];
                selectedSilabas[index] = selectedSilabas[droppedIndex];
                selectedSilabas[droppedIndex] = temp;
              }
            }
          });
        },
      ),
      onDragStarted: () {},
      onDragCompleted: () {},
      onDraggableCanceled: (velocity, offset) {
        setState(() => selectedSilabas.insert(index, silaba));
      },
    );
  }
}