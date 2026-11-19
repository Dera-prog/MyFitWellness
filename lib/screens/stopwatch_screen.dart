import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/energy.dart';

class StopwatchScreen extends StatefulWidget {
  const StopwatchScreen({super.key});

  @override
  State<StopwatchScreen> createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen>
    with TickerProviderStateMixin {
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  DateTime? _startedAt;
  Duration _base = Duration.zero;
  bool _running = false;
  bool _scanning = false;
  int _setNumber = 1;
  final List<Duration> _laps = [];

  late final AnimationController _ambient = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 10),
  )..repeat();

  @override
  void dispose() {
    _timer?.cancel();
    _ambient.dispose();
    super.dispose();
  }

  void _start() {
    setState(() {
      _running = true;
      _startedAt = DateTime.now();
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (_startedAt == null) return;
      setState(() {
        _elapsed = _base + DateTime.now().difference(_startedAt!);
      });
    });
  }

  void _pause() {
    _timer?.cancel();
    setState(() {
      _running = false;
      _base = _elapsed;
      _startedAt = null;
    });
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _running = false;
      _elapsed = Duration.zero;
      _base = Duration.zero;
      _startedAt = null;
      _laps.clear();
    });
  }

  void _lap() {
    if (_elapsed == Duration.zero) return;
    setState(() => _laps.insert(0, _elapsed));
  }

  void _finish() {
    if (_elapsed == Duration.zero) return;
    final logged = _setNumber;
    final time = _format(_elapsed, withHundredths: false);
    _reset();
    setState(() => _setNumber = logged + 1);
    appToast(context, 'Set $logged logged · $time', icon: Icons.check_circle_rounded);
  }

  String _format(Duration d, {bool withHundredths = true}) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final cs = (d.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(2, '0');
    return withHundredths ? '$m:$s.$cs' : '$m:$s';
  }

  Future<void> _pair() async {
    final state = AppScope.of(context);
    setState(() => _scanning = true);
    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;
    state.pairStopwatch();
    setState(() => _scanning = false);
    appToast(context, 'FitWatch S2 connected', icon: Icons.bluetooth_connected_rounded);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final progress = (_elapsed.inMilliseconds % 60000) / 60000;

    return Scaffold(
      backgroundColor: AppColors.nightTop,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0A1E18), Color(0xFF04100C)],
              ),
            ),
          ),
          AuroraBackground(
            animation: _ambient,
            opacity: 0.6,
            colors: const [Color(0xFF2E8B57), Color(0xFF1E4E79), Color(0xFFC8F74A)],
          ),
          ParticleField(animation: _ambient, count: 24, opacity: 0.4, seed: 5),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: [
                      AppIconButton(
                        icon: Icons.arrow_back_rounded,
                        dark: true,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Stopwatch',
                              style: AppText.h3.copyWith(color: Colors.white, fontSize: 18)),
                          Text(_running ? 'Session running' : 'Ready when you are',
                              style: AppText.tiny.copyWith(
                                  color: Colors.white.withValues(alpha: 0.45),
                                  fontSize: 9.5)),
                        ],
                      ),
                      const Spacer(),
                      AppIconButton(
                        icon: state.stopwatchPaired
                            ? Icons.bluetooth_connected_rounded
                            : Icons.bluetooth_rounded,
                        dark: true,
                        onTap: _pair,
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Dial
                SizedBox(
                  width: 300,
                  height: 300,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _ambient,
                        builder: (context, _) => CustomPaint(
                          size: const Size.square(300),
                          painter: _DialPainter(
                            progress: progress,
                            running: _running,
                            t: _ambient.value,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.timer_rounded,
                                  size: 14, color: AppColors.lime),
                              const SizedBox(width: 5),
                              Text(
                                _running ? 'ACTIVE' : 'PAUSED',
                                style: AppText.tiny.copyWith(
                                  color: AppColors.lime,
                                  fontSize: 9,
                                  letterSpacing: 1.6,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _format(_elapsed),
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 52,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -1,
                              height: 1,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text('SET $_setNumber · BENCH PRESS',
                              style: AppText.tiny.copyWith(
                                color: Colors.white.withValues(alpha: 0.4),
                                fontSize: 8.5,
                                letterSpacing: 1.4,
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _stat('${_laps.length}', 'laps'),
                    Container(
                      width: 1,
                      height: 26,
                      margin: const EdgeInsets.symmetric(horizontal: 22),
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                    _stat(
                      _laps.isEmpty
                          ? '—'
                          : _format(Duration(
                              milliseconds: (_laps.first.inMilliseconds / _laps.length).round())),
                      'avg split',
                    ),
                    Container(
                      width: 1,
                      height: 26,
                      margin: const EdgeInsets.symmetric(horizontal: 22),
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                    _stat(_running || _elapsed > Duration.zero ? 'LIVE' : 'IDLE', 'status'),
                  ],
                ),
                const Spacer(),
                // Controls
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  child: Row(
                    children: [
                      _roundAction(
                        icon: _elapsed == Duration.zero ? Icons.refresh_rounded : Icons.stop_rounded,
                        label: _elapsed == Duration.zero ? 'Reset' : 'Finish',
                        onTap: _elapsed == Duration.zero ? _reset : _finish,
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: AppButton(
                          label: _running ? 'Pause' : (_elapsed == Duration.zero ? 'Start set' : 'Resume'),
                          height: 62,
                          trailing: false,
                          icon: _running ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          onTap: _running ? _pause : _start,
                        ),
                      ),
                      const SizedBox(width: 18),
                      _roundAction(
                        icon: Icons.flag_outlined,
                        label: 'Lap',
                        onTap: _lap,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                // Bluetooth card
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      20, 0, 20, MediaQuery.paddingOf(context).bottom + 16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.greenBright.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            state.stopwatchPaired
                                ? Icons.watch_rounded
                                : Icons.bluetooth_searching_rounded,
                            size: 18,
                            color: AppColors.lime,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.stopwatchPaired
                                    ? 'FitWatch S2 · paired'
                                    : _scanning
                                        ? 'Scanning for devices…'
                                        : 'Pair your stopwatch',
                                style: AppText.bodyStrong.copyWith(
                                    color: Colors.white, fontSize: 12.5),
                              ),
                              Text(
                                state.stopwatchPaired
                                    ? 'Times sync automatically to your log'
                                    : 'Bluetooth stopwatch for accurate set timing',
                                style: AppText.tiny.copyWith(
                                    color: Colors.white.withValues(alpha: 0.45),
                                    fontSize: 9),
                              ),
                            ],
                          ),
                        ),
                        if (!state.stopwatchPaired)
                          TextButton(
                            onPressed: _scanning ? null : _pair,
                            child: _scanning
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: AppColors.lime),
                                  )
                                : Text('Connect',
                                    style: AppText.label.copyWith(
                                        color: AppColors.lime, fontSize: 11)),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: AppText.h3.copyWith(color: Colors.white, fontSize: 16)),
        Text(label,
            style: AppText.tiny.copyWith(
                color: Colors.white.withValues(alpha: 0.4), fontSize: 8.5)),
      ],
    );
  }

  Widget _roundAction({required IconData icon, required String label, required VoidCallback onTap}) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.08),
              border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
            ),
            child: Icon(icon, size: 21, color: Colors.white.withValues(alpha: 0.85)),
          ),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: AppText.tiny.copyWith(
                color: Colors.white.withValues(alpha: 0.45), fontSize: 8.5)),
      ],
    );
  }
}

class _DialPainter extends CustomPainter {
  _DialPainter({required this.progress, required this.running, required this.t});

  final double progress;
  final bool running;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 14;

    // Glow
    if (running) {
      canvas.drawCircle(
        c,
        radius,
        Paint()
          ..color = AppColors.green.withValues(alpha: 0.10 + 0.05 * math.sin(t * 6.28))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 26),
      );
    }

    // Track
    canvas.drawCircle(
      c,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..color = Colors.white.withValues(alpha: 0.07),
    );

    // Progress
    final rect = Rect.fromCircle(center: c, radius: radius);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round
        ..shader = const SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: 3 * math.pi / 2,
          colors: [AppColors.green, AppColors.lime],
        ).createShader(rect),
    );

    // Ticks
    for (var i = 0; i < 60; i++) {
      final angle = i * math.pi * 2 / 60 - math.pi / 2;
      final major = i % 5 == 0;
      final r1 = radius - (major ? 20 : 16);
      final r2 = radius - 13;
      canvas.drawLine(
        Offset(c.dx + r1 * math.cos(angle), c.dy + r1 * math.sin(angle)),
        Offset(c.dx + r2 * math.cos(angle), c.dy + r2 * math.sin(angle)),
        Paint()
          ..strokeWidth = major ? 2 : 1
          ..strokeCap = StrokeCap.round
          ..color = Colors.white.withValues(alpha: major ? 0.35 : 0.14),
      );
    }

    // Progress head
    final angle = -math.pi / 2 + 2 * math.pi * progress;
    final head = Offset(c.dx + radius * math.cos(angle), c.dy + radius * math.sin(angle));
    canvas.drawCircle(
      head,
      8,
      Paint()
        ..color = AppColors.lime
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawCircle(head, 4.5, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _DialPainter old) =>
      old.progress != progress || old.running != running || old.t != t;
}
