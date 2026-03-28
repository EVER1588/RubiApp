import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/state_manager.dart';
import '../services/tts_manager.dart';
import '../services/music_manager.dart';
import '../modo_historia/models/historia_progress.dart';

class CustomBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onBackPressed;
  final VoidCallback? onResetPressed;
  final VoidCallback? onHelpPressed;
  final VoidCallback? onInfoPressed;
  final VoidCallback? onSettingsPressed;
  final int? score;
  final String? titleText;

  CustomBar({
    this.onBackPressed,
    this.onResetPressed,
    this.onHelpPressed,
    this.onInfoPressed,
    this.onSettingsPressed,
    this.score,
    this.titleText,
  });

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final toolbarH = isLandscape ? 58.0 : 72.0;
    final iconSz = isLandscape ? 22.0 : 26.0;
    final btnSz = isLandscape ? 40.0 : 46.0;

    return AppBar(
      elevation: 0,
      toolbarHeight: toolbarH,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF6C63FF),
              Color(0xFFE91E63),
              Color(0xFFFF9800),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.3),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
      ),
      leadingWidth: onBackPressed != null ? 96 : 0,
      leading: onBackPressed != null
          ? Center(
              child: GestureDetector(
                onTap: onBackPressed,
                child: Container(
                  margin: EdgeInsets.only(left: 6),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back_rounded, color: Colors.white, size: 18),
                      SizedBox(width: 4),
                      Text('Atrás', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            )
          : null,
      centerTitle: false,
      title: titleText != null
          ? _MarqueeTitle(text: titleText!, isLandscape: isLandscape)
          : (score != null
              ? Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_rounded, color: Colors.amber[300], size: iconSz),
                      SizedBox(width: 6),
                      Text(
                        score.toString(),
                        style: TextStyle(
                          fontSize: isLandscape ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              : null),
      actions: [
        if (onResetPressed != null)
          _buildBarAction(Icons.refresh_rounded, Color(0xFF4CAF50), onResetPressed!, iconSz, btnSz),
        _buildBarAction(Icons.help_outline_rounded, Color(0xFF2196F3), onHelpPressed ?? () => _mostrarAyuda(context), iconSz, btnSz),
        _buildBarAction(Icons.info_outline_rounded, Color(0xFF9C27B0), onInfoPressed ?? () => _mostrarInformacion(context), iconSz, btnSz),
        if (onSettingsPressed != null)
          _buildBarAction(Icons.settings_rounded, Color(0xFFFF9800), onSettingsPressed!, iconSz, btnSz),
        SizedBox(width: 3),
      ],
    );
  }

  Widget _buildBarAction(IconData icon, Color bgColor, VoidCallback onPressed, double iconSz, double btnSz) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: btnSz,
          height: btnSz,
          decoration: BoxDecoration(
            color: bgColor.withOpacity(0.35),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
          ),
          child: Icon(icon, color: Colors.white, size: iconSz),
        ),
      ),
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
                    'Primera Sílaba',
                    stateManager.logrosDesbloqueados['primera_silaba'] ?? false,
                  ),
                  _buildLogro(
                    '10 Sílabas Descubiertas',
                    stateManager.logrosDesbloqueados['diez_silabas'] ?? false,
                  ),
                  _buildLogro(
                    '50 Sílabas Descubiertas',
                    stateManager.logrosDesbloqueados['cincuenta_silabas'] ??
                        false,
                  ),
                  _buildLogro(
                    '100 Sílabas Descubiertas',
                    stateManager.logrosDesbloqueados['cien_silabas'] ?? false,
                  ),
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
                    '50 Palabras Descubiertas',
                    stateManager.logrosDesbloqueados['cincuenta_palabras'] ?? false,
                  ),
                  _buildLogro(
                    '100 Palabras Descubiertas',
                    stateManager.logrosDesbloqueados['cien_palabras'] ?? false,
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
  Size get preferredSize {
    // Sincronizar con toolbarH: landscape=58, portrait=72
    // Usamos window.physicalSize porque preferredSize no tiene BuildContext
    final window = WidgetsBinding.instance.window;
    final isLandscape = window.physicalSize.width > window.physicalSize.height;
    return Size.fromHeight(isLandscape ? 58.0 : 72.0);
  }
}

/// Widget de título con desplazamiento automático cuando el texto es muy largo.
class _MarqueeTitle extends StatefulWidget {
  final String text;
  final bool isLandscape;
  const _MarqueeTitle({required this.text, required this.isLandscape});

  @override
  State<_MarqueeTitle> createState() => _MarqueeTitleState();
}

class _MarqueeTitleState extends State<_MarqueeTitle> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  bool _needsScroll = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAndAnimate());
  }

  void _checkAndAnimate() {
    if (!mounted) return;
    if (_scrollController.hasClients && _scrollController.position.maxScrollExtent > 0) {
      setState(() => _needsScroll = true);
      _startAnimation();
    }
  }

  void _startAnimation() async {
    if (!mounted || !_scrollController.hasClients) return;
    while (mounted && _needsScroll) {
      await Future.delayed(Duration(seconds: 1));
      if (!mounted || !_scrollController.hasClients) break;
      final max = _scrollController.position.maxScrollExtent;
      await _scrollController.animateTo(max, duration: Duration(milliseconds: 2000), curve: Curves.easeInOut);
      await Future.delayed(Duration(seconds: 1));
      if (!mounted || !_scrollController.hasClients) break;
      await _scrollController.animateTo(0, duration: Duration(milliseconds: 2000), curve: Curves.easeInOut);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: NeverScrollableScrollPhysics(),
      child: Text(
        widget.text,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: widget.isLandscape ? 18 : 20,
          shadows: [Shadow(blurRadius: 4, color: Colors.black26, offset: Offset(1, 1))],
        ),
      ),
    );
  }
}

/// Diálogo global de ajustes (Velocidad, Volumen lectura, Volumen música)
void mostrarAjustesGlobales(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return StatefulBuilder(
        builder: (ctx, setDialogState) {
          return FutureBuilder<SharedPreferences>(
            future: SharedPreferences.getInstance(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
              final prefs = snapshot.data!;

              double ttsSpeed = prefs.getDouble('ttsSpeed') ?? 1.0;
              String selectedSpeed = ttsSpeed < 0.75 ? 'Lenta' : (ttsSpeed > 1.25 ? 'Rápida' : 'Normal');
              double musicVolume = prefs.getDouble('musicVolume') ?? 0.5;
              bool isMusicMuted = prefs.getBool('isMusicMuted') ?? false;
              double ttsVolume = prefs.getDouble('ttsVolume') ?? 1.0;
              bool isTtsMuted = prefs.getBool('isTtsMuted') ?? false;

              return Dialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                insetPadding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width > 600
                      ? MediaQuery.of(context).size.width * 0.22
                      : 40,
                  vertical: 24,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFF3E5F5), Color(0xFFE8EAF6), Color(0xFFE0F7FA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Título ──
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(20, 18, 8, 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF667EEA), Color(0xFF764BA2), Color(0xFFF093FB)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.tune_rounded, color: Colors.white, size: 26),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text('Ajustes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                            ),
                            IconButton(
                              icon: Icon(Icons.close_rounded, color: Colors.white),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                      ),
                      // ── Contenido ──
                      Flexible(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(16, 16, 16, 20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // ── Velocidad de lectura ──
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.deepPurple.withOpacity(0.2), width: 1.5),
                                    boxShadow: [BoxShadow(color: Colors.deepPurple.withOpacity(0.08), blurRadius: 8, offset: Offset(0, 3))],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.speed_rounded, color: Colors.deepPurple, size: 22),
                                          SizedBox(width: 8),
                                          Text('🗣️ Velocidad de lectura', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.deepPurple[800])),
                                        ],
                                      ),
                                      SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          _buildSpeedChip('🐢 Lenta', 0.5, selectedSpeed == 'Lenta', Colors.orange, () async {
                                            await prefs.setDouble('ttsSpeed', 0.5);
                                            TtsManager.instance.setSpeechRate(0.5);
                                            setDialogState(() {});
                                          }),
                                          _buildSpeedChip('🚶 Normal', 1.0, selectedSpeed == 'Normal', Colors.green, () async {
                                            await prefs.setDouble('ttsSpeed', 1.0);
                                            TtsManager.instance.setSpeechRate(1.0);
                                            setDialogState(() {});
                                          }),
                                          _buildSpeedChip('🐇 Rápida', 1.5, selectedSpeed == 'Rápida', Colors.red, () async {
                                            await prefs.setDouble('ttsSpeed', 1.5);
                                            TtsManager.instance.setSpeechRate(1.5);
                                            setDialogState(() {});
                                          }),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 12),
                                // ── Volumen de lectura ──
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.blue.withOpacity(0.2), width: 1.5),
                                    boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.08), blurRadius: 8, offset: Offset(0, 3))],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.record_voice_over_rounded, color: Colors.blue[700], size: 22),
                                          SizedBox(width: 8),
                                          Text('📖 Volumen de lectura', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blue[800])),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: SliderTheme(
                                              data: SliderThemeData(
                                                activeTrackColor: Colors.blue[400],
                                                inactiveTrackColor: Colors.blue[100],
                                                thumbColor: Colors.blue[600],
                                                overlayColor: Colors.blue.withOpacity(0.2),
                                              ),
                                              child: Slider(
                                                value: ttsVolume,
                                                min: 0.0,
                                                max: 1.0,
                                                onChanged: (value) async {
                                                  await prefs.setDouble('ttsVolume', value);
                                                  TtsManager.instance.setVolume(value);
                                                  setDialogState(() {});
                                                },
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              isTtsMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                                              color: isTtsMuted ? Colors.grey : Colors.blue[700],
                                            ),
                                            onPressed: () async {
                                              final newMuted = !isTtsMuted;
                                              await prefs.setBool('isTtsMuted', newMuted);
                                              setDialogState(() {});
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 12),
                                // ── Volumen de la música ──
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.pink.withOpacity(0.2), width: 1.5),
                                    boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.08), blurRadius: 8, offset: Offset(0, 3))],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.music_note_rounded, color: Colors.pink[600], size: 22),
                                          SizedBox(width: 8),
                                          Text('🎵 Volumen de la música', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.pink[800])),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: SliderTheme(
                                              data: SliderThemeData(
                                                activeTrackColor: Colors.pink[300],
                                                inactiveTrackColor: Colors.pink[100],
                                                thumbColor: Colors.pink[500],
                                                overlayColor: Colors.pink.withOpacity(0.2),
                                              ),
                                              child: Slider(
                                                value: musicVolume,
                                                min: 0.0,
                                                max: 1.0,
                                                onChanged: (value) async {
                                                  await prefs.setDouble('musicVolume', value);
                                                  MusicManager.instance.setVolume(value);
                                                  setDialogState(() {});
                                                },
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              isMusicMuted ? Icons.music_off_rounded : Icons.music_note_rounded,
                                              color: isMusicMuted ? Colors.grey : Colors.pink[600],
                                            ),
                                            onPressed: () async {
                                              final newMuted = !isMusicMuted;
                                              await prefs.setBool('isMusicMuted', newMuted);
                                              MusicManager.instance.setMuted(newMuted);
                                              setDialogState(() {});
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 12),
                                // ── Estadísticas del Modo Historia ──
                                FutureBuilder(
                                  future: Future.microtask(() => _cargarEstadisticasHistoria()),
                                  builder: (ctx, snapshot) {
                                    if (snapshot.hasData) {
                                      final stats = snapshot.data as Map<String, dynamic>;
                                      return Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.8),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: Colors.amber.withOpacity(0.2), width: 1.5),
                                          boxShadow: [BoxShadow(color: Colors.amber.withOpacity(0.08), blurRadius: 8, offset: Offset(0, 3))],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.emoji_events_rounded, color: Colors.amber[700], size: 22),
                                                SizedBox(width: 8),
                                                Text('🗺️ Estadísticas - El Viaje de Rubí', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.amber[800])),
                                              ],
                                            ),
                                            SizedBox(height: 12),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                              children: [
                                                _buildStatBox('🪙 Monedas', stats['monedas'].toString(), Colors.amber),
                                                _buildStatBox('⭐ Estrellas', stats['estrellas'].toString(), Colors.yellow),
                                                _buildStatBox('✅ Letras', '${stats['letrasCompletadas']}/${stats['totalLetras']}', Colors.green),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                    return SizedBox.shrink();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    },
  );
}

Widget _buildSpeedChip(String label, double speed, bool selected, Color color, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? color : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
        border: selected ? Border.all(color: color.withOpacity(0.8), width: 2) : Border.all(color: Colors.grey[300]!, width: 1),
        boxShadow: selected ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 6, offset: Offset(0, 3))] : [],
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: selected ? Colors.white : Colors.grey[700],
        ),
      ),
    ),
  );
}

Future<Map<String, dynamic>> _cargarEstadisticasHistoria() async {
  await HistoriaProgress.instance.cargar();
  final progress = HistoriaProgress.instance;
  
  int letrasCompletadas = 0;
  for (final letra in HistoriaProgress.letrasOrden) {
    if (progress.estadoLetra(letra) == LetraEstado.completado) {
      letrasCompletadas++;
    }
  }

  return {
    'monedas': progress.monedas,
    'estrellas': progress.totalEstrellas,
    'letrasCompletadas': letrasCompletadas,
    'totalLetras': HistoriaProgress.letrasOrden.length,
  };
}

Widget _buildStatBox(String label, String value, Color color) {
  return Column(
    children: [
      Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.15),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
        ),
        child: Center(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ),
      SizedBox(height: 6),
      Text(
        label,
        style: TextStyle(fontSize: 11, color: Colors.grey[700], fontWeight: FontWeight.w500),
        textAlign: TextAlign.center,
      ),
    ],
  );
}

/// Diálogo de ajuste de tamaño de items para pantallas de categorías.
void mostrarAjustesTamanio(BuildContext context, int currentSize, void Function(int) onChanged) {
  int localSize = currentSize;
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return StatefulBuilder(
        builder: (ctx, setDialogState) {
          final labels = ['Pequeños', 'Medianos', 'Grandes'];
          final icons = [Icons.grid_view_rounded, Icons.view_module_rounded, Icons.view_stream_rounded];
          final colors = [Colors.teal, Colors.blue, Colors.deepPurple];
          final isDialogLandscape = MediaQuery.of(ctx).orientation == Orientation.landscape;

          Widget buildChip(int i) {
            final selected = localSize == i;
            return GestureDetector(
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setInt('metodo3ItemSize', i);
                localSize = i;
                setDialogState(() {});
                onChanged(i);
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                    horizontal: isDialogLandscape ? 10 : 12,
                    vertical: isDialogLandscape ? 8 : 14),
                decoration: BoxDecoration(
                  color: selected ? colors[i] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: selected
                      ? Border.all(color: colors[i].withOpacity(0.8), width: 2)
                      : Border.all(color: Colors.grey[300]!, width: 1),
                  boxShadow: selected
                      ? [BoxShadow(color: colors[i].withOpacity(0.3), blurRadius: 6, offset: Offset(0, 3))]
                      : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icons[i], size: 16, color: selected ? Colors.white : Colors.grey[600]),
                    SizedBox(width: 4),
                    Text(labels[i],
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: selected ? Colors.white : Colors.grey[700])),
                  ],
                ),
              ),
            );
          }

          return Dialog(
            insetPadding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(ctx).size.width > 600
                  ? MediaQuery.of(ctx).size.width * 0.22
                  : 40,
              vertical: 24,
            ),
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFFF093FB), Color(0xFF43E97B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: EdgeInsets.all(5),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        'lib/utils/images/fondos/fondo 1.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.72),
                              Colors.black.withOpacity(0.55)
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF667EEA).withOpacity(0.10),
                            Color(0xFFF093FB).withOpacity(0.14)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(20, isDialogLandscape ? 10 : 16, 8, 0),
                            child: Row(
                              children: [
                                Text('⚙️ Ajustes',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: isDialogLandscape ? 16 : 18,
                                        color: Colors.white)),
                                Spacer(),
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(8)),
                                  child: IconButton(
                                    icon: Icon(Icons.close, color: Colors.white, size: 20),
                                    constraints: BoxConstraints(minWidth: 36, minHeight: 36),
                                    padding: EdgeInsets.zero,
                                    onPressed: () => Navigator.of(dialogContext).pop(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(color: Color(0xFF667EEA).withOpacity(0.2), height: 1),
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                                16, isDialogLandscape ? 10 : 16, 16, isDialogLandscape ? 14 : 20),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(isDialogLandscape ? 10 : 14),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.blue.withOpacity(0.25), width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.blue.withOpacity(0.08),
                                      blurRadius: 6,
                                      offset: Offset(0, 3))
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.photo_size_select_large_rounded,
                                          color: Colors.blue[700], size: 22),
                                      SizedBox(width: 8),
                                      Text('📐 Tamaño de items',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: Colors.white)),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  isDialogLandscape
                                      ? Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: List.generate(3, (i) => buildChip(i)),
                                        )
                                      : Column(
                                          children: List.generate(
                                            3,
                                            (i) => Padding(
                                              padding: EdgeInsets.only(bottom: i < 2 ? 8 : 0),
                                              child: SizedBox(
                                                  width: double.infinity, child: buildChip(i)),
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}