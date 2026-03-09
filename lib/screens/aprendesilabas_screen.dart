import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/tts_manager.dart';
import '../widgets/boton_de_borrar.dart';

class Metodo1Screen extends StatefulWidget {
  @override
  _Metodo1ScreenState createState() => _Metodo1ScreenState();
}

class _Metodo1ScreenState extends State<Metodo1Screen> with TickerProviderStateMixin {
  // Eliminamos FlutterTts local y usamos TtsManager.instance
  List<String> _syllables = ['']; // Lista para almacenar bloques de sílabas
  int _currentBlockIndex = 0; // Índice del bloque actual
  
  // Controller para el scroll del contenedor de sílabas
  late ScrollController _scrollController;
  
  // Controlar si mostrar letras sueltas o bloque formado
  bool _showCurrentLooseLetters = true;

  // Keys para la animación de letras volando
  final GlobalKey _syllableContainerKey = GlobalKey();
  final Map<String, GlobalKey> _letterKeys = {};

  // Lista de letras del alfabeto español
  final List<String> _letters = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
    'N', 'Ñ', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
  ];

  // Lista de sílabas válidas en español
  final List<String> _validSyllables = [
    'AL', 'AN', 'AR', 'AS',
    'BA', 'BE', 'BI', 'BO', 'BU',
    'CA', 'CE', 'CI', 'CO', 'CU',
    'DA', 'DE', 'DI', 'DO', 'DU',
    'EL', 'ES', 'EN', 'EX',
    'FA', 'FE', 'FI', 'FO', 'FU',
    'GA', 'GE', 'GI', 'GO', 'GU',
    'HA', 'HE', 'HI', 'HO', 'HU',
    'IS', 'IN',
    'JA', 'JE', 'JI', 'JO', 'JU',
    'KA', 'KE', 'KI', 'KO', 'KU', 
    'LA', 'LE', 'LI', 'LO', 'LU',
    'MA', 'ME', 'MI', 'MO', 'MU',
    'NA', 'NE', 'NI', 'NO', 'NU',
    'ÑA', 'ÑE', 'ÑI', 'ÑO', 'ÑU',
    'OP', 'OR', 'OS',  
    'PA', 'PE', 'PI', 'PO', 'PU',
    'QUE', 'QUI',  
    'RA', 'RE', 'RI', 'RO', 'RU',
    'SA', 'SE', 'SI', 'SO', 'SU',
    'TA', 'TE', 'TI', 'TO', 'TU',
    'UL', 'UN', 'US',  
    'VA', 'VE', 'VI', 'VO', 'VU',
    'WA', 'WI', 
    'XA', 'XE', 'XI', 'XO', 'XU',
    'YA', 'YE', 'YI', 'YO', 'YU',   
    'ZA', 'ZE', 'ZI', 'ZO', 'ZU',
    'BLA', 'BLE', 'BLI', 'BLO', 'BLU',
    'CLA', 'CLE', 'CLI', 'CLO', 'CLU',
    'FLA', 'FLE', 'FLI', 'FLO', 'FLU',
    'GLA', 'GLE', 'GLI', 'GLO', 'GLU',
    'PLA', 'PLE', 'PLI', 'PLO', 'PLU',
    'LLA', 'LLE', 'LLI', 'LLO', 'LLU',
    'CRA', 'CRE', 'CRI', 'CRO', 'CRU',
    'FRA', 'FRE', 'FRI', 'FRO', 'FRU',
    'GRA', 'GRE', 'GRI', 'GRO', 'GRU',
    'PRA', 'PRE', 'PRI', 'PRO', 'PRU',
    'RRA', 'RRE', 'RRI', 'RRO', 'RRU', 
    'TRA', 'TRE', 'TRI', 'TRO', 'TRU',
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
    // Inicializar GlobalKeys para cada letra del teclado
    for (String letter in _letters) {
      _letterKeys[letter] = GlobalKey();
    }
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

  // Anima una letra volando desde el teclado hasta el contenedor de sílabas
  Future<void> _flyLetterAnimation(String letter) async {
    final sourceKey = _letterKeys[letter];
    if (sourceKey?.currentContext == null ||
        _syllableContainerKey.currentContext == null ||
        !mounted) {
      return;
    }

    final sourceBox = sourceKey!.currentContext!.findRenderObject() as RenderBox;
    final sourceSize = sourceBox.size;
    final sourcePos = sourceBox.localToGlobal(
      Offset(sourceSize.width / 2, sourceSize.height / 2),
    );

    final targetBox =
        _syllableContainerKey.currentContext!.findRenderObject() as RenderBox;
    final targetSize = targetBox.size;
    final targetPos = targetBox.localToGlobal(
      Offset(targetSize.width / 2, targetSize.height / 2),
    );

    final screenHeight = MediaQuery.of(context).size.height;
    final arcHeight = -screenHeight * 0.1;

    final controller = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    final curved = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOutCubic,
    );

    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) {
        return AnimatedBuilder(
          animation: curved,
          builder: (context, child) {
            final t = curved.value;
            final dx = sourcePos.dx + (targetPos.dx - sourcePos.dx) * t;
            final dy = sourcePos.dy +
                (targetPos.dy - sourcePos.dy) * t +
                arcHeight * math.sin(t * math.pi);
            final scale = 1.0 + 0.3 * math.sin(t * math.pi);

            return Positioned(
              left: dx - 20,
              top: dy - 20,
              child: Transform.scale(
                scale: scale,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.5),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Text(
                      letter,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    try {
      overlay.insert(entry);
      await controller.forward();
    } finally {
      entry.remove();
      controller.dispose();
    }
  }

  // Mapa de sustituciones fonéticas para sílabas que el TTS lee como siglas
  final Map<String, String> _phoneticOverrides = {
    // Clusters con C y G seguidos de E (problemas de pronunciación)
    'CLE': 'clé', 'GLE': 'glé',
    'CRE': 'cré', 'GRE': 'gré',
    // Doble L (LL suena como Y en español)
    'LLA': 'ya', 'LLE': 'ye', 'LLI': 'yi', 'LLO': 'yo', 'LLU': 'yu',
    // Doble R (RR - usar acentos para forzar lectura como palabra)
    'RRA': 'rá', 'RRE': 'ré', 'RRI': 'rí', 'RRO': 'ró', 'RRU': 'rú',
  };

  // Convierte sílabas para pronunciación natural por el TTS
  String _convertSyllableForSpeech(String syllable) {
    if (syllable.isEmpty) return syllable;
    
    // Primero verificar si hay una sustitución fonética directa
    if (_phoneticOverrides.containsKey(syllable)) {
      return _phoneticOverrides[syllable]!;
    }
    
    // Para clusters consonánticos, enviar todo minúscula
    final List<String> consonantClusters = [
      'BL', 'BR', 'CL', 'CR', 'DR', 'FL', 'FR', 'GL', 'GR', 'PL', 'PR', 'TR'
    ];
    
    for (String cluster in consonantClusters) {
      if (syllable.startsWith(cluster)) {
        return syllable.toLowerCase();
      }
    }
    
    // Para otros casos, primera mayúscula + resto minúscula
    return syllable[0] + syllable.substring(1).toLowerCase();
  }

  // Agrega una letra al bloque actual y valida la sílaba
  void _addLetter(String letter) async {
    if (!_activeLetters[letter]!) return; // Ignorar letras desactivadas

    // Pre-calcular contenido futuro para actualizar teclado inmediatamente
    String futureContent = _syllables[_currentBlockIndex] + letter;

    // Actualizar teclado antes de la animación (feedback visual inmediato)
    setState(() {
      if (futureContent.length == 1) {
        _updateActiveLetters(futureContent);
      } else if (futureContent.length >= 2) {
        if (_validSyllables.contains(futureContent)) {
          _activeLetters.updateAll((key, value) => false);
        } else {
          _updateActiveLetters(futureContent);
        }
      }
    });

    // Animar la letra volando desde el teclado al contenedor
    await _flyLetterAnimation(letter);

    // Agregar la letra al bloque actual (aparece en el contenedor)
    setState(() {
      _syllables[_currentBlockIndex] += letter;
      _showCurrentLooseLetters = true;
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

  // Limpia toda la sílaba formada - muestra confirmación antes
  void _clearSyllable() {
    // No mostrar diálogo si no hay sílabas que borrar
    final tieneContenido = _syllables.any((s) => s.isNotEmpty);
    if (!tieneContenido) {
      _speak('Primero creemos algunas sílabas');
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Align(
            alignment: Alignment.center,
            child: Text('¿Eliminar todas las sílabas?'),
          ),
          content: Text('¿Estás seguro de que deseas eliminar todas las sílabas?'),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white
              ),
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white
              ),
              child: Text('Eliminar'),
              onPressed: () {
                Navigator.of(context).pop();
                _confirmClearSyllable();
              },
            ),
          ],
        );
      },
    );
    // Reproducir el texto del diálogo después de que se muestre el dialogo de Limpiar
    Future.delayed(Duration(milliseconds: 300), () {
      _speak('¿Con el botón rojo eliminarás todas las sílabas?');
    });
  }

  // Ejecuta la eliminación confirmada de todas las sílabas
  void _confirmClearSyllable() {
    setState(() {
      _syllables = ['']; // Reiniciar la lista de bloques
      _currentBlockIndex = 0; // Reiniciar el índice del bloque actual
      _showCurrentLooseLetters = true; // Mostrar letras sueltas de nuevo
    });
    _resetActiveLetters(); // Restaurar todas las letras
  }

  // Detecta si el dispositivo es una tablet basado en la relación de aspecto
  bool _isTablet(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final aspectRatio = size.longestSide / size.shortestSide;
    // Tablets tienen relación de aspecto menor (más cercana a 1.33 o 1.6)
    // Phones tienen relación mayor (típicamente > 1.8 en landscape)
    return aspectRatio < 1.75;
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
        // Si se elimina el bloque actual, limpiar el estado
        if (indexABorrar == _currentBlockIndex) {
          _syllables.removeAt(indexABorrar);
          
          // Ajustar el índice actual si es necesario
          if (_currentBlockIndex >= _syllables.length) {
            _currentBlockIndex = _syllables.length - 1;
          }
          
          // Vaciar el bloque actual después de ajustar el índice
          _syllables[_currentBlockIndex] = '';
          _showCurrentLooseLetters = true;
          _resetActiveLetters();
        } else {
          // SI NO se elimina el bloque actual, MANTENER su estado actual
          // Eliminar el bloque en el índice especificado
          _syllables.removeAt(indexABorrar);
          
          // Ajustar el índice actual si el elemento borrado estaba ANTES
          if (indexABorrar < _currentBlockIndex) {
            _currentBlockIndex--; // Decrementar porque los índices después se desplazan
          }
          
          // Mantener el contenido del bloque actual intacto
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
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    
    return Scaffold(
      appBar: isLandscape ? null : AppBar(
        title: Text('Aprende Sílabas'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isLandscape ? _buildLandscapeLayout() : _buildPortraitLayout(),
    );
  }

  // Layout en modo vertical (portrait)
  Widget _buildPortraitLayout() {
    return Column(
        children: [
          // Zona de Sílabas - Contenedor responsivo con Flex
          Flexible(
            flex: 15, // Toma 2 partes del espacio disponible
            child: Container(
              key: _syllableContainerKey,
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
                      alignment: WrapAlignment.start,
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
                ],
              ),
            ),
          ),

          // Fila de botones (Limpiar a la izquierda, Borrar a la derecha)
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue, width: 3),
              borderRadius: BorderRadius.circular(12),
              color: Colors.blue.withOpacity(0.05),
              boxShadow: [
                BoxShadow(
                  color: Colors.lightBlueAccent.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3), // cambio de posición de la sombra
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                  // Botón Limpiar (izquierda)
                  Expanded(
                    flex: 3,
                    child: SizedBox.expand(
                      child: ElevatedButton(
                        onPressed: _clearSyllable,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.all(0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Limpiar',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                  // Espacio vacío entre botones
                  Expanded(
                    flex: 3,
                    child: SizedBox(),
                  ),
                  // Botón Borrar (derecha)
                  Expanded(
                    flex: 5,
                    child: DragTarget<Object>(
                      onAccept: (data) {
                        if (data is Map && data.containsKey('index')) {
                          int indexABorrar = data['index'];
                          _handleDeleteSyllable(indexABorrar);
                        }
                      },
                      builder: (context, candidateData, rejectedData) {
                        return SizedBox.expand(
                          child: GestureDetector(
                            onTap: () {
                              final tieneContenido = _syllables.any((s) => s.isNotEmpty);
                              if (tieneContenido) {
                                _speak('Arrastra las sílabas hasta acá para borrarlas');
                              } else {
                                _speak('Forma sílabas con las letras para verlas aquí');
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: candidateData.isNotEmpty ? Colors.red : Colors.grey,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                color: candidateData.isNotEmpty ? Colors.red.withOpacity(0.15) : const Color.fromARGB(255, 88, 88, 88),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Arrastra las\nsílabas hasta acá\npara borrarlas',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: const Color.fromARGB(221, 255, 255, 255),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Icon(Icons.delete, size: 28, color: Colors.red),
                                ],
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
          ),
          ),

          // Teclado de letras - Flex responsivo
          Flexible(
            flex: 25,
            child: Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const int crossAxisCount = 5;
                  const double spacing = 8;
                  const double pad = 8;
                  final int rowCount = (_letters.length / crossAxisCount).ceil();
                  final double cellWidth = (constraints.maxWidth - pad * 2 - spacing * (crossAxisCount - 1)) / crossAxisCount;
                  final double cellHeight = (constraints.maxHeight - pad * 2 - spacing * (rowCount - 1)) / rowCount;
                  final double ratio = cellHeight > 0 ? cellWidth / cellHeight : 1.0;
                  return GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.all(pad),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: spacing,
                      mainAxisSpacing: spacing,
                      childAspectRatio: ratio,
                    ),
                    itemCount: _letters.length,
                    itemBuilder: (context, index) {
                      return _buildLetterButton(_letters[index]);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      );
    }

  // Layout en modo horizontal (landscape)
  Widget _buildLandscapeLayout() {
    return Builder(
      builder: (context) {
        final isTablet = _isTablet(context);
        return Row(
          children: [
            // Spacer para evitar cámara frontal en phones (solo en phones)
            // Calcula dinámicamente basado en el ancho de pantalla (~4% del ancho)
            if (!isTablet)
              SizedBox(width: MediaQuery.of(context).size.width * 0.032),
            
            // Columna de sílabas con título - Izquierda
            Expanded(
              flex: 5,
              child: Column(
                children: [
              // Título con botón de retroceso
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'Formar Sílabas',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              // Contenedor de sílabas
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Container(
                      key: _syllableContainerKey,
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      margin: EdgeInsets.only(left: 10, right: 1, top: 2, bottom: 8), // Más espacio a la derecha
                      padding: EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8),
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
                            thickness: 8.0,
                            radius: Radius.circular(4.0),
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              child: Wrap(
                                spacing: 12.0,
                                runSpacing: 12.0,
                                alignment: WrapAlignment.start,
                                children: [
                                  ..._syllables.asMap().entries.where((entry) {
                                    final isValid = _validSyllables.contains(entry.value);
                                    final isCurrentBlock = entry.key == _currentBlockIndex;
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
                                      childWhenDragging: SizedBox.shrink(),
                                      child: GestureDetector(
                                        onTap: () {
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
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        // Columna de botones - Centro (entre sílabas y teclado)
        Expanded(
          flex: 2,
          child: Column(
            children: [
              // Botón Borrar (basurero) - arriba
              Expanded(
                flex: 10,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 4, top: 9, left: 8, right: 0),
                  child: DragTarget<Object>(
                    onAccept: (data) {
                      if (data is Map && data.containsKey('index')) {
                        int indexABorrar = data['index'];
                        _handleDeleteSyllable(indexABorrar);
                      }
                    },
                    builder: (context, candidateData, rejectedData) {
                      return SizedBox.expand(
                        child: GestureDetector(
                          onTap: () {
                            final tieneContenido = _syllables.any((s) => s.isNotEmpty);
                            if (tieneContenido) {
                              _speak('Arrastra las sílabas hasta acá para borrarlas');
                            } else {
                              _speak('Forma sílabas con las letras para verlas aquí');
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: candidateData.isNotEmpty ? Colors.red : Colors.grey,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              color: candidateData.isNotEmpty ? Colors.red.withOpacity(0.15) : const Color.fromARGB(255, 88, 88, 88),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                    'Arrastra las\nsílabas hasta acá\npara borrarlas',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: const Color.fromARGB(221, 255, 255, 255),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Icon(Icons.delete, size: 28, color: Colors.red),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Espacio vacío entre botones
              Expanded(
                flex: 3,
                child: SizedBox(),
              ),
              // Botón Limpiar (rojo) - abajo
              Expanded(
                flex: 3,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 9, top: 4, left: 8, right: 0),
                  child: SizedBox.expand(
                    child: ElevatedButton(
                      onPressed: _clearSyllable,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.all(0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Limpiar',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Columna de teclado - Derecha
        Expanded(
          flex: 7,
          child: Column(
            children: [
              // Teclado de letras (5 columnas en landscape)
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const int crossAxisCount = 5;
                    const double spacing = 8;
                    const double pad = 10;
                    final int rowCount = (_letters.length / crossAxisCount).ceil();
                    final double cellWidth = (constraints.maxWidth - pad * 2 - spacing * (crossAxisCount - 1)) / crossAxisCount;
                    final double cellHeight = (constraints.maxHeight - pad * 2 - spacing * (rowCount - 1)) / rowCount;
                    final double ratio = cellHeight > 0 ? cellWidth / cellHeight : 1.0;
                    return GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.all(pad),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: spacing,
                        mainAxisSpacing: spacing,
                        childAspectRatio: ratio,
                      ),
                      itemCount: _letters.length,
                      itemBuilder: (context, index) {
                        return _buildLetterButton(_letters[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
      },
    );
  }

  // Construye un botón de letra con tamaño completamente adaptable
  Widget _buildLetterButton(String letter) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calcula el tamaño de fuente basado en el espacio disponible
        double fontSize = constraints.maxWidth * 0.4; // 40% del ancho
        double minFontSize = 14.0;
        double maxFontSize = 48.0;
        
        return Container(
          key: _letterKeys[letter],
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: ElevatedButton(
            onPressed: _activeLetters[letter]! ? () => _addLetter(letter) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _activeLetters[letter]! ? Colors.blueAccent : Colors.grey,
              foregroundColor: Colors.white,
              padding: EdgeInsets.all(4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                letter,
                style: TextStyle(
                  fontSize: fontSize.clamp(minFontSize, maxFontSize),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}