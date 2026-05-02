import 'dart:math' as math;

import 'package:flutter/material.dart';

class ParticleSpec {
  final double xFactor;
  final double yFactor;
  final double radius;
  final double speed;
  final double drift;

  const ParticleSpec({
    required this.xFactor,
    required this.yFactor,
    required this.radius,
    required this.speed,
    required this.drift,
  });
}

class ParticlesPainter extends CustomPainter {
  final List<ParticleSpec> particles;
  final double t;

  const ParticlesPainter({required this.particles, required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in particles) {
      final dx =
          (p.xFactor * size.width) + math.sin((t * p.speed) + p.drift) * 8;
      final dy =
          (p.yFactor * size.height) + math.cos((t * p.speed) + p.drift) * 6;
      paint.color = Colors.white.withValues(alpha: 0.08);
      canvas.drawCircle(Offset(dx, dy), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlesPainter oldDelegate) {
    return oldDelegate.t != t;
  }
}
