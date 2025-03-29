// filepath: c:\Users\Ever Solis\RubiApp2\rubiapp2\lib\constants\concatenacion_screen.dart

import 'constants.dart';

enum BlockColor {
  blue,   // Estado inicial
  green,  // Palabra completa
  orange, // Inicio de palabra de 3 o 4 sílabas
  red,    // Combinación inválida
}

/// Retorna la nueva cadena concatenada y el color correspondiente
Map<String, dynamic> concatenarBloques(String bloque1, String bloque2) {
  final palabraFormada = bloque1 + bloque2;

  // Verifica si la palabra completa está en 'palabrasValidas'
  if (palabrasValidas.contains(palabraFormada.toUpperCase())) {
    return {
      'cadena': palabraFormada,
      'color': BlockColor.green,
    };
  }

  // Verifica si coincide con inicios de 3 sílabas
  if (iniciosDePalabras3Silabas.contains(palabraFormada.toUpperCase())) {
    return {
      'cadena': palabraFormada,
      'color': BlockColor.orange,
    };
  }

  // Verifica si coincide con inicios de 4 sílabas
  if (iniciosDePalabras4Silabas.contains(palabraFormada.toUpperCase())) {
    return {
      'cadena': palabraFormada,
      'color': BlockColor.orange,
    };
  }

  // Si no coincide, marca el bloque en rojo
  return {
    'cadena': palabraFormada,
    'color': BlockColor.red,
  };
}