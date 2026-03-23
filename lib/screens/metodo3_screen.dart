import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/custombar_screen.dart';
import '../services/tts_manager.dart';
import '../categorias/animales_screen.dart';
import '../categorias/frutas_screen.dart';
import '../categorias/verduras_screen.dart';
import '../categorias/colores_screen.dart';
import '../categorias/numeros_screen.dart';

class Metodo3Screen extends StatefulWidget {
  @override
  _Metodo3ScreenState createState() => _Metodo3ScreenState();
}

class _Metodo3ScreenState extends State<Metodo3Screen> {
  int _itemSize = 1; // 0=Pequeños, 1=Medianos, 2=Grandes

  // Instancias cacheadas para preservar el estado de cada categoría
  AnimalesScreen? _animales;
  FrutasScreen? _frutas;
  VerdurasScreen? _verduras;
  ColoresScreen? _colores;
  NumerosScreen? _numeros;

  final List<Map<String, dynamic>> categorias = [
    {"nombre": "Animales", "imagen": "lib/utils/images/animales.jpeg"},
    {"nombre": "Frutas", "imagen": "lib/utils/images/frutas.jpeg"},
    {"nombre": "Verduras", "imagen": "lib/utils/images/verduras.jpeg"},
    {"nombre": "Colores", "imagen": "lib/utils/images/colores.jpeg"},
    {"nombre": "Números", "imagen": "lib/utils/images/numeros.jpeg"},
    {"nombre": "Familia", "imagen": "lib/utils/images/familia.jpeg"},
    {"nombre": "Ropa", "imagen": "lib/utils/images/ropa.jpeg"},
    {"nombre": "Transportes", "imagen": "lib/utils/images/transportes.jpeg"},
    {"nombre": "Escuela", "imagen": "lib/utils/images/escuela.jpeg"},
    {"nombre": "Cuerpo", "imagen": "lib/utils/images/cuerpo.jpeg"},
    {"nombre": "Casa", "imagen": "lib/utils/images/casa.jpeg"},
    {"nombre": "Clima", "imagen": "lib/utils/images/clima.jpeg"},
    {"nombre": "incectos", "imagen": "lib/utils/images/incectos.jpeg"},
  ];

  // Mapeo de tamaño a columnas
  int _getPortraitColumns() => [3, 2, 1][_itemSize];
  int _getLandscapeColumns() => [5, 4, 3][_itemSize];

  @override
  void initState() {
    super.initState();
    _loadSettings();
    TtsManager.instance.speak("Describe la Imagen");
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _itemSize = prefs.getInt('metodo3ItemSize') ?? 1;
    });
  }

  void _navegarACategoria(String categoria) {
    TtsManager.instance.speak(categoria);

    Widget? screen;
    if (categoria == "Animales") {
      _animales ??= AnimalesScreen();
      screen = _animales;
    } else if (categoria == "Frutas") {
      _frutas ??= FrutasScreen();
      screen = _frutas;
    } else if (categoria == "Verduras") {
      _verduras ??= VerdurasScreen();
      screen = _verduras;
    } else if (categoria == "Colores") {
      _colores ??= ColoresScreen();
      screen = _colores;
    } else if (categoria == "Números") {
      _numeros ??= NumerosScreen();
      screen = _numeros;
    }

    if (screen != null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => screen!));
    }
  }

  void _mostrarAjustes() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            final labels = ['Pequeños', 'Medianos', 'Grandes'];
            final icons = [Icons.grid_view_rounded, Icons.view_module_rounded, Icons.view_stream_rounded];
            final colors = [Colors.teal, Colors.blue, Colors.deepPurple];
            final isDialogLandscape = MediaQuery.of(ctx).orientation == Orientation.landscape;

            Widget buildChip(int i) {
              final selected = _itemSize == i;
              return GestureDetector(
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setInt('metodo3ItemSize', i);
                  setDialogState(() {});
                  setState(() { _itemSize = i; });
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: isDialogLandscape ? 10 : 12, vertical: isDialogLandscape ? 8 : 14),
                  decoration: BoxDecoration(
                    color: selected ? colors[i] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: selected ? Border.all(color: colors[i].withOpacity(0.8), width: 2) : Border.all(color: Colors.grey[300]!, width: 1),
                    boxShadow: selected ? [BoxShadow(color: colors[i].withOpacity(0.3), blurRadius: 6, offset: Offset(0, 3))] : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icons[i], size: 16, color: selected ? Colors.white : Colors.grey[600]),
                      SizedBox(width: 4),
                      Text(labels[i], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: selected ? Colors.white : Colors.grey[700])),
                    ],
                  ),
                ),
              );
            }

            return Dialog(
              insetPadding: isDialogLandscape ? EdgeInsets.symmetric(horizontal: 170, vertical: 24) : EdgeInsets.symmetric(horizontal: 40, vertical: 24),
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
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF667EEA).withOpacity(0.10), Color(0xFFF093FB).withOpacity(0.14)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(20, isDialogLandscape ? 10 : 16, 8, 0),
                        child: Row(
                          children: [
                            Text('⚙️ Ajustes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isDialogLandscape ? 16 : 18, color: Colors.white)),
                            Spacer(),
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
                                onPressed: () => Navigator.of(dialogContext).pop(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(color: Color(0xFF667EEA).withOpacity(0.2), height: 1),
                      Padding(
                        padding: EdgeInsets.fromLTRB(16, isDialogLandscape ? 10 : 16, 16, isDialogLandscape ? 14 : 20),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(isDialogLandscape ? 10 : 14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.blue.withOpacity(0.25), width: 1.5),
                            boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.08), blurRadius: 6, offset: Offset(0, 3))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.photo_size_select_large_rounded, color: Colors.blue[700], size: 22),
                                  SizedBox(width: 8),
                                  Text('📐 Tamaño de items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blue[800])),
                                ],
                              ),
                              SizedBox(height: 10),
                              isDialogLandscape
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: List.generate(3, (i) => buildChip(i)),
                                  )
                                : Column(
                                    children: List.generate(3, (i) => Padding(
                                      padding: EdgeInsets.only(bottom: i < 2 ? 8 : 0),
                                      child: SizedBox(width: double.infinity, child: buildChip(i)),
                                    )),
                                  ),
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

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final columns = isLandscape ? _getLandscapeColumns() : _getPortraitColumns();

    return Scaffold(
      appBar: CustomBar(
        titleText: 'Describe la Imágen',
        onBackPressed: () => Navigator.pop(context),
        onSettingsPressed: _mostrarAjustes,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color.fromARGB(255, 247, 250, 255),
              const Color.fromARGB(255, 215, 235, 255),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              // Instrucciones - al tocar lee en voz alta
              GestureDetector(
                onTap: () => TtsManager.instance.speak(
                  "Selecciona una categoría y aprendamos a escribir palabras con imágenes",
                ),
                child: Container(
                  padding: EdgeInsets.all(15),
                  margin: EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    "Selecciona una categoría y aprendamos a escribir palabras con imágenes",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(blurRadius: 4, color: Colors.black45, offset: Offset(1, 2)),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Grid con las categorías
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return AnimatedSwitcher(
                      duration: Duration(milliseconds: 400),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(scale: Tween(begin: 0.92, end: 1.0).animate(animation), child: child),
                        );
                      },
                      child: GridView.builder(
                        key: ValueKey<int>(columns),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: categorias.length,
                        padding: EdgeInsets.all(5),
                        itemBuilder: (context, index) {
                          return _buildCategoriaItem(categorias[index]);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriaItem(Map<String, dynamic> categoria) {
    return GestureDetector(
      onTap: () => _navegarACategoria(categoria["nombre"]),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: Colors.blue.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(13),
                  topRight: Radius.circular(13),
                ),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: Image.asset(
                    categoria["imagen"],
                    fit: BoxFit.fill,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.image_not_supported,
                        size: 40,
                        color: Colors.grey,
                      );
                    },
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.7),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(13),
                  bottomRight: Radius.circular(13),
                ),
              ),
              child: Center(
                child: Text(
                  categoria["nombre"],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    shadows: [
                      Shadow(blurRadius: 4, color: Colors.black45, offset: Offset(1, 2)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}