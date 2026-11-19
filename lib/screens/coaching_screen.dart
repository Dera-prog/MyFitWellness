import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class CoachingScreen extends StatefulWidget {
  const CoachingScreen({super.key});

  @override
  State<CoachingScreen> createState() => _CoachingScreenState();
}

class _CoachingScreenState extends State<CoachingScreen> {
  int _trainer = 0;
  int _mode = 0;
  int _day = 1;
  int _slot = 2;

  static const _modes = ['At home', 'At my gym', 'Virtual'];
  static const _slots = ['07:00', '09:30', '12:00', '16:30', '18:00', '19:30'];

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final trainers = state.trainers;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const ScreenHeader(
              title: 'Coaching',
              subtitle: 'Book a trainer, at your place or theirs',
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  _introCard(),
                  const SizedBox(height: 20),
                  SectionHeader(
                    title: 'Choose your coach',
                    action: '${trainers.length} available',
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 178,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: trainers.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, i) => _TrainerCard(
                        trainer: trainers[i],
                        selected: i == _trainer,
                        onTap: () => setState(() => _trainer = i),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const SectionHeader(title: 'How do you want to train?'),
                  const SizedBox(height: 10),
                  Row(
                    children: List.generate(_modes.length, (i) {
                      final active = i == _mode;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _mode = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            margin: EdgeInsets.only(right: i == _modes.length - 1 ? 0 : 8),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            decoration: BoxDecoration(
                              color: active ? AppColors.ink : AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: active ? AppColors.ink : AppColors.line,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  [
                                    Icons.home_rounded,
                                    Icons.fitness_center_rounded,
                                    Icons.videocam_rounded,
                                  ][i],
                                  size: 18,
                                  color: active ? AppColors.lime : AppColors.muted,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  _modes[i],
                                  style: AppText.tiny.copyWith(
                                    fontSize: 9.5,
                                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                                    color: active ? Colors.white : AppColors.inkSoft,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  const SectionHeader(title: 'Pick a day'),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 76,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 7,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final date = DateTime.now().add(Duration(days: i + 1));
                        final active = i == _day;
                        return GestureDetector(
                          onTap: () => setState(() => _day = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            width: 58,
                            decoration: BoxDecoration(
                              color: active ? AppColors.green : AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: active ? AppColors.green : AppColors.line,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _shortDay(date.weekday),
                                  style: AppText.tiny.copyWith(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.6,
                                    color: active
                                        ? Colors.white.withValues(alpha: 0.75)
                                        : AppColors.muted,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '${date.day}',
                                  style: AppText.h3.copyWith(
                                    fontSize: 18,
                                    color: active ? Colors.white : AppColors.ink,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _monthShort(date.month),
                                  style: AppText.tiny.copyWith(
                                    fontSize: 8,
                                    color: active
                                        ? Colors.white.withValues(alpha: 0.75)
                                        : AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  const SectionHeader(title: 'Available times'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(_slots.length, (i) {
                      final active = i == _slot;
                      final taken = i == 0;
                      return GestureDetector(
                        onTap: taken ? null : () => setState(() => _slot = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                          decoration: BoxDecoration(
                            color: active ? AppColors.ink : AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: active ? AppColors.ink : AppColors.line,
                            ),
                          ),
                          child: Text(
                            _slots[i],
                            style: AppText.bodyStrong.copyWith(
                              fontSize: 12.5,
                              color: taken
                                  ? AppColors.muted.withValues(alpha: 0.5)
                                  : active
                                      ? Colors.white
                                      : AppColors.ink,
                              decoration: taken ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  _summary(trainers[_trainer]),
                  const SizedBox(height: 12),
                  AppButton(
                    label: 'Book session',
                    icon: Icons.event_available_rounded,
                    trailing: false,
                    onTap: () => _confirm(trainers[_trainer]),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      'Included with Premium · reschedule free up to 24h',
                      style: AppText.tiny.copyWith(fontSize: 9.5),
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

  Widget _introCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B211A), Color(0xFF16452F)],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.lime.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.sports_handball_rounded,
                color: AppColors.lime, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'A coach who comes to you',
                  style: AppText.h3.copyWith(color: Colors.white, fontSize: 15),
                ),
                const SizedBox(height: 3),
                Text(
                  'Home sessions, gym floor or live video — same coach, same plan.',
                  style: AppText.small.copyWith(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 11,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summary(Trainer trainer) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: trainer.color,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Center(
              child: Text(
                trainer.initials,
                style: AppText.label.copyWith(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trainer.name, style: AppText.bodyStrong.copyWith(fontSize: 13)),
                const SizedBox(height: 2),
                Text(
                  '${_modes[_mode]} · ${_slots[_slot]}',
                  style: AppText.tiny.copyWith(fontSize: 10),
                ),
              ],
            ),
          ),
          Text('60 min', style: AppText.label.copyWith(fontSize: 10.5)),
        ],
      ),
    );
  }

  void _confirm(Trainer trainer) {
    showAppSheet(
      context,
      Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                gradient: AppColors.greenGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.green.withValues(alpha: 0.35),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 14),
            Text('Session booked', style: AppText.h2.copyWith(fontSize: 20)),
            const SizedBox(height: 6),
            Text(
              '${trainer.name} · ${_modes[_mode]}\n'
              '${_shortDay(DateTime.now().add(Duration(days: _day + 1)).weekday)} '
              'at ${_slots[_slot]}',
              textAlign: TextAlign.center,
              style: AppText.small.copyWith(fontSize: 12, height: 1.6),
            ),
            const SizedBox(height: 18),
            AppButton(
              label: 'Done',
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  String _shortDay(int w) =>
      const ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'][(w - 1) % 7];

  String _monthShort(int m) =>
      const ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'][m - 1];
}

class _TrainerCard extends StatelessWidget {
  const _TrainerCard({
    required this.trainer,
    required this.selected,
    required this.onTap,
  });

  final Trainer trainer;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 148,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.ink : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.ink : AppColors.line,
          ),
          boxShadow: selected ? AppShadows.float : AppShadows.soft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: trainer.color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      trainer.initials,
                      style: AppText.label.copyWith(color: Colors.white, fontSize: 11),
                    ),
                  ),
                ),
                const Spacer(),
                if (selected)
                  const Icon(Icons.check_circle_rounded,
                      size: 18, color: AppColors.lime),
              ],
            ),
            const Spacer(),
            Text(
              trainer.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.bodyStrong.copyWith(
                fontSize: 12.5,
                color: selected ? Colors.white : AppColors.ink,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              trainer.specialty,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppText.tiny.copyWith(
                fontSize: 9,
                color: selected ? Colors.white.withValues(alpha: 0.6) : AppColors.muted,
              ),
            ),
            const SizedBox(height: 7),
            Row(
              children: [
                const Icon(Icons.star_rounded, size: 12, color: AppColors.amber),
                const SizedBox(width: 3),
                Text(
                  '${trainer.rating}',
                  style: AppText.tiny.copyWith(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : AppColors.ink,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${trainer.sessions} sessions',
                  style: AppText.tiny.copyWith(fontSize: 8, color: AppColors.muted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
