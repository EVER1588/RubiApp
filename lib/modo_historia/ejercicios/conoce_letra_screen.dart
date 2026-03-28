import 'package:flutter/material.dart';
import '../../constants/custombar_screen.dart';
import '../../services/tts_manager.dart';
import '../models/historia_progress.dart';
import '../models/letra_data.dart';

/// Ejercicio 1: "Conoce la letra"
/// Muestra la letra grande, su sonido, la traza con el dedo,
/// y 3 imágenes de palabras que empiezan con ella.
class ConoceLetraScreen extends StatefulWidget {
  final String letra;
  const ConoceLetraScreen({Key? key, required this.letra}) : super(key: key);

  @override
  State<ConoceLetraScreen> createState() => _ConoceLetraScreenState();
}

class _ConoceLetraScreenState extends State<ConoceLetraScreen>
    with TickerProviderStateMixin {
  late LetraData _data;
  int _paso = 0; // 0=presentación, 1=trazo, 2=palabras, 3=completado
  late AnimationController _letraAnimCtrl;
  late Animation<double> _letraScaleAnim;

  // Trazo - lista de trazos (cada trazo = lista de Offset)
  final List<List<Offset>> _trazos = [];
  bool _trazoCompletado = false;

  // Palabras tocadas
  final Set<int> _palabrasTocadas = {};

  @override
  void initState() {
    super.initState();
    _data = LetrasDiccionario.obtener(widget.letra);

    _letraAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _letraScaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _letraAnimCtrl, curve: Curves.elasticOut),
    );
    _letraAnimCtrl.forward();

    // Pronunciar la letra al iniciar
    Future.delayed(const Duration(milliseconds: 500), () {
      TtsManager.instance.speak('${_data.nombreLetra}');
    });
  }

  @override
  void dispose() {
    _letraAnimCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomBar(
        titleText: 'Conoce la ${widget.letra}',
        onBackPressed: () => Navigator.of(context).pop(),
        onSettingsPressed: () => mostrarAjustesGlobales(context),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2), Color(0xFFFFCC80)],
          ),
        ),
        child: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: _buildPaso(),
          ),
        ),
      ),
    );
  }

  Widget _buildPaso() {
    switch (_paso) {
      case 0:
        return _buildPresentacion();
      case 1:
        return _buildTrazo();
      case 2:
        return _buildPalabras();
      case 3:
        return _buildCompletado();
      default:
        return const SizedBox();
    }
  }

  // ── Paso 0: Presentación de la letra ──
  Widget _buildPresentacion() {
    return Center(
      key: const ValueKey(0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '¡Descubre una nueva letra!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5D4037),
            ),
          ),
          const SizedBox(height: 30),
          ScaleTransition(
            scale: _letraScaleAnim,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.orange.shade300, Colors.deepOrange.shade400],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepOrange.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  widget.letra,
                  style: const TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Esta es la letra ${_data.nombreLetra}',
            style: TextStyle(
              fontSize: 18,
              color: Colors.brown.shade700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Suena así: "${_data.sonido}"',
            style: TextStyle(
              fontSize: 16,
              color: Colors.brown.shade500,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _data.icono,
            style: const TextStyle(fontSize: 40),
          ),
          const SizedBox(height: 40),
          // Botón "Escuchar" 
          ElevatedButton.icon(
            onPressed: () {
              TtsManager.instance.speak('${_data.nombreLetra}. ${_data.sonido}');
            },
            icon: const Icon(Icons.volume_up),
            label: const Text('Escuchar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
          const SizedBox(height: 20),
          // Botón "Siguiente"
          ElevatedButton(
            onPressed: () => setState(() => _paso = 1),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('¡Vamos a escribirla! ✏️', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  // ── Paso 1: Trazar la letra con el dedo ──
  Widget _buildTrazo() {
    return Center(
      key: const ValueKey(1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Dibuja la letra ${widget.letra} con tu dedo',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5D4037),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sigue la forma de la letra',
            style: TextStyle(fontSize: 14, color: Colors.brown.shade400),
          ),
          const SizedBox(height: 20),
          // Área de trazo
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.orange.shade300, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Letra guía (fantasma)
                Center(
                  child: Text(
                    widget.letra,
                    style: TextStyle(
                      fontSize: 160,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade200,
                    ),
                  ),
                ),
                // Área de dibujo
                GestureDetector(
                  onPanStart: (d) {
                    setState(() {
                      _trazos.add([d.localPosition]);
                    });
                  },
                  onPanUpdate: (d) {
                    setState(() {
                      if (_trazos.isNotEmpty) {
                        _trazos.last.add(d.localPosition);
                      }
                    });
                  },
                  onPanEnd: (_) {
                    // Completado si hay suficientes puntos en total
                    final totalPuntos = _trazos.fold<int>(0, (sum, t) => sum + t.length);
                    if (totalPuntos > 30) {
                      setState(() => _trazoCompletado = true);
                    }
                  },
                  child: CustomPaint(
                    size: const Size(250, 250),
                    painter: _TrazoPainter(trazos: _trazos),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Borrar trazo
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _trazos.clear();
                    _trazoCompletado = false;
                  });
                },
                icon: const Icon(Icons.refresh, color: Colors.grey),
                label: Text('Borrar', style: TextStyle(color: Colors.grey.shade600)),
              ),
              const SizedBox(width: 20),
              // Siguiente
              ElevatedButton(
                onPressed: _trazoCompletado
                    ? () {
                        TtsManager.instance.speak('¡Muy bien!');
                        setState(() => _paso = 2);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('Siguiente ➡️', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Paso 2: Palabras con la letra ──
  Widget _buildPalabras() {
    // Tomar las 3 primeras palabras de la letra
    final palabras = _data.palabras.take(3).toList();
    final todasTocadas = _palabrasTocadas.length >= palabras.length;

    return Center(
      key: const ValueKey(2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Palabras con ${widget.letra}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5D4037),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toca cada palabra para escucharla',
            style: TextStyle(fontSize: 14, color: Colors.brown.shade400),
          ),
          const SizedBox(height: 4),
          Text(
            '${_palabrasTocadas.length}/${palabras.length} palabras escuchadas',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: todasTocadas ? Colors.green.shade700 : Colors.orange.shade700,
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(palabras.length, (i) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildPalabraCard(palabras[i], i),
              )),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: todasTocadas ? () => setState(() => _paso = 3) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: Text(
              todasTocadas ? '¡Terminé! 🎉' : 'Escucha todas las palabras',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPalabraCard(PalabraData palabra, int index) {
    final tocada = _palabrasTocadas.contains(index);
    return GestureDetector(
      onTap: () {
        TtsManager.instance.speak(palabra.palabra.toLowerCase());
        setState(() => _palabrasTocadas.add(index));
      },
      child: Container(
        width: 260,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: tocada ? Colors.green.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: tocada ? Colors.green.shade400 : Colors.orange.shade200,
            width: tocada ? 2.5 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: (tocada ? Colors.green : Colors.orange).withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Placeholder de imagen
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: palabra.imagenAsset != null
                    ? Image.asset(palabra.imagenAsset!, width: 40, height: 40)
                    : Text(
                        palabra.palabra[0],
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Palabra con la letra resaltada
                  RichText(
                    text: TextSpan(
                      children: palabra.palabra.split('').map((char) {
                        final isTarget = char.toUpperCase() == widget.letra.toUpperCase();
                        return TextSpan(
                          text: char,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isTarget
                                ? Colors.deepOrange
                                : Colors.brown.shade700,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  // Sílabas separadas
                  Text(
                    palabra.silabas.join(' - '),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              tocada ? Icons.check_circle : Icons.volume_up,
              color: tocada ? Colors.green.shade600 : Colors.orange.shade400,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  // ── Paso 3: Completado ──
  Widget _buildCompletado() {
    return Center(
      key: const ValueKey(3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎉', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          const Text(
            '¡Excelente!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Ya conoces la letra ${widget.letra}',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 16),
          const Text('+2 🪙', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.amber)),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () async {
              await HistoriaProgress.instance
                  .completarEjercicio(widget.letra, 1);
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

/// Pinta los trazos del dedo del usuario (soporta múltiples trazos).
class _TrazoPainter extends CustomPainter {
  final List<List<Offset>> trazos;
  _TrazoPainter({required this.trazos});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.deepOrange
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (final trazo in trazos) {
      if (trazo.length < 2) continue;
      final path = Path();
      path.moveTo(trazo.first.dx, trazo.first.dy);
      for (int i = 1; i < trazo.length; i++) {
        path.lineTo(trazo[i].dx, trazo[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TrazoPainter old) => true;
}
