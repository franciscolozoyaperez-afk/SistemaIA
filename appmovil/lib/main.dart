import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const VelocimetroApp());
}

class VelocimetroApp extends StatelessWidget {
  const VelocimetroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Velocímetro GPS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B0F14),
      ),
      home: const VelocimetroPage(),
    );
  }
}

class VelocimetroPage extends StatefulWidget {
  const VelocimetroPage({super.key});

  @override
  State<VelocimetroPage> createState() => _VelocimetroPageState();
}

class _VelocimetroPageState extends State<VelocimetroPage> {
  StreamSubscription<Position>? _positionSub;

  double _speedKmh = 0;
  double _accuracy = 0;
  double _altitude = 0;
  double _heading = 0;
  bool _tracking = false;
  String _status = 'Iniciando...';
  DateTime? _lastUpdate;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _status = 'Activa el GPS del dispositivo');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() => _status = 'Permiso de ubicación denegado');
      return;
    }

    _startTracking();
  }

  void _startTracking() {
    final settings = AndroidSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 0,
      intervalDuration: const Duration(milliseconds: 500),
    );

    _positionSub = Geolocator.getPositionStream(locationSettings: settings)
        .listen(_onPosition, onError: _onError);
    setState(() {
      _tracking = true;
      _status = 'Midiendo velocidad...';
    });
  }

  void _onPosition(Position position) {
    if (!mounted) return;
    setState(() {
      _speedKmh = position.speed * 3.6;
      _accuracy = position.accuracy;
      _altitude = position.altitude;
      _heading = position.heading;
      _lastUpdate = DateTime.now();
      _status = 'Midiendo velocidad...';
    });
  }

  void _onError(Object error) {
    if (!mounted) return;
    setState(() => _status = 'Error GPS: $error');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.speed, color: Colors.cyanAccent),
                  const SizedBox(width: 8),
                  const Text(
                    'Velocímetro GPS',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  if (_tracking)
                    const Icon(Icons.gps_fixed, color: Colors.greenAccent)
                  else
                    const Icon(Icons.gps_off, color: Colors.orange),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: CustomPaint(
                    painter: GaugePainter(
                      speedKmh: _speedKmh,
                      maxKmh: 200,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 40),
                          Text(
                            _speedKmh.toStringAsFixed(0),
                            style: const TextStyle(
                              fontSize: 72,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            'km/h',
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.white70,
                              letterSpacing: 4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                color: Colors.white10,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _infoRow('Estado', _status),
                      _infoRow('Precisión', '±${_accuracy.toStringAsFixed(0)} m'),
                      _infoRow('Altitud', '${_altitude.toStringAsFixed(0)} m'),
                      _infoRow(
                        'Dirección',
                        _speedKmh > 1 ? '${_heading.toStringAsFixed(0)}°' : '—',
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
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class GaugePainter extends CustomPainter {
  final double speedKmh;
  final double maxKmh;

  GaugePainter({required this.speedKmh, required this.maxKmh});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    // Arco de fondo
    final bgPaint = Paint()
      ..color = Colors.white12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 0.75,
      math.pi * 1.5,
      false,
      bgPaint,
    );

    // Arco de progreso
    final fraction = (speedKmh / maxKmh).clamp(0.0, 1.0);
    final fgPaint = Paint()
      ..shader = const SweepGradient(
        startAngle: math.pi * 0.75,
        endAngle: math.pi * 2.25,
        colors: [Colors.cyanAccent, Colors.greenAccent, Colors.orangeAccent],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 0.75,
      math.pi * 1.5 * fraction,
      false,
      fgPaint,
    );

    // Marcas de velocidad
    final tickPaint = Paint()
      ..color = Colors.white38
      ..strokeWidth = 2;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i <= 10; i++) {
      final t = i / 10;
      final angle = math.pi * 0.75 + math.pi * 1.5 * t;
      final outer = Offset(
        center.dx + (radius - 6) * math.cos(angle),
        center.dy + (radius - 6) * math.sin(angle),
      );
      final inner = Offset(
        center.dx + (radius - 24) * math.cos(angle),
        center.dy + (radius - 24) * math.sin(angle),
      );
      canvas.drawLine(outer, inner, tickPaint);

      if (i % 2 == 0) {
        final label = (maxKmh * t).round();
        textPainter.text = TextSpan(
          text: '$label',
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        );
        textPainter.layout();
        final tp = Offset(
          center.dx + (radius - 44) * math.cos(angle) - textPainter.width / 2,
          center.dy + (radius - 44) * math.sin(angle) - textPainter.height / 2,
        );
        textPainter.paint(canvas, tp);
      }
    }

    // Aguja
    final needleAngle = math.pi * 0.75 + math.pi * 1.5 * fraction;
    final needlePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      Offset(
        center.dx + (radius - 40) * math.cos(needleAngle),
        center.dy + (radius - 40) * math.sin(needleAngle),
      ),
      needlePaint,
    );
    canvas.drawCircle(center, 8, Paint()..color = Colors.cyanAccent);
  }

  @override
  bool shouldRepaint(covariant GaugePainter oldDelegate) =>
      oldDelegate.speedKmh != speedKmh;
}
