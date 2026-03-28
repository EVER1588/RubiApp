import 'dart:math';
import 'package:flutter/material.dart';
import '../services/tts_manager.dart';
import 'models/historia_progress.dart';

/// Pantalla de celebración cuando se completan todos los ejercicios de una letra.
/// Muestra animaciones, confeti y felicitaciones, luego regresa al mapa.
class CelebracionScreen extends StatefulWidget {
  final String letra;
  final int estrellas; // Total de estrellas obtenidas

  const CelebracionScreen({
    Key? key,
    required this.letra,
    required this.estrellas,
  }) : super(key: key);

  @override
  State<CelebracionScreen> createState() => _CelebracionScreenState();
}

class _CelebracionScreenState extends State<CelebracionScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _floatController;
  late AnimationController _starController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();

    TtsManager.instance.speak('¡Felicidades! ¡Completaste todos los ejercicios!');

    // Mantener la pantalla visible por 4 segundos, luego cerrar
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  void _initAnimations() {
    // Animación de escala para el emoji principal
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Animación flotante para estrellas
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _floatAnimation =
        Tween<double>(begin: 0.0, end: 20.0).animate(_floatController);

    // Star burst animation
    _starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _scaleController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _floatController.dispose();
    _starController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFE082), Color(0xFFFFCC80), Color(0xFFFFAB91)],
          ),
        ),
        child: Stack(
          children: [
            // ── Confeti animado: estrellas de fondo ──
            ..._buildConfeti(),

            // ── Contenido principal ──
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  // ── Emoji principal con escala ──
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: const Text(
                      '🎉',
                      style: TextStyle(fontSize: 120),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Título principal ──
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Text(
                      '¡Excelente!',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple.shade700,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.2),
                            offset: const Offset(2, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Subtítulo ──
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Text(
                      'Completaste la letra ${widget.letra}',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ── Estrellas ganadas ──
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.estrellas,
                        (i) => Padding(
                          padding: EdgeInsets.only(
                            left: i == 0 ? 0 : 12,
                            top: sin((i * 0.5 + _starController.value * pi) *
                                    pi) *
                                10,
                          ),
                          child: const Text(
                            '⭐',
                            style: TextStyle(fontSize: 50),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ── Botón flotante ──
                  AnimatedBuilder(
                    animation: _floatAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _floatAnimation.value),
                        child: child,
                      );
                    },
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade500,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 18,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        shadowColor: Colors.green.withOpacity(0.6),
                        elevation: 8,
                      ),
                      child: const Text(
                        'Continuar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye estrellas animadas de confeti
  List<Widget> _buildConfeti() {
    return List.generate(20, (i) {
      final random = (i * 0.7) % 1.0; // "pseudo-random"
      final angle = random * 2 * pi;
      final distance = 200.0 + (i * 10.0) % 100;

      return Positioned(
        left: MediaQuery.of(context).size.width / 2 - 20,
        top: MediaQuery.of(context).size.height / 2 - 20,
        child: AnimatedBuilder(
          animation: _starController,
          builder: (context, child) {
            final progress = (_starController.value + random) % 1.0;
            final x = cos(angle) * distance * progress;
            final y = sin(angle) * distance * progress;
            final opacity = 1.0 - progress;

            return Transform.translate(
              offset: Offset(x, y),
              child: Opacity(
                opacity: opacity,
                child: child,
              ),
            );
          },
          child: const Text(
            '⭐',
            style: TextStyle(fontSize: 24),
          ),
        ),
      );
    });
  }
}
