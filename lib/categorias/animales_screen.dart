import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'item_detail_screen.dart';
import '../constants/custombar_screen.dart'; // Agregar esta importación

class AnimalesScreen extends StatefulWidget {
  @override
  _AnimalesScreenState createState() => _AnimalesScreenState();
}

class _AnimalesScreenState extends State<AnimalesScreen> {
  List<Map<String, dynamic>> animales = [
    {"nombre": "Gato", "imagen": "lib/utils/images/animales/gato.jpeg"},
    {"nombre": "Vaca", "imagen": "lib/utils/images/animales/vaca.jpeg"},
    {"nombre": "Mono", "imagen": "lib/utils/images/animales/mono.jpeg"},
    {"nombre": "Rana", "imagen": "lib/utils/images/animales/rana.jpeg"},
    {"nombre": "Lobo", "imagen": "lib/utils/images/animales/lobo.jpeg"},
    {"nombre": "Cebra", "imagen": "lib/utils/images/animales/cebra.jpeg"},
    {"nombre": "Perro", "imagen": "lib/utils/images/animales/perro.jpeg"},
    {"nombre": "Panda", "imagen": "lib/utils/images/animales/panda.jpeg"},
    {"nombre": "Tigre", "imagen": "lib/utils/images/animales/tigre.jpeg"},
    {"nombre": "León", "imagen": "lib/utils/images/animales/leon.jpeg"},
    {"nombre": "Ratón", "imagen": "lib/utils/images/animales/raton.jpeg"},
    {"nombre": "Delfín", "imagen": "lib/utils/images/animales/delfin.jpeg"},
    {"nombre": "Pájaro", "imagen": "lib/utils/images/animales/pajaro.jpeg"},
    {"nombre": "Conejo", "imagen": "lib/utils/images/animales/conejo.jpeg"},
    {"nombre": "Caballo", "imagen": "lib/utils/images/animales/caballo.jpeg"},
    {"nombre": "Oveja", "imagen": "lib/utils/images/animales/oveja.jpeg"},
    {"nombre": "Araña", "imagen": "lib/utils/images/animales/arana.jpeg"},
    {"nombre": "Jirafa", "imagen": "lib/utils/images/animales/jirafa.jpeg"},
    {"nombre": "Koala", "imagen": "lib/utils/images/animales/koala.jpeg"},
    {"nombre": "Tortuga", "imagen": "lib/utils/images/animales/tortuga.jpeg"},
    {"nombre": "Ballena", "imagen": "lib/utils/images/animales/ballena.jpeg"},
    {"nombre": "Canguro", "imagen": "lib/utils/images/animales/canguro.jpeg"},
    {"nombre": "Caracol", "imagen": "lib/utils/images/animales/caracol.jpeg"},
    {"nombre": "Gallina", "imagen": "lib/utils/images/animales/gallina.jpeg"},
    {"nombre": "Pingüino", "imagen": "lib/utils/images/animales/pinguino.jpeg"},
    {"nombre": "Mariposa", "imagen": "lib/utils/images/animales/mariposa.jpeg"},
    {"nombre": "Serpiente", "imagen": "lib/utils/images/animales/serpiente.jpeg"},
    {"nombre": "Elefante", "imagen": "lib/utils/images/animales/elefante.jpeg"},
  ];

  @override
  void initState() {
    super.initState();
    _cargarProgreso();
  }

  Future<void> _cargarProgreso() async {
    final prefs = await SharedPreferences.getInstance();
    final ejerciciosCompletados = prefs.getStringList('animales_completados') ?? [];
    
    setState(() {
      // Primero, marcar todos como bloqueados
      for (var animal in animales) {
        animal['desbloqueado'] = false;
      }
      
      // Solo desbloquear el primer animal
      if (animales.isNotEmpty) {
        animales[0]['desbloqueado'] = true;
      }
      
      // Luego desbloquear según el progreso guardado
      if (ejerciciosCompletados.isNotEmpty) {
        for (var nombre in ejerciciosCompletados) {
          int index = animales.indexWhere((a) => a['nombre'] == nombre);
          if (index != -1) {
            animales[index]['desbloqueado'] = true;
            // Desbloquear el siguiente animal
            if (index + 1 < animales.length) {
              animales[index + 1]['desbloqueado'] = true;
            }
          }
        }
      }
    });
  }

  Future<void> _marcarComoCompletado(String nombre) async {
    final prefs = await SharedPreferences.getInstance();
    final ejerciciosCompletados = prefs.getStringList('animales_completados') ?? [];
    
    if (!ejerciciosCompletados.contains(nombre)) {
      ejerciciosCompletados.add(nombre);
      await prefs.setStringList('animales_completados', ejerciciosCompletados);
      
      setState(() {
        // Desbloquear el siguiente ejercicio
        final currentIndex = animales.indexWhere((a) => a['nombre'] == nombre);
        if (currentIndex + 1 < animales.length) {
          animales[currentIndex + 1]['desbloqueado'] = true;
        }
      });
    }
  }

  void _seleccionarAnimal(String animal) async {
    Map<String, dynamic>? animalSeleccionado = animales.firstWhere(
      (item) => item["nombre"] == animal,
    );
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemDetailScreen(
          nombre: animalSeleccionado["nombre"],
          imagen: animalSeleccionado["imagen"],
          categoria: "Animales",
        ),
      ),
    );

    if (result != null && result['completado'] == true) {
      await _marcarComoCompletado(animal);
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
              const Color.fromARGB(255, 247, 250, 255),
              const Color.fromARGB(255, 215, 235, 255),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              // Banner con instrucciones
              Container(
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
                  "Selecciona un animal para aprender a escribir su nombre",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              
              // Grid con los animales
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: animales.length,
                  padding: EdgeInsets.all(5),
                  itemBuilder: (context, index) {
                    return _buildAnimalItem(animales[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimalItem(Map<String, dynamic> animal) {
    final bool desbloqueado = animal['desbloqueado'];

    return GestureDetector(
      onTap: desbloqueado ? () => _seleccionarAnimal(animal["nombre"]) : null,
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
              color: desbloqueado ? Colors.blue.withOpacity(0.5) : Colors.grey,
              width: 2,
            ),
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  // Imagen del animal
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
                          animal["imagen"],
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
                  // Nombre del animal
                  Expanded(
                    flex: 2,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.7),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(13),
                          bottomRight: Radius.circular(13),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          animal["nombre"],
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