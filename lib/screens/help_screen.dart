import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/common.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final _search = TextEditingController();
  int? _open;
  String _query = '';

  static const _faqs = [
    (
      'How do I pause or cancel my plan?',
      'Open Menu → Billing & plan and choose Manage plan. Cancelling keeps your access until the end of the current period, and your history stays available on the General plan.',
    ),
    (
      'Can I book a trainer to my home?',
      'Premium members can book a home trainer in Menu → Premium coaching. Choose At home, pick a day and a time slot. Rescheduling is free up to 24 hours before the session.',
    ),
    (
      'Why is a workout video locked?',
      'Advanced sessions and the nutrition library are part of Premium. General members keep the beginner and intermediate library, daily workouts and goal tracking.',
    ),
    (
      'How does the stopwatch pair with my watch?',
      'Open the stopwatch from Home and tap Connect device. Keep the watch awake and within a metre of your phone — pairing usually completes within two seconds.',
    ),
    (
      'How is my streak calculated?',
      'A day counts toward your streak when at least one planned workout is completed before midnight. Rest days set in your goals do not break the streak.',
    ),
  ];

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visible = _faqs
        .where((f) => _query.isEmpty ||
            f.$1.toLowerCase().contains(_query.toLowerCase()) ||
            f.$2.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const ScreenHeader(title: 'Help & support', subtitle: 'We answer within a day'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _ContactCard(
                          icon: Icons.forum_rounded,
                          label: 'Live chat',
                          sub: 'Fastest',
                          color: AppColors.green,
                          onTap: () => appToast(context, 'Support chat opened',
                              icon: Icons.forum_rounded),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ContactCard(
                          icon: Icons.mail_outline_rounded,
                          label: 'Email us',
                          sub: 'support@myfitwellness.com',
                          color: AppColors.navy,
                          onTap: () => appToast(context, 'Draft email opened',
                              icon: Icons.mail_outline_rounded),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _search,
                    onChanged: (v) => setState(() => _query = v),
                    decoration: const InputDecoration(
                      hintText: 'Search help articles',
                      prefixIcon: Icon(Icons.search_rounded, size: 20),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const SectionHeader(title: 'Common questions'),
                  const SizedBox(height: 10),
                  ...List.generate(visible.length, (i) {
                    final faq = visible[i];
                    final open = _open == i;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 240),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: open
                                ? AppColors.green.withValues(alpha: 0.5)
                                : AppColors.line,
                          ),
                        ),
                        child: Column(
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () => setState(() => _open = open ? null : i),
                              child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        faq.$1,
                                        style: AppText.bodyStrong.copyWith(fontSize: 12.5),
                                      ),
                                    ),
                                    AnimatedRotation(
                                      turns: open ? 0.5 : 0,
                                      duration: const Duration(milliseconds: 240),
                                      child: const Icon(Icons.expand_more_rounded,
                                          size: 20, color: AppColors.muted),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            AnimatedSize(
                              duration: const Duration(milliseconds: 260),
                              curve: Curves.easeOutCubic,
                              child: open
                                  ? Padding(
                                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                                      child: Text(
                                        faq.$2,
                                        style: AppText.small.copyWith(
                                          fontSize: 11.5,
                                          height: 1.55,
                                        ),
                                      ),
                                    )
                                  : const SizedBox(width: double.infinity),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  if (visible.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 26),
                      child: Column(
                        children: [
                          const Icon(Icons.search_off_rounded,
                              size: 30, color: AppColors.muted),
                          const SizedBox(height: 8),
                          Text('No articles match “$_query”',
                              style: AppText.small.copyWith(fontSize: 12)),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF0B211A), Color(0xFF16452F)],
                      ),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Still stuck?',
                          style: AppText.h3.copyWith(color: Colors.white, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Send us your account email and a screenshot — the team picks it up within one business day.',
                          style: AppText.small.copyWith(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 11,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 14),
                        AppButton(
                          label: 'Contact support',
                          height: 44,
                          variant: ButtonVariant.light,
                          trailing: false,
                          onTap: () => appToast(context, 'Support request created',
                              icon: Icons.check_circle_rounded),
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

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.icon,
    required this.label,
    required this.sub,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String sub;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.11),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(height: 10),
            Text(label, style: AppText.bodyStrong.copyWith(fontSize: 12.5)),
            const SizedBox(height: 2),
            Text(
              sub,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.tiny.copyWith(fontSize: 9.5),
            ),
          ],
        ),
      ),
    );
  }
}
