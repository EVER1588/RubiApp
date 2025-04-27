import 'package:flutter/material.dart';

class AnimalesScreen extends StatefulWidget {
  @override
  _AnimalesScreenState createState() => _AnimalesScreenState();
}

class _AnimalesScreenState extends State<AnimalesScreen> {
  // Lista de animales con sus nombres e imágenes
  final List<Map<String, dynamic>> animales = [
    {"nombre": "Perro", "imagen": "lib/utils/images/animales/perro.jpeg"},
    {"nombre": "Gato", "imagen": "lib/utils/images/animales/gato.jpeg"},
    {"nombre": "Vaca", "imagen": "lib/utils/images/animales/vaca.jpeg"},
    {"nombre": "Caballo", "imagen": "lib/utils/images/animales/caballo.jpeg"},
    {"nombre": "León", "imagen": "lib/utils/images/animales/leon.jpeg"},
    {"nombre": "Elefante", "imagen": "lib/utils/images/animales/elefante.jpeg"},
    {"nombre": "Jirafa", "imagen": "lib/utils/images/animales/jirafa.jpeg"},
    {"nombre": "Mono", "imagen": "lib/utils/images/animales/mono.jpeg"},
    {"nombre": "Pájaro", "imagen": "lib/utils/images/animales/pajaro.jpeg"},
    {"nombre": "Pez", "imagen": "lib/utils/images/animales/pez.jpeg"},
    {"nombre": "Tortuga", "imagen": "lib/utils/images/animales/tortuga.jpeg"},
    {"nombre": "Conejo", "imagen": "lib/utils/images/animales/conejo.jpeg"},
  ];

  void _seleccionarAnimal(String animal) {
    // Esta función manejará la selección de un animal
    print("Seleccionaste el animal: $animal");
    // Aquí puedes agregar navegación a una pantalla de actividad o mostrar un diálogo
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Animales"),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[700]!, Colors.blue[500]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 22,
            ),
            padding: EdgeInsets.zero,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: Colors.white),
            onPressed: () {
              // Mostrar diálogo de ayuda
            },
          ),
        ],
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
    return GestureDetector(
      onTap: () => _seleccionarAnimal(animal["nombre"]),
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
      ),
    );
  }
}