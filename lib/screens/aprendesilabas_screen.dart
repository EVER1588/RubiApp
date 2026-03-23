import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/tts_manager.dart';
import '../constants/state_manager.dart';
import '../constants/custombar_screen.dart';

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
  
  // Rastrear la letra que está siendo animada (no mostrar en el Wrap)
  String? _animatingLetter;

  // Bloquear la adición de letras mientras hay una animación en progreso
  bool _isAnimating = false;

  // ─── Variables para el tutorial de primera sílaba ───────────────────────────
  bool _showTutorial = false;
  bool _tutorialCompleted = false;
  int _tutorialStep = 0; // 0: apuntar a B, 1: apuntar a A, 2: completado
  bool _isHelpTutorial = false; // true cuando se muestra desde el botón Ayuda
  late AnimationController _tutorialHandController;
  late Animation<double> _tutorialHandBounce;
  Map<String, GlobalKey> _tutorialLetterKeys = {};

  // Modo de visualización: false = clásico, true = módulos (MODERNO ES EL MODO POR DEFECTO)
  bool _useModules = true;

  // Estilo del teclado: false = uniforme, true = colorido (pasteles)
  bool _useColorfulKeyboard = false;

  // Esquema de color para teclado colorido (0-4)
  int _colorfulScheme = 0;

  // Índice de color para teclado uniforme  
  int _uniformColorIndex = 0; // Azul clásico por defecto

  // Paletas disponibles para teclado uniforme [activo, inactivo]
  static const List<List<Color>> _uniformPalettes = [
    [Color(0xFF1976D2), Color(0xFF9E9E9E)],  // Azul clásico
    [Color(0xFF7B1FA2), Color(0xFF9E9E9E)],  // Violeta
    [Color(0xFFE64A19), Color(0xFF9E9E9E)],  // Naranja
    [Color(0xFF00838F), Color(0xFF9E9E9E)],  // Turquesa
    [Color(0xFF5D4037), Color(0xFF9E9E9E)],  // Café
    [Color(0xFFC62828), Color(0xFF9E9E9E)],  // Rojo cereza
  ];

  static const List<String> _uniformPaletteNames = [
    'Azul clásico', 'Violeta', 'Naranja', 'Turquesa', 'Café', 'Cereza',
  ];

  static const List<String> _colorfulSchemeNames = [
    'Arcoiris', 'Ocaso', 'Océano', 'Primavera', 'Noche', 'Aleatorio',
  ];

  // Colores aleatorios para el esquema "Aleatorio"
  Map<String, Color> _randomLetterColors = {};

  // Keys para la animación de letras volando
  final GlobalKey _syllableContainerKey = GlobalKey();
  final Map<String, GlobalKey> _letterKeys = {};
  
  // Key para obtener la posición exacta donde aparecerá la nueva letra
  final GlobalKey _nextLetterPositionKey = GlobalKey();

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
    'OR', 'OS',  
    'PA', 'PE', 'PI', 'PO', 'PU',
    'QUE', 'QUI',  
    'RA', 'RE', 'RI', 'RO', 'RU',
    'SA', 'SE', 'SI', 'SO', 'SU',
    'TA', 'TE', 'TI', 'TO', 'TU',
    'UL', 'UN', 'US',  
    'VA', 'VE', 'VI', 'VO', 'VU',
    'WA', 'WI', 'WEB', 
    'XA', 'XE', 'XI', 'XO', 'XU',
    'YA', 'YE', 'YI', 'YO', 'YU',   
    'ZA', 'ZE', 'ZI', 'ZO', 'ZU',

    
    'BLA', 'BLE', 'BLI', 'BLO', 'BLU',
    'CLA', 'CLE', 'CLI', 'CLO', 'CLU',
    'FLA', 'FLE', 'FLI', 'FLO', 'FLU',
    'GLA', 'GLE', 'GLI', 'GLO', 'GLU',
    'PLA', 'PLE', 'PLI', 'PLO', 'PLU',
    'LLA', 'LLE', 'LLI', 'LLO', 'LLU',
    'BRA', 'BRE', 'BRI', 'BRO', 'BRU',
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

  // Variables para animar sílabas completadas (modo módulos)
  String? _lastAnimatedSyllable;
  bool _isSyllableAppearing = false;
  late AnimationController _syllableAnimController;
  late Animation<double> _syllableSlideAnim;
  late Animation<double> _syllableScaleAnim;

  // Variables para animación de fusión (modo clásico)
  bool _isMergingClassic = false;
  String? _classicMergeSyllable;
  late AnimationController _mergeAnimController;
  late Animation<double> _letterShrinkAnim;   // letras se encogen: 1.0→0.0
  late Animation<double> _classicSyllablePopAnim; // sílaba aparece: 0.0→1.0 con rebote

  // Colores de las letras sueltas en modo clásico (por posición en el bloque actual)
  final Map<int, Color> _classicLetterColors = {};

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    TtsManager.instance.init();
    TtsManager.instance.speak("Aprende Sílabas");
    StateManager().cargarDatos();
    _loadViewMode();
    for (String letter in _letters) {
      _letterKeys[letter] = GlobalKey();
      _tutorialLetterKeys[letter] = GlobalKey();
    }
    
    // Controlador de animación para el tutorial
    _tutorialHandController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _tutorialHandBounce = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _tutorialHandController, curve: Curves.easeInOut),
    );
    
    // Verificar si mostrar el tutorial
    _checkTutorial();

    // Controlador de animación de aparición de sílaba (slide + bounce)
    _syllableAnimController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 850),
    );
    // Fase 1 (0%–50%): deslizamiento suave desde la izquierda
    _syllableSlideAnim = _syllableAnimController.drive(
      Tween(begin: -1.2, end: 0.0).chain(
        CurveTween(curve: Interval(0.0, 0.5, curve: Curves.easeOut)),
      ),
    );
    // Fase 2 (40%–100%): rebote pronunciado al aterrizar
    _syllableScaleAnim = _syllableAnimController.drive(
      Tween(begin: 0.55, end: 1.0).chain(
        CurveTween(curve: Interval(0.4, 1.0, curve: Curves.elasticOut)),
      ),
    );
    _syllableAnimController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() {
          _isSyllableAppearing = false;
          _lastAnimatedSyllable = null;
        });
      }
    });

    // Controlador para fusión en modo clásico (900ms total)
    _mergeAnimController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 900),
    );
    // Fase 1 (0–35%): letras se encogen hasta desaparecer
    _letterShrinkAnim = _mergeAnimController.drive(
      Tween(begin: 1.0, end: 0.0).chain(
        CurveTween(curve: Interval(0.0, 0.35, curve: Curves.easeIn)),
      ),
    );
    // Fase 2 (32–100%): sílaba aparece con pop + rebote
    _classicSyllablePopAnim = _mergeAnimController.drive(
      Tween(begin: 0.0, end: 1.0).chain(
        CurveTween(curve: Interval(0.32, 1.0, curve: Curves.elasticOut)),
      ),
    );
    _mergeAnimController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() { _isMergingClassic = false; });
      }
    });
  }

  Future<void> _loadViewMode() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _useModules = prefs.getBool('useModules') ?? true;
        _useColorfulKeyboard = prefs.getBool('useColorfulKeyboard') ?? false;
        _colorfulScheme = prefs.getInt('colorfulScheme') ?? 0;
        _uniformColorIndex = prefs.getInt('uniformColorIndex') ?? 0;
      });
      if (_colorfulScheme == 5) _generateRandomColors();
    }
    await _loadSyllableState();
  }

  Future<void> _saveSyllableState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('syllables_state', _syllables);
    await prefs.setInt('syllables_blockIndex', _currentBlockIndex);
  }

  Future<void> _loadSyllableState() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('syllables_state');
    final savedIndex = prefs.getInt('syllables_blockIndex');
    if (saved != null && saved.isNotEmpty && mounted) {
      setState(() {
        _syllables = saved;
        _currentBlockIndex = (savedIndex ?? saved.length - 1).clamp(0, saved.length - 1);
        _showCurrentLooseLetters = true;
        if (_syllables[_currentBlockIndex].isNotEmpty) {
          _updateActiveLetters(_syllables[_currentBlockIndex]);
        } else {
          _resetActiveLetters();
        }
      });
    }
  }

  // ─── Métodos del tutorial de primera sílaba ─────────────────────────────────
  Future<void> _checkTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final hasCompletedFirstSyllable = prefs.getBool('aprendesilabas_tutorial_completed') ?? false;
    
    if (!hasCompletedFirstSyllable) {
      // Esperar un momento para que la UI se construya
      await Future.delayed(Duration(milliseconds: 1200));
      if (mounted) {
        setState(() {
          _showTutorial = true;
          _tutorialStep = 0;
          _isHelpTutorial = false;
        });
        // Iniciar con TTS
        _speak('Toca la letra B del teclado para iniciar');
      }
    }
  }

  void _startHelpTutorial() {
    setState(() {
      _showTutorial = true;
      _tutorialStep = 0;
      _isHelpTutorial = true; // Sin TTS
    });
  }

  Future<void> _onTutorialLetterTapped(String letter) async {
    if (!_showTutorial) return;
    
    if (_tutorialStep == 0 && letter == 'B') {
      // Paso 1 completado: tocó la B
      setState(() {
        _tutorialStep = 1;
      });
      if (!_isHelpTutorial) {
        await Future.delayed(Duration(milliseconds: 800));
        _speak('Ahora toca la letra A');
      }
    } else if (_tutorialStep == 1 && letter == 'A') {
      // Paso 2 completado: tocó la A, se formará BA
      setState(() {
        _tutorialStep = 2;
        _showTutorial = false;
      });
    }
  }

  Future<void> _onFirstSyllableCompleted() async {
    if (_tutorialCompleted) return;
    
    // Solo se felicita si no es tutorial de ayuda y es la primera vez
    if (!_isHelpTutorial) {
      await Future.delayed(Duration(milliseconds: 1200));
      _speak('¡Felicidades! formaste tu primera sílaba. ¡Continúa formando muchas más!');
    }
    
    // Marcar como completado
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('aprendesilabas_tutorial_completed', true);
    
    setState(() {
      _tutorialCompleted = true;
      _showTutorial = false;
    });
  }

  // Widget de la manita apuntando para el tutorial
  Widget _buildTutorialHandOverlay() {
    if (!_showTutorial) return SizedBox.shrink();

    String targetLetter = _tutorialStep == 0 ? 'B' : 'A';
    
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _tutorialHandController,
              builder: (context, child) {
                // Obtener posición de la letra objetivo desde su GlobalKey
                // Asegurar que sea mayúscula
                final searchLetter = targetLetter.toUpperCase();
                final targetKey = _letterKeys[searchLetter];
                if (targetKey == null) return SizedBox.shrink();
                
                final renderBox = targetKey.currentContext?.findRenderObject() as RenderBox?;
                if (renderBox == null || !renderBox.hasSize) return SizedBox.shrink();
                
                late final Offset position;
                try {
                  position = renderBox.localToGlobal(Offset.zero);
                } catch (_) {
                  return SizedBox.shrink();
                }
                final size = renderBox.size;
                
                // Centro de la letra
                final targetCenter = Offset(
                  position.dx + size.width / 2,
                  position.dy + size.height / 2,
                );
                
                // Tamaño de la imagen
                const double handSize = 380.0;
                const double pointerVerticalOffset = -90.0;
                
                // Posicionar la imagen: la punta del dedo está en el centro de la imagen
                // por lo que centramos la imagen directamente en el punto objetivo
                final bounceOffsetY = _tutorialHandBounce.value * 10;
                
                final handX = targetCenter.dx - handSize / 2;
                final handY = targetCenter.dy - handSize / 2 + pointerVerticalOffset + bounceOffsetY;
                
                return Positioned(
                  left: handX,
                  top: handY,
                  child: Image.asset(
                    'lib/utils/images/fondos/manita.png',
                    width: handSize,
                    height: handSize,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Genera colores aleatorios para cada letra (esquema "Aleatorio")
  void _generateRandomColors() {
    final rng = math.Random();
    _randomLetterColors = {
      for (final l in _letters)
        l: HSLColor.fromAHSL(1.0, rng.nextDouble() * 360.0, 0.55 + rng.nextDouble() * 0.15, 0.42 + rng.nextDouble() * 0.16).toColor(),
    };
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    _syllableAnimController.dispose();
    _mergeAnimController.dispose();
    _tutorialHandController.dispose();
    super.dispose();
  }

  // Reproduce el texto usando TtsManager
  Future<void> _speak(String text) async {
    await TtsManager.instance.speak(text);
  }

  // Obtiene la posición y tamaño exactos donde será renderizada la siguiente letra.
  // Usa addPostFrameCallback para garantizar que el layout está completo.
  Future<(Offset?, Size?)> _getTargetPositionAndSize() async {
    final completer = Completer<void>();
    WidgetsBinding.instance.addPostFrameCallback((_) => completer.complete());
    await completer.future;

    if (!mounted) return (null, null);
    try {
      final box = _nextLetterPositionKey.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) return (null, null);

      final size = box.size;
      final pos = box.localToGlobal(
        Offset(size.width / 2, size.height / 2),
      );
      return (pos, size);
    } catch (e) {
      return (null, null);
    }
  }

  // Anima una letra volando desde el teclado hasta el contenedor de sílabas.
  // En modo módulos, la letra se transforma gradualmente del tamaño del teclado
  // al tamaño que tendrá dentro del módulo.
  Future<void> _flyLetterAnimation(String letter, String displayLetter, Offset? targetPos, [Size? targetChipSize, Color? letterColor]) async {
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

    // Si no hay posición exacta calculada, usar el centro del contenedor
    if (targetPos == null) {
      final targetBox =
          _syllableContainerKey.currentContext!.findRenderObject() as RenderBox;
      final targetSize = targetBox.size;
      targetPos = targetBox.localToGlobal(
        Offset(targetSize.width / 2, targetSize.height / 2),
      );
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final arcHeight = -screenHeight * 0.08;

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

    // displayLetter ya viene calculado desde _addLetter con la mayúscula/minúscula correcta

    if (targetChipSize != null) {
      // ── Modo módulos: morph del botón del teclado al chip del módulo ──
      final startW = sourceSize.width;
      final startH = sourceSize.height;
      final endW = targetChipSize.width;
      final endH = targetChipSize.height;
      final startR = 8.0; // borderRadius del botón del teclado
      final endR = 6.0; // borderRadius del chip del módulo (coincide con _moduleLetterChip)
      final startFs = (startW * 0.4).clamp(14.0, 48.0);
      final endFs = 18.0;

      entry = OverlayEntry(
        builder: (context) {
          return AnimatedBuilder(
            animation: curved,
            builder: (context, child) {
              final t = curved.value;
              final dx = sourcePos.dx + (targetPos!.dx - sourcePos.dx) * t;
              final dy = sourcePos.dy +
                  (targetPos.dy - sourcePos.dy) * t +
                  arcHeight * math.sin(t * math.pi);
              final w = startW + (endW - startW) * t;
              final h = startH + (endH - startH) * t;
              final r = startR + (endR - startR) * t;
              final fs = startFs + (endFs - startFs) * t;

              return Positioned(
                left: dx - w / 2,
                top: dy - h / 2,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: w,
                    height: h,
                    decoration: BoxDecoration(
                      color: letterColor ?? Colors.blueAccent,
                      borderRadius: BorderRadius.circular(r),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (letterColor ?? Colors.blueAccent).withOpacity(0.5),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        displayLetter,
                        style: TextStyle(
                          fontSize: fs,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          decoration: TextDecoration.none,
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
    } else {
      // ── Modo clásico: animación con rebote ──
      entry = OverlayEntry(
        builder: (context) {
          return AnimatedBuilder(
            animation: curved,
            builder: (context, child) {
              final t = curved.value;
              final dx = sourcePos.dx + ((targetPos?.dx ?? sourcePos.dx) - sourcePos.dx) * t;
              final dy = sourcePos.dy +
                  ((targetPos?.dy ?? sourcePos.dy) - sourcePos.dy) * t +
                  arcHeight * math.sin(t * math.pi);
              final scale = 1.0 + 0.3 * math.sin(t * math.pi);

              return Positioned(
                left: dx - 24,
                top: dy - 27,
                child: Transform.scale(
                  scale: scale,
                  child: Material(
                    color: Colors.transparent,
                    child: Chip(
                      label: Text(
                        displayLetter,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: letterColor ?? Colors.blueAccent,
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    }

    try {
      overlay.insert(entry);
      await controller.forward();
    } finally {
      entry.remove();
      controller.dispose();
    }
  }

  // Habla una sílaba formada con velocidad lenta y corrección fonética.
  Future<void> _speakFormedSyllable(String syllable) async {
    await TtsManager.instance.speakSyllable(syllable);
  }

  // Formatea una sílaba según su posición en la palabra
  // Primera sílaba: primera letra mayúscula, resto minúscula
  // Otras sílabas: todas minúsculas
  String _formatSyllableForDisplay(String syllable, int syllableIndex) {
    if (syllable.isEmpty) return syllable;
    
    if (_useModules) {
      // MODO MODERNO: Primera letra de CADA sílaba en mayúscula
      return syllable[0].toUpperCase() + syllable.substring(1).toLowerCase();
    } else {
      // MODO CLÁSICO: Solo la primera sílaba tiene mayúscula
      if (syllableIndex == 0) {
        return syllable[0].toUpperCase() + syllable.substring(1).toLowerCase();
      } else {
        return syllable.toLowerCase();
      }
    }
  }

  // Agrega una letra al bloque actual y valida la sílaba
  void _addLetter(String letter) async {
    if (_isAnimating) return; // Bloquear si hay animación en progreso
    if (!_activeLetters[letter]!) return; // Ignorar letras desactivadas
    _isAnimating = true;
    
    // Manejar el tutorial si está activo
    if (_showTutorial) {
      _onTutorialLetterTapped(letter);
    }

    // 🔊 LEER LA LETRA INMEDIATAMENTE AL TOCAR (antes de cualquier otra acción)
    _speak(letter);

    // Pre-calcular contenido futuro para actualizar teclado inmediatamente
    String futureContent = _syllables[_currentBlockIndex] + letter;

    // Actualizar teclado antes de la animación (feedback visual inmediato)
    setState(() {
      if (futureContent.length == 1) {
        _updateActiveLetters(futureContent);
      } else if (futureContent.length >= 2) {
        if (_validSyllables.contains(futureContent.toUpperCase())) {
          _activeLetters.updateAll((key, value) => false);
        } else {
          _updateActiveLetters(futureContent);
        }
      }
    });

    // Determinar si convertir la letra a minúscula según el modo
    String letterToAdd = letter;
    if (_useModules) {
      // Modo Moderno: mayúscula solo en la primera letra de cada sílaba
      if (_syllables[_currentBlockIndex].isNotEmpty) {
        letterToAdd = letter.toLowerCase();
      }
    } else {
      // Modo Clásico: mayúscula solo si es la primera letra de toda la sesión
      final nothingTyped = _syllables.every((s) => s.isEmpty);
      if (!nothingTyped) {
        letterToAdd = letter.toLowerCase();
      }
    }

    // PASO 1: Agregar la letra al estado Y marcarla como animando al mismo tiempo
    // Así nunca se muestra visible antes de la animación
    setState(() {
      _syllables[_currentBlockIndex] += letterToAdd;
      _showCurrentLooseLetters = true;
      _animatingLetter = letter; // Invisible desde el primer frame
    });
    
    // PASO 2: Obtener la posición y tamaño exactos (renderizada pero invisible con opacity 0)
    final (targetPosition, targetSize) = await _getTargetPositionAndSize();
    
    // PASO 3: Animar la letra hacia su posición exacta
    // En modo módulos, la letra se transforma del tamaño del teclado al del chip
    final animColor = _getActiveButtonColor(letter);
    // Guardar el color para mostrarlo en el chip clásico después de la animación
    if (!_useModules) {
      _classicLetterColors[_syllables[_currentBlockIndex].length - 1] = animColor;
    }
    await _flyLetterAnimation(letter, letterToAdd, targetPosition, _useModules ? targetSize : null, animColor);

    // PASO 4: Desmarcar la animación (la letra reaparece normalmente)
    setState(() {
      _animatingLetter = null;
    });

    // Si la síla es válida, seguir el nuevo flujo
    if (_syllables[_currentBlockIndex].length >= 2 && 
        _validSyllables.contains(_syllables[_currentBlockIndex].toUpperCase())) {
      
      // PASO 1: Esperar un momento después de la lectura de la letra
      await Future.delayed(Duration(milliseconds: 500));
      
      // Guarda la sílaba formada
      String formedSyllable = _syllables[_currentBlockIndex];
      
      if (_useModules) {
        // ── Modo módulos: slide desde izquierda + rebote ──
        setState(() {
          _showCurrentLooseLetters = false;
          _isSyllableAppearing = true;
          _lastAnimatedSyllable = formedSyllable;
        });
        _syllableAnimController.forward(from: 0);
        await Future.delayed(Duration(milliseconds: 100));
        await _speakFormedSyllable(formedSyllable);
      } else {
        // ── Modo clásico: letras se encogen y sílaba aparece con pop ──
        setState(() {
          _isMergingClassic = true;
          _classicMergeSyllable = formedSyllable;
        });
        _mergeAnimController.forward(from: 0);

        // Esperar que las letras terminen de encogerse (~35% de 900ms)
        await Future.delayed(Duration(milliseconds: 320));

        // Cambiar a vista de sílaba (la sílaba pop arranca desde este momento)
        setState(() { _showCurrentLooseLetters = false; });
        await Future.delayed(Duration(milliseconds: 80));
        await _speakFormedSyllable(formedSyllable);
      }

      // Contar la sílaba en las estadísticas
      StateManager().actualizarContadores(nuevaSilaba: true);
      
      // Verificar si se completó la primera sílaba del tutorial (BA)
      if (!_tutorialCompleted && formedSyllable.toUpperCase() == 'BA') {
        _onFirstSyllableCompleted();
      }
      
      // Esperar un momento después de leer
      await Future.delayed(Duration(milliseconds: 500));
      
      // Mover al siguiente bloque
      _moveToNextBlock();
      
      // Volver a mostrar letras sueltas para la siguiente sílaba
      setState(() {
        _showCurrentLooseLetters = true;
      });
    }
    _isAnimating = false;
  }

  // Actualiza las letras activas basadas en la primera o segunda letra seleccionada
  void _updateActiveLetters(String currentSyllable) {
    _activeLetters.updateAll((key, value) => false); // Desactivar todas las letras
    String currentUpper = currentSyllable.toUpperCase(); // Convertir a mayúsculas para comparación
    for (String syllable in _validSyllables) {
      if (syllable.startsWith(currentUpper)) {
        _activeLetters[syllable[currentUpper.length]] = true; // Activar letras válidas
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
      _classicLetterColors.clear(); // Limpiar colores del bloque anterior
    });
    _saveSyllableState();
    // Auto-scroll al fondo para que el nuevo bloque sea visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Limpia toda la sílaba formada - muestra confirmación antes
  void _clearSyllable() {
    // No mostrar diálogo si no hay sílabas que borrar
    final tieneContenido = _syllables.any((s) => s.isNotEmpty);
    if (!tieneContenido) {
      _speak('Primero creemos algunas sílabas.');
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
      _speak('Con el botón rojo eliminaremos todas las sílabas y letras.');
    });
  }

  // Ejecuta la eliminación confirmada de todas las sílabas
  void _confirmClearSyllable() {
    setState(() {
      _syllables = ['']; // Reiniciar la lista de bloques
      _currentBlockIndex = 0; // Reiniciar el índice del bloque actual
      _showCurrentLooseLetters = true; // Mostrar letras sueltas de nuevo
      _classicLetterColors.clear();
    });
    _resetActiveLetters(); // Restaurar todas las letras
    _saveSyllableState();
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
          
          // Agregar un nuevo bloque vacío al final en lugar de sobrescribir uno existente
          _syllables.add('');
          _currentBlockIndex = _syllables.length - 1;
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
    _saveSyllableState();
  }

  // Borra una letra individual de la sílaba actual por índice
  void _handleDeleteLetter(int letterIndex) {
    if (_syllables[_currentBlockIndex].isNotEmpty &&
        letterIndex >= 0 &&
        letterIndex < _syllables[_currentBlockIndex].length) {
      setState(() {
        String current = _syllables[_currentBlockIndex];
        // Construir nueva sílaba sin la letra en ese índice
        _syllables[_currentBlockIndex] =
            current.substring(0, letterIndex) + current.substring(letterIndex + 1);
        
        // Actualizar letras activas según lo que queda
        if (_syllables[_currentBlockIndex].isEmpty) {
          _resetActiveLetters(); // Si está vacío, activar todas
        } else {
          _updateActiveLetters(_syllables[_currentBlockIndex]); // Si hay contenido, validar
        }
      });
      _saveSyllableState();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    
    return Scaffold(
      appBar: isLandscape ? null : CustomBar(
        titleText: 'Aprende Sílabas',
        onBackPressed: () => Navigator.pop(context),
        onHelpPressed: _mostrarAyuda,
        onInfoPressed: _mostrarEstadisticas,
        onSettingsPressed: _mostrarAjustes,
      ),
      body: Stack(
        children: [
          isLandscape ? _buildLandscapeLayout() : _buildPortraitLayout(),
          // Overlay del tutorial
          if (_showTutorial) _buildTutorialHandOverlay(),
        ],
      ),
    );
  }

  // Layout en modo vertical (portrait)
  Widget _buildPortraitLayout() {
    return Column(
        children: [
          // Zona de Sílabas - Contenedor responsivo con Flex
          Flexible(
            flex: 17, 
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
                      child: _useModules
                        ? LayoutBuilder(
                            builder: (context, constraints) =>
                              _buildModulesContent(constraints.maxWidth),
                          )
                        : Wrap(
                      spacing: 12.0,
                      runSpacing: 12.0,
                      alignment: WrapAlignment.start,
                      children: [
                        // Mostrar sílabas completadas como bloques verdes
                        // PERO NO mostrar el bloque actual si aún estamos mostrando letras sueltas
                        ..._syllables.asMap().entries.where((entry) {
                          final isValid = _validSyllables.contains(entry.value.toUpperCase());
                          final isCurrentBlock = entry.key == _currentBlockIndex;
                          // Mostrar solo si: es válido Y (NO es el bloque actual O ya ocultamos las letras sueltas)
                          return isValid && entry.value.isNotEmpty && (!isCurrentBlock || !_showCurrentLooseLetters);
                        }).map((entry) {
                          return Draggable<Map<String, dynamic>>(
                            data: {
                              'type': 'syllable',
                              'index': entry.key,
                              'silaba': entry.value,
                            },
                            feedback: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Material(
                                elevation: 8,
                                child: Chip(
                                  label: Text(
                                    _formatSyllableForDisplay(entry.value, entry.key),
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
                                // Leer la sílaba al tocarla (TtsManager normaliza internamente)
                                _speak(entry.value.toUpperCase());
                              },
                              child: _isMergingClassic && entry.value == _classicMergeSyllable
                                ? Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.green.withOpacity(0.45),
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: AnimatedBuilder(
                                      animation: _mergeAnimController,
                                      builder: (ctx, child) => Transform.scale(
                                        scale: _classicSyllablePopAnim.value,
                                        child: child,
                                      ),
                                      child: Chip(
                                        label: Text(
                                          _formatSyllableForDisplay(entry.value, entry.key),
                                          style: TextStyle(
                                            fontSize: 24, fontWeight: FontWeight.bold,
                                            shadows: [Shadow(blurRadius: 3, color: Colors.black38, offset: Offset(1, 1))],
                                          ),
                                        ),
                                        backgroundColor: Colors.green,
                                        labelStyle: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.green.withOpacity(0.45),
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Chip(
                                      label: Text(
                                        _formatSyllableForDisplay(entry.value, entry.key),
                                        style: TextStyle(
                                          fontSize: 24, fontWeight: FontWeight.bold,
                                          shadows: [Shadow(blurRadius: 3, color: Colors.black38, offset: Offset(1, 1))],
                                        ),
                                      ),
                                      backgroundColor: Colors.green,
                                      labelStyle: TextStyle(color: Colors.white),
                                    ),
                                  ),
                            ),
                          );
                        }).toList(),
                        
                        // Mostrar letras de la sílaba actual como elementos sueltos SOLO si debe mostrarlas
                        if (_showCurrentLooseLetters && _syllables[_currentBlockIndex].isNotEmpty)
                          ..._syllables[_currentBlockIndex].split('').asMap().entries.map((letterEntry) {
                            final isLast = letterEntry.key == _syllables[_currentBlockIndex].length - 1;
                            final isAnimating = isLast && _animatingLetter != null;
                            final letterColor = _classicLetterColors[letterEntry.key] ?? Colors.blueAccent;
                            Widget chip = Opacity(
                              opacity: isAnimating ? 0 : 1,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: letterColor.withOpacity(0.45),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Chip(
                                  key: isLast ? _nextLetterPositionKey : null,
                                  label: Text(
                                    letterEntry.value,
                                    style: TextStyle(
                                      fontSize: 24, fontWeight: FontWeight.bold,
                                      shadows: [Shadow(blurRadius: 3, color: Colors.black38, offset: Offset(1, 1))],
                                    ),
                                  ),
                                  backgroundColor: letterColor,
                                  labelStyle: TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                            // Envolver con animación de encogimiento si estamos fusionando
                            if (_isMergingClassic) {
                              chip = AnimatedBuilder(
                                animation: _mergeAnimController,
                                builder: (ctx, child) => Transform.scale(
                                  scale: _letterShrinkAnim.value,
                                  child: child,
                                ),
                                child: chip,
                              );
                            }
                            return Draggable<Map<String, dynamic>>(
                              data: {
                                'type': 'letter',
                                'index': letterEntry.key,
                                'letter': letterEntry.value,
                              },
                              feedback: Material(
                                elevation: 8,
                                child: Chip(
                                  label: Text(
                                    letterEntry.value,
                                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                  ),
                                  backgroundColor: Colors.blueAccent,
                                  labelStyle: TextStyle(color: Colors.white),
                                ),
                              ),
                              childWhenDragging: SizedBox.shrink(),
                              child: GestureDetector(
                                onTap: () => _speak(letterEntry.value.toUpperCase()),
                                child: chip,
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
                          elevation: 5,
                          shadowColor: Colors.red.withOpacity(0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.black, width: 2),
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
                    child: _buildDeleteDragTarget(),
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
              padding: EdgeInsets.only(bottom: 20),
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
              flex: 7,
              child: Column(
                children: [
              // Título con botón de retroceso
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
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
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.help_outline_rounded),
                      onPressed: _mostrarAyuda,
                      tooltip: 'Ayuda',
                    ),
                    IconButton(
                      icon: Icon(Icons.info_outline_rounded),
                      onPressed: _mostrarEstadisticas,
                      tooltip: 'Estadísticas',
                    ),
                    IconButton(
                      icon: Icon(Icons.settings_rounded),
                      onPressed: _mostrarAjustes,
                      tooltip: 'Ajustes',
                  ),
                ],
              ),
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
                        fit: StackFit.expand,
                        children: [
                          Scrollbar(
                            controller: _scrollController,
                            thickness: 8.0,
                            radius: Radius.circular(4.0),
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              child: _useModules
                                ? LayoutBuilder(
                                    builder: (context, constraints) =>
                                      _buildModulesContent(constraints.maxWidth),
                                  )
                                : Wrap(
                                spacing: 12.0,
                                runSpacing: 12.0,
                                alignment: WrapAlignment.start,
                                children: [
                                  ..._syllables.asMap().entries.where((entry) {
                                    final isValid = _validSyllables.contains(entry.value.toUpperCase());
                                    final isCurrentBlock = entry.key == _currentBlockIndex;
                                    return isValid && entry.value.isNotEmpty && (!isCurrentBlock || !_showCurrentLooseLetters);
                                  }).map((entry) {
                                    return Draggable<Map<String, dynamic>>(
                                      data: {
                                        'type': 'syllable',
                                        'index': entry.key,
                                        'silaba': entry.value,
                                      },
                                      feedback: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Material(
                                          elevation: 8,
                                          child: Chip(
                                            label: Text(
                                              _formatSyllableForDisplay(entry.value, entry.key),
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
                                          _speak(entry.value.toUpperCase());
                                        },
                                        child: Chip(
                                          label: Text(
                                            _formatSyllableForDisplay(entry.value, entry.key),
                                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                          ),
                                          backgroundColor: Colors.green,
                                          labelStyle: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  if (_showCurrentLooseLetters && _syllables[_currentBlockIndex].isNotEmpty)
                                    ..._syllables[_currentBlockIndex].split('').asMap().entries.map((letterEntry) {
                                      final isLast = letterEntry.key == _syllables[_currentBlockIndex].length - 1;
                                      final isAnimating = isLast && _animatingLetter != null;
                                      final letterColor = _classicLetterColors[letterEntry.key] ?? Colors.blueAccent;
                                      return Draggable<Map<String, dynamic>>(
                                        data: {
                                          'type': 'letter',
                                          'index': letterEntry.key,
                                          'letter': letterEntry.value,
                                        },
                                        feedback: Material(
                                          elevation: 8,
                                          child: Chip(
                                            label: Text(
                                              letterEntry.value,
                                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                            ),
                                            backgroundColor: letterColor,
                                            labelStyle: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                        childWhenDragging: SizedBox.shrink(),
                                        child: GestureDetector(
                                          onTap: () => _speak(letterEntry.value.toUpperCase()),
                                          child: Opacity(
                                            opacity: isAnimating ? 0 : 1,
                                            child: Material(
                                              elevation: 4,
                                              borderRadius: BorderRadius.circular(20),
                                              child: Chip(
                                                key: isLast ? _nextLetterPositionKey : null,
                                                label: Text(
                                                  letterEntry.value,
                                                  style: TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                    shadows: [
                                                      Shadow(
                                                        blurRadius: 3,
                                                        color: Colors.black38,
                                                        offset: Offset(1, 1),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                backgroundColor: letterColor,
                                                labelStyle: TextStyle(color: Colors.white),
                                              ),
                                            ),
                                          ),
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
                  child: _buildDeleteDragTarget(),
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
                        elevation: 5,
                        shadowColor: Colors.red.withOpacity(0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.black, width: 2),
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

  // Construye el botón de arrastrar para borrar sílabas y letras (reutilizable en portrait y landscape)
  Widget _buildDeleteDragTarget() {
    return DragTarget<Map<String, dynamic>>(
      onAccept: (data) {
        if (data.containsKey('type')) {
          if (data['type'] == 'syllable' && data.containsKey('index')) {
            // Borrar sílaba completa
            int indexABorrar = data['index'];
            _handleDeleteSyllable(indexABorrar);
          } else if (data['type'] == 'letter' && data.containsKey('index')) {
            // Borrar letra individual
            _handleDeleteLetter(data['index']);
          }
        }
      },
      builder: (context, candidateData, rejectedData) {
        return SizedBox.expand(
          child: GestureDetector(
            onTap: () {
              final tieneContenido = _syllables.any((s) => s.isNotEmpty);
              if (tieneContenido) {
                _speak('Arrastremos las sílabas o letras hasta allí para borrárlas.');
              } else {
                _speak('Forma algunas sílabas y arrastrémoslas allí para borrárlas.');
              }
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: candidateData.isNotEmpty ? Colors.red : Colors.red.shade700,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
                color: candidateData.isNotEmpty ? Colors.red.withOpacity(0.15) : const Color.fromARGB(255, 88, 88, 88),
                boxShadow: candidateData.isNotEmpty
                  ? [BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 8, offset: Offset(0, 3))]
                  : [BoxShadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2))],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Arrastra las\nsílabas o letras\nhasta acá\npara borrarlas',
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
    );
  }

  // Construye un botón de letra con tamaño completamente adaptable
  // Obtener la letra a mostrar en el teclado según el modo activo
  String _getDisplayLetter(String letter) {
    if (_useModules) {
      // Modo Moderno: mayúscula al inicio de cada nueva sílaba
      if (_syllables[_currentBlockIndex].isEmpty) {
        return letter; // Mayúscula
      } else {
        return letter.toLowerCase();
      }
    } else {
      // Modo Clásico: mayúscula solo si no se ha escrito nada en toda la sesión
      final nothingTyped = _syllables.every((s) => s.isEmpty);
      if (nothingTyped) {
        return letter; // Mayúscula solo al inicio absoluto
      } else {
        return letter.toLowerCase();
      }
    }
  }

  // Detecta si una letra es una vocal del alfabeto español
  bool _isVowel(String letter) {
    final vowels = ['A', 'E', 'I', 'O', 'U'];
    return vowels.contains(letter.toUpperCase());
  }

  Widget _buildLetterButton(String letter) {
    final bool isActive = _activeLetters[letter]!;
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calcula el tamaño de fuente basado en el espacio disponible
        double fontSize = constraints.maxWidth * 0.4; // 40% del ancho
        double minFontSize = 14.0;
        double maxFontSize = 48.0;
        
        // Obtener la letra a mostrar (mayúscula o minúscula según el estado)
        String displayLetter = _getDisplayLetter(letter);
        
        final activeColor = _getActiveButtonColor(letter);
        
        return AnimatedScale(
          scale: isActive ? 1.0 : 0.6,
          duration: Duration(milliseconds: 500),
          curve: Curves.elasticOut,
          child: AnimatedOpacity(
            opacity: isActive ? 1.0 : 0.35,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: Container(
              key: _letterKeys[letter],
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: ElevatedButton(
                onPressed: isActive ? () => _addLetter(letter) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isActive ? activeColor : Colors.grey.shade400,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.all(4),
                  elevation: isActive ? 4 : 1,
                  shadowColor: activeColor.withOpacity(0.6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.white.withOpacity(0.4), width: 2),
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    displayLetter,
                    style: TextStyle(
                      fontSize: fontSize.clamp(minFontSize, maxFontSize),
                      fontWeight: FontWeight.bold,
                      shadows: isActive ? [
                        Shadow(blurRadius: 4, color: Colors.black38, offset: Offset(1, 2)),
                      ] : null,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Genera un color según el esquema colorido seleccionado
  Color _getLetterPastelColor(String letter) {
    final index = _letters.indexOf(letter);
    if (index < 0) return Colors.blueAccent;
    final t = index / _letters.length;
    switch (_colorfulScheme) {
      case 0: // Arcoiris: espectro completo
        return HSLColor.fromAHSL(1.0, t * 360.0, 0.60, 0.50).toColor();
      case 1: // Ocaso: rojo → naranja → violeta
        return HSLColor.fromAHSL(1.0, (t * 120.0 + 270.0) % 360.0, 0.65, 0.52).toColor();
      case 2: // Océano: cian → azul → índigo
        return HSLColor.fromAHSL(1.0, 170.0 + t * 70.0, 0.60, 0.45).toColor();
      case 3: // Primavera: verde → amarillo → rosa
        return HSLColor.fromAHSL(1.0, (t * 150.0 + 80.0) % 360.0, 0.55, 0.50).toColor();
      case 4: // Noche: índigo → púrpura → azul profundo
        return HSLColor.fromAHSL(1.0, 220.0 + t * 80.0, 0.50, 0.38).toColor();
      case 5: // Aleatorio: colores al azar por letra
        return _randomLetterColors[letter] ?? Colors.blueAccent;
      default:
        return HSLColor.fromAHSL(1.0, t * 360.0, 0.60, 0.50).toColor();
    }
  }

  // Obtiene el color activo del teclado para una letra dada
  Color _getActiveButtonColor(String letter) {
    if (_useColorfulKeyboard) return _getLetterPastelColor(letter);
    final palette = _uniformPalettes[_uniformColorIndex];
    final isVowel = _isVowel(letter);
    // En modo uniforme: vocales ligeramente más claras
    return isVowel ? palette[0].withOpacity(0.82) : palette[0];
  }

  // ─── Diálogos de ayuda, estadísticas y ajustes ─────────────────────────────
  void _mostrarAyuda() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ayuda', style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold)),
              IconButton(icon: Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
            ],
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('📖 Cómo jugar:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 8),
                Text('1. Toca una letra del teclado para agregarla'),
                Text('2. Forma sílabas combinando letras'),
                Text('3. Las letras disponibles se actualizan automáticamente'),
                Text('4. Arrastra sílabas o letras al basurero para borrarlas'),
                Text('5. Usa "Limpiar" para eliminar todo'),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      // Iniciar tutorial de ayuda (sin TTS) después de cerrar el diálogo
      _startHelpTutorial();
    });
  }

  void _mostrarEstadisticas() {
    final stateManager = StateManager();
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Estadísticas', style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold)),
              IconButton(icon: Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
            ],
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: SingleChildScrollView(
            child: Container(
              width: isLandscape ? 500 : 320,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(children: [Icon(Icons.short_text, color: Colors.blue[700]), SizedBox(width: 8), Text('Sílabas Utilizadas:')]),
                            Text(stateManager.totalSilabasUsadas.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(children: [Icon(Icons.auto_stories, color: Colors.blue[700]), SizedBox(width: 8), Text('Palabras Descubiertas:')]),
                            Text(stateManager.palabrasUnicas.length.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(children: [Icon(Icons.library_books, color: Colors.blue[700]), SizedBox(width: 8), Text('Palabras Utilizadas:')]),
                            Text(stateManager.totalPalabrasUsadas.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('🏆 Logros Desbloqueados:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                  SizedBox(height: 8),
                  _buildLogro('Primera Sílaba', stateManager.logrosDesbloqueados['primera_silaba'] ?? false),
                  _buildLogro('10 Sílabas Descubiertas', stateManager.logrosDesbloqueados['diez_silabas'] ?? false),
                  _buildLogro('50 Sílabas Descubiertas', stateManager.logrosDesbloqueados['cincuenta_silabas'] ?? false),
                  _buildLogro('100 Sílabas Descubiertas', stateManager.logrosDesbloqueados['cien_silabas'] ?? false),
                  _buildLogro('Primera Palabra', stateManager.logrosDesbloqueados['primera_palabra'] ?? false),
                  _buildLogro('10 Palabras Descubiertas', stateManager.logrosDesbloqueados['diez_palabras'] ?? false),
                  _buildLogro('50 Palabras Descubiertas', stateManager.logrosDesbloqueados['cincuenta_palabras'] ?? false),
                  _buildLogro('100 Palabras Descubiertas', stateManager.logrosDesbloqueados['cien_palabras'] ?? false),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogro(String nombre, bool desbloqueado) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            desbloqueado ? Icons.emoji_events : Icons.lock_outline,
            color: desbloqueado ? Colors.amber : Colors.grey,
            size: 20,
          ),
          SizedBox(width: 8),
          Text(
            nombre,
            style: TextStyle(
              color: desbloqueado ? Colors.black : Colors.grey,
              fontWeight: desbloqueado ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarAjustes() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFFF093FB), Color(0xFF43E97B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: EdgeInsets.all(5),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      // Fondo con imagen
                      Positioned.fill(
                        child: Image.asset(
                          'lib/utils/images/escuela.jpeg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Overlay oscuro semitransparente
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.black.withOpacity(0.72), Colors.black.withOpacity(0.55)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                      // Contenido
                      SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // ── Título transparente ──
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('⚙️ Ajustes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: IconButton(
                                        icon: Icon(Icons.close, color: Colors.white, size: 20),
                                        constraints: BoxConstraints(minWidth: 36, minHeight: 36),
                                        padding: EdgeInsets.zero,
                                        onPressed: () => Navigator.of(context).pop(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(color: Colors.white24, height: 1),
                              SizedBox(height: 12),
                              // ── Modo de visualización ──
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.30),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.blue.withOpacity(0.4), width: 2),
                                ),
                                padding: EdgeInsets.all(12),
                                margin: EdgeInsets.only(bottom: 12),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text('📺 Modo de visualización', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                                        ),
                                        Switch(
                                          value: _useModules,
                                          onChanged: (value) async {
                                            final prefs = await SharedPreferences.getInstance();
                                            await prefs.setBool('useModules', value);
                                            setDialogState(() {});
                                            setState(() { _useModules = value; });
                                          },
                                          activeColor: Colors.purple[300],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: _useModules
                                            ? [Colors.purple.withOpacity(0.5), Colors.blue.withOpacity(0.3)]
                                            : [Colors.grey.withOpacity(0.4), Colors.blueGrey.withOpacity(0.3)],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: Colors.white24, width: 1),
                                      ),
                                      child: Center(
                                        child: Text(
                                          _useModules ? '🎯 Moderno' : '📝 Clásico',
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // ── Estilo del teclado ──
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.30),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.orange.withOpacity(0.4), width: 2),
                                ),
                                padding: EdgeInsets.all(12),
                                margin: EdgeInsets.only(bottom: 12),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text('🎨 Estilo del teclado', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                                        ),
                                        Switch(
                                          value: _useColorfulKeyboard,
                                          onChanged: (value) async {
                                            final prefs = await SharedPreferences.getInstance();
                                            await prefs.setBool('useColorfulKeyboard', value);
                                            setDialogState(() {});
                                            setState(() { _useColorfulKeyboard = value; });
                                          },
                                          activeColor: Colors.orange[300],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: _useColorfulKeyboard
                                            ? [Colors.orange.withOpacity(0.5), Colors.red.withOpacity(0.3)]
                                            : [Colors.blue.withOpacity(0.4), Colors.teal.withOpacity(0.3)],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: Colors.white24, width: 1),
                                      ),
                                      child: Center(
                                        child: Text(
                                          _useColorfulKeyboard ? '🌈 Colorido' : '🔵 Uniforme',
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // ── Selector de espectro / color con animación de rebote ──
                              AnimatedSwitcher(
                                duration: Duration(milliseconds: 500),
                                switchInCurve: Curves.elasticOut,
                                switchOutCurve: Curves.easeIn,
                                transitionBuilder: (child, animation) {
                                  return ScaleTransition(
                                    scale: animation,
                                    child: FadeTransition(opacity: animation, child: child),
                                  );
                                },
                                child: _useColorfulKeyboard
                                  ? Container(
                                      key: ValueKey('espectro'),
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.30),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.purple.withOpacity(0.4), width: 2),
                                      ),
                                      padding: EdgeInsets.all(12),
                                      margin: EdgeInsets.only(bottom: 12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('🌈 Selector de espectro:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                                          SizedBox(height: 10),
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: List.generate(_colorfulSchemeNames.length, (idx) {
                                              final hue = idx * 72.0;
                                              final c = HSLColor.fromAHSL(1.0, hue, 0.60, 0.50).toColor();
                                              return GestureDetector(
                                                onTap: () async {
                                                  final prefs = await SharedPreferences.getInstance();
                                                  await prefs.setInt('colorfulScheme', idx);
                                                  if (idx == 5) _generateRandomColors();
                                                  setDialogState(() {});
                                                  setState(() { _colorfulScheme = idx; });
                                                },
                                                child: Transform.scale(
                                                  scale: _colorfulScheme == idx ? 1.1 : 1.0,
                                                  child: Container(
                                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                    decoration: BoxDecoration(
                                                      color: c,
                                                      borderRadius: BorderRadius.circular(20),
                                                      border: _colorfulScheme == idx
                                                        ? Border.all(color: Colors.white, width: 3)
                                                        : Border.all(color: Colors.white38, width: 2),
                                                      boxShadow: _colorfulScheme == idx
                                                        ? [BoxShadow(color: c.withOpacity(0.6), blurRadius: 8, offset: Offset(0, 4))]
                                                        : [BoxShadow(color: c.withOpacity(0.3), blurRadius: 4)],
                                                    ),
                                                    child: Text(_colorfulSchemeNames[idx],
                                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                                                  ),
                                                ),
                                              );
                                            }),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Container(
                                      key: ValueKey('uniforme'),
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.30),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.teal.withOpacity(0.4), width: 2),
                                      ),
                                      padding: EdgeInsets.all(12),
                                      margin: EdgeInsets.only(bottom: 12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('🎨 Selector de color:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                                          SizedBox(height: 10),
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: List.generate(_uniformPalettes.length, (idx) {
                                              final c = _uniformPalettes[idx][0];
                                              return GestureDetector(
                                                onTap: () async {
                                                  final prefs = await SharedPreferences.getInstance();
                                                  await prefs.setInt('uniformColorIndex', idx);
                                                  setDialogState(() {});
                                                  setState(() { _uniformColorIndex = idx; });
                                                },
                                                child: Transform.scale(
                                                  scale: _uniformColorIndex == idx ? 1.1 : 1.0,
                                                  child: Container(
                                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                    decoration: BoxDecoration(
                                                      color: c,
                                                      borderRadius: BorderRadius.circular(20),
                                                      border: _uniformColorIndex == idx
                                                        ? Border.all(color: Colors.white, width: 3)
                                                        : Border.all(color: Colors.white38, width: 2),
                                                      boxShadow: _uniformColorIndex == idx
                                                        ? [BoxShadow(color: c.withOpacity(0.6), blurRadius: 8, offset: Offset(0, 4))]
                                                        : [BoxShadow(color: c.withOpacity(0.3), blurRadius: 4)],
                                                    ),
                                                    child: Text(_uniformPaletteNames[idx],
                                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                                                  ),
                                                ),
                                              );
                                            }),
                                          ),
                                        ],
                                      ),
                                    ),
                              ),
                              SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ─── Módulos de sílabas ────────────────────────────────────────────────────
  // Construye el contenido del contenedor en modo módulos: cada sílaba (completa
  // o en construcción) se muestra como un bloque visual  [letra] + [letra] = [sílaba]
  // Los chips llenan la altura completa del módulo (CrossAxisAlignment.stretch)
  // y se reparten el ancho con Expanded, evitando huecos verticales.

  Widget _buildModulesContent(double containerWidth) {
    const double scrollMargin = 50.0;
    const double spacing = 8.0;
    final double availableWidth = containerWidth - scrollMargin;
    final double moduleWidth = (availableWidth - spacing) / 2;
    const double moduleHeight = 52.0;

    const moduleColors = [
      Color(0xFFE3F2FD), Color(0xFFFCE4EC), Color(0xFFE8F5E9),
      Color(0xFFFFF3E0), Color(0xFFF3E5F5), Color(0xFFE0F7FA),
    ];

    List<Widget> modules = [];

    for (int i = 0; i < _syllables.length; i++) {
      final syllable = _syllables[i];
      final isCurrentBlock = i == _currentBlockIndex;
      final isValid = _validSyllables.contains(syllable.toUpperCase());
      final isComplete = isValid && syllable.isNotEmpty;
      final showLetters = isCurrentBlock ? _showCurrentLooseLetters : !isComplete;
      final moduleColor = moduleColors[i % moduleColors.length];

      final letters = syllable.isNotEmpty ? syllable.split('') : <String>[];
      const int minSlots = 2;
      // Si hay 2+ letras sin formar sílaba válida, verificar si hay sílabas más largas posibles
      int effectiveMinSlots = minSlots;
      if (isCurrentBlock && !isComplete && letters.length >= 2) {
        final upper = syllable.toUpperCase();
        if (_validSyllables.any((s) => s.startsWith(upper) && s.length > upper.length)) {
          effectiveMinSlots = letters.length + 1;
        }
      }
      final int placeholderCount = math.max(0, effectiveMinSlots - letters.length);

      List<Widget> rowChildren = [];

      if (syllable.isEmpty && isCurrentBlock) {
        // ── Módulo vacío: todos placeholders ──
        for (int j = 0; j < minSlots; j++) {
          if (j > 0) rowChildren.add(_moduleOperator('+'));
          rowChildren.add(Expanded(child: _modulePlaceholder()));
        }
        rowChildren.add(_moduleOperator('='));
        rowChildren.add(Expanded(flex: 2, child: _modulePlaceholder()));
      } else if (showLetters && isCurrentBlock) {
        // ── Módulo en construcción: letras + placeholders restantes ──
        for (int j = 0; j < letters.length; j++) {
          if (j > 0) rowChildren.add(_moduleOperator('+'));
          final isLastLetter = j == letters.length - 1;
          final isAnimating = isLastLetter && _animatingLetter != null;
          // Primera letra del módulo en mayúscula, el resto en minúscula
          final displayChar = j == 0 ? letters[j].toUpperCase() : letters[j].toLowerCase();
          final chipColor = _getActiveButtonColor(letters[j].toUpperCase());
          rowChildren.add(Expanded(
            child: GestureDetector(
              onTap: () => TtsManager.instance.speakLetterName(letters[j]),
              child: isAnimating
                ? Stack(fit: StackFit.expand, children: [
                    _modulePlaceholder(), // placeholder visible durante la animación
                    Opacity(
                      opacity: 0,
                      child: _moduleLetterChip(
                        displayChar,
                        key: isLastLetter ? _nextLetterPositionKey : null,
                        color: chipColor,
                      ),
                    ),
                  ])
                : _moduleLetterChip(
                    displayChar,
                    key: isLastLetter ? _nextLetterPositionKey : null,
                    color: chipColor,
                  ),
            ),
          ));
        }
        for (int j = 0; j < placeholderCount; j++) {
          rowChildren.add(_moduleOperator('+'));
          rowChildren.add(Expanded(child: _modulePlaceholder()));
        }
        rowChildren.add(_moduleOperator('='));
        rowChildren.add(Expanded(flex: 2, child: _modulePlaceholder()));
      } else {
        // ── Módulo completo: letras + = + sílaba verde ──
        for (int j = 0; j < letters.length; j++) {
          if (j > 0) rowChildren.add(_moduleOperator('+'));
          final displayChar = j == 0 ? letters[j].toUpperCase() : letters[j].toLowerCase();
          final chipColor = _getActiveButtonColor(letters[j].toUpperCase());
          rowChildren.add(Expanded(
            child: GestureDetector(
              onTap: () => TtsManager.instance.speakLetterName(letters[j]),
              child: _moduleLetterChip(displayChar, color: chipColor),
            ),
          ));
        }
        rowChildren.add(_moduleOperator('='));
        final displaySyllable = _formatSyllableForDisplay(syllable, i);
        final shouldAnimate = _isSyllableAppearing && _lastAnimatedSyllable == syllable;
        rowChildren.add(Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: () => TtsManager.instance.speakSyllable(syllable),
            child: shouldAnimate
              ? _animatedModuleResultChip(displaySyllable)
              : _moduleResultChip(displaySyllable),
          ),
        ));
      }

      Widget moduleContent = Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: rowChildren,
      );

      Widget moduleWidget = Container(
        width: moduleWidth,
        height: moduleHeight,
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: moduleColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCurrentBlock && !isComplete ? Colors.blueAccent : Colors.grey.shade300,
            width: isCurrentBlock && !isComplete ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        child: moduleContent,
      );

      if (syllable.isNotEmpty) {
        moduleWidget = Draggable<Map<String, dynamic>>(
          data: {'type': 'syllable', 'index': i, 'silaba': syllable},
          feedback: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: moduleWidth,
              height: moduleHeight,
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: moduleColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isComplete ? Colors.green : Colors.blueAccent, width: 2),
              ),
              child: moduleContent,
            ),
          ),
          childWhenDragging: Container(
            width: moduleWidth,
            height: moduleHeight,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
          ),
          child: isComplete
            ? GestureDetector(
                onTap: () => TtsManager.instance.speakSyllable(syllable),
                child: moduleWidget,
              )
            : moduleWidget,
        );
      }

      modules.add(moduleWidget);
    }

    return Padding(
      padding: EdgeInsets.only(right: scrollMargin),
      child: Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: modules,
      ),
    );
  }

  // Chip de letra dentro de un módulo (llena la altura completa via stretch)
  Widget _moduleLetterChip(String text, {Key? key, Color? color}) {
    final chipColor = color ?? Colors.blueAccent;
    return Container(
      key: key,
      margin: EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: chipColor.withOpacity(0.45),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(text, style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white,
              decoration: TextDecoration.none,
              shadows: [Shadow(blurRadius: 3, color: Colors.black38, offset: Offset(1, 1))],
            )),
          ),
        ),
      ),
    );
  }

  // Crea una animación de aparición de sílaba: desliza desde la izquierda + rebote al aterrizar
  Widget _animatedModuleResultChip(String text) {
    return AnimatedBuilder(
      animation: _syllableAnimController,
      builder: (context, child) {
        return ClipRect(
          child: FractionalTranslation(
            translation: Offset(_syllableSlideAnim.value, 0),
            child: Transform.scale(
              scale: _syllableScaleAnim.value,
              child: child,
            ),
          ),
        );
      },
      child: _moduleResultChip(text),
    );
  }

  // Chip de resultado (sílaba completa) dentro de un módulo
  Widget _moduleResultChip(String text) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.45),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(text, style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white,
              decoration: TextDecoration.none,
              shadows: [Shadow(blurRadius: 3, color: Colors.black38, offset: Offset(1, 1))],
            )),
          ),
        ),
      ),
    );
  }

  // Operador (+, =) entre chips dentro de un módulo
  Widget _moduleOperator(String op) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2),
      child: Center(
        child: Text(op, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
      ),
    );
  }

  // Placeholder vacío dentro de un módulo (llena la altura completa via stretch)
  Widget _modulePlaceholder() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Center(
        child: Text('?', style: TextStyle(color: Colors.grey.shade400, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}