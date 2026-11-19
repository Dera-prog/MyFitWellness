import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../theme/app_theme.dart';
import 'common.dart';

Future<void> showAddWorkoutSheet(BuildContext context) async {
  final state = AppScope.of(context);
  final name = TextEditingController();
  final sets = TextEditingController(text: '3');
  final reps = TextEditingController(text: '10');
  final weight = TextEditingController(text: '20');
  final minutes = TextEditingController(text: '12');
  var type = 0;
  const types = [
    (Icons.fitness_center_rounded, 'Strength'),
    (Icons.directions_run_rounded, 'Cardio'),
    (Icons.self_improvement_rounded, 'Mobility'),
    (Icons.sports_gymnastics_rounded, 'Circuit'),
  ];

  await showAppSheet(
    context,
    StatefulBuilder(
      builder: (context, setSheetState) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Add exercise', style: AppText.h2.copyWith(fontSize: 20)),
                  const Spacer(),
                  AppIconButton(
                    icon: Icons.close_rounded,
                    size: 36,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: name,
                autofocus: true,
                style: AppText.bodyStrong.copyWith(fontSize: 14),
                decoration: const InputDecoration(hintText: 'Exercise name'),
              ),
              const SizedBox(height: 12),
              Row(
                children: List.generate(types.length, (i) {
                  final active = type == i;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: i == types.length - 1 ? 0 : 8),
                      child: GestureDetector(
                        onTap: () => setSheetState(() => type = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: active ? AppColors.ink : AppColors.surfaceSunken,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            children: [
                              Icon(types[i].$1,
                                  size: 18,
                                  color: active ? Colors.white : AppColors.inkSoft),
                              const SizedBox(height: 5),
                              Text(
                                types[i].$2,
                                style: AppText.tiny.copyWith(
                                  fontSize: 8.5,
                                  color: active ? Colors.white : AppColors.inkSoft,
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
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: _numField(sets, 'Sets')),
                  const SizedBox(width: 9),
                  Expanded(child: _numField(reps, 'Reps')),
                  const SizedBox(width: 9),
                  Expanded(child: _numField(weight, 'Weight (kg)')),
                  const SizedBox(width: 9),
                  Expanded(child: _numField(minutes, 'Minutes')),
                ],
              ),
              const SizedBox(height: 18),
              AppButton(
                label: 'Add to today\'s workout',
                onTap: () {
                  if (name.text.trim().isEmpty) {
                    appToast(context, 'Give the exercise a name',
                        icon: Icons.info_outline_rounded);
                    return;
                  }
                  state.addExercise(Exercise(
                    name: name.text.trim(),
                    detail: '${types[type].$2} · custom',
                    sets: int.tryParse(sets.text) ?? 3,
                    reps: int.tryParse(reps.text) ?? 10,
                    weight: double.tryParse(weight.text) ?? 0,
                    minutes: int.tryParse(minutes.text) ?? 10,
                    icon: types[type].$1,
                  ));
                  Navigator.of(context).pop();
                  appToast(context, '${name.text.trim()} added',
                      icon: Icons.check_circle_outline_rounded);
                },
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  'Tip: swipe left on a row to remove it.',
                  style: AppText.tiny.copyWith(fontSize: 9.5),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

Widget _numField(TextEditingController controller, String label) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppText.tiny.copyWith(fontSize: 9)),
      const SizedBox(height: 5),
      TextField(
        controller: controller,
        textAlign: TextAlign.center,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: AppText.bodyStrong.copyWith(fontSize: 14),
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        ),
      ),
    ],
  );
}
