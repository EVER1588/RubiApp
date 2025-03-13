import 'package:flutter/material.dart';
import 'metodo2teclado_screen.dart';

class Metodo2Screen extends StatefulWidget {
  const Metodo2Screen({Key? key}) : super(key: key);

  @override
  _Metodo2ScreenState createState() => _Metodo2ScreenState();
}

class _Metodo2ScreenState extends State<Metodo2Screen> {
  bool _isDraggingOverTarget = false;
  List<String> selectedSilabas = [];
  final List<String> _validWords = [
    "HUMANIDAD", "HUMANO", "PERSONA", "GENTE", "HOMBRE", "MUJER",
    "SÍ", "NO", "GRACIAS"
  ];

  bool _isValidPrefix(String prefix) {
    print('Prefijo a verificar: $prefix');
    for (String word in _validWords) {
      if (word.startsWith(prefix)) {
        return true;
      }
    }
    return false;
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
                    color: Colors.orange.withAlpha((0.8 * 255).round()),
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
                    color: Colors.orange.withAlpha((0.8 * 255).round()),
                    spreadRadius: screenWidth * 0.005,
                    blurRadius: screenWidth * 0.01,
                    offset: Offset(0, screenHeight * 0.005),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  DragTarget<String>(
                    builder: (BuildContext context, List<String?> incoming, List<dynamic> rejected) {
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          return Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              color: _isDraggingOverTarget ? Colors.yellow : Colors.green,
                              borderRadius: BorderRadius.circular(screenWidth * 0.025),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withAlpha((0.8 * 255).round()),
                                  spreadRadius: screenWidth * 0.005,
                                  blurRadius: screenWidth * 0.01,
                                  offset: Offset(0, screenHeight * 0.005),
                                ),
                              ],
                            ),
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
                      );
                    },
                    onWillAccept: (data) {
                      setState(() {
                        _isDraggingOverTarget = true;
                      });
                      return true;
                    },
                    onLeave: (data) {
                      setState(() {
                        _isDraggingOverTarget = false;
                      });
                    },
                    onAcceptWithDetails: (details) {
                      setState(() {
                        _isDraggingOverTarget = false;
                        final droppedSyllable = details.data;

                        // Agrega la sílaba arrastrada a la lista selectedSilabas
                        selectedSilabas.add(droppedSyllable);

                        // Imprime la lista selectedSilabas para verificar
                        print('selectedSilabas: $selectedSilabas');
                      });
                    },
                  ),
                  Positioned(
                    bottom: screenHeight * 0.005,
                    right: screenWidth * 0.025,
                    child: DragTarget<String>(
                      builder: (BuildContext context, List<String?> incoming, List<dynamic> rejected) {
                        return Container(
                          height: screenWidth * 0.15,
                          width: screenWidth * 0.15,
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(screenWidth * 0.025),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withAlpha((0.8 * 255).round()),
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
                      onWillAccept: (data) {
                        setState(() {
                          _isDraggingOverTarget = true;
                        });
                        return true;
                      },
                      onLeave: (data) {
                        setState(() {
                          _isDraggingOverTarget = false;
                        });
                      },
                      onAcceptWithDetails: (details) {
                        setState(() {
                          _isDraggingOverTarget = false;
                          final droppedSyllable = details.data;
                          selectedSilabas.remove(droppedSyllable);
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Metodo2Teclado(
                onSyllableSelected: (silaba) {
                  setState(() {
                    selectedSilabas.add(silaba);
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableSyllableBlock(String silaba, int index, double screenWidth, double screenHeight) {
    Color blockColor;
    final isValidWord = _validWords.contains(silaba.toUpperCase());
    final isValidPrefix = _isValidPrefix(silaba.toUpperCase());

    print('Silaba: $silaba, isValidWord: $isValidWord, isValidPrefix: $isValidPrefix');

    if (isValidWord) {
      blockColor = Colors.green;
    } else if (isValidPrefix) {
      blockColor = Colors.orange;
    } else {
      blockColor = Colors.grey;
    }

    return Draggable<String>(
      data: silaba,
      feedback: Material(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.025,
            vertical: screenHeight * 0.005,
          ),
          decoration: BoxDecoration(
            color: Colors.orange.withAlpha((0.8 * 255).round()),
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
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.025,
          vertical: screenHeight * 0.005,
        ),
        decoration: BoxDecoration(
          color: blockColor,
          borderRadius: BorderRadius.circular(screenWidth * 0.025),
        ),
        child: Text(
          silaba,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      onDragStarted: () {},
      onDragCompleted: () {},
      onDraggableCanceled: (velocity, offset) {
        setState(() {
          selectedSilabas.insert(index, silaba);
        });
      },
    );
  }
}