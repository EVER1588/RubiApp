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
  final palabraFormada = bloque1 + bloque2;

  // Verifica si la palabra completa está en 'palabrasValidas'
  if (palabrasValidas.contains(palabraFormada.toUpperCase())) {
    return {
      'cadena': palabraFormada,
      'color': BlockColor.green,
    };
  }

  // Verifica si coincide con 'silabasPorLetra'
  if (_esSilabaDeLista(palabraFormada)) {
    return {
      'cadena': palabraFormada,
      'color': BlockColor.blue,
    };
  }

  // Verifica si coincide con 'IniciosDePalabras'
  if (IniciosDePalabras.contains(palabraFormada.toUpperCase())) {
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

/// Función para verificar si una palabra está en 'silabasPorLetra'
bool _esSilabaDeLista(String palabra) {
  for (var lista in silabasPorLetra.values) {
    if (lista.contains(palabra)) {
      return true;
    }
  }
  return false;
}