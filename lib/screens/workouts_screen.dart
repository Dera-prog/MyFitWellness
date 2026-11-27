import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/add_workout_sheet.dart';
import '../widgets/common.dart';
import '../widgets/energy.dart';
import 'stopwatch_screen.dart';

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _ambient = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 22),
  )..repeat();

  late DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  late DateTime _selected = DateUtils.dateOnly(DateTime.now());

  static const _weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static const _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  void dispose() {
    _ambient.dispose();
    super.dispose();
  }

  WorkoutEntry? _entryFor(DateTime day) {
    for (final e in AppScope.of(context).history) {
      if (DateUtils.isSameDay(e.date, day)) return e;
    }
    return null;
  }

  bool _hasWorkout(DateTime day) => _entryFor(day) != null;

  bool get _isToday => DateUtils.isSameDay(_selected, DateTime.now());

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Workouts', style: AppText.h1.copyWith(fontSize: 26)),
                      const SizedBox(height: 3),
                      Text('Your training calendar', style: AppText.small.copyWith(fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_fire_department_rounded,
                          size: 16, color: AppColors.amber),
                      const SizedBox(width: 5),
                      Text(
                        '${state.streak} day streak',
                        style: AppText.tiny.copyWith(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _statsRow(state),
            const SizedBox(height: 18),
            _CalendarCard(
              month: _month,
              selected: _selected,
              weekdays: _weekdays,
              monthName: _monthNames[_month.month - 1],
              hasWorkout: _hasWorkout,
              onPrev: () => setState(
                () => _month = DateTime(_month.year, _month.month - 1),
              ),
              onNext: () => setState(
                () => _month = DateTime(_month.year, _month.month + 1),
              ),
              onSelect: (d) => setState(() => _selected = d),
            ),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              switchInCurve: Curves.easeOutCubic,
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween(begin: const Offset(0, 0.06), end: Offset.zero)
                      .animate(anim),
                  child: child,
                ),
              ),
              child: _isToday
                  ? _TodaySessionCard(key: const ValueKey('today'), state: state)
                  : _DayCard(
                      key: ValueKey(_selected.toIso8601String()),
                      day: _selected,
                      entry: _entryFor(_selected),
                      monthName: _monthNames[_selected.month - 1],
                    ),
            ),
            const SizedBox(height: 22),
            const SectionHeader(title: 'Recent sessions'),
            const SizedBox(height: 10),
            ...List.generate(state.history.length, (i) {
              return SlideFadeIn(
                delay: Duration(milliseconds: 60 * i),
                duration: const Duration(milliseconds: 420),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _HistoryTile(entry: state.history[i], index: i + 1),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _statsRow(AppState state) {
    final total = state.weekMinutes.fold<double>(0, (a, b) => a + b);
    final sessions = state.weekSessions;
    final kcal =
        state.history.fold<int>(0, (a, e) => a + e.kcal);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B211A), Color(0xFF133C2B)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppShadows.soft,
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -30,
            child: SizedBox(
              width: 150,
              height: 150,
              child: ParticleField(
                animation: _ambient,
                count: 10,
                seed: 11,
                opacity: 0.35,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(child: _stat('${total.toInt()}', 'min this week', Icons.timer_rounded)),
              _divider(),
              Expanded(child: _stat('$sessions', 'sessions', Icons.fitness_center_rounded)),
              _divider(),
              Expanded(
                child: _stat(
                  '$kcal',
                  'kcal burned',
                  Icons.local_fire_department_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 34,
        color: Colors.white.withValues(alpha: 0.10),
      );

  Widget _stat(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 16, color: AppColors.lime),
        const SizedBox(height: 6),
        Text(value, style: AppText.h3.copyWith(color: Colors.white, fontSize: 19)),
        const SizedBox(height: 1),
        Text(
          label,
          style: AppText.tiny.copyWith(
            color: Colors.white.withValues(alpha: 0.55),
            fontSize: 9.5,
          ),
        ),
      ],
    );
  }
}

class _CalendarCard extends StatelessWidget {
  const _CalendarCard({
    required this.month,
    required this.selected,
    required this.weekdays,
    required this.monthName,
    required this.hasWorkout,
    required this.onPrev,
    required this.onNext,
    required this.onSelect,
  });

  final DateTime month;
  final DateTime selected;
  final List<String> weekdays;
  final String monthName;
  final bool Function(DateTime) hasWorkout;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final leading = first.weekday - 1; // Monday-first grid
    final cells = leading + daysInMonth;

    return AppCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      elevated: true,
      child: Column(
        children: [
          Row(
            children: [
              _NavButton(icon: Icons.chevron_left_rounded, onTap: onPrev),
              Expanded(
                child: Center(
                  child: Text(
                    '$monthName ${month.year}',
                    style: AppText.h3.copyWith(fontSize: 15),
                  ),
                ),
              ),
              _NavButton(icon: Icons.chevron_right_rounded, onTap: onNext),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: weekdays
                .map(
                  (d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: AppText.tiny.copyWith(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: ((cells + 6) ~/ 7) * 7,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisExtent: 44,
            ),
            itemBuilder: (context, index) {
              final dayNumber = index - leading + 1;
              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const SizedBox.shrink();
              }
              final date = DateTime(month.year, month.month, dayNumber);
              final isSelected = DateUtils.isSameDay(date, selected);
              final isToday = DateUtils.isSameDay(date, DateTime.now());
              final done = hasWorkout(date);

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelect(date),
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutBack,
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.ink : Colors.transparent,
                      shape: BoxShape.circle,
                      border: isToday && !isSelected
                          ? Border.all(color: AppColors.green, width: 1.4)
                          : null,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          '$dayNumber',
                          style: AppText.bodyStrong.copyWith(
                            fontSize: 12.5,
                            color: isSelected ? Colors.white : AppColors.ink,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                        if (done)
                          Positioned(
                            bottom: 5,
                            child: Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.lime : AppColors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: AppColors.surfaceSunken,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(icon, size: 19, color: AppColors.ink),
      ),
    );
  }
}

class _TodaySessionCard extends StatelessWidget {
  const _TodaySessionCard({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final total = state.todayWorkout.length;
    final done = state.completedToday;
    final empty = total == 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.green.withValues(alpha: 0.35)),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: [
          ProgressRing(
            value: state.todayProgress,
            size: 66,
            stroke: 7,
            trackColor: AppColors.surfaceSunken,
            center: Text(
              empty ? '—' : '$done/$total',
              style: AppText.h3.copyWith(fontSize: 14),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  empty ? 'Nothing planned today' : 'Today · in progress',
                  style: AppText.h3.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 3),
                Text(
                  empty
                      ? 'Add exercises to build today\'s session'
                      : '${state.todayMinutes} min planned · ${total - done} left',
                  style: AppText.small.copyWith(fontSize: 11.5),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    label: empty ? 'Add exercises' : 'Continue session',
                    height: 42,
                    onTap: () {
                      if (empty) {
                        showAddWorkoutSheet(context);
                        return;
                      }
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const StopwatchScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({super.key, required this.day, required this.entry, required this.monthName});

  final DateTime day;
  final WorkoutEntry? entry;
  final String monthName;

  @override
  Widget build(BuildContext context) {
    final label = '${weekdayName(day.weekday)}, ${day.day} $monthName';

    if (entry == null) {
      return AppCard(
        elevated: true,
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.surfaceSunken,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.self_improvement_rounded,
                  size: 22, color: AppColors.muted),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppText.h3.copyWith(fontSize: 14)),
                  const SizedBox(height: 2),
                  Text('Rest & recovery day', style: AppText.small.copyWith(fontSize: 11.5)),
                ],
              ),
            ),
            LevelChip(label: 'Rest', color: AppColors.muted),
          ],
        ),
      );
    }

    final e = entry!;
    return AppCard(
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(label, style: AppText.tiny.copyWith(fontSize: 10)),
              ),
              LevelChip(
                label: e.intensity > 0.8
                    ? 'High intensity'
                    : e.intensity > 0.6
                        ? 'Moderate'
                        : 'Light',
                color: e.intensity > 0.8 ? AppColors.amber : AppColors.green,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(e.title, style: AppText.h3.copyWith(fontSize: 16)),
          const SizedBox(height: 12),
          Row(
            children: [
              _metric(Icons.timer_rounded, '${e.minutes} min'),
              const SizedBox(width: 18),
              _metric(Icons.fitness_center_rounded, '${e.exercises} moves'),
              const SizedBox(width: 18),
              _metric(Icons.local_fire_department_rounded, '${e.kcal} kcal'),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: e.intensity,
              minHeight: 7,
              backgroundColor: AppColors.surfaceSunken,
              valueColor: const AlwaysStoppedAnimation(AppColors.green),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.greenDeep),
        const SizedBox(width: 4),
        Text(text, style: AppText.tiny.copyWith(fontSize: 10, color: AppColors.inkSoft)),
      ],
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.entry, required this.index});

  final WorkoutEntry entry;
  final int index;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.navy.withValues(alpha: 0.9),
                  AppColors.navyDeep,
                ],
              ),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Center(
              child: Text(
                entry.date.day.toString().padLeft(2, '0'),
                style: AppText.h3.copyWith(color: Colors.white, fontSize: 15),
              ),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.title, style: AppText.bodyStrong.copyWith(fontSize: 13.5)),
                const SizedBox(height: 3),
                Text(
                  '${weekdayName(entry.date.weekday)} · ${entry.minutes} min · ${entry.kcal} kcal',
                  style: AppText.tiny.copyWith(fontSize: 10),
                ),
              ],
            ),
          ),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, size: 17, color: AppColors.greenDeep),
          ),
        ],
      ),
    );
  }
}

String weekdayName(int weekday) {
  const names = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];
  return names[(weekday - 1) % 7];
}
