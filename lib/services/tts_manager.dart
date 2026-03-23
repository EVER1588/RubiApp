import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TtsManager {
  // Ajusta manualmente estas 3 líneas para cambiar cada preset.
  static const double slowPresetRate = 0.40;
  static const double normalPresetRate = 0.50;
  static const double fastPresetRate = 0.55;

  TtsManager._internal();
  static final TtsManager instance = TtsManager._internal();

  factory TtsManager() => instance;

  final FlutterTts _tts = FlutterTts();
  double rate = 0.5;  
  double volume = 1.0;
  String language = 'es-MX';


  // Pronunciación fonética de letras y sílabas especiales
  static const Map<String, String> _phoneticOverrides = {
    // Letras del alfabeto español
    'A': 'a', 'B': 'bé', 'C': 'ce', 'D': 'de', 'E': 'e',
    'F': 'efe', 'G': 'jé', 'H': 'ache', 'I': 'i', 'J': 'jota',
    'K': 'ka', 'L': 'ele', 'M': 'eme', 'N': 'ene', 'Ñ': 'eñe',
    'O': 'o', 'P': 'pe', 'Q': 'ku', 'R': 'erre', 'S': 'ese',
    'T': 'te', 'U': 'u', 'V': 'uve', 'W': 'doble u', 'X': 'equis',
    'Y': 'ye', 'Z': 'zeta',

    // Sílabas especiales y dígrafos
    'BE': 'bé', 'BLE': 'blé', 'CE': 'cé', 'CU': 'cú', 'CLA': 'clá', 'CLI': 'clí',
    'CLO': 'cló', 'CLU': 'clú', 'FLA': 'flá', 'FRA': 'frá', 'GE': 'gué',
    'GI': 'guí', 'GO': 'gó', 'HI': 'i', 'HO': 'o', 'HU': 'u',
    'JE': 'jé', 'JO': 'jó', 'JU': 'jú', 'KE': 'que', 'TO': 'tó',
    'TRU': 'trú', 'US': 'ús', 'VO': 'vó', 'XA': 'sá', 'XE': 'sé',
    'XI': 'sí', 'XO': 'só', 'XU': 'sú', 'QUE': 'ke', 'QUI': 'ki',
    'GUE': 'ge', 'GUI': 'gi', 'LLA': 'ya', 'LLE': 'ye', 'LLI': 'yi',
    'LLO': 'yo', 'LLU': 'yu', 'RRA': 'rá', 'RRE': 'ré', 'RRI': 'rí',
    'RRO': 'ró', 'RRU': 'rú', 'UL': 'hul', 'CLE': 'clé', 'GLE': 'glé',
    'CRE': 'cré', 'GRE': 'gré', 'WA': 'wá', 'WI': 'wí', 'WEB': 'wéb',
  };




  static String toPhoneticText(String text) {
    if (text.isEmpty) return text;
    final upper = text.toUpperCase();

    // 1. Override exacto (letras individuales, sílabas especiales conocidas)
    if (_phoneticOverrides.containsKey(upper)) return _phoneticOverrides[upper]!;

    // 2. Reglas fonéticas algorítmicas para textos de más de un carácter.
    //    Se aplican en orden de mayor a menor longitud de patrón para evitar
    //    que un reemplazo corto "rompa" un patrón más largo.
    final processed = upper
        // QU + vocal → K + vocal  (U siempre muda en español)
        .replaceAll('QUE', 'KE').replaceAll('QUI', 'KI')
        // GU + E/I → G + E/I  (U muda; no aplica a GUA/GUO donde U sí suena)
        .replaceAll('GUE', 'GE').replaceAll('GUI', 'GI')
        // LL → Y  (solo fuera de coincidencias exactas ya cubiertas)
        .replaceAll('LLA', 'YA').replaceAll('LLE', 'YE').replaceAll('LLI', 'YI')
        .replaceAll('LLO', 'YO').replaceAll('LLU', 'YU').replaceAll('LL', 'Y');

    // Si hubo cambios, devolver en minúsculas (TTS no distingue mayúsculas).
    if (processed != upper) return processed.toLowerCase();

    // 3. Sin cambios: devolver el texto original (preserva formato del original).
    return text;
  }

  /// Pronuncia una sílaba con velocidad lenta para mayor claridad.
  /// Usa [toPhoneticText] internamente para garantizar la pronunciación correcta.
  Future<void> speakSyllable(String syllable) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('isTtsMuted') ?? false) return;

    final phoneticText = toPhoneticText(syllable);
    await _tts.setLanguage(prefs.getString('ttsLanguage') ?? language);
    await _tts.setVolume(prefs.getDouble('ttsVolume') ?? 1.0);
    await _tts.setSpeechRate(slowPresetRate);
    await _tts.speak(phoneticText);
  }

  /// Pronuncia el nombre de una letra (p. ej. "B" → "be", "C" → "ce").
  Future<void> speakLetterName(String letter) async {
    // Un solo carácter siempre coincide con el override de nombre de letra.
    await speak(letter.trim());
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    rate = prefs.getDouble('ttsSpeed') ?? 1.0;
    volume = prefs.getDouble('ttsVolume') ?? 1.0;
    language = prefs.getString('ttsLanguage') ?? 'es-MX';
    await _tts.setLanguage(language);
    await _tts.setVolume(volume);
    await _tts.setPitch(1.0);
  }

  Future<void> initialize() async {
    await init();
  }

  Future<void> setSpeechRate(double r) async {
    rate = r;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('ttsSpeed', r);
  }

  Future<void> setVolume(double v) async {
    volume = v;
    await _tts.setVolume(v);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('ttsVolume', v);
  }

  Future<void> setLanguage(String lang) async {
    language = lang;
    await _tts.setLanguage(lang);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ttsLanguage', lang);
  }

  Future<void> speak(String text) async {
    final prefs = await SharedPreferences.getInstance();
    final isMuted = prefs.getBool('isTtsMuted') ?? false;
    if (isMuted) return;

    final phoneticText = toPhoneticText(text);

    final vol = prefs.getDouble('ttsVolume') ?? 1.0;
    final savedSpeed = prefs.getDouble('ttsSpeed') ?? 1.0;

    double presetRate;
    if (savedSpeed <= 0.6) {
      presetRate = slowPresetRate;
    } else if (savedSpeed >= 1.4) {
      presetRate = fastPresetRate;
    } else {
      presetRate = normalPresetRate;
    }

    await _tts.setLanguage(prefs.getString('ttsLanguage') ?? language);
    await _tts.setVolume(vol);
    await _tts.setSpeechRate(presetRate);
    await _tts.speak(phoneticText);
  }

  Future<void> speakSpecialSyllable(String text) async {
    final prefs = await SharedPreferences.getInstance();
    final isMuted = prefs.getBool('isTtsMuted') ?? false;
    if (isMuted) return;

    final phoneticText = toPhoneticText(text);

    final vol = prefs.getDouble('ttsVolume') ?? 1.0;
    await _tts.setLanguage(prefs.getString('ttsLanguage') ?? language);
    await _tts.setVolume(vol);
    await _tts.setSpeechRate(slowPresetRate);
    await _tts.speak(phoneticText);
  }

  Future<void> stop() async {
    await _tts.stop();
  }
}