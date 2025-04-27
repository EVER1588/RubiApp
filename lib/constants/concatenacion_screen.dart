// filepath: c:\Users\Ever Solis\RubiApp2\rubiapp2\lib\constants\concatenacion_screen.dart

import 'constants.dart';

enum BlockColor {
  blue,   // Estado inicial
  green,  // Palabra completa
  orange, // Inicio de palabra
  red,    // Combinación inválida
}

/// Retorna la nueva cadena concatenada y el color correspondiente
Map<String, dynamic> concatenarBloques(String bloque1, String bloque2) {
  String nuevaCadena = bloque1 + bloque2;
  BlockColor nuevoColor;
  
  // Verificar si la nueva cadena es una palabra válida
  if (palabrasValidas.contains(nuevaCadena.trim().toUpperCase())) {
    nuevoColor = BlockColor.green;
  } 
  // Verificar si la nueva cadena es inicio de una palabra
  else if (IniciosDePalabras.contains(nuevaCadena.trim().toUpperCase())) {
    nuevoColor = BlockColor.orange;
  } 
  // CAMBIO: Ya no usar rojo para combinaciones inválidas, siempre mantenerlas azules
  else {
    nuevoColor = BlockColor.blue; // Antes era BlockColor.red
  }
  
  return {
    'cadena': nuevaCadena,
    'color': nuevoColor,
  };
}