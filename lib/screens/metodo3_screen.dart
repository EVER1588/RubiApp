import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';

class Metodo3Screen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Describe la Imagen'),
      body: Center(
        child: Text('Pantalla del Método 3'),
      ),
    );
  }
}