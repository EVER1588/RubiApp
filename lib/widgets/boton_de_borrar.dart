import 'package:flutter/material.dart';

class BotonDeBorrar extends StatelessWidget {
  final double anchoP;
  final double altoP;
  final Function(dynamic) alBorrar; // Acepta dynamic (String o Map)
  final bool isLandscape; // Parámetro para identificar modo landscape

  const BotonDeBorrar({
    Key? key,
    required this.anchoP,
    required this.altoP,
    required this.alBorrar,
    this.isLandscape = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calcular tamaño según si es landscape o portrait
    final sizeMultiplier = isLandscape ? 0.12 : 0.20;
    final buttonSize = anchoP * sizeMultiplier;

    return DragTarget<Object>( // Acepta cualquier tipo (Map, String, etc)
      builder: (context, candidateData, rejectedData) {
        return Container(
          height: buttonSize,
          width: buttonSize,
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(anchoP * 0.03),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: anchoP * 0.007,
                blurRadius: anchoP * 0.012,
                offset: Offset(0, altoP * 0.007),
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.delete, color: Colors.white, size: 25),
          ),
        );
      },
      onWillAccept: (data) => true,
      onAccept: (dynamic data) {
        alBorrar(data);
      },
    );
  }
}
