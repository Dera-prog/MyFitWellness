import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Breakpoints and spacing for the marketing site. The site is mobile-first:
/// every section stacks below 760 and opens up above it.
class Site {
  Site._();

  static double width(BuildContext context) => MediaQuery.sizeOf(context).width;

  static bool wide(BuildContext context) => width(context) >= 980;

  static bool tablet(BuildContext context) => width(context) >= 760;

  static double gutter(BuildContext context) => tablet(context) ? 32 : 20;

  static double bandPadding(BuildContext context) => wide(context) ? 88 : 64;

  static double heroSize(BuildContext context) =>
      (width(context) * 0.09).clamp(32.0, 52.0);

  static double titleSize(BuildContext context) =>
      (width(context) * 0.034).clamp(27.0, 40.0);

  static double ctaSize(BuildContext context) =>
      (width(context) * 0.03).clamp(24.0, 32.0);
}

/// Centres content and keeps the page column from stretching edge to edge.
class SiteWrap extends StatelessWidget {
  const SiteWrap({super.key, required this.child, this.maxWidth = 1140});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final gutter = Site.gutter(context);
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth + gutter * 2),
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: gutter),
            child: child,
          ),
        ),
      ),
    );
  }
}

class SiteEyebrow extends StatelessWidget {
  const SiteEyebrow(this.text, {super.key, this.onDark = false});

  final String text;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: onDark ? AppColors.lime : AppColors.green,
            boxShadow: [
              BoxShadow(
                color: AppColors.green.withValues(alpha: onDark ? 0.25 : 0.14),
                spreadRadius: 5,
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            text.toUpperCase(),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
              height: 1.2,
              color: onDark ? AppColors.lime : AppColors.greenDeep,
            ),
          ),
        ),
      ],
    );
  }
}

class SiteTitle extends StatelessWidget {
  const SiteTitle(this.text, {super.key, this.maxWidth = 680, this.onDark = false});

  final String text;
  final double maxWidth;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: Site.titleSize(context),
          fontWeight: FontWeight.w800,
          height: 1.14,
          letterSpacing: -0.6,
          color: onDark ? Colors.white : AppColors.ink,
        ),
      ),
    );
  }
}

class SiteSectionHead extends StatelessWidget {
  const SiteSectionHead({
    super.key,
    required this.eyebrow,
    required this.title,
    this.lead,
    this.onDark = false,
  });

  final String eyebrow;
  final String title;
  final String? lead;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SiteEyebrow(eyebrow, onDark: onDark),
        const SizedBox(height: 14),
        SiteTitle(title, onDark: onDark),
        if (lead != null) ...[
          const SizedBox(height: 14),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Text(
              lead!,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                height: 1.6,
                color: onDark
                    ? Colors.white.withValues(alpha: 0.62)
                    : AppColors.inkSoft,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

enum SiteButtonKind { gradient, ghost, light, lightGhost }

class SiteButton extends StatelessWidget {
  const SiteButton({
    super.key,
    required this.label,
    required this.onTap,
    this.kind = SiteButtonKind.gradient,
    this.compact = false,
    this.expand = false,
  });

  final String label;
  final VoidCallback onTap;
  final SiteButtonKind kind;
  final bool compact;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    Gradient? gradient;
    Color? fill;
    late final Color fg;
    BoxBorder? border;
    List<BoxShadow>? shadow;

    switch (kind) {
      case SiteButtonKind.gradient:
        gradient = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.greenBright, AppColors.green],
        );
        fg = Colors.white;
        shadow = [
          BoxShadow(
            color: AppColors.green.withValues(alpha: 0.30),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ];
      case SiteButtonKind.ghost:
        fill = AppColors.surface;
        fg = AppColors.ink;
        border = Border.all(color: AppColors.line);
        shadow = AppShadows.soft;
      case SiteButtonKind.light:
        fill = Colors.white;
        fg = AppColors.ink;
        shadow = const [
          BoxShadow(color: Color(0x2E000000), blurRadius: 34, offset: Offset(0, 16)),
        ];
      case SiteButtonKind.lightGhost:
        fg = Colors.white;
        border = Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1.5);
    }

    final button = Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          gradient: gradient,
          color: fill,
          borderRadius: BorderRadius.circular(999),
          border: border,
          boxShadow: shadow,
        ),
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          hoverColor: Colors.white.withValues(alpha: 0.08),
          child: Padding(
            padding: compact
                ? const EdgeInsets.symmetric(horizontal: 17, vertical: 11)
                : const EdgeInsets.symmetric(horizontal: 26, vertical: 15),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: compact ? 13 : 15,
                fontWeight: FontWeight.w600,
                height: 1.1,
                letterSpacing: 0.1,
                color: fg,
              ),
            ),
          ),
        ),
      ),
    );

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

class SiteCard extends StatelessWidget {
  const SiteCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.background = AppColors.surface,
    this.borderColor = AppColors.line,
    this.radius = 24,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color background;
  final Color borderColor;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
  }
}

class SiteCheckLine extends StatelessWidget {
  const SiteCheckLine(this.text, {super.key, this.onDark = false});

  final String text;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(Icons.check_rounded, size: 16, color: AppColors.green),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              height: 1.45,
              color: onDark
                  ? Colors.white.withValues(alpha: 0.78)
                  : AppColors.inkSoft,
            ),
          ),
        ),
      ],
    );
  }
}

/// A white band with hairline borders, used to alternate sections.
class SiteBand extends StatelessWidget {
  const SiteBand({
    super.key,
    required this.child,
    this.alt = false,
    this.bandKey,
    this.padding,
  });

  final Widget child;
  final bool alt;
  final Key? bandKey;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: bandKey,
      width: double.infinity,
      padding:
          padding ?? EdgeInsets.symmetric(vertical: Site.bandPadding(context)),
      decoration: alt
          ? const BoxDecoration(
              color: AppColors.surface,
              border: Border.symmetric(
                vertical: BorderSide(color: AppColors.line),
              ),
            )
          : null,
      child: child,
    );
  }
}