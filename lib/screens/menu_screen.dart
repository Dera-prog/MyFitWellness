import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/brand.dart';
import '../widgets/common.dart';
import '../widgets/paywall.dart';
import 'auth_screen.dart';
import 'coaching_screen.dart';
import 'help_screen.dart';
import 'meal_plan_screen.dart';
import 'nutritionist_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'subscription_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

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
                      Text('Menu', style: AppText.h1.copyWith(fontSize: 26)),
                      const SizedBox(height: 3),
                      Text(
                        'Your account & coaching',
                        style: AppText.small.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                AppIconButton(
                  icon: Icons.settings_outlined,
                  onTap: () => _push(context, const SettingsScreen()),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _ProfileCard(state: state),
            const SizedBox(height: 12),
            _MembershipCard(state: state),
            const SizedBox(height: 22),
            const SectionHeader(title: 'Premium coaching'),
            const SizedBox(height: 10),
            _CoachingGrid(state: state),
            const SizedBox(height: 22),
            const SectionHeader(title: 'Account'),
            const SizedBox(height: 6),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                children: [
                  InfoRow(
                    icon: Icons.person_outline_rounded,
                    title: 'Profile & body metrics',
                    subtitle: 'Name, height, weight, goals',
                    onTap: () => _push(context, const SettingsScreen()),
                  ),
                  const Divider(),
                  InfoRow(
                    icon: Icons.credit_card_rounded,
                    title: 'Billing & plan',
                    subtitle: state.isPremium
                        ? 'Premium · ${state.annualBilling ? "annual" : "monthly"}'
                        : 'General · upgrade anytime',
                    onTap: () => _push(context, const SubscriptionScreen()),
                  ),
                  const Divider(),
                  InfoRow(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifications',
                    subtitle: 'Reminders, check-ins, renewals',
                    onTap: () => _push(context, const SettingsScreen()),
                  ),
                  const Divider(),
                  InfoRow(
                    icon: Icons.help_outline_rounded,
                    title: 'Help & support',
                    subtitle: 'FAQs, contact the team',
                    onTap: () => _push(context, const HelpScreen()),
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
            const SizedBox(height: 24),
            const Center(child: BrandWordmark(fontSize: 18, dark: false)),
            const SizedBox(height: 6),
            Center(
              child: Text(
                'MyFitWellness · v1.0.0',
                style: AppText.tiny.copyWith(fontSize: 9.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
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

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      elevated: true,
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const ProfileScreen())),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
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
                style: AppText.h2.copyWith(color: Colors.white, fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(state.name, style: AppText.h3.copyWith(fontSize: 17)),
                const SizedBox(height: 2),
                Text(state.email, style: AppText.small.copyWith(fontSize: 11)),
                const SizedBox(height: 7),
                Row(
                  children: [
                    LevelChip(
                      label: state.isPremium ? 'Premium' : 'General',
                      color: state.isPremium
                          ? AppColors.greenDeep
                          : AppColors.muted,
                    ),
                    const SizedBox(width: 6),
                    LevelChip(
                      label: state.gym.split(' ').first,
                      color: AppColors.navy,
                    ),
                  ],
                ),
              ],
            ),
          ),
          AppIconButton(
            icon: Icons.edit_outlined,
            size: 38,
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
    );
  }
}

class _MembershipCard extends StatelessWidget {
  const _MembershipCard({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final price = state.isPremium
        ? (state.annualBilling ? '\$149 / year' : '\$14.99 / month')
        : (state.annualBilling ? '\$49 / year' : '\$4.99 / month');

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B211A), Color(0xFF123B29)],
        ),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.card_membership_rounded,
                size: 17,
                color: AppColors.lime,
              ),
              const SizedBox(width: 8),
              Text(
                state.isPremium ? 'PREMIUM MEMBER' : 'GENERAL MEMBER',
                style: AppText.tiny.copyWith(
                  color: AppColors.lime,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
              const Spacer(),
              Text(
                price,
                style: AppText.tiny.copyWith(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            state.isPremium
                ? 'Everything unlocked. Coaches, meal plans and the full library.'
                : 'Gym access, workouts, goals and progress tracking.',
            style: AppText.small.copyWith(
              color: Colors.white.withValues(alpha: 0.72),
              fontSize: 11.5,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    state.isPremium ? 'Manage plan' : 'Upgrade to Premium',
                    style: AppText.label.copyWith(
                      color: Colors.white,
                      fontSize: 10.5,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: AppColors.lime,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoachingGrid extends StatelessWidget {
  const _CoachingGrid({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        'Home trainer',
        'Trainer comes to you',
        Icons.sports_handball_rounded,
        const Color(0xFF1F5D4A),
        () => _pushPremium(context, const CoachingScreen(), 'Home trainer'),
      ),
      (
        'Nutritionist chat',
        'Message your dietitian',
        Icons.forum_rounded,
        const Color(0xFF7A4E2D),
        () => _pushPremium(
          context,
          const NutritionistScreen(),
          'Nutritionist chat',
        ),
      ),
      (
        'Meal plans',
        'Built around your macros',
        Icons.restaurant_menu_rounded,
        const Color(0xFF2C4A7A),
        () => _pushPremium(context, const MealPlanScreen(), 'Meal plans'),
      ),
      (
        'Coaching sessions',
        'Book your next block',
        Icons.calendar_month_rounded,
        const Color(0xFF6A3FB0),
        () =>
            _pushPremium(context, const CoachingScreen(), 'Coaching sessions'),
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
        mainAxisExtent: 122,
      ),
      itemBuilder: (context, i) {
        final item = items[i];
        final locked = !state.isPremium;

        return Pressable(
          onTap: () {
            if (locked) {
              showPremiumPaywall(
                context,
                feature: item.$1,
                description: '${item.$2} is included with Premium coaching.',
              );
            } else {
              item.$5();
            }
          },
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
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: item.$4.withValues(alpha: locked ? 0.08 : 0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        locked ? Icons.lock_outline_rounded : item.$3,
                        size: 18,
                        color: locked ? AppColors.muted : item.$4,
                      ),
                    ),
                    const Spacer(),
                    if (locked)
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 17,
                        color: AppColors.muted,
                      )
                    else
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
                  style: AppText.bodyStrong.copyWith(
                    fontSize: 12.5,
                    height: 1.25,
                  ),
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

  void _pushPremium(BuildContext context, Widget screen, String feature) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }
}
