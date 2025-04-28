import 'package:flutter/material.dart';
import '../constants/custombar_screen.dart';
import '../categorias/animales_screen.dart';

class Metodo3Screen extends StatefulWidget {
  @override
  _Metodo3ScreenState createState() => _Metodo3ScreenState();
}

class _Metodo3ScreenState extends State<Metodo3Screen> {
  // Lista de categorías de imágenes con sus nombres y rutas corregidas
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
    {"nombre": "Estaciones", "imagen": "lib/utils/images/estaciones.jpeg"},
    {"nombre": "incectos", "imagen": "lib/utils/images/incectos.jpeg"},
  ];

  void _navegarACategoria(String categoria) {
    print("Seleccionaste la categoría: $categoria");
    
    // Navegar a la pantalla correspondiente según la categoría seleccionada
    if (categoria == "Animales") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AnimalesScreen()),
      );
    }
    // Puedes añadir más casos para otras categorías a medida que las vayas implementando
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
          IconButton(
            icon: Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          // Fondo con gradiente para un aspecto más atractivo
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
              // Instrucciones para el usuario
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
                  "Selecciona una categoría y aprendamos a escribir palabras con imágenes",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              
              // Grid con las categorías
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // Cambiado de 4 a 3 columnas
                    crossAxisSpacing: 15, // Aumentado de 10 a 15 para dar más espacio entre columnas
                    mainAxisSpacing: 15, // Aumentado para consistencia
                    childAspectRatio: 0.85, // Ajustado para mejor visualización con 3 columnas
                  ),
                  itemCount: categorias.length,
                  padding: EdgeInsets.all(5),
                  itemBuilder: (context, index) {
                    return _buildCategoriaItem(categorias[index]);
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
            // Imagen de la categoría - ahora con ClipRRect para que se ajuste al contenedor con bordes redondeados
            Expanded(
              flex: 6,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(13),
                  topRight: Radius.circular(13),
                ),
                child: Container(
                  width: double.infinity,
                  height: double.infinity, // Asegurar que use toda la altura
                  child: Image.asset(
                    categoria["imagen"],
                    fit: BoxFit.fill, // Cambiado a fill para que rellene todo el espacio
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
            // Nombre de la categoría
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
                    categoria["nombre"],
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