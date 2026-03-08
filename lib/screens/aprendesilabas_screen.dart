import 'package:flutter/material.dart';
import '../services/tts_manager.dart';
import '../widgets/boton_de_borrar.dart';

class Metodo1Screen extends StatefulWidget {
  @override
  _Metodo1ScreenState createState() => _Metodo1ScreenState();
}

class _Metodo1ScreenState extends State<Metodo1Screen> {
  // Eliminamos FlutterTts local y usamos TtsManager.instance
  List<String> _syllables = ['']; // Lista para almacenar bloques de sílabas
  int _currentBlockIndex = 0; // Índice del bloque actual
  
  // Controller para el scroll del contenedor de sílabas
  late ScrollController _scrollController;
  
  // Controlar si mostrar letras sueltas o bloque formado
  bool _showCurrentLooseLetters = true;

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
    'LA', 'LE', 'LI', 'LO', 'LU',
    'MA', 'ME', 'MI', 'MO', 'MU',
    'NA', 'NE', 'NI', 'NO', 'NU',
    'ÑA', 'ÑE', 'ÑI', 'ÑO', 'ÑU',
    'PA', 'PE', 'PI', 'PO', 'PU',
    'RA', 'RE', 'RI', 'RO', 'RU',
    'SA', 'SE', 'SI', 'SO', 'SU',
    'TA', 'TE', 'TI', 'TO', 'TU',
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
    _scrollController = ScrollController();
    TtsManager.instance.init(); // Inicializamos el manager centralizado
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Reproduce el texto usando TtsManager
  Future<void> _speak(String text) async {
    await TtsManager.instance.speak(text);
  }

  // Convierte sílabas a minúsculas (excepto la primera letra) para lectura natural
  String _convertSyllableForSpeech(String syllable) {
    if (syllable.isEmpty) return syllable;
    // Primera letra mayúscula, resto minúsculas
    return syllable[0] + syllable.substring(1).toLowerCase();
  }

  // Agrega una letra al bloque actual y valida la sílaba
  void _addLetter(String letter) async {
    if (!_activeLetters[letter]!) return; // Ignorar letras desactivadas

    setState(() {
      _syllables[_currentBlockIndex] += letter; // Agregar la letra al bloque actual
      _showCurrentLooseLetters = true; // Mostrar letras sueltas mientras escribes
      
      // Validar y actualizar el estado del teclado DENTRO del setState
      if (_syllables[_currentBlockIndex].length == 1) {
        _updateActiveLetters(_syllables[_currentBlockIndex]);
      } else if (_syllables[_currentBlockIndex].length >= 2) {
        if (_validSyllables.contains(_syllables[_currentBlockIndex])) {
          // La sílaba es válida, desactivar todas las letras mientras se reproduce
          _activeLetters.updateAll((key, value) => false);
        } else {
          // La sílaba aún no está completa, actualizar letras válidas
          _updateActiveLetters(_syllables[_currentBlockIndex]);
        }
      }
    });

    await _speak(letter); // Reproduce el sonido de la letra

    // Si la sílaba es válida, seguir el nuevo flujo
    if (_syllables[_currentBlockIndex].length >= 2 && 
        _validSyllables.contains(_syllables[_currentBlockIndex])) {
      
      // PASO 1: Ya se leyó la última letra arriba, esperar un momento
      await Future.delayed(Duration(milliseconds: 500));
      
      // Guarda la sílaba formada
      String formedSyllable = _syllables[_currentBlockIndex];
      
      // PASO 2: OCULTAR LETRAS Y MOSTRAR BLOQUE
      setState(() {
        _showCurrentLooseLetters = false;
      });
      
      // Pequeña pausa para que se vea el cambio visual
      await Future.delayed(Duration(milliseconds: 100));
      
      // LEER LA SÍLABA MIENTRAS SE VE EL BLOQUE VERDE
      // Convertir a minúsculas para que suene como una palabra, no como siglas
      await _speak(_convertSyllableForSpeech(formedSyllable));
      
      // Esperar un momento después de leer
      await Future.delayed(Duration(milliseconds: 500));
      
      // Mover al siguiente bloque
      _moveToNextBlock();
      
      // Volver a mostrar letras sueltas para la siguiente sílaba
      setState(() {
        _showCurrentLooseLetters = true;
      });
    }
  }

  // Actualiza las letras activas basadas en la primera o segunda letra seleccionada
  void _updateActiveLetters(String currentSyllable) {
    _activeLetters.updateAll((key, value) => false); // Desactivar todas las letras
    for (String syllable in _validSyllables) {
      if (syllable.startsWith(currentSyllable)) {
        _activeLetters[syllable[currentSyllable.length]] = true; // Activar letras válidas
      }
    }
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
      _resetActiveLetters(); // Reactivar todas las letras para el nuevo bloque
    });
  }

  // Borra la última letra del bloque actual
  void _deleteLastLetter() {
    if (_syllables[_currentBlockIndex].isNotEmpty) {
      setState(() {
        _syllables[_currentBlockIndex] =
            _syllables[_currentBlockIndex].substring(0, _syllables[_currentBlockIndex].length - 1);
        
        // Actualizar letras activas según lo que queda
        if (_syllables[_currentBlockIndex].isEmpty) {
          _resetActiveLetters(); // Si está vacío, activar todas
        } else {
          _updateActiveLetters(_syllables[_currentBlockIndex]); // Si hay contenido, validar
        }
      });
    }
  }

  // Limpia toda la sílaba formada
  void _clearSyllable() {
    setState(() {
      _syllables = ['']; // Reiniciar la lista de bloques
      _currentBlockIndex = 0; // Reiniciar el índice del bloque actual
      _showCurrentLooseLetters = true; // Mostrar letras sueltas de nuevo
    });
    _resetActiveLetters(); // Restaurar todas las letras
  }

  // Maneja la eliminación de una sílaba (más robusto que solo actualizar activeLetters)
  void _handleDeleteSyllable(int indexABorrar) {
    setState(() {
      // Si solo hay un bloque, limpiarlo en lugar de eliminarlo
      if (_syllables.length == 1) {
        _syllables[0] = '';
        _showCurrentLooseLetters = true;
        _currentBlockIndex = 0;
        _resetActiveLetters(); // Aquí sí reseteamos porque está vacío
      } else {
        // Eliminar el bloque en el índice especificado
        _syllables.removeAt(indexABorrar);
        
        // Ajustar el índice actual si es necesario
        if (_currentBlockIndex >= _syllables.length) {
          _currentBlockIndex = _syllables.length - 1;
        }
        
        // Si se elimina el bloque actual, limpiar el estado
        if (indexABorrar == _currentBlockIndex) {
          _syllables[_currentBlockIndex] = '';
          _showCurrentLooseLetters = true;
          _resetActiveLetters(); // Reseteamos porque vaciamos el bloque actual
        } else {
          // SI NO se elimina el bloque actual, MANTENER su estado actual
          // Actualizar las letras activas basadas en lo que ya estés escribiendo
          if (_syllables[_currentBlockIndex].isEmpty) {
            _resetActiveLetters(); // Si está vacío, activar todas
          } else {
            // Si tiene contenido, mantener las letras activas válidas para esa entrada
            _updateActiveLetters(_syllables[_currentBlockIndex]);
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Formar Sílabas'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          // Zona de Sílabas - Contenedor responsivo con Flex
          Flexible(
            flex: 15, // Toma 2 partes del espacio disponible
            child: Container(
              width: double.infinity,
              height: double.infinity, // Expandir al máximo disponible
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              padding: EdgeInsets.only(left: 4, right: 4, top: 4, bottom: 4), // Reducido padding derecho
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent, width: 3),
                borderRadius: BorderRadius.circular(15),
                color: Colors.blue.withOpacity(0.1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Scrollbar(
                    controller: _scrollController,
                    thickness: 8.0, // Grosor de la barra
                    radius: Radius.circular(4.0), // Bordes redondeados
                    thumbVisibility: true, // La barra siempre visible, no se oculta
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: Wrap(
                      spacing: 12.0,
                      runSpacing: 12.0,
                      alignment: WrapAlignment.center,
                      children: [
                        // Mostrar sílabas completadas como bloques verdes
                        // PERO NO mostrar el bloque actual si aún estamos mostrando letras sueltas
                        ..._syllables.asMap().entries.where((entry) {
                          final isValid = _validSyllables.contains(entry.value);
                          final isCurrentBlock = entry.key == _currentBlockIndex;
                          // Mostrar solo si: es válido Y (NO es el bloque actual O ya ocultamos las letras sueltas)
                          return isValid && entry.value.isNotEmpty && (!isCurrentBlock || !_showCurrentLooseLetters);
                        }).map((entry) {
                          return Draggable<Object>(
                            data: {'index': entry.key, 'silaba': entry.value},
                            feedback: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Material(
                                elevation: 8,
                                child: Chip(
                                  label: Text(
                                    entry.value,
                                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                  ),
                                  backgroundColor: Colors.green,
                                  labelStyle: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            childWhenDragging: SizedBox.shrink(), // Desaparece cuando arrastras
                            child: GestureDetector(
                              onTap: () {
                                // Leer la sílaba al tocarla con pronunciación natural
                                _speak(_convertSyllableForSpeech(entry.value));
                              },
                              child: Chip(
                                label: Text(
                                  entry.value,
                                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                                backgroundColor: Colors.green,
                                labelStyle: TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                        }).toList(),
                        
                        // Mostrar letras de la sílaba actual como elementos sueltos SOLO si debe mostrarlas
                        if (_showCurrentLooseLetters && _syllables[_currentBlockIndex].isNotEmpty)
                          ..._syllables[_currentBlockIndex].split('').map((letter) {
                            return Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey, width: 2),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey.withOpacity(0.3),
                              ),
                              child: Text(
                                letter,
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            );
                          }).toList(),
                      ],
                    ),
                  ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: BotonDeBorrar(
                      anchoP: MediaQuery.of(context).size.width,
                      altoP: MediaQuery.of(context).size.height,
                      alBorrar: (data) {
                        if (data is Map && data.containsKey('index')) {
                          int indexABorrar = data['index'];
                          _handleDeleteSyllable(indexABorrar);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Teclado de letras - Flex responsivo
          Flexible(
            flex: 30, // Toma 3 partes del espacio disponible (más grande que sílabas)
            child: GridView.builder(
              padding: EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, // 4 columnas
                crossAxisSpacing: 10, // Espacio horizontal entre letras
                mainAxisSpacing: 10, // Espacio vertical entre letras
                childAspectRatio: 1.5, // Relación de aspecto de los botones
              ),
              itemCount: _letters.length,
              itemBuilder: (context, index) {
                return _buildLetterButton(_letters[index]);
              },
            ),
          ),

          // Botones de borrar y limpiar
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _deleteLastLetter,
                  child: Text('Borrar Última Letra'),
                ),
                ElevatedButton(
                  onPressed: _clearSyllable,
                  child: Text('Limpiar'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Construye un botón de letra
  Widget _buildLetterButton(String letter) {
    return ElevatedButton(
      onPressed: _activeLetters[letter]! ? () => _addLetter(letter) : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: _activeLetters[letter]! ? Colors.blueAccent : Colors.grey,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        letter,
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}