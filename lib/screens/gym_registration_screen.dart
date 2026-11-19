import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/circular_reveal_route.dart';
import '../widgets/common.dart';
import 'main_shell.dart';
import 'subscription_screen.dart';

class GymRegistrationScreen extends StatefulWidget {
  const GymRegistrationScreen({super.key});

  @override
  State<GymRegistrationScreen> createState() => _GymRegistrationScreenState();
}

class _GymRegistrationScreenState extends State<GymRegistrationScreen> {
  int _selected = -1;
  bool _codeMode = false;
  final _code = TextEditingController();
  final _memberId = TextEditingController();

  static const _gyms = [
    ('Iron House Fitness', 'Lekki Phase 1 · 2.4 km', 'IHF-2201'),
    ('Pulse & Power Gym', 'Victoria Island · 4.1 km', 'PPG-1044'),
    ('The Forge Athletic Club', 'Ikoyi · 6.8 km', 'FAC-8820'),
    ('Anytime Fitness, Yaba', 'Yaba · 8.2 km', 'AFY-3312'),
  ];

  @override
  void dispose() {
    _code.dispose();
    _memberId.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.green.withValues(alpha: 0.16),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Row(
                    children: [
                      AppIconButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => Navigator.of(context).maybePop(),
                      ),
                      const Spacer(),
                      const StepDots(current:1, total:3),
                      const Spacer(),
                      TextButton(
                        onPressed: () => Navigator.of(context).pushReplacement(
                          CircularRevealRoute(
                            originColor: AppColors.bg,
                            builder: (_) => const MainShell(),
                          ),
                        ),
                        child: Text('Skip',
                            style: AppText.label.copyWith(
                                color: AppColors.muted, letterSpacing: 0)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 10, 24, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SlideFadeIn(
                          child: Text('Register with\nyour gym',
                              style: AppText.display.copyWith(fontSize: 34, height: 1.08)),
                        ),
                        const SizedBox(height: 10),
                        SlideFadeIn(
                          delay: const Duration(milliseconds: 80),
                          child: Text(
                            'Link your membership so check-ins, classes and trainer bookings stay in sync.',
                            style: AppText.body.copyWith(fontSize: 13.5),
                          ),
                        ),
                        const SizedBox(height: 22),
                        _ModeSwitch(
                          codeMode: _codeMode,
                          onChanged: (v) => setState(() => _codeMode = v),
                        ),
                        const SizedBox(height: 16),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 280),
                          alignment: Alignment.topCenter,
                          child: _codeMode
                              ? _CodeEntry(code: _code, memberId: _memberId, onFind: _fakeFind)
                              : Column(
                                  children: [
                                    ...List.generate(_gyms.length, (i) {
                                      final gym = _gyms[i];
                                      return SlideFadeIn(
                                        delay: Duration(milliseconds: 130 + i * 60),
                                        child: Padding(
                                          padding: const EdgeInsets.only(bottom: 10),
                                          child: _GymTile(
                                            name: gym.$1,
                                            distance: gym.$2,
                                            code: gym.$3,
                                            selected: _selected == i,
                                            onTap: () => setState(() => _selected = i),
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.navy.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.verified_user_outlined,
                                  size: 18, color: AppColors.navy),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Membership is verified directly with your gym. We never store your gym PIN.',
                                  style: AppText.tiny.copyWith(fontSize: 10.5, height: 1.45),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      24, 0, 24, MediaQuery.paddingOf(context).bottom + 18),
                  child: AppButton(
                    label: 'Continue',
                    onTap: () {
                      if (!_codeMode && _selected < 0) {
                        appToast(context, 'Select your gym to continue',
                            icon: Icons.info_outline_rounded);
                        return;
                      }
                      AppScope.of(context).gym =
                          _codeMode ? 'Gym code · ${_code.text}' : _gyms[_selected].$1;
                      Navigator.of(context).pushReplacement(
                        CircularRevealRoute(
                          originColor: AppColors.bg,
                          builder: (_) => const SubscriptionScreen(),
                        ),
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

  void _fakeFind() {
    setState(() {
      _selected = 0;
      _codeMode = false;
      appToast(context, 'Gym found — ${_code.text.toUpperCase()}',
          icon: Icons.check_circle_outline_rounded);
    });
  }
}

class _ModeSwitch extends StatelessWidget {
  const _ModeSwitch({required this.codeMode, required this.onChanged});

  final bool codeMode;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _pill('Find my gym', !codeMode, () => onChanged(false)),
        const SizedBox(width: 8),
        _pill('I have a code', codeMode, () => onChanged(true)),
      ],
    );
  }

  Widget _pill(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
        decoration: BoxDecoration(
          color: active ? AppColors.ink : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: active ? AppColors.ink : AppColors.line),
        ),
        child: Text(
          label,
          style: AppText.label.copyWith(
            color: active ? Colors.white : AppColors.inkSoft,
            fontSize: 11,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _GymTile extends StatelessWidget {
  const _GymTile({
    required this.name,
    required this.distance,
    required this.code,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final String distance;
  final String code;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.green.withValues(alpha: 0.07) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppColors.green : AppColors.line,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: AppColors.greenGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.fitness_center_rounded, color: Colors.white, size: 21),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppText.bodyStrong.copyWith(fontSize: 13.5)),
                  const SizedBox(height: 2),
                  Text(distance, style: AppText.tiny.copyWith(fontSize: 10.5)),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.green : Colors.transparent,
                border: Border.all(
                  color: selected ? AppColors.green : AppColors.line,
                  width: 1.6,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _CodeEntry extends StatelessWidget {
  const _CodeEntry({required this.code, required this.memberId, required this.onFind});

  final TextEditingController code;
  final TextEditingController memberId;
  final VoidCallback onFind;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: code,
          textCapitalization: TextCapitalization.characters,
          style: AppText.bodyStrong.copyWith(fontSize: 14, letterSpacing: 1.4),
          decoration: const InputDecoration(
            hintText: 'Gym code (e.g. IHF-2201)',
            prefixIcon: Padding(
              padding: EdgeInsets.only(left: 6),
              child: Icon(Icons.qr_code_2_rounded, size: 20, color: AppColors.muted),
            ),
            prefixIconConstraints: BoxConstraints(minWidth: 44),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: memberId,
          style: AppText.bodyStrong.copyWith(fontSize: 14),
          decoration: const InputDecoration(
            hintText: 'Membership ID (optional)',
            prefixIcon: Padding(
              padding: EdgeInsets.only(left: 6),
              child: Icon(Icons.badge_outlined, size: 20, color: AppColors.muted),
            ),
            prefixIconConstraints: BoxConstraints(minWidth: 44),
          ),
        ),
        const SizedBox(height: 12),
        AppButton(
          label: 'Find Gym',
          variant: ButtonVariant.dark,
          height: 52,
          onTap: onFind,
        ),
      ],
    );
  }
}
