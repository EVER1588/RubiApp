import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'bloque_model.dart'; // Modelo de Bloque
import 'constants.dart'; // Constantes como palabras válidas
import 'metodo2teclado_screen.dart'; // Teclado personalizado

class Metodo2Screen extends StatefulWidget {
  const Metodo2Screen({Key? key}) : super(key: key);

  @override
  _Metodo2ScreenState createState() => _Metodo2ScreenState();
}

class _Metodo2ScreenState extends State<Metodo2Screen> {
  final FlutterTts flutterTts = FlutterTts();
  List<Bloque> contenedor2Bloques = []; // Bloques en el Contenedor 2
  List<Bloque> contenedor1Bloques = []; // Bloques en el Contenedor 1 (oración)

  Future<void> reproducirSilaba(String silaba) async {
    await flutterTts.setLanguage("es-ES");
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(silaba);
  }

  Future<void> reproducirOracion() async {
    String textoCompleto = contenedor1Bloques.map((bloque) => bloque.silaba).join(" ");
    if (textoCompleto.isNotEmpty) {
      await flutterTts.setLanguage("es-ES");
      await flutterTts.setPitch(1.0);
      await flutterTts.speak(textoCompleto);
    }
  }

  bool esPalabraValida(String palabra) {
    return palabrasValidas.contains(palabra);
  }

  void fusionarBloques(Bloque bloque1, Bloque bloque2) {
    String nuevaSilaba = bloque1.silaba + bloque2.silaba;
    if (esPalabraValida(nuevaSilaba)) {
      setState(() {
        contenedor2Bloques.remove(bloque1);
        contenedor2Bloques.remove(bloque2);
        contenedor2Bloques.add(Bloque(silaba: nuevaSilaba, color: Colors.green, esValido: true));
      });
    } else {
      setState(() {
        contenedor2Bloques.add(Bloque(silaba: nuevaSilaba, color: Colors.blue, esValido: false));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: Text('Método 2')),
      body: Column(
        children: [
          // Contenedor 1 (Azul)
          Expanded(
            flex: 1,
            child: Stack(
              children: [
                Container(
                  color: Colors.blue.withOpacity(0.3),
                  child: Center(
                    child: Text(
                      'Oración: ${contenedor1Bloques.map((bloque) => bloque.silaba).join(" ")}',
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: ElevatedButton.icon(
                    onPressed: reproducirOracion,
                    icon: Icon(Icons.play_arrow, color: Colors.white),
                    label: Text('Reproducir', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Contenedor 2 (Verde)
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.green.withOpacity(0.3),
              child: Stack(
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: contenedor2Bloques.map((bloque) => _buildBloque(bloque)).toList(),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: DragTarget<Bloque>(
                      builder: (context, incoming, rejected) {
                        return Container(
                          width: 50,
                          height: 50,
                          color: Colors.red,
                          child: Icon(Icons.delete, color: Colors.white),
                        );
                      },
                      onAccept: (bloque) {
                        setState(() {
                          contenedor2Bloques.remove(bloque);
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Teclado Principal
          Expanded(
            flex: 1,
            child: Metodo2Teclado(
              onSyllableSelected: (silaba) {
                setState(() {
                  contenedor2Bloques.add(Bloque(silaba: silaba, color: Colors.blue));
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBloque(Bloque bloque) {
    return LongPressDraggable<Bloque>(
      data: bloque,
      delay: Duration(milliseconds: 100), // Retraso de 0.1 segundos
      feedback: Material(
        child: Container(
          width: 80,
          height: 40,
          color: bloque.color,
          child: Center(
            child: Text(
              bloque.silaba,
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: Container(
          width: 80,
          height: 40,
          color: bloque.color,
          child: Center(
            child: Text(
              bloque.silaba,
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
      ),
      child: GestureDetector(
        onTap: () {
          reproducirSilaba(bloque.silaba);
        },
        child: Container(
          width: 80,
          height: 40,
          color: bloque.color,
          child: Center(
            child: Text(
              bloque.silaba,
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}