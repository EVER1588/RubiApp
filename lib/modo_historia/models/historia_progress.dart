import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Gestiona el progreso del modo historia.
/// Almacena qué letras están completadas, estrellas, y ejercicios individuales.
class HistoriaProgress {
  HistoriaProgress._internal();
  static final HistoriaProgress instance = HistoriaProgress._internal();

  static const String _keyProgreso = 'historia_progreso';
  static const String _keyLetraActual = 'historia_letra_actual';
  static const String _keyMonedas = 'historia_monedas';

  /// Orden de las letras en el camino.
  static const List<String> letrasOrden = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J',
    'K', 'L', 'M', 'N', 'Ñ', 'O', 'P', 'Q', 'R', 'S',
    'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
  ];

  /// Total de ejercicios por letra.
  static const int ejerciciosPorLetra = 5;

  /// Monedas por ejercicio (1-5).
  static const Map<int, int> monedasPorEjercicio = {
    1: 2, 2: 4, 3: 8, 4: 16, 5: 32,
  };

  /// Bonus al completar todos los ejercicios de una letra.
  static const int bonusCompletarLetra = 50;

  // ── Cache en memoria ──────────────────────────────────────────────────────
  Map<String, LetraProgreso> _progreso = {};
  String _letraActual = 'A';
  int _monedas = 0;
  bool _loaded = false;

  // ── Getters ────────────────────────────────────────────────────────────────
  String get letraActual => _letraActual;
  int get monedas => _monedas;
  Map<String, LetraProgreso> get progreso => _progreso;

  int get letrasCompletadas =>
      _progreso.values.where((lp) => lp.completado).length;

  int get totalLetras => letrasOrden.length;

  int get totalEstrellas =>
      _progreso.values.fold(0, (sum, lp) => sum + lp.estrellas);

  // ── Cargar / Guardar ──────────────────────────────────────────────────────

  Future<void> cargar() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _letraActual = prefs.getString(_keyLetraActual) ?? 'A';
    _monedas = prefs.getInt(_keyMonedas) ?? 0;

    final jsonStr = prefs.getString(_keyProgreso);
    if (jsonStr != null) {
      final Map<String, dynamic> map = json.decode(jsonStr);
      _progreso = map.map((k, v) => MapEntry(k, LetraProgreso.fromJson(v)));
    }

    // Asegurar que todas las letras tengan entrada
    for (final letra in letrasOrden) {
      _progreso.putIfAbsent(letra, () => LetraProgreso());
    }
    _loaded = true;
  }

  Future<void> _guardar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLetraActual, _letraActual);
    await prefs.setInt(_keyMonedas, _monedas);
    final map = _progreso.map((k, v) => MapEntry(k, v.toJson()));
    await prefs.setString(_keyProgreso, json.encode(map));
  }

  // ── API pública ────────────────────────────────────────────────────────────

  /// Estado de una letra: bloqueado, activo, o completado.
  LetraEstado estadoLetra(String letra) {
    final idx = letrasOrden.indexOf(letra);
    if (idx < 0) return LetraEstado.bloqueado;

    final lp = _progreso[letra];
    if (lp != null && lp.completado) return LetraEstado.completado;

    if (letra == _letraActual) return LetraEstado.activo;

    // Desbloqueado si la letra anterior está completada
    if (idx == 0) return LetraEstado.activo;
    final anterior = letrasOrden[idx - 1];
    final lpAnt = _progreso[anterior];
    if (lpAnt != null && lpAnt.completado) return LetraEstado.activo;

    return LetraEstado.bloqueado;
  }

  /// Marcar un ejercicio como completado.
  /// Retorna las monedas ganadas (0 si ya estaba completado).
  Future<int> completarEjercicio(String letra, int ejercicio) async {
    await cargar();
    final lp = _progreso[letra] ?? LetraProgreso();
    
    // Si ya estaba completado, no dar monedas
    final yaCompletado = lp.ejerciciosCompletados.contains(ejercicio);
    lp.ejerciciosCompletados.add(ejercicio);
    
    int monedasGanadas = 0;
    
    if (!yaCompletado) {
      monedasGanadas = monedasPorEjercicio[ejercicio] ?? 0;
      _monedas += monedasGanadas;
    }

    // Verificar si completó todos los ejercicios
    if (lp.ejerciciosCompletados.length >= ejerciciosPorLetra) {
      if (!lp.completado) {
        // Primera vez completando la letra: bonus
        lp.completado = true;
        lp.estrellas = _calcularEstrellas(lp);
        _monedas += bonusCompletarLetra;
        monedasGanadas += bonusCompletarLetra;

        // Avanzar a la siguiente letra
        final idx = letrasOrden.indexOf(letra);
        if (idx >= 0 && idx < letrasOrden.length - 1) {
          _letraActual = letrasOrden[idx + 1];
        }
      }
    }

    _progreso[letra] = lp;
    await _guardar();
    return monedasGanadas;
  }

  /// Verificar si un ejercicio específico ya fue completado.
  bool ejercicioCompletado(String letra, int ejercicio) {
    final lp = _progreso[letra];
    if (lp == null) return false;
    return lp.ejerciciosCompletados.contains(ejercicio);
  }

  /// Obtener las estrellas de una letra.
  int estrellasDeLetra(String letra) {
    return _progreso[letra]?.estrellas ?? 0;
  }

  /// Número de ejercicios completados para una letra.
  int ejerciciosCompletadosDeLetra(String letra) {
    return _progreso[letra]?.ejerciciosCompletados.length ?? 0;
  }

  /// Agregar monedas.
  Future<void> agregarMonedas(int cantidad) async {
    _monedas += cantidad;
    await _guardar();
  }

  int _calcularEstrellas(LetraProgreso lp) {
    // Por ahora: 3 estrellas si completa sin fallos, 2 si < 3 fallos, 1 si más
    if (lp.fallos == 0) return 3;
    if (lp.fallos <= 3) return 2;
    return 1;
  }

  /// Registrar un fallo en un ejercicio.
  Future<void> registrarFallo(String letra) async {
    await cargar();
    final lp = _progreso[letra] ?? LetraProgreso();
    lp.fallos++;
    _progreso[letra] = lp;
    await _guardar();
  }

  /// Reiniciar todo el progreso (para debug/testing).
  Future<void> resetear() async {
    _progreso.clear();
    _letraActual = 'A';
    _monedas = 0;
    _loaded = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyProgreso);
    await prefs.remove(_keyLetraActual);
    await prefs.remove(_keyMonedas);
  }
}

// ── Modelos auxiliares ──────────────────────────────────────────────────────

enum LetraEstado { bloqueado, activo, completado }

class LetraProgreso {
  bool completado;
  int estrellas; // 1-3
  Set<int> ejerciciosCompletados;
  int fallos;

  LetraProgreso({
    this.completado = false,
    this.estrellas = 0,
    Set<int>? ejerciciosCompletados,
    this.fallos = 0,
  }) : ejerciciosCompletados = ejerciciosCompletados ?? {};

  Map<String, dynamic> toJson() => {
        'completado': completado,
        'estrellas': estrellas,
        'ejercicios': ejerciciosCompletados.toList(),
        'fallos': fallos,
      };

  factory LetraProgreso.fromJson(Map<String, dynamic> json) => LetraProgreso(
        completado: json['completado'] ?? false,
        estrellas: json['estrellas'] ?? 0,
        ejerciciosCompletados:
            (json['ejercicios'] as List?)?.map((e) => e as int).toSet() ?? {},
        fallos: json['fallos'] ?? 0,
      );
}
