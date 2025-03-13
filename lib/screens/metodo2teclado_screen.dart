import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class Metodo2Teclado extends StatefulWidget {
  final Function(String) onSyllableSelected;
  const Metodo2Teclado({Key? key, required this.onSyllableSelected}) : super(key: key);

  @override
  _Metodo2TecladoState createState() => _Metodo2TecladoState();
}

class _Metodo2TecladoState extends State<Metodo2Teclado> {
  final FlutterTts flutterTts = FlutterTts();
  bool isGridVisible = false;
  String? letraSeleccionada;

  // Lista de sílabas por letra
  Map<String, List<String>> silabasPorLetra = {
    "A": ["Á", "A", "AL", "AN", "AR", "AS", "AM"],
    "B": ["B", "BA", "BE", "BI", "BO", "BU", "BLA", "BLE", "BLI", "BLO", "BLU"],
    "C": ["C", "CA", "CE", "CI", "CO", "CU", "CLA", "CLE", "CLI", "CLO", "CLU", "CRA", "CRE", "CRI", "CRO", "CRU","CIAS"],
    "D": ["D", "DA", "DE", "DI", "DO", "DU"],
    "E": ["É", "E", "EL", "EM", "EN", "ES", "ER"],
    "F": ["F", "FA", "FE", "FI", "FO", "FU", "FLA", "FLE", "FLI", "FLO", "FLU", "FRA", "FRE", "FRI", "FRO", "FRU"],
    "G": ["G", "GA", "GE", "GI", "GO", "GU", "GUN", "GEN", "GUA", "GUE", "GUI", "GLA", "GLE", "GLI", "GLO", "GLU", "GRA", "GRE", "GRI", "GRO", "GRU"],
    "H": ["H", "HA", "HE", "HI", "HIS", "HO", "HU"],
    "I": ["Í", "I", "IS", "IN", "IR", "IM"],
    "J": ["J", "JA", "JE", "JI", "JO", "JU"],
    "K": ["K", "KA", "KE", "KI", "KO", "KU"],
    "L": ["L", "LA", "LE", "LI", "LO", "LU", "LAS", "LOS", "LUZ", "LLA", "LLE", "LLI", "LLO", "LLU"],
    "M": ["M", "MA", "ME", "MI", "MO", "MU", "MAS", "MES", "MIS", "MOS"],
    "N": ["N", "NA", "NE", "NI", "NO", "NU"],
    "Ñ": ["Ñ", "ÑA", "ÑE", "ÑI", "ÑO", "ÑU"],
    "O": ["Ó", "O", "OS", "ON"],
    "P": ["P", "PA", "PE", "PI", "PO", "PU", "PLA", "PLE", "PLI", "PLO", "PLU", "PRA", "PRE", "PRI", "PRO", "PRU"],
    "Q": ["Q", "QUE", "QUI"],
    "R": ["R", "RA", "RE", "RI", "RO", "RU"],
    "S": ["S", "SA", "SE", "SI", "SO", "SU"],
    "T": ["T", "TA", "TE", "TI", "TO", "TU", "TRA", "TRE", "TRI", "TRO", "TRU"],
    "U": ["Ú", "U", "UL", "UN", "UR", "US"],
    "V": ["V", "VA", "VE", "VI", "VO", "VU"],
    "W": ["W", "WEB", "WI"],
    "X": ["X", "XA", "XE", "XI"],
    "Y": ["Y", "YA", "YO"],
    "Z": ["Z", "ZA", "ZE", "ZI", "ZO", "ZU"],
   // Agrega más letras según sea necesario
  };

  // Método para reproducir voz
void _speak(String text) async {
  await flutterTts.speak(text);
}

// Mostrar cuadrícula flotante
void _showFloatingGrid(String letter) {
  setState(() {
    letraSeleccionada = letter;
    isGridVisible = true;
  });
}

// Cerrar cuadrícula flotante
void _closeFloatingGrid() {
  setState(() {
    isGridVisible = false;
  });
}

@override
Widget build(BuildContext context) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final double maxWidth = constraints.maxWidth;
      final double maxHeight = constraints.maxHeight;

      // Tamaños relativos para la cuadrícula flotante
      final double floatingGridHeight = maxHeight * 0.7;
      final double gridPadding = maxWidth * 0.025;
      final double gridBorderRadius = maxWidth * 0.025;
      final double gridSpacing = maxWidth * 0.02;
      final double closeButtonSize = maxWidth * 0.10;

      return Stack(
        children: [
          _buildKeyboard(),
          if (isGridVisible)
            Positioned(
              top: gridPadding,
              left: gridPadding,
              right: gridPadding,
              child: Material(
                elevation: maxWidth * 0.005,
                borderRadius: BorderRadius.circular(gridBorderRadius),
                child: Container(
                  height: floatingGridHeight,
                  padding: EdgeInsets.all(gridPadding),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(gridBorderRadius),
                  ),
                  child: Stack(
                    children: [
                      GridView.builder(
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          crossAxisSpacing: gridSpacing,
                          mainAxisSpacing: gridSpacing,
                          childAspectRatio: 1.5,
                        ),
                        itemCount: silabasPorLetra[letraSeleccionada]?.length ?? 0,
                        itemBuilder: (context, index) {
                          final silaba = silabasPorLetra[letraSeleccionada]![index];
                          return Draggable<String>(
                            data: silaba,
                            feedback: Material(
                              child: Container(
                                padding: EdgeInsets.all(gridPadding),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withAlpha((0.8 * 255).round()),
                                  borderRadius: BorderRadius.circular(gridBorderRadius),
                                ),
                                child: Center(
                                  child: Text(
                                    silaba,
                                    style: TextStyle(fontSize: maxWidth * 0.035, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                            childWhenDragging: Container(),
                            child: GestureDetector(
                              onTap: () {
                                // Solo leer la sílaba en voz alta
                                _speak(silaba);
                              },
                              child: Container(
                                padding: EdgeInsets.all(gridPadding),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(gridBorderRadius),
                                ),
                                child: Center(
                                  child: Text(
                                    silaba,
                                    style: TextStyle(fontSize: maxWidth * 0.035, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      // Botón de cierre: redondo, rojo y posicionado en la esquina inferior derecha
                      Positioned(
                        bottom: gridPadding,
                        right: gridPadding,
                        child: GestureDetector(
                          onTap: _closeFloatingGrid,
                          child: Container(
                            width: closeButtonSize,
                            height: closeButtonSize,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withAlpha((0.8 * 255).round()),
                                  spreadRadius: maxWidth * 0.005,
                                  blurRadius: maxWidth * 0.01,
                                  offset: Offset(0, maxHeight * 0.005),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: maxWidth * 0.08,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      );
    },
  );
}

// Construir el teclado principal
Widget _buildKeyboard() {
  final double screenWidth = MediaQuery.of(context).size.width;
  final double keyboardPadding = screenWidth * 0.04;
  final double keyboardSpacing = screenWidth * 0.02;
  final double keyboardBorderRadius = screenWidth * 0.025;
  final List<String> letras = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
    'N', 'Ñ', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
  ];

  return GridView.builder(
    padding: EdgeInsets.all(keyboardPadding),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 5,
      crossAxisSpacing: keyboardSpacing,
      mainAxisSpacing: keyboardSpacing,
      childAspectRatio: 1.5,
    ),
    itemCount: letras.length,
    itemBuilder: (context, index) {
      final letra = letras[index];
      return GestureDetector(
        onTap: () {
          // Solo leer la letra en voz alta
          _speak(letra);
          _showFloatingGrid(letra);
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(keyboardBorderRadius),
          ),
          child: Center(
            child: Text(
              letra,
              style: TextStyle(fontSize: screenWidth * 0.05, color: Colors.white),
            ),
          ),
        ),
      );
    },
  );
}
}