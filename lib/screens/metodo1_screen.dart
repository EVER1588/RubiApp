import 'package:flutter/material.dart';
import '../constants/constants.dart'; // Importar las funciones globales
import '../constants/custombar_screen.dart'; // Importa el nuevo CustomBar
import '../constants/state_manager.dart'; // Añadir esta importación
import '../widgets/loading_background_image.dart'; // Añadir esta importación
import '../services/tts_manager.dart'; // Importar TtsManager

class Metodo1Screen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomBar(
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: LoadingBackgroundImage(
        imagePath: 'lib/utils/images/metodo1-por_defecto-vertical.png',
        child: _Metodo1ScreenContent(),
      ),
    );
  }
}

class _Metodo1ScreenContent extends StatefulWidget {
  @override
  _Metodo1ScreenContentState createState() => _Metodo1ScreenContentState();
}

class _Metodo1ScreenContentState extends State<_Metodo1ScreenContent> {
  final StateManager stateManager = StateManager();
  final TtsManager ttsManager = TtsManager();
  List<String> _syllables = ['']; // Lista para almacenar bloques de sílabas
  int _currentBlockIndex = 0; // Índice del bloque actual

  // Lista de letras del alfabeto español
  final List<String> _letters = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
    'N', 'Ñ', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
  ];

  // Lista de sílabas válidas en español
  final List<String> _validSyllables = [
    'AL', 'AN', 'AR',
    'EL', 'ES', 'IS', 'AS', 'IN',
    'BA', 'BE', 'BI', 'BO', 'BU',
    'CA', 'CE', 'CI', 'CO', 'CU',
    'DA', 'DE', 'DI', 'DO', 'DU',
    'FA', 'FE', 'FI', 'FO', 'FU',
    'GA', 'GE', 'GI', 'GO', 'GU',
    'HA', 'HE', 'HI', 'HO', 'HU',
    'JA', 'JE', 'JI', 'JO', 'JU',
    'KA', 'KA', 'KI', 'KO', 'KU',
    'LA', 'LE', 'LI', 'LO', 'LU',
    'MA', 'ME', 'MI', 'MO', 'MU',
    'NA', 'NE', 'NI', 'NO', 'NU',
    'ÑA', 'ÑE', 'ÑI', 'ÑO', 'ÑU',
    'PA', 'PE', 'PI', 'PO', 'PU',
    'RA', 'RE', 'RI', 'RO', 'RU',
    'SA', 'SE', 'SI', 'SO', 'SU',
    'TA', 'TE', 'TI', 'TO', 'TU',
    'UN', 'US',
    'VA', 'VE', 'VI', 'VO', 'VU',
    'ZA', 'ZE', 'ZI', 'ZO', 'ZU',
    'BLA', 'BLE', 'BLI', 'BLO', 'BLU',
    'CLA', 'CLE', 'CLI', 'CLO', 'CLU',
    'FLA', 'FLE', 'FLI', 'FLO', 'FLU',
    'GLA', 'GLE', 'GLI', 'GLO', 'GLU',
    'PLA', 'PLE', 'PLI', 'PLO', 'PLU',
    'TRA', 'TRE', 'TRI', 'TRO', 'TRU',
    'LLA', 'LLE', 'LLI', 'LLO', 'LLU',
    'CRA', 'CRE', 'CRI', 'CRO', 'CRU',
    'FRA', 'FRE', 'FRI', 'FRO', 'FRU',
    'GRA', 'GRE', 'GRI', 'GRO', 'GRU',
    'PRA', 'PRE', 'PRI', 'PRO', 'PRU',
    'QUE', 'QUI',
  ];

  // Mapa para controlar qué letras están activas
  Map<String, bool> _activeLetters = {
    'A': true, 'B': true, 'C': true, 'D': true, 'E': true, 'F': true, 'G': true,
    'H': true, 'I': true, 'J': true, 'K': true, 'L': true, 'M': true, 'N': true,
    'Ñ': true, 'O': true, 'P': true, 'Q': true, 'R': true, 'S': true, 'T': true,
    'U': true, 'V': true, 'W': true, 'X': true, 'Y': true, 'Z': true,
  };

  @override
  void initState() {
    super.initState();
    ttsManager.initialize();
    // Recuperar el estado guardado
    _syllables = List.from(stateManager.syllablesM1);
    _currentBlockIndex = stateManager.currentBlockIndexM1;
    _activeLetters = Map.from(stateManager.activeLettersM1);

    // Inicializar TTS
    configurarFlutterTts();

    // Si no hay estado previo, inicializar con valores por defecto
    if (_syllables.isEmpty) {
      _syllables = [''];
      _resetActiveLetters();
    }
  }

  @override
  void dispose() {
    // Guardar el estado actual antes de cerrar la pantalla
    stateManager.syllablesM1 = List.from(_syllables);
    stateManager.currentBlockIndexM1 = _currentBlockIndex;
    stateManager.activeLettersM1 = Map.from(_activeLetters);
    super.dispose();
  }

  // Reproduce el texto usando TTS
  Future<void> _speak(String text) async {
    await ttsManager.speak(text, isSyllable: text.length <= 2);
  }

  // Modificar el método _addLetter en _Metodo1ScreenState
  void _addLetter(String letter) async {
    if (!_activeLetters[letter]!) return; // Ignorar letras desactivadas

    await _speak(letter); // Primero reproducir el sonido de la letra

    setState(() {
      String newSyllable = _syllables[_currentBlockIndex] + letter;
      _syllables[_currentBlockIndex] = newSyllable;

      // Desactivar todas las letras primero
      _activeLetters.updateAll((key, value) => false);

      // Validación mejorada después de agregar una letra
      if (newSyllable.length == 1) {
        // Primera letra: habilitar solo las que pueden formar sílabas válidas
        for (String validSyllable in _validSyllables) {
          if (validSyllable.startsWith(newSyllable)) {
            if (validSyllable.length > 1) {
              String segundaLetra = validSyllable[1];
              if (segundaLetra != letter) {
                _activeLetters[segundaLetra] = true;
              }
            }
          }
        }
      } else if (newSyllable.length >= 2) {
        // Segunda letra o más: verificar posibles continuaciones
        bool formasSilabaValida = false;
        
        // Verificar si la sílaba actual puede continuar
        for (String validSyllable in _validSyllables) {
          if (validSyllable.startsWith(newSyllable)) {
            formasSilabaValida = true;
            // Si la sílaba puede continuar, activar las letras que pueden seguir
            if (validSyllable.length > newSyllable.length) {
              String siguienteLetra = validSyllable[newSyllable.length];
              _activeLetters[siguienteLetra] = true;
            }
          }
        }

        if (!formasSilabaValida) {
          // Si no forma una sílaba válida, eliminar la última letra
          _syllables[_currentBlockIndex] = newSyllable.substring(0, newSyllable.length - 1);
          // Revalidar las letras disponibles para la sílaba anterior
          String silabaAnterior = _syllables[_currentBlockIndex];
          for (String validSyllable in _validSyllables) {
            if (validSyllable.startsWith(silabaAnterior)) {
              if (validSyllable.length > silabaAnterior.length) {
                String siguienteLetra = validSyllable[silabaAnterior.length];
                _activeLetters[siguienteLetra] = true;
              }
            }
          }
        } else if (_validSyllables.contains(newSyllable)) {
          // Si forma una sílaba completa válida
          _syllables[_currentBlockIndex] = newSyllable;
          _moveToNextBlock();
          _resetActiveLetters();
          _speak(newSyllable);
          
          // Actualizar el contador global de sílabas
          stateManager.actualizarContadores(nuevaSilaba: true);
        }
        // Si no es una sílaba completa pero es válida, las letras ya están actualizadas
      }
    });
  }

  // Restaura todas las letras como activas
  void _resetActiveLetters() {
    _activeLetters.updateAll((key, value) => true); // Activar todas las letras
  }

  // Moverse al siguiente bloque
  void _moveToNextBlock() {
    setState(() {
      _syllables.add(''); // Agregar un nuevo bloque vacío
      _currentBlockIndex++; // Incrementar el índice del bloque actual
    });
  }

  // Borra la última letra del bloque actual
  void _deleteLastLetter() {
    if (_syllables[_currentBlockIndex].isNotEmpty) {
      setState(() {
        _syllables[_currentBlockIndex] =
            _syllables[_currentBlockIndex].substring(0, _syllables[_currentBlockIndex].length - 1);
      });
    }
    _resetActiveLetters(); // Restaurar todas las letras si se borra algo
  }

  // Limpia toda la sílaba formada
  void _clearSyllable() {
    setState(() {
      _syllables = ['']; // Reiniciar la lista de bloques
      _currentBlockIndex = 0; // Reiniciar el índice del bloque actual
    });
    _resetActiveLetters(); // Restaurar todas las letras
  }

  @override
  Widget build(BuildContext context) {
    // Detectar la orientación de la pantalla
    final Orientation orientation = MediaQuery.of(context).orientation;

    // Para orientación horizontal (landscape)
    if (orientation == Orientation.landscape) {
      return Row(
        children: [
          // Contenedor de sílabas (izquierda)
          Expanded(
            flex: 20, // Ya tienes ajustado este valor
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Container(
                // Usar LayoutBuilder para obtener dimensiones disponibles
                height: MediaQuery.of(context).size.height * 0.85, // Usar un porcentaje de la altura de la pantalla
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 65, 183, 230).withOpacity(0.7),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      spreadRadius: 3,
                      blurRadius: 3,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Lista de sílabas con scroll
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          alignment: WrapAlignment.start,
                          children: [
                            // Lista de sílabas
                            ...(_syllables.map((syllable) {
                              final isValid = _validSyllables.contains(syllable);
                              return syllable.isEmpty ? SizedBox() : GestureDetector(
                                onTap: () {
                                  if (syllable.isNotEmpty) {
                                    _speak(syllable);
                                  }
                                },
                                child: Chip(
                                  label: Text(
                                    syllable,
                                    style: TextStyle(
                                      fontSize: 24, // Ligeramente más pequeño en horizontal
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  backgroundColor: isValid ? Colors.green : Colors.grey,
                                  side: BorderSide(
                                    color: Colors.black,
                                    width: 1.0,
                                  ),
                                  labelPadding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  padding: EdgeInsets.all(4),
                                ),
                              );
                            }).toList()),
                            // Bloque actual de edición
                            if (_syllables[_currentBlockIndex].isEmpty)
                              Chip(
                                label: Text(
                                  '_',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor: Colors.blueGrey,
                                side: BorderSide(
                                  color: Colors.black,
                                  width: 1.0,
                                ),
                                labelPadding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                padding: EdgeInsets.all(4),
                              ),
                          ],
                        ),
                      ),
                    ),
                    // Botones para limpiar y borrar
                    Positioned(
                      bottom: 5,
                      right: 5,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Botón limpiar todo
                          GestureDetector(
                            onTap: _clearSyllable,
                            child: Container(
                              width: 40,
                              height: 40,
                              margin: EdgeInsets.only(right: 8, bottom: 3),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.black.withOpacity(0.3),
                                  width: 2.0,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.cleaning_services,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                          // Botón borrar última letra
                          GestureDetector(
                            onTap: _deleteLastLetter,
                            child: Container(
                              width: 60, // Más pequeño en horizontal
                              height: 60, // Más pequeño en horizontal
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.black.withOpacity(0.3),
                                  width: 2.0,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.backspace,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Teclado de letras (derecha)
          Expanded(
            flex: 20, // Toma aproximadamente 2/3 del ancho
            child: Container(
              margin: EdgeInsets.fromLTRB(5, 10, 10, 10),
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.3),
                borderRadius: BorderRadius.circular(15),
              ),
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final double availableWidth = constraints.maxWidth;
                  final double availableHeight = constraints.maxHeight;
                  
                  // En horizontal, usamos 6 columnas en lugar de 4
                  final int columns = 6;
                  final int numberOfRows = ((_letters.length / columns) + 0.6).ceil();
                  
                  final double horizontalSpacing = 6.0;
                  final double buttonWidth = (availableWidth - (horizontalSpacing * (columns + 1))) / columns;
                  
                  final double fontSize = buttonWidth * 0.5;
                  
                  final double totalVerticalSpace = 2.0 * (numberOfRows + 1);
                  final double buttonHeight = (availableHeight - totalVerticalSpace) / numberOfRows;
                  final double childAspectRatio = buttonWidth / buttonHeight;
                  
                  return GridView.builder(
                    padding: EdgeInsets.all(4),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: horizontalSpacing,
                      mainAxisSpacing: 6.0,
                      childAspectRatio: childAspectRatio,
                    ),
                    itemCount: _letters.length,
                    itemBuilder: (context, index) {
                      return _buildLetterButton(_letters[index], fontSize);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      );
    } 
    // Para orientación vertical (portrait) - mantener el diseño original
    else {
      return Column(
        children: [
          // Contenedor 1: Para mostrar las sílabas formadas
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.98,
              height: 370,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 65, 183, 230).withOpacity(0.7),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    spreadRadius: 3,
                    blurRadius: 3,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              // El resto del contenido del contenedor vertical es el mismo...
              child: Stack(
                children: [
                  // Código actual para modo vertical...
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        alignment: WrapAlignment.start,
                        children: [
                          ...(_syllables.map((syllable) {
                            // Contenido actual...
                            final isValid = _validSyllables.contains(syllable);
                            return syllable.isEmpty ? SizedBox() : GestureDetector(
                              onTap: () {
                                if (syllable.isNotEmpty) {
                                  _speak(syllable);
                                }
                              },
                              child: Chip(
                                // Mantener el diseño actual...
                                label: Text(
                                  syllable,
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor: isValid ? Colors.green : Colors.grey,
                                side: BorderSide(
                                  color: Colors.black,
                                  width: 1.0,
                                ),
                                labelPadding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                padding: EdgeInsets.all(4),
                              ),
                            );
                          }).toList()),
                          if (_syllables[_currentBlockIndex].isEmpty)
                            Chip(
                              label: Text(
                                '_',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: Colors.blueGrey,
                              side: BorderSide(
                                color: Colors.black,
                                width: 1.0,
                              ),
                              labelPadding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              padding: EdgeInsets.all(4),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 5,
                    right: 5,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: _clearSyllable,
                          child: Container(
                            width: 40,
                            height: 40,
                            margin: EdgeInsets.only(right: 8, bottom: 3),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.black.withOpacity(0.3),
                                width: 2.0,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.cleaning_services,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _deleteLastLetter,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.black.withOpacity(0.3),
                                width: 2.0,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.backspace,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Teclado de letras (actual para modo vertical)
          Expanded(
            child: Container(
              // Código actual del teclado para orientación vertical...
              margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.3),
                borderRadius: BorderRadius.circular(15),
              ),
              child: LayoutBuilder(
                // Código actual del LayoutBuilder...
                builder: (BuildContext context, BoxConstraints constraints) {
                  final double availableWidth = constraints.maxWidth;
                  final double availableHeight = constraints.maxHeight;

                  final int numberOfRows = ((_letters.length / 4) + 0.6).ceil();
                  final double horizontalSpacing = 8.0;
                  final double buttonWidth = (availableWidth - (horizontalSpacing * 5)) / 4;
                  final double fontSize = buttonWidth * 0.4;
                  final double totalVerticalSpace = 3.0 * (numberOfRows + 1);
                  final double buttonHeight = (availableHeight - totalVerticalSpace) / numberOfRows;
                  final double childAspectRatio = buttonWidth / buttonHeight;

                  return GridView.builder(
                    padding: EdgeInsets.all(4),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: horizontalSpacing,
                      mainAxisSpacing: 8.0,
                      childAspectRatio: childAspectRatio,
                    ),
                    itemCount: _letters.length,
                    itemBuilder: (context, index) {
                      return _buildLetterButton(_letters[index], fontSize);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      );
    }
  }

  // Construye un botón de letra con transparencia
  Widget _buildLetterButton(String letter, double fontSize) {
    return Container(
      // Usar Container personalizado en lugar de ElevatedButton para mayor control
      decoration: BoxDecoration(
        color: _activeLetters[letter]! 
            ? const Color.fromARGB(255, 34, 115, 255).withOpacity(0.9)  // 90% opacidad para botones activos
            : Colors.grey[400]!.withOpacity(0.7), // 70% opacidad para botones inactivos
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _activeLetters[letter]! 
              ? const Color.fromARGB(255, 10, 97, 184).withOpacity(0.8)
              : Colors.grey.shade600.withOpacity(0.6),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,  // Material transparente para el efecto de ink
        child: InkWell(
          onTap: _activeLetters[letter]! ? () => _addLetter(letter) : null,
          borderRadius: BorderRadius.circular(10),
          splashColor: Colors.white.withOpacity(0.3),  // Efecto splash semi-transparente
          highlightColor: Colors.white.withOpacity(0.2), // Color de resaltado semi-transparente
          child: Container(
            alignment: Alignment.center, // Asegura centrado perfecto
            child: FittedBox(
              fit: BoxFit.contain,
              child: Padding(
                padding: const EdgeInsets.all(2.0), // Pequeño padding para evitar recortes
                child: Text(
                  letter,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: _activeLetters[letter]! 
                        ? Colors.white.withOpacity(0.9)  // Texto ligeramente transparente
                        : Colors.white.withOpacity(0.5), // Texto más transparente para botones inactivos
                  ),
                  textAlign: TextAlign.center, // Asegurar que el texto esté centrado
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}