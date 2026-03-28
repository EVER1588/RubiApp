/// Datos estáticos de cada letra para el modo historia.
/// Contiene las palabras, sílabas e imágenes asociadas a cada letra.
class LetraData {
  final String letra;
  final String nombreLetra; // "A", "Be", "Ce"...
  final String sonido; // fonema: "a", "b", "c"...
  final List<PalabraData> palabras;
  final String icono; // emoji o asset para el nodo del mapa
  final String bioma; // bosque, playa, montaña, desierto, castillo

  const LetraData({
    required this.letra,
    required this.nombreLetra,
    required this.sonido,
    required this.palabras,
    required this.icono,
    required this.bioma,
  });
}

class PalabraData {
  final String palabra;
  final List<String> silabas;
  final String? imagenAsset; // null = placeholder

  const PalabraData({
    required this.palabra,
    required this.silabas,
    this.imagenAsset,
  });
}

/// Diccionario maestro de datos por letra.
/// Por ahora solo la A está completa; el resto se irá llenando.
class LetrasDiccionario {
  static const Map<String, LetraData> datos = {
    'A': LetraData(
      letra: 'A',
      nombreLetra: 'A',
      sonido: 'a',
      icono: '🐝',
      bioma: 'bosque',
      palabras: [
        PalabraData(palabra: 'ABEJA', silabas: ['A', 'BE', 'JA']),
        PalabraData(palabra: 'AGUA', silabas: ['A', 'GUA']),
        PalabraData(palabra: 'ARCO', silabas: ['AR', 'CO']),
        PalabraData(palabra: 'AIRE', silabas: ['AI', 'RE']),
        PalabraData(palabra: 'ARAÑA', silabas: ['A', 'RA', 'ÑA']),
        PalabraData(palabra: 'ANILLO', silabas: ['A', 'NI', 'LLO']),
        PalabraData(palabra: 'ALA', silabas: ['A', 'LA']),
        PalabraData(palabra: 'AMO', silabas: ['A', 'MO']),
      ],
    ),
    // ── Letras futuras (datos mínimos para el mapa) ──
    'B': LetraData(letra: 'B', nombreLetra: 'Be', sonido: 'b', icono: '🐋', bioma: 'bosque', palabras: []),
    'C': LetraData(letra: 'C', nombreLetra: 'Ce', sonido: 'c', icono: '🏠', bioma: 'bosque', palabras: []),
    'D': LetraData(letra: 'D', nombreLetra: 'De', sonido: 'd', icono: '🐬', bioma: 'bosque', palabras: []),
    'E': LetraData(letra: 'E', nombreLetra: 'E', sonido: 'e', icono: '⭐', bioma: 'bosque', palabras: []),
    'F': LetraData(letra: 'F', nombreLetra: 'Efe', sonido: 'f', icono: '🌸', bioma: 'playa', palabras: []),
    'G': LetraData(letra: 'G', nombreLetra: 'Ge', sonido: 'g', icono: '🐱', bioma: 'playa', palabras: []),
    'H': LetraData(letra: 'H', nombreLetra: 'Hache', sonido: 'h', icono: '🍦', bioma: 'playa', palabras: []),
    'I': LetraData(letra: 'I', nombreLetra: 'I', sonido: 'i', icono: '🏝️', bioma: 'playa', palabras: []),
    'J': LetraData(letra: 'J', nombreLetra: 'Jota', sonido: 'j', icono: '🦒', bioma: 'playa', palabras: []),
    'K': LetraData(letra: 'K', nombreLetra: 'Ka', sonido: 'k', icono: '🐨', bioma: 'montaña', palabras: []),
    'L': LetraData(letra: 'L', nombreLetra: 'Ele', sonido: 'l', icono: '🦁', bioma: 'montaña', palabras: []),
    'M': LetraData(letra: 'M', nombreLetra: 'Eme', sonido: 'm', icono: '🦋', bioma: 'montaña', palabras: []),
    'N': LetraData(letra: 'N', nombreLetra: 'Ene', sonido: 'n', icono: '☁️', bioma: 'montaña', palabras: []),
    'Ñ': LetraData(letra: 'Ñ', nombreLetra: 'Eñe', sonido: 'ñ', icono: '🎵', bioma: 'montaña', palabras: []),
    'O': LetraData(letra: 'O', nombreLetra: 'O', sonido: 'o', icono: '🐻', bioma: 'montaña', palabras: []),
    'P': LetraData(letra: 'P', nombreLetra: 'Pe', sonido: 'p', icono: '🐧', bioma: 'desierto', palabras: []),
    'Q': LetraData(letra: 'Q', nombreLetra: 'Cu', sonido: 'k', icono: '🧀', bioma: 'desierto', palabras: []),
    'R': LetraData(letra: 'R', nombreLetra: 'Erre', sonido: 'r', icono: '🐸', bioma: 'desierto', palabras: []),
    'S': LetraData(letra: 'S', nombreLetra: 'Ese', sonido: 's', icono: '🐍', bioma: 'desierto', palabras: []),
    'T': LetraData(letra: 'T', nombreLetra: 'Te', sonido: 't', icono: '🐢', bioma: 'desierto', palabras: []),
    'U': LetraData(letra: 'U', nombreLetra: 'U', sonido: 'u', icono: '🦄', bioma: 'castillo', palabras: []),
    'V': LetraData(letra: 'V', nombreLetra: 'Uve', sonido: 'b', icono: '🐄', bioma: 'castillo', palabras: []),
    'W': LetraData(letra: 'W', nombreLetra: 'Doble uve', sonido: 'w', icono: '🐺', bioma: 'castillo', palabras: []),
    'X': LetraData(letra: 'X', nombreLetra: 'Equis', sonido: 'ks', icono: '🎸', bioma: 'castillo', palabras: []),
    'Y': LetraData(letra: 'Y', nombreLetra: 'Ye', sonido: 'y', icono: '🛥️', bioma: 'castillo', palabras: []),
    'Z': LetraData(letra: 'Z', nombreLetra: 'Zeta', sonido: 's', icono: '🦊', bioma: 'castillo', palabras: []),
  };

  /// Obtener los datos de una letra.
  static LetraData obtener(String letra) {
    return datos[letra] ?? datos['A']!;
  }

  /// Sílabas que contienen la letra indicada (para ejercicio 2).
  static List<String> silabasConLetra(String letra) {
    final l = letra.toUpperCase();
    final data = datos[l];
    if (data == null) return [];
    final silabas = <String>{};
    for (final p in data.palabras) {
      for (final s in p.silabas) {
        silabas.add(s);
      }
    }
    return silabas.toList();
  }
}
