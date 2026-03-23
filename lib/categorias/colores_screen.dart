import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'item_detail_screen.dart';
import '../constants/custombar_screen.dart';
import '../services/tts_manager.dart';

class ColoresScreen extends StatefulWidget {
  @override
  _ColoresScreenState createState() => _ColoresScreenState();
}

class _ColoresScreenState extends State<ColoresScreen> {
  int _itemSize = 1;
  int _getPortraitColumns() => [3, 2, 1][_itemSize];
  int _getLandscapeColumns() => [5, 4, 3][_itemSize];

  List<Map<String, dynamic>> colores = [
    {"nombre": "Rojo", "imagen": "lib/utils/images/colores/rojo.jpeg"},
    {"nombre": "Azul", "imagen": "lib/utils/images/colores/azul.jpeg"},
    {"nombre": "Verde", "imagen": "lib/utils/images/colores/verde.jpeg"},
    {"nombre": "Negro", "imagen": "lib/utils/images/colores/negro.jpeg"},
    {"nombre": "Blanco", "imagen": "lib/utils/images/colores/blanco.jpeg"},
    {"nombre": "Morado", "imagen": "lib/utils/images/colores/morado.jpeg"},
    {"nombre": "Rosado", "imagen": "lib/utils/images/colores/rosado.jpeg"},
    {"nombre": "Naranja", "imagen": "lib/utils/images/colores/naranja.jpeg"},
    {"nombre": "Marrón", "imagen": "lib/utils/images/colores/marron.jpeg"},
    {"nombre": "Amarillo", "imagen": "lib/utils/images/colores/amarillo.jpeg"},
    {"nombre": "Gris", "imagen": "lib/utils/images/colores/gris.jpeg"},
    {"nombre": "Dorado", "imagen": "lib/utils/images/colores/dorado.jpeg"},
    {"nombre": "Plateado", "imagen": "lib/utils/images/colores/plateado.jpeg"},
    {"nombre": "Violeta", "imagen": "lib/utils/images/colores/violeta.jpeg"},
  ];

  @override
  void initState() {
    super.initState();
    _cargarProgreso();
    _loadItemSize();
    TtsManager.instance.speak("Colores");
  }

  Future<void> _loadItemSize() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _itemSize = prefs.getInt('metodo3ItemSize') ?? 1;
    });
  }

  Future<void> _cargarProgreso() async {
    final prefs = await SharedPreferences.getInstance();
    final ejerciciosCompletados = prefs.getStringList('colores_completados') ?? [];
    
    setState(() {
      for (var color in colores) {
        color['desbloqueado'] = false;
      }
      
      if (colores.isNotEmpty) {
        colores[0]['desbloqueado'] = true;
      }
      
      if (ejerciciosCompletados.isNotEmpty) {
        for (var nombre in ejerciciosCompletados) {
          int index = colores.indexWhere((c) => c['nombre'] == nombre);
          if (index != -1) {
            colores[index]['desbloqueado'] = true;
            if (index + 1 < colores.length) {
              colores[index + 1]['desbloqueado'] = true;
            }
          }
        }
      }
    });
  }

  Future<void> _marcarComoCompletado(String nombre) async {
    final prefs = await SharedPreferences.getInstance();
    final ejerciciosCompletados = prefs.getStringList('colores_completados') ?? [];
    
    if (!ejerciciosCompletados.contains(nombre)) {
      ejerciciosCompletados.add(nombre);
      await prefs.setStringList('colores_completados', ejerciciosCompletados);
      
      setState(() {
        final currentIndex = colores.indexWhere((c) => c['nombre'] == nombre);
        if (currentIndex + 1 < colores.length) {
          colores[currentIndex + 1]['desbloqueado'] = true;
        }
      });
    }
  }

  void _seleccionarColor(String color) async {
    final int index = colores.indexWhere((c) => c['nombre'] == color);
    Map<String, dynamic> colorSeleccionado = colores[index];
    
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemDetailScreen(
          nombre: colorSeleccionado["nombre"],
          imagen: colorSeleccionado["imagen"],
          categoria: "Colores",
          allItems: colores,
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
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color.fromARGB(255, 255, 250, 245),
              const Color.fromARGB(255, 255, 240, 230),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: () => TtsManager.instance.speak("Selecciona un color para aprender a escribir su nombre"),
                child: Container(
                padding: EdgeInsets.all(15),
                margin: EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.7),
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
                  "Selecciona un color para aprender a escribir su nombre",
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
                    crossAxisCount: MediaQuery.of(context).orientation == Orientation.portrait ? _getPortraitColumns() : _getLandscapeColumns(),
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: colores.length,
                  padding: EdgeInsets.all(5),
                  itemBuilder: (context, index) {
                    return _buildColorItem(colores[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorItem(Map<String, dynamic> color) {
    final bool desbloqueado = color['desbloqueado'];

    return GestureDetector(
      onTap: desbloqueado ? () => _seleccionarColor(color["nombre"]) : null,
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
              color: desbloqueado ? Colors.orange.withOpacity(0.5) : Colors.grey,
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
                          color["imagen"],
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
                        color: Colors.orange.withOpacity(0.7),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(13),
                          bottomRight: Radius.circular(13),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          color["nombre"],
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