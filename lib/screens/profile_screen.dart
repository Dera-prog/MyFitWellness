import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../theme/app_theme.dart';
import '../ui/layout.dart';
import '../widgets/common.dart';
import 'auth_screen.dart';
import 'help_screen.dart';
import 'settings_screen.dart';
import 'subscription_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      body: WideFrame(
        maxWidth: 760,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const ScreenHeader(
                title: 'Profile',
                subtitle: 'Your account at a glance',
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                  children: [
                    _ProfileHero(state: state),
                    const SizedBox(height: 14),
                    _StatsCard(state: state),
                    const SizedBox(height: 20),
                    const SectionHeader(title: 'Account details'),
                    const SizedBox(height: 8),
                    AppCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 4,
                      ),
                      child: Column(
                        children: [
                          _Detail(
                            icon: Icons.alternate_email_rounded,
                            label: 'Email',
                            value: state.email,
                          ),
                          const Divider(),
                          _Detail(
                            icon: Icons.phone_outlined,
                            label: 'Phone',
                            value: (state.phone == null || state.phone!.isEmpty)
                                ? 'Not added'
                                : state.phone!,
                          ),
                          const Divider(),
                          _Detail(
                            icon: Icons.fitness_center_rounded,
                            label: 'Gym',
                            value: state.gym,
                          ),
                          const Divider(),
                          _Detail(
                            icon: Icons.card_membership_rounded,
                            label: 'Plan',
                            value: state.isPremium ? 'Premium' : 'General',
                          ),
                          if (state.joinedAt != null) ...[
                            const Divider(),
                            _Detail(
                              icon: Icons.calendar_today_rounded,
                              label: 'Member since',
                              value: _monthYear(state.joinedAt!),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const SectionHeader(title: 'Manage'),
                    const SizedBox(height: 8),
                    AppCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Column(
                        children: [
                          InfoRow(
                            icon: Icons.edit_outlined,
                            title: 'Edit profile',
                            subtitle: 'Name, body metrics, alerts',
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SettingsScreen(),
                              ),
                            ),
                          ),
                          const Divider(),
                          InfoRow(
                            icon: Icons.credit_card_rounded,
                            title: 'Billing & plan',
                            subtitle: state.isPremium
                                ? 'Premium · ${state.annualBilling ? "annual" : "monthly"}'
                                : 'General · upgrade anytime',
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SubscriptionScreen(),
                              ),
                            ),
                          ),
                          const Divider(),
                          InfoRow(
                            icon: Icons.help_outline_rounded,
                            title: 'Help & support',
                            subtitle: 'FAQs, contact the team',
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const HelpScreen(),
                              ),
                            ),
                          ),
                          const Divider(),
                          InfoRow(
                            icon: Icons.logout_rounded,
                            title: 'Sign out',
                            iconColor: AppColors.danger,
                            trailing: const SizedBox.shrink(),
                            onTap: () => _confirmSignOut(context),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _DashboardPreviewCard(state: state),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showAppSheet(
      context,
      Padding(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: AppColors.danger,
                size: 24,
              ),
            ),
            const SizedBox(height: 14),
            Text('Sign out?', style: AppText.h2.copyWith(fontSize: 19)),
            const SizedBox(height: 6),
            Text(
              'Your plan and progress stay safe. You can sign back in anytime.',
              textAlign: TextAlign.center,
              style: AppText.small.copyWith(fontSize: 12, height: 1.5),
            ),
            const SizedBox(height: 20),
            AppButton(
              label: 'Sign out',
              variant: ButtonVariant.dark,
              onTap: () {
                AppScope.of(context).signOut();
                Navigator.of(context).pop();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const AuthScreen()),
                  (route) => false,
                );
              },
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Stay here',
                style: AppText.small.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B211A), Color(0xFF123B29)],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: AppShadows.float,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    state.name.isEmpty
                        ? 'A'
                        : state.name.characters.first.toUpperCase(),
                    style: AppText.h1.copyWith(
                      color: Colors.white,
                      fontSize: 26,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.name,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.h2.copyWith(
                        color: Colors.white,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      state.email,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.small.copyWith(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 11.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _HeroChip(
                          icon: state.isPremium
                              ? Icons.workspace_premium_rounded
                              : Icons.person_rounded,
                          label: state.isPremium ? 'Premium' : 'General',
                          highlight: state.isPremium,
                        ),
                        const SizedBox(width: 7),
                        Flexible(
                          child: _HeroChip(
                            icon: Icons.fitness_center_rounded,
                            label: state.gym,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.10)),
          const SizedBox(height: 14),
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
              const Spacer(),
              AppButton(
                label: 'Edit',
                icon: Icons.edit_outlined,
                height: 40,
                expanded: false,
                trailing: false,
                variant: ButtonVariant.light,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({
    required this.icon,
    required this.label,
    this.highlight = false,
  });

  final IconData icon;
  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final color = highlight
        ? AppColors.lime
        : Colors.white.withValues(alpha: 0.72);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: highlight ? 0.14 : 0.08),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label.toUpperCase(),
              overflow: TextOverflow.ellipsis,
              style: AppText.tiny.copyWith(
                color: color,
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.7,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: StatPill(
              value: '${state.totalSessions}',
              label: 'sessions',
              icon: Icons.fitness_center_rounded,
            ),
          ),
          Container(width: 1, height: 34, color: AppColors.line),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: StatPill(
                value: '${state.totalMinutes}',
                label: 'active min',
                icon: Icons.timer_outlined,
              ),
            ),
          ),
          Container(width: 1, height: 34, color: AppColors.line),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: StatPill(
                value: '${state.goals.length}',
                label: 'goals',
                icon: Icons.flag_rounded,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.muted),
          const SizedBox(width: 12),
          Text(label, style: AppText.small.copyWith(fontSize: 11.5)),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: AppText.bodyStrong.copyWith(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardPreviewCard extends StatelessWidget {
  const _DashboardPreviewCard({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final chips = <(DashboardPreview, String, String)>[
      (DashboardPreview.auto, 'Auto', 'By account'),
      (DashboardPreview.newUser, 'New user', 'Empty state'),
      (DashboardPreview.general, 'General', 'Standard'),
      (DashboardPreview.premium, 'Premium', 'Coaching'),
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.visibility_outlined,
                size: 18,
                color: AppColors.greenDeep,
              ),
              const SizedBox(width: 8),
              Text(
                'Dashboard preview',
                style: AppText.bodyStrong.copyWith(fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Flip the Home dashboard between account states. This only changes '
            'what you see here.',
            style: AppText.small.copyWith(fontSize: 11.5, height: 1.45),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final chip in chips)
                Pressable(
                  onTap: () => state.setDashboardPreview(chip.$1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: state.preview == chip.$1
                          ? AppColors.green.withValues(alpha: 0.12)
                          : AppColors.surfaceSunken,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(
                        color: state.preview == chip.$1
                            ? AppColors.green.withValues(alpha: 0.45)
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          chip.$2,
                          style: AppText.label.copyWith(
                            fontSize: 10.5,
                            letterSpacing: 0.1,
                            color: state.preview == chip.$1
                                ? AppColors.greenDeep
                                : AppColors.inkSoft,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          chip.$3,
                          style: AppText.tiny.copyWith(fontSize: 8.5),
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

String _monthYear(DateTime date) {
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
  return '${months[date.month - 1]} ${date.year}';
}
