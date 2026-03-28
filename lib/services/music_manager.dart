import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gestiona la música de fondo con transiciones suaves (fade-out/fade-in)
/// entre pantallas. Patrón singleton igual que TtsManager.
class MusicManager {
  MusicManager._internal();
  static final MusicManager instance = MusicManager._internal();
  factory MusicManager() => instance;

  // ── Rutas de pistas ───────────────────────────────────────────────────────
  static const String trackHome =
      'lib/utils/musica/Happiness In Music - Happy Child.mp3';
  static const String trackSilabas =
      'lib/utils/musica/Lite Saturation - Infinite Love.mp3';
  static const String trackDescribe =
      'lib/utils/musica/Lite Saturation - Echoing Hearts.mp3';
  static const String trackPalabras =
      'lib/utils/musica/Lite Saturation - Motivation Piano.mp3';
  static const String trackHistoria =
      'lib/utils/musica/Happiness In Music - Happy Child.mp3';

  // Volumen maestro global (reducir si está muy fuerte)
  static const double _masterVolume = 0.25; // ajustar entre 0.3-0.8 según sea necesario

  static const MethodChannel _eqChannel =
      MethodChannel('com.example.rubiapp2/equalizer');

  final AudioPlayer _player = AudioPlayer()
    ..audioCache.prefix = ''; // evita que audioplayers anteponga "assets/"
  String? _currentTrack;
  String? _lastTrack;           // para restaurar al volver de segundo plano
  double _targetVolume = 0.5;   // volumen por defecto
  double _screenMultiplier = 1.0; // 1.0 home, 0.75 resto
  double _liveVolume = 0.0;     // volumen activo en el player
  int _opId = 0;                // identificador de operación; cancela fades viejos
  bool _isMuted = false;        // copia en memoria del estado mute (sincronizada con prefs)

  /// Cambia a la pista de la pantalla indicada.
  /// Si ya está sonando esa pista, no hace nada.
  /// – Fade-out de la pista actual: 1 segundo.
  /// – Fade-in de la nueva pista: 1.5 segundos.
  Future<void> playForScreen(String assetPath) async {
    if (_currentTrack == assetPath) return;

    final int myId = ++_opId;

    final prefs = await SharedPreferences.getInstance();
    final isMuted = prefs.getBool('isMusicMuted') ?? false;
    _targetVolume = prefs.getDouble('musicVolume') ?? 0.5;

    final isHome = assetPath == trackHome;
    _screenMultiplier = 1.0; // volumen igual en todas las pantallas

    // Fade-out rápido de la pista actual (100ms)
    if (_currentTrack != null) {
      await _fadeOut(myId, const Duration(milliseconds: 100));
      if (_opId != myId) return; // cancelado por otra llamada
    }

    _currentTrack = assetPath;
    _lastTrack = assetPath;
    _isMuted = isMuted;

    // Reducción de graves en pantallas secundarias
    _applyEq(!isHome);

    // Siempre iniciar la pista (incluso en mute, a volumen 0)
    // así al desactivar mute la música ya está corriendo
    _liveVolume = 0.0;
    await _player.setVolume(0.0);
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.play(AssetSource(assetPath));
    if (_opId != myId) return;

    // Fade-in solo si no está en mute
    if (!isMuted) {
      final playVolume = (_targetVolume * _screenMultiplier) * _masterVolume;
      await _fadeIn(myId, playVolume);
    }
  }

  /// Detiene la música inmediatamente (sin fade).
  /// Llamar cuando la app pasa a segundo plano.
  Future<void> stopAll() async {
    _lastTrack = _currentTrack;
    ++_opId;
    _currentTrack = null;
    _liveVolume = 0.0;
    await _player.setVolume(0.0);
    await _player.stop();
    _applyEq(false);
  }

  /// Reanuda la música que sonaba antes de stopAll().
  Future<void> resumeAll() async {
    if (_lastTrack != null) {
      await playForScreen(_lastTrack!);
    }
  }

  // ── Control desde el diálogo de ajustes ────────────────────────────────────

  /// Actualiza el volumen en tiempo real (desde el slider de ajustes).
  Future<void> setVolume(double volume) async {
    _targetVolume = volume;
    if (!_isMuted) {
      _liveVolume = (volume * _screenMultiplier) * _masterVolume;
      await _player.setVolume(_liveVolume);
    }
  }

  /// Activa/desactiva el silencio en tiempo real (desde el botón de ajustes).
  Future<void> setMuted(bool muted) async {
    _isMuted = muted;
    if (muted) {
      _liveVolume = 0.0;
      await _player.setVolume(0.0);
    } else {
      // Si el player se detuvo (p.ej. app relanzada en mute), reiniciar la pista
      if (_currentTrack != null && _player.state != PlayerState.playing) {
        await _player.setVolume(0.0);
        await _player.setReleaseMode(ReleaseMode.loop);
        await _player.play(AssetSource(_currentTrack!));
      }
      _liveVolume = (_targetVolume * _screenMultiplier) * _masterVolume;
      await _player.setVolume(_liveVolume);
    }
  }

  /// Pausa la música sin afectar el estado (para cambios de volumen en tiempo real sin fade).
  /// Llamar cuando el usuario ajusta el volumen desde settings sin cambiar de pantalla.
  Future<void> pause() async {
    await _player.pause();
  }

  /// Reanuda la música que estaba en pausa.
  Future<void> resume() async {
    await _player.resume();
  }

  // ── EQ ─────────────────────────────────────────────────────────────────────

  void _applyEq(bool enable) {
    _eqChannel
        .invokeMethod(enable ? 'enableBassReduction' : 'disableBassReduction')
        .catchError((_) {}); // silencioso si el dispositivo no soporta EQ
  }

  // ── Fades internos ─────────────────────────────────────────────────────────

  Future<void> _fadeOut(int opId, Duration duration) async {
    const steps = 20;
    final stepMs = duration.inMilliseconds ~/ steps;
    final startVol = _liveVolume;
    for (int i = 1; i <= steps; i++) {
      if (_opId != opId) return;
      _liveVolume = (startVol * (1.0 - i / steps)).clamp(0.0, 1.0);
      await _player.setVolume(_liveVolume);
      await Future.delayed(Duration(milliseconds: stepMs));
    }
    if (_opId != opId) return;
    _liveVolume = 0.0;
    await _player.setVolume(0.0);
    await _player.stop();
  }

  Future<void> _fadeIn(int opId, double target) async {
    const steps = 10;
    const duration = Duration(milliseconds: 250);
    final stepMs = duration.inMilliseconds ~/ steps;
    for (int i = 1; i <= steps; i++) {
      if (_opId != opId) return;
      _liveVolume = (target * i / steps).clamp(0.0, target);
      await _player.setVolume(_liveVolume);
      await Future.delayed(Duration(milliseconds: stepMs));
    }
    if (_opId != opId) return;
    _liveVolume = target;
    await _player.setVolume(target);
  }

  void dispose() {
    _player.dispose();
  }
}
