import 'package:flutter/material.dart';
import '../../constants/custombar_screen.dart';
import '../../services/tts_manager.dart';
import '../models/historia_progress.dart';
import '../models/letra_data.dart';

/// Ejercicio 2: "Forma sílabas con [letra]"
/// Teclado completo estilo Aprende Sílabas con visualización de módulos/chips.
/// Después de formar las sílabas, el niño las escribe con el dedo.
class FormaSilabasScreen extends StatefulWidget {
  final String letra;
  const FormaSilabasScreen({Key? key, required this.letra}) : super(key: key);

  @override
  State<FormaSilabasScreen> createState() => _FormaSilabasScreenState();
}

class _FormaSilabasScreenState extends State<FormaSilabasScreen>
    with TickerProviderStateMixin {
  // Sílabas formadas y objetivo
  final List<String> _silabasFormadas = [];
  static const int _totalSilabas = 4;

  // Letras seleccionadas para el módulo actual
  final List<String> _letrasActuales = [];

  // Estado general: 0=formando, 1=escribiendo, 2=completado
  int _fase = 0;

  // Escritura: índice de la sílaba actual
  int _silabaEscribiendoIdx = 0;
  final List<List<Offset>> _trazosEscritura = [];
  bool _trazoSilabaCompletado = false;

  // Animación módulo completado
  late AnimationController _moduleAnimCtrl;

  static const _vocales = {'A', 'E', 'I', 'O', 'U'};

  // Sílabas válidas en español
  static const List<String> _silabasValidas = [
    'BA', 'BE', 'BI', 'BO', 'BU', 'CA', 'CE', 'CI', 'CO', 'CU',
    'DA', 'DE', 'DI', 'DO', 'DU', 'FA', 'FE', 'FI', 'FO', 'FU',
    'GA', 'GE', 'GI', 'GO', 'GU', 'HA', 'HE', 'HI', 'HO', 'HU',
    'JA', 'JE', 'JI', 'JO', 'JU', 'KA', 'KE', 'KI', 'KO', 'KU',
    'LA', 'LE', 'LI', 'LO', 'LU', 'MA', 'ME', 'MI', 'MO', 'MU',
    'NA', 'NE', 'NI', 'NO', 'NU', 'ÑA', 'ÑE', 'ÑI', 'ÑO', 'ÑU',
    'PA', 'PE', 'PI', 'PO', 'PU', 'RA', 'RE', 'RI', 'RO', 'RU',
    'SA', 'SE', 'SI', 'SO', 'SU', 'TA', 'TE', 'TI', 'TO', 'TU',
    'VA', 'VE', 'VI', 'VO', 'VU', 'XA', 'XE', 'XI', 'XO', 'XU',
    'YA', 'YE', 'YI', 'YO', 'YU', 'ZA', 'ZE', 'ZI', 'ZO', 'ZU',
    'AL', 'AN', 'AR', 'AS', 'EL', 'EN', 'ES', 'IL', 'IN', 'IS',
    'OL', 'ON', 'OR', 'OS', 'UL', 'UN', 'US',
    'AB', 'AC', 'AD', 'AF', 'AG', 'AJ', 'AM', 'AP', 'AT', 'AX', 'AZ',
    'EB', 'EC', 'ED', 'EF', 'EG', 'EJ', 'EM', 'EP', 'ET', 'EX',
    'OB', 'OC', 'OD', 'OF', 'OG', 'OJ', 'OM', 'OP', 'OT', 'OX',
  ];

  static const List<String> _letras = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
    'N', 'Ñ', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
  ];

  @override
  void initState() {
    super.initState();
    _moduleAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    TtsManager.instance.speak('Forma sílabas que tengan la ${widget.letra}');
  }

  @override
  void dispose() {
    _moduleAnimCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomBar(
        titleText: 'Sílabas con ${widget.letra}',
        onBackPressed: () => Navigator.of(context).pop(),
        onSettingsPressed: () => mostrarAjustesGlobales(context),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB), Color(0xFF90CAF9)],
          ),
        ),
        child: SafeArea(
          child: _buildFaseActual(),
        ),
      ),
    );
  }

  Widget _buildFaseActual() {
    switch (_fase) {
      case 0:
        return _buildFaseFormacion();
      case 1:
        return _buildFaseEscritura();
      case 2:
        return _buildCompletado();
      default:
        return const SizedBox();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FASE 0: Formar sílabas con teclado + módulos
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildFaseFormacion() {
    return Column(
      children: [
        const SizedBox(height: 10),
        Text(
          'Toca dos letras para formar una sílaba con ${widget.letra}',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${_silabasFormadas.length}/$_totalSilabas sílabas',
          style: TextStyle(fontSize: 13, color: Colors.blue.shade600),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _silabasFormadas.length / _totalSilabas,
              minHeight: 6,
              backgroundColor: Colors.blue.shade100,
              valueColor: AlwaysStoppedAnimation(Colors.blue.shade600),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Módulos
        _buildModulos(),
        const Spacer(),
        // Teclado
        _buildTeclado(),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildModulos() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          if (_silabasFormadas.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_silabasFormadas.length, (i) {
                return _buildModuloCompleto(_silabasFormadas[i], i);
              }),
            ),
          if (_silabasFormadas.isNotEmpty) const SizedBox(height: 12),
          if (_silabasFormadas.length < _totalSilabas)
            _buildModuloActual(),
        ],
      ),
    );
  }

  Widget _buildModuloCompleto(String silaba, int index) {
    const colors = [
      Color(0xFFE8F5E9), Color(0xFFFCE4EC),
      Color(0xFFFFF3E0), Color(0xFFF3E5F5),
    ];
    final letters = silaba.split('');
    return Container(
      width: 170,
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors[index % colors.length],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade300, width: 1.5),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...List.generate(letters.length, (j) {
            final widgets = <Widget>[];
            if (j > 0) widgets.add(_moduleOperator('+'));
            widgets.add(Expanded(
              child: GestureDetector(
                onTap: () => TtsManager.instance.speak(letters[j].toLowerCase()),
                child: _moduleLetterChip(
                  j == 0 ? letters[j].toUpperCase() : letters[j].toLowerCase(),
                  color: _getLetterColor(letters[j]),
                ),
              ),
            ));
            return widgets;
          }).expand((w) => w),
          _moduleOperator('='),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () => TtsManager.instance.speak(silaba.toLowerCase()),
              child: _moduleResultChip(
                silaba[0].toUpperCase() + silaba.substring(1).toLowerCase(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuloActual() {
    return Container(
      width: 200,
      height: 56,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueAccent, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _letrasActuales.isNotEmpty
                ? _moduleLetterChip(
                    _letrasActuales[0].toUpperCase(),
                    color: _getLetterColor(_letrasActuales[0]),
                  )
                : _modulePlaceholder(),
          ),
          _moduleOperator('+'),
          Expanded(
            child: _letrasActuales.length >= 2
                ? _moduleLetterChip(
                    _letrasActuales[1].toLowerCase(),
                    color: _getLetterColor(_letrasActuales[1]),
                  )
                : _modulePlaceholder(),
          ),
          _moduleOperator('='),
          Expanded(flex: 2, child: _modulePlaceholder()),
        ],
      ),
    );
  }

  // ── Widgets de módulo (estilo Aprende Sílabas) ──

  Widget _moduleLetterChip(String text, {Color? color}) {
    final chipColor = color ?? Colors.blueAccent;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(color: chipColor.withOpacity(0.45), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(text, style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white,
              shadows: [Shadow(blurRadius: 3, color: Colors.black38, offset: Offset(1, 1))],
            )),
          ),
        ),
      ),
    );
  }

  Widget _moduleResultChip(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(color: Colors.green.withOpacity(0.45), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(text, style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white,
              shadows: [Shadow(blurRadius: 3, color: Colors.black38, offset: Offset(1, 1))],
            )),
          ),
        ),
      ),
    );
  }

  Widget _moduleOperator(String op) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Center(
        child: Text(op, style: TextStyle(
          fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade600,
        )),
      ),
    );
  }

  Widget _modulePlaceholder() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Center(
        child: Text('?', style: TextStyle(
          color: Colors.grey.shade400, fontSize: 16, fontWeight: FontWeight.bold,
        )),
      ),
    );
  }

  Color _getLetterColor(String letter) {
    final upper = letter.toUpperCase();
    if (_vocales.contains(upper)) return Colors.deepOrange;
    final idx = _letras.indexOf(upper);
    final hue = (idx / _letras.length) * 300.0;
    return HSLColor.fromAHSL(1.0, hue, 0.55, 0.45).toColor();
  }

  // ── Teclado completo ──

  Widget _buildTeclado() {
    final targetUpper = widget.letra.toUpperCase();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.blue.withOpacity(0.12), blurRadius: 8),
        ],
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 9,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          childAspectRatio: 1.0,
        ),
        itemCount: _letras.length,
        itemBuilder: (context, index) {
          final letra = _letras[index];
          final isTarget = letra == targetUpper;
          final color = _getLetterColor(letra);

          return GestureDetector(
            onTap: () => _onTeclaPressed(letra),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isTarget ? Colors.yellow.shade600 : Colors.white.withOpacity(0.4),
                  width: isTarget ? 3 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.4), blurRadius: 3, offset: const Offset(0, 2)),
                ],
              ),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Text(
                      letra,
                      style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white,
                        shadows: [Shadow(blurRadius: 3, color: Colors.black38, offset: Offset(1, 1))],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _onTeclaPressed(String letra) {
    if (_silabasFormadas.length >= _totalSilabas) return;

    setState(() => _letrasActuales.add(letra));

    if (_letrasActuales.length >= 2) {
      final silaba = _letrasActuales.join();
      _evaluarSilaba(silaba);
    }
  }

  void _evaluarSilaba(String silaba) {
    final upper = silaba.toUpperCase();
    final contieneLetra = upper.contains(widget.letra.toUpperCase());
    final esValida = _silabasValidas.contains(upper);

    if (contieneLetra && esValida && !_silabasFormadas.contains(upper)) {
      TtsManager.instance.speak(silaba.toLowerCase());
      _moduleAnimCtrl.forward(from: 0);

      setState(() {
        _silabasFormadas.add(upper);
        _letrasActuales.clear();
      });

      if (_silabasFormadas.length >= _totalSilabas) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            TtsManager.instance.speak('¡Ahora escribe las sílabas!');
            setState(() => _fase = 1);
          }
        });
      }
    } else {
      if (!contieneLetra) {
        TtsManager.instance.speak('Necesita la ${widget.letra}');
      } else if (!esValida) {
        TtsManager.instance.speak('Esa sílaba no existe');
      } else {
        TtsManager.instance.speak('Ya la formaste');
      }
      HistoriaProgress.instance.registrarFallo(widget.letra);

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _letrasActuales.clear());
      });
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FASE 1: Escribir las sílabas con el dedo
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildFaseEscritura() {
    final silaba = _silabasFormadas[_silabaEscribiendoIdx];
    final display = silaba[0].toUpperCase() + silaba.substring(1).toLowerCase();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Escribe la sílaba',
            style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_silabaEscribiendoIdx + 1}/${_silabasFormadas.length}',
            style: TextStyle(fontSize: 13, color: Colors.blue.shade500),
          ),
          const SizedBox(height: 16),
          Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blue.shade300, width: 3),
              boxShadow: [
                BoxShadow(color: Colors.blue.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 4)),
              ],
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    display,
                    style: TextStyle(fontSize: 120, fontWeight: FontWeight.bold, color: Colors.grey.shade200),
                  ),
                ),
                GestureDetector(
                  onPanStart: (d) {
                    setState(() => _trazosEscritura.add([d.localPosition]));
                  },
                  onPanUpdate: (d) {
                    setState(() {
                      if (_trazosEscritura.isNotEmpty) {
                        _trazosEscritura.last.add(d.localPosition);
                      }
                    });
                  },
                  onPanEnd: (_) {
                    final totalPuntos = _trazosEscritura.fold<int>(0, (sum, t) => sum + t.length);
                    if (totalPuntos > 20) {
                      setState(() => _trazoSilabaCompletado = true);
                    }
                  },
                  child: CustomPaint(
                    size: const Size(260, 260),
                    painter: _TrazoPainter(trazos: _trazosEscritura),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _trazosEscritura.clear();
                    _trazoSilabaCompletado = false;
                  });
                },
                icon: const Icon(Icons.refresh, color: Colors.grey),
                label: Text('Borrar', style: TextStyle(color: Colors.grey.shade600)),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: _trazoSilabaCompletado ? _siguienteSilabaEscritura : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: Text(
                  _silabaEscribiendoIdx < _silabasFormadas.length - 1
                      ? 'Siguiente ➡️'
                      : '¡Listo! ✅',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _siguienteSilabaEscritura() {
    TtsManager.instance.speak('¡Muy bien!');
    if (_silabaEscribiendoIdx < _silabasFormadas.length - 1) {
      setState(() {
        _silabaEscribiendoIdx++;
        _trazosEscritura.clear();
        _trazoSilabaCompletado = false;
      });
    } else {
      setState(() => _fase = 2);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FASE 2: Completado
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildCompletado() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎉', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          const Text(
            '¡Fantástico!',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1565C0)),
          ),
          const SizedBox(height: 10),
          Text(
            'Formaste y escribiste $_totalSilabas sílabas con la ${widget.letra}',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _silabasFormadas.map((s) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade400),
                ),
                child: Text(
                  s[0].toUpperCase() + s.substring(1).toLowerCase(),
                  style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green.shade800,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text('+4 🪙', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.amber)),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () async {
              await HistoriaProgress.instance.completarEjercicio(widget.letra, 2);
              if (mounted) Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Continuar', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }
}

/// Pinta trazos del dedo (múltiples trazos).
class _TrazoPainter extends CustomPainter {
  final List<List<Offset>> trazos;
  _TrazoPainter({required this.trazos});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.shade700
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (final trazo in trazos) {
      if (trazo.length < 2) continue;
      final path = Path();
      path.moveTo(trazo.first.dx, trazo.first.dy);
      for (int i = 1; i < trazo.length; i++) {
        path.lineTo(trazo[i].dx, trazo[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TrazoPainter old) => true;
}
