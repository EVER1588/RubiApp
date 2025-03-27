// lib/screens/metodo2teclado_screen.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Metodo2Teclado extends StatelessWidget {
  final Function(String) onLetterPressed;
  final String letraSeleccionada;

  Metodo2Teclado({
    Key? key,
    required this.onLetterPressed,
    required this.letraSeleccionada,
  }) : super(key: key);

  // Mapa de letras y sus sílabas correspondientes
  final Map<String, List<String>> silabasPorLetra = {
    "A": ["Á", "A", "AL", "AN", "AR", "AS", "AM"],
    "B": ["B", "BA", "BE", "BI", "BO", "BU", "BLA", "BLE", "BLI", "BLO", "BLU"],
    "C": ["C", "CA", "CE", "CI", "CO", "CU", "CLA", "CLE", "CLI", "CLO", "CLU", "CRA", "CRE", "CRI", "CRO", "CRU","CIAS"],
    "D": ["D", "DA", "DE", "DI", "DO", "DU"],
    "E": ["É", "E", "EL", "EM", "EN", "ES", "ER"],
    "F": ["F", "FA", "FE", "FI", "FO", "FU", "FLA", "FLE", "FLI", "FLO", "FLU", "FRA", "FRE", "FRI", "FRO", "FRU"],
    "G": ["G", "GA", "GE", "GI", "GO", "GU", "GEN", "GUA", "GUE", "GUI", "GLA", "GLE", "GLI", "GLO", "GLU", "GRA", "GRE", "GRI", "GRO", "GRU"],
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
    "R": ["R", "RA", "RAL",  "RE", "RI", "RO", "RU"],
    "S": ["S", "SA", "SE", "SI", "SO", "SU"],
    "T": ["T", "TA", "TE", "TI", "TO", "TU", "TRA", "TRE", "TRI", "TRO", "TRU"],
    "U": ["Ú", "U", "UL", "UN", "UR", "US"],
    "V": ["V", "VA", "VE", "VI", "VO", "VU"],
    "W": ["W", "WEB", "WI"],
    "X": ["X", "XA", "XE", "XI"],
    "Y": ["Y", "YA", "YO"],
    "Z": ["Z", "ZA", "ZE", "ZI", "ZO", "ZU",

    ],
    // Agrega más letras y sílabas aquí...
  };

  final List<String> silabasEspeciales = [
    "A", "AL", "DA", "DE", "EL", "EN", "ES", "FE", "HA", "LA",
    "LE", "LAS", "LOS", "LUZ", "ME", "MI", "MAS", "MES", "MIS", "NI",
    "NO", "QUE", "QUI", "SE", "SI", "SU", "TE", "TU", "UN", "VA",
    "VE", "VI", "WEB", "WI", "Y", "YA", "YO",
  ];

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
                  color: Colors.black.withOpacity(0.7),
                ),

                // Contenido del teclado secundario
                Center(
                  child: Container(
                    width: screenWidth * 0.8,
                    height: screenHeight * 0.4,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: GridView.builder(
                      padding: EdgeInsets.all(8),
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: silabasPorLetra[letraSeleccionada]?.length ?? 0,
                      itemBuilder: (context, index) {
                        final silaba = silabasPorLetra[letraSeleccionada]![index];
                        final esSilabaEspecial = silabasEspeciales.contains(silaba);

                        return Draggable<Map<String, String>>(
                          data: {
                            'id': const Uuid().v4(),
                            'contenido': silaba,
                          },
                          onDragCompleted: () {
                            onLetterPressed(""); // Cierra el teclado secundario
                          },
                          feedback: Material(
                            child: Container(
                              width: screenWidth * 0.15,
                              height: screenWidth * 0.15,
                              color: esSilabaEspecial ? Colors.green : Colors.blue,
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
                          childWhenDragging: Opacity(
                            opacity: 0.5,
                            child: Container(
                              width: screenWidth * 0.15,
                              height: screenWidth * 0.15,
                              color: esSilabaEspecial ? Colors.green : Colors.blue,
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
                          child: Container(
                            width: screenWidth * 0.15,
                            height: screenWidth * 0.15,
                            color: esSilabaEspecial ? Colors.green : Colors.blue,
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
                    onPressed: () {
                      onLetterPressed(""); // Cierra el teclado secundario
                    },
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