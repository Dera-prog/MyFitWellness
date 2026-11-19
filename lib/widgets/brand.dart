import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The MyFitWellness mark: a navy ring with an abstract green figure/leaf.
class BrandMark extends StatelessWidget {
  const BrandMark({
    super.key,
    this.size = 64,
    this.ringProgress = 1,
    this.markProgress = 1,
    this.ringColor = AppColors.navy,
    this.markColor = AppColors.green,
    this.glow = false,
  });

  final double size;
  final double ringProgress;
  final double markProgress;
  final Color ringColor;
  final Color markColor;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _BrandMarkPainter(
        ringProgress: ringProgress,
        markProgress: markProgress,
        ringColor: ringColor,
        markColor: markColor,
        glow: glow,
      ),
    );
  }
}

class _BrandMarkPainter extends CustomPainter {
  _BrandMarkPainter({
    required this.ringProgress,
    required this.markProgress,
    required this.ringColor,
    required this.markColor,
    required this.glow,
  });

  final double ringProgress;
  final double markProgress;
  final Color ringColor;
  final Color markColor;
  final bool glow;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final c = Offset(size.width / 2, size.height / 2);

    if (glow && ringProgress > 0) {
      final g = Paint()
        ..shader = RadialGradient(
          colors: [markColor.withValues(alpha: 0.28), Colors.transparent],
        ).createShader(Rect.fromCircle(center: c, radius: s * 0.55));
      canvas.drawCircle(c, s * 0.55, g);
    }

    // Ring
    if (ringProgress > 0) {
      final ring = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.045
        ..strokeCap = StrokeCap.round
        ..color = ringColor;
      final rect = Rect.fromCircle(center: c, radius: s * 0.455);
      canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * ringProgress.clamp(0, 1), false, ring);
    }

    if (markProgress <= 0) return;

    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.scale(markProgress);
    final u = s;

    final green = Paint()..color = markColor;
    final greenDeep = Paint()..color = Color.lerp(markColor, AppColors.greenDeep, 0.55)!;

    // Leaf body
    final leaf = Path()
      ..moveTo(-0.12 * u, 0.01 * u)
      ..quadraticBezierTo(0.06 * u, -0.10 * u, 0.21 * u, 0.09 * u)
      ..quadraticBezierTo(0.10 * u, 0.25 * u, -0.06 * u, 0.19 * u)
      ..quadraticBezierTo(-0.18 * u, 0.13 * u, -0.12 * u, 0.01 * u)
      ..close();
    canvas.drawPath(leaf, green);

    // Leaf vein
    final vein = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = u * 0.018
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.55);
    canvas.drawPath(
      Path()
        ..moveTo(-0.07 * u, 0.05 * u)
        ..quadraticBezierTo(0.04 * u, 0.05 * u, 0.14 * u, 0.12 * u),
      vein,
    );

    // Second small leaf
    canvas.drawPath(
      Path()
        ..moveTo(-0.19 * u, 0.10 * u)
        ..quadraticBezierTo(-0.27 * u, 0.20 * u, -0.17 * u, 0.27 * u)
        ..quadraticBezierTo(-0.10 * u, 0.18 * u, -0.19 * u, 0.10 * u)
        ..close(),
      greenDeep,
    );

    // Head
    canvas.drawCircle(Offset(0.03 * u, -0.245 * u), 0.072 * u, greenDeep..style = PaintingStyle.fill);
    canvas.drawCircle(
      Offset(0.03 * u, -0.245 * u),
      0.072 * u,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = u * 0.012
        ..color = Colors.white.withValues(alpha: 0.25),
    );

    // Raised arm
    final arm = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = u * 0.072
      ..strokeCap = StrokeCap.round
      ..color = green.color;
    canvas.drawPath(
      Path()
        ..moveTo(0.0, -0.13 * u)
        ..quadraticBezierTo(0.10 * u, -0.17 * u, 0.17 * u, -0.30 * u),
      arm,
    );

    // Torso link
    canvas.drawPath(
      Path()
        ..moveTo(0.0, -0.16 * u)
        ..quadraticBezierTo(-0.04 * u, -0.06 * u, -0.03 * u, 0.03 * u),
      arm,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BrandMarkPainter old) =>
      old.ringProgress != ringProgress ||
      old.markProgress != markProgress ||
      old.ringColor != ringColor ||
      old.markColor != markColor ||
      old.glow != glow;
}

class BrandWordmark extends StatelessWidget {
  const BrandWordmark({
    super.key,
    this.fontSize = 18,
    this.dark = false,
    this.letterSpacing = 1.6,
  });

  final double fontSize;
  final bool dark;
  final double letterSpacing;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          letterSpacing: letterSpacing,
          height: 1,
        ),
        children: [
          const TextSpan(text: 'MYFIT', style: TextStyle(color: AppColors.green)),
          TextSpan(
            text: 'WELLNESS',
            style: TextStyle(color: dark ? Colors.white : AppColors.navy),
          ),
        ],
      ),
    );
  }
}

/// Lockup used on auth / splash screens.
class BrandLockup extends StatelessWidget {
  const BrandLockup({super.key, this.markSize = 76, this.wordmarkSize = 19, this.dark = false});

  final double markSize;
  final double wordmarkSize;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BrandMark(
          size: markSize,
          ringColor: dark ? Colors.white : AppColors.navy,
          glow: true,
        ),
        const SizedBox(height: 12),
        BrandWordmark(fontSize: wordmarkSize, dark: dark),
      ],
    );
  }
}
