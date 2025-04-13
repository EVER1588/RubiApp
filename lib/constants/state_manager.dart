import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StateManager {
  // Singleton instance
  static final StateManager _instance = StateManager._internal();
  factory StateManager() => _instance;
  StateManager._internal();

  // Estado para Método 2 (Formando Palabras)
  List<Map<String, dynamic>> bloquesContenedor2M2 = [];
  List<Map<String, dynamic>> bloquesContenedor1M2 = [];
  Map<String, dynamic> coloresBloquesM2 = {};
  String letraSeleccionadaM2 = "";
  bool cerrarAutomaticamenteM2 = true;

  // Estado para Método 1 (Aprende Sílabas)
  List<String> syllablesM1 = [''];
  int currentBlockIndexM1 = 0;
  Map<String, bool> activeLettersM1 = {
    'A': true, 'B': true, 'C': true, 'D': true, 'E': true, 'F': true, 'G': true,
    'H': true, 'I': true, 'J': true, 'K': true, 'L': true, 'M': true, 'N': true,
    'Ñ': true, 'O': true, 'P': true, 'Q': true, 'R': true, 'S': true, 'T': true,
    'U': true, 'V': true, 'W': true, 'X': true, 'Y': true, 'Z': true,
  };

  // Estado para Método 3 (Describe la Imagen)
  String imagenActualM3 = '';
  List<Map<String, dynamic>> palabrasSeleccionadasM3 = [];
  List<String> palabrasDisponiblesM3 = [];
  int puntuacionM3 = 0;
  int nivelActualM3 = 1;

  // Contadores globales para logros
  int totalPalabrasUsadas = 0;
  Set<String> palabrasUnicas = {};
  int totalSilabasUsadas = 0;

  // Mapa para rastrear logros desbloqueados
  Map<String, bool> logrosDesbloqueados = {
    'primera_palabra': false,
    'diez_palabras': false,
    'primera_silaba': false,
    'cincuenta_silabas': false,
  };

  void clearMetodo2State() {
    bloquesContenedor2M2.clear();
    bloquesContenedor1M2.clear();
    coloresBloquesM2.clear();
    letraSeleccionadaM2 = "";
    cerrarAutomaticamenteM2 = true;
  }

  void clearMetodo1State() {
    syllablesM1 = [''];
    currentBlockIndexM1 = 0;
    activeLettersM1.clear();
  }

  void clearMetodo3State() {
    imagenActualM3 = '';
    palabrasSeleccionadasM3.clear();
    palabrasDisponiblesM3.clear();
    puntuacionM3 = 0;
    nivelActualM3 = 1;
  }

  // Método para guardar datos
  Future<void> guardarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Guardar contadores
    await prefs.setInt('totalPalabrasUsadas', totalPalabrasUsadas);
    await prefs.setStringList('palabrasUnicas', palabrasUnicas.toList());
    await prefs.setInt('totalSilabasUsadas', totalSilabasUsadas);
    
    // Guardar logros
    for (var entry in logrosDesbloqueados.entries) {
      await prefs.setBool('logro_${entry.key}', entry.value);
    }
  }

  // Método para cargar datos
  Future<void> cargarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Cargar contadores
    totalPalabrasUsadas = prefs.getInt('totalPalabrasUsadas') ?? 0;
    palabrasUnicas = Set<String>.from(prefs.getStringList('palabrasUnicas') ?? []);
    totalSilabasUsadas = prefs.getInt('totalSilabasUsadas') ?? 0;
    
    // Cargar logros
    logrosDesbloqueados = {
      'primera_palabra': prefs.getBool('logro_primera_palabra') ?? false,
      'diez_palabras': prefs.getBool('logro_diez_palabras') ?? false,
      'primera_silaba': prefs.getBool('logro_primera_silaba') ?? false,
      'cincuenta_silabas': prefs.getBool('logro_cincuenta_silabas') ?? false,
    };
  }

  // Método para actualizar contadores y verificar logros
  void actualizarContadores({String? nuevaPalabra, bool nuevaSilaba = false}) {
    if (nuevaPalabra != null) {
      // Incrementar contador total de palabras usadas
      totalPalabrasUsadas++;

      // Agregar a palabras únicas si es nueva
      if (!palabrasUnicas.contains(nuevaPalabra)) {
        palabrasUnicas.add(nuevaPalabra);
        // Verificar logros basados en palabras únicas
        if (palabrasUnicas.length == 1) {
          logrosDesbloqueados['primera_palabra'] = true;
        }
        if (palabrasUnicas.length == 10) {
          logrosDesbloqueados['diez_palabras'] = true;
        }
      }
    }

    if (nuevaSilaba) {
      totalSilabasUsadas++;
      if (totalSilabasUsadas == 1) {
        logrosDesbloqueados['primera_silaba'] = true;
      }
      if (totalSilabasUsadas == 50) {
        logrosDesbloqueados['cincuenta_silabas'] = true;
      }
    }

    // Guardar cambios
    guardarDatos();
  }

  // Getter para el total de palabras únicas
  int get totalPalabrasDescubiertas => palabrasUnicas.length;
}