import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/circular_reveal_route.dart';
import '../widgets/common.dart';
import 'main_shell.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key, required this.plan, required this.annual});

  final PlanType plan;
  final bool annual;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _method = 0;
  bool _processing = false;
  final _number = TextEditingController(text: '4242 4242 4242 4242');
  final _expiry = TextEditingController(text: '09/28');
  final _cvv = TextEditingController(text: '123');
  final _holder = TextEditingController(text: 'ALEX MORGAN');

  double get _base => widget.plan == PlanType.premium
      ? (widget.annual ? 149 : 14.99)
      : (widget.annual ? 49 : 4.99);

  double get _due => widget.annual ? _base : _base * 0.5;

  @override
  void dispose() {
    _number.dispose();
    _expiry.dispose();
    _cvv.dispose();
    _holder.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    FocusScope.of(context).unfocus();
    setState(() => _processing = true);
    await Future.delayed(const Duration(milliseconds: 1700));
    if (!mounted) return;
    setState(() => _processing = false);
    AppScope.of(context).setPlan(widget.plan);
    Navigator.of(context).pushReplacement(
      CircularRevealRoute(
        originColor: AppColors.ink,
        builder: (_) => PaymentSuccessScreen(plan: widget.plan, annual: widget.annual, due: _due),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final planLabel = widget.plan == PlanType.premium ? 'Premium' : 'General';

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Row(
                    children: [
                      AppIconButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => Navigator.of(context).maybePop(),
                      ),
                      const SizedBox(width: 12),
                      Text('Checkout', style: AppText.h2.copyWith(fontSize: 20)),
                      const Spacer(),
                      const StepDots(current: 3, total: 3),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Summary(
                          label: planLabel,
                          base: _base,
                          due: _due,
                          annual: widget.annual,
                        ),
                        const SizedBox(height: 22),
                        Text('Payment method', style: AppText.h3.copyWith(fontSize: 16)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _methodPill(0, Icons.credit_card_rounded, 'Card'),
                            const SizedBox(width: 8),
                            _methodPill(1, Icons.account_balance_rounded, 'Transfer'),
                            const SizedBox(width: 8),
                            _methodPill(2, Icons.account_balance_wallet_outlined, 'Wallet'),
                          ],
                        ),
                        const SizedBox(height: 18),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 280),
                          child: switch (_method) {
                            0 => Column(
                                key: const ValueKey('card'),
                                children: [
                                  _CardPreview(
                                    number: _number.text,
                                    holder: _holder.text,
                                    expiry: _expiry.text,
                                  ),
                                  const SizedBox(height: 16),
                                  _CardField(
                                    controller: _number,
                                    hint: 'Card number',
                                    icon: Icons.credit_card_rounded,
                                    formatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      _GroupFormatter(),
                                    ],
                                    keyboardType: TextInputType.number,
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _CardField(
                                          controller: _expiry,
                                          hint: 'MM/YY',
                                          icon: Icons.event_outlined,
                                          formatters: [_ExpiryFormatter()],
                                          keyboardType: TextInputType.number,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: _CardField(
                                          controller: _cvv,
                                          hint: 'CVV',
                                          icon: Icons.lock_outline_rounded,
                                          obscure: true,
                                          formatters: [
                                            FilteringTextInputFormatter.digitsOnly,
                                            LengthLimitingTextInputFormatter(4),
                                          ],
                                          keyboardType: TextInputType.number,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  _CardField(
                                    controller: _holder,
                                    hint: 'Name on card',
                                    icon: Icons.person_outline_rounded,
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ],
                              ),
                            1 => _TransferPanel(
                                key: const ValueKey('transfer'),
                                account: 'MyFitWellness Ltd · 0123456789',
                                onCopy: () => appToast(
                                  context,
                                  'Account number copied',
                                  icon: Icons.check_circle_outline_rounded,
                                ),
                              ),
                            _ => _WalletPanel(
                                key: const ValueKey('wallet'),
                                onPick: (label) =>
                                    appToast(context, '$label selected'),
                              ),
                          },
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            const Icon(Icons.verified_user_outlined,
                                size: 14, color: AppColors.greenDeep),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Card details are encrypted end-to-end and never touch our servers.',
                                style: AppText.tiny.copyWith(fontSize: 9.5),
                              ),
                            ),
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
                  child: AppButton(
                    label: 'Pay \$${_due.toStringAsFixed(2)} today',
                    icon: Icons.lock_outline_rounded,
                    trailing: false,
                    loading: _processing,
                    onTap: _pay,
                  ),
                ),
              ],
            ),
            if (_processing)
              Positioned.fill(
                child: Container(
                  color: AppColors.ink.withValues(alpha: 0.55),
                  child: const _ProcessingOverlay(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _methodPill(int index, IconData icon, String label) {
    final active = _method == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _method = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          height: 52,
          decoration: BoxDecoration(
            color: active ? AppColors.ink : Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: active ? AppColors.ink : AppColors.line),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: active ? Colors.white : AppColors.inkSoft),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppText.label.copyWith(
                  color: active ? Colors.white : AppColors.inkSoft,
                  fontSize: 11.5,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({
    required this.label,
    required this.base,
    required this.due,
    required this.annual,
  });

  final String label;
  final double base;
  final double due;
  final bool annual;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: AppColors.greenGradient,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(Icons.workspace_premium_rounded,
                    size: 20, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('MyFitWellness $label',
                        style: AppText.bodyStrong.copyWith(fontSize: 13.5)),
                    Text(annual ? 'Annual plan' : 'Monthly plan · cancel anytime',
                        style: AppText.tiny.copyWith(fontSize: 10)),
                  ],
                ),
              ),
              Text('\$${base.toStringAsFixed(annual ? 0 : 2)}',
                  style: AppText.bodyStrong.copyWith(fontSize: 13.5)),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 12),
          if (!annual) ...[
            _line('First month discount (50%)',
                '−\$${(base * 0.5).toStringAsFixed(2)}', AppColors.greenDeep),
            const SizedBox(height: 8),
          ],
          _line('Tax', 'Included', AppColors.muted),
          const SizedBox(height: 10),
          Row(
            children: [
              Text('Total today', style: AppText.bodyStrong.copyWith(fontSize: 13.5)),
              const Spacer(),
              Text('\$${due.toStringAsFixed(2)}',
                  style: AppText.h3.copyWith(fontSize: 20)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _line(String label, String value, Color color) {
    return Row(
      children: [
        Text(label, style: AppText.small.copyWith(fontSize: 11.5)),
        const Spacer(),
        Text(value, style: AppText.label.copyWith(color: color, fontSize: 11.5, letterSpacing: 0)),
      ],
    );
  }
}

class _CardPreview extends StatelessWidget {
  const _CardPreview({required this.number, required this.holder, required this.expiry});

  final String number;
  final String holder;
  final String expiry;

  @override
  Widget build(BuildContext context) {
    final digits = number.replaceAll(' ', '');
    final display = digits.padRight(16, '•');
    final grouped = [
      display.substring(0, 4),
      display.substring(4, 8),
      display.substring(8, 12),
      display.substring(12, 16),
    ].join('  ');

    return Container(
      height: 178,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF10241C), Color(0xFF1C4A2F), Color(0xFF0B1F1A)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppShadows.float,
      ),
      child: Stack(
        children: [
          Positioned(
            right: -50,
            top: -60,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.greenBright.withValues(alpha: 0.14),
              ),
            ),
          ),
          Positioned(
            left: -30,
            bottom: -70,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.navy.withValues(alpha: 0.35),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('MYFITWELLNESS',
                        style: AppText.tiny.copyWith(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.4)),
                    const Spacer(),
                    Container(
                      width: 34,
                      height: 24,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE8C56B), Color(0xFFB58B32)],
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  grouped,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CARD HOLDER',
                            style: AppText.tiny.copyWith(
                                color: Colors.white.withValues(alpha: 0.45),
                                fontSize: 7.5,
                                letterSpacing: 1)),
                        const SizedBox(height: 3),
                        Text(
                          holder.toUpperCase().isEmpty ? 'YOUR NAME' : holder.toUpperCase(),
                          style: AppText.tiny.copyWith(
                              color: Colors.white, fontSize: 10.5, letterSpacing: 0.6),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('EXPIRES',
                            style: AppText.tiny.copyWith(
                                color: Colors.white.withValues(alpha: 0.45),
                                fontSize: 7.5,
                                letterSpacing: 1)),
                        const SizedBox(height: 3),
                        Text(expiry.isEmpty ? 'MM/YY' : expiry,
                            style: AppText.tiny.copyWith(
                                color: Colors.white, fontSize: 10.5)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CardField extends StatelessWidget {
  const _CardField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.formatters,
    this.keyboardType,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final List<TextInputFormatter>? formatters;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      inputFormatters: formatters,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: AppText.bodyStrong.copyWith(fontSize: 13.5, letterSpacing: 0.6),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 6),
          child: Icon(icon, size: 18, color: AppColors.muted),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 42),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      ),
    );
  }
}

class _GroupFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > 16 ? digits.substring(0, 16) : digits;
    final buffer = StringBuffer();
    for (var i = 0; i < limited.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(limited[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    var text = digits;
    if (digits.length >= 3) {
      text = '${digits.substring(0, 2)}/${digits.substring(2, math.min(4, digits.length))}';
    }
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class _TransferPanel extends StatelessWidget {
  const _TransferPanel({super.key, required this.account, required this.onCopy});

  final String account;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bank transfer', style: AppText.h3.copyWith(fontSize: 14)),
          const SizedBox(height: 4),
          Text('Transfer to the account below, then tap pay.',
              style: AppText.small.copyWith(fontSize: 11.5)),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceSunken,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ACCOUNT', style: AppText.tiny.copyWith(fontSize: 8.5)),
                      const SizedBox(height: 4),
                      Text(account,
                          style: AppText.bodyStrong.copyWith(fontSize: 13)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onCopy,
                  icon: const Icon(Icons.copy_rounded, size: 17),
                  color: AppColors.greenDeep,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text('Transfers reflect within 5 minutes.',
              style: AppText.tiny.copyWith(fontSize: 9.5)),
        ],
      ),
    );
  }
}

class _WalletPanel extends StatelessWidget {
  const _WalletPanel({super.key, required this.onPick});

  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    final wallets = [
      ('Apple Pay', Icons.apple_rounded, AppColors.ink),
      ('Google Pay', Icons.g_mobiledata_rounded, AppColors.navy),
      ('Paystack Wallet', Icons.account_balance_wallet_rounded, AppColors.greenDeep),
    ];
    return Column(
      children: wallets.map((w) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Pressable(
            onTap: () => onPick(w.$1),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.line),
              ),
              child: Row(
                children: [
                  Icon(w.$2, color: w.$3, size: 22),
                  const SizedBox(width: 12),
                  Text(w.$1, style: AppText.bodyStrong.copyWith(fontSize: 13.5)),
                  const Spacer(),
                  const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.muted),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ProcessingOverlay extends StatefulWidget {
  const _ProcessingOverlay();

  @override
  State<_ProcessingOverlay> createState() => _ProcessingOverlayState();
}

class _ProcessingOverlayState extends State<_ProcessingOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 78,
            height: 78,
            child: AnimatedBuilder(
              animation: _c,
              builder: (context, _) => CustomPaint(
                painter: _ProcessingPainter(_c.value),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Processing securely…',
              style: AppText.bodyStrong.copyWith(color: Colors.white, fontSize: 13.5)),
          const SizedBox(height: 5),
          Text('Do not close this screen',
              style: AppText.tiny.copyWith(
                  color: Colors.white.withValues(alpha: 0.5), fontSize: 10)),
        ],
      ),
    );
  }
}

class _ProcessingPainter extends CustomPainter {
  _ProcessingPainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2 - 4;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = Colors.white.withValues(alpha: 0.15),
    );
    final sweep = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: [Colors.transparent, AppColors.lime, AppColors.greenBright],
      ).createShader(Rect.fromCircle(center: c, radius: r));
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), t * 2 * math.pi, 2.1, false, sweep);
    canvas.drawCircle(c, 5, Paint()..color = AppColors.greenBright);
  }

  @override
  bool shouldRepaint(covariant _ProcessingPainter old) => old.t != t;
}

class PaymentSuccessScreen extends StatefulWidget {
  const PaymentSuccessScreen({
    super.key,
    required this.plan,
    required this.annual,
    required this.due,
  });

  final PlanType plan;
  final bool annual;
  final double due;

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  String _renewalDate(bool annual) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final now = DateTime.now();
    final d = DateTime(now.year, now.month + (annual ? 12 : 1), now.day);
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.nightTop,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.4),
                radius: 1.0,
                colors: [Color(0xFF123326), Color(0xFF05100D)],
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _c,
            builder: (context, _) => CustomPaint(
              painter: _ConfettiPainter(_c.value),
              size: Size.infinite,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(26),
              child: Column(
                children: [
                  const Spacer(),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.elasticOut,
                    builder: (context, v, _) => Transform.scale(
                      scale: v,
                      child: Container(
                        width: 104,
                        height: 104,
                        decoration: BoxDecoration(
                          gradient: AppColors.greenGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.green.withValues(alpha: 0.45),
                              blurRadius: 40,
                              spreadRadius: 6,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.check_rounded, size: 52, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),
                  SlideFadeIn(
                    delay: const Duration(milliseconds: 250),
                    child: Text(
                      'You\'re in!',
                      style: AppText.display.copyWith(fontSize: 34, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SlideFadeIn(
                    delay: const Duration(milliseconds: 330),
                    child: Text(
                      '${widget.plan == PlanType.premium ? 'Premium' : 'General'} plan activated. '
                      'Receipt sent to your email.',
                      textAlign: TextAlign.center,
                      style: AppText.body.copyWith(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),
                  SlideFadeIn(
                    delay: const Duration(milliseconds: 420),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                      ),
                      child: Column(
                        children: [
                          _receipt('Amount charged', '\$${widget.due.toStringAsFixed(2)}'),
                          const SizedBox(height: 10),
                          _receipt('Billing', widget.annual ? 'Annual' : 'Monthly'),
                          const SizedBox(height: 10),
                          _receipt('Next renewal', _renewalDate(widget.annual)),
                          const SizedBox(height: 10),
                          _receipt('Payment', 'Visa ···· 4242'),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  AppButton(
                    label: 'Go to Dashboard',
                    onTap: () => Navigator.of(context).pushReplacement(
                      CircularRevealRoute(
                        originColor: AppColors.nightTop,
                        builder: (_) => const MainShell(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Manage this plan anytime in Menu → Subscription',
                    style: AppText.tiny.copyWith(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 9.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _receipt(String label, String value) {
    return Row(
      children: [
        Text(label,
            style: AppText.tiny.copyWith(
                color: Colors.white.withValues(alpha: 0.5), fontSize: 10.5)),
        const Spacer(),
        Text(value,
            style: AppText.label.copyWith(
                color: Colors.white, fontSize: 11, letterSpacing: 0)),
      ],
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(42);
    for (var i = 0; i < 70; i++) {
      final startX = rnd.nextDouble() * size.width;
      final delay = rnd.nextDouble() * 0.35;
      final speed = 0.5 + rnd.nextDouble() * 0.9;
      final local = ((t - delay) / 0.9).clamp(0.0, 1.0) * speed;
      if (local <= 0) continue;
      final y = local * size.height * 0.7;
      final x = startX + math.sin(t * 6 + i) * 24;
      final color = [
        AppColors.greenBright,
        AppColors.lime,
        Colors.white,
        AppColors.green,
      ][i % 4];
      final opacity = (1 - local).clamp(0.0, 1.0);
      final paint = Paint()..color = color.withValues(alpha: opacity * 0.85);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(t * 8 + i);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: 6, height: 11),
          const Radius.circular(1.6),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => old.t != t;
}
