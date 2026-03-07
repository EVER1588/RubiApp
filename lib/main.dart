import 'package:flutter/material.dart';
import 'screens/bienvenida_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rubi Aprende a Leer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Builder(
        builder: (context) {
          // Usamos Builder para acceder al contexto y obtener MediaQuery
          final screenWidth = MediaQuery.of(context).size.width;
          final screenHeight = MediaQuery.of(context).size.height;

          return BienvenidaScreen();
        },
      ),
    );
  }
}