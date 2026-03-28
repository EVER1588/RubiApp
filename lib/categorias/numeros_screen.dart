import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'item_detail_screen.dart';
import '../constants/custombar_screen.dart';
import '../services/tts_manager.dart';

class NumerosScreen extends StatefulWidget {
  @override
  _NumerosScreenState createState() => _NumerosScreenState();
}

class _NumerosScreenState extends State<NumerosScreen> {
  int _itemSize = 1;
  int _getPortraitColumns(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide > 600;
    if (isTablet) return [4, 3, 2][_itemSize];
    return [3, 2, 1][_itemSize];
  }
  int _getLandscapeColumns() => [5, 4, 3][_itemSize];

  List<Map<String, dynamic>> numeros = [
    {"nombre": "Uno", "imagen": "lib/utils/images/numeros/uno.jpeg"},
    {"nombre": "Dos", "imagen": "lib/utils/images/numeros/dos.jpeg"},
    {"nombre": "Tres", "imagen": "lib/utils/images/numeros/tres.jpeg"},
    {"nombre": "Cuatro", "imagen": "lib/utils/images/numeros/cuatro.jpeg"},
    {"nombre": "Cinco", "imagen": "lib/utils/images/numeros/cinco.jpeg"},
    {"nombre": "Seis", "imagen": "lib/utils/images/numeros/seis.jpeg"},
    {"nombre": "Siete", "imagen": "lib/utils/images/numeros/siete.jpeg"},
    {"nombre": "Ocho", "imagen": "lib/utils/images/numeros/ocho.jpeg"},
    {"nombre": "Nueve", "imagen": "lib/utils/images/numeros/nueve.jpeg"},
    {"nombre": "Diez", "imagen": "lib/utils/images/numeros/diez.jpeg"},
    {"nombre": "Once", "imagen": "lib/utils/images/numeros/once.jpeg"},
    {"nombre": "Doce", "imagen": "lib/utils/images/numeros/doce.jpeg"},
    {"nombre": "Trece", "imagen": "lib/utils/images/numeros/trece.jpeg"},
    {"nombre": "Catorce", "imagen": "lib/utils/images/numeros/catorce.jpeg"},
    {"nombre": "Quince", "imagen": "lib/utils/images/numeros/quince.jpeg"},
    {"nombre": "Dieciséis", "imagen": "lib/utils/images/numeros/dieciseis.jpeg"},
    {"nombre": "Diecisiete", "imagen": "lib/utils/images/numeros/diecisiete.jpeg"},
    {"nombre": "Dieciocho", "imagen": "lib/utils/images/numeros/dieciocho.jpeg"},
    {"nombre": "Diecinueve", "imagen": "lib/utils/images/numeros/diecinueve.jpeg"},
    {"nombre": "Veinte", "imagen": "lib/utils/images/numeros/veinte.jpeg"},
  ];

  @override
  void initState() {
    super.initState();
    _cargarProgreso();
    _loadItemSize();
    TtsManager.instance.speak("Números");
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
    final ejerciciosCompletados = prefs.getStringList('numeros_completados') ?? [];
    
    setState(() {
      for (var numero in numeros) {
        numero['desbloqueado'] = false;
      }
      
      if (numeros.isNotEmpty) {
        numeros[0]['desbloqueado'] = true;
      }
      
      if (ejerciciosCompletados.isNotEmpty) {
        for (var nombre in ejerciciosCompletados) {
          int index = numeros.indexWhere((n) => n['nombre'] == nombre);
          if (index != -1) {
            numeros[index]['desbloqueado'] = true;
            if (index + 1 < numeros.length) {
              numeros[index + 1]['desbloqueado'] = true;
            }
          }
        }
      }
    });
  }

  Future<void> _marcarComoCompletado(String nombre) async {
    final prefs = await SharedPreferences.getInstance();
    final ejerciciosCompletados = prefs.getStringList('numeros_completados') ?? [];
    
    if (!ejerciciosCompletados.contains(nombre)) {
      ejerciciosCompletados.add(nombre);
      await prefs.setStringList('numeros_completados', ejerciciosCompletados);
      
      setState(() {
        final currentIndex = numeros.indexWhere((n) => n['nombre'] == nombre);
        if (currentIndex + 1 < numeros.length) {
          numeros[currentIndex + 1]['desbloqueado'] = true;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomBar(
        titleText: 'Números',
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
              const Color.fromARGB(255, 250, 245, 255),
              const Color.fromARGB(255, 240, 230, 255),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: () => TtsManager.instance.speak("Selecciona un número para aprender a escribir su nombre"),
                child: Container(
                padding: EdgeInsets.all(15),
                margin: EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.7),
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
                  "Selecciona un número para aprender a escribir su nombre",
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
                  itemCount: numeros.length,
                  padding: EdgeInsets.all(5),
                  itemBuilder: (context, index) {
                    return _buildNumeroItem(numeros[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumeroItem(Map<String, dynamic> numero) {
    final bool desbloqueado = numero['desbloqueado'];

    return GestureDetector(
      onTap: desbloqueado ? () => _seleccionarNumero(numero["nombre"]) : null,
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
              color: desbloqueado ? Colors.purple.withOpacity(0.5) : Colors.grey,
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
                          numero["imagen"],
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
                        color: Colors.purple.withOpacity(0.7),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(13),
                          bottomRight: Radius.circular(13),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          numero["nombre"],
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

  void _seleccionarNumero(String numero) async {
    final int index = numeros.indexWhere((n) => n['nombre'] == numero);
    Map<String, dynamic> numeroSeleccionado = numeros[index];
    
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemDetailScreen(
          nombre: numeroSeleccionado["nombre"],
          imagen: numeroSeleccionado["imagen"],
          categoria: "Números",
          allItems: numeros,
          currentIndex: index,
        ),
      ),
    );

    await _cargarProgreso();
  }
}