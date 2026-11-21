import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/brand.dart';
import '../widgets/circular_reveal_route.dart';
import '../widgets/common.dart';
import '../widgets/energy.dart';
import 'gym_registration_screen.dart';
import 'main_shell.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.startOnSignUp = false});

  final bool startOnSignUp;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late bool _signUp = widget.startOnSignUp;
  bool _obscure = true;
  bool _loading = false;
  bool _terms = true;

  final _name = TextEditingController();
  final _email = TextEditingController(text: 'alex@myfitwellness.com');
  final _phone = TextEditingController();
  final _password = TextEditingController(text: 'fitwellness');

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_signUp && (_email.text.trim().isEmpty || _password.text.isEmpty)) {
      appToast(context, 'Enter your email and password', icon: Icons.info_outline_rounded);
      return;
    }
    if (_signUp && (!_terms || _name.text.trim().isEmpty)) {
      appToast(
        context,
        !_terms ? 'Accept the terms to continue' : 'Tell us your name',
        icon: Icons.info_outline_rounded,
      );
      return;
    }
    if (_signUp && _password.text.length < 6) {
      appToast(context, 'Use at least 6 characters for your password',
          icon: Icons.info_outline_rounded);
      return;
    }
    setState(() => _loading = true);

    final state = AppScope.of(context);
    final started = DateTime.now();
    final error = _signUp
        ? await state.signUp(
            name: _name.text.trim(),
            email: _email.text.trim(),
            password: _password.text,
            phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
          )
        : await state.signIn(email: _email.text.trim(), password: _password.text);
    final elapsed = DateTime.now().difference(started);
    if (elapsed < const Duration(milliseconds: 700)) {
      await Future<void>.delayed(const Duration(milliseconds: 700) - elapsed);
    }
    if (!mounted) return;
    setState(() => _loading = false);

    if (error != null) {
      appToast(context, error.message, icon: Icons.error_outline_rounded);
      return;
    }
    if (!state.signedIn) {
      appToast(context, 'Could not reach the server — check your connection',
          icon: Icons.wifi_off_rounded);
      return;
    }

    Navigator.of(context).pushReplacement(
      CircularRevealRoute(
        originColor: AppColors.bg,
        builder: (_) => _signUp ? const GymRegistrationScreen() : MainShell(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          Positioned(
            top: -size.width * 0.35,
            right: -size.width * 0.25,
            child: Container(
              width: size.width * 0.9,
              height: size.width * 0.9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.green.withValues(alpha: 0.16),
                    AppColors.green.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DotGrid(color: AppColors.ink.withValues(alpha: 0.03), gap: 26),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const BrandMark(size: 44, glow: true),
                      const SizedBox(width: 12),
                      const BrandWordmark(fontSize: 14, letterSpacing: 1.2),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.green.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.lock_outline_rounded,
                                size: 12, color: AppColors.greenDeep),
                            const SizedBox(width: 4),
                            Text(
                              'SECURE',
                              style: AppText.tiny.copyWith(
                                color: AppColors.greenDeep,
                                fontWeight: FontWeight.w700,
                                fontSize: 9,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 34),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween(begin: const Offset(0, 0.08), end: Offset.zero)
                            .animate(anim),
                        child: child,
                      ),
                    ),
                    child: Column(
                      key: ValueKey(_signUp),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _signUp ? 'Create your\naccount' : 'Welcome\nback.',
                          style: AppText.display.copyWith(fontSize: 36, height: 1.06),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _signUp
                              ? 'One account for your gym, workouts, coaches and nutrition.'
                              : 'Your plan, your progress and your coach are waiting.',
                          style: AppText.body.copyWith(fontSize: 13.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  _Segmented(
                    signUp: _signUp,
                    onChanged: (v) => setState(() => _signUp = v),
                  ),
                  const SizedBox(height: 22),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.topCenter,
                    child: Column(
                      children: [
                        if (_signUp) ...[
                          _Field(
                            controller: _name,
                            hint: 'Full name',
                            icon: Icons.person_outline_rounded,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 12),
                        ],
                        _Field(
                          controller: _email,
                          hint: 'Email address',
                          icon: Icons.alternate_email_rounded,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),
                        if (_signUp) ...[
                          _Field(
                            controller: _phone,
                            hint: 'Phone number',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 12),
                        ],
                        _Field(
                          controller: _password,
                          hint: 'Password',
                          icon: Icons.lock_outline_rounded,
                          obscure: _obscure,
                          textInputAction: TextInputAction.done,
                          trailing: GestureDetector(
                            onTap: () => setState(() => _obscure = !_obscure),
                            child: Icon(
                              _obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 19,
                              color: AppColors.muted,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            if (_signUp)
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _terms = !_terms),
                                  behavior: HitTestBehavior.opaque,
                                  child: Row(
                                    children: [
                                      AnimatedCheckbox(checked: _terms, size: 22),
                                      const SizedBox(width: 9),
                                      Expanded(
                                        child: Text(
                                          'I agree to the Terms & Privacy Policy',
                                          style: AppText.tiny.copyWith(fontSize: 10.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else ...[
                              GestureDetector(
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const ForgotPasswordScreen(),
                                  ),
                                ),
                                child: Text(
                                  'Forgot password?',
                                  style: AppText.label.copyWith(
                                    color: AppColors.greenDeep,
                                    fontSize: 11.5,
                                    letterSpacing: 0,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  const Icon(Icons.check_circle_rounded,
                                      size: 13, color: AppColors.green),
                                  const SizedBox(width: 4),
                                  Text('Remember me',
                                      style: AppText.tiny.copyWith(fontSize: 10.5)),
                                ],
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 22),
                        AppButton(
                          label: _signUp ? 'Create Account' : 'Sign In',
                          loading: _loading,
                          onTap: _submit,
                        ),
                        if (!_signUp) ...[
                          const SizedBox(height: 14),
                          Center(
                            child: Text(
                              'New here? Create an account above — it takes 40 seconds.',
                              textAlign: TextAlign.center,
                              style: AppText.tiny.copyWith(fontSize: 10.5),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('or continue with',
                            style: AppText.tiny.copyWith(fontSize: 10)),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _SocialButton(
                          icon: Icons.g_mobiledata_rounded,
                          label: 'Google',
                          onTap: _submit,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SocialButton(
                          icon: Icons.apple_rounded,
                          label: 'Apple',
                          onTap: _submit,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  Center(
                    child: GestureDetector(
                      onTap: () => setState(() => _signUp = !_signUp),
                      child: Text.rich(
                        TextSpan(
                          style: AppText.small.copyWith(fontSize: 12),
                          children: [
                            TextSpan(
                              text: _signUp
                                  ? 'Already have an account? '
                                  : 'Don\'t have an account? ',
                            ),
                            TextSpan(
                              text: _signUp ? 'Sign in' : 'Create one',
                              style: const TextStyle(
                                color: AppColors.greenDeep,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
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
}

class _Segmented extends StatelessWidget {
  const _Segmented({required this.signUp, required this.onChanged});

  final bool signUp;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.surfaceSunken,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final half = constraints.maxWidth / 2;
          return Stack(
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
                alignment: signUp ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: half,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    boxShadow: AppShadows.soft,
                  ),
                ),
              ),
              Row(
                children: [
                  _segment('Sign In', !signUp, () => onChanged(false)),
                  _segment('Sign Up', signUp, () => onChanged(true)),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _segment(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Text(
            label,
            style: AppText.label.copyWith(
              color: active ? AppColors.ink : AppColors.muted,
              letterSpacing: 0.2,
              fontSize: 12.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.obscure = false,
    this.trailing,
    this.textInputAction,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscure;
  final Widget? trailing;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      style: AppText.bodyStrong.copyWith(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 6),
          child: Icon(icon, size: 19, color: AppColors.muted),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 44),
        suffixIcon: trailing == null
            ? null
            : Padding(padding: const EdgeInsets.only(right: 16), child: trailing),
        suffixIconConstraints: const BoxConstraints(minWidth: 40),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: AppColors.line, width: 1.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: AppColors.ink),
            const SizedBox(width: 8),
            Text(label, style: AppText.label.copyWith(color: AppColors.ink, fontSize: 12.5)),
          ],
        ),
      ),
    );
  }
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  bool _sent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppIconButton(
                icon: Icons.arrow_back_rounded,
                onTap: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 28),
              const BrandMark(size: 54, glow: true),
              const SizedBox(height: 22),
              Text('Reset your\npassword', style: AppText.display.copyWith(fontSize: 32)),
              const SizedBox(height: 10),
              Text(
                'We will email you a secure link to set a new password.',
                style: AppText.body.copyWith(fontSize: 13.5),
              ),
              const SizedBox(height: 26),
              _Field(
                controller: _email,
                hint: 'Email address',
                icon: Icons.alternate_email_rounded,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 18),
              AppButton(
                label: _sent ? 'Link Sent' : 'Send Reset Link',
                icon: _sent ? Icons.check_rounded : null,
                onTap: () {
                  setState(() => _sent = true);
                  appToast(context, 'Reset link sent to your inbox',
                      icon: Icons.mark_email_read_outlined);
                },
              ),
              const Spacer(),
              Center(
                child: Text(
                  'Tip: check your spam folder if it does not arrive in 2 minutes.',
                  textAlign: TextAlign.center,
                  style: AppText.tiny.copyWith(fontSize: 10.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
