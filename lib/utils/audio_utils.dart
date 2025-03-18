import 'package:flutter_tts/flutter_tts.dart';

class AudioUtils {
  static final FlutterTts _flutterTts = FlutterTts();

  static Future<void> reproducirOracion(String oracion) async {
    await _flutterTts.setLanguage("es-ES"); // Configurar idioma
    await _flutterTts.speak(oracion); // Reproducir la oración
  }
}