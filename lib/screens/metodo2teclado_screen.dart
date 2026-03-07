// lib/screens/metodo2teclado_screen.dart
import 'package:flutter/material.dart';
<<<<<<< HEAD
import '../services/tts_manager.dart';

class Metodo2Teclado extends StatefulWidget {
  final Function(String) onSyllableSelected;
  const Metodo2Teclado({Key? key, required this.onSyllableSelected}) : super(key: key);

  @override
  _Metodo2TecladoState createState() => _Metodo2TecladoState();
}

class _Metodo2TecladoState extends State<Metodo2Teclado> {
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
    "Z": ["Z", "ZA", "ZE", "ZI", "ZO", "ZU"]
   // Agrega más letras según sea necesario
  };

  // Método para reproducir voz
void _speak(String text) async {
  await TtsManager.instance.speak(text);
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
                                  color: Colors.orange.withOpacity(0.8),
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
                                  color: Colors.black.withOpacity(0.2),
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
=======
import '../constants/constants.dart'; // Importar las funciones globales y silabasClasificadas
import '../constants/concatenacion_screen.dart'; // Importar BlockColor y concatenar bloques
import '../services/tts_manager.dart';

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
  final TtsManager ttsManager = TtsManager();

  String _categoriaSeleccionada = "comunes"; // Categoría seleccionada por defecto
  List<String> _silabasActuales = []; // Lista de sílabas actuales
  bool _modoAcentuado = false; // Modo acentuado desactivado por defecto
  bool _cerrarAutomaticamente = true; // Estado inicial del check

  @override
  void initState() {
    super.initState();
    ttsManager.initialize();
  }

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

  Future<void> _decirSilaba(String silaba) async {
    await ttsManager.speakSpecialSyllable(silaba);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final keyboardWidth = screenWidth * (isLandscape ? 0.45 : KEYBOARD_WIDTH_FACTOR);
    final buttonWidth = (keyboardWidth - (8 * 6)) / 5;

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
                            // Añadir transparencia al color de fondo (0.85 = 85% de opacidad)
                            color: const Color.fromARGB(255, 0, 129, 235).withOpacity(0.85),
                            borderRadius: BorderRadius.circular(CONTAINER_BORDER_RADIUS),
                            border: Border.all(
                              color: Colors.black.withOpacity(0.9), // También hacer el borde ligeramente transparente
                              width: 2.0,
                            ),
                            // Opcional: añadir sombra para mejor efecto visual con transparencia
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              letra,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
>>>>>>> 4d4801eb5df27b08381da363d79fb5703bcc6225
                              ),
                            ),
                          ),
                        ),
                      ),
<<<<<<< HEAD
=======
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
                  width: isLandscape ? screenWidth * 0.45 : screenWidth * KEYBOARD_WIDTH_FACTOR,
                  height: isLandscape ? screenHeight * 0.95 : screenHeight * KEYBOARD_HEIGHT_FACTOR,
                  margin: EdgeInsets.only(
                    bottom: 15,
                    top: isLandscape ? 0 : 4,
                  ),
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
                        child: Column( // Cambiar Stack por Column
                          children: [
                            // Grid de sílabas
                            Expanded( // Envolver el Container en un Expanded
                              child: Container(
                                child: GridView.builder(
                                  padding: EdgeInsets.all(8),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 5,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                    childAspectRatio: isLandscape ? 1.8 : 1.6, // Ajustar aspecto en modo horizontal
                                  ),
                                  itemCount: _silabasActuales.length,
                                  itemBuilder: (context, index) {
                                    final silaba = _silabasActuales[index];
                                    final esPalabraValida = silabasEspeciales.contains(silaba.toUpperCase());
                                    
                                    return GestureDetector(
                                      onTap: () {
                                        _decirSilaba(silaba); // Leer la sílaba
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
                                              border: Border.all(  // Agregar el borde negro
                                                color: Colors.black,
                                                width: 2.0,
                                              ),
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
                                            // Usar el mismo color pero con transparencia
                                            color: esPalabraValida 
                                                ? Colors.green.withOpacity(0.85) 
                                                : Colors.blue.withOpacity(0.85),
                                            borderRadius: BorderRadius.circular(15),
                                            border: Border.all(
                                              color: Colors.black,
                                              width: 2.0,
                                            ),
                                          ),
                                          // Usar Align para garantizar centrado perfecto
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                silaba,
                                                textAlign: TextAlign.center, // Asegura que el texto esté centrado
                                                style: TextStyle(
                                                  color: const Color.fromARGB(255, 255, 255, 255),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20, // Aumentar un poco más el tamaño de fuente
                                                ),
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

                            // Botones inferiores
                            Container(
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 231, 230, 191), // Fondo gris claro
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(KEYBOARD_BORDER_RADIUS),
                                  bottomRight: Radius.circular(KEYBOARD_BORDER_RADIUS),
                                ),
                                border: Border(
                                  top: BorderSide(
                                    color: Colors.black.withOpacity(0.3),
                                    width: 2.0,
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: isLandscape ? 4.0 : 8.0
                                ),
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
                                      height: isLandscape ? 40 : 50, // Ajustar altura en modo horizontal
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
                                      height: isLandscape ? 40 : 50, // Ajustar altura en modo horizontal
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
                                      height: isLandscape ? 40 : 50, // Ajustar altura en modo horizontal
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
                                      height: isLandscape ? 40 : 50, // Ajustar altura en modo horizontal
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
                                      height: isLandscape ? 40 : 50, // Ajustar altura en modo horizontal
                                      icon: Icon(Icons.close, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
>>>>>>> 4d4801eb5df27b08381da363d79fb5703bcc6225
                    ],
                  ),
                ),
              ),
            ),
<<<<<<< HEAD
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
=======
          ),
      ],
    );
  }

  // Método para construir botones redondeados
  Widget _buildRoundedButton(String text, Color color, VoidCallback onPressed, double width, {Icon? icon, double? height}) {
    return SizedBox(
      width: width,
      height: height ?? 50, // Usar altura proporcionada o 50 por defecto
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: height == null ? 8 : 4),
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
              fontSize: height == null ? BUTTON_TEXT_SIZE : BUTTON_TEXT_SIZE - 2,
            ),
          ),
        ),
      ),
    );
  }
>>>>>>> 4d4801eb5df27b08381da363d79fb5703bcc6225
}