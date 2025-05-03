import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart'; // Agregar esta importación
import 'dart:math';
import '../constants/custombar_screen.dart'; // Agregar esta importación

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

  final FlutterTts flutterTts = FlutterTts(); // Agregar esta línea

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
    _dividirEnSilabas();
    silabasColocadas = List.generate(
      silabasOriginales.length,
      (index) => {"silaba": "", "ocupado": false, "id": null},
    );
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
              // Colores según la categoría
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Banner con categoría y nombre
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                margin: EdgeInsets.all(16),
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
                    SizedBox(height: 5),
                    Text(
                      widget.nombre,
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Imagen con función de lectura
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isImageEnlarged = true;
                    decirTexto(widget.nombre);
                  });
                  // Regresar la imagen a su tamaño normal después de la animación
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
                  width: _isImageEnlarged ? 220 : 200,
                  height: _isImageEnlarged ? 220 : 200,
                  margin: EdgeInsets.symmetric(vertical: 20),
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
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
                ),
              ),

              // Área para construcción de palabra
              Container(
                margin: EdgeInsets.all(15),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: categoryColor.withOpacity(0.5)),
                ),
                child: Column(
                  children: [
                    Text(
                      "Construye la palabra",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: categoryColor,
                      ),
                    ),
                    SizedBox(height: 20),
                    // Espacios para colocar sílabas
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        silabasOriginales.length,
                        (index) => _buildTargetBox(index),
                      ),
                    ),
                  ],
                ),
              ),

              // Sílabas disponibles
              Padding(
                padding: EdgeInsets.all(16),
                child: Container(  // Agregar un Container
                  width: double.infinity,
                  height: 250,  // Altura específica
                  padding: EdgeInsets.all(25),  // Padding más grande
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: categoryColor.withOpacity(0.5)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Sílabas disponibles:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: categoryColor,
                        ),
                      ),
                      SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: silabas.map((silaba) => _buildDraggableSilaba(silaba)).toList(),
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
  }

  // Método para texto a voz
  Future<void> decirTexto(String texto) async {
    await flutterTts.setLanguage("es-ES");
    await flutterTts.speak(texto);
  }

  // Método para construir cajas objetivo
  Widget _buildTargetBox(int index) {
    return DragTarget<Map<String, dynamic>>(
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: 75,  // Aumentar de 60 a 75
          height: 75, // Aumentar de 60 a 75
          margin: EdgeInsets.symmetric(horizontal: 8), // Aumentar de 5 a 8
          decoration: BoxDecoration(
            color: silabasColocadas[index]["ocupado"] ? categoryColor.withOpacity(0.3) : Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: categoryColor.withOpacity(0.5)),
          ),
          child: Center(
            child: silabasColocadas[index]["ocupado"]
                ? Text(
                    silabasColocadas[index]["silaba"],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: categoryColor,
                    ),
                  )
                : Icon(Icons.add, color: Colors.grey[400]),
          ),
        );
      },
      onWillAccept: (data) => true,
      onAccept: (data) {
        setState(() {
          silabasColocadas[index] = {
            "silaba": data["silaba"],
            "ocupado": true,
            "id": data["id"],
          };
          _verificarPalabra();
        });
      },
    );
  }

  // Método para construir sílabas arrastrables
  Widget _buildDraggableSilaba(Map<String, dynamic> silaba) {
    return Draggable<Map<String, dynamic>>(
      data: silaba,
      child: GestureDetector(
        onTap: () => decirTexto(silaba["silaba"]),
        child: Container(
          width: 75,  // Aumentar de 60 a 75
          height: 75, // Aumentar de 60 a 75
          decoration: BoxDecoration(
            color: categoryColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              silaba["silaba"],
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      feedback: Material(
        child: Container(
          width: 75,  // Aumentar de 60 a 75
          height: 75, // Aumentar de 60 a 75
          decoration: BoxDecoration(
            color: categoryColor.withOpacity(0.8),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              silaba["silaba"],
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      childWhenDragging: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
      ),
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
    "NARANJA": ["NA", "RAN", "JA"],
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
  
  // Agregar sílabas aleatorias adicionales
  Random random = Random();
  List<String> silabasAdicionales = ["MA", "TA", "SA", "LA", "PA", "NA"];
  silabasAdicionales.shuffle(random);
  
  // Agregar 2 sílabas adicionales
  for (int i = 0; i < 2 && i < silabasAdicionales.length; i++) {
    if (!silabasTemp.contains(silabasAdicionales[i])) {
      silabasTemp.add(silabasAdicionales[i]);
    }
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
}