import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/brand.dart';
import '../widgets/circular_reveal_route.dart';
import '../widgets/energy.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _main = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 5200),
  );
  late final AnimationController _ambient = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  )..repeat();
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1900),
  )..repeat(reverse: true);

  bool _leaving = false;

  Animation<double> _at(double begin, double end, [Curve curve = Curves.easeOutCubic]) =>
      CurvedAnimation(
        parent: _main,
        curve: Interval(begin, end, curve: curve),
      );

  @override
  void initState() {
    super.initState();
    _main.forward();
    _main.addStatusListener((status) {
      if (status == AnimationStatus.completed) _goNext();
    });
    _main.addListener(() => setState(() {}));
  }

  void _goNext() {
    if (!mounted || _leaving) return;
    _leaving = true;
    Navigator.of(context).pushReplacement(
      CircularRevealRoute(
        builder: (_) => const OnboardingScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _main.dispose();
    _ambient.dispose();
    _pulse.dispose();
    super.dispose();
  }

  String get _status {
    if (_main.value < 0.35) return 'SYNCING YOUR PROGRAM';
    if (_main.value < 0.62) return 'WARMING UP';
    if (_main.value < 0.86) return 'ALMOST READY';
    return 'LET\'S MOVE';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final ringProgress = _at(0.04, 0.34, Curves.easeInOutCubic).value;
    final markProgress = _at(0.24, 0.52, Curves.elasticOut).value;
    final orbitFade = _at(0.3, 0.62).value;
    final haloOpacity = _at(0.2, 0.5).value;
    final progress = _at(0.08, 0.93, Curves.easeInOutCubic).value;

    return Scaffold(
      backgroundColor: AppColors.nightTop,
      body: GestureDetector(
        onTap: () {
          if (_main.value > 0.45) _goNext();
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Ambient layers
            AuroraBackground(animation: _ambient),
            ParticleField(animation: _ambient, count: 52, seed: 11),
            IgnorePointer(
              child: Center(
                child: Opacity(
                  opacity: orbitFade * 0.9,
                  child: SizedBox(
                    width: size.width * 0.95,
                    height: size.width * 0.95,
                    child: FittedBox(
                      child: OrbitRings(
                        animation: _ambient,
                        size: 360,
                        ringProgress: orbitFade,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Diagonal light sweep
            IgnorePointer(
              child: AnimatedBuilder(
                animation: _ambient,
                builder: (context, _) => CustomPaint(
                  painter: _SweepPainter(_ambient.value, haloOpacity * 0.5),
                  size: Size.infinite,
                ),
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26),
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    // Logo cluster
                    SizedBox(
                      height: size.width * 0.62,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Halo
                          Opacity(
                            opacity: haloOpacity,
                            child: AnimatedBuilder(
                              animation: _pulse,
                              builder: (context, _) => Container(
                                width: size.width * 0.52 * (0.94 + _pulse.value * 0.12),
                                height: size.width * 0.52 * (0.94 + _pulse.value * 0.12),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      AppColors.green.withValues(alpha: 0.20 + _pulse.value * 0.10),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Shockwaves
                          if (_main.value > 0.28)
                            ...List.generate(2, (i) {
                              final local = ((_main.value - 0.28) * 2.4 - i * 0.35).clamp(0.0, 1.0);
                              return Opacity(
                                opacity: (1 - local) * 0.5,
                                child: Container(
                                  width: 110 + local * 190,
                                  height: 110 + local * 190,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.lime.withValues(alpha: 0.55),
                                      width: 1.2,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          BrandMark(
                            size: 118,
                            ringProgress: ringProgress,
                            markProgress: markProgress,
                            ringColor: Colors.white,
                            markColor: AppColors.greenBright,
                            glow: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Wordmark, letter by letter
                    _StaggeredWordmark(animation: _main),
                    const SizedBox(height: 18),
                    // Tagline
                    Opacity(
                      opacity: _at(0.56, 0.76).value,
                      child: Transform.translate(
                        offset: Offset(0, 18 * (1 - _at(0.56, 0.76).value)),
                        child: Text(
                          'STRONGER  EVERY  DAY',
                          style: AppText.label.copyWith(
                            color: Colors.white.withValues(alpha: 0.62),
                            fontSize: 11,
                            letterSpacing: 4.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 34),
                    // Feature row
                    _SplashFeatures(animation: _at(0.62, 0.9)),
                    const Spacer(flex: 3),

                    // Progress
                    Opacity(
                      opacity: _at(0.12, 0.3).value,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: AppColors.greenBright,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _status,
                                    style: AppText.tiny.copyWith(
                                      color: Colors.white.withValues(alpha: 0.55),
                                      letterSpacing: 1.6,
                                      fontSize: 9.5,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '${(progress * 100).round()}%',
                                style: AppText.tiny.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(9),
                            child: Stack(
                              children: [
                                Container(
                                  height: 4,
                                  color: Colors.white.withValues(alpha: 0.10),
                                ),
                                FractionallySizedBox(
                                  widthFactor: progress,
                                  child: Container(
                                    height: 4,
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [AppColors.lime, AppColors.greenBright],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Skip
            Positioned(
              top: MediaQuery.paddingOf(context).top + 12,
              right: 20,
              child: Opacity(
                opacity: _at(0.5, 0.7).value,
                child: TextButton(
                  onPressed: _goNext,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white.withValues(alpha: 0.85),
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Text(
                    'Skip',
                    style: AppText.label.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 11,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashFeatures extends StatelessWidget {
  const _SplashFeatures({required this.animation});

  final Animation<double> animation;

  static const _items = [
    (Icons.fitness_center_rounded, 'Training'),
    (Icons.restaurant_rounded, 'Nutrition'),
    (Icons.psychology_rounded, 'Coaching'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_items.length, (i) {
        final v = Interval(
          i * 0.12,
          0.55 + i * 0.12,
          curve: Curves.easeOutCubic,
        ).transform(animation.value.clamp(0.0, 1.0));
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Opacity(
            opacity: v,
            child: Transform.translate(
              offset: Offset(0, 14 * (1 - v)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_items[i].$1, size: 14, color: AppColors.lime.withValues(alpha: 0.85)),
                  const SizedBox(width: 6),
                  Text(
                    _items[i].$2,
                    style: AppText.small.copyWith(
                      color: Colors.white.withValues(alpha: 0.72),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _StaggeredWordmark extends StatelessWidget {
  const _StaggeredWordmark({required this.animation});

  final AnimationController animation;

  @override
  Widget build(BuildContext context) {
    const left = 'MYFIT';
    const right = 'WELLNESS';
    final letters = <(String, Color)>[
      ...left.split('').map((l) => (l, AppColors.greenBright)),
      ...right.split('').map((l) => (l, Colors.white)),
    ];
    const style = TextStyle(
      fontFamily: 'Poppins',
      fontSize: 21,
      fontWeight: FontWeight.w800,
      letterSpacing: 2.0,
      height: 1,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(letters.length, (i) {
        final start = 0.36 + i * 0.022;
        final v = CurvedAnimation(
          parent: animation,
          curve: Interval(start, (start + 0.22).clamp(0.0, 1.0), curve: Curves.easeOutBack),
        ).value.clamp(0.0, 1.0);
        return Opacity(
          opacity: v.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 22 * (1 - v)),
            child: Transform.rotate(
              angle: -0.10 * (1 - v),
              child: Text(letters[i].$1, style: style.copyWith(color: letters[i].$2)),
            ),
          ),
        );
      }),
    );
  }
}

class _SweepPainter extends CustomPainter {
  _SweepPainter(this.t, this.opacity);

  final double t;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0.01) return;
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(-0.5);
    final x = (t * 2 - 0.5) * size.width * 1.6 - size.width / 2;
    final rect = Rect.fromLTWH(x, -size.height, 90, size.height * 2);
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.white.withValues(alpha: 0),
          Colors.white.withValues(alpha: 0.045 * opacity),
          Colors.white.withValues(alpha: 0),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SweepPainter old) => old.t != t;
}
