import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../theme/app_theme.dart';
import '../ui/layout.dart';
import '../widgets/common.dart';
import 'help_screen.dart';
import 'subscription_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _height = TextEditingController(text: '178');
  final _weight = TextEditingController(text: '78.7');
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    final state = AppScope.of(context);
    _name.text = state.name;
    _email.text = state.email;
    _phone.text = state.phone ?? '';
    _loaded = true;
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _height.dispose();
    _weight.dispose();
    super.dispose();
  }

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
            const ScreenHeader(title: 'Settings', subtitle: 'Account, body metrics & alerts'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                children: [
                  const SectionHeader(title: 'Account'),
                  const SizedBox(height: 8),
                  AppCard(
                    child: Column(
                      children: [
                        _field('Full name', _name),
                        const SizedBox(height: 10),
                        _field('Email', _email, keyboard: TextInputType.emailAddress),
                        const SizedBox(height: 10),
                        _field('Phone', _phone),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const SectionHeader(title: 'Body metrics'),
                  const SizedBox(height: 8),
                  AppCard(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: _field('Height (cm)', _height, numeric: true)),
                            const SizedBox(width: 10),
                            Expanded(child: _field('Weight (kg)', _weight, numeric: true)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSunken,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calculate_outlined,
                                  size: 16, color: AppColors.greenDeep),
                              const SizedBox(width: 8),
                              Text(
                                'BMI 24.8 · healthy range',
                                style: AppText.small.copyWith(
                                  fontSize: 11,
                                  color: AppColors.inkSoft,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const SectionHeader(title: 'Notifications'),
                  const SizedBox(height: 8),
                  AppCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Column(
                      children: [
                        _toggle(
                          'Workout reminders',
                          'A nudge at your usual training time',
                          state.reminders,
                          (v) => state.setAlerts(reminders: v),
                        ),
                        const Divider(),
                        _toggle(
                          'Goal check-ins',
                          'Weekly progress digest',
                          state.goalCheckIns,
                          (v) => state.setAlerts(goalCheckIns: v),
                        ),
                        const Divider(),
                        _toggle(
                          'Renewal alerts',
                          'Before your plan renews',
                          state.renewalAlerts,
                          (v) => state.setAlerts(renewalAlerts: v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const SectionHeader(title: 'Membership'),
                  const SizedBox(height: 8),
                  AppCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Column(
                      children: [
                        InfoRow(
                          icon: Icons.card_membership_rounded,
                          title: state.isPremium ? 'Premium plan' : 'General plan',
                          subtitle: state.isPremium
                              ? 'Unlimited coaching & video library'
                              : 'Upgrade for coaching and meal plans',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
                          ),
                        ),
                        const Divider(),
                        InfoRow(
                          icon: Icons.receipt_long_rounded,
                          title: 'Payment history',
                          subtitle: 'Invoices and receipts',
                          onTap: () => appToast(context, 'Invoices are emailed monthly',
                              icon: Icons.mail_outline_rounded),
                        ),
                        const Divider(),
                        InfoRow(
                          icon: Icons.help_outline_rounded,
                          title: 'Help & support',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const HelpScreen()),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  AppButton(
                    label: 'Save changes',
                    icon: Icons.check_rounded,
                    trailing: false,
                    onTap: () {
                      state.updateProfile(
                        name: _name.text.trim().isEmpty ? null : _name.text.trim(),
                        email: _email.text.trim().isEmpty ? null : _email.text.trim(),
                        phone: _phone.text.trim(),
                      );
                      appToast(context, 'Settings saved',
                          icon: Icons.check_circle_rounded);
                    },
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: TextButton(
                      onPressed: () => _deleteAccount(context),
                      child: Text(
                        'Delete account',
                        style: AppText.small.copyWith(
                          fontSize: 11.5,
                          color: AppColors.danger,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    TextInputType? keyboard,
    bool numeric = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 5),
          child: Text(label.toUpperCase(),
              style: AppText.label.copyWith(fontSize: 8.5, letterSpacing: 0.9)),
        ),
        TextField(
          controller: controller,
          keyboardType: keyboard ?? (numeric ? TextInputType.number : null),
          decoration: const InputDecoration(isDense: true),
        ),
      ],
    );
  }

  Widget _toggle(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.bodyStrong.copyWith(fontSize: 13)),
                const SizedBox(height: 2),
                Text(subtitle, style: AppText.tiny.copyWith(fontSize: 9.5)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.green,
            activeThumbColor: Colors.white,
          ),
        ],
      ),
    );
  }

  void _deleteAccount(BuildContext context) {
    showAppSheet(
      context,
      Padding(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Delete account?', style: AppText.h2.copyWith(fontSize: 19)),
            const SizedBox(height: 8),
            Text(
              'This removes your history, goals and coaching threads. This cannot be undone.',
              textAlign: TextAlign.center,
              style: AppText.small.copyWith(fontSize: 12, height: 1.5),
            ),
            const SizedBox(height: 18),
            AppButton(
              label: 'Keep my account',
              onTap: () => Navigator.of(context).pop(),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                appToast(context, 'Deletion request sent to support',
                    icon: Icons.info_outline_rounded);
              },
              child: Text(
                'Continue deleting',
                style: AppText.small.copyWith(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
