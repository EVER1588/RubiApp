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
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return AppBar(
      elevation: 0,
      toolbarHeight: isLandscape ? 50.0 : 56.0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[700]!, Colors.blue[500]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      leading: Align(
        alignment: Alignment.center,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withOpacity(0.4),
              width: 1.5,
            ),
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 18,
            ),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(minWidth: 40, minHeight: 40),
            onPressed: onBackPressed,
            tooltip: 'Atrás',
          ),
        ),
      ),
      leadingWidth: 60,
      centerTitle: false,
      title: score != null
          ? Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star_rounded, color: Colors.amber[300], size: 20),
                  SizedBox(width: 4),
                  Text(
                    score.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          : null,
      actions: [
        if (onResetPressed != null)
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
            onPressed: onResetPressed,
            tooltip: 'Reiniciar',
            padding: EdgeInsets.symmetric(horizontal: 8),
            constraints: BoxConstraints(minWidth: 40, minHeight: 40),
          ),
        IconButton(
          icon: Icon(Icons.help_outline_rounded, color: Colors.white, size: 20),
          onPressed: () => _mostrarAyuda(context),
          tooltip: 'Ayuda',
          padding: EdgeInsets.symmetric(horizontal: 8),
          constraints: BoxConstraints(minWidth: 40, minHeight: 40),
        ),
        IconButton(
          icon: Icon(Icons.info_outline_rounded, color: Colors.white, size: 20),
          onPressed: () => _mostrarInformacion(context),
          tooltip: 'Estadísticas',
          padding: EdgeInsets.symmetric(horizontal: 8),
          constraints: BoxConstraints(minWidth: 40, minHeight: 40),
        ),
      ],
    );
  }

  void _mostrarAyuda(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ayuda',
                  style: TextStyle(
                      color: Colors.blue[700], fontWeight: FontWeight.bold)),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('📖 Cómo jugar:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 8),
                Text('1. Observa la imagen y escucha la palabra'),
                Text('2. Arrastrar las sílabas al área de construcción'),
                Text('3. Forma la palabra correcta'),
                Text('4. ¡Completa el ejercicio para ganar estrellas!'),
              ],
            ),
          ),
        );
      },
    );
  }

  void _mostrarInformacion(BuildContext context) {
    final stateManager = StateManager();
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Estadísticas',
                  style: TextStyle(
                      color: Colors.blue[700], fontWeight: FontWeight.bold)),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: SingleChildScrollView(
            child: Container(
              width: isLandscape ? 500 : 320,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sección de estadísticas principales
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      children: [
                        _buildEstadisticaItem(
                          'Palabras Descubiertas:',
                          stateManager.palabrasUnicas.length.toString(),
                          Icons.auto_stories,
                        ),
                        SizedBox(height: 10),
                        _buildEstadisticaItem(
                          'Palabras Utilizadas:',
                          stateManager.totalPalabrasUsadas.toString(),
                          Icons.library_books,
                        ),
                        SizedBox(height: 10),
                        _buildEstadisticaItem(
                          'Sílabas Utilizadas:',
                          stateManager.totalSilabasUsadas.toString(),
                          Icons.short_text,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  // Sección de logros
                  Text('🏆 Logros Desbloqueados:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  SizedBox(height: 8),
                  _buildLogro(
                    'Primera Palabra',
                    stateManager.logrosDesbloqueados['primera_palabra'] ??
                        false,
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
                    stateManager.logrosDesbloqueados['cincuenta_silabas'] ??
                        false,
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.blue[700], size: 18),
            SizedBox(width: 8),
            Text(label,
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
          ],
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue[700],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(value,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildLogro(String nombre, bool desbloqueado) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            desbloqueado ? Icons.check_circle_rounded : Icons.lock_outline,
            color: desbloqueado ? Colors.green[600] : Colors.grey[400],
            size: 18,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              nombre,
              style: TextStyle(
                color: desbloqueado ? Colors.black87 : Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
          Icon(
            desbloqueado ? Icons.star : Icons.star_outline,
            color: desbloqueado ? Colors.amber : Colors.grey[400],
            size: 16,
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}