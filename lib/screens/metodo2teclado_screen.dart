import 'package:flutter/material.dart';

class Metodo2Teclado extends StatelessWidget {
  final Function(String) onSyllableSelected;

  const Metodo2Teclado({Key? key, required this.onSyllableSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, // 4 columnas
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: letras.length,
      itemBuilder: (context, index) {
        final letra = letras[index];
        return ElevatedButton(
          onPressed: () {
            // Simula la selección de una letra
            final silabas = obtenerSilabasPorLetra(letra);
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Silabas para $letra'),
                  content: Wrap(
                    children: silabas.map((silaba) {
                      return ElevatedButton(
                        onPressed: () {
                          onSyllableSelected(silaba);
                          Navigator.pop(context); // Cierra el diálogo
                        },
                        child: Text(silaba),
                      );
                    }).toList(),
                  ),
                );
              },
            );
          },
          child: Text(letra),
        );
      },
    );
  }

  List<String> obtenerSilabasPorLetra(String letra) {
    // Ejemplo de mapeo de letras a sílabas
    Map<String, List<String>> silabasPorLetra = {
      'A': ['A', 'AL', 'AM'],
      'B': ['BA', 'BE', 'BI'],
      'C': ['CA', 'CE', 'CI'],
    };
    return silabasPorLetra[letra] ?? [];
  }
}

const List<String> letras = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M'];