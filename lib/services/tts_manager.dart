import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TtsManager {
  // Ajusta manualmente estas 3 líneas para cambiar cada preset.
  static const double slowPresetRate = 0.30;
  static const double normalPresetRate = 0.40;
  static const double fastPresetRate = 0.50;

  TtsManager._internal();
  static final TtsManager instance = TtsManager._internal();

  final FlutterTts _tts = FlutterTts();
  double rate = 0.5;
  double volume = 1.0;
  String language = 'es-MX';

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    rate = prefs.getDouble('ttsSpeed') ?? 0.5;
    volume = prefs.getDouble('ttsVolume') ?? 1.0;
    await _tts.setLanguage(language);
    await _tts.setSpeechRate(rate);
    await _tts.setVolume(volume);
    await _tts.setPitch(1.0);
  }

  Future<void> setSpeechRate(double r) async {
    rate = r;
    await _tts.setSpeechRate(r);
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
    bool isMuted = prefs.getBool('isTtsMuted') ?? false;
    double vol = isMuted ? 0.0 : (prefs.getDouble('ttsVolume') ?? 1.0);

    // Obtenemos el preset guardado desde Configuración.
    double savedSpeed = prefs.getDouble('ttsSpeed') ?? 1.0;

    double presetRate;
    if (savedSpeed <= 0.6) {
      presetRate = slowPresetRate;
    } else if (savedSpeed >= 1.4) {
      presetRate = fastPresetRate;
    } else {
      presetRate = normalPresetRate;
    }

    await _tts.setLanguage("es-MX");
    await _tts.setVolume(vol);
    await _tts.setSpeechRate(presetRate);

    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
  }
}
