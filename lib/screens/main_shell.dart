import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/app_state.dart';
import '../theme/app_theme.dart';
import '../ui/layout.dart';
import '../widgets/brand.dart';
import 'goals_screen.dart';
import 'home_screen.dart';
import 'menu_screen.dart';
import 'profile_screen.dart';
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
    (
      Icons.play_circle_fill_rounded,
      Icons.play_circle_outline_rounded,
      'Videos',
    ),
    (Icons.flag_rounded, Icons.flag_outlined, 'Goals'),
    (Icons.grid_view_rounded, Icons.grid_view_outlined, 'Menu'),
  ];

  List<Widget> _pages() => [
    HomeScreen(onTab: (i) => setState(() => _index = i)),
    const WorkoutsScreen(),
    const VideosScreen(),
    const GoalsScreen(),
    const MenuScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final desktop = AppLayout.isDesktop(context);
    final pages = _pages();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: desktop
          ? Scaffold(
              backgroundColor: AppColors.bg,
              body: Row(
                children: [
                  _DesktopRail(
                    index: _index,
                    tabs: _tabs,
                    onSelect: (i) => setState(() => _index = i),
                  ),
                  Expanded(
                    child: IndexedStack(
                      index: _index,
                      children: [
                        pages[0],
                        for (final page in pages.skip(1))
                          DesktopPage(child: page),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : Scaffold(
              extendBody: true,
              body: IndexedStack(index: _index, children: pages),
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
                    border: Border.all(
                      color: AppColors.line.withValues(alpha: 0.7),
                    ),
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
                                  color: active
                                      ? AppColors.greenDeep
                                      : AppColors.muted,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                tab.$3,
                                style: AppText.tiny.copyWith(
                                  fontSize: 8.5,
                                  fontWeight: active
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: active
                                      ? AppColors.greenDeep
                                      : AppColors.muted,
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

class _DesktopRail extends StatelessWidget {
  const _DesktopRail({
    required this.index,
    required this.tabs,
    required this.onSelect,
  });

  final int index;
  final List<(IconData, IconData, String)> tabs;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Container(
      width: 252,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        right: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 26),
              child: Row(
                children: const [
                  BrandMark(size: 38, glow: true),
                  SizedBox(width: 11),
                  BrandWordmark(fontSize: 13, letterSpacing: 1.1),
                ],
              ),
            ),
            for (var i = 0; i < tabs.length; i++)
              _RailItem(
                icon: tabs[i].$2,
                activeIcon: tabs[i].$1,
                label: tabs[i].$3,
                active: i == index,
                onTap: () => onSelect(i),
              ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _RailStreak(state: state),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 8, 18),
              child: Row(
                children: [
                  Expanded(child: _RailProfileRow(state: state)),
                  IconButton(
                    tooltip: 'Settings',
                    onPressed: () => onSelect(4),
                    icon: const Icon(
                      Icons.settings_outlined,
                      size: 18,
                      color: AppColors.muted,
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

class _RailProfileRow extends StatefulWidget {
  const _RailProfileRow({required this.state});

  final AppState state;

  @override
  State<_RailProfileRow> createState() => _RailProfileRowState();
}

class _RailProfileRowState extends State<_RailProfileRow> {
  bool _hover = false;

  void _openProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Semantics(
        button: true,
        label: 'Open profile',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _openProfile,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            decoration: BoxDecoration(
              color: _hover
                  ? AppColors.green.withValues(alpha: 0.08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1D4A33), Color(0xFF0D2A1D)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      state.name.isEmpty
                          ? 'A'
                          : state.name.characters.first.toUpperCase(),
                      style: AppText.h3.copyWith(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.name,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.label.copyWith(
                          fontSize: 12,
                          color: _hover ? AppColors.greenDeep : null,
                        ),
                      ),
                      Text(
                        state.isPremium ? 'Premium plan' : 'General plan',
                        style: AppText.tiny.copyWith(fontSize: 9.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RailItem extends StatefulWidget {
  const _RailItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  State<_RailItem> createState() => _RailItemState();
}

class _RailItemState extends State<_RailItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.active;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: active
                  ? AppColors.green.withValues(alpha: 0.12)
                  : _hover
                  ? AppColors.surfaceSunken
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(
                  active ? widget.activeIcon : widget.icon,
                  size: 19,
                  color: active ? AppColors.greenDeep : AppColors.muted,
                ),
                const SizedBox(width: 12),
                Text(
                  widget.label,
                  style: AppText.label.copyWith(
                    fontSize: 12.5,
                    color: active ? AppColors.greenDeep : AppColors.inkSoft,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RailStreak extends StatelessWidget {
  const _RailStreak({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B211A), Color(0xFF123B29)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_fire_department_rounded,
                size: 16,
                color: AppColors.lime,
              ),
              const SizedBox(width: 6),
              Text(
                '${state.streak}-day streak',
                style: AppText.label.copyWith(
                  color: Colors.white,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: state.todayProgress,
              minHeight: 5,
              backgroundColor: Colors.white.withValues(alpha: 0.14),
              valueColor: const AlwaysStoppedAnimation(AppColors.greenBright),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            '${state.completedToday} of ${state.todayWorkout.length} exercises today',
            style: AppText.tiny.copyWith(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}
