import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../theme/app_theme.dart';
import '../ui/layout.dart';
import '../widgets/add_workout_sheet.dart';
import '../widgets/common.dart';
import '../widgets/energy.dart';
import 'coaching_screen.dart';
import 'meal_plan_screen.dart';
import 'nutritionist_screen.dart';
import 'stopwatch_screen.dart';
import 'subscription_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onTab});

  final ValueChanged<int>? onTab;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
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

    switch (state.dashboardStage) {
      case DashboardStage.newUser:
        return _NewUserDashboard(
          state: state,
          greeting: _greeting,
          ambient: _ambient,
          onTab: widget.onTab,
        );
      case DashboardStage.premium:
        return _PremiumDashboard(
          state: state,
          greeting: _greeting,
          ambient: _ambient,
          onTab: widget.onTab,
        );
      case DashboardStage.general:
        break;
    }

    if (AppLayout.isDesktop(context)) return _desktop(context, state);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
          children: [
            _PreviewBanner(state: state),
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
            _TodayWorkoutTiles(state: state),
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
                    _PreviewBanner(state: state),
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
                                child: _HeroCard(
                                  state: state,
                                  ambient: _ambient,
                                ),
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
                              _TodayWorkoutTiles(state: state),
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
                                    builder: (_) => const NutritionistScreen(),
                                  ),
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
      onStopwatch: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const StopwatchScreen())),
      onVideos: () => widget.onTab?.call(2),
      onGoals: () => widget.onTab?.call(3),
      onAdd: () => showAddWorkoutSheet(context),
    );
  }

  Widget _premiumSlot(BuildContext context, AppState state) {
    if (state.isPremium) return _PremiumActive();
    return _PremiumBanner(
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const SubscriptionScreen())),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.state, required this.greeting});

  final AppState state;
  final String greeting;

  @override
  Widget build(BuildContext context) {
    final premiumView = state.dashboardStage == DashboardStage.premium;
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
              state.name.isEmpty
                  ? 'A'
                  : state.name.characters.first.toUpperCase(),
              style: AppText.h3.copyWith(color: Colors.white, fontSize: 17),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting, ${state.name}',
                style: AppText.h3.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(
                    Icons.verified_rounded,
                    size: 12,
                    color: AppColors.green,
                  ),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: premiumView
                          ? AppColors.green.withValues(alpha: 0.12)
                          : AppColors.surfaceSunken,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      premiumView ? 'PREMIUM' : 'GENERAL',
                      style: AppText.tiny.copyWith(
                        fontSize: 7.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: premiumView
                            ? AppColors.greenDeep
                            : AppColors.muted,
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
                Text(
                  '2 new',
                  style: AppText.tiny.copyWith(color: AppColors.greenDeep),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Notification(
              icon: Icons.fitness_center_rounded,
              title: 'Leg day is waiting',
              body: state.streak > 0
                  ? 'Your ${state.streak}-day streak is on the line. 24 minutes to go.'
                  : 'A 24-minute session today starts your streak.',
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
              body: state.planRenewsAt == null
                  ? 'No renewal scheduled on the ${state.isPremium ? 'Premium' : 'General'} plan.'
                  : '${state.isPremium ? 'Premium' : 'General'} plan renews on '
                      '${MaterialLocalizations.of(context).formatMediumDate(state.planRenewsAt!)}.',
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
                    Text(
                      title,
                      style: AppText.bodyStrong.copyWith(fontSize: 13),
                    ),
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
                Text(
                  body,
                  style: AppText.small.copyWith(fontSize: 11.5, height: 1.4),
                ),
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
    final empty = total == 0;
    final sets = state.todayWorkout.fold<int>(0, (a, e) => a + e.sets);

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
                child: ParticleField(
                  animation: ambient,
                  count: 16,
                  seed: 3,
                  opacity: 0.5,
                ),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
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
                          empty ? 'No workout yet' : 'Push & core',
                          style: AppText.h1.copyWith(
                            color: Colors.white,
                            fontSize: 26,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          empty
                              ? 'Add your first exercise to get started'
                              : done == total
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
                            _miniStat(
                              Icons.local_fire_department_rounded,
                              '${state.streak}',
                              'streak',
                            ),
                            const SizedBox(width: 16),
                            _miniStat(
                              Icons.timer_outlined,
                              '${state.todayMinutes}',
                              'min',
                            ),
                            const SizedBox(width: 16),
                            _miniStat(Icons.bolt_rounded, '$sets', 'sets'),
                          ],
                        ),
                        const SizedBox(height: 14),
                        AppButton(
                          label: empty
                              ? 'Add workout'
                              : done == total
                                  ? 'Bonus round'
                                  : 'Start workout',
                          height: 44,
                          expanded: false,
                          trailing: false,
                          icon: empty ? Icons.add_rounded : Icons.play_arrow_rounded,
                          onTap: () {
                            if (empty) {
                              showAddWorkoutSheet(context);
                              return;
                            }
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const StopwatchScreen(),
                              ),
                            );
                          },
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
                          empty ? '—' : '$done/$total',
                          style: AppText.h2.copyWith(
                            color: Colors.white,
                            fontSize: 21,
                          ),
                        ),
                        Text(
                          'completed',
                          style: AppText.tiny.copyWith(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 8,
                          ),
                        ),
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
        Text(
          value,
          style: AppText.label.copyWith(
            color: Colors.white,
            fontSize: 12,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: AppText.tiny.copyWith(
            color: Colors.white.withValues(alpha: 0.45),
            fontSize: 8.5,
          ),
        ),
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
      (
        Icons.play_circle_fill_rounded,
        'Videos',
        onVideos,
        const Color(0xFF234E7D),
      ),
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
                    Text(
                      it.$2,
                      style: AppText.tiny.copyWith(
                        fontSize: 9,
                        color: AppColors.inkSoft,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
          color: exercise.done
              ? AppColors.green.withValues(alpha: 0.06)
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: exercise.done
                ? AppColors.green.withValues(alpha: 0.35)
                : AppColors.line,
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
                      decoration: exercise.done
                          ? TextDecoration.lineThrough
                          : null,
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
    final week = state.weekMinutes;
    final maxVal = week.fold<double>(0, (a, b) => b > a ? b : a);
    final scale = maxVal <= 0 ? 1.0 : maxVal;
    final weekTotal = week.fold<int>(0, (a, b) => a + b.round());
    final lastTotal = state.lastWeekMinutes;
    final delta = lastTotal > 0
        ? ((weekTotal - lastTotal) / lastTotal * 100).round()
        : null;
    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              Text('This week', style: AppText.h3.copyWith(fontSize: 16)),
              const Spacer(),
              if (delta != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        delta >= 0
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        size: 12,
                        color: AppColors.greenDeep,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${delta >= 0 ? '+' : ''}$delta%',
                        style: AppText.tiny.copyWith(
                          fontSize: 9,
                          color: AppColors.greenDeep,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$weekTotal',
                style: AppText.h1.copyWith(fontSize: 26),
              ),
              const SizedBox(width: 5),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'active minutes',
                  style: AppText.tiny.copyWith(fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 82,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(week.length, (i) {
                final v = week[i];
                final today = i == DateTime.now().weekday - 1;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: v / scale),
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
                            color: today
                                ? AppColors.greenDeep
                                : AppColors.muted,
                            fontWeight: today
                                ? FontWeight.w700
                                : FontWeight.w500,
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '50% OFF FIRST MONTH',
                      style: AppText.tiny.copyWith(
                        color: Colors.white,
                        fontSize: 7.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.7,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Level up with a\npersonal coach',
                    style: AppText.h3.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Live sessions, meal plans and home training.',
                    style: AppText.tiny.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 9.5,
                    ),
                  ),
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
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.greenDeep,
                size: 20,
              ),
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
            child: const Icon(
              Icons.verified_rounded,
              size: 19,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Premium is active',
                  style: AppText.bodyStrong.copyWith(fontSize: 13),
                ),
                Text(
                  '2 coaching sessions left this month.',
                  style: AppText.tiny.copyWith(fontSize: 9.5),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: AppColors.muted,
          ),
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
                  child: const Icon(
                    Icons.support_agent_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Ask your coach',
                    style: AppText.h3.copyWith(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: Colors.white70,
                ),
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
                child: Text(
                  'View all',
                  style: AppText.tiny.copyWith(
                    fontSize: 10,
                    color: AppColors.greenDeep,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (goals.isEmpty)
            Text(
              'No goals yet — add one from the Goals tab.',
              style: AppText.small.copyWith(fontSize: 11),
            )
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
              child: Text(
                goal.title,
                overflow: TextOverflow.ellipsis,
                style: AppText.label.copyWith(fontSize: 11),
              ),
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

  String _short(double v) =>
      v == v.roundToDouble() ? '${v.round()}' : v.toStringAsFixed(1);
}

class _PreviewBanner extends StatelessWidget {
  const _PreviewBanner({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    if (state.preview == DashboardPreview.auto) return const SizedBox.shrink();
    final label = switch (state.preview) {
      DashboardPreview.newUser => 'new member',
      DashboardPreview.general => 'general',
      DashboardPreview.premium => 'premium',
      DashboardPreview.auto => '',
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 10, 8),
        decoration: BoxDecoration(
          color: AppColors.lime.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.green.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.visibility_outlined,
              size: 15,
              color: AppColors.greenDeep,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Previewing the $label dashboard',
                style: AppText.tiny.copyWith(
                  fontSize: 10.5,
                  color: AppColors.greenDeep,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Pressable(
              onTap: () => state.setDashboardPreview(DashboardPreview.auto),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                child: Text(
                  'Exit',
                  style: AppText.label.copyWith(
                    fontSize: 10.5,
                    color: AppColors.greenDeep,
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

class _TodayWorkoutTiles extends StatelessWidget {
  const _TodayWorkoutTiles({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(state.todayWorkout.length, (i) {
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
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.danger,
                  size: 20,
                ),
              ),
              onDismissed: (_) => state.removeExercise(i),
              child: _ExerciseTile(
                exercise: e,
                onTap: () => state.toggleExercise(i),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _PremiumDashboard extends StatelessWidget {
  const _PremiumDashboard({
    required this.state,
    required this.greeting,
    required this.ambient,
    required this.onTab,
  });

  final AppState state;
  final String greeting;
  final AnimationController ambient;
  final ValueChanged<int>? onTab;

  @override
  Widget build(BuildContext context) {
    if (AppLayout.isDesktop(context)) return _desktop(context);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
          children: [
            _PreviewBanner(state: state),
            _Header(state: state, greeting: greeting),
            const SizedBox(height: 16),
            _PremiumHero(state: state, ambient: ambient),
            const SizedBox(height: 22),
            const SectionHeader(title: 'Your coaching toolkit'),
            const SizedBox(height: 10),
            _CoachingToolkit(),
            const SizedBox(height: 22),
            SectionHeader(
              title: 'Today\'s workout',
              action: 'Add',
              onAction: () => showAddWorkoutSheet(context),
            ),
            const SizedBox(height: 10),
            _TodayWorkoutTiles(state: state),
            const SizedBox(height: 14),
            _WeeklyCard(state: state),
            const SizedBox(height: 14),
            _AdvancedLibrary(state: state, onOpen: () => onTab?.call(2)),
            const SizedBox(height: 14),
            _GoalsPreview(state: state, onViewAll: () => onTab?.call(3)),
          ],
        ),
      ),
    );
  }

  Widget _desktop(BuildContext context) {
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
                    _PreviewBanner(state: state),
                    _Header(state: state, greeting: greeting),
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
                                child: _PremiumHero(
                                  state: state,
                                  ambient: ambient,
                                ),
                              ),
                              const SizedBox(height: 24),
                              const SectionHeader(
                                title: 'Your coaching toolkit',
                              ),
                              const SizedBox(height: 12),
                              _CoachingToolkit(),
                              const SizedBox(height: 28),
                              SectionHeader(
                                title: 'Today\'s workout',
                                action: 'Add',
                                onAction: () => showAddWorkoutSheet(context),
                              ),
                              const SizedBox(height: 12),
                              _TodayWorkoutTiles(state: state),
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
                              _AdvancedLibrary(
                                state: state,
                                onOpen: () => onTab?.call(2),
                              ),
                              const SizedBox(height: 16),
                              _GoalsPreview(
                                state: state,
                                onViewAll: () => onTab?.call(3),
                              ),
                              const SizedBox(height: 16),
                              _CoachCard(
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const NutritionistScreen(),
                                  ),
                                ),
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
}

class _PremiumHero extends StatelessWidget {
  const _PremiumHero({required this.state, required this.ambient});

  final AppState state;
  final AnimationController ambient;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
                width: 230,
                height: 230,
                child: ParticleField(
                  animation: ambient,
                  count: 14,
                  seed: 7,
                  opacity: 0.45,
                ),
              ),
            ),
            Positioned(
              right: -40,
              bottom: -60,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.lime.withValues(alpha: 0.16),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.workspace_premium_rounded,
                          size: 12,
                          color: AppColors.lime,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'PREMIUM · ACTIVE',
                          style: AppText.tiny.copyWith(
                            color: AppColors.lime,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Premium coaching\nunlocked',
                    style: AppText.h1.copyWith(
                      color: Colors.white,
                      fontSize: 26,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    state.planRenewsAt != null
                        ? 'Coach, meal plans and advanced sessions. Renews ${_shortDate(state.planRenewsAt!)}.'
                        : 'Coach, meal plans and advanced sessions — all in one place.',
                    style: AppText.small.copyWith(
                      color: Colors.white.withValues(alpha: 0.58),
                      fontSize: 11,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      AppButton(
                        label: 'Message coach',
                        icon: Icons.forum_rounded,
                        height: 42,
                        expanded: false,
                        trailing: false,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const NutritionistScreen(),
                          ),
                        ),
                      ),
                      Pressable(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SubscriptionScreen(),
                          ),
                        ),
                        child: Container(
                          height: 42,
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.16),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Manage plan',
                                style: AppText.label.copyWith(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoachingToolkit extends StatelessWidget {
  const _CoachingToolkit();

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        'Home trainer',
        'Trainer comes to you',
        Icons.sports_handball_rounded,
        const Color(0xFF1F5D4A),
        const CoachingScreen(),
      ),
      (
        'Nutritionist chat',
        'Message your dietitian',
        Icons.forum_rounded,
        const Color(0xFF7A4E2D),
        const NutritionistScreen(),
      ),
      (
        'Meal plans',
        'Built around your macros',
        Icons.restaurant_menu_rounded,
        const Color(0xFF2C4A7A),
        const MealPlanScreen(),
      ),
      (
        'Coaching sessions',
        'Book your next block',
        Icons.calendar_month_rounded,
        const Color(0xFF6A3FB0),
        const CoachingScreen(),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        mainAxisExtent: 112,
      ),
      itemBuilder: (context, i) {
        final item = items[i];
        return Pressable(
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => item.$5)),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.line.withValues(alpha: 0.8)),
              boxShadow: AppShadows.soft,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: item.$4.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item.$3, size: 18, color: item.$4),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.arrow_outward_rounded,
                      size: 15,
                      color: AppColors.greenDeep,
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  item.$1,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.bodyStrong.copyWith(fontSize: 12.5),
                ),
                const SizedBox(height: 2),
                Text(
                  item.$2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.tiny.copyWith(fontSize: 9.5),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AdvancedLibrary extends StatelessWidget {
  const _AdvancedLibrary({required this.state, required this.onOpen});

  final AppState state;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final videos = state.videos.where((v) => v.premium).toList();
    if (videos.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Advanced library',
                style: AppText.h3.copyWith(fontSize: 16),
              ),
            ),
            GestureDetector(
              onTap: onOpen,
              behavior: HitTestBehavior.opaque,
              child: Text(
                'Videos',
                style: AppText.tiny.copyWith(
                  fontSize: 10,
                  color: AppColors.greenDeep,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 142,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: videos.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final video = videos[i];
              return Pressable(
                onTap: onOpen,
                child: SizedBox(
                  width: 196,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(video.image, fit: BoxFit.cover),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                AppColors.ink.withValues(alpha: 0.78),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.lime.withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'PREMIUM',
                              style: AppText.tiny.copyWith(
                                color: AppColors.ink,
                                fontSize: 7.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 12,
                          right: 12,
                          bottom: 11,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                video.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppText.bodyStrong.copyWith(
                                  color: Colors.white,
                                  fontSize: 12.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${video.level} · ${video.minutes} min',
                                style: AppText.tiny.copyWith(
                                  color: Colors.white.withValues(alpha: 0.65),
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _NewUserDashboard extends StatelessWidget {
  const _NewUserDashboard({
    required this.state,
    required this.greeting,
    required this.ambient,
    required this.onTab,
  });

  final AppState state;
  final String greeting;
  final AnimationController ambient;
  final ValueChanged<int>? onTab;

  @override
  Widget build(BuildContext context) {
    if (AppLayout.isDesktop(context)) return _desktop(context);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
          children: [
            _PreviewBanner(state: state),
            _Header(state: state, greeting: greeting),
            const SizedBox(height: 16),
            _WelcomeCard(
              state: state,
              ambient: ambient,
              onGoal: () => onTab?.call(3),
              onAdd: () => showAddWorkoutSheet(context),
            ),
            const SizedBox(height: 22),
            const SectionHeader(title: 'Get set up'),
            const SizedBox(height: 10),
            _SetupChecklist(
              onGoal: () => onTab?.call(3),
              onAdd: () => showAddWorkoutSheet(context),
              onVideos: () => onTab?.call(2),
            ),
            const SizedBox(height: 22),
            const SectionHeader(title: 'Your week'),
            const SizedBox(height: 10),
            const _EmptyWeekCard(),
            const SizedBox(height: 14),
            _EmptyGoalsCard(onCreate: () => onTab?.call(3)),
            const SizedBox(height: 14),
            _CoachCard(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NutritionistScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _desktop(BuildContext context) {
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
                    _PreviewBanner(state: state),
                    _Header(state: state, greeting: greeting),
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
                                child: _WelcomeCard(
                                  state: state,
                                  ambient: ambient,
                                  onGoal: () => onTab?.call(3),
                                  onAdd: () => showAddWorkoutSheet(context),
                                ),
                              ),
                              const SizedBox(height: 24),
                              const SectionHeader(title: 'Get set up'),
                              const SizedBox(height: 12),
                              _SetupChecklist(
                                onGoal: () => onTab?.call(3),
                                onAdd: () => showAddWorkoutSheet(context),
                                onVideos: () => onTab?.call(2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 26),
                        SizedBox(
                          width: 356,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const _EmptyWeekCard(),
                              const SizedBox(height: 16),
                              _EmptyGoalsCard(onCreate: () => onTab?.call(3)),
                              const SizedBox(height: 16),
                              _CoachCard(
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const NutritionistScreen(),
                                  ),
                                ),
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
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({
    required this.state,
    required this.ambient,
    required this.onGoal,
    required this.onAdd,
  });

  final AppState state;
  final AnimationController ambient;
  final VoidCallback onGoal;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
                width: 230,
                height: 230,
                child: ParticleField(
                  animation: ambient,
                  count: 14,
                  seed: 11,
                  opacity: 0.4,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      'WELCOME',
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
                    'Hi ${state.name},\nlet\'s build your first week.',
                    style: AppText.h1.copyWith(
                      color: Colors.white,
                      fontSize: 24,
                      height: 1.14,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Your dashboard fills up as you train. Start with one goal — '
                    'everything else follows from there.',
                    style: AppText.small.copyWith(
                      color: Colors.white.withValues(alpha: 0.58),
                      fontSize: 11,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      AppButton(
                        label: 'Set a goal',
                        icon: Icons.flag_rounded,
                        height: 42,
                        expanded: false,
                        trailing: false,
                        onTap: onGoal,
                      ),
                      Pressable(
                        onTap: onAdd,
                        child: Container(
                          height: 42,
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.16),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Add an exercise',
                                style: AppText.label.copyWith(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SetupChecklist extends StatelessWidget {
  const _SetupChecklist({
    required this.onGoal,
    required this.onAdd,
    required this.onVideos,
  });

  final VoidCallback onGoal;
  final VoidCallback onAdd;
  final VoidCallback onVideos;

  @override
  Widget build(BuildContext context) {
    final steps = [
      (
        'Set your first goal',
        'Pick a target and we\'ll track the progress',
        Icons.flag_rounded,
        onGoal,
      ),
      (
        'Build today\'s workout',
        'Add the exercises you plan to train',
        Icons.fitness_center_rounded,
        onAdd,
      ),
      (
        'Explore the library',
        'Watch a form guide before you start',
        Icons.play_circle_fill_rounded,
        onVideos,
      ),
    ];

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          for (var i = 0; i < steps.length; i++) ...[
            if (i != 0) const Divider(),
            Pressable(
              onTap: steps[i].$4,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 13),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.green.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${i + 1}',
                          style: AppText.label.copyWith(
                            fontSize: 12,
                            color: AppColors.greenDeep,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            steps[i].$1,
                            style: AppText.bodyStrong.copyWith(fontSize: 13.5),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            steps[i].$2,
                            style: AppText.tiny.copyWith(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    Icon(steps[i].$3, size: 17, color: AppColors.muted),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: AppColors.muted,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyWeekCard extends StatelessWidget {
  const _EmptyWeekCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('This week', style: AppText.h3.copyWith(fontSize: 16)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('0', style: AppText.h1.copyWith(fontSize: 26)),
              const SizedBox(width: 5),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'active minutes',
                  style: AppText.tiny.copyWith(fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 74,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.line,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          const ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i],
                          style: AppText.tiny.copyWith(fontSize: 8.5),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.insights_rounded,
                size: 15,
                color: AppColors.muted,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'No sessions yet — your week starts with the first workout.',
                  style: AppText.small.copyWith(fontSize: 11, height: 1.4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyGoalsCard extends StatelessWidget {
  const _EmptyGoalsCard({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.flag_rounded,
                  size: 18,
                  color: AppColors.greenDeep,
                ),
              ),
              const SizedBox(width: 11),
              Text('Goals', style: AppText.h3.copyWith(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'No goals yet. Set one target and we\'ll chart your progress here.',
            style: AppText.small.copyWith(fontSize: 11.5, height: 1.45),
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'Create a goal',
            icon: Icons.add_rounded,
            height: 42,
            trailing: false,
            onTap: onCreate,
          ),
        ],
      ),
    );
  }
}

String _shortDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}';
}
