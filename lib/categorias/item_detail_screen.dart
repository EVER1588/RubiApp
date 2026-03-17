import 'package:flutter/material.dart';
import 'dart:math';
import '../constants/custombar_screen.dart'; // Agregar esta importación
import '../services/tts_manager.dart';
import '../constants/state_manager.dart';

class ItemDetailScreen extends StatefulWidget {
  final String nombre;
  final String imagen;
  final String categoria;
  
  const ItemDetailScreen({
    Key? key,
    required this.nombre,
    required this.imagen,
    required this.categoria,
  }) : super(key: key);

  @override
  _ItemDetailScreenState createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  List<Map<String, dynamic>> silabas = [];
  List<Map<String, dynamic>> silabasColocadas = [];
  List<String> silabasOriginales = [];

  final TtsManager ttsManager = TtsManager();

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
    _dividirEnSilabas();
    silabasColocadas = List.generate(
      silabasOriginales.length,
      (index) => {"silaba": "", "ocupado": false, "id": null},
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    
    return Scaffold(
      appBar: CustomBar(
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: isLandscape ? _buildLandscapeLayout() : _buildPortraitLayout(),
    );
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

    return DragTarget<Map<String, dynamic>>(
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
              color: silabasColocadas[index]["ocupado"] == true ? categoryColor : Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: categoryColor.withOpacity(0.5)),
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
        
        // Verificar si todas las sílabas han sido colocadas
        bool todasColocadas = silabasColocadas.every((s) => s["ocupado"] == true);
        
        if (todasColocadas) {
          // Si es la última sílaba, leer la palabra completa
          decirTexto(widget.nombre);
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
      onTap: () {
        decirTexto(silaba["silaba"], esSilaba: true);
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: categoryColor,
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
        decirTexto(widget.nombre);
        
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
        
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 300,
                  maxHeight: 400,
                ),
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.asset(
                            randomGif,
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              backgroundColor: categoryColor,
                            ),
                            child: Text(
                              'Intentar otro',
                              style: TextStyle(fontSize: 16),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              _reiniciarEjercicio();
                            },
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              backgroundColor: categoryColor,
                            ),
                            child: Text(
                              'Siguiente',
                              style: TextStyle(fontSize: 16),
                            ),
                            onPressed: () {
                              Navigator.pop(context); // Cierra el diálogo
                              Navigator.pop(context, {'completado': true}); // Retorna a la lista de animales
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      } else {
        // Si la palabra está mal formada
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange),
                  SizedBox(width: 10),
                  Text('¡Inténtalo de nuevo!'),
                ],
              ),
              content: Text('Las sílabas no están en el orden correcto.'),
              actions: [
                TextButton(
                  child: Text('Continuar'),
                  onPressed: () {
                    Navigator.pop(context);
                    _reiniciarEjercicio();
                  },
                ),
              ],
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
    "PLÁTANO": ["PLÁ", "TA", "NO"],
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