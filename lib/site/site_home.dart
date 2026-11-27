import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'site_content.dart';
import 'site_sections.dart';
import 'site_shell.dart';
import 'site_widgets.dart';

class SiteHomeBody extends StatelessWidget {
  const SiteHomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _Hero(),
        SiteBand(
          child: SiteWrap(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SiteHeadWithLink(
                  eyebrow: 'Everything in one app',
                  title:
                      "Built for the days you show up — and the ones you almost don't.",
                  linkLabel: 'Explore the features',
                  page: SitePage.features,
                ),
                const SizedBox(height: 36),
                const SiteFeatureGrid(features: siteFeatures),
              ],
            ),
          ),
        ),
        SiteBand(
          alt: true,
          child: SiteWrap(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SiteHeadWithLink(
                  eyebrow: 'Three minutes to start',
                  title: 'From sign-up to your first checkmark.',
                  linkLabel: 'See the walkthrough',
                  page: SitePage.howItWorks,
                ),
                const SizedBox(height: 36),
                const SiteStepCards(steps: siteSteps),
              ],
            ),
          ),
        ),
        SiteBand(
          child: SiteWrap(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SiteHeadWithLink(
                  eyebrow: 'Plans',
                  title:
                      'Start simple. Upgrade when you want a coach in the loop.',
                  linkLabel: 'Compare plans',
                  page: SitePage.plans,
                ),
                const SizedBox(height: 36),
                const SitePlanGrid(plans: sitePlans),
              ],
            ),
          ),
        ),
        SiteBand(
          alt: true,
          child: SiteWrap(
            maxWidth: 860,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SiteHeadWithLink(
                  eyebrow: 'Questions',
                  title: 'The short answers.',
                  linkLabel: 'All questions',
                  page: SitePage.faq,
                ),
                const SizedBox(height: 30),
                const SiteFaqList(items: siteHomeFaqs),
              ],
            ),
          ),
        ),
        const SiteCtaBand(),
      ],
    );
  }
}

// ---------------------------------------------------------------- hero

class _Hero extends StatelessWidget {
  const _Hero();

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
          const Positioned(top: -190, right: -140, child: SiteGlow()),
          SiteWrap(
            child: Padding(
              padding: EdgeInsets.only(
                top: wide ? 56 : 34,
                bottom: wide ? 44 : 30,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (wide)
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(flex: 108, child: _HeroCopy()),
                        SizedBox(width: 48),
                        Expanded(
                          flex: 92,
                          child: Center(child: _HeroVisual()),
                        ),
                      ],
                    )
                  else ...[
                    const _HeroCopy(),
                    const SizedBox(height: 34),
                    const Center(child: _HeroVisual()),
                  ],
                  const _TrustStrip(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy();

  @override
  Widget build(BuildContext context) {
    final stacked = Site.width(context) < 560;
    final headline = Site.heroSize(context);
    final nav = SiteNavScope.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SiteEyebrow('Fitness that follows you'),
        const SizedBox(height: 18),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Text.rich(
            TextSpan(
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: headline,
                fontWeight: FontWeight.w800,
                height: 1.06,
                letterSpacing: -1.2,
                color: AppColors.ink,
              ),
              children: [
                const TextSpan(
                  text: 'Your gym, your plan, your progress — ',
                ),
                TextSpan(
                  text: 'in one place.',
                  style: TextStyle(
                    foreground: Paint()
                      ..shader = const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          AppColors.greenDeep,
                          AppColors.green,
                          Color(0xFF8BDC2E),
                        ],
                      ).createShader(const Rect.fromLTWH(0, 0, 520, 110)),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: const Text(
            "MyFitWellness turns a gym membership into a daily plan. Check off "
            "today's workout, keep the streak alive, hit your goals and ask a "
            'coach whenever you get stuck.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              height: 1.6,
              color: AppColors.inkSoft,
            ),
          ),
        ),
        const SizedBox(height: 26),
        SiteButton(
          label: 'See how it works',
          kind: SiteButtonKind.ghost,
          onTap: () => nav.open(SitePage.howItWorks),
          expand: stacked,
        ),
        const SizedBox(height: 24),
        const Wrap(
          spacing: 20,
          runSpacing: 8,
          children: [
            _DotPoint('Works on phone and desktop'),
            _DotPoint('No install, no card'),
            _DotPoint('Real progress saved'),
          ],
        ),
      ],
    );
  }
}

class _DotPoint extends StatelessWidget {
  const _DotPoint(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.green,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.55),
              width: 1.5,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12.5,
            color: AppColors.muted,
          ),
        ),
      ],
    );
  }
}

class _HeroVisual extends StatelessWidget {
  const _HeroVisual();

  @override
  Widget build(BuildContext context) {
    final width = Site.width(context);
    final phone = (width * 0.68).clamp(224.0, 300.0);
    final height = phone * 2.06;
    final chips = width >= 560;
    return SizedBox(
      width: phone,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          _Bobbing(
            offset: 5,
            child: Transform.rotate(
              angle: 0.026,
              child: _PhoneShot(width: phone),
            ),
          ),
          if (chips)
            Positioned(
              left: -120,
              top: height * 0.16,
              child: const _Bobbing(
                offset: 9,
                child: _FloatChip(
                  icon: Icons.local_fire_department_rounded,
                  title: '6-day streak',
                  subtitle: 'Keep it going',
                ),
              ),
            ),
          if (chips)
            Positioned(
              right: -70,
              bottom: height * 0.12,
              child: const _Bobbing(
                offset: 9,
                reverse: true,
                child: _FloatChip(
                  icon: Icons.gps_fixed_rounded,
                  title: 'Goal on track',
                  subtitle: '84 / 100 kg',
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PhoneShot extends StatelessWidget {
  const _PhoneShot({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    final pad = width * 0.045;
    return Container(
      width: width,
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1512),
        borderRadius: BorderRadius.circular(width * 0.145),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.30),
            blurRadius: 70,
            spreadRadius: -12,
            offset: const Offset(0, 34),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(width * 0.115),
        child: Image.asset(
          'assets/images/app_home.png',
          width: width - pad * 2,
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  }
}

class _FloatChip extends StatelessWidget {
  const _FloatChip({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.float,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 18, color: AppColors.greenDeep),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10.5,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Bobbing extends StatefulWidget {
  const _Bobbing({
    required this.child,
    this.offset = 8,
    this.reverse = false,
  });

  final Widget child;
  final double offset;
  final bool reverse;

  @override
  State<_Bobbing> createState() => _BobbingState();
}

class _BobbingState extends State<_Bobbing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_controller.value);
        final value = widget.reverse ? 1 - t : t;
        return Transform.translate(
          offset: Offset(0, -widget.offset * value),
          child: child,
        );
      },
    );
  }
}

class _TrustStrip extends StatelessWidget {
  const _TrustStrip();

  static const _clubs = [
    'Iron House Fitness',
    'Pulse Gym',
    'Vertex Athletic',
    'Harbor Strength',
  ];

  @override
  Widget build(BuildContext context) {
    final wide = Site.wide(context);
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: wide ? 46 : 36),
      padding: const EdgeInsets.only(top: 22),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: Wrap(
        spacing: 26,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text(
            'Trusted by members at',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: AppColors.muted,
            ),
          ),
          for (final club in _clubs)
            Text(
              club,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.inkSoft,
              ),
            ),
        ],
      ),
    );
  }
}