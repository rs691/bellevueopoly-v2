import 'dart:math' as math;
import 'package:flutter/material.dart';

class ParticlePainter extends CustomPainter {
  final double animationValue;

  ParticlePainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(20)
      ..isAntiAlias = true;

    final particles = [
      _Particle(0.15, 0.2, 6),
      _Particle(0.85, 0.15, 5),
      _Particle(0.5, 0.75, 7),
      _Particle(0.1, 0.65, 4),
      _Particle(0.9, 0.8, 6),
      _Particle(0.3, 0.4, 5),
      _Particle(0.7, 0.5, 6),
    ];

    for (final particle in particles) {
      final dx =
          size.width * particle.x +
              math.sin(animationValue * math.pi * 2 + particle.phase) * 25;
      final dy =
          size.height * particle.y +
              math.cos(animationValue * math.pi * 2 + particle.phase) * 25;

      canvas.drawCircle(Offset(dx, dy), particle.radius, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}

class _Particle {
  final double x;
  final double y;
  final double radius;
  final double phase = 0;

  _Particle(this.x, this.y, this.radius);
}
