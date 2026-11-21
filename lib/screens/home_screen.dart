import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../theme/app_theme.dart';
import '../ui/layout.dart';
import '../widgets/add_workout_sheet.dart';
import '../widgets/common.dart';
import '../widgets/energy.dart';
import 'nutritionist_screen.dart';
import 'stopwatch_screen.dart';
import 'subscription_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onTab});

  final ValueChanged<int>? onTab;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _ambient = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 18),
  )..repeat();

  @override
  void dispose() {
    _ambient.dispose();
    super.dispose();
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    if (AppLayout.isDesktop(context)) return _desktop(context, state);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
          children: [
            _Header(state: state, greeting: _greeting),
            const SizedBox(height: 16),
            _HeroCard(state: state, ambient: _ambient),
            const SizedBox(height: 14),
            _quickActions(context, state),
            const SizedBox(height: 22),
            SectionHeader(
              title: 'Today\'s workout',
              action: 'Add',
              onAction: () => showAddWorkoutSheet(context),
            ),
            const SizedBox(height: 10),
            ..._exerciseTiles(context, state),
            const SizedBox(height: 14),
            _WeeklyCard(state: state),
            const SizedBox(height: 14),
            _premiumSlot(context, state),
          ],
        ),
      ),
    );
  }

  Widget _desktop(BuildContext context, AppState state) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppLayout.contentMax),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 24, 32, 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Header(state: state, greeting: _greeting),
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 250,
                                child: _HeroCard(state: state, ambient: _ambient),
                              ),
                              const SizedBox(height: 16),
                              _quickActions(context, state),
                              const SizedBox(height: 28),
                              SectionHeader(
                                title: 'Today\'s workout',
                                action: 'Add',
                                onAction: () => showAddWorkoutSheet(context),
                              ),
                              const SizedBox(height: 12),
                              ..._exerciseTiles(context, state),
                            ],
                          ),
                        ),
                        const SizedBox(width: 26),
                        SizedBox(
                          width: 356,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _WeeklyCard(state: state),
                              const SizedBox(height: 16),
                              _premiumSlot(context, state),
                              const SizedBox(height: 16),
                              _CoachCard(
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => const NutritionistScreen()),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _GoalsPreview(
                                state: state,
                                onViewAll: () => widget.onTab?.call(3),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _quickActions(BuildContext context, AppState state) {
    return _QuickActions(
      onStopwatch: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const StopwatchScreen()),
      ),
      onVideos: () => widget.onTab?.call(2),
      onGoals: () => widget.onTab?.call(3),
      onAdd: () => showAddWorkoutSheet(context),
    );
  }

  List<Widget> _exerciseTiles(BuildContext context, AppState state) {
    return List.generate(state.todayWorkout.length, (i) {
      final e = state.todayWorkout[i];
      return SlideFadeIn(
        delay: Duration(milliseconds: 40 * i),
        duration: const Duration(milliseconds: 420),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Dismissible(
            key: ValueKey('${e.name}-$i'),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.danger, size: 20),
            ),
            onDismissed: (_) => state.removeExercise(i),
            child: _ExerciseTile(
              exercise: e,
              onTap: () => state.toggleExercise(i),
            ),
          ),
        ),
      );
    });
  }

  Widget _premiumSlot(BuildContext context, AppState state) {
    if (state.isPremium) return _PremiumActive();
    return _PremiumBanner(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.state, required this.greeting});

  final AppState state;
  final String greeting;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1D4A33), Color(0xFF0D2A1D)],
            ),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: AppShadows.soft,
          ),
          child: Center(
            child: Text(
              state.name.isEmpty ? 'A' : state.name.characters.first.toUpperCase(),
              style: AppText.h3.copyWith(color: Colors.white, fontSize: 17),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$greeting, ${state.name}',
                  style: AppText.h3.copyWith(fontSize: 16)),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.verified_rounded, size: 12, color: AppColors.green),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      state.gym,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.tiny.copyWith(fontSize: 10),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: state.isPremium
                          ? AppColors.green.withValues(alpha: 0.12)
                          : AppColors.surfaceSunken,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      state.isPremium ? 'PREMIUM' : 'GENERAL',
                      style: AppText.tiny.copyWith(
                        fontSize: 7.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: state.isPremium ? AppColors.greenDeep : AppColors.muted,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        AppIconButton(
          icon: Icons.notifications_none_rounded,
          badge: true,
          onTap: () => _showNotifications(context),
        ),
      ],
    );
  }

  void _showNotifications(BuildContext context) {
    showAppSheet(
      context,
      Padding(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text('Notifications', style: AppText.h2.copyWith(fontSize: 19)),
                const Spacer(),
                Text('2 new', style: AppText.tiny.copyWith(color: AppColors.greenDeep)),
              ],
            ),
            const SizedBox(height: 16),
            _Notification(
              icon: Icons.fitness_center_rounded,
              title: 'Leg day is waiting',
              body: 'Your 6-day streak is on the line. 24 minutes to go.',
              time: 'Now',
              unread: true,
            ),
            _Notification(
              icon: Icons.local_fire_department_rounded,
              title: 'Protein check-in',
              body: 'You are 32g short of today\'s target.',
              time: '2h',
              unread: true,
            ),
            _Notification(
              icon: Icons.card_membership_rounded,
              title: 'Renewal reminder',
              body: 'General plan renews on Dec 19.',
              time: '1d',
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _Notification extends StatelessWidget {
  const _Notification({
    required this.icon,
    required this.title,
    required this.body,
    required this.time,
    this.unread = false,
  });

  final IconData icon;
  final String title;
  final String body;
  final String time;
  final bool unread;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, size: 18, color: AppColors.greenDeep),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: AppText.bodyStrong.copyWith(fontSize: 13)),
                    if (unread) ...[
                      const SizedBox(width: 6),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                    const Spacer(),
                    Text(time, style: AppText.tiny.copyWith(fontSize: 9.5)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(body, style: AppText.small.copyWith(fontSize: 11.5, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.state, required this.ambient});

  final AppState state;
  final AnimationController ambient;

  @override
  Widget build(BuildContext context) {
    final done = state.completedToday;
    final total = state.todayWorkout.length;

    return Container(
      height: 210,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B211A), Color(0xFF123B29), Color(0xFF081812)],
        ),
        boxShadow: AppShadows.float,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: [
            Positioned(
              right: -30,
              top: -40,
              child: SizedBox(
                width: 240,
                height: 240,
                child: ParticleField(animation: ambient, count: 16, seed: 3, opacity: 0.5),
              ),
            ),
            Positioned(
              right: -40,
              bottom: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.green.withValues(alpha: 0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Text(
                            'TODAY  ·  ${_weekday()}',
                            style: AppText.tiny.copyWith(
                              color: AppColors.lime,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Push & core',
                          style: AppText.h1.copyWith(
                              color: Colors.white, fontSize: 26),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          done == total
                              ? 'Workout complete — great work!'
                              : '$done of $total done · ${state.todayMinutes} min plan',
                          style: AppText.small.copyWith(
                            color: Colors.white.withValues(alpha: 0.55),
                            fontSize: 11,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            _miniStat(Icons.local_fire_department_rounded,
                                '${state.streak}', 'streak'),
                            const SizedBox(width: 16),
                            _miniStat(Icons.timer_outlined,
                                '${state.todayMinutes}', 'min'),
                            const SizedBox(width: 16),
                            _miniStat(Icons.bolt_rounded, '420', 'kcal'),
                          ],
                        ),
                        const SizedBox(height: 14),
                        AppButton(
                          label: done == total ? 'Bonus round' : 'Start workout',
                          height: 44,
                          expanded: false,
                          trailing: false,
                          icon: Icons.play_arrow_rounded,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const StopwatchScreen()),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  ProgressRing(
                    value: state.todayProgress,
                    size: 108,
                    stroke: 9,
                    center: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$done/$total',
                          style: AppText.h2.copyWith(
                              color: Colors.white, fontSize: 21),
                        ),
                        Text('completed',
                            style: AppText.tiny.copyWith(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 8)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.lime),
        const SizedBox(width: 4),
        Text(value,
            style: AppText.label.copyWith(
                color: Colors.white, fontSize: 12, letterSpacing: 0)),
        const SizedBox(width: 3),
        Text(label,
            style: AppText.tiny.copyWith(
                color: Colors.white.withValues(alpha: 0.45), fontSize: 8.5)),
      ],
    );
  }

  String _weekday() {
    const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return days[DateTime.now().weekday - 1];
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.onStopwatch,
    required this.onVideos,
    required this.onGoals,
    required this.onAdd,
  });

  final VoidCallback onStopwatch;
  final VoidCallback onVideos;
  final VoidCallback onGoals;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.timer_rounded, 'Stopwatch', onStopwatch, const Color(0xFF1D6B52)),
      (Icons.play_circle_fill_rounded, 'Videos', onVideos, const Color(0xFF234E7D)),
      (Icons.flag_rounded, 'Goals', onGoals, const Color(0xFFB9761E)),
      (Icons.add_circle_rounded, 'Add', onAdd, const Color(0xFF3F7A20)),
    ];
    return Row(
      children: List.generate(items.length, (i) {
        final it = items[i];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == items.length - 1 ? 0 : 9),
            child: Pressable(
              onTap: it.$3,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.line),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: it.$4.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(it.$1, size: 17, color: it.$4),
                    ),
                    const SizedBox(height: 7),
                    Text(it.$2,
                        style: AppText.tiny.copyWith(
                            fontSize: 9, color: AppColors.inkSoft,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  const _ExerciseTile({required this.exercise, required this.onTap});

  final Exercise exercise;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: exercise.done ? AppColors.green.withValues(alpha: 0.06) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: exercise.done ? AppColors.green.withValues(alpha: 0.35) : AppColors.line,
          ),
        ),
        child: Row(
          children: [
            AnimatedOpacity(
              duration: const Duration(milliseconds: 260),
              opacity: exercise.done ? 0.5 : 1,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.surfaceSunken,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(exercise.icon, size: 19, color: AppColors.inkSoft),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: AppText.bodyStrong.copyWith(
                      fontSize: 13.5,
                      color: exercise.done ? AppColors.muted : AppColors.ink,
                      decoration: exercise.done ? TextDecoration.lineThrough : null,
                      decorationColor: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${exercise.sets} sets × ${exercise.reps > 0 ? exercise.reps : '—'}'
                    '${exercise.weight > 0 ? ' · ${exercise.weight.toStringAsFixed(exercise.weight % 1 == 0 ? 0 : 1)} kg' : ''}'
                    ' · ${exercise.minutes} min',
                    style: AppText.tiny.copyWith(fontSize: 10),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            AnimatedCheckbox(checked: exercise.done),
          ],
        ),
      ),
    );
  }
}

class _WeeklyCard extends StatelessWidget {
  const _WeeklyCard({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final maxVal = state.weeklyMinutes.reduce(math.max);
    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              Text('This week', style: AppText.h3.copyWith(fontSize: 16)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.trending_up_rounded,
                        size: 12, color: AppColors.greenDeep),
                    const SizedBox(width: 4),
                    Text('+18%',
                        style: AppText.tiny.copyWith(
                            fontSize: 9, color: AppColors.greenDeep,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${state.weeklyMinutes.fold<int>(0, (a, b) => a + b.round())}',
                  style: AppText.h1.copyWith(fontSize: 26)),
              const SizedBox(width: 5),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('active minutes',
                    style: AppText.tiny.copyWith(fontSize: 10)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 82,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(state.weeklyMinutes.length, (i) {
                final v = state.weeklyMinutes[i];
                final today = i == DateTime.now().weekday - 1;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: v / maxVal),
                          duration: Duration(milliseconds: 700 + i * 60),
                          curve: Curves.easeOutCubic,
                          builder: (context, h, _) => Container(
                            height: 4 + h * 56,
                            decoration: BoxDecoration(
                              gradient: today
                                  ? AppColors.greenGradient
                                  : LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        AppColors.green.withValues(alpha: 0.35),
                                        AppColors.green.withValues(alpha: 0.12),
                                      ],
                                    ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          const ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i],
                          style: AppText.tiny.copyWith(
                            fontSize: 8.5,
                            color: today ? AppColors.greenDeep : AppColors.muted,
                            fontWeight: today ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumBanner extends StatelessWidget {
  const _PremiumBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.green.withValues(alpha: 0.28),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('50% OFF FIRST MONTH',
                        style: AppText.tiny.copyWith(
                            color: Colors.white,
                            fontSize: 7.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.7)),
                  ),
                  const SizedBox(height: 8),
                  Text('Level up with a\npersonal coach',
                      style: AppText.h3.copyWith(
                          color: Colors.white, fontSize: 16, height: 1.2)),
                  const SizedBox(height: 4),
                  Text('Live sessions, meal plans and home training.',
                      style: AppText.tiny.copyWith(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 9.5)),
                ],
              ),
            ),
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.arrow_forward_rounded,
                  color: AppColors.greenDeep, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumActive extends StatelessWidget {
  const _PremiumActive();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navy.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.navy.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.navy.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.verified_rounded, size: 19, color: AppColors.navy),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Premium is active', style: AppText.bodyStrong.copyWith(fontSize: 13)),
                Text('2 coaching sessions left this month.',
                    style: AppText.tiny.copyWith(fontSize: 9.5)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.muted),
        ],
      ),
    );
  }
}

class _CoachCard extends StatelessWidget {
  const _CoachCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF234E7D), Color(0xFF16365C)],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: 0.24),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.support_agent_rounded,
                      size: 20, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Ask your coach',
                      style: AppText.h3.copyWith(color: Colors.white, fontSize: 15)),
                ),
                const Icon(Icons.arrow_forward_rounded,
                    size: 18, color: Colors.white70),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Nutrition, recovery and training questions answered in seconds.',
              style: AppText.small.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 10.5,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalsPreview extends StatelessWidget {
  const _GoalsPreview({required this.state, required this.onViewAll});

  final AppState state;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final goals = state.goals.take(3).toList();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Goals', style: AppText.h3.copyWith(fontSize: 16)),
              const Spacer(),
              GestureDetector(
                onTap: onViewAll,
                behavior: HitTestBehavior.opaque,
                child: Text('View all',
                    style: AppText.tiny.copyWith(
                        fontSize: 10, color: AppColors.greenDeep)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (goals.isEmpty)
            Text('No goals yet — add one from the Goals tab.',
                style: AppText.small.copyWith(fontSize: 11))
          else
            for (var i = 0; i < goals.length; i++) ...[
              _GoalRow(goal: goals[i]),
              if (i != goals.length - 1) const SizedBox(height: 14),
            ],
        ],
      ),
    );
  }
}

class _GoalRow extends StatelessWidget {
  const _GoalRow({required this.goal});

  final FitnessGoal goal;

  @override
  Widget build(BuildContext context) {
    final span = goal.target - goal.start;
    final value = span == 0
        ? 0.0
        : ((goal.current - goal.start) / span).clamp(0.0, 1.0).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(goal.icon, size: 14, color: goal.color),
            const SizedBox(width: 7),
            Expanded(
              child: Text(goal.title,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.label.copyWith(fontSize: 11)),
            ),
            Text(
              '${_short(goal.current)}/${_short(goal.target)} ${goal.unit}',
              style: AppText.tiny.copyWith(fontSize: 9),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 5,
            backgroundColor: AppColors.surfaceSunken,
            valueColor: AlwaysStoppedAnimation(goal.color),
          ),
        ),
      ],
    );
  }

  String _short(double v) => v == v.roundToDouble() ? '${v.round()}' : v.toStringAsFixed(1);
}
