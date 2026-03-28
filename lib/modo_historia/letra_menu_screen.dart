import 'package:flutter/material.dart';
import '../constants/custombar_screen.dart';
import '../services/music_manager.dart';
import 'models/historia_progress.dart';
import 'models/letra_data.dart';
import 'ejercicios/conoce_letra_screen.dart';
import 'ejercicios/forma_silabas_screen.dart';
import 'ejercicios/encuentra_letra_screen.dart';
import 'ejercicios/arma_palabra_screen.dart';
import 'ejercicios/completa_palabra_screen.dart';
import 'celebracion_screen.dart';

/// Menú de ejercicios para una letra específica.
/// Muestra 5 misiones/ejercicios con su estado (completado o no).
class LetraMenuScreen extends StatefulWidget {
  final String letra;
  const LetraMenuScreen({Key? key, required this.letra}) : super(key: key);

  @override
  State<LetraMenuScreen> createState() => _LetraMenuScreenState();
}

class _LetraMenuScreenState extends State<LetraMenuScreen> {
  late LetraData _letraData;

  @override
  void initState() {
    super.initState();
    _letraData = LetrasDiccionario.obtener(widget.letra);
    MusicManager.instance.playForScreen(MusicManager.trackSilabas);
  }

  @override
  Widget build(BuildContext context) {
    final progress = HistoriaProgress.instance;
    final icono = _letraData.icono;

    return Scaffold(
      appBar: CustomBar(
        titleText: 'Letra ${widget.letra}',
        onBackPressed: () {
          MusicManager.instance.playForScreen(MusicManager.trackHome);
          Navigator.of(context).pop();
        },
        onSettingsPressed: () => mostrarAjustesGlobales(context),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF3E5F5), Color(0xFFE8EAF6), Color(0xFFE0F7FA)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              // ── Encabezado de la letra ──
              _buildEncabezado(icono),
              const SizedBox(height: 8),
              // ── Progreso de ejercicios ──
              _buildProgresoBar(progress),
              const SizedBox(height: 20),
              // ── Lista de ejercicios ──
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildEjercicioCard(
                      numero: 1,
                      titulo: 'Conoce la ${widget.letra}',
                      descripcion: 'Descubre cómo suena y se escribe',
                      icono: '✏️',
                      color: Colors.purple,
                      completado: progress.ejercicioCompletado(widget.letra, 1),
                      onTap: () => _abrirEjercicio(1),
                    ),
                    _buildEjercicioCard(
                      numero: 2,
                      titulo: 'Forma sílabas',
                      descripcion: 'Crea sílabas que tengan la ${widget.letra}',
                      icono: '🔤',
                      color: Colors.blue,
                      completado: progress.ejercicioCompletado(widget.letra, 2),
                      onTap: () => _abrirEjercicio(2),
                    ),
                    _buildEjercicioCard(
                      numero: 3,
                      titulo: 'Encuentra la ${widget.letra}',
                      descripcion: 'Busca todas las ${widget.letra} escondidas',
                      icono: '🔍',
                      color: Colors.orange,
                      completado: progress.ejercicioCompletado(widget.letra, 3),
                      onTap: () => _abrirEjercicio(3),
                    ),
                    _buildEjercicioCard(
                      numero: 4,
                      titulo: 'Arma la palabra',
                      descripcion: 'Ordena las sílabas correctamente',
                      icono: '🧩',
                      color: Colors.teal,
                      completado: progress.ejercicioCompletado(widget.letra, 4),
                      onTap: () => _abrirEjercicio(4),
                    ),
                    _buildEjercicioCard(
                      numero: 5,
                      titulo: 'Completa la palabra',
                      descripcion: 'Elige la sílaba que falta',
                      icono: '🎯',
                      color: Colors.red,
                      completado: progress.ejercicioCompletado(widget.letra, 5),
                      onTap: () => _abrirEjercicio(5),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEncabezado(String icono) {
    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Colors.amber.shade300, Colors.orange.shade500],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.4),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.letra,
              style: const TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [Shadow(blurRadius: 6, color: Colors.black38)],
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(icono, style: const TextStyle(fontSize: 28)),
      ],
    );
  }

  Widget _buildProgresoBar(HistoriaProgress progress) {
    final completados = progress.ejerciciosCompletadosDeLetra(widget.letra);
    const total = HistoriaProgress.ejerciciosPorLetra;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          Text(
            '$completados/$total ejercicios',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: completados / total,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation(Color(0xFF66BB6A)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEjercicioCard({
    required int numero,
    required String titulo,
    required String descripcion,
    required String icono,
    required Color color,
    required bool completado,
    required VoidCallback onTap,
  }) {
    // Los ejercicios son secuenciales: solo se puede jugar si el anterior está hecho
    final progress = HistoriaProgress.instance;
    final habilitado = numero == 1 ||
        progress.ejercicioCompletado(widget.letra, numero - 1);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: habilitado ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: habilitado
                ? Colors.white.withOpacity(0.95)
                : Colors.grey.shade200.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: completado
                  ? Colors.green.shade400
                  : habilitado
                      ? color.withOpacity(0.4)
                      : Colors.grey.shade300,
              width: completado ? 2 : 1.5,
            ),
            boxShadow: [
              if (habilitado)
                BoxShadow(
                  color: color.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
            ],
          ),
          child: Row(
            children: [
              // Ícono / número
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: completado
                      ? Colors.green.shade100
                      : habilitado
                          ? color.withOpacity(0.12)
                          : Colors.grey.shade200,
                ),
                child: Center(
                  child: completado
                      ? Icon(Icons.check_circle, color: Colors.green.shade600, size: 28)
                      : Text(icono, style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 14),
              // Texto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: habilitado ? Colors.grey.shade800 : Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      descripcion,
                      style: TextStyle(
                        fontSize: 12,
                        color: habilitado ? Colors.grey.shade600 : Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
              // Flecha / candado
              if (!habilitado)
                Icon(Icons.lock_outline, color: Colors.grey.shade400, size: 22)
              else if (!completado)
                Icon(Icons.arrow_forward_ios, color: color, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  void _abrirEjercicio(int numero) async {
    Widget screen;
    switch (numero) {
      case 1:
        screen = ConoceLetraScreen(letra: widget.letra);
        break;
      case 2:
        screen = FormaSilabasScreen(letra: widget.letra);
        break;
      case 3:
        screen = EncuentraLetraScreen(letra: widget.letra);
        break;
      case 4:
        screen = ArmaPalabraScreen(letra: widget.letra);
        break;
      case 5:
        screen = CompletaPalabraScreen(letra: widget.letra);
        break;
      default:
        return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
    
    // Refrescar estado al volver
    setState(() {});
    
    // Verificar si se completaron TODOS los ejercicios
    final progress = HistoriaProgress.instance;
    final todosCompletados =
        progress.ejerciciosCompletadosDeLetra(widget.letra) ==
            HistoriaProgress.ejerciciosPorLetra;
    
    if (todosCompletados && mounted) {
      // Mostrar pantalla de celebración
      final estrellas = progress.estrellasDeLetra(widget.letra);
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CelebracionScreen(
            letra: widget.letra,
            estrellas: estrellas,
          ),
        ),
      );
      // Después de celebración, regresar al mapa
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}
