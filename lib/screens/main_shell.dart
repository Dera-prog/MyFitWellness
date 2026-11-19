import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import 'goals_screen.dart';
import 'home_screen.dart';
import 'menu_screen.dart';
import 'videos_screen.dart';
import 'workouts_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index = widget.initialTab;

  static const _tabs = [
    (Icons.home_rounded, Icons.home_outlined, 'Home'),
    (Icons.fitness_center_rounded, Icons.fitness_center_outlined, 'Workouts'),
    (Icons.play_circle_fill_rounded, Icons.play_circle_outline_rounded, 'Videos'),
    (Icons.flag_rounded, Icons.flag_outlined, 'Goals'),
    (Icons.grid_view_rounded, Icons.grid_view_outlined, 'Menu'),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        extendBody: true,
        body: IndexedStack(
          index: _index,
          children: [
            HomeScreen(onTab: (i) => setState(() => _index = i)),
            const WorkoutsScreen(),
            const VideosScreen(),
            const GoalsScreen(),
            const MenuScreen(),
          ],
        ),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: AppColors.ink.withValues(alpha: 0.10),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
              border: Border.all(color: AppColors.line.withValues(alpha: 0.7)),
            ),
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final active = i == _index;
                final tab = _tabs[i];
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _index = i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 260),
                          curve: Curves.easeOutCubic,
                          width: active ? 44 : 32,
                          height: 30,
                          decoration: BoxDecoration(
                            color: active
                                ? AppColors.green.withValues(alpha: 0.12)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            active ? tab.$1 : tab.$2,
                            size: 21,
                            color: active ? AppColors.greenDeep : AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          tab.$3,
                          style: AppText.tiny.copyWith(
                            fontSize: 8.5,
                            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                            color: active ? AppColors.greenDeep : AppColors.muted,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
