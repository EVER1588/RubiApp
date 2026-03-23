import 'package:flutter/material.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/custombar_screen.dart'; // Agregar esta importación
import '../services/tts_manager.dart';
import '../constants/state_manager.dart';

class ItemDetailScreen extends StatefulWidget {
  final String nombre;
  final String imagen;
  final String categoria;
  final List<Map<String, dynamic>>? allItems;
  final int? currentIndex;
  
  const ItemDetailScreen({
    Key? key,
    required this.nombre,
    required this.imagen,
    required this.categoria,
    this.allItems,
    this.currentIndex,
  }) : super(key: key);

  @override
  _ItemDetailScreenState createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> with TickerProviderStateMixin {
  List<Map<String, dynamic>> silabas = [];
  List<Map<String, dynamic>> silabasColocadas = [];
  List<String> silabasOriginales = [];

  final TtsManager ttsManager = TtsManager();

  // Controlador para animación de respiración del botón Siguiente
  late AnimationController _breathController;
  late Animation<double> _breathAnim;

  // ─── Variables para el tutorial con manita ───────────────────────────────
  bool _showTutorial = false;
  bool _tutorialCompleted = false;
  late AnimationController _handAnimController;
  int _tutorialSequenceId = 0;
  int _tutorialStep = 0; // 0: bounce sílaba 1, 1: drag al slot 1, 2: bounce sílaba 2, 3: drag al slot 2
  GlobalKey _firstSyllableKey = GlobalKey();
  GlobalKey _firstSlotKey = GlobalKey();
  GlobalKey _secondSyllableKey = GlobalKey();
  GlobalKey _secondSlotKey = GlobalKey();
  bool _tutorialStartedOnCurrentScreen = false;

  static const String _describeImagenTutorialShownKey = 'describe_imagen_tutorial_shown';
  
  // Controlar si hay un diálogo abierto
  bool _isDialogOpen = false;

  // Clave de SharedPreferences para guardar progreso
  String get _completadosKey {
    const Map<String, String> keys = {
      'Animales': 'animales_completados',
      'Frutas': 'frutas_completados',
      'Verduras': 'verduras_completados',
      'Colores': 'colores_completados',
      'Números': 'numeros_completados',
    };
    return keys[widget.categoria] ?? '${widget.categoria.toLowerCase()}_completados';
  }

  Future<void> _guardarCompletado() async {
    final prefs = await SharedPreferences.getInstance();
    final completados = prefs.getStringList(_completadosKey) ?? [];
    if (!completados.contains(widget.nombre)) {
      completados.add(widget.nombre);
      await prefs.setStringList(_completadosKey, completados);
    }
  }

  // Agregar esta variable de estado
  bool _isImageEnlarged = false;

  final List<String> celebrationGifs = [
    'lib/utils/gifs/celebracion1.gif',
    'lib/utils/gifs/celebracion2.gif',
    'lib/utils/gifs/celebracion3.gif',
    'lib/utils/gifs/celebracion4.gif',
    'lib/utils/gifs/celebracion5.gif',
    'lib/utils/gifs/celebracion6.gif',
    'lib/utils/gifs/celebracion7.gif',
    'lib/utils/gifs/celebracion8.gif',
    'lib/utils/gifs/celebracion9.gif',
    'lib/utils/gifs/celebracion10.gif',
  ];

  // Actualizar el getter de colores
  Color get categoryColor {
    switch (widget.categoria) {
      case "Frutas":
        return Colors.red;
      case "Animales":
        return Colors.blue;
      case "Verduras":
        return Colors.green;
      case "Colores":
        return Colors.orange;
      case "Números":
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }

  @override
  void initState() {
    super.initState();
    ttsManager.initialize();
    TtsManager.instance.speak(widget.nombre);
    _dividirEnSilabas();
    silabasColocadas = List.generate(
      silabasOriginales.length,
      (index) => {"silaba": "", "ocupado": false, "id": null},
    );
    _breathController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    )..repeat(reverse: true);
    _breathAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );
    
    // Inicializar animaciones del tutorial
    _handAnimController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );
    // Verificar si debe mostrarse el tutorial
    _checkTutorial();
  }

  Future<void> _checkTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final bool tutorialAlreadyShown = prefs.getBool(_describeImagenTutorialShownKey) ?? false;

    if (_isTutorialEligibleLevel && !tutorialAlreadyShown) {
      // Esperar un momento para que la UI se construya
      await Future.delayed(Duration(milliseconds: 800));
      if (mounted) {
        _launchTutorial();
      }
    }
  }

  bool get _isTutorialEligibleLevel {
    return widget.currentIndex != null && widget.currentIndex! < 2;
  }

  void _launchTutorial() {
    if (!mounted || silabasOriginales.length < 2) return;

    setState(() {
      _showTutorial = true;
      _tutorialCompleted = false;
      _tutorialStartedOnCurrentScreen = true;
      _tutorialStep = 0;
      _firstSyllableKey = GlobalKey();
      _firstSlotKey = GlobalKey();
      _secondSyllableKey = GlobalKey();
      _secondSlotKey = GlobalKey();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _showTutorial) {
        _setTutorialStep(0);
      }
    });
  }

  void _setTutorialStep(int step) {
    if (!mounted) return;

    final int sequenceId = ++_tutorialSequenceId;

    setState(() {
      _tutorialStep = step;
    });

    _handAnimController.stop();

    final bool isBounceStep = step == 0 || step == 2;
    if (isBounceStep) {
      _handAnimController.duration = const Duration(milliseconds: 850);
      _handAnimController.repeat(reverse: true);

      Future.delayed(const Duration(milliseconds: 1600), () {
        if (!mounted || !_showTutorial || _tutorialStep != step || _tutorialSequenceId != sequenceId) {
          return;
        }
        _setTutorialStep(step + 1);
      });
      return;
    }

    _handAnimController.duration = const Duration(milliseconds: 1250);
    _loopTutorialDragStep(step, sequenceId);
  }

  Future<void> _loopTutorialDragStep(int step, int sequenceId) async {
    while (mounted && _showTutorial && _tutorialStep == step && _tutorialSequenceId == sequenceId) {
      await _handAnimController.forward(from: 0.0);
      if (!mounted || !_showTutorial || _tutorialStep != step || _tutorialSequenceId != sequenceId) {
        return;
      }
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  double _getTutorialOverlayOpacity(double progress) {
    final double safeProgress = progress.clamp(0.0, 1.0);
    if (progress <= 0.12) {
      final double fadeInT = (safeProgress / 0.12).clamp(0.0, 1.0);
      return Curves.easeOut.transform(fadeInT);
    }
    if (safeProgress >= 0.82) {
      final double fadeOutT = ((safeProgress - 0.82) / 0.18).clamp(0.0, 1.0);
      return 1 - Curves.easeIn.transform(fadeOutT);
    }
    return 1.0;
  }

  Future<void> _markTutorialCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_describeImagenTutorialShownKey, true);
    setState(() {
      _tutorialCompleted = true;
      _showTutorial = false;
    });
    _tutorialSequenceId++;
    _handAnimController.stop();
  }

  @override
  void dispose() {
    _breathController.dispose();
    _handAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    
    return Stack(
      children: [
        Scaffold(
          appBar: CustomBar(
            onBackPressed: () {
              Navigator.pop(context);
            },
            onHelpPressed: _mostrarAyuda,
          ),
          body: isLandscape ? _buildLandscapeLayout() : _buildPortraitLayout(),
        ),
        // Overlay del tutorial con manita
        if (_showTutorial) _buildTutorialOverlay(),
      ],
    );
  }

  // Widget del tutorial con manita animada (usa imagen manita.png)
  Widget _buildTutorialOverlay() {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _handAnimController,
          builder: (context, child) {
            // Seleccionar keys según el paso del tutorial
            final bool isSecondPair = _tutorialStep >= 2;
            final syllableKey = isSecondPair ? _secondSyllableKey : _firstSyllableKey;
            final slotKey = isSecondPair ? _secondSlotKey : _firstSlotKey;
            final String tutorialSyllable = _getTutorialSyllableText(isSecondPair);

            Offset? syllablePos = _getWidgetCenter(syllableKey);
            Offset? slotPos = _getWidgetCenter(slotKey);
            final Size syllableSize = _getWidgetSize(syllableKey) ?? const Size(75, 75);
            final Size slotSize = _getWidgetSize(slotKey) ?? const Size(75, 75);
            
            if (syllablePos == null) return SizedBox.shrink();
            
            const double handSize = 200.0;
            final double overlayOpacity = _getTutorialOverlayOpacity(_handAnimController.value);
            
            Offset targetPos;
            final bool isBounceStep = (_tutorialStep == 0 || _tutorialStep == 2);
            final bool isDragStep = !isBounceStep && slotPos != null;
            if (isBounceStep || slotPos == null) {
              // Paso de rebote sobre la sílaba
              final bounce = sin(_handAnimController.value * 3.14159 * 2) * 8;
              targetPos = Offset(syllablePos.dx, syllablePos.dy + bounce);
            } else {
              // Paso de arrastre de la sílaba al slot
              final t = _handAnimController.value;
              targetPos = Offset(
                syllablePos.dx + (slotPos.dx - syllablePos.dx) * t,
                syllablePos.dy + (slotPos.dy - syllablePos.dy) * t,
              );
            }
            
            // Centrar la imagen en el punto objetivo (la punta del dedo está en el centro de la imagen)
            final handCenter = isDragStep
                ? Offset(targetPos.dx + 42, targetPos.dy + 48)
                : targetPos;
            final handX = handCenter.dx - handSize / 2;
            final handY = handCenter.dy - handSize / 2;
            
            return Stack(
              children: [
                if (isDragStep)
                  _buildTutorialDragSyllable(
                    text: tutorialSyllable,
                    center: targetPos,
                    sourceSize: syllableSize,
                    targetSize: slotSize,
                    progress: _handAnimController.value,
                    opacity: overlayOpacity,
                  ),
                Positioned(
                  left: handX,
                  top: handY,
                  child: Opacity(
                    opacity: overlayOpacity,
                    child: Image.asset(
                      'lib/utils/images/fondos/manita.png',
                      width: handSize,
                      height: handSize,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Obtener el centro de un widget por su GlobalKey
  Offset? _getWidgetCenter(GlobalKey key) {
    try {
      final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null || !renderBox.hasSize) return null;
      final position = renderBox.localToGlobal(Offset.zero);
      return Offset(
        position.dx + renderBox.size.width / 2,
        position.dy + renderBox.size.height / 2,
      );
    } catch (e) {
      return null;
    }
  }

  Size? _getWidgetSize(GlobalKey key) {
    try {
      final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null || !renderBox.hasSize) return null;
      return renderBox.size;
    } catch (e) {
      return null;
    }
  }

  String _getTutorialSyllableText(bool isSecondPair) {
    if (silabasOriginales.isEmpty) return '';
    if (isSecondPair && silabasOriginales.length > 1) return silabasOriginales[1];
    return silabasOriginales.first;
  }

  Widget _buildTutorialDragSyllable({
    required String text,
    required Offset center,
    required Size sourceSize,
    required Size targetSize,
    required double progress,
    required double opacity,
  }) {
    final double width = sourceSize.width + (targetSize.width - sourceSize.width) * progress;
    final double height = sourceSize.height + (targetSize.height - sourceSize.height) * progress;
    final double fontSize = (height * 0.27).clamp(14.0, 22.0);

    return Positioned(
      left: center.dx - width / 2,
      top: center.dy - height / 2,
      child: Opacity(
        opacity: opacity * 0.95,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: categoryColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.yellow, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.yellow.withOpacity(0.45),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _mostrarAyuda() async {
    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ayuda',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📖 Cómo jugar:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text('1. Observa la imagen y forma la palabra correcta'),
                Text('2. Arrastra las sílabas al área de construcción'),
                Text('3. Completa la palabra en el orden correcto'),
                Text('4. Si quieres, sigue la guía visual de la manita'),
              ],
            ),
          ),
        );
      },
    );

    if (mounted) {
      _launchTutorial();
    }
  }

  // Layout para modo vertical (portrait)
  Widget _buildPortraitLayout() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.categoria == "Frutas"
                ? const Color.fromARGB(255, 255, 245, 245)
                : widget.categoria == "Verduras"
                    ? const Color.fromARGB(255, 245, 255, 245)
                    : const Color.fromARGB(255, 247, 250, 255),
            widget.categoria == "Frutas"
                ? const Color.fromARGB(255, 255, 230, 230)
                : widget.categoria == "Verduras"
                    ? const Color.fromARGB(255, 230, 255, 230)
                    : const Color.fromARGB(255, 215, 235, 255),
          ],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Imagen ocupa ~40% de la altura de pantalla
          final imageConstraints = BoxConstraints(
            maxHeight: constraints.maxHeight * 0.40,
            maxWidth: constraints.maxWidth,
          );

          // Calcular cuántas filas ocuparán las sílabas en portrait
          // El ancho disponible es la pantalla menos el padding horizontal (12 cada lado)
          final double availableWidth = constraints.maxWidth - 24;
          // El chip size se basa en ~25% de pantalla × 0.38 (misma fórmula que _buildSyllablesArea)
          final double estimatedChipSize = (constraints.maxHeight * 0.25 * 0.38).clamp(50.0, 80.0);
          final double estimatedSpacing = (availableWidth * 0.02).clamp(6.0, 12.0);
          final int silabasPerRow = (availableWidth / (estimatedChipSize + estimatedSpacing)).floor().clamp(1, 100);
          final int numRows = (silabas.length / silabasPerRow).ceil();

          // Flex dinámico: si hay 2 filas, dar más espacio al contenedor de sílabas
          final int flexConstruction = numRows > 1 ? 3 : 3;
          final int flexSyllabes    = numRows > 1 ? 4 : 3;

          final boxConstraints = BoxConstraints(
            maxHeight: constraints.maxHeight * 0.25,
            maxWidth: constraints.maxWidth,
          );

          return Column(
            children: [
              _buildBannerHeader(),
              _buildImageWidget(imageConstraints),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Column(
                    children: [
                      Expanded(
                        flex: flexConstruction,
                        child: _buildConstructionArea(constraints: boxConstraints),
                      ),
                      SizedBox(height: 8),
                      Expanded(
                        flex: flexSyllabes,
                        child: _buildSyllablesArea(constraints: boxConstraints),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 4), // Margen inferior
            ],
          );
        },
      ),
    );
  }

  // Layout para modo horizontal (landscape)
  Widget _buildLandscapeLayout() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.categoria == "Frutas"
                ? const Color.fromARGB(255, 255, 245, 245)
                : widget.categoria == "Verduras"
                    ? const Color.fromARGB(255, 245, 255, 245)
                    : const Color.fromARGB(255, 247, 250, 255),
            widget.categoria == "Frutas"
                ? const Color.fromARGB(255, 255, 230, 230)
                : widget.categoria == "Verduras"
                    ? const Color.fromARGB(255, 230, 255, 230)
                    : const Color.fromARGB(255, 215, 235, 255),
          ],
        ),
      ),
      child: Row(
        children: [
          // Panel izquierdo: Imagen y Banner (flex 2)
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildBannerHeader(),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return FittedBox(
                        fit: BoxFit.contain,
                        child: _buildImageWidget(constraints),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Panel derecho: Construcción de palabra y Sílabas (flex 3)
          Expanded(
            flex: 3,
            child: _buildRightPanel(),
          ),
        ],
      ),
    );
  }

  // Widget que envuelve los contenedores de la derecha en landscape
  Widget _buildRightPanel() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double outerPad = (constraints.maxWidth * 0.015).clamp(4.0, 8.0);

        return Column(
          children: [
            // Área de construcción de palabra (flex 3)
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.only(
                  left: outerPad,
                  right: outerPad,
                  top: outerPad,
                  bottom: outerPad * 0.5,
                ),
                child: _buildConstructionArea(constraints: constraints),
              ),
            ),
            // Área de sílabas con scroll horizontal (flex 3)
            Expanded(
              flex: 3,
              child: LayoutBuilder(
                builder: (context, sylConstraints) {
                  return Padding(
                    padding: EdgeInsets.only(
                      left: outerPad,
                      right: outerPad,
                      top: outerPad * 0.5,
                      bottom: outerPad,
                    ),
                    child: _buildSyllablesAreaLandscape(constraints: sylConstraints),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // Área de sílabas en landscape: scroll horizontal, una sola fila
  Widget _buildSyllablesAreaLandscape({BoxConstraints? constraints}) {
    final double hPad = constraints != null
        ? (constraints.maxWidth * 0.04).clamp(8.0, 25.0)
        : 25.0;
    final double vPad = constraints != null
        ? (constraints.maxHeight * 0.05).clamp(8.0, 16.0)
        : 12.0;
    final double titleSize = constraints != null
        ? (constraints.maxHeight * 0.10).clamp(12.0, 18.0)
        : 15.0;
    final double gap = constraints != null
        ? (constraints.maxHeight * 0.04).clamp(4.0, 10.0)
        : 8.0;
    // Chip ocupa ~55% de la altura del contenedor de sílabas
    final double chipSize = constraints != null
        ? (constraints.maxHeight * 0.55).clamp(46.0, 72.0)
        : 60.0;
    final double chipSpacing = (constraints?.maxWidth != null)
        ? (constraints!.maxWidth * 0.015).clamp(6.0, 14.0)
        : 10.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: categoryColor.withOpacity(0.5), width: 2.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Sílabas disponibles:",
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              color: categoryColor,
            ),
          ),
          Text(
            "Mantén para arrastrar · Desliza para ver más",
            style: TextStyle(
              fontSize: (titleSize * 0.65).clamp(9.0, 13.0),
              color: categoryColor.withOpacity(0.6),
            ),
          ),
          SizedBox(height: gap),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: silabas.map((silaba) => Padding(
                padding: EdgeInsets.symmetric(horizontal: chipSpacing / 2),
                child: _buildDraggableSilaba(silaba, size: chipSize, useLongPress: true),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // Widget del banner de encabezado
  Widget _buildBannerHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin: EdgeInsets.only(bottom: 2, top: 12, left: 8, right: 8),
      decoration: BoxDecoration(
        color: categoryColor.withOpacity(0.7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            "Categoría: ${widget.categoria}",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Widget de la imagen
  Widget _buildImageWidget(BoxConstraints? constraints) {
    // Calcular tamaño adaptativo basado en constraints disponibles
    double baseSize = 200.0;
    if (constraints != null) {
      // Usar hasta el 90% de la altura disponible para aprovechar mejor el espacio
      baseSize = (constraints.maxHeight * 0.9).clamp(180.0, 400.0);
    }
    final enlargedSize = baseSize * 1.05; // 5% más grande al tocar (menos agresivo con FittedBox)

    return GestureDetector(
      onTap: () {
        setState(() {
          _isImageEnlarged = true;
          decirTexto(widget.nombre);
        });
        Future.delayed(Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _isImageEnlarged = false;
            });
          }
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: _isImageEnlarged ? enlargedSize : baseSize,
        height: _isImageEnlarged ? enlargedSize : baseSize,
        margin: EdgeInsets.symmetric(vertical: 10), // Margen vertical de la imagen
        decoration: BoxDecoration(
          border: Border.all(
            color: _isImageEnlarged ? categoryColor.withOpacity(0.7) : categoryColor,
            width: _isImageEnlarged ? 3 : 2,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: categoryColor.withOpacity(_isImageEnlarged ? 0.3 : 0.1),
              spreadRadius: _isImageEnlarged ? 5 : 2,
              blurRadius: _isImageEnlarged ? 8 : 4,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Image.asset(
          widget.imagen,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[200],
              child: Icon(Icons.broken_image, size: 80, color: Colors.grey),
            );
          },
        ),
      ),
    );
  }

  // Widget del área de construcción de palabra
  Widget _buildConstructionArea({BoxConstraints? constraints}) {
    final double hPad = constraints != null
        ? (constraints.maxWidth * 0.04).clamp(8.0, 20.0)
        : 16.0;
    final double vPad = constraints != null
        ? (constraints.maxHeight * 0.06).clamp(8.0, 16.0)
        : 16.0;
    final double titleSize = constraints != null
        ? (constraints.maxHeight * 0.12).clamp(13.0, 20.0)
        : 18.0;
    final double gap = constraints != null
        ? (constraints.maxHeight * 0.08).clamp(8.0, 20.0)
        : 20.0;
    final double boxSize = constraints != null
        ? (constraints.maxHeight * 0.45).clamp(50.0, 80.0)
        : 75.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: categoryColor.withOpacity(0.5), width: 2.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Construye la palabra",
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              color: categoryColor,
            ),
          ),
          SizedBox(height: gap),
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    silabasOriginales.length,
                    (index) => _buildTargetBox(index, size: boxSize),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget del área de sílabas disponibles
  Widget _buildSyllablesArea({BoxConstraints? constraints}) {
    final double hPad = constraints != null
        ? (constraints.maxWidth * 0.04).clamp(8.0, 25.0)
        : 25.0;
    final double vPad = constraints != null
        ? (constraints.maxHeight * 0.05).clamp(8.0, 20.0)
        : 16.0;
    final double titleSize = constraints != null
        ? (constraints.maxHeight * 0.10).clamp(13.0, 20.0)
        : 16.0;
    final double gap = constraints != null
        ? (constraints.maxHeight * 0.04).clamp(6.0, 12.0)
        : 10.0;
    final double chipSize = constraints != null
        ? (constraints.maxHeight * 0.38).clamp(50.0, 80.0)
        : 75.0;
    final double chipSpacing = constraints != null
        ? (constraints.maxWidth * 0.02).clamp(6.0, 12.0)
        : 10.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: categoryColor.withOpacity(0.5), width: 2.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Sílabas disponibles:",
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              color: categoryColor,
            ),
          ),
          SizedBox(height: gap),
          Wrap(
            spacing: chipSpacing,
            runSpacing: chipSpacing,
            alignment: WrapAlignment.center,
            children: silabas.map((silaba) => _buildDraggableSilaba(silaba, size: chipSize)).toList(),
          ),
        ],
      ),
    );
  }

  // Mapa de correcciones fonéticas para sílabas que el TTS pronuncia incorrectamente
  final Map<String, String> _phoneticOverrides = {
    // Sílabas con O que el TTS pronuncia como "u" en inglés
    'TO': 'tó',
    'DO': 'dó',
    'PO': 'pó',
    'SO': 'só',
    'LO': 'ló',
    'NO': 'nó',
    'MO': 'mó',
    'RO': 'ró',
    'CO': 'có',
    'BO': 'bó',
    'GO': 'gó',
    'FO': 'fó',
    'JO': 'jó',
    'HO': 'hó',
    'VO': 'vó',
    'ZO': 'zó',
  };

  // Reemplazar el método decirTexto actual
  Future<void> decirTexto(String texto, {bool esSilaba = false}) async {
    if (esSilaba) {
      // Convertir a mayúsculas para buscar en el mapa
      String textoMayus = texto.toUpperCase();
      // Si hay una corrección fonética, usar esa; si no, usar el texto original
      String textoALeer = _phoneticOverrides[textoMayus] ?? texto;
      await ttsManager.speakSpecialSyllable(textoALeer);
    } else {
      await ttsManager.speak(texto);
    }
  }

  // Método para construir cajas objetivo
  Widget _buildTargetBox(int index, {double size = 75.0}) {
    final double fontSize = (size * 0.27).clamp(14.0, 22.0);
    final double marginH = (size * 0.1).clamp(4.0, 10.0);
    
    // Zócalos del tutorial
    final bool isFirstSlot = index == 0;
    final bool isSecondSlot = index == 1;
    final bool showTutorialHighlight = _showTutorial && (
        (isFirstSlot && _tutorialStep == 1) ||
        (isSecondSlot && _tutorialStep == 3));

    return DragTarget<Map<String, dynamic>>(
      key: isFirstSlot ? _firstSlotKey : isSecondSlot ? _secondSlotKey : null,
      builder: (context, candidateData, rejectedData) {
        return GestureDetector(
          onTap: () {
            // Si hay una sílaba colocada, leerla
            if (silabasColocadas[index]["ocupado"] == true) {
              decirTexto(silabasColocadas[index]["silaba"], esSilaba: true);
            } else {
              // Verificar si hay al menos una sílaba colocada
              final bool hasAnyPlaced = silabasColocadas.any((s) => s["ocupado"] == true);
              if (hasAnyPlaced) {
                decirTexto("Coloca ótra allí", esSilaba: false);
              } else {
                decirTexto("Coloca una sílaba allí", esSilaba: false);
              }
            }
          },
          child: Container(
            width: size,
            height: size,
            margin: EdgeInsets.symmetric(horizontal: marginH),
            decoration: BoxDecoration(
              color: silabasColocadas[index]["ocupado"] == true 
                  ? categoryColor 
                  : showTutorialHighlight 
                      ? Colors.yellow.withOpacity(0.3) 
                      : Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: showTutorialHighlight 
                    ? Colors.yellow 
                    : categoryColor.withOpacity(0.5),
                width: showTutorialHighlight ? 3 : 1,
              ),
              boxShadow: showTutorialHighlight
                  ? [BoxShadow(color: Colors.yellow.withOpacity(0.5), blurRadius: 10, spreadRadius: 2)]
                  : null,
            ),
            child: Center(
              child: silabasColocadas[index]["ocupado"] == true
                  ? Text(
                      silabasColocadas[index]["silaba"],
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  : Icon(Icons.add, color: Colors.grey[400], size: fontSize),
            ),
          ),
        );
      },
      onWillAcceptWithDetails: (details) => true,
      onAccept: (data) {
        setState(() {
          silabasColocadas[index] = {
            "silaba": data["silaba"],
            "ocupado": true,
            "id": data["id"],
          };
        });

        if (_showTutorial) {
          if (index == 0 && _tutorialStep <= 1) {
            _setTutorialStep(2);
          } else if (index == 1 && _tutorialStep >= 2) {
            _tutorialSequenceId++;
            _handAnimController.stop();
            setState(() {
              _showTutorial = false;
            });
          }
        }
        
        // Verificar si todas las sílabas han sido colocadas
        bool todasColocadas = silabasColocadas.every((s) => s["ocupado"] == true);
        
        if (todasColocadas) {
          _verificarPalabra();
        } else {
          // Si no es la última sílaba, leer solo la sílaba que se colocó
          decirTexto(data["silaba"], esSilaba: true);
        }
      },
    );
  }

  // Método para construir sílabas arrastrables
  // useLongPress: true en landscape para que el scroll horizontal no sea interferido
  Widget _buildDraggableSilaba(Map<String, dynamic> silaba, {double size = 75.0, bool useLongPress = false}) {
    final double fontSize = (size * 0.27).clamp(14.0, 22.0);
    
    // Verificar si la sílaba ya ha sido usada
    final bool isUsed = silabasColocadas.any((s) => s["id"] == silaba["id"] && s["ocupado"] == true);
    
    // Determinar si esta sílaba corresponde al tutorial
    final bool isFirstTutorialSyllable = _showTutorial && 
        silabasOriginales.isNotEmpty && 
        silaba["silaba"] == silabasOriginales[0] &&
        _tutorialStep <= 1;
    final bool isSecondTutorialSyllable = _showTutorial && 
        silabasOriginales.length > 1 && 
        silaba["silaba"] == silabasOriginales[1] &&
        _tutorialStep >= 2;
    final bool isTutorialSyllable = isFirstTutorialSyllable || isSecondTutorialSyllable;

    // Si ya está usada, mostrar solo el contenedor gris
    if (isUsed) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
      );
    }

    final Widget childWidget = GestureDetector(
      key: isFirstTutorialSyllable ? _firstSyllableKey : isSecondTutorialSyllable ? _secondSyllableKey : null,
      onTap: () {
        decirTexto(silaba["silaba"], esSilaba: true);
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isTutorialSyllable && _showTutorial 
              ? categoryColor.withOpacity(0.9) // Resaltar la sílaba del tutorial
              : categoryColor,
          borderRadius: BorderRadius.circular(10),
          border: isTutorialSyllable && _showTutorial
              ? Border.all(color: Colors.yellow, width: 3)
              : null,
        ),
        child: Center(
          child: Text(
            silaba["silaba"],
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );

    final Widget feedbackWidget = Material(
      color: Colors.transparent,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: categoryColor.withOpacity(0.8),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            silaba["silaba"],
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );

    final Widget draggingChild = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
      ),
    );

    // En landscape usamos LongPressDraggable para que el scroll horizontal
    // no sea interferido: deslizar = scroll, mantener = arrastrar sílaba
    if (useLongPress) {
      return LongPressDraggable<Map<String, dynamic>>(
        data: silaba,
        delay: Duration(milliseconds: 80),
        child: childWidget,
        feedback: feedbackWidget,
        childWhenDragging: draggingChild,
      );
    }

    return Draggable<Map<String, dynamic>>(
      data: silaba,
      child: childWidget,
      feedback: feedbackWidget,
      childWhenDragging: draggingChild,
    );
  }

  // Método para verificar si la palabra está completa y correcta
  void _verificarPalabra() {
    String palabraFormada = silabasColocadas
        .where((s) => s["ocupado"] == true)
        .map((s) => s["silaba"])
        .join("");

    if (silabasColocadas.every((s) => s["ocupado"] == true)) {
      if (palabraFormada == widget.nombre.toUpperCase()) {
        decirTexto('${widget.nombre}. ¡muy bien! intentemos la siguiénte');
        
        // Guardar como completado INMEDIATAMENTE
        _guardarCompletado();
        
        // Actualizar estadísticas: contar la palabra y sus sílabas
        final stateManager = StateManager();
        stateManager.actualizarContadores(
          nuevaPalabra: widget.nombre.toUpperCase(),
        );
        // Contar cada sílaba de la palabra
        for (int i = 0; i < silabasOriginales.length; i++) {
          stateManager.actualizarContadores(nuevaSilaba: true);
        }
        
        // Seleccionar un GIF aleatorio
        final random = Random();
        final randomGif = celebrationGifs[random.nextInt(celebrationGifs.length)];

        // Verificar si hay siguiente ejercicio
        final bool haySiguiente = widget.allItems != null &&
            widget.currentIndex != null &&
            widget.currentIndex! + 1 < widget.allItems!.length;
        
        // Marcar tutorial como completado si aplica
        if (_tutorialStartedOnCurrentScreen && !_tutorialCompleted) {
          _markTutorialCompleted();
        }
        
        setState(() {
          _isDialogOpen = true;
        });
        
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            // Obtener dimensiones de pantalla para tamaño adaptable
            final screenSize = MediaQuery.of(dialogContext).size;
            final isSmallScreen = screenSize.width < 360 || screenSize.height < 600;
            final mainImageSize = isSmallScreen ? 180.0 : 260.0;
            final gifSize = isSmallScreen ? 130.0 : 160.0;
            final padding = isSmallScreen ? 12.0 : 16.0;
            
            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              insetPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: PopScope(
                canPop: false,
                onPopInvokedWithResult: (didPop, _) {
                  if (!didPop) {
                    Navigator.pop(dialogContext);
                    setState(() { _isDialogOpen = false; });
                    _reiniciarEjercicio();
                  }
                },
                child: Container(
                constraints: BoxConstraints(
                  maxWidth: isSmallScreen ? screenSize.width * 0.92 : 410,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFFF093FB), Color(0xFF43E97B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.all(4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          'lib/utils/images/escuela.jpeg',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(color: Color(0xFF667EEA)),
                        ),
                      ),
                      Positioned.fill(
                        child: Container(color: Colors.black.withOpacity(0.55)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(padding),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white, width: 2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  widget.imagen,
                                  width: mainImageSize,
                                  height: mainImageSize,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: mainImageSize,
                                    height: mainImageSize,
                                    color: Colors.grey[300],
                                    child: Icon(Icons.image, size: 40, color: Colors.grey),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white, width: 2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  randomGif,
                                  width: gifSize,
                                  height: gifSize,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              '¡Muy bien! 🎉',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 18 : 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(blurRadius: 4, color: Colors.black54, offset: Offset(1, 2)),
                                ],
                              ),
                            ),
                            SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isSmallScreen ? 14 : 18, 
                                      vertical: isSmallScreen ? 8 : 10,
                                    ),
                                    backgroundColor: Colors.orange,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: Text(
                                    'Intentar otro',
                                    style: TextStyle(fontSize: isSmallScreen ? 13 : 15, color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(dialogContext);
                                    setState(() {
                                      _isDialogOpen = false;
                                    });
                                    _reiniciarEjercicio();
                                  },
                                ),
                                AnimatedBuilder(
                                  animation: _breathAnim,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: haySiguiente ? _breathAnim.value : 1.0,
                                      child: child,
                                    );
                                  },
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isSmallScreen ? 14 : 18, 
                                        vertical: isSmallScreen ? 8 : 10,
                                      ),
                                      backgroundColor: Colors.green,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: Text(
                                      haySiguiente ? 'Siguiente ▶' : 'Volver',
                                      style: TextStyle(fontSize: isSmallScreen ? 13 : 15, color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                    onPressed: () {
                                    Navigator.pop(dialogContext); // Cierra el diálogo
                                    setState(() {
                                      _isDialogOpen = false;
                                    });
                                    if (haySiguiente) {
                                      final nextItem = widget.allItems![widget.currentIndex! + 1];
                                      Navigator.pushReplacement(
                                        this.context,
                                        MaterialPageRoute(
                                          builder: (_) => ItemDetailScreen(
                                            nombre: nextItem['nombre'],
                                            imagen: nextItem['imagen'],
                                            categoria: widget.categoria,
                                            allItems: widget.allItems,
                                            currentIndex: widget.currentIndex! + 1,
                                          ),
                                        ),
                                      );
                                    } else {
                                      Navigator.pop(this.context, {'completado': true});
                                    }
                                  },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ),
            );
          },
        );
      } else {
        // Determinar tipo de error: sílabas incorrectas vs orden incorrecto
        List<String> silabasUsadas = silabasColocadas
            .where((s) => s["ocupado"] == true)
            .map((s) => s["silaba"] as String)
            .toList();
        List<String> sortedUsadas = [...silabasUsadas]..sort();
        List<String> sortedOriginales = [...silabasOriginales]..sort();
        final bool mismasSilabas = sortedUsadas.join() == sortedOriginales.join();

        String fraseError;
        if (mismasSilabas) {
          fraseError = '¡¡Casi lo tienes!!, están en el orden incorrecto.';
        } else {
          final List<String> opciones = [
            '¡Casi lo logras!, ¡inténtalo otra vez!!',
            '¡¡Estás muy cerca!!, ¡inténtalo otra vez!',
            '¡Sigue intentándolo!',
          ];
          fraseError = opciones[Random().nextInt(opciones.length)];
        }

        decirTexto(fraseError);

        setState(() {
          _isDialogOpen = true;
        });

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            // Obtener dimensiones de pantalla para tamaño adaptable
            final screenSize = MediaQuery.of(dialogContext).size;
            final isSmallScreen = screenSize.width < 360 || screenSize.height < 600;
            final dialogSize = isSmallScreen 
                ? screenSize.width * 0.85 
                : min(screenSize.width * 0.75, 320.0);
            final imageSize = isSmallScreen ? 100.0 : 120.0;
            final fontSize = isSmallScreen ? 14.0 : 16.0;
            final padding = isSmallScreen ? 12.0 : 16.0;
            
            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: PopScope(
                canPop: false,
                onPopInvokedWithResult: (didPop, _) {
                  if (!didPop) {
                    Navigator.pop(dialogContext);
                    setState(() { _isDialogOpen = false; });
                    _reiniciarEjercicio();
                  }
                },
                child: Container(
                width: dialogSize,
                constraints: BoxConstraints(
                  maxWidth: dialogSize,
                  maxHeight: dialogSize * 1.1, // Casi cuadrado
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFFF093FB), Color(0xFF43E97B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.all(4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          'lib/utils/images/escuela.jpeg',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(color: Color(0xFF667EEA)),
                        ),
                      ),
                      Positioned.fill(
                        child: Container(color: Colors.black.withOpacity(0.55)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(padding),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(dialogContext);
                                  setState(() {
                                    _isDialogOpen = false;
                                  });
                                  _reiniciarEjercicio();
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    'lib/utils/images/fondos/intento.jpg',
                                    width: imageSize,
                                    height: imageSize,
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, err, st) => Container(
                                      width: imageSize,
                                      height: imageSize,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.sentiment_dissatisfied_rounded,
                                        size: isSmallScreen ? 50 : 60,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: isSmallScreen ? 10 : 14),
                            Text(
                              fraseError,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: fontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(blurRadius: 4, color: Colors.black54, offset: Offset(1, 2)),
                                ],
                              ),
                            ),
                            SizedBox(height: isSmallScreen ? 12 : 16),
                            Center(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isSmallScreen ? 20 : 28, 
                                    vertical: isSmallScreen ? 8 : 10,
                                  ),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                  setState(() {
                                    _isDialogOpen = false;
                                  });
                                  _reiniciarEjercicio();
                                },
                                child: Text(
                                  '¡Continuar!',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 14 : 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
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
            );
          },
        );
      }
    }
  }

  // Agregar método para reiniciar el ejercicio
  void _reiniciarEjercicio() {
    setState(() {
      silabasColocadas = List.generate(
        silabasOriginales.length,
        (index) => {"silaba": "", "ocupado": false, "id": null},
      );
      _dividirEnSilabas(); // Esto mezclará las sílabas de nuevo
      // Resetear keys
      _firstSyllableKey = GlobalKey();
      _firstSlotKey = GlobalKey();
      _secondSyllableKey = GlobalKey();
      _secondSlotKey = GlobalKey();
      _tutorialSequenceId++;
      // Si el tutorial ya fue lanzado en esta pantalla, reiniciarlo
      if (_tutorialStartedOnCurrentScreen && !_tutorialCompleted) {
        _showTutorial = true;
        _tutorialStep = 0;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _showTutorial) {
            _setTutorialStep(0);
          }
        });
      }
    });
  }

  void _dividirEnSilabas() {
  String palabra = widget.nombre.toUpperCase();
  List<String> silabasTemp = [];
  
  // Definir manualmente las divisiones de sílabas para casos especiales
  Map<String, List<String>> casosEspeciales = {
    // Animales
    "PERRO": ["PE", "RRO"],
    "GATO": ["GA", "TO"],
    "VACA": ["VA", "CA"],
    "CABALLO": ["CA", "BA", "LLO"],
    "LEÓN": ["LE", "ÓN"],
    "ELEFANTE": ["E", "LE", "FAN", "TE"],
    "JIRAFA": ["JI", "RA", "FA"],
    "MONO": ["MO", "NO"],
    "PÁJARO": ["PÁ", "JA", "RO"],
    "PEZ": ["PEZ"],
    "TORTUGA": ["TOR", "TU", "GA"],
    "CONEJO": ["CO", "NE", "JO"],
    "SERPIENTE": ["SER", "PIEN", "TE"],
    "DELFÍN": ["DEL", "FÍN"],
    "BALLENA": ["BA", "LLE", "NA"],
    "CEBRA": ["CE", "BRA"],
    "CANGURO": ["CAN", "GU", "RO"],
    "KOALA": ["KO", "A", "LA"],
    "MARIPOSA": ["MA", "RI", "PO", "SA"],
    "PINGÜINO": ["PIN", "GÜI", "NO"],
    "TIGRE": ["TI", "GRE"],
    "PANDA": ["PAN", "DA"],
    "RATÓN": ["RA", "TÓN"],
    "OVEJA": ["O", "VE", "JA"],
    "GALLINA": ["GA", "LLI", "NA"],
    "CARACOL": ["CA", "RA", "COL"],
    "ARAÑA": ["A", "RA", "ÑA"],
    "RANA": ["RA", "NA"],
    "LOBO": ["LO", "BO"],
    // Frutas
    "MANGO": ["MAN", "GO"],
    "PERA": ["PE", "RA"],
    "UVAS": ["U", "VAS"],
    "PIÑA": ["PI", "ÑA"],
    "LIMÓN": ["LI", "MÓN"],
    "NARANJA": ["NA", "RAN", "JA"],
    "FRESA": ["FRE", "SA"],
    "BANANO": ["BA", "NA", "NO"],
    "SANDÍA": ["SAN", "DÍ", "A"],
    "MANZANA": ["MAN", "ZA", "NA"],
    "MELÓN": ["ME", "LÓN"],
    "PAPAYA": ["PA", "PA", "YA"],
    "DURAZNO": ["DU", "RAZ", "NO"],
    "CIRUELA": ["CI", "RUE", "LA"],
    "GUAYABA": ["GUA", "YA", "BA"],
    "CEREZA": ["CE", "RE", "ZA"],
    "GRANADA": ["GRA", "NA", "DA"],
    "KIWI": ["KI", "WI"],
    // Verduras
    "PAPA": ["PA", "PA"],
    "AJO": ["A", "JO"],
    "APIO": ["A", "PIO"],
    "CEBOLLA": ["CE", "BO", "LLA"],
    "TOMATE": ["TO", "MA", "TE"],
    "LECHUGA": ["LE", "CHU", "GA"],
    "ZANAHORIA": ["ZA", "NA", "HO", "RIA"],
    "BRÓCOLI": ["BRÓ", "CO", "LI"],
    "PEPINO": ["PE", "PI", "NO"],
    "CALABAZA": ["CA", "LA", "BA", "ZA"],
    "PIMIENTO": ["PI", "MIEN", "TO"],
    "ESPINACA": ["ES", "PI", "NA", "CA"],
    "CHAYOTE": ["CHA", "YO", "TE"],
    "COLIFLOR": ["CO", "LI", "FLOR"],
    "RÁBANO": ["RÁ", "BA", "NO"],
    "BERENJENA": ["BE", "REN", "JE", "NA"],
    // Colores
    "ROJO": ["RO", "JO"],
    "AZUL": ["A", "ZUL"],
    "VERDE": ["VER", "DE"],
    "NEGRO": ["NE", "GRO"],
    "BLANCO": ["BLAN", "CO"],
    "MORADO": ["MO", "RA", "DO"],
    "ROSADO": ["RO", "SA", "DO"],
    "MARRÓN": ["MA", "RRÓN"],
    "AMARILLO": ["A", "MA", "RI", "LLO"],
    "GRIS": ["GRIS"],
    "DORADO": ["DO", "RA", "DO"],
    "PLATEADO": ["PLA", "TE", "A", "DO"],
    "VIOLETA": ["VIO", "LE", "TA"],
    // Números
    "UNO": ["U", "NO"],
    "DOS": ["DOS"],
    "TRES": ["TRES"],
    "CUATRO": ["CUA", "TRO"],
    "CINCO": ["CIN", "CO"],
    "SEIS": ["SEIS"],
    "SIETE": ["SIE", "TE"],
    "OCHO": ["O", "CHO"],
    "NUEVE": ["NUE", "VE"],
    "DIEZ": ["DIEZ"],
    "ONCE": ["ON", "CE"],
    "DOCE": ["DO", "CE"],
    "QUINCE": ["QUIN", "CE"],
    "VEINTE": ["VEIN", "TE"],
  };

  // Verificar si la palabra es un caso especial
  if (casosEspeciales.containsKey(palabra)) {
    silabasTemp.addAll(casosEspeciales[palabra]!);
  } else {
    // Si no es un caso especial, dividir por longitud
    if (palabra.length <= 2) {
      silabasTemp.add(palabra);
    } else if (palabra.length <= 4) {
      silabasTemp.add(palabra.substring(0, 2));
      silabasTemp.add(palabra.substring(2));
    } else {
      int mitad = palabra.length ~/ 2;
      silabasTemp.add(palabra.substring(0, mitad));
      silabasTemp.add(palabra.substring(mitad));
    }
  }

  // Guardar las sílabas originales
  silabasOriginales = List.from(silabasTemp);
  
  // Detectar si hay sílabas trabadas en la palabra
  List<String> silabasTrabadasEnPalabra = _detectarSilabasTraabadas(silabasTemp);
  
  // Agregar sílabas aleatorias adicionales según el número de sílabas
  Random random = Random();
  int cantidadAdicionales = _calcularCantidadSilabas(silabasTemp.length);
  
  // Lista de sílabas simples comunes (distractores)
  List<String> silabasSimples = [
    "MA", "TA", "SA", "LA", "PA", "NA",
    "DA", "GA", "BA", "CA", "FA", "RA",
    "MI", "TI", "SI", "LI", "PI", "NI",
    "MO", "TO", "SO", "LO", "PO", "NO",
    "MU", "TU", "SU", "LU", "PU", "NU",
    "ME", "TE", "SE", "LE", "PE", "NE",
  ];
  
  // Lista de sílabas trabadas (para palabras con sílabas trabadas)
  List<String> silabasTraabadas = [
    "BRA", "BRE", "BRO", "BRU",
    "TRA", "TRE", "TRO", "TRU",
    "GRA", "GRE", "GRO", "GRU",
    "PRA", "PRE", "PRO", "PRU",
    "DRA", "DRE", "DRO", "DRU",
    "CRA", "CRE", "CRO", "CRU",
    "FRA", "FRE", "FRO", "FRU",
    "LLA", "LLE", "LLI", "LLO", "LLU",
    "RRA", "RRE", "RRI", "RRO", "RRU",
    "FLA", "FLE", "FLI", "FLO", "FLU",
    "CLA", "CLE", "CLI", "CLO", "CLU",
    "PLA", "PLE", "PLI", "PLO", "PLU",
  ];
  
  // Mezclar listas
  silabasSimples.shuffle(random);
  silabasTraabadas.shuffle(random);
  
  // Agregar sílabas según si la palabra tiene trabadas o no
  int indiceSimple = 0;
  int indiceTrabada = 0;
  
  // Si hay sílabas trabadas en la palabra, agregar 1-2 trabajadas diferentes
  if (silabasTrabadasEnPalabra.isNotEmpty) {
    int cantidadTraabadas = (cantidadAdicionales / 2).ceil();
    for (int i = 0; i < cantidadTraabadas && indiceTrabada < silabasTraabadas.length; i++) {
      if (!silabasTemp.contains(silabasTraabadas[indiceTrabada])) {
        silabasTemp.add(silabasTraabadas[indiceTrabada]);
      }
      indiceTrabada++;
    }
    cantidadAdicionales = cantidadAdicionales - (cantidadTraabadas);
  }
  
  // Completar con sílabas simples
  for (int i = 0; i < cantidadAdicionales && indiceSimple < silabasSimples.length; i++) {
    if (!silabasTemp.contains(silabasSimples[indiceSimple])) {
      silabasTemp.add(silabasSimples[indiceSimple]);
    }
    indiceSimple++;
  }

  // Mezclar todas las sílabas
  silabasTemp.shuffle();

  // Convertir a mapas con IDs únicos
  silabas = silabasTemp.map((silaba) => {
    "silaba": silaba,
    "id": UniqueKey().toString(),
  }).toList();

  print("Palabra: $palabra");
  print("Sílabas originales: $silabasOriginales");
  print("Todas las sílabas disponibles: $silabasTemp");
}

// Detectar si hay sílabas trabadas en la palabra
List<String> _detectarSilabasTraabadas(List<String> silabas) {
  List<String> silabasTraabadas = [];
  List<String> silabasTrabadasPatrones = [
    "BRA", "BRE", "BRO", "BRU",
    "TRA", "TRE", "TRO", "TRU",
    "GRA", "GRE", "GRO", "GRU",
    "PRA", "PRE", "PRO", "PRU",
    "DRA", "DRE", "DRO", "DRU",
    "CRA", "CRE", "CRO", "CRU",
    "FRA", "FRE", "FRO", "FRU",
    "LLA", "LLE", "LLI", "LLO", "LLU",
    "RRA", "RRE", "RRI", "RRO", "RRU",
    "FLA", "FLE", "FLI", "FLO", "FLU",
    "CLA", "CLE", "CLI", "CLO", "CLU",
    "PLA", "PLE", "PLI", "PLO", "PLU",
  ];
  
  for (var silaba in silabas) {
    for (var patron in silabasTrabadasPatrones) {
      if (silaba.contains(patron)) {
        silabasTraabadas.add(silaba);
        break;
      }
    }
  }
  return silabasTraabadas;
}

// Calcular cantidad de sílabas adicionales según el número de sílabas de la palabra
int _calcularCantidadSilabas(int numSilabas) {
  switch (numSilabas) {
    case 1:
      return 4; // 1 + 4 = 5 totales
    case 2:
      return 3; // 2 + 3 = 5 totales
    case 3:
      return 3; // 3 + 3 = 6 totales
    case 4:
      return 3; // 4 + 3 = 7 totales
    case 5:
      return 2; // 5 + 2 = 7 totales
    default:
      return 3;
  }
}
}