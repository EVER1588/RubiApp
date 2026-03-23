import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'menu_screen.dart';
import '../constants/custombar_screen.dart';
import '../services/tts_manager.dart';

/// Diálogo global de ajustes (Velocidad, Volumen lectura, Volumen música)
/// Se puede llamar desde cualquier pantalla.
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
                      Padding(
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
                                          setDialogState(() {});
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
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

class BienvenidaScreen extends StatefulWidget {
  const BienvenidaScreen({Key? key}) : super(key: key);

  @override
  State<BienvenidaScreen> createState() => _BienvenidaScreenState();
}

class _BienvenidaScreenState extends State<BienvenidaScreen> {

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: CustomBar(
        onBackPressed: () {
          Navigator.pop(context);
        },
        onSettingsPressed: () => mostrarAjustesGlobales(context),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Contenido principal
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Hola',
                      style: TextStyle(
                        fontSize: screenHeight * 0.08, // Tamaño relativo al alto
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    Text(
                      'Aprendamos a leer',
                      style: TextStyle(
                        fontSize: screenHeight * 0.04, // Tamaño relativo al alto
                        color: Colors.deepPurple[800],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.1), // Espaciado relativo
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MenuScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.1, // Ancho relativo
                          vertical: screenHeight * 0.02, // Alto relativo
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        'Comencemos',
                        style: TextStyle(
                          fontSize: screenHeight * 0.03, // Tamaño relativo
                          color: Colors.white,
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
    );
  }
}