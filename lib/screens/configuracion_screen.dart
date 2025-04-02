import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../constants/custombar_screen.dart'; // Importa el nuevo CustomBar

class ConfiguracionScreen extends StatefulWidget {
  @override
  _ConfiguracionScreenState createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  final FlutterTts _flutterTts = FlutterTts();

  // Velocidad de lectura
  double _ttsSpeed = 0.5; // Normal por defecto
  String _selectedSpeed = 'Normal'; // Botón seleccionado

  // Volumen de la música
  double _musicVolume = 0.5; // Rango: 0.0 a 1.0
  bool _isMusicMuted = false;

  // Volumen de la lectura
  double _ttsVolume = 1.0; // Rango: 0.0 a 1.0
  bool _isTtsMuted = false;

  // Esquema de colores
  Color _primaryColor = Colors.deepPurple;
  Color _secondaryColor = Colors.orange;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _ttsSpeed = prefs.getDouble('ttsSpeed') ?? 1.0;
      _selectedSpeed = _getSpeedLabel(_ttsSpeed);

      _musicVolume = prefs.getDouble('musicVolume') ?? 0.5;
      _isMusicMuted = prefs.getBool('isMusicMuted') ?? false;

      _ttsVolume = prefs.getDouble('ttsVolume') ?? 1.0;
      _isTtsMuted = prefs.getBool('isTtsMuted') ?? false;

      _primaryColor = Color(prefs.getInt('primaryColor') ?? Colors.deepPurple.value);
      _secondaryColor = Color(prefs.getInt('secondaryColor') ?? Colors.orange.value);
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('ttsSpeed', _ttsSpeed);
    await prefs.setDouble('musicVolume', _musicVolume);
    await prefs.setBool('isMusicMuted', _isMusicMuted);
    await prefs.setDouble('ttsVolume', _ttsVolume);
    await prefs.setBool('isTtsMuted', _isTtsMuted);
    await prefs.setInt('primaryColor', _primaryColor.value);
    await prefs.setInt('secondaryColor', _secondaryColor.value);
  }

  String _getSpeedLabel(double speed) {
    if (speed < 0.75) return 'Lenta';
    if (speed > 1.25) return 'Rápida';
    return 'Normal';
  }

  void _setTtsSpeed(double speed) {
    setState(() {
      _ttsSpeed = speed;
      _selectedSpeed = _getSpeedLabel(speed);
      _flutterTts.setSpeechRate(speed);
      _saveSettings();
    });
  }

  void _toggleMusicMute() {
    setState(() {
      _isMusicMuted = !_isMusicMuted;
      _saveSettings();
    });
  }

  void _toggleTtsMute() {
    setState(() {
      _isTtsMuted = !_isTtsMuted;
      _flutterTts.setVolume(_isTtsMuted ? 0.0 : _ttsVolume);
      _saveSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomBar(
        title: 'Configuración',
        onBackPressed: () {
          Navigator.pop(context); // Acción al presionar el botón de retroceso
        },
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Velocidad de lectura
          ListTile(
            title: Text('Velocidad de Lectura'),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _setTtsSpeed(0.5),
                  child: Text('Lenta'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedSpeed == 'Lenta' ? _primaryColor : null,
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _setTtsSpeed(1.0),
                  child: Text('Normal'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedSpeed == 'Normal' ? _primaryColor : null,
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _setTtsSpeed(1.5),
                  child: Text('Rápida'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedSpeed == 'Rápida' ? _primaryColor : null,
                  ),
                ),
              ],
            ),
          ),

          // Volumen de la música
          ListTile(
            title: Text('Volumen de la Música'),
            subtitle: Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _musicVolume,
                    min: 0.0,
                    max: 1.0,
                    onChanged: (value) {
                      setState(() {
                        _musicVolume = value;
                        _saveSettings();
                      });
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(_isMusicMuted ? Icons.volume_off : Icons.volume_up),
                  onPressed: _toggleMusicMute,
                ),
              ],
            ),
          ),

          // Volumen de la lectura
          ListTile(
            title: Text('Volumen de la Lectura'),
            subtitle: Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _ttsVolume,
                    min: 0.0,
                    max: 1.0,
                    onChanged: (value) {
                      setState(() {
                        _ttsVolume = value;
                        _flutterTts.setVolume(value);
                        _saveSettings();
                      });
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(_isTtsMuted ? Icons.volume_off : Icons.volume_up),
                  onPressed: _toggleTtsMute,
                ),
              ],
            ),
          ),

          // Esquema de colores
          ListTile(
            title: Text('Esquema de Colores'),
            subtitle: Wrap(
              spacing: 8,
              children: [
                _buildColorButton(Colors.deepPurple, _primaryColor),
                _buildColorButton(Colors.blue, _primaryColor),
                _buildColorButton(Colors.green, _primaryColor),
                _buildColorButton(Colors.red, _primaryColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorButton(Color color, Color selectedColor) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _primaryColor = color;
          _saveSettings();
        });
      },
      child: CircleAvatar(
        radius: 20,
        backgroundColor: color,
        child: color == selectedColor ? Icon(Icons.check, color: Colors.white) : null,
      ),
    );
  }
}
