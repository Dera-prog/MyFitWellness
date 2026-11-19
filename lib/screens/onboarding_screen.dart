import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import '../widgets/brand.dart';
import '../widgets/circular_reveal_route.dart';
import '../widgets/common.dart';
import '../widgets/energy.dart';
import 'auth_screen.dart';

class _Ad {
  const _Ad({
    required this.image,
    required this.kicker,
    required this.lines,
    required this.accentWord,
    required this.subtitle,
    required this.highlights,
    required this.stat,
    required this.statLabel,
    required this.tint,
    required this.cta,
    required this.floaters,
  });

  final String image;
  final String kicker;
  final List<String> lines;
  final String accentWord;
  final String subtitle;
  final List<(IconData, String)> highlights;
  final String stat;
  final String statLabel;
  final Color tint;
  final String cta;
  final List<IconData> floaters;
}

const _ads = [
  _Ad(
    image: 'assets/images/onboard_track.jpg',
    kicker: '01  ·  TRACK EVERYTHING',
    lines: ['Every rep,', 'every second,', 'counted.'],
    accentWord: 'counted.',
    subtitle:
        'Log sets, reps and weight in seconds. Pair your Bluetooth stopwatch and let MyFitWellness do the maths.',
    highlights: [
      (Icons.timer_outlined, 'Bluetooth stopwatch sync'),
      (Icons.insights_rounded, 'Weekly progress analytics'),
      (Icons.notifications_active_outlined, 'Reminders that keep you honest'),
    ],
    stat: '12k',
    statLabel: 'athletes training',
    tint: AppColors.green,
    cta: 'Continue',
    floaters: [Icons.timer_rounded, Icons.show_chart_rounded, Icons.watch_rounded],
  ),
  _Ad(
    image: 'assets/images/onboard_food.jpg',
    kicker: '02  ·  FUEL RIGHT',
    lines: ['Nutrition that', 'keeps up with', 'your training.'],
    accentWord: 'training.',
    subtitle:
        'Personalised meal plans, macro breakdowns and a direct line to a nutritionist — all in one place.',
    highlights: [
      (Icons.restaurant_menu_rounded, 'Meal plans built for your goal'),
      (Icons.pie_chart_outline_rounded, 'Macro tracking made simple'),
      (Icons.chat_bubble_outline_rounded, 'Chat with your nutritionist'),
    ],
    stat: '98%',
    statLabel: 'stay on plan',
    tint: AppColors.lime,
    cta: 'Continue',
    floaters: [Icons.spa_rounded, Icons.egg_alt_rounded, Icons.local_dining_rounded],
  ),
  _Ad(
    image: 'assets/images/onboard_train.jpg',
    kicker: '03  ·  TRAIN SMARTER',
    lines: ['Real coaches.', 'Real progress.', 'On demand.'],
    accentWord: 'progress.',
    subtitle:
        'Live coaching, a trainer at your door and advanced programs. Premium unlocks the full team behind you.',
    highlights: [
      (Icons.video_camera_front_outlined, 'Live 1:1 coaching sessions'),
      (Icons.home_work_outlined, 'Trainer at your home'),
      (Icons.lock_open_rounded, 'Full premium video library'),
    ],
    stat: '4.9★',
    statLabel: 'coach rating',
    tint: AppColors.navy,
    cta: 'Get Started',
    floaters: [Icons.fitness_center_rounded, Icons.sports_gymnastics_rounded, Icons.bolt_rounded],
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  final PageController _page = PageController();
  late final AnimationController _auto = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 7),
  )..addStatusListener((s) {
      if (s == AnimationStatus.completed) _next();
    });
  late final AnimationController _content = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..forward();
  late final AnimationController _ambient = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 16),
  )..repeat();
  late final AnimationController _kb = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 18),
  )..repeat(reverse: true);

  int _index = 0;
  double _pageValue = 0;

  @override
  void initState() {
    super.initState();
    _auto.forward();
    _page.addListener(() {
      setState(() => _pageValue = _page.page ?? 0);
    });
  }

  void _next() {
    if (_index == _ads.length - 1) return;
    _page.nextPage(duration: const Duration(milliseconds: 700), curve: Curves.easeInOutCubic);
  }

  void _goToAuth({bool signUp = false}) {
    Navigator.of(context).pushReplacement(
      CircularRevealRoute(
        originColor: AppColors.nightTop,
        builder: (_) => AuthScreen(startOnSignUp: signUp),
      ),
    );
  }

  @override
  void dispose() {
    _page.dispose();
    _auto.dispose();
    _content.dispose();
    _ambient.dispose();
    _kb.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.nightTop,
        body: Stack(
          fit: StackFit.expand,
          children: [
            NotificationListener<ScrollNotification>(
              onNotification: (n) {
                if (n is ScrollStartNotification && n.dragDetails != null) {
                  _auto.stop();
                } else if (n is ScrollEndNotification) {
                  if (_index < _ads.length - 1) _auto.forward();
                }
                return false;
              },
              child: PageView.builder(
                controller: _page,
                physics: const BouncingScrollPhysics(),
                itemCount: _ads.length,
                onPageChanged: (i) {
                  setState(() => _index = i);
                  _content.forward(from: 0);
                  if (i < _ads.length - 1) {
                    _auto.forward(from: 0);
                  } else {
                    _auto.stop();
                  }
                },
                itemBuilder: (context, i) => _AdPage(
                  key: ValueKey(i),
                  ad: _ads[i],
                  index: i,
                  pageValue: _pageValue,
                  content: _content,
                  ambient: _ambient,
                  kenBurns: _kb,
                  onCta: i == _ads.length - 1
                      ? () => _goToAuth(signUp: true)
                      : _next,
                ),
              ),
            ),

            // Top chrome: brand + skip
            Positioned(
              top: MediaQuery.paddingOf(context).top + 14,
              left: 22,
              right: 20,
              child: Row(
                children: [
                  const BrandMark(size: 26, ringColor: Colors.white, markColor: AppColors.greenBright),
                  const SizedBox(width: 9),
                  const BrandWordmark(fontSize: 10.5, dark: true, letterSpacing: 1.5),
                  const Spacer(),
                  _SkipPill(onTap: () => _goToAuth()),
                ],
              ),
            ),

            // Indicators
            Positioned(
              left: 24,
              right: 24,
              bottom: MediaQuery.paddingOf(context).bottom + 26,
              child: AnimatedBuilder(
                animation: _auto,
                builder: (context, _) => Row(
                  children: List.generate(_ads.length, (i) {
                    final active = i == _index;
                    final done = i < _index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                      height: 4,
                      width: active ? 42 : 18,
                      margin: EdgeInsets.only(right: i == _ads.length - 1 ? 0 : 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(9),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: active
                                ? (i == _ads.length - 1 ? 1 : _auto.value)
                                : (done ? 1 : 0),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppColors.lime, AppColors.greenBright],
                                ),
                                borderRadius: BorderRadius.circular(9),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  })
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkipPill extends StatelessWidget {
  const _SkipPill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        ),
        child: Row(
          children: [
            Text(
              'Skip',
              style: AppText.label.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 11,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_forward_rounded,
                size: 13, color: Colors.white.withValues(alpha: 0.9)),
          ],
        ),
      ),
    );
  }
}

class _AdPage extends StatelessWidget {
  const _AdPage({
    super.key,
    required this.ad,
    required this.index,
    required this.pageValue,
    required this.content,
    required this.ambient,
    required this.kenBurns,
    required this.onCta,
  });

  final _Ad ad;
  final int index;
  final double pageValue;
  final AnimationController content;
  final AnimationController ambient;
  final AnimationController kenBurns;
  final VoidCallback onCta;

  double get _distance => (pageValue - index).clamp(-1.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final d = _distance;
    final depth = d.abs();

    return Stack(
      fit: StackFit.expand,
      children: [
        // Ken-burns photo with parallax
        Positioned.fill(
          child: Transform.translate(
            offset: Offset(-d * size.width * 0.18, 0),
            child: AnimatedBuilder(
              animation: kenBurns,
              builder: (context, child) {
                final t = Curves.easeInOut.transform(kenBurns.value);
                return Transform.scale(
                  scale: 1.12 + t * 0.10,
                  alignment: Alignment(-0.2 + t * 0.3, -0.1 + t * 0.2),
                  child: child,
                );
              },
              child: Image.asset(
                ad.image,
                fit: BoxFit.cover,
                width: size.width,
                height: size.height,
              ),
            ),
          ),
        ),

        // Color grade + scrim
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.52),
                  Colors.black.withValues(alpha: 0.18),
                  AppColors.nightTop.withValues(alpha: 0.92),
                  AppColors.nightTop,
                ],
                stops: const [0, 0.28, 0.62, 1],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.8, -0.6),
                radius: 1.1,
                colors: [
                  ad.tint.withValues(alpha: 0.26),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Floating glass icons
        ...List.generate(ad.floaters.length, (i) {
          final positions = [
            const Alignment(0.78, -0.62),
            const Alignment(-0.82, -0.32),
            const Alignment(0.62, 0.2),
          ];
          return Align(
            alignment: positions[i % positions.length],
            child: AnimatedBuilder(
              animation: ambient,
              builder: (context, child) {
                final t = ambient.value * 2 * math.pi + i * 2.1 + index;
                return Transform.translate(
                  offset: Offset(math.sin(t) * 9, math.cos(t * 0.8) * 14),
                  child: Transform.rotate(
                    angle: math.sin(t * 0.6) * 0.08,
                    child: Opacity(opacity: 0.55, child: child),
                  ),
                );
              },
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
                ),
                child: Icon(ad.floaters[i], size: 20, color: Colors.white.withValues(alpha: 0.85)),
              ),
            ),
          );
        }),

        // Ambient particles
        ParticleField(
          animation: ambient,
          count: 18,
          seed: 30 + index,
          color: ad.tint,
          opacity: 0.5,
        ),

        // Content
        SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(26, 0, 26, MediaQuery.paddingOf(context).bottom + 58),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Opacity(
                  opacity: (1 - depth * 0.7).clamp(0, 1),
                  child: Transform.translate(
                    offset: Offset(0, depth * 24),
                    child: _Kicker(ad: ad, content: content),
                  ),
                ),
                const SizedBox(height: 16),
                _Headline(ad: ad, content: content),
                const SizedBox(height: 14),
                _Reveal(
                  content: content,
                  start: 0.44,
                  end: 0.68,
                  offsetY: 18,
                  child: Text(
                    ad.subtitle,
                    style: AppText.body.copyWith(
                      color: Colors.white.withValues(alpha: 0.72),
                      fontSize: 13.5,
                      height: 1.55,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ...List.generate(ad.highlights.length, (i) {
                  return _Reveal(
                    content: content,
                    start: 0.55 + i * 0.055,
                    end: 0.80 + i * 0.05,
                    offsetY: 16,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: Row(
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: ad.tint.withValues(alpha: 0.22),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(ad.highlights[i].$1, size: 14, color: AppColors.lime),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Text(
                              ad.highlights[i].$2,
                              style: AppText.bodyStrong.copyWith(
                                color: Colors.white.withValues(alpha: 0.86),
                                fontSize: 12.8,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 18),
                _Reveal(
                  content: content,
                  start: 0.68,
                  end: 0.95,
                  offsetY: 24,
                  child: AppButton(
                    label: ad.cta,
                    height: 58,
                    onTap: onCta,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Kicker extends StatelessWidget {
  const _Kicker({required this.ad, required this.content});

  final _Ad ad;
  final AnimationController content;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: content,
      builder: (context, _) {
        final t = Curves.easeOutCubic
            .transform(Interval(0, 0.32).transform(content.value).clamp(0.0, 1.0));
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(-(1 - t) * 24, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _pulseDot(),
                      const SizedBox(width: 7),
                      Text(
                        ad.kicker,
                        style: AppText.tiny.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          letterSpacing: 1.2,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                  decoration: BoxDecoration(
                    color: ad.tint.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        ad.stat,
                        style: AppText.tiny.copyWith(
                          color: indexOnTint(ad.tint),
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        ad.statLabel,
                        style: AppText.tiny.copyWith(
                          color: indexOnTint(ad.tint).withValues(alpha: 0.7),
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _pulseDot() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.4, end: 1),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOut,
      builder: (context, v, _) => Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: AppColors.greenBright.withValues(alpha: v),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.greenBright.withValues(alpha: 0.6 * v),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }

  Color indexOnTint(Color tint) =>
      tint == AppColors.navy ? Colors.white : const Color(0xFF0B1B10);
}

class _Headline extends StatelessWidget {
  const _Headline({required this.ad, required this.content});

  final _Ad ad;
  final AnimationController content;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: content,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(ad.lines.length, (lineIndex) {
            final words = ad.lines[lineIndex].split(' ');
            return Row(
              children: [
                for (var w = 0; w < words.length; w++) ...[
                  _word(words[w], lineIndex * 2 + w),
                  if (w != words.length - 1) const SizedBox(width: 8),
                ],
              ],
            );
          }),
        );
      },
    );
  }

  Widget _word(String word, int order) {
    final start = 0.08 + order * 0.055;
    final end = (start + 0.26).clamp(0.0, 1.0);
    final t = Curves.easeOutCubic
        .transform(Interval(start, end).transform(content.value).clamp(0.0, 1.0));
    final accent = word.replaceAll(',', '').replaceAll('.', '') ==
        ad.accentWord.replaceAll(',', '').replaceAll('.', '');

    return Opacity(
      opacity: t,
      child: Transform.translate(
        offset: Offset(0, (1 - t) * 34),
        child: Transform.rotate(
          angle: (1 - t) * 0.035,
          child: Text(
            word,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 34,
              fontWeight: FontWeight.w700,
              height: 1.12,
              letterSpacing: -0.9,
              color: accent ? AppColors.lime : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _Reveal extends StatelessWidget {
  const _Reveal({
    required this.content,
    required this.start,
    required this.end,
    required this.child,
    this.offsetY = 20,
  });

  final AnimationController content;
  final double start;
  final double end;
  final Widget child;
  final double offsetY;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: content,
      builder: (context, _) {
        final t = Curves.easeOutCubic
            .transform(Interval(start, end).transform(content.value).clamp(0.0, 1.0));
        return Opacity(
          opacity: t,
          child: Transform.translate(offset: Offset(0, (1 - t) * offsetY), child: child),
        );
      },
    );
  }
}
