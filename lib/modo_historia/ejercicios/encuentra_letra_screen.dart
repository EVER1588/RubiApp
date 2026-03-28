import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../constants/custombar_screen.dart';
import '../../services/tts_manager.dart';
import '../models/historia_progress.dart';

/// Ejercicio 3: "Encuentra la [letra]"
/// Burbujas de letras flotan en la pantalla. El niño debe tocar
/// todas las instancias de la letra objetivo.
class EncuentraLetraScreen extends StatefulWidget {
  final String letra;
  const EncuentraLetraScreen({Key? key, required this.letra}) : super(key: key);

  @override
  State<EncuentraLetraScreen> createState() => _EncuentraLetraScreenState();
}

class _EncuentraLetraScreenState extends State<EncuentraLetraScreen>
    with TickerProviderStateMixin {
  final _random = Random();
  late List<_BurbujaData> _burbujas;
  int _encontradas = 0;
  int _totalObjetivos = 0;
  bool _completado = false;
  late AnimationController _floatController;
  late Set<int> _indicesEncontrados; // Rastrear índices encontrados

  // Timer visual (barra de progreso)
  static const _duracionSegundos = 30;
  double _tiempoRestante = 1.0; // 1.0 = lleno, 0.0 = vacío
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _indicesEncontrados = {};
    _generarBurbujas();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    TtsManager.instance.speak('Encuentra todas las ${widget.letra}');

    _timer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      if (!mounted || _completado) {
        t.cancel();
        return;
      }
      setState(() {
        _tiempoRestante -= 1.0 / (_duracionSegundos * 10);
        if (_tiempoRestante <= 0) {
          _tiempoRestante = 0;
          _regenerar();
        }
      });
    });
  }

  void _generarBurbujas() {
    const totalBurbujas = 12;
    final objetivos = 4; // 4 letras objetivo
    _totalObjetivos = objetivos;
    _encontradas = 0;
    _indicesEncontrados = {};

    final letrasDistractoras = 'BCDEFGHIJKLMNOPQRSTUVWXYZ'
        .replaceAll(widget.letra.toUpperCase(), '')
        .split('');
    letrasDistractoras.shuffle(_random);

    _burbujas = [];

    // Agregar letras objetivo
    for (int i = 0; i < objetivos; i++) {
      _burbujas.add(_BurbujaData(
        letra: widget.letra.toUpperCase(),
        esObjetivo: true,
      ));
    }

    // Agregar distractoras
    for (int i = 0; i < totalBurbujas - objetivos; i++) {
      _burbujas.add(_BurbujaData(
        letra: letrasDistractoras[i % letrasDistractoras.length],
        esObjetivo: false,
      ));
    }

    _burbujas.shuffle(_random);

    for (int i = 0; i < _burbujas.length; i++) {
      _burbujas[i].posX = 0.1 + _random.nextDouble() * 0.7;
      _burbujas[i].posY = 0.08 + (i / _burbujas.length) * 0.7;
      _burbujas[i].offsetPhase = _random.nextDouble() * 2 * pi;
    }
  }

  void _regenerar() {
    setState(() {
      _tiempoRestante = 1.0;
      _indicesEncontrados = {};
      _encontradas = 0;
      _generarBurbujas();
    });
    TtsManager.instance.speak('¡Inténtalo de nuevo! Busca la ${widget.letra}');
  }

  @override
  void dispose() {
    _floatController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomBar(
        titleText: 'Encuentra la ${widget.letra}',
        onBackPressed: () => Navigator.of(context).pop(),
        onSettingsPressed: () => mostrarAjustesGlobales(context),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9), Color(0xFFA5D6A7)],
          ),
        ),
        child: SafeArea(
          child: _completado ? _buildCompletado() : _buildJuego(context),
        ),
      ),
    );
  }

  Widget _buildJuego(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        // ── Barra de tiempo ──
        Positioned(
          top: 8,
          left: 20,
          right: 20,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$_encontradas/$_totalObjetivos encontradas',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                  const Text('⏱️', style: TextStyle(fontSize: 18)),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _tiempoRestante,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(
                    _tiempoRestante > 0.3
                        ? Colors.green.shade500
                        : Colors.red.shade400,
                  ),
                ),
              ),
            ],
          ),
        ),
        // ── Burbujas ──
        for (int i = 0; i < _burbujas.length; i++)
          AnimatedBuilder(
            key: ValueKey(i),
            animation: _floatController,
            builder: (ctx, child) {
              if (_indicesEncontrados.contains(i)) {
                return const Positioned(left: -200, top: -200, child: SizedBox.shrink());
              }
              final b = _burbujas[i];
              final floatOffset =
                  sin(_floatController.value * 2 * pi + b.offsetPhase) * 8;
              final x = b.posX * (size.width - 70);
              final y = b.posY * (size.height - 200) + 60 + floatOffset;
              return Positioned(left: x, top: y, child: child!);
            },
            child: _buildBurbuja(_burbujas[i], i),
          ),
      ],
    );
  }

  Widget _buildBurbuja(_BurbujaData b, int index) {
    return GestureDetector(
      onTap: () => _onBurbujaTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.blue.shade100],
          ),
          border: Border.all(
            color: Colors.blue.shade300,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            b.letra,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
        ),
      ),
    );
  }

  void _onBurbujaTap(int index) {
    if (_indicesEncontrados.contains(index)) return;

    final b = _burbujas[index];

    if (b.esObjetivo) {
      setState(() {
        _indicesEncontrados.add(index);
        _encontradas++;
      });
      TtsManager.instance.speak('${widget.letra}');

      if (_encontradas >= _totalObjetivos) {
        _timer?.cancel();
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            TtsManager.instance.speak('¡Las encontraste todas!');
            setState(() => _completado = true);
          }
        });
      }
    } else {
      HistoriaProgress.instance.registrarFallo(widget.letra);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ No es la letra correcta'),
            duration: Duration(milliseconds: 500),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildCompletado() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔍🎉', style: TextStyle(fontSize: 50)),
          const SizedBox(height: 16),
          const Text(
            '¡Las encontraste todas!',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
          ),
          const SizedBox(height: 10),
          Text(
            'Encontraste todas las ${widget.letra}',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 16),
          const Text('+8 🪙', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.amber)),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () async {
              await HistoriaProgress.instance.completarEjercicio(widget.letra, 3);
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

class _BurbujaData {
  final String letra;
  final bool esObjetivo;
  bool encontrada;
  bool error;
  double posX;
  double posY;
  double offsetPhase;

  _BurbujaData({
    required this.letra,
    required this.esObjetivo,
    this.encontrada = false,
    this.error = false,
    this.posX = 0,
    this.posY = 0,
    this.offsetPhase = 0,
  });
}


