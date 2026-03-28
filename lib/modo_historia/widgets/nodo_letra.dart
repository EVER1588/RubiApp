import 'package:flutter/material.dart';
import '../models/historia_progress.dart';
import '../models/letra_data.dart';

/// Widget que representa un nodo de letra en el camino del mapa.
/// Muestra la letra, su estado (bloqueado/activo/completado) y estrellas.
class NodoLetra extends StatefulWidget {
  final String letra;
  final LetraEstado estado;
  final int estrellas;
  final int ejerciciosCompletados;
  final VoidCallback? onTap;

  const NodoLetra({
    Key? key,
    required this.letra,
    required this.estado,
    this.estrellas = 0,
    this.ejerciciosCompletados = 0,
    this.onTap,
  }) : super(key: key);

  @override
  State<NodoLetra> createState() => _NodoLetraState();
}

class _NodoLetraState extends State<NodoLetra>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    if (widget.estado == LetraEstado.activo) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(NodoLetra oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.estado == LetraEstado.activo && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (widget.estado != LetraEstado.activo &&
        _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = LetrasDiccionario.datos[widget.letra];
    final icono = data?.icono ?? '❓';
    const nodeSize = 56.0;

    return GestureDetector(
      onTap: widget.estado != LetraEstado.bloqueado ? widget.onTap : null,
      child: AnimatedBuilder(
        animation: _pulseAnim,
        builder: (context, child) {
          final scale =
              widget.estado == LetraEstado.activo ? _pulseAnim.value : 1.0;
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Estrellas (si completada) ──
            if (widget.estado == LetraEstado.completado)
              _buildEstrellas(widget.estrellas),
            // ── Nodo circular ──
            Container(
              width: nodeSize,
              height: nodeSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _gradientForEstado(widget.estado),
                border: Border.all(
                  color: widget.estado == LetraEstado.activo
                      ? Colors.amber
                      : widget.estado == LetraEstado.completado
                          ? Colors.green.shade700
                          : Colors.grey.shade600,
                  width: widget.estado == LetraEstado.activo ? 3.5 : 2.5,
                ),
                boxShadow: [
                  if (widget.estado == LetraEstado.activo)
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.5),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  if (widget.estado == LetraEstado.completado)
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 8,
                    ),
                ],
              ),
              child: Center(
                child: widget.estado == LetraEstado.bloqueado
                    ? Icon(Icons.lock, color: Colors.grey.shade400, size: 24)
                    : Text(
                        widget.letra,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 4,
                              color: Colors.black38,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 2),
            // ── Ícono temático ──
            if (widget.estado != LetraEstado.bloqueado)
              Text(icono, style: const TextStyle(fontSize: 16)),
            // ── Progreso parcial (ejercicios) ──
            if (widget.estado == LetraEstado.activo &&
                widget.ejerciciosCompletados > 0)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  '${widget.ejerciciosCompletados}/5',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.amber.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  LinearGradient _gradientForEstado(LetraEstado estado) {
    switch (estado) {
      case LetraEstado.completado:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.green.shade400, Colors.green.shade700],
        );
      case LetraEstado.activo:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.amber.shade400, Colors.orange.shade600],
        );
      case LetraEstado.bloqueado:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey.shade400, Colors.grey.shade600],
        );
    }
  }

  Widget _buildEstrellas(int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return Icon(
          i < count ? Icons.star : Icons.star_border,
          color: i < count ? Colors.amber : Colors.grey.shade400,
          size: 14,
        );
      }),
    );
  }
}
