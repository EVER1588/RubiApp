import 'package:flutter_tts/flutter_tts.dart';
import 'dart:io';

class TtsManager {
  static final TtsManager _instance = TtsManager._internal();
  late FlutterTts _flutterTts;
  bool _isInitialized = false;

  // Configuraciones constantes
  static const String defaultLanguage = "es-ES";
  static const double defaultSpeechRate = 0.5;
  static const double syllableSpeechRate = 0.3;
  static const double defaultPitch = 1.0;
  static const double syllablePitch = 1.2;
  static const int speakDelay = 300;

  // Singleton pattern
  factory TtsManager() => _instance;
  TtsManager._internal();

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _flutterTts = FlutterTts();
    
    try {
      // Configuración base optimizada
      await _flutterTts.setLanguage(defaultLanguage);
      await _flutterTts.setPitch(defaultPitch);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setQueueMode(1);
      
      if (Platform.isAndroid) {
        await _flutterTts.setEngine("com.google.android.tts");
        final voices = await _flutterTts.getVoices;
        if (voices != null) {
          for (dynamic voice in voices) {
            if (voice is Map && voice['locale'].toString().contains('es')) {
              await _flutterTts.setVoice(voice.cast<String, String>());
              break;
            }
          }
        }
      }

      _isInitialized = true;
    } catch (e) {
      print('Error inicializando TTS: $e');
      // Asegurar que la app no se bloquee si hay error en TTS
      _isInitialized = true;
    }
  }

  Future<void> speak(String text, {bool isSyllable = false}) async {
    if (!_isInitialized) await initialize();
    
    await stop();

    if (isSyllable) {
      await _flutterTts.setSpeechRate(syllableSpeechRate);
      await _flutterTts.setPitch(syllablePitch);
      
      if (text.length > 2) {
        text = text.split('').join(' ');
      }
    } else {
      await _flutterTts.setSpeechRate(defaultSpeechRate);
      await _flutterTts.setPitch(defaultPitch);
    }

    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    if (!_isInitialized) return;
    await _flutterTts.stop();
  }

  // Método específico para sílabas especiales
  Future<void> speakSpecialSyllable(String syllable) async {
    if (!_isInitialized) await initialize();
    
    await stop();
    await _flutterTts.setSpeechRate(syllableSpeechRate); // Reducir velocidad para mejor pronunciación
    
    // Mapa de pronunciaciones especiales
    final Map<String, String> pronunciacionesSilabas = {
      // Sílabas con G
      "GUE": "gue", "GUI": "gui", "GA": "ga", "GO": "go", "GU": "gu",
      // Sílabas con Q
      "QUE": "ke", "QUI": "ki",
      // Sílabas con Ñ
      "ÑA": "ña", "ÑE": "ñe", "ÑI": "ñi", "ÑO": "ño", "ÑU": "ñu",
      // Sílabas con LL
      "LLA": "lla", "LLE": "lle", "LLI": "lli", "LLO": "llo", "LLU": "llu",
      // Sílabas con RR
      "RRA": "rra", "RRE": "rre", "RRI": "rri", "RRO": "rro", "RRU": "rru",
      // Sílabas con H
      "HUE": "ue", "HUI": "ui", "HA": "a", "HE": "e", "HI": "i", "HO": "o", "HU": "u",
      // Vocales acentuadas
      "Á": "á", "É": "é", "Í": "í", "Ó": "ó", "Ú": "ú",
    };

    // Buscar pronunciación especial o usar la sílaba original
    String pronunciacion = pronunciacionesSilabas[syllable.toUpperCase()] ?? syllable;

    // Configuración específica para mejorar pronunciación
    if (syllable.length > 2) {
      await _flutterTts.setPitch(syllablePitch); // Aumentar tono para sílabas largas
      await _flutterTts.setVolume(1.0);
      pronunciacion = pronunciacion.split('').join(' '); // Separar letras
    } else {
      await _flutterTts.setPitch(defaultPitch);
      await _flutterTts.setVolume(0.9);
    }

    await _flutterTts.speak(pronunciacion);
    await Future.delayed(Duration(milliseconds: speakDelay)); // Pequeña pausa después
    
    // Restaurar configuración
    await _flutterTts.setSpeechRate(defaultSpeechRate);
    await _flutterTts.setPitch(defaultPitch);
  }
}