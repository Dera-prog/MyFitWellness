import 'package:flutter/material.dart';

import '../screens/subscription_screen.dart';
import '../theme/app_theme.dart';
import 'common.dart';

/// Bottom-sheet gate shown wherever a Premium-only feature is tapped.
Future<void> showPremiumPaywall(
  BuildContext context, {
  required String feature,
  required String description,
}) {
  return showAppSheet(
    context,
    _PaywallSheet(feature: feature, description: description),
  );
}

class _PaywallSheet extends StatefulWidget {
  const _PaywallSheet({required this.feature, required this.description});

  final String feature;
  final String description;

  @override
  State<_PaywallSheet> createState() => _PaywallSheetState();
}

class _PaywallSheetState extends State<_PaywallSheet> {
  bool _upgrading = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 26),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              gradient: AppColors.greenGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.green.withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(Icons.workspace_premium_rounded,
                color: Colors.white, size: 30),
          ),
          const SizedBox(height: 16),
          Text(
            'Premium unlock',
            style: AppText.label.copyWith(
              color: AppColors.greenDeep,
              letterSpacing: 1.4,
              fontSize: 10.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(widget.feature, textAlign: TextAlign.center, style: AppText.h2),
          const SizedBox(height: 8),
          Text(
            widget.description,
            textAlign: TextAlign.center,
            style: AppText.small.copyWith(height: 1.5),
          ),
          const SizedBox(height: 18),
          const _Benefit(icon: Icons.smart_toy_rounded, text: 'AI coach + human trainers on demand'),
          const _Benefit(icon: Icons.restaurant_rounded, text: 'Personalised meal plans & macro tracking'),
          const _Benefit(icon: Icons.video_library_rounded, text: 'Full advanced video library'),
          const _Benefit(icon: Icons.timeline_rounded, text: 'Deep progress analytics & monthly reviews'),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.lime.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_offer_rounded, size: 16, color: AppColors.greenDeep),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'First month 50% off — \$7.49, then \$14.99/mo',
                    style: AppText.small.copyWith(
                      fontSize: 11.5,
                      color: AppColors.greenDeep,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppButton(
            label: _upgrading ? 'Opening plans…' : 'See Premium plans',
            loading: _upgrading,
            onTap: () async {
              setState(() => _upgrading = true);
              await Future<void>.delayed(const Duration(milliseconds: 220));
              if (!context.mounted) return;
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
              );
            },
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Not right now',
              style: AppText.small.copyWith(
                color: AppColors.muted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 17, color: AppColors.greenDeep),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: AppText.bodyStrong.copyWith(fontSize: 12.5)),
          ),
          const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.green),
        ],
      ),
    );
  }
}
