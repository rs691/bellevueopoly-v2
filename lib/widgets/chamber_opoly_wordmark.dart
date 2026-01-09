import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Curved, cartoon-style wordmark that matches the Chamber Opoly branding.
class ChamberOpolyWordmark extends StatelessWidget {
  const ChamberOpolyWordmark({
    super.key,
    this.width = 240,
    this.showBanner = true,
    this.hero = false,
  });

  final double width;
  final bool showBanner;
  final bool hero;

  @override
  Widget build(BuildContext context) {
    final height = width * 0.55;
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _ChamberOpolyPainter(
          showBanner: showBanner,
          hero: hero,
        ),
      ),
    );
  }
}

class _ChamberOpolyPainter extends CustomPainter {
  _ChamberOpolyPainter({
    required this.showBanner,
    required this.hero,
  });

  final bool showBanner;
  final bool hero;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);

    if (showBanner) {
      final bubbleRect = Rect.fromCenter(
        center: center,
        width: size.width * 0.92,
        height: size.height * 0.72,
      );
      final bubble = RRect.fromRectAndRadius(
        bubbleRect,
        Radius.circular(size.height * 0.28),
      );
      final bubblePath = Path()..addRRect(bubble);

      canvas.drawShadow(
        bubblePath,
        Colors.black.withOpacity(0.45),
        8,
        true,
      );

      final fill = Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xFF4A148C),
            Color(0xFF512DA8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bubbleRect);

      canvas.drawRRect(bubble, fill);

      final gloss = Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withOpacity(0.18),
            Colors.white.withOpacity(0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bubbleRect)
        ..blendMode = BlendMode.screen;
      canvas.drawRRect(bubble, gloss);

      canvas.drawRRect(
        bubble.inflate(5),
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = hero ? 6 : 5,
      );
    }

    final baseSize = size.height * (hero ? 0.30 : 0.26);
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = hero ? 6 : 4
      ..color = Colors.white
      ..strokeJoin = StrokeJoin.round;

    final strokeStyle = GoogleFonts.luckiestGuy(
      textStyle: TextStyle(
        fontSize: baseSize,
        foreground: strokePaint,
        letterSpacing: 1.5,
      ),
    );

    final fillStyle = GoogleFonts.luckiestGuy(
      textStyle: TextStyle(
        fontSize: baseSize,
        color: const Color(0xFF2C2F8F),
        letterSpacing: 1.5,
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.28),
            blurRadius: hero ? 6 : 4,
            offset: Offset(0, hero ? 2 : 1),
          ),
        ],
      ),
    );

    _drawArcText(
      canvas,
      size,
      text: 'CHAMBER',
      radius: size.width * 0.40,
      centerAngle: -math.pi / 2,
      style: strokeStyle,
      spacing: 4,
    );
    _drawArcText(
      canvas,
      size,
      text: 'CHAMBER',
      radius: size.width * 0.40,
      centerAngle: -math.pi / 2,
      style: fillStyle,
      spacing: 4,
    );

    _drawArcText(
      canvas,
      size,
      text: 'OPOLY',
      radius: size.width * 0.32,
      centerAngle: math.pi / 2,
      style: strokeStyle.copyWith(fontSize: baseSize * 0.92),
      spacing: 5,
      flip: true,
    );
    _drawArcText(
      canvas,
      size,
      text: 'OPOLY',
      radius: size.width * 0.32,
      centerAngle: math.pi / 2,
      style: fillStyle.copyWith(fontSize: baseSize * 0.92),
      spacing: 5,
      flip: true,
    );
  }

  void _drawArcText(
    Canvas canvas,
    Size size, {
    required String text,
    required double radius,
    required double centerAngle,
    required TextStyle style,
    double spacing = 0,
    bool flip = false,
  }) {
    final center = size.center(Offset.zero);
    final characters = text.split('');
    final painters = characters
        .map((char) => TextPainter(
              text: TextSpan(text: char, style: style),
              textDirection: TextDirection.ltr,
            )..layout())
        .toList();

    final totalWidth = painters.fold<double>(0, (sum, painter) => sum + painter.width) +
        spacing * (characters.length - 1);
    final totalAngle = totalWidth / radius;
    var angle = centerAngle - totalAngle / 2;

    for (final painter in painters) {
      final halfAngle = painter.width / (2 * radius);
      final theta = angle + halfAngle;
      final position = Offset(
        center.dx + radius * math.cos(theta),
        center.dy + radius * math.sin(theta),
      );

      canvas.save();
      canvas.translate(position.dx, position.dy);
      canvas.rotate(theta + (flip ? math.pi / 2 : -math.pi / 2));
      painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
      canvas.restore();

      angle += painter.width / radius + spacing / radius;
    }
  }

  @override
  bool shouldRepaint(covariant _ChamberOpolyPainter oldDelegate) {
    return oldDelegate.showBanner != showBanner || oldDelegate.hero != hero;
  }
}
