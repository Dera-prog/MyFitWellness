import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.97,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.onTap == null ? null : (_) => setState(() => _down = true),
      onTapCancel: widget.onTap == null ? null : () => setState(() => _down = false),
      onTapUp: widget.onTap == null ? null : (_) => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? widget.scale : 1,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

enum ButtonVariant { primary, dark, light, outline, ghost }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.trailing = true,
    this.variant = ButtonVariant.primary,
    this.loading = false,
    this.height = 56,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool trailing;
  final ButtonVariant variant;
  final bool loading;
  final double height;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = switch (variant) {
      ButtonVariant.primary => (null, Colors.white, null),
      ButtonVariant.dark => (AppColors.ink, Colors.white, null),
      ButtonVariant.light => (Colors.white, AppColors.ink, null),
      ButtonVariant.outline => (null, AppColors.ink, AppColors.line),
      ButtonVariant.ghost => (null, AppColors.greenDeep, null),
    };

    final radius = BorderRadius.circular(height / 2);
    final content = AnimatedOpacity(
      opacity: loading ? 0 : 1,
      duration: const Duration(milliseconds: 180),
      child: Row(
        mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 19, color: fg),
            const SizedBox(width: 9),
          ],
          Text(label, style: AppText.button.copyWith(color: fg, fontSize: 15.5)),
          if (trailing && variant == ButtonVariant.primary) ...[
            const SizedBox(width: 10),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.white),
            ),
          ],
        ],
      ),
    );

    return Pressable(
      onTap: loading ? null : onTap,
      child: Container(
        height: height,
        width: expanded ? double.infinity : null,
        padding: expanded ? null : const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          gradient: variant == ButtonVariant.primary ? AppColors.greenGradient : null,
          color: bg,
          borderRadius: radius,
          border: border == null ? null : Border.all(color: border, width: 1.4),
          boxShadow: variant == ButtonVariant.primary
              ? [
                  BoxShadow(
                    color: AppColors.green.withValues(alpha: 0.32),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            content,
            if (loading)
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
              ),
            if (variant == ButtonVariant.primary && !loading)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: radius,
                  child: const _Sheen(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Slow moving glossy highlight across primary buttons.
class _Sheen extends StatefulWidget {
  const _Sheen();

  @override
  State<_Sheen> createState() => _SheenState();
}

class _SheenState extends State<_Sheen> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final v = _c.value * 2 - 0.5;
        return FractionalTranslation(
          translation: Offset(v, 0),
          child: Transform.rotate(
            angle: 0.35,
            child: Container(
              width: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0),
                    Colors.white.withValues(alpha: 0.22),
                    Colors.white.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.dark = false,
    this.badge = false,
    this.size = 44,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool dark;
  final bool badge;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: dark ? Colors.white.withValues(alpha: 0.12) : Colors.white,
              shape: BoxShape.circle,
              border: dark ? null : Border.all(color: AppColors.line),
            ),
            child: Icon(icon, size: 20, color: dark ? Colors.white : AppColors.ink),
          ),
          if (badge)
            Positioned(
              right: 9,
              top: 9,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.danger,
                  shape: BoxShape.circle,
                  border: Border.all(color: dark ? AppColors.nightTop : Colors.white, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = AppRadius.card,
    this.color = AppColors.surface,
    this.onTap,
    this.elevated = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color color;
  final VoidCallback? onTap;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: elevated ? AppShadows.soft : null,
      ),
      child: child,
    );
    if (onTap == null) return card;
    return Pressable(onTap: onTap, child: card);
  }
}

class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.value,
    this.size = 120,
    this.stroke = 11,
    this.trackColor = const Color(0x22FFFFFF),
    this.colors = const [AppColors.greenBright, AppColors.green],
    this.center,
    this.duration = const Duration(milliseconds: 1100),
  });

  final double value;
  final double size;
  final double stroke;
  final Color trackColor;
  final List<Color> colors;
  final Widget? center;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, v, _) {
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size.square(size),
                painter: _RingPainter(v, stroke, trackColor, colors),
              ),
              if (center != null) center!,
            ],
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.value, this.stroke, this.track, this.colors);

  final double value;
  final double stroke;
  final Color track;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (size.shortestSide - stroke) / 2;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = track,
    );

    final arcRect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
        colors: colors,
      ).createShader(arcRect);

    canvas.drawArc(arcRect, -math.pi / 2, 2 * math.pi * value, false, paint);

    if (value > 0.02) {
      final angle = -math.pi / 2 + 2 * math.pi * value;
      final p = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawCircle(
        p,
        stroke * 0.62,
        Paint()..color = Colors.white.withValues(alpha: 0.9),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.value != value || old.stroke != stroke || old.colors != colors;
}

class AnimatedCheckbox extends StatelessWidget {
  const AnimatedCheckbox({super.key, required this.checked, this.size = 28});

  final bool checked;
  final double size;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutBack,
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: checked ? AppColors.greenGradient : null,
        color: checked ? null : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: checked ? Colors.transparent : AppColors.line,
          width: 1.8,
        ),
        boxShadow: checked
            ? [
                BoxShadow(
                  color: AppColors.green.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: AnimatedScale(
        scale: checked ? 1 : 0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutBack,
        child: const Icon(Icons.check_rounded, size: 17, color: Colors.white),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
    this.padding = EdgeInsets.zero,
  });

  final String title;
  final String? action;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(child: Text(title, style: AppText.h3.copyWith(fontSize: 17))),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                action!,
                style: AppText.label.copyWith(color: AppColors.greenDeep, letterSpacing: 0.2),
              ),
            ),
        ],
      ),
    );
  }
}

class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Row(
        children: [
          AppIconButton(
            icon: Icons.arrow_back_rounded,
            onTap: onBack ?? () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: AppText.h2.copyWith(fontSize: 20)),
                if (subtitle != null)
                  Text(subtitle!, style: AppText.small.copyWith(fontSize: 12)),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class LevelChip extends StatelessWidget {
  const LevelChip({super.key, required this.label, this.color = AppColors.green});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppText.tiny.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 9.5,
          letterSpacing: 0.7,
        ),
      ),
    );
  }
}

class StatPill extends StatelessWidget {
  const StatPill({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.dark = false,
  });

  final String value;
  final String label;
  final IconData? icon;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: dark ? AppColors.lime : AppColors.greenDeep),
              const SizedBox(width: 5),
            ],
            Text(
              value,
              style: AppText.h3.copyWith(
                fontSize: 17,
                color: dark ? Colors.white : AppColors.ink,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppText.tiny.copyWith(
            color: dark ? Colors.white.withValues(alpha: 0.55) : AppColors.muted,
          ),
        ),
      ],
    );
  }
}

class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor = AppColors.green,
    this.iconBg,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color iconColor;
  final Color? iconBg;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg ?? iconColor.withValues(alpha: 0.11),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 21, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppText.bodyStrong.copyWith(fontSize: 14.5)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: AppText.small.copyWith(fontSize: 12)),
                  ],
                ],
              ),
            ),
            trailing ??
                const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

/// Staggered entrance used across screens.
class StepDots extends StatelessWidget {
  const StepDots({super.key, required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final active = i + 1 <= current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: i + 1 == current ? 22 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: active ? AppColors.green : AppColors.line,
            borderRadius: BorderRadius.circular(9),
          ),
        );
      }),
    );
  }
}

class SlideFadeIn extends StatelessWidget {
  const SlideFadeIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = const Offset(0, 0.12),
    this.duration = const Duration(milliseconds: 620),
  });

  final Widget child;
  final Duration delay;
  final Offset offset;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration + delay,
      curve: Interval(
        delay.inMilliseconds / (duration + delay).inMilliseconds,
        1,
        curve: Curves.easeOutCubic,
      ),
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(offset.dx * (1 - v) * 60, offset.dy * (1 - v) * 60),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

Future<T?> showAppSheet<T>(BuildContext context, Widget child) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    barrierColor: AppColors.ink.withValues(alpha: 0.45),
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.line,
              borderRadius: BorderRadius.circular(9),
            ),
          ),
          Flexible(child: SingleChildScrollView(child: child)),
        ],
      ),
    ),
  );
}

void appToast(BuildContext context, String message, {IconData? icon}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 2200),
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: AppColors.greenBright, size: 18),
              const SizedBox(width: 10),
            ],
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
}
