import 'dart:async';

import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'meal_plan_screen.dart';

class NutritionistScreen extends StatefulWidget {
  const NutritionistScreen({super.key});

  @override
  State<NutritionistScreen> createState() => _NutritionistScreenState();
}

class _NutritionistScreenState extends State<NutritionistScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  bool _typing = false;
  Timer? _timer;

  static const _suggestions = [
    'High-protein breakfast ideas?',
    'Is my macro split right?',
    'Snacks under 200 kcal',
  ];

  static const _replies = [
    'Try 40g of protein at breakfast — eggs with cottage cheese, or a Greek yogurt bowl with oats and berries. Keeps you full past lunch.',
    'For your training load, aim for 35% protein, 40% carbs, 25% fat. I would keep carbs around your sessions.',
    'Greek yogurt (15g), a boiled egg (6g), or edamame (11g). All under 200 kcal and easy to prep in batches.',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _jump());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _jump() {
    if (!_scroll.hasClients) return;
    _scroll.animateTo(
      _scroll.position.maxScrollExtent + 120,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _send([String? preset]) {
    final text = (preset ?? _input.text).trim();
    if (text.isEmpty) return;
    final state = AppScope.of(context);
    _input.clear();
    setState(() => _typing = true);
    _jump();

    _timer?.cancel();
    final started = DateTime.now();
    state.sendMessage(text).then((reply) {
      final wait = const Duration(milliseconds: 900) - DateTime.now().difference(started);
      _timer = Timer(wait.isNegative ? Duration.zero : wait, () {
        if (!mounted) return;
        state.receiveCoachMessage(reply ?? _replies[text.length % _replies.length]);
        setState(() => _typing = false);
        _jump();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            ScreenHeader(
              title: 'Nutritionist',
              subtitle: 'Coach Amara · replies in ~5 min',
              trailing: AppIconButton(
                icon: Icons.restaurant_menu_rounded,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MealPlanScreen()),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: AppColors.green.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFF7A4E2D),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        'AA',
                        style: AppText.tiny.copyWith(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'You are on the Premium nutrition plan. Share a food log any time.',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10.5,
                        height: 1.4,
                        color: AppColors.inkSoft,
                      ),
                    ),
                  ),
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                itemCount: state.chat.length + (_typing ? 1 : 0),
                itemBuilder: (context, i) {
                  if (i == state.chat.length) {
                    return const _TypingBubble();
                  }
                  final m = state.chat[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _Bubble(message: m),
                  );
                },
              ),
            ),
            SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _suggestions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) => GestureDetector(
                  onTap: () => _send(_suggestions[i]),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 13),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Text(
                      _suggestions[i],
                      style: AppText.tiny.copyWith(
                        fontSize: 9.5,
                        color: AppColors.inkSoft,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _input,
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (_) => _send(),
                        decoration: const InputDecoration(
                          hintText: 'Ask about food, macros or timing…',
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Pressable(
                      onTap: _send,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: AppColors.greenGradient,
                          borderRadius: BorderRadius.circular(17),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.green.withValues(alpha: 0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.send_rounded,
                            color: Colors.white, size: 21),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final mine = message.fromMe;

    return Row(
      mainAxisAlignment: mine ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!mine) ...[
          Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              color: Color(0xFF7A4E2D),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                'AA',
                style: AppText.tiny.copyWith(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 280),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              gradient: mine ? AppColors.greenGradient : null,
              color: mine ? null : AppColors.surface,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(17),
                topRight: const Radius.circular(17),
                bottomLeft: Radius.circular(mine ? 17 : 5),
                bottomRight: Radius.circular(mine ? 5 : 17),
              ),
              boxShadow: mine ? null : AppShadows.soft,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  message.text,
                  style: AppText.bodyStrong.copyWith(
                    fontSize: 12.5,
                    height: 1.45,
                    fontWeight: FontWeight.w400,
                    color: mine ? Colors.white : AppColors.ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message.time,
                  style: AppText.tiny.copyWith(
                    fontSize: 8,
                    color: mine
                        ? Colors.white.withValues(alpha: 0.65)
                        : AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: const BoxDecoration(
            color: Color(0xFF7A4E2D),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              'AA',
              style: AppText.tiny.copyWith(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(17),
            boxShadow: AppShadows.soft,
          ),
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) => Row(
              children: List.generate(3, (i) {
                final phase = ((_c.value + i * 0.18) % 1);
                final bounce = phase < 0.5 ? phase * 2 : (1 - phase) * 2;
                return Container(
                  width: 5,
                  height: 5,
                  margin: EdgeInsets.only(right: i == 2 ? 0 : 5),
                  transform: Matrix4.translationValues(0, -bounce * 4, 0),
                  decoration: BoxDecoration(
                    color: AppColors.muted.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}
