import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/circular_reveal_route.dart';
import '../widgets/common.dart';
import 'main_shell.dart';
import 'payment_screen.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  PlanType _plan = PlanType.premium;
  bool _annual = false;
  bool _manage = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final state = AppScope.of(context);
    if (state.plan != PlanType.general) {
      _manage = true;
      _plan = state.plan;
      _annual = state.annualBilling;
    }
  }

  double get _price => _plan == PlanType.premium
      ? (_annual ? 149 : 14.99)
      : (_annual ? 49 : 4.99);

  String get _priceLabel {
    if (_annual) return '\$${_price.toStringAsFixed(0)}/year';
    return '\$${_price.toStringAsFixed(2)}/month';
  }

  String _planName(PlanType plan) =>
      plan == PlanType.premium ? 'Premium' : 'General';

  String _renewalLabel(AppState state, {required bool annual}) {
    final start = state.planStartedAt ?? DateTime.now();
    var d = DateTime(start.year, start.month + (annual ? 12 : 1), start.day);
    final today = DateTime.now();
    while (!d.isAfter(today)) {
      d = DateTime(d.year, d.month + (annual ? 12 : 1), d.day);
    }
    return '${_months[d.month - 1]} ${d.day}, ${d.year}';
  }

  Future<bool> _confirm(String title, String body, String action) async {
    final result = await showAppSheet<bool>(
      context,
      Padding(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: AppText.h2.copyWith(fontSize: 19)),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: AppText.small.copyWith(fontSize: 12, height: 1.5),
            ),
            const SizedBox(height: 18),
            AppButton(
              label: action,
              onTap: () => Navigator.of(context).pop(true),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Never mind',
                style: AppText.small.copyWith(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    return result ?? false;
  }

  Future<void> _switchPlan(PlanType target) async {
    final state = AppScope.of(context);
    final annual = target == PlanType.premium ? _annual : false;
    final ok = await _confirm(
      'Switch to ${_planName(target)}?',
      target == PlanType.premium
          ? 'You\u2019ll be billed \$${(_annual ? 149 : 14.99).toStringAsFixed(_annual ? 0 : 2)} '
              '${_annual ? "per year" : "per month"} starting ${_renewalLabel(state, annual: _annual)}. '
              'Everything else stays the same.'
          : 'You\u2019ll move to the free General plan on ${_renewalLabel(state, annual: _annual)}. '
              'Coaching, home trainer and meal plans end at that point.',
      'Confirm switch',
    );
    if (!ok || !mounted) return;
    state.switchPlan(target, annual: annual);
    appToast(
      context,
      target == PlanType.premium
          ? 'Switched to Premium \u00b7 ${annual ? "annual" : "monthly"}'
          : 'Moved to the free General plan',
      icon: Icons.check_circle_rounded,
    );
    Navigator.of(context).maybePop();
  }

  Future<void> _cancelPlan() async {
    final state = AppScope.of(context);
    final ok = await _confirm(
      'Cancel subscription?',
      'You\u2019ll move to the free General plan right away. Premium workouts and coaching lock again immediately.',
      'Cancel subscription',
    );
    if (!ok || !mounted) return;
    state.cancelPlan();
    appToast(context, 'Subscription cancelled', icon: Icons.info_outline_rounded);
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final isCurrent = _manage &&
        _plan == state.plan &&
        _annual == state.annualBilling;

    return Scaffold(
      body: SafeArea(
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
                  if (!_manage) const StepDots(current: 2, total: 3),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      if (_manage) {
                        Navigator.of(context).maybePop();
                        return;
                      }
                      Navigator.of(context).pushReplacement(
                        CircularRevealRoute(
                          originColor: AppColors.bg,
                          builder: (_) => const MainShell(),
                        ),
                      );
                    },
                    child: Text(_manage ? 'Done' : 'Later',
                        style: AppText.label.copyWith(
                            color: AppColors.muted, letterSpacing: 0)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SlideFadeIn(
                      child: Text(_manage ? 'Manage your\nplan' : 'Choose your\nplan',
                          style: AppText.display.copyWith(fontSize: 34, height: 1.08)),
                    ),
                    const SizedBox(height: 8),
                    SlideFadeIn(
                      delay: const Duration(milliseconds: 70),
                      child: Text(
                        _manage
                            ? 'You\u2019re on ${_planName(state.plan)} \u00b7 '
                                '${state.annualBilling ? "annual" : "monthly"} billing, '
                                'renewing ${_renewalLabel(state, annual: state.annualBilling)}. '
                                'Switch or cancel anytime.'
                            : 'Start free for 7 days. Change or cancel whenever you like.',
                        style: AppText.body.copyWith(fontSize: 13.5),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _BillingToggle(
                      annual: _annual,
                      onChanged: (v) => setState(() => _annual = v),
                    ),
                    const SizedBox(height: 18),
                    SlideFadeIn(
                      delay: const Duration(milliseconds: 130),
                      child: _PlanCard(
                        plan: PlanType.general,
                        selected: _plan == PlanType.general,
                        annual: _annual,
                        onTap: () => setState(() => _plan = PlanType.general),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SlideFadeIn(
                      delay: const Duration(milliseconds: 200),
                      child: _PlanCard(
                        plan: PlanType.premium,
                        selected: _plan == PlanType.premium,
                        annual: _annual,
                        onTap: () => setState(() => _plan = PlanType.premium),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock_outline_rounded, size: 12, color: AppColors.muted),
                        const SizedBox(width: 5),
                        Text('Secured by Stripe · PCI DSS ready',
                            style: AppText.tiny.copyWith(fontSize: 9.5)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(
                  24, 12, 24, MediaQuery.paddingOf(context).bottom + 16),
              decoration: const BoxDecoration(
                color: AppColors.bg,
                border: Border(top: BorderSide(color: AppColors.line)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _planName(_plan),
                              style: AppText.h3.copyWith(fontSize: 15),
                            ),
                            Text(_priceLabel,
                                style: AppText.small.copyWith(fontSize: 11.5)),
                          ],
                        ),
                      ),
                      Text(
                        _annual ? 'Save 2 months' : 'Billed monthly',
                        style: AppText.tiny.copyWith(
                            color: AppColors.greenDeep, fontSize: 9.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (_manage && isCurrent)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.green.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppColors.green.withValues(alpha: 0.28)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              size: 18, color: AppColors.greenDeep),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Current plan \u00b7 renews ${_renewalLabel(state, annual: _annual)}',
                              style: AppText.small.copyWith(
                                fontSize: 11.5,
                                color: AppColors.greenDeep,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    AppButton(
                      label: _manage
                          ? 'Switch to ${_planName(_plan)}'
                          : (_plan == PlanType.premium
                              ? 'Continue to payment'
                              : 'Start with General'),
                      onTap: () {
                        if (_manage) {
                          _switchPlan(_plan);
                          return;
                        }
                        AppScope.of(context).setBilling(annual: _annual);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                PaymentScreen(plan: _plan, annual: _annual),
                          ),
                        );
                      },
                    ),
                  if (_manage)
                    TextButton(
                      onPressed: _cancelPlan,
                      child: Text(
                        'Cancel subscription',
                        style: AppText.small.copyWith(
                          color: AppColors.danger,
                          fontWeight: FontWeight.w600,
                        ),
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

class _BillingToggle extends StatelessWidget {
  const _BillingToggle({required this.annual, required this.onChanged});

  final bool annual;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.surfaceSunken,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(false),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                decoration: BoxDecoration(
                  color: !annual ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  boxShadow: !annual ? AppShadows.soft : null,
                ),
                child: Center(
                  child: Text('Monthly',
                      style: AppText.label.copyWith(
                        color: !annual ? AppColors.ink : AppColors.muted,
                        fontSize: 12,
                      )),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(true),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                decoration: BoxDecoration(
                  color: annual ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  boxShadow: annual ? AppShadows.soft : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Annual',
                        style: AppText.label.copyWith(
                          color: annual ? AppColors.ink : AppColors.muted,
                          fontSize: 12,
                        )),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.green.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text('−17%',
                          style: AppText.tiny.copyWith(
                              color: AppColors.greenDeep,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.selected,
    required this.annual,
    required this.onTap,
  });

  final PlanType plan;
  final bool selected;
  final bool annual;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final premium = plan == PlanType.premium;
    final monthly = premium ? 14.99 : 4.99;
    final price = annual ? (premium ? 149 : 49) : monthly;

    final features = premium
        ? [
            'Everything in General',
            'Live personal coaching (2–3/mo)',
            'Trainer at your home',
            'Nutritionist chat + meal plans',
            'Advanced video library',
          ]
        : [
            'Beginner & intermediate videos',
            'Workout logging + reminders',
            'Standard workout plans',
            'Progress analytics',
            'Community challenges',
          ];

    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: premium
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0C1F19), Color(0xFF123024)],
                )
              : null,
          color: premium ? null : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected
                ? (premium ? AppColors.greenBright : AppColors.green)
                : (premium ? Colors.transparent : AppColors.line),
            width: selected ? 1.8 : 1,
          ),
          boxShadow: selected ? AppShadows.float : AppShadows.soft,
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: premium
                            ? AppColors.greenBright.withValues(alpha: 0.18)
                            : AppColors.surfaceSunken,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        premium ? 'MOST POPULAR' : 'STARTER',
                        style: AppText.tiny.copyWith(
                          color: premium ? AppColors.lime : AppColors.muted,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.9,
                        ),
                      ),
                    ),
                    const Spacer(),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected
                            ? (premium ? AppColors.greenBright : AppColors.green)
                            : Colors.transparent,
                        border: Border.all(
                          color: selected
                              ? Colors.transparent
                              : (premium
                                  ? Colors.white.withValues(alpha: 0.3)
                                  : AppColors.line),
                          width: 1.6,
                        ),
                      ),
                      child: selected
                          ? const Icon(Icons.check_rounded, size: 14, color: AppColors.ink)
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      premium ? 'Premium' : 'General',
                      style: AppText.h2.copyWith(
                          fontSize: 21,
                          color: premium ? Colors.white : AppColors.ink),
                    ),
                    const Spacer(),
                    Text(
                      '\$${price.toStringAsFixed(annual ? 0 : 2)}',
                      style: AppText.display.copyWith(
                        fontSize: 30,
                        color: premium ? Colors.white : AppColors.ink,
                        letterSpacing: -1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4, left: 2),
                      child: Text(
                        annual ? '/yr' : '/mo',
                        style: AppText.tiny.copyWith(
                            color: premium
                                ? Colors.white.withValues(alpha: 0.5)
                                : AppColors.muted,
                            fontSize: 10),
                      ),
                    ),
                  ],
                ),
                if (premium) ...[
                  const SizedBox(height: 4),
                  Text(
                    'First month 50% off · then \$${monthly.toStringAsFixed(2)}/mo',
                    style: AppText.tiny.copyWith(
                        color: AppColors.lime, fontSize: 9.5),
                  ),
                ],
                const SizedBox(height: 14),
                ...features.map(
                  (f) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 17,
                          height: 17,
                          decoration: BoxDecoration(
                            color: premium
                                ? AppColors.greenBright.withValues(alpha: 0.2)
                                : AppColors.green.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.check_rounded,
                              size: 11,
                              color: premium ? AppColors.lime : AppColors.greenDeep),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            f,
                            style: AppText.body.copyWith(
                              fontSize: 12,
                              height: 1.3,
                              color: premium
                                  ? Colors.white.withValues(alpha: 0.76)
                                  : AppColors.inkSoft,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
