import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'site_content.dart';
import 'site_shell.dart';
import 'site_widgets.dart';

// ---------------------------------------------------------------- layout

class SiteGrid extends StatelessWidget {
  const SiteGrid({
    super.key,
    required this.cols,
    required this.children,
    this.gap = 20,
  });

  final int cols;
  final double gap;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var start = 0; start < children.length; start += cols) {
      final chunk = children.sublist(
        start,
        math.min(start + cols, children.length),
      );
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < cols; i++) ...[
                if (i > 0) SizedBox(width: gap),
                Expanded(
                  child: i < chunk.length ? chunk[i] : const SizedBox(),
                ),
              ],
            ],
          ),
        ),
      );
      if (start + cols < children.length) rows.add(SizedBox(height: gap));
    }
    return Column(children: rows);
  }
}

class SiteDotGridPainter extends CustomPainter {
  const SiteDotGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const gap = 26.0;
    final paint = Paint();
    for (double y = 0; y < size.height; y += gap) {
      final fade = (1 - y / size.height).clamp(0.0, 1.0);
      paint.color = AppColors.ink.withValues(alpha: 0.07 * fade);
      for (double x = 0; x < size.width; x += gap) {
        canvas.drawCircle(Offset(x, y), 1.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant SiteDotGridPainter oldDelegate) => false;
}

class SiteGlow extends StatelessWidget {
  const SiteGlow({super.key, this.size = 560, this.alignment});

  final double size;
  final Alignment? alignment;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppColors.green.withValues(alpha: 0.16),
              Colors.transparent,
            ],
            stops: const [0, 0.62],
          ),
        ),
      ),
    );
  }
}

/// The header block at the top of a standalone page.
class SitePageIntro extends StatelessWidget {
  const SitePageIntro({
    super.key,
    required this.eyebrow,
    required this.title,
    this.lead,
  });

  final String eyebrow;
  final String title;
  final String? lead;

  @override
  Widget build(BuildContext context) {
    final wide = Site.wide(context);
    return ClipRect(
      child: Stack(
        children: [
          const Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: SiteDotGridPainter()),
            ),
          ),
          const Positioned(top: -220, right: -150, child: SiteGlow()),
          SiteWrap(
            child: Padding(
              padding: EdgeInsets.only(
                top: wide ? 58 : 36,
                bottom: wide ? 14 : 8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SiteEyebrow(eyebrow),
                  const SizedBox(height: 16),
                  SiteTitle(title, maxWidth: 760),
                  if (lead != null) ...[
                    const SizedBox(height: 16),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 620),
                      child: Text(
                        lead!,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          height: 1.6,
                          color: AppColors.inkSoft,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Section heading with a link to the page that covers the topic in full.
class SiteHeadWithLink extends StatelessWidget {
  const SiteHeadWithLink({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.linkLabel,
    required this.page,
  });

  final String eyebrow;
  final String title;
  final String linkLabel;
  final SitePage page;

  @override
  Widget build(BuildContext context) {
    final head = SiteSectionHead(eyebrow: eyebrow, title: title);
    final link = SiteMoreLink(label: linkLabel, page: page);
    if (!Site.wide(context)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [head, const SizedBox(height: 16), link],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: head),
        const SizedBox(width: 24),
        Padding(padding: const EdgeInsets.only(bottom: 6), child: link),
      ],
    );
  }
}

class SiteMoreLink extends StatelessWidget {
  const SiteMoreLink({super.key, required this.label, required this.page});

  final String label;
  final SitePage page;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => SiteNavScope.of(context).open(page),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.greenDeep,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.arrow_forward_rounded,
              size: 16,
              color: AppColors.greenDeep,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- features

class SiteFeatureGrid extends StatelessWidget {
  const SiteFeatureGrid({super.key, required this.features});

  final List<SiteFeature> features;

  @override
  Widget build(BuildContext context) {
    final cols = Site.wide(context) ? 3 : (Site.tablet(context) ? 2 : 1);
    return SiteGrid(
      cols: cols,
      children: [for (final feature in features) SiteFeatureCard(feature)],
    );
  }
}

class SiteFeatureCard extends StatelessWidget {
  const SiteFeatureCard(this.feature, {super.key});

  final SiteFeature feature;

  @override
  Widget build(BuildContext context) {
    return SiteCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: feature.tint,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(feature.icon, size: 22, color: feature.ink),
          ),
          const SizedBox(height: 16),
          Text(
            feature.title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            feature.body,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              height: 1.55,
              color: AppColors.inkSoft,
            ),
          ),
        ],
      ),
    );
  }
}

/// The long-form version of each feature, used on the Features page.
class SiteFeatureDetails extends StatelessWidget {
  const SiteFeatureDetails({super.key, required this.features});

  final List<SiteFeature> features;

  @override
  Widget build(BuildContext context) {
    final cols = Site.wide(context) ? 2 : 1;
    return SiteGrid(
      cols: cols,
      children: [
        for (final feature in features)
          SiteCard(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: feature.tint,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(feature.icon, size: 22, color: feature.ink),
                ),
                const SizedBox(height: 18),
                Text(
                  feature.detailTitle,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  feature.detailBody,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    height: 1.6,
                    color: AppColors.inkSoft,
                  ),
                ),
                const SizedBox(height: 18),
                for (final bullet in feature.bullets)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SiteCheckLine(bullet),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class SiteInfoCards extends StatelessWidget {
  const SiteInfoCards({super.key, required this.cards, this.cols});

  final List<SiteInfoCard> cards;
  final int? cols;

  @override
  Widget build(BuildContext context) {
    final width = cols ?? (Site.wide(context) ? 3 : (Site.tablet(context) ? 2 : 1));
    return SiteGrid(
      cols: width,
      children: [
        for (final card in cards)
          SiteCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(card.icon, size: 21, color: AppColors.greenDeep),
                ),
                const SizedBox(height: 16),
                Text(
                  card.title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  card.body,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    height: 1.55,
                    color: AppColors.inkSoft,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------- steps

class SiteStepCards extends StatelessWidget {
  const SiteStepCards({
    super.key,
    required this.steps,
    this.showBullets = false,
  });

  final List<SiteStep> steps;
  final bool showBullets;

  @override
  Widget build(BuildContext context) {
    final cols = Site.wide(context) ? 3 : 1;
    return SiteGrid(
      cols: cols,
      children: [
        for (final step in steps)
          SiteCard(
            background: AppColors.bg,
            padding: const EdgeInsets.fromLTRB(26, 30, 26, 26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.number,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    color: AppColors.greenDeep,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  step.title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  step.body,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    height: 1.55,
                    color: AppColors.inkSoft,
                  ),
                ),
                if (showBullets) ...[
                  const SizedBox(height: 16),
                  for (final bullet in step.bullets)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 7),
                      child: SiteCheckLine(bullet),
                    ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------- plans

class SitePlanGrid extends StatelessWidget {
  const SitePlanGrid({super.key, required this.plans});

  final List<SitePlan> plans;

  @override
  Widget build(BuildContext context) {
    final cols = Site.tablet(context) ? 2 : 1;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 900),
      child: SiteGrid(
        cols: cols,
        children: [
          for (final plan in plans) SitePlanCard(plan: plan),
        ],
      ),
    );
  }
}

class SitePlanCard extends StatelessWidget {
  const SitePlanCard({super.key, required this.plan});

  final SitePlan plan;

  @override
  Widget build(BuildContext context) {
    final featured = plan.featured;
    final fg = featured ? Colors.white : AppColors.ink;
    final nav = SiteNavScope.of(context);

    return Container(
      padding: EdgeInsets.all(Site.wide(context) ? 30 : 26),
      decoration: BoxDecoration(
        gradient: featured
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.nightTop, Color(0xFF123B29)],
              )
            : null,
        color: featured ? null : AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: featured ? null : Border.all(color: AppColors.line),
        boxShadow: featured
            ? [
                BoxShadow(
                  color: const Color(0xFF06110F).withValues(alpha: 0.24),
                  blurRadius: 60,
                  spreadRadius: -10,
                  offset: const Offset(0, 30),
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.name,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: fg,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: plan.price,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 44,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                            height: 1.1,
                            color: fg,
                          ),
                        ),
                        TextSpan(
                          text: '/month',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: fg.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    plan.note,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: featured
                          ? Colors.white.withValues(alpha: 0.55)
                          : AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 22),
                  for (final item in plan.features)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: SiteCheckLine(item, onDark: featured),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: SiteButton(
                  label: plan.cta,
                  kind: featured ? SiteButtonKind.light : SiteButtonKind.ghost,
                  onTap: nav.openApp,
                  expand: true,
                ),
              ),
            ],
          ),
          if (featured)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.lime.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'MOST POPULAR',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    color: AppColors.lime,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class SiteCompareTable extends StatelessWidget {
  const SiteCompareTable({super.key, required this.rows});

  final List<SiteCompareRow> rows;

  @override
  Widget build(BuildContext context) {
    final col = Site.width(context) < 420 ? 74.0 : 108.0;
    final tint = AppColors.green.withValues(alpha: 0.035);

    Widget cell(String value, {bool premium = false}) {
      if (value == 'yes') {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.check_circle_rounded, size: 18, color: AppColors.green),
          ],
        );
      }
      if (value == 'no') {
        return const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.remove_rounded, size: 17, color: AppColors.muted),
          ],
        );
      }
      return Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          height: 1.3,
          color: premium ? AppColors.greenDeep : AppColors.inkSoft,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            color: AppColors.bg,
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'What you get',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: AppColors.muted,
                    ),
                  ),
                ),
                SizedBox(
                  width: col,
                  child: const Text(
                    'General',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                SizedBox(
                  width: col,
                  child: const Text(
                    'Premium',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.greenDeep,
                    ),
                  ),
                ),
              ],
            ),
          ),
          for (final row in rows)
            IntrinsicHeight(
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.line)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 13,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            row.label,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13.5,
                              height: 1.4,
                              color: AppColors.inkSoft,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: col,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      child: cell(row.general),
                    ),
                    Container(
                      width: col,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      color: tint,
                      child: cell(row.premium, premium: true),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- faq

class SiteFaqList extends StatelessWidget {
  const SiteFaqList({super.key, required this.items});

  final List<SiteFaqItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SiteFaqTile(item),
          ),
      ],
    );
  }
}

class SiteFaqGroups extends StatelessWidget {
  const SiteFaqGroups({super.key, required this.groups});

  final List<SiteFaqGroup> groups;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < groups.length; i++) ...[
          if (i > 0) const SizedBox(height: 34),
          Text(
            groups[i].title.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.3,
              color: AppColors.greenDeep,
            ),
          ),
          const SizedBox(height: 12),
          SiteFaqList(items: groups[i].items),
        ],
      ],
    );
  }
}

class SiteFaqTile extends StatefulWidget {
  const SiteFaqTile(this.item, {super.key});

  final SiteFaqItem item;

  @override
  State<SiteFaqTile> createState() => _SiteFaqTileState();
}

class _SiteFaqTileState extends State<SiteFaqTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => setState(() => _open = !_open),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.item.question,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    AnimatedRotation(
                      turns: _open ? 0.125 : 0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      child: const Icon(
                        Icons.add_rounded,
                        size: 20,
                        color: AppColors.greenDeep,
                      ),
                    ),
                  ],
                ),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 220),
                  sizeCurve: Curves.easeInOut,
                  crossFadeState: _open
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: const SizedBox(width: double.infinity),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 10, right: 26),
                    child: Text(
                      widget.item.answer,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        height: 1.55,
                        color: AppColors.inkSoft,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- cta

class SiteCtaBand extends StatelessWidget {
  const SiteCtaBand({super.key});

  @override
  Widget build(BuildContext context) {
    final wide = Site.wide(context);
    final radius = wide ? 32.0 : 26.0;
    final nav = SiteNavScope.of(context);
    return SiteWrap(
      child: Padding(
        padding: EdgeInsets.only(
          top: wide ? 10 : 0,
          bottom: wide ? 96 : 64,
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.nightTop, Color(0xFF123B29)],
            ),
            borderRadius: BorderRadius.circular(radius),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF06110F).withValues(alpha: 0.26),
                blurRadius: 80,
                offset: const Offset(0, 36),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Stack(
              children: [
                Positioned(
                  top: -130,
                  right: -70,
                  child: IgnorePointer(
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.lime.withValues(alpha: 0.16),
                            Colors.transparent,
                          ],
                          stops: const [0, 0.5],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(wide ? 48 : 28),
                  child: wide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Expanded(child: _CtaCopy()),
                            const SizedBox(width: 32),
                            _CtaActions(openApp: nav.openApp),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _CtaCopy(),
                            const SizedBox(height: 22),
                            _CtaActions(
                              openApp: nav.openApp,
                              stacked: true,
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CtaCopy extends StatelessWidget {
  const _CtaCopy();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your next workout is already waiting.',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: Site.ctaSize(context),
            fontWeight: FontWeight.w800,
            height: 1.15,
            letterSpacing: -0.4,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Text(
            "Open the app and check off today's first exercise in under a minute.",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              height: 1.55,
              color: Colors.white.withValues(alpha: 0.62),
            ),
          ),
        ),
      ],
    );
  }
}

class _CtaActions extends StatelessWidget {
  const _CtaActions({required this.openApp, this.stacked = false});

  final VoidCallback openApp;
  final bool stacked;

  @override
  Widget build(BuildContext context) {
    return SiteButton(
      label: 'Open the app',
      kind: SiteButtonKind.light,
      onTap: openApp,
      expand: stacked,
    );
  }
}