import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Drifting aurora blobs used behind dark screens.
class AuroraBackground extends StatelessWidget {
  const AuroraBackground({
    super.key,
    required this.animation,
    this.colors = const [Color(0xFF35B81F), Color(0xFF2E6BB8), Color(0xFFC8F74A)],
    this.opacity = 1,
  });

  final Animation<double> animation;
  final List<Color> colors;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) => CustomPaint(
        painter: _AuroraPainter(animation.value, colors, opacity),
        size: Size.infinite,
      ),
    );
  }
}

class _AuroraPainter extends CustomPainter {
  _AuroraPainter(this.t, this.colors, this.opacity);

  final double t;
  final List<Color> colors;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF05100D));

    void blob(Offset center, double radius, Color color, double strength) {
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [color.withValues(alpha: strength), color.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..blendMode = BlendMode.plus;
      canvas.saveLayer(Offset.zero & size, Paint());
      canvas.drawCircle(center, radius, paint);
      canvas.restore();
    }

    final a = t * 2 * math.pi;
    blob(
      Offset(w * (0.25 + 0.16 * math.sin(a)), h * (0.22 + 0.07 * math.cos(a * 1.3))),
      w * 0.72,
      colors[0],
      0.30 * opacity,
    );
    blob(
      Offset(w * (0.82 + 0.10 * math.cos(a * 0.8)), h * (0.32 + 0.08 * math.sin(a * 1.1))),
      w * 0.65,
      colors[1],
      0.34 * opacity,
    );
    blob(
      Offset(w * (0.55 + 0.18 * math.sin(a * 0.7 + 2)), h * (0.86 + 0.05 * math.cos(a))),
      w * 0.62,
      colors[2],
      0.14 * opacity,
    );

    // Vignette
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          radius: 1.05,
          colors: [
            Colors.transparent,
            const Color(0xFF03100C).withValues(alpha: 0.55),
          ],
          stops: const [0.55, 1],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(covariant _AuroraPainter old) => old.t != t;
}

class _Particle {
  final double x;
  final double y;
  final double radius;
  final double speed;
  final double phase;
  final double drift;
  final double hue;

  _Particle(math.Random r)
      : x = r.nextDouble(),
        y = r.nextDouble(),
        radius = 0.6 + r.nextDouble() * 2.4,
        speed = 0.05 + r.nextDouble() * 0.22,
        phase = r.nextDouble() * math.pi * 2,
        drift = r.nextDouble() * 0.12 - 0.06,
        hue = r.nextDouble();
}

/// Rising sparks / dust with a parallax feel.
class ParticleField extends StatelessWidget {
  const ParticleField({
    super.key,
    required this.animation,
    this.count = 46,
    this.color = const Color(0xFFC8F74A),
    this.seed = 7,
    this.opacity = 1,
    this.upwards = true,
  });

  final Animation<double> animation;
  final int count;
  final Color color;
  final int seed;
  final double opacity;
  final bool upwards;

  @override
  Widget build(BuildContext context) {
    final particles = List.generate(count, (_) => _Particle(math.Random(seed)));
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) => IgnorePointer(
        child: CustomPaint(
          painter: _ParticlePainter(particles, animation.value, color, opacity, upwards),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter(this.particles, this.t, this.color, this.opacity, this.upwards);

  final List<_Particle> particles;
  final double t;
  final Color color;
  final double opacity;
  final bool upwards;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final travel = (p.y + (upwards ? -t * p.speed : t * p.speed)) % 1.0;
      final y = (travel + 1) % 1.0 * size.height;
      final x = ((p.x + math.sin(t * 6.283 + p.phase) * 0.02 + p.drift * t) % 1.0) * size.width;
      final twinkle = 0.35 + 0.65 * (0.5 + 0.5 * math.sin(t * 12 + p.phase));
      final c = Color.lerp(color, Colors.white, p.hue * 0.55)!;
      final paint = Paint()
        ..color = c.withValues(alpha: 0.55 * twinkle * opacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.radius * 0.8);
      canvas.drawCircle(Offset(x, y), p.radius * (0.7 + 0.5 * twinkle), paint);
      canvas.drawCircle(
        Offset(x, y),
        p.radius * 0.6,
        Paint()..color = Colors.white.withValues(alpha: 0.5 * twinkle * opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) => old.t != t;
}

/// Concentric orbit rings with orbiting nodes.
class OrbitRings extends StatelessWidget {
  const OrbitRings({
    super.key,
    required this.animation,
    this.size = 300,
    this.color = const Color(0xFFC8F74A),
    this.ringProgress = 1,
  });

  final Animation<double> animation;
  final double size;
  final Color color;
  final double ringProgress;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) => CustomPaint(
        size: Size.square(size),
        painter: _OrbitPainter(animation.value, color, ringProgress),
      ),
    );
  }
}

class _OrbitPainter extends CustomPainter {
  _OrbitPainter(this.t, this.color, this.progress);

  final double t;
  final Color color;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final maxR = size.shortestSide / 2;

    for (var i = 0; i < 3; i++) {
      final r = maxR * (0.55 + i * 0.17);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = color.withValues(alpha: (0.20 - i * 0.05) * progress);
      final dashPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round
        ..color = color.withValues(alpha: (0.42 - i * 0.09) * progress);

      canvas.drawCircle(c, r, paint);

      // Rotating dashed arc
      final start = t * 2 * math.pi * (i.isEven ? 1 : -1) + i * 1.7;
      const segment = math.pi / 7;
      for (var k = 0; k < 4; k++) {
        canvas.drawArc(
          Rect.fromCircle(center: c, radius: r),
          start + k * segment * 1.8,
          segment,
          false,
          dashPaint,
        );
      }

      // Orbiting node
      final angle = t * 2 * math.pi * (1.4 + i * 0.3) + i * 2.1;
      final p = Offset(c.dx + r * math.cos(angle), c.dy + r * math.sin(angle));
      canvas.drawCircle(
        p,
        7 - i * 1.6,
        Paint()
          ..color = color.withValues(alpha: 0.28)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      canvas.drawCircle(p, 2.6 - i * 0.5, Paint()..color = Colors.white.withValues(alpha: 0.9));
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter old) => old.t != t || old.progress != progress;
}

/// Fine dotted grid, subtle depth for light surfaces.
class DotGrid extends StatelessWidget {
  const DotGrid({super.key, this.color = const Color(0x11000000), this.gap = 22});

  final Color color;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _DotGridPainter(color, gap), size: Size.infinite);
  }
}

class _DotGridPainter extends CustomPainter {
  _DotGridPainter(this.color, this.gap);

  final Color color;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color;
    for (double x = gap / 2; x < size.width; x += gap) {
      for (double y = gap / 2; y < size.height; y += gap) {
        canvas.drawCircle(Offset(x, y), 1, p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotGridPainter old) => old.color != color || old.gap != gap;
}
