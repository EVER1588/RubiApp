import 'package:flutter/material.dart';
import '../constants/custombar_screen.dart';

class Metodo3Screen extends StatefulWidget {
  @override
  _Metodo3ScreenState createState() => _Metodo3ScreenState();
}

class _Metodo3ScreenState extends State<Metodo3Screen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomBar(
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: Center(
        child: Text('Pantalla del Método 3'),
      ),
    );
  }
}