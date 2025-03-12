import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class Metodo1Screen extends StatefulWidget {
  @override
  _Metodo1ScreenState createState() => _Metodo1ScreenState();
}

class _Metodo1ScreenState extends State<Metodo1Screen> {
  final FlutterTts _flutterTts = FlutterTts(); // Instancia de FlutterTts
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
    _configureTts(); // Configura el TTS al iniciar la pantalla
  }

  // Configura el TTS (idioma, velocidad, volumen, tono)
  void _configureTts() async {
    await _flutterTts.setLanguage("es-MX"); // Español latino (México)
    await _flutterTts.setSpeechRate(1.0); // Velocidad de habla (1.0 es normal)
    await _flutterTts.setVolume(1.0); // Volumen (0.0 a 1.0)
    await _flutterTts.setPitch(1.0); // Tono (0.5 a 2.0)
  }

  // Reproduce el texto usando TTS
  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  // Agrega una letra al bloque actual y valida la sílaba
  void _addLetter(String letter) async {
    if (!_activeLetters[letter]!) return; // Ignorar letras desactivadas

    setState(() {
      _syllables[_currentBlockIndex] += letter; // Agregar la letra al bloque actual
    });

    await _speak(letter); // Reproduce el sonido de la letra

    // Validar y actualizar el estado del teclado
    if (_syllables[_currentBlockIndex].length == 1) {
      _updateActiveLetters(_syllables[_currentBlockIndex]);
    } else if (_syllables[_currentBlockIndex].length >= 2) {
      if (_validSyllables.contains(_syllables[_currentBlockIndex])) {
        await _speak(_syllables[_currentBlockIndex]); // Reproduce la sílaba completa
        _resetActiveLetters(); // Restaurar todas las letras después de formar una sílaba
        _moveToNextBlock(); // Moverse al siguiente bloque
      } else {
        _updateActiveLetters(_syllables[_currentBlockIndex]);
      }
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
          // Renglón superior: Muestra los bloques de sílabas
          Padding(
            padding: EdgeInsets.all(20),
            child: Wrap(
              spacing: 8.0, // Espacio entre bloques
              children: _syllables.map((syllable) {
                final isValid = _validSyllables.contains(syllable);
                return Chip(
                  label: Text(
                    syllable.isNotEmpty ? syllable : '_',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: isValid ? Colors.green : Colors.grey,
                  labelStyle: TextStyle(color: Colors.white),
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