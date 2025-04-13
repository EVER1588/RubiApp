import 'package:flutter/material.dart';
import '../constants/constants.dart'; // Importar las funciones globales
import '../constants/custombar_screen.dart'; // Importa el nuevo CustomBar
import '../constants/state_manager.dart'; // Añadir esta importación

class Metodo1Screen extends StatefulWidget {
  @override
  _Metodo1ScreenState createState() => _Metodo1ScreenState();
}

class _Metodo1ScreenState extends State<Metodo1Screen> {
  final StateManager stateManager = StateManager();
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
    await decirTexto(text); // Usar la función global
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

  // Agregar botón de reinicio en el CustomBar
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomBar(
        
        onBackPressed: () {
          Navigator.pop(context);
        },
        onResetPressed: () {
          setState(() {
            stateManager.clearMetodo1State();
            _syllables = [''];
            _currentBlockIndex = 0;
            _resetActiveLetters();
          });
        },
      ),
      body: Column(
        children: [
          // Renglón superior: Muestra los bloques de sílabas
          Padding(
            padding: EdgeInsets.all(20),
            child: Wrap(
              spacing: 8.0, // Espacio entre bloques
              children: _syllables.map((syllable) {
                final isValid = _validSyllables.contains(syllable);
                return GestureDetector( // Agregar GestureDetector
                  onTap: () {
                    if (syllable.isNotEmpty) {
                      _speak(syllable); // Leer la sílaba al tocarla
                    }
                  },
                  child: Chip(
                    label: Text(
                      syllable.isNotEmpty ? syllable : '_',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: isValid ? Colors.green : Colors.grey,
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
            ),
          ),

          // Teclado de letras
          Expanded(
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
        // Cambiar el color basado en el estado activo/inactivo
        backgroundColor: _activeLetters[letter]! ? Colors.blueAccent : Colors.grey[400],
        foregroundColor: Colors.white,
        // Usar disabledBackgroundColor para el estado inactivo
        disabledBackgroundColor: Colors.grey[400],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        letter,
        style: TextStyle(
          fontSize: 24,
          // El color del texto también debería cambiar
          color: _activeLetters[letter]! ? Colors.white : Colors.grey[300],
        ),
      ),
    );
  }
}