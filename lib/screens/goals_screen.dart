import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/energy.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _ambient = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 20),
  )..repeat();

  @override
  void dispose() {
    _ambient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final overall = state.goals.isEmpty
        ? 0.0
        : state.goals.fold<double>(0, (a, g) => a + g.progress) / state.goals.length;

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
                      Text('Goals', style: AppText.h1.copyWith(fontSize: 26)),
                      const SizedBox(height: 3),
                      Text('Small steps, tracked weekly',
                          style: AppText.small.copyWith(fontSize: 12)),
                    ],
                  ),
                ),
                AppIconButton(
                  icon: Icons.add_rounded,
                  onTap: () => showAddGoalSheet(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SummaryCard(overall: overall, goals: state.goals, ambient: _ambient),
            const SizedBox(height: 20),
            SectionHeader(
              title: 'Active goals',
              action: 'Add goal',
              onAction: () => showAddGoalSheet(context),
            ),
            const SizedBox(height: 10),
            ...List.generate(state.goals.length, (i) {
              final goal = state.goals[i];
              return SlideFadeIn(
                delay: Duration(milliseconds: 70 * i),
                duration: const Duration(milliseconds: 460),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _GoalCard(
                    goal: goal,
                    onLog: () => _showLogSheet(context, state, goal),
                  ),
                ),
              );
            }),
            const SizedBox(height: 10),
            _CheckInCard(state: state),
          ],
        ),
      ),
    );
  }

  void _showLogSheet(BuildContext context, AppState state, FitnessGoal goal) {
    double value = goal.current;
    showAppSheet(
      context,
      StatefulBuilder(
        builder: (context, setSheet) {
          final span = (goal.target - goal.start).abs();
          final progress = span == 0
              ? 0.0
              : ((value - goal.start) / (goal.target - goal.start)).clamp(0.0, 1.0);
          return Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: goal.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(goal.icon, size: 20, color: goal.color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Log progress', style: AppText.h2.copyWith(fontSize: 18)),
                          Text(goal.title, style: AppText.small.copyWith(fontSize: 11.5)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: value.toStringAsFixed(value % 1 == 0 ? 0 : 1),
                          style: AppText.display.copyWith(fontSize: 42, color: AppColors.ink),
                        ),
                        TextSpan(
                          text: goal.unit,
                          style: AppText.h2.copyWith(color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    'Target ${goal.targetLabel}',
                    style: AppText.tiny.copyWith(fontSize: 10.5),
                  ),
                ),
                const SizedBox(height: 10),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: goal.color,
                    inactiveTrackColor: AppColors.surfaceSunken,
                    thumbColor: Colors.white,
                    overlayColor: goal.color.withValues(alpha: 0.16),
                    trackHeight: 7,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 11),
                  ),
                  child: Slider(
                    value: value.clamp(
                      goal.start < goal.target ? goal.start : goal.target,
                      goal.start < goal.target ? goal.target : goal.start,
                    ),
                    min: goal.start < goal.target ? goal.start : goal.target,
                    max: goal.start < goal.target ? goal.target : goal.start,
                    divisions: 40,
                    onChanged: (v) => setSheet(() => value = v),
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: AppColors.surfaceSunken,
                    valueColor: AlwaysStoppedAnimation(goal.color),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(progress * 100).round()}% of this goal complete',
                  style: AppText.tiny.copyWith(fontSize: 10.5),
                ),
                const SizedBox(height: 20),
                AppButton(
                  label: 'Save progress',
                  onTap: () {
                    state.nudgeGoal(goal, value - goal.current);
                    Navigator.of(context).pop();
                    appToast(context, 'Progress updated',
                        icon: Icons.trending_up_rounded);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.overall,
    required this.goals,
    required this.ambient,
  });

  final double overall;
  final List<FitnessGoal> goals;
  final AnimationController ambient;

  @override
  Widget build(BuildContext context) {
    final onTrack = goals.where((g) => g.progress >= 0.5).length;

    return Container(
      height: 172,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B211A), Color(0xFF123B29)],
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
                width: 190,
                height: 190,
                child: ParticleField(
                  animation: ambient,
                  count: 14,
                  seed: 21,
                  opacity: 0.45,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  ProgressRing(
                    value: overall,
                    size: 108,
                    stroke: 10,
                    colors: const [AppColors.lime, AppColors.greenBright],
                    center: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(overall * 100).round()}%',
                          style: AppText.h2.copyWith(color: Colors.white, fontSize: 24),
                        ),
                        Text(
                          'ON TRACK',
                          style: AppText.tiny.copyWith(
                            color: Colors.white.withValues(alpha: 0.55),
                            fontSize: 7.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${goals.length} active goals',
                          style: AppText.h3.copyWith(color: Colors.white, fontSize: 17),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$onTrack on track this month. Keep the momentum going.',
                          style: AppText.small.copyWith(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 11.5,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(AppRadius.pill),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.trending_up_rounded,
                                      size: 12, color: AppColors.lime),
                                  const SizedBox(width: 4),
                                  Text(
                                    '+12% vs last month',
                                    style: AppText.tiny.copyWith(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.goal, required this.onLog});

  final FitnessGoal goal;
  final VoidCallback onLog;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      elevated: true,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: goal.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(goal.icon, size: 20, color: goal.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(goal.title, style: AppText.h3.copyWith(fontSize: 14.5)),
                    const SizedBox(height: 2),
                    Text(
                      '${goal.currentLabel} of ${goal.targetLabel}',
                      style: AppText.tiny.copyWith(fontSize: 10.5),
                    ),
                  ],
                ),
              ),
              Text(
                '${(goal.progress * 100).round()}%',
                style: AppText.h3.copyWith(fontSize: 16, color: goal.color),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: goal.progress),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, v, _) {
              return LayoutBuilder(
                builder: (context, c) => ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: SizedBox(
                    height: 9,
                    child: Stack(
                      children: [
                        Container(width: c.maxWidth, color: AppColors.surfaceSunken),
                        Container(
                          width: c.maxWidth * v,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [goal.color.withValues(alpha: 0.75), goal.color],
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
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.flag_rounded, size: 13, color: AppColors.muted),
              const SizedBox(width: 4),
              Text(
                'Target ${goal.targetLabel}',
                style: AppText.tiny.copyWith(fontSize: 9.5),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onLog,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: goal.color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, size: 13, color: goal.color),
                      const SizedBox(width: 3),
                      Text(
                        'Log progress',
                        style: AppText.tiny.copyWith(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: goal.color,
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
    );
  }
}

class _CheckInCard extends StatelessWidget {
  const _CheckInCard({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final week = state.weekMinutes;
    final maxMinutes = week.fold<double>(0, (a, b) => b > a ? b : a);
    final scale = maxMinutes <= 0 ? 1.0 : maxMinutes;
    final today = DateTime.now().weekday - 1;
    final activeDays = week.where((m) => m > 0).length;

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.insights_rounded, size: 18, color: AppColors.greenDeep),
              const SizedBox(width: 8),
              Text('Weekly check-in', style: AppText.h3.copyWith(fontSize: 15)),
              const Spacer(),
              Text('This week', style: AppText.tiny.copyWith(fontSize: 9.5)),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 74,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(week.length, (i) {
                final v = week[i];
                final active = i == today;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          v == 0 ? '–' : '${v.toInt()}',
                          style: AppText.tiny.copyWith(
                            fontSize: 8,
                            color: active ? AppColors.greenDeep : AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: v / scale),
                          duration: Duration(milliseconds: 600 + i * 70),
                          curve: Curves.easeOutCubic,
                          builder: (context, h, _) => Container(
                            width: double.infinity,
                            height: 8 + h * 40,
                            decoration: BoxDecoration(
                              gradient: active ? AppColors.greenGradient : null,
                              color: active ? null : AppColors.surfaceSunken,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: const [
              _DayLetter('M'),
              _DayLetter('T'),
              _DayLetter('W'),
              _DayLetter('T'),
              _DayLetter('F'),
              _DayLetter('S'),
              _DayLetter('S'),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.lime.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.auto_awesome_rounded,
                    size: 16, color: AppColors.greenDeep),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    activeDays == 0
                        ? 'No sessions logged this week yet. One workout puts you on the board.'
                        : activeDays >= 5
                            ? 'You trained $activeDays days this week. Strong week — keep it rolling.'
                            : 'You trained $activeDays ${activeDays == 1 ? 'day' : 'days'} this week. One more session keeps your streak alive.',
                    style: AppText.small.copyWith(
                      fontSize: 11.5,
                      color: AppColors.inkSoft,
                      height: 1.4,
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
}

class _DayLetter extends StatelessWidget {
  const _DayLetter(this.letter);

  final String letter;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(letter, style: AppText.tiny.copyWith(fontSize: 8.5)),
      ),
    );
  }
}

Future<void> showAddGoalSheet(BuildContext context) {
  final title = TextEditingController();
  final target = TextEditingController(text: '80');
  final unit = TextEditingController(text: 'kg');
  var colorIndex = 0;
  const colors = [AppColors.green, AppColors.navy, AppColors.amber, AppColors.greenDeep];

  return showAppSheet(
    context,
    StatefulBuilder(
      builder: (context, setSheet) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('New goal', style: AppText.h2.copyWith(fontSize: 20)),
              const SizedBox(height: 4),
              Text('Give it a name and a target to aim for.',
                  style: AppText.small.copyWith(fontSize: 11.5)),
              const SizedBox(height: 16),
              TextField(
                controller: title,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(hintText: 'e.g. Run a 5K without stopping'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: target,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(hintText: 'Target'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 96,
                    child: TextField(
                      controller: unit,
                      decoration: const InputDecoration(hintText: 'Unit'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text('COLOUR', style: AppText.label.copyWith(fontSize: 9.5)),
              const SizedBox(height: 8),
              Row(
                children: List.generate(colors.length, (i) {
                  final active = i == colorIndex;
                  return GestureDetector(
                    onTap: () => setSheet(() => colorIndex = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 34,
                      height: 34,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: colors[i],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: active ? AppColors.ink : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: active
                          ? const Icon(Icons.check_rounded,
                              size: 16, color: Colors.white)
                          : null,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              AppButton(
                label: 'Create goal',
                icon: Icons.flag_rounded,
                trailing: false,
                onTap: () {
                  final parsed =
                      double.tryParse(target.text.trim().replaceAll(',', '.')) ?? 0;
                  if (title.text.trim().isEmpty || parsed <= 0) {
                    appToast(context, 'Add a name and a target above zero',
                        icon: Icons.info_outline_rounded);
                    return;
                  }
                  AppScope.of(context).addGoal(
                    FitnessGoal(
                      title: title.text.trim(),
                      unit: unit.text.trim().isEmpty ? '' : unit.text.trim(),
                      start: 0,
                      target: parsed,
                      current: 0,
                      icon: Icons.flag_rounded,
                      color: colors[colorIndex],
                      colorKey: AppState.colorKeyFor(colors[colorIndex]),
                    ),
                  );
                  Navigator.of(context).pop();
                  appToast(context, 'Goal created', icon: Icons.check_circle_rounded);
                },
              ),
            ],
          ),
        );
      },
    ),
  );
}
