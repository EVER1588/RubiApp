import 'package:flutter/material.dart';
import '../constants/state_manager.dart';

class CustomBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onBackPressed;
  final VoidCallback? onResetPressed;
  final int? score;

  CustomBar({
    required this.onBackPressed,
    this.onResetPressed,
    this.score,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[700]!, Colors.blue[500]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: onBackPressed,
      ),
      actions: [
        if (score != null)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: Text(
                '⭐ $score',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        if (onResetPressed != null)
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: onResetPressed,
          ),
        IconButton(
          icon: Icon(Icons.help_outline, color: Colors.white),
          onPressed: () {
            // Mostrar diálogo de ayuda
          },
        ),
        IconButton(
          icon: Icon(Icons.info_outline, color: Colors.white),
          onPressed: () => _mostrarInformacion(context),
        ),
      ],
    );
  }

  void _mostrarInformacion(BuildContext context) {
    final stateManager = StateManager();
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Stack(
            children: [
              Text('Estadísticas', 
                style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold)
              ),
              Positioned(
                right: 0,
                top: 0,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.blue[700]),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: SingleChildScrollView(
            child: Container(
              width: isLandscape ? 400 : 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEstadisticaItem(
                    'Palabras Descubiertas:',
                    stateManager.palabrasUnicas.length.toString(),
                    Icons.auto_stories,
                  ),
                  SizedBox(height: 12),
                  _buildEstadisticaItem(
                    'Palabras Utilizadas:',
                    stateManager.totalPalabrasUsadas.toString(),
                    Icons.library_books,
                  ),
                  SizedBox(height: 12),
                  _buildEstadisticaItem(
                    'Sílabas Utilizadas:',
                    stateManager.totalSilabasUsadas.toString(),
                    Icons.short_text,
                  ),
                  SizedBox(height: 20),
                  Text('Logros Desbloqueados:', 
                    style: TextStyle(fontWeight: FontWeight.bold)
                  ),
                  _buildLogro(
                    'Primera Palabra',
                    stateManager.logrosDesbloqueados['primera_palabra'] ?? false,
                  ),
                  _buildLogro(
                    '10 Palabras Descubiertas',
                    stateManager.logrosDesbloqueados['diez_palabras'] ?? false,
                  ),
                  _buildLogro(
                    'Primera Sílaba',
                    stateManager.logrosDesbloqueados['primera_silaba'] ?? false,
                  ),
                  _buildLogro(
                    '50 Sílabas Utilizadas',
                    stateManager.logrosDesbloqueados['cincuenta_silabas'] ?? false,
                  ),
                ],
              ),
            ),
          ),
          actions: [],
        );
      },
    );
  }

  Widget _buildEstadisticaItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue[700], size: 20),
        SizedBox(width: 8),
        Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
        Spacer(),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildLogro(String nombre, bool desbloqueado) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            desbloqueado ? Icons.emoji_events : Icons.lock_outline,
            color: desbloqueado ? Colors.amber : Colors.grey,
            size: 16,
          ),
          SizedBox(width: 8),
          Text(
            nombre,
            style: TextStyle(
              color: desbloqueado ? Colors.black87 : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}