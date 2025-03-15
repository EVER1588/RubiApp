import 'package:flutter/material.dart';

class Bloque {
  String silaba;
  Color color;
  bool esValido;

  Bloque({
    required this.silaba,
    this.color = Colors.blue,
    this.esValido = false,
  });
}