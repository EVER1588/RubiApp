import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'item_detail_screen.dart';
import '../constants/custombar_screen.dart';
import '../services/tts_manager.dart';

class FamiliaScreen extends StatefulWidget {
  @override
  _FamiliaScreenState createState() => _FamiliaScreenState();
}

class _FamiliaScreenState extends State<FamiliaScreen> {
  int _itemSize = 1;
  int _getPortraitColumns(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide > 600;
    if (isTablet) return [4, 3, 2][_itemSize];
    return [3, 2, 1][_itemSize];
  }
  int _getLandscapeColumns() => [5, 4, 3][_itemSize];

  List<Map<String, dynamic>> familia = [
    {"nombre": "Papá",    "imagen": "lib/utils/images/familia/papa.jpeg"},
    {"nombre": "Mamá",    "imagen": "lib/utils/images/familia/mama.jpeg"},
    {"nombre": "Hijo",    "imagen": "lib/utils/images/familia/hijo.jpeg"},
    {"nombre": "Hija",    "imagen": "lib/utils/images/familia/hija.jpeg"},
    {"nombre": "Hermano", "imagen": "lib/utils/images/familia/hermano.jpeg"},
    {"nombre": "Hermana", "imagen": "lib/utils/images/familia/hermana.jpeg"},
    {"nombre": "Bebé",    "imagen": "lib/utils/images/familia/bebe.jpeg"},
    {"nombre": "Abuelo",  "imagen": "lib/utils/images/familia/abuelo.jpeg"},
    {"nombre": "Abuela",  "imagen": "lib/utils/images/familia/abuela.jpeg"},
    {"nombre": "Tío",     "imagen": "lib/utils/images/familia/tio.jpeg"},
    {"nombre": "Tía",     "imagen": "lib/utils/images/familia/tia.jpeg"},
    {"nombre": "Primo",   "imagen": "lib/utils/images/familia/primo.jpeg"},
    {"nombre": "Prima",   "imagen": "lib/utils/images/familia/prima.jpeg"},

  ];

  @override
  void initState() {
    super.initState();
    _cargarProgreso();
    _loadItemSize();
    TtsManager.instance.speak("Familia");
  }

  ModalRoute? _currentRoute;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_currentRoute == null) {
      _currentRoute = ModalRoute.of(context);
      _currentRoute?.secondaryAnimation?.addStatusListener(_onRouteChanged);
    }
  }

  void _onRouteChanged(AnimationStatus status) {
    if (status == AnimationStatus.dismissed && mounted) {
      _cargarProgreso();
    }
  }

  @override
  void dispose() {
    _currentRoute?.secondaryAnimation?.removeStatusListener(_onRouteChanged);
    super.dispose();
  }

  Future<void> _loadItemSize() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _itemSize = prefs.getInt('metodo3ItemSize') ?? 1;
    });
  }

  Future<void> _cargarProgreso() async {
    final prefs = await SharedPreferences.getInstance();
    final ejerciciosCompletados = prefs.getStringList('familia_completados') ?? [];

    setState(() {
      for (var miembro in familia) {
        miembro['desbloqueado'] = false;
      }

      if (familia.isNotEmpty) {
        familia[0]['desbloqueado'] = true;
      }

      if (ejerciciosCompletados.isNotEmpty) {
        for (var nombre in ejerciciosCompletados) {
          int index = familia.indexWhere((m) => m['nombre'] == nombre);
          if (index != -1) {
            familia[index]['desbloqueado'] = true;
            if (index + 1 < familia.length) {
              familia[index + 1]['desbloqueado'] = true;
            }
          }
        }
      }
    });
  }

  void _seleccionarMiembro(String nombre) async {
    final int index = familia.indexWhere((m) => m['nombre'] == nombre);
    Map<String, dynamic> miembro = familia[index];

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemDetailScreen(
          nombre: miembro["nombre"],
          imagen: miembro["imagen"],
          categoria: "Familia",
          allItems: familia,
          currentIndex: index,
        ),
      ),
    );

    await _cargarProgreso();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomBar(
        titleText: 'Familia',
        onBackPressed: () {
          Navigator.pop(context);
        },
        onSettingsPressed: () => mostrarAjustesTamanio(context, _itemSize, (v) => setState(() => _itemSize = v)),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color.fromARGB(255, 255, 245, 250),
              const Color.fromARGB(255, 255, 225, 240),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: () => TtsManager.instance.speak("Selecciona un miembro de la familia para aprender a escribir su nombre"),
                child: Container(
                  padding: EdgeInsets.all(15),
                  margin: EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: Colors.pink.withOpacity(0.7),
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
                    "Selecciona un miembro de la familia para aprender a escribir su nombre",
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
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).orientation == Orientation.portrait
                        ? _getPortraitColumns(context)
                        : _getLandscapeColumns(),
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: familia.length,
                  padding: EdgeInsets.all(5),
                  itemBuilder: (context, index) {
                    return _buildFamiliaItem(familia[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFamiliaItem(Map<String, dynamic> miembro) {
    final bool desbloqueado = miembro['desbloqueado'] ?? false;

    return GestureDetector(
      onTap: desbloqueado ? () => _seleccionarMiembro(miembro["nombre"]) : null,
      child: Opacity(
        opacity: desbloqueado ? 1.0 : 0.5,
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
              color: desbloqueado ? Colors.pink.withOpacity(0.5) : Colors.grey,
              width: 2,
            ),
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    flex: 6,
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(13),
                        topRight: Radius.circular(13),
                      ),
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        child: Image.asset(
                          miembro["imagen"],
                          fit: BoxFit.cover,
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
                  Expanded(
                    flex: 2,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.pink.withOpacity(0.7),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(13),
                          bottomRight: Radius.circular(13),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          miembro["nombre"],
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
                  ),
                ],
              ),
              if (!desbloqueado)
                Center(
                  child: Icon(
                    Icons.lock,
                    size: 40,
                    color: Colors.grey,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
