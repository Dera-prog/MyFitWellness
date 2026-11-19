import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/common.dart';

class _Meal {
  const _Meal(this.slot, this.name, this.kcal, this.protein, this.icon);

  final String slot;
  final String name;
  final int kcal;
  final int protein;
  final IconData icon;
}

class _DayPlan {
  const _DayPlan(this.kcal, this.protein, this.carbs, this.fat, this.meals);

  final int kcal;
  final int protein;
  final int carbs;
  final int fat;
  final List<_Meal> meals;
}

const _plans = <_DayPlan>[
  _DayPlan(2080, 162, 214, 62, [
    _Meal('Breakfast · 07:30', 'Greek yogurt, oats & berries', 420, 32, Icons.breakfast_dining_rounded),
    _Meal('Lunch · 12:30', 'Grilled chicken, rice & greens', 610, 48, Icons.lunch_dining_rounded),
    _Meal('Snack · 16:00', 'Protein shake + almonds', 260, 27, Icons.local_cafe_rounded),
    _Meal('Dinner · 19:30', 'Salmon, sweet potato & broccoli', 790, 55, Icons.dinner_dining_rounded),
  ]),
  _DayPlan(2120, 168, 226, 60, [
    _Meal('Breakfast · 07:30', 'Egg white omelette & toast', 440, 34, Icons.breakfast_dining_rounded),
    _Meal('Lunch · 12:30', 'Turkey wrap & side salad', 580, 42, Icons.lunch_dining_rounded),
    _Meal('Snack · 16:00', 'Cottage cheese & pineapple', 240, 24, Icons.local_cafe_rounded),
    _Meal('Dinner · 19:30', 'Lean beef stir-fry & quinoa', 860, 68, Icons.dinner_dining_rounded),
  ]),
  _DayPlan(2040, 158, 208, 64, [
    _Meal('Breakfast · 07:30', 'Overnight oats & peanut butter', 460, 26, Icons.breakfast_dining_rounded),
    _Meal('Lunch · 12:30', 'Tuna poke bowl', 590, 46, Icons.lunch_dining_rounded),
    _Meal('Snack · 16:00', 'Apple & string cheese', 210, 12, Icons.local_cafe_rounded),
    _Meal('Dinner · 19:30', 'Chicken thigh traybake', 780, 62, Icons.dinner_dining_rounded),
  ]),
  _DayPlan(2100, 164, 220, 61, [
    _Meal('Breakfast · 07:30', 'Protein pancakes & banana', 480, 33, Icons.breakfast_dining_rounded),
    _Meal('Lunch · 12:30', 'Chickpea & feta salad bowl', 560, 26, Icons.lunch_dining_rounded),
    _Meal('Snack · 16:00', 'Greek yogurt & honey', 230, 20, Icons.local_cafe_rounded),
    _Meal('Dinner · 19:30', 'Turkey meatballs & pasta', 830, 58, Icons.dinner_dining_rounded),
  ]),
  _DayPlan(2060, 160, 212, 63, [
    _Meal('Breakfast · 07:30', 'Scrambled eggs & avocado toast', 470, 28, Icons.breakfast_dining_rounded),
    _Meal('Lunch · 12:30', 'Grilled prawn rice bowl', 600, 44, Icons.lunch_dining_rounded),
    _Meal('Snack · 16:00', 'Trail mix & espresso', 250, 9, Icons.local_cafe_rounded),
    _Meal('Dinner · 19:30', 'Steak, potatoes & asparagus', 740, 62, Icons.dinner_dining_rounded),
  ]),
  _DayPlan(2180, 170, 232, 66, [
    _Meal('Breakfast · 08:30', 'Banana protein smoothie', 450, 35, Icons.breakfast_dining_rounded),
    _Meal('Lunch · 13:00', 'Chicken burrito bowl', 640, 50, Icons.lunch_dining_rounded),
    _Meal('Snack · 16:30', 'Rice cakes & cottage cheese', 240, 22, Icons.local_cafe_rounded),
    _Meal('Dinner · 20:00', 'Baked cod, couscous & veg', 850, 60, Icons.dinner_dining_rounded),
  ]),
  _DayPlan(1980, 150, 200, 62, [
    _Meal('Breakfast · 08:30', 'Shakshuka & sourdough', 460, 24, Icons.breakfast_dining_rounded),
    _Meal('Lunch · 13:00', 'Miso salmon rice bowl', 620, 46, Icons.lunch_dining_rounded),
    _Meal('Snack · 16:30', 'Protein bar & green tea', 220, 20, Icons.local_cafe_rounded),
    _Meal('Dinner · 20:00', 'Veggie lentil curry', 680, 30, Icons.dinner_dining_rounded),
  ]),
];

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  int _day = DateTime.now().weekday - 1;
  final Set<int> _checked = {};
  final Set<int> _swapped = {};
  int _glasses = 5;

  static const _days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
  static const _shopping = [
    'Chicken breast · 1.2 kg',
    'Greek yogurt · 6 cups',
    'Rolled oats · 500 g',
    'Salmon fillets · 3',
    'Mixed greens · 2 bags',
    'Almonds · 250 g',
  ];

  @override
  Widget build(BuildContext context) {
    final plan = _plans[_day];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const ScreenHeader(
              title: 'Meal plan',
              subtitle: 'Built around your training load',
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 32),
                children: [
                  SizedBox(
                    height: 56,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _days.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 7),
                      itemBuilder: (context, i) {
                        final active = i == _day;
                        return GestureDetector(
                          onTap: () => setState(() => _day = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 52,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: active ? AppColors.ink : AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: active ? AppColors.ink : AppColors.line,
                              ),
                            ),
                            child: Text(
                              _days[i],
                              style: AppText.tiny.copyWith(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.7,
                                color: active ? Colors.white : AppColors.muted,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Column(
                      key: ValueKey(_day),
                      children: [
                        _MacroCard(plan: plan),
                        const SizedBox(height: 18),
                        SectionHeader(
                          title: 'Today\'s meals',
                          action: '${plan.meals.length} meals',
                        ),
                        const SizedBox(height: 10),
                        ...List.generate(plan.meals.length, (i) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 9),
                            child: _MealCard(
                              meal: plan.meals[i],
                              swapped: _swapped.contains(i),
                              onSwap: () => setState(() {
                                if (!_swapped.remove(i)) _swapped.add(i);
                                appToast(
                                  context,
                                  _swapped.contains(i)
                                      ? 'Swapped for a vegetarian option'
                                      : 'Restored the original meal',
                                  icon: Icons.swap_horiz_rounded,
                                );
                              }),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _WaterCard(
                    glasses: _glasses,
                    onAdd: () => setState(() => _glasses = (_glasses + 1).clamp(0, 8)),
                  ),
                  const SizedBox(height: 18),
                  const SectionHeader(title: 'Shopping list'),
                  const SizedBox(height: 8),
                  AppCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Column(
                      children: List.generate(_shopping.length, (i) {
                        final checked = _checked.contains(i);
                        return InkWell(
                          onTap: () => setState(() {
                            if (!_checked.remove(i)) _checked.add(i);
                          }),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: [
                                AnimatedCheckbox(checked: checked, size: 22),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _shopping[i],
                                    style: AppText.bodyStrong.copyWith(
                                      fontSize: 12,
                                      color: checked ? AppColors.muted : AppColors.ink,
                                      decoration:
                                          checked ? TextDecoration.lineThrough : null,
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
                  const SizedBox(height: 18),
                  AppButton(
                    label: 'Ask your nutritionist',
                    variant: ButtonVariant.dark,
                    trailing: false,
                    onTap: () => Navigator.of(context).pop(),
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

class _MacroCard extends StatelessWidget {
  const _MacroCard({required this.plan});

  final _DayPlan plan;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B211A), Color(0xFF16452F)],
        ),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${plan.kcal}',
                    style: AppText.display.copyWith(color: Colors.white, fontSize: 34),
                  ),
                  Text(
                    'KCAL TODAY · TARGET 2,100',
                    style: AppText.tiny.copyWith(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.lime.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bolt_rounded, size: 13, color: AppColors.lime),
                    const SizedBox(width: 4),
                    Text(
                      'On target',
                      style: AppText.tiny.copyWith(
                        color: AppColors.lime,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _macro('Protein', plan.protein, 180, AppColors.greenBright),
              const SizedBox(width: 10),
              _macro('Carbs', plan.carbs, 260, AppColors.lime),
              const SizedBox(width: 10),
              _macro('Fat', plan.fat, 80, const Color(0xFF7DB3E8)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _macro(String label, int value, int target, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '$value g',
                style: AppText.h3.copyWith(color: Colors.white, fontSize: 14),
              ),
              const Spacer(),
              Text(
                '${(value / target * 100).round()}%',
                style: AppText.tiny.copyWith(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 8.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: (value / target).clamp(0.0, 1.0),
              minHeight: 5,
              backgroundColor: Colors.white.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: AppText.tiny.copyWith(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 8.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  const _MealCard({required this.meal, required this.swapped, required this.onSwap});

  final _Meal meal;
  final bool swapped;
  final VoidCallback onSwap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: swapped
                  ? AppColors.amber.withValues(alpha: 0.12)
                  : AppColors.green.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              swapped ? Icons.eco_rounded : meal.icon,
              size: 20,
              color: swapped ? AppColors.amber : AppColors.greenDeep,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.slot,
                  style: AppText.tiny.copyWith(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  swapped ? 'Vegetarian alternative bowl' : meal.name,
                  style: AppText.bodyStrong.copyWith(fontSize: 12.5),
                ),
                const SizedBox(height: 3),
                Text(
                  '${swapped ? meal.kcal - 30 : meal.kcal} kcal · ${meal.protein} g protein',
                  style: AppText.tiny.copyWith(fontSize: 9.5),
                ),
              ],
            ),
          ),
          AppIconButton(
            icon: Icons.swap_horiz_rounded,
            size: 34,
            onTap: onSwap,
          ),
        ],
      ),
    );
  }
}

class _WaterCard extends StatelessWidget {
  const _WaterCard({required this.glasses, required this.onAdd});

  final int glasses;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.water_drop_rounded, size: 17, color: Color(0xFF2E8BD8)),
              const SizedBox(width: 7),
              Text('Water', style: AppText.h3.copyWith(fontSize: 14)),
              const Spacer(),
              GestureDetector(
                onTap: onAdd,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E8BD8).withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    '+ 1 glass',
                    style: AppText.tiny.copyWith(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2E8BD8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(8, (i) {
              final filled = i < glasses;
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  height: 34,
                  margin: EdgeInsets.only(right: i == 7 ? 0 : 5),
                  decoration: BoxDecoration(
                    color: filled
                        ? const Color(0xFF2E8BD8).withValues(alpha: 0.16)
                        : AppColors.surfaceSunken,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.local_drink_rounded,
                    size: 15,
                    color: filled ? const Color(0xFF2E8BD8) : AppColors.line,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text('$glasses of 8 glasses · ${glasses * 250} ml',
              style: AppText.tiny.copyWith(fontSize: 9.5)),
        ],
      ),
    );
  }
}
