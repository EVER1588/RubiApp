import 'dart:math';
import 'package:flutter/material.dart';
import '../../constants/custombar_screen.dart';
import '../../services/tts_manager.dart';
import '../models/historia_progress.dart';
import '../models/letra_data.dart';

/// Ejercicio 4: "Arma la palabra"
/// Muestra una palabra y sus sílabas desordenadas. El niño debe
/// tocarlas en el orden correcto para armar la palabra.
class ArmaPalabraScreen extends StatefulWidget {
  final String letra;
  const ArmaPalabraScreen({Key? key, required this.letra}) : super(key: key);

  @override
  State<ArmaPalabraScreen> createState() => _ArmaPalabraScreenState();
}

class _ArmaPalabraScreenState extends State<ArmaPalabraScreen> {
  late LetraData _data;
  late List<PalabraData> _palabras;
  int _palabraActual = 0;
  List<String> _silabasDesordenadas = [];
  List<String> _silabasOrdenadas = [];
  bool _palabraCompletada = false;
  bool _todoCompletado = false;
  int _totalPalabras = 3;

  @override
  void initState() {
    super.initState();
    _data = LetrasDiccionario.obtener(widget.letra);

    // Tomar 3 palabras que tengan al menos 2 sílabas
    final todas = List<PalabraData>.from(
      _data.palabras.where((p) => p.silabas.length >= 2),
    );
    todas.shuffle(Random());
    _palabras = todas.take(3).toList();
    _totalPalabras = _palabras.length;

    if (_palabras.isEmpty) {
      _todoCompletado = true;
    } else {
      _iniciarPalabra();
    }
    TtsManager.instance.speak('Ordena las sílabas para armar la palabra');
  }

  void _iniciarPalabra() {
    final p = _palabras[_palabraActual];
    _silabasDesordenadas = List.from(p.silabas)..shuffle(Random());
    // Asegurar que estén desordenadas
    while (_listEquals(_silabasDesordenadas, p.silabas) &&
        p.silabas.length > 1) {
      _silabasDesordenadas.shuffle(Random());
    }
    _silabasOrdenadas = [];
    _palabraCompletada = false;
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomBar(
        titleText: 'Arma la palabra',
        onBackPressed: () => Navigator.of(context).pop(),
        onSettingsPressed: () => mostrarAjustesGlobales(context),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE0F2F1), Color(0xFFB2DFDB), Color(0xFF80CBC4)],
          ),
        ),
        child: SafeArea(
          child: _todoCompletado
              ? _buildCompletado()
              : _palabras.isEmpty
                  ? _buildSinPalabras()
                  : _buildEjercicio(),
        ),
      ),
    );
  }

  Widget _buildEjercicio() {
    final p = _palabras[_palabraActual];

    return Column(
      children: [
        const SizedBox(height: 16),
        // ── Progreso ──
        Text(
          'Palabra ${_palabraActual + 1} de $_totalPalabras',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.teal.shade800),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _palabraActual / _totalPalabras,
              minHeight: 6,
              backgroundColor: Colors.teal.shade100,
              valueColor: AlwaysStoppedAnimation(Colors.teal.shade600),
            ),
          ),
        ),
        const Spacer(flex: 1),
        // ── Placeholder de imagen ──
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.teal.shade200, width: 2),
            boxShadow: [
              BoxShadow(color: Colors.teal.withOpacity(0.15), blurRadius: 12),
            ],
          ),
          child: Center(
            child: p.imagenAsset != null
                ? Image.asset(p.imagenAsset!, width: 80, height: 80)
                : Text(
                    _data.icono,
                    style: const TextStyle(fontSize: 50),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        // ── Botón escuchar ──
        GestureDetector(
          onTap: () => TtsManager.instance.speak(p.palabra.toLowerCase()),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.volume_up, color: Colors.teal.shade600, size: 22),
              const SizedBox(width: 6),
              Text(
                'Escuchar',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.teal.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // ── Slots de respuesta ──
        _buildSlots(p),
        const SizedBox(height: 30),
        // ── Sílabas desordenadas (opciones) ──
        _buildOpciones(),
        const Spacer(flex: 2),
        // ── Botón siguiente (si completó la palabra) ──
        if (_palabraCompletada) _buildBotonSiguiente(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSlots(PalabraData p) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(p.silabas.length, (i) {
        final filled = i < _silabasOrdenadas.length;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 70,
          height: 50,
          decoration: BoxDecoration(
            color: filled ? Colors.teal.shade100 : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: filled ? Colors.teal.shade500 : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              filled ? _silabasOrdenadas[i] : '',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade800,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildOpciones() {
    // Solo mostrar las sílabas que aún no se han colocado
    final disponibles = List<String>.from(_silabasDesordenadas);
    for (final colocada in _silabasOrdenadas) {
      disponibles.remove(colocada);
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: disponibles.map((s) {
        return GestureDetector(
          onTap: _palabraCompletada ? null : () => _onSilabaTap(s),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.teal.shade300, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withOpacity(0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              s,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade800,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _onSilabaTap(String silaba) {
    final p = _palabras[_palabraActual];
    final posicionEsperada = _silabasOrdenadas.length;
    final silabaCorrecta = p.silabas[posicionEsperada];

    if (silaba == silabaCorrecta) {
      setState(() {
        _silabasOrdenadas.add(silaba);
      });
      TtsManager.instance.speak(silaba.toLowerCase());

      // ¿Completó la palabra?
      if (_silabasOrdenadas.length == p.silabas.length) {
        Future.delayed(const Duration(milliseconds: 400), () {
          TtsManager.instance.speak(p.palabra.toLowerCase());
          if (mounted) setState(() => _palabraCompletada = true);
        });
      }
    } else {
      // Error visual + feedback
      HistoriaProgress.instance.registrarFallo(widget.letra);
      TtsManager.instance.speak('Intenta otra');
    }
  }

  Widget _buildBotonSiguiente() {
    return ElevatedButton(
      onPressed: () {
        if (_palabraActual + 1 < _totalPalabras) {
          setState(() {
            _palabraActual++;
            _iniciarPalabra();
          });
        } else {
          setState(() => _todoCompletado = true);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(
        _palabraActual + 1 < _totalPalabras ? 'Siguiente palabra ➡️' : '¡Terminé! 🎉',
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildSinPalabras() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🧩', style: TextStyle(fontSize: 50)),
          const SizedBox(height: 16),
          Text(
            'No hay palabras disponibles para la ${widget.letra} aún',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () async {
              await HistoriaProgress.instance.completarEjercicio(widget.letra, 4);
              if (mounted) Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Continuar', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletado() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🧩🎉', style: TextStyle(fontSize: 50)),
          const SizedBox(height: 16),
          const Text(
            '¡Palabras armadas!',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF00695C)),
          ),
          const SizedBox(height: 10),
          Text(
            'Armaste $_totalPalabras palabras correctamente',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 16),
          const Text('+16 🪙', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.amber)),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () async {
              await HistoriaProgress.instance.completarEjercicio(widget.letra, 4);
              if (mounted) Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Continuar', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }
}
