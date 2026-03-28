import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'item_detail_screen.dart';
import '../constants/custombar_screen.dart';
import '../services/tts_manager.dart';

class VerdurasScreen extends StatefulWidget {
  @override
  _VerdurasScreenState createState() => _VerdurasScreenState();
}

class _VerdurasScreenState extends State<VerdurasScreen> {
  int _itemSize = 1;
  ModalRoute? _currentRoute;
  int _getPortraitColumns(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide > 600;
    if (isTablet) return [4, 3, 2][_itemSize];
    return [3, 2, 1][_itemSize];
  }
  int _getLandscapeColumns() => [5, 4, 3][_itemSize];

  List<Map<String, dynamic>> verduras = [
    {"nombre": "Papa", "imagen": "lib/utils/images/verduras/papa.jpeg"},
    {"nombre": "Ajo", "imagen": "lib/utils/images/verduras/ajo.jpeg"},
    {"nombre": "Apio", "imagen": "lib/utils/images/verduras/apio.jpeg"},
    {"nombre": "Cebolla", "imagen": "lib/utils/images/verduras/cebolla.jpeg"},
    {"nombre": "Tomate", "imagen": "lib/utils/images/verduras/tomate.jpeg"},
    {"nombre": "Lechuga", "imagen": "lib/utils/images/verduras/lechuga.jpeg"},
    {"nombre": "Zanahoria", "imagen": "lib/utils/images/verduras/zanahoria.jpeg"},
    {"nombre": "Brócoli", "imagen": "lib/utils/images/verduras/brocoli.jpeg"},
    {"nombre": "Pepino", "imagen": "lib/utils/images/verduras/pepino.jpeg"},
    {"nombre": "Calabaza", "imagen": "lib/utils/images/verduras/calabaza.jpeg"},
    {"nombre": "Chile", "imagen": "lib/utils/images/verduras/chile.jpeg"},
    {"nombre": "Espinaca", "imagen": "lib/utils/images/verduras/espinaca.jpeg"},
    {"nombre": "Chayote", "imagen": "lib/utils/images/verduras/chayote.jpeg"},
    {"nombre": "Coliflor", "imagen": "lib/utils/images/verduras/coliflor.jpeg"},
    {"nombre": "Rábano", "imagen": "lib/utils/images/verduras/rabano.jpeg"},
    {"nombre": "Berenjena", "imagen": "lib/utils/images/verduras/berenjena.jpeg"},
  ];

  @override
  void initState() {
    super.initState();
    _cargarProgreso();
    _loadItemSize();
    TtsManager.instance.speak("Verduras");
  }

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
    final ejerciciosCompletados = prefs.getStringList('verduras_completados') ?? [];
    
    setState(() {
      for (var verdura in verduras) {
        verdura['desbloqueado'] = false;
      }
      
      if (verduras.isNotEmpty) {
        verduras[0]['desbloqueado'] = true;
      }
      
      if (ejerciciosCompletados.isNotEmpty) {
        for (var nombre in ejerciciosCompletados) {
          int index = verduras.indexWhere((v) => v['nombre'] == nombre);
          if (index != -1) {
            verduras[index]['desbloqueado'] = true;
            if (index + 1 < verduras.length) {
              verduras[index + 1]['desbloqueado'] = true;
            }
          }
        }
      }
    });
  }

  Future<void> _marcarComoCompletado(String nombre) async {
    final prefs = await SharedPreferences.getInstance();
    final ejerciciosCompletados = prefs.getStringList('verduras_completados') ?? [];
    
    if (!ejerciciosCompletados.contains(nombre)) {
      ejerciciosCompletados.add(nombre);
      await prefs.setStringList('verduras_completados', ejerciciosCompletados);
      
      setState(() {
        final currentIndex = verduras.indexWhere((v) => v['nombre'] == nombre);
        if (currentIndex + 1 < verduras.length) {
          verduras[currentIndex + 1]['desbloqueado'] = true;
        }
      });
    }
  }

  void _seleccionarVerdura(String verdura) async {
    final int index = verduras.indexWhere((v) => v['nombre'] == verdura);
    Map<String, dynamic> verduraSeleccionada = verduras[index];
    
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemDetailScreen(
          nombre: verduraSeleccionada["nombre"],
          imagen: verduraSeleccionada["imagen"],
          categoria: "Verduras",
          allItems: verduras,
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
        titleText: 'Verduras',
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
              const Color.fromARGB(255, 245, 255, 245),
              const Color.fromARGB(255, 230, 255, 230),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: () => TtsManager.instance.speak("Selecciona una verdura para aprender a escribir su nombre"),
                child: Container(
                padding: EdgeInsets.all(15),
                margin: EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.7),
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
                  "Selecciona una verdura para aprender a escribir su nombre",
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
                    crossAxisCount: MediaQuery.of(context).orientation == Orientation.portrait ? _getPortraitColumns(context) : _getLandscapeColumns(),
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: verduras.length,
                  padding: EdgeInsets.all(5),
                  itemBuilder: (context, index) {
                    return _buildVerduraItem(verduras[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerduraItem(Map<String, dynamic> verdura) {
    final bool desbloqueado = verdura['desbloqueado'];

    return GestureDetector(
      onTap: desbloqueado ? () => _seleccionarVerdura(verdura["nombre"]) : null,
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
              color: desbloqueado ? Colors.green.withOpacity(0.5) : Colors.grey,
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
                          verdura["imagen"],
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
                        color: Colors.green.withOpacity(0.7),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(13),
                          bottomRight: Radius.circular(13),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          verdura["nombre"],
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