import 'dart:math';
import 'package:flutter/material.dart';
import '../../constants/custombar_screen.dart';
import '../../services/tts_manager.dart';
import '../models/historia_progress.dart';
import '../models/letra_data.dart';

/// Ejercicio 5: "Completa la palabra"
/// Se muestra una palabra con una sílaba faltante y 3 opciones.
/// El niño elige la sílaba correcta para completarla.
class CompletaPalabraScreen extends StatefulWidget {
  final String letra;
  const CompletaPalabraScreen({Key? key, required this.letra}) : super(key: key);

  @override
  State<CompletaPalabraScreen> createState() => _CompletaPalabraScreenState();
}

class _CompletaPalabraScreenState extends State<CompletaPalabraScreen> {
  late LetraData _data;
  late List<_Pregunta> _preguntas;
  int _preguntaActual = 0;
  String? _respuestaSeleccionada;
  bool _respondioCorrectamente = false;
  bool _todoCompletado = false;

  @override
  void initState() {
    super.initState();
    _data = LetrasDiccionario.obtener(widget.letra);
    _generarPreguntas();
    TtsManager.instance.speak('Elige la sílaba que falta');
  }

  void _generarPreguntas() {
    final random = Random();
    final palabras = List<PalabraData>.from(_data.palabras)
      ..shuffle(random);

    _preguntas = [];
    for (final p in palabras.take(4)) {
      if (p.silabas.length < 2) continue;

      // Elegir una sílaba para esconder
      final idxEscondido = random.nextInt(p.silabas.length);
      final silabaCorrecta = p.silabas[idxEscondido];

      // Generar 2 opciones incorrectas
      final incorrectas = <String>[];
      final todasSilabas = _data.palabras
          .expand((pw) => pw.silabas)
          .where((s) => s != silabaCorrecta)
          .toSet()
          .toList();
      todasSilabas.shuffle(random);
      for (final s in todasSilabas) {
        if (incorrectas.length >= 2) break;
        if (!incorrectas.contains(s)) incorrectas.add(s);
      }
      // Si no hay suficientes, agregar genéricas
      while (incorrectas.length < 2) {
        incorrectas.add(['MA', 'LO', 'TI', 'PE', 'RU'][incorrectas.length]);
      }

      final opciones = [silabaCorrecta, ...incorrectas]..shuffle(random);

      _preguntas.add(_Pregunta(
        palabra: p.palabra,
        silabas: p.silabas,
        indiceEscondido: idxEscondido,
        silabaCorrecta: silabaCorrecta,
        opciones: opciones,
      ));
    }

    if (_preguntas.isEmpty) {
      // Fallback si la letra no tiene suficientes palabras
      _preguntas.add(_Pregunta(
        palabra: 'A',
        silabas: ['A'],
        indiceEscondido: 0,
        silabaCorrecta: 'A',
        opciones: ['A', 'E', 'O'],
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomBar(
        titleText: 'Completa la palabra',
        onBackPressed: () => Navigator.of(context).pop(),
        onSettingsPressed: () => mostrarAjustesGlobales(context),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFCE4EC), Color(0xFFF8BBD0), Color(0xFFF48FB1)],
          ),
        ),
        child: SafeArea(
          child: _todoCompletado ? _buildCompletado() : _buildEjercicio(),
        ),
      ),
    );
  }

  Widget _buildEjercicio() {
    final preg = _preguntas[_preguntaActual];

    return Column(
      children: [
        const SizedBox(height: 16),
        // ── Progreso ──
        Text(
          '${_preguntaActual + 1} de ${_preguntas.length}',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.pink.shade800),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _preguntaActual / _preguntas.length,
              minHeight: 6,
              backgroundColor: Colors.pink.shade100,
              valueColor: AlwaysStoppedAnimation(Colors.pink.shade400),
            ),
          ),
        ),
        const Spacer(flex: 1),
        // ── Instrucción ──
        Text(
          '¿Qué sílaba falta?',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.pink.shade800,
          ),
        ),
        const SizedBox(height: 24),
        // ── Palabra con hueco ──
        _buildPalabraConHueco(preg),
        const SizedBox(height: 8),
        // ── Botón escuchar ──
        GestureDetector(
          onTap: () => TtsManager.instance.speak(preg.palabra.toLowerCase()),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.volume_up, color: Colors.pink.shade400, size: 22),
              const SizedBox(width: 6),
              Text('Escuchar', style: TextStyle(fontSize: 13, color: Colors.pink.shade400)),
            ],
          ),
        ),
        const SizedBox(height: 30),
        // ── Opciones ──
        _buildOpciones(preg),
        const Spacer(flex: 2),
        // ── Botón siguiente ──
        if (_respondioCorrectamente) _buildBotonSiguiente(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildPalabraConHueco(_Pregunta preg) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(preg.silabas.length, (i) {
        final esHueco = i == preg.indiceEscondido && !_respondioCorrectamente;
        final texto = esHueco
            ? (_respuestaSeleccionada ?? '?')
            : preg.silabas[i];
        final esRespuesta = i == preg.indiceEscondido && _respondioCorrectamente;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: esHueco
                ? Colors.white
                : esRespuesta
                    ? Colors.green.shade100
                    : Colors.pink.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: esHueco
                  ? Colors.pink.shade300
                  : esRespuesta
                      ? Colors.green.shade500
                      : Colors.pink.shade200,
              width: esHueco ? 2.5 : 1.5,
            ),
          ),
          child: Text(
            texto,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: esHueco
                  ? (texto == '?' ? Colors.grey.shade300 : Colors.pink.shade700)
                  : Colors.pink.shade800,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildOpciones(_Pregunta preg) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: preg.opciones.map((opcion) {
        final esCorrecta = opcion == preg.silabaCorrecta;
        final seleccionada = _respuestaSeleccionada == opcion;
        final mostrarResultado = _respuestaSeleccionada != null;

        Color bgColor = Colors.white;
        Color borderColor = Colors.pink.shade300;
        if (mostrarResultado && seleccionada) {
          bgColor = esCorrecta ? Colors.green.shade100 : Colors.red.shade100;
          borderColor = esCorrecta ? Colors.green.shade500 : Colors.red.shade500;
        } else if (mostrarResultado && esCorrecta) {
          bgColor = Colors.green.shade50;
          borderColor = Colors.green.shade400;
        }

        return GestureDetector(
          onTap: _respuestaSeleccionada == null ? () => _responder(opcion, preg) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 6),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.pink.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              opcion,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.pink.shade800,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _responder(String opcion, _Pregunta preg) {
    setState(() => _respuestaSeleccionada = opcion);

    if (opcion == preg.silabaCorrecta) {
      TtsManager.instance.speak(preg.palabra.toLowerCase());
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => _respondioCorrectamente = true);
      });
    } else {
      HistoriaProgress.instance.registrarFallo(widget.letra);
      TtsManager.instance.speak('Intenta otra vez');
      // Permitir otro intento después de un momento
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            _respuestaSeleccionada = null;
          });
        }
      });
    }
  }

  Widget _buildBotonSiguiente() {
    return ElevatedButton(
      onPressed: () {
        if (_preguntaActual + 1 < _preguntas.length) {
          setState(() {
            _preguntaActual++;
            _respuestaSeleccionada = null;
            _respondioCorrectamente = false;
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
        _preguntaActual + 1 < _preguntas.length ? 'Siguiente ➡️' : '¡Terminé! 🎉',
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildCompletado() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎯🎉', style: TextStyle(fontSize: 50)),
          const SizedBox(height: 16),
          const Text(
            '¡Completaste todo!',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFFC2185B)),
          ),
          const SizedBox(height: 10),
          Text(
            '¡Ya dominas la letra ${widget.letra}!',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 16),
          const Text('+32 🪙', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.amber)),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () async {
              await HistoriaProgress.instance.completarEjercicio(widget.letra, 5);
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

class _Pregunta {
  final String palabra;
  final List<String> silabas;
  final int indiceEscondido;
  final String silabaCorrecta;
  final List<String> opciones;

  _Pregunta({
    required this.palabra,
    required this.silabas,
    required this.indiceEscondido,
    required this.silabaCorrecta,
    required this.opciones,
  });
}
