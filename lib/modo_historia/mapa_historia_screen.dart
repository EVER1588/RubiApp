import 'package:flutter/material.dart';
import '../constants/custombar_screen.dart';
import '../services/music_manager.dart';
import 'models/historia_progress.dart';
import 'models/letra_data.dart';
import 'widgets/camino_painter.dart';
import 'widgets/nodo_letra.dart';
import 'letra_menu_screen.dart';

/// Pantalla principal del modo historia.
/// Muestra el mapa con el camino serpenteante y los nodos de letras.
class MapaHistoriaScreen extends StatefulWidget {
  const MapaHistoriaScreen({Key? key}) : super(key: key);

  // Variable estática para rastrear si ya hemos hecho el primer scroll de esta sesión
  static bool _primeraVezSesion = true;

  @override
  State<MapaHistoriaScreen> createState() => _MapaHistoriaScreenState();
}

class _MapaHistoriaScreenState extends State<MapaHistoriaScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _loaded = false;
  late AnimationController _footprintAnimationController;
  late Animation<double> _footprintAnimation;
  int _lastCompletedCount = 0;

  @override
  void initState() {
    super.initState();
    MusicManager.instance.playForScreen(MusicManager.trackHome);
    
    // Inicializar animación de huellitas
    _footprintAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _footprintAnimation = CurvedAnimation(
      parent: _footprintAnimationController,
      curve: Curves.easeInOut,
    );
    
    _cargarProgreso();
  }

  Future<void> _cargarProgreso() async {
    await HistoriaProgress.instance.cargar();
    if (mounted) {
      // Detectar si hubo cambio en progreso completado
      final completedCount = HistoriaProgress.instance.letrasCompletadas;
      if (completedCount > _lastCompletedCount) {
        _lastCompletedCount = completedCount;
        // Animar las nuevas huellitas
        _footprintAnimationController.forward(from: 0.0);
      }
      
      setState(() => _loaded = true);
      // Auto-scroll a la letra activa después de renderizar
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToActive());
    }
  }

  void _scrollToActive() {
    final letraActual = HistoriaProgress.instance.letraActual;
    final idx = HistoriaProgress.letrasOrden.indexOf(letraActual);
    if (idx < 0) return;

    // Calcular posición Y del nodo activo en el canvas
    final total = HistoriaProgress.letrasOrden.length;
    final canvasHeight = total * 130.0 + 200;
    final espacioY = canvasHeight / (total + 1);
    final nodeY = canvasHeight - espacioY * (idx + 1);

    // Centrar en pantalla
    final screenHeight = MediaQuery.of(context).size.height;
    final scrollTo = (nodeY - screenHeight / 2 + 60).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );

    // Usar duración diferente según si es la primera vez de esta sesión
    final duracion = MapaHistoriaScreen._primeraVezSesion
        ? const Duration(seconds: 3)
        : const Duration(milliseconds: 1500);

    _scrollController.animateTo(
      scrollTo,
      duration: duracion,
      curve: Curves.easeOutCubic,
    );

    // Marcar que ya completó el primer scroll
    MapaHistoriaScreen._primeraVezSesion = false;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _footprintAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = HistoriaProgress.instance;
    final total = HistoriaProgress.letrasOrden.length;
    final canvasHeight = total * 130.0 + 200;

    return Scaffold(
      appBar: CustomBar(
        titleText: 'El Viaje de Rubi',
        onBackPressed: () => Navigator.of(context).pop(),
        onSettingsPressed: () => mostrarAjustesGlobales(context),
      ),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // ── Fondo con gradiente por bioma ──
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF87CEEB), // cielo
                        Color(0xFF98D8A0), // pasto
                        Color(0xFF7CB342), // verde bosque
                      ],
                    ),
                  ),
                ),
                // ── Decoración: nubes, árboles, etc. ──
                ..._buildDecoraciones(context),
                // ── Mapa scrollable ──
                SingleChildScrollView(
                  controller: _scrollController,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: canvasHeight,
                    child: Stack(
                      children: [
                        // ── Camino/carretera ──
                        Positioned.fill(
                          child: AnimatedBuilder(
                            animation: _footprintAnimation,
                            builder: (context, _) {
                              final completedLetras =
                                  progress.letrasCompletadas;
                              return CustomPaint(
                                painter: CaminoPainter(
                                  totalNodos: total,
                                  nodosCompletados: completedLetras,
                                  animationValue: _footprintAnimation.value,
                                ),
                              );
                            },
                          ),
                        ),
                        // ── Nodos de letras ──
                        ...List.generate(total, (i) {
                          final letra = HistoriaProgress.letrasOrden[i];
                          final estado = progress.estadoLetra(letra);
                          final estrellas = progress.estrellasDeLetra(letra);
                          final ejCompletados =
                              progress.ejerciciosCompletadosDeLetra(letra);

                          // Calcular posición del nodo
                          final positions = CaminoPainter.calcularPosicionesNodos(
                            total: total,
                            anchoCanvas: MediaQuery.of(context).size.width,
                            altoCanvas: canvasHeight,
                          );
                          final pos = positions[i];

                          return Positioned(
                            left: pos.dx - 35, // centrar nodo (70/2)
                            top: pos.dy - 35,
                            child: NodoLetra(
                              letra: letra,
                              estado: estado,
                              estrellas: estrellas,
                              ejerciciosCompletados: ejCompletados,
                              onTap: () => _abrirLetra(letra),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                // ── Barra de progreso flotante ──
                Positioned(
                  top: 8,
                  left: 16,
                  right: 16,
                  child: _buildBarraProgreso(progress),
                ),
              ],
            ),
    );
  }

  void _abrirLetra(String letra) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LetraMenuScreen(letra: letra),
      ),
    );
    // Recargar progreso al volver
    setState(() {});
  }

  Widget _buildBarraProgreso(HistoriaProgress progress) {
    final completadas = progress.letrasCompletadas;
    final total = progress.totalLetras;
    final porcentaje = completadas / total;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('🌟', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$completadas/$total letras',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF37474F),
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: porcentaje,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF66BB6A)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Monedas
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade300),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🪙', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 4),
                Text(
                  '${progress.monedas}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDecoraciones(BuildContext context) {
    // Decoraciones estáticas de fondo (nubes, arbolitos)
    return [
      Positioned(
        top: 60,
        left: 20,
        child: Opacity(
          opacity: 0.3,
          child: Text('☁️', style: TextStyle(fontSize: 40)),
        ),
      ),
      Positioned(
        top: 120,
        right: 30,
        child: Opacity(
          opacity: 0.25,
          child: Text('☁️', style: TextStyle(fontSize: 50)),
        ),
      ),
      Positioned(
        top: 200,
        left: 10,
        child: Opacity(
          opacity: 0.2,
          child: Text('🌳', style: TextStyle(fontSize: 30)),
        ),
      ),
      Positioned(
        top: 300,
        right: 15,
        child: Opacity(
          opacity: 0.2,
          child: Text('🌲', style: TextStyle(fontSize: 28)),
        ),
      ),
    ];
  }
}
