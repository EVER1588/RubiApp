import 'package:flutter/material.dart';
import '../constants/custombar_screen.dart'; // Importa el nuevo CustomBar

class Metodo3Screen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomBar(
        
        onBackPressed: () {
          Navigator.pop(context); // Acción al presionar el botón de retroceso
        },
      ),
      body: Center(
        child: Text('Pantalla del Método 3'),
      ),
    );
  }
}