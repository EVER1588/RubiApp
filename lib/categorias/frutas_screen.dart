import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'item_detail_screen.dart';
import '../constants/custombar_screen.dart';

class FrutasScreen extends StatefulWidget {
  @override
  _FrutasScreenState createState() => _FrutasScreenState();
}

class _FrutasScreenState extends State<FrutasScreen> {
  List<Map<String, dynamic>> frutas = [
    {"nombre": "Mango", "imagen": "lib/utils/images/frutas/mango.jpeg"},
    {"nombre": "Pera", "imagen": "lib/utils/images/frutas/pera.jpeg"},
    {"nombre": "Uvas", "imagen": "lib/utils/images/frutas/uvas.jpeg"},
    {"nombre": "Piña", "imagen": "lib/utils/images/frutas/pina.jpeg"},
    {"nombre": "Limón", "imagen": "lib/utils/images/frutas/limon.jpeg"},
    {"nombre": "Naranja", "imagen": "lib/utils/images/frutas/naranja.jpeg"},
    {"nombre": "Fresa", "imagen": "lib/utils/images/frutas/fresa.jpeg"},
    {"nombre": "Plátano", "imagen": "lib/utils/images/frutas/platano.jpeg"},
    {"nombre": "Sandía", "imagen": "lib/utils/images/frutas/sandia.jpeg"},
    {"nombre": "Manzana", "imagen": "lib/utils/images/frutas/manzana.jpeg"},
    {"nombre": "Melón", "imagen": "lib/utils/images/frutas/melon.jpeg"},
    {"nombre": "Papaya", "imagen": "lib/utils/images/frutas/papaya.jpeg"},
    {"nombre": "Durazno", "imagen": "lib/utils/images/frutas/durazno.jpeg"},
    {"nombre": "Ciruela", "imagen": "lib/utils/images/frutas/ciruela.jpeg"},
    {"nombre": "Guayaba", "imagen": "lib/utils/images/frutas/guayaba.jpeg"},
    {"nombre": "Cereza", "imagen": "lib/utils/images/frutas/cereza.jpeg"},
    {"nombre": "Granada", "imagen": "lib/utils/images/frutas/granada.jpeg"},
    {"nombre": "Kiwi", "imagen": "lib/utils/images/frutas/kiwi.jpeg"},
  ];

  @override
  void initState() {
    super.initState();
    _cargarProgreso();
  }

  Future<void> _cargarProgreso() async {
    final prefs = await SharedPreferences.getInstance();
    final ejerciciosCompletados = prefs.getStringList('frutas_completados') ?? [];
    
    setState(() {
      // Primero, marcar todos como bloqueados
      for (var fruta in frutas) {
        fruta['desbloqueado'] = false;
      }
      
      // Solo desbloquear la primera fruta
      if (frutas.isNotEmpty) {
        frutas[0]['desbloqueado'] = true;
      }
      
      // Luego desbloquear según el progreso guardado
      if (ejerciciosCompletados.isNotEmpty) {
        for (var nombre in ejerciciosCompletados) {
          int index = frutas.indexWhere((f) => f['nombre'] == nombre);
          if (index != -1) {
            frutas[index]['desbloqueado'] = true;
            // Desbloquear la siguiente fruta
            if (index + 1 < frutas.length) {
              frutas[index + 1]['desbloqueado'] = true;
            }
          }
        }
      }
    });
  }

  Future<void> _marcarComoCompletado(String nombre) async {
    final prefs = await SharedPreferences.getInstance();
    final ejerciciosCompletados = prefs.getStringList('frutas_completados') ?? [];
    
    if (!ejerciciosCompletados.contains(nombre)) {
      ejerciciosCompletados.add(nombre);
      await prefs.setStringList('frutas_completados', ejerciciosCompletados);
      
      setState(() {
        final currentIndex = frutas.indexWhere((f) => f['nombre'] == nombre);
        if (currentIndex + 1 < frutas.length) {
          frutas[currentIndex + 1]['desbloqueado'] = true;
        }
      });
    }
  }

  void _seleccionarFruta(String fruta) async {
    Map<String, dynamic>? frutaSeleccionada = frutas.firstWhere(
      (item) => item["nombre"] == fruta,
    );
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemDetailScreen(
          nombre: frutaSeleccionada["nombre"],
          imagen: frutaSeleccionada["imagen"],
          categoria: "Frutas",
        ),
      ),
    );

    if (result != null && result['completado'] == true) {
      await _marcarComoCompletado(fruta);
    }
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
              const Color.fromARGB(255, 255, 245, 245),
              const Color.fromARGB(255, 255, 230, 230),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(15),
                margin: EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.7),
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
                  "Selecciona una fruta para aprender a escribir su nombre",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: frutas.length,
                  padding: EdgeInsets.all(5),
                  itemBuilder: (context, index) {
                    return _buildFrutaItem(frutas[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFrutaItem(Map<String, dynamic> fruta) {
    final bool desbloqueado = fruta['desbloqueado'];

    return GestureDetector(
      onTap: desbloqueado ? () => _seleccionarFruta(fruta["nombre"]) : null,
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
              color: desbloqueado ? Colors.red.withOpacity(0.5) : Colors.grey,
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
                          fruta["imagen"],
                          fit: BoxFit.fill,
                          errorBuilder: (context, error, stackTrace) {
                            print("Error cargando imagen: $error");
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
                        color: Colors.red.withOpacity(0.7),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(13),
                          bottomRight: Radius.circular(13),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          fruta["nombre"],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
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