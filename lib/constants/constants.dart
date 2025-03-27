import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Bloque {
  final String id;
  final String contenido;
  final Color color;
  final Offset posicion;

  Bloque({
    required this.contenido,
    this.color = Colors.blue,
    required this.posicion,
  }) : id = const Uuid().v4();

  Map<String, String> get dragData => {
    'id': id,
    'contenido': contenido,
  };
}

const List<String> palabrasValidas = [
  'LA', 'QUE', 'EL', 'MESA', 'CAMA', 'PERRO', 'GATO', 'LUNA', 'SOL', 'ZAPATO', 'HUMANO',
];

const List<String> silabasEspeciales = [
  "A", "AL", "DA", "DE", "EL", "EN", "ES", "FE", "HA", "LA",
  "LE", "LAS", "LOS", "LUZ", "ME", "MI", "MAS", "MES", "MIS", "NI",
  "NO", "QUE", "QUI", "SE", "SI", "SU", "TE", "TU", "UN", "VA",
  "VE", "VI", "WEB", "WI", "Y", "YA", "YO",
];

final List<String> iniciosDePalabras3Silabas = [
  'MES', 'CAM', 'PER', 'GAT', 'LUN',
];

final List<String> iniciosDePalabras4Silabas = [
  'HUMA', 'ZAPA',
];

const double blockWidth = 60.0;
const double blockHeight = 40.0;
const double blockSpacing = 8.0;