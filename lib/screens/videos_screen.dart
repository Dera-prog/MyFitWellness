import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/paywall.dart';

class VideosScreen extends StatefulWidget {
  const VideosScreen({super.key});

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  String _level = 'All';
  static const _levels = ['All', 'Beginner', 'Intermediate', 'Advanced'];

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final items = _level == 'All'
        ? state.videos
        : state.videos.where((v) => v.level == _level).toList();
    final featured = items.isEmpty ? null : items.first;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Video library', style: AppText.h1.copyWith(fontSize: 26)),
                            const SizedBox(height: 3),
                            Text('Guided sessions by level',
                                style: AppText.small.copyWith(fontSize: 12)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                        decoration: BoxDecoration(
                          color: state.isPremium
                              ? AppColors.green.withValues(alpha: 0.12)
                              : AppColors.surfaceSunken,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              state.isPremium
                                  ? Icons.workspace_premium_rounded
                                  : Icons.lock_outline_rounded,
                              size: 14,
                              color: state.isPremium ? AppColors.greenDeep : AppColors.muted,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              state.isPremium ? 'PREMIUM' : 'GENERAL',
                              style: AppText.tiny.copyWith(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.7,
                                color: state.isPremium ? AppColors.greenDeep : AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _levels.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final level = _levels[i];
                        final active = level == _level;
                        return GestureDetector(
                          onTap: () => setState(() => _level = level),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 240),
                            curve: Curves.easeOutCubic,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: active ? AppColors.ink : AppColors.surface,
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                              border: Border.all(
                                color: active ? AppColors.ink : AppColors.line,
                              ),
                            ),
                            child: Text(
                              level,
                              style: AppText.label.copyWith(
                                fontSize: 11,
                                letterSpacing: 0.2,
                                color: active ? Colors.white : AppColors.inkSoft,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (featured != null)
                    _FeaturedCard(
                      video: featured,
                      pulse: _pulse,
                      locked: featured.premium && !state.isPremium,
                      onTap: () => _open(context, featured, state),
                    ),
                  const SizedBox(height: 22),
                  SectionHeader(
                    title: 'All sessions',
                    action: '${items.length} videos',
                  ),
                  const SizedBox(height: 10),
                ]),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  mainAxisExtent: 208,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final v = items[i];
                    final locked = v.premium && !state.isPremium;
                    return SlideFadeIn(
                      delay: Duration(milliseconds: 50 * i),
                      duration: const Duration(milliseconds: 420),
                      child: _VideoCard(
                        video: v,
                        locked: locked,
                        onTap: () => _open(context, v, state),
                      ),
                    );
                  },
                  childCount: items.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context, VideoItem video, AppState state) {
    if (video.premium && !state.isPremium) {
      showPremiumPaywall(
        context,
        feature: video.title,
        description: 'This session is part of the Premium video library with advanced programming.',
      );
      return;
    }
    showAppSheet(context, _PlayerSheet(video: video));
    state.playVideo(video);
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({
    required this.video,
    required this.pulse,
    required this.locked,
    required this.onTap,
  });

  final VideoItem video;
  final AnimationController pulse;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.985,
      child: Container(
        height: 196,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppShadows.float,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(video.image, fit: BoxFit.cover),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x33000000), Color(0xE6061510)],
                  ),
                ),
              ),
              Positioned(
                left: 16,
                top: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.42),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                  ),
                  child: Text(
                    'FEATURED · ${video.level.toUpperCase()}',
                    style: AppText.tiny.copyWith(
                      color: Colors.white,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              Center(
                child: AnimatedBuilder(
                  animation: pulse,
                  builder: (context, child) {
                    return Transform.scale(scale: 1 + pulse.value * 0.06, child: child);
                  },
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.greenBright.withValues(alpha: 0.45),
                          blurRadius: 28,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      locked ? Icons.lock_rounded : Icons.play_arrow_rounded,
                      size: 30,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 14,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            video.title,
                            style: AppText.h2.copyWith(color: Colors.white, fontSize: 19),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${video.focus} · ${video.minutes} min',
                            style: AppText.tiny.copyWith(
                              color: Colors.white.withValues(alpha: 0.65),
                              fontSize: 10.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (video.premium)
                      const LevelChip(label: 'Premium', color: AppColors.lime),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  const _VideoCard({required this.video, required this.locked, required this.onTap});

  final VideoItem video;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.975,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppShadows.soft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(video.image, fit: BoxFit.cover),
                    if (locked)
                      Container(
                        color: AppColors.ink.withValues(alpha: 0.42),
                        child: const Center(
                          child: Icon(Icons.lock_rounded, color: Colors.white, size: 22),
                        ),
                      ),
                    Positioned(
                      left: 9,
                      top: 9,
                      child: LevelChip(
                        label: video.level,
                        color: video.level == 'Advanced'
                            ? AppColors.amber
                            : video.level == 'Intermediate'
                                ? AppColors.navy
                                : AppColors.green,
                      ),
                    ),
                    Positioned(
                      right: 9,
                      bottom: 9,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          '${video.minutes}m',
                          style: AppText.tiny.copyWith(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(11, 9, 11, 11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.bodyStrong.copyWith(fontSize: 12.5, height: 1.3),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        video.focus,
                        style: AppText.tiny.copyWith(fontSize: 9.5),
                      ),
                      const Spacer(),
                      if (video.premium)
                        const Icon(Icons.workspace_premium_rounded,
                            size: 13, color: AppColors.amber),
                    ],
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

class _PlayerSheet extends StatefulWidget {
  const _PlayerSheet({required this.video});

  final VideoItem video;

  @override
  State<_PlayerSheet> createState() => _PlayerSheetState();
}

class _PlayerSheetState extends State<_PlayerSheet> with SingleTickerProviderStateMixin {
  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: Duration(seconds: widget.video.minutes * 6),
  )..forward();
  bool _playing = true;

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _playing = !_playing;
      if (_playing) {
        _progress.forward();
      } else {
        _progress.stop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.video.minutes * 60;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 26),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(widget.video.image, fit: BoxFit.cover),
                  Container(color: Colors.black.withValues(alpha: 0.35)),
                  Center(
                    child: GestureDetector(
                      onTap: _toggle,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 62,
                        height: 62,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.greenBright.withValues(alpha: 0.4),
                              blurRadius: 26,
                            ),
                          ],
                        ),
                        child: Icon(
                          _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          size: 32,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 14,
                    right: 14,
                    bottom: 12,
                    child: AnimatedBuilder(
                      animation: _progress,
                      builder: (context, _) {
                        final seconds = (_progress.value * total).round();
                        return Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: _progress.value,
                                minHeight: 5,
                                backgroundColor: Colors.white.withValues(alpha: 0.25),
                                valueColor: const AlwaysStoppedAnimation(AppColors.greenBright),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text(
                                  _fmt(seconds),
                                  style: AppText.tiny.copyWith(color: Colors.white, fontSize: 9.5),
                                ),
                                const Spacer(),
                                Text(
                                  _fmt(total),
                                  style: AppText.tiny.copyWith(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontSize: 9.5,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.video.title, style: AppText.h2.copyWith(fontSize: 19)),
                    const SizedBox(height: 3),
                    Text(
                      '${widget.video.level} · ${widget.video.focus} · ${widget.video.minutes} min',
                      style: AppText.small.copyWith(fontSize: 11.5),
                    ),
                  ],
                ),
              ),
              LevelChip(
                label: widget.video.premium ? 'Premium' : 'Included',
                color: widget.video.premium ? AppColors.amber : AppColors.green,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const InfoRow(
            icon: Icons.playlist_play_rounded,
            title: 'What you will do',
            subtitle: 'Warm-up · 4 working blocks · cooldown',
            trailing: SizedBox.shrink(),
          ),
          const InfoRow(
            icon: Icons.fitness_center_rounded,
            title: 'Equipment',
            subtitle: 'Dumbbells, bench, mat',
            trailing: SizedBox.shrink(),
          ),
          const SizedBox(height: 8),
          AppButton(
            label: 'Add to today\'s plan',
            icon: Icons.add_rounded,
            trailing: false,
            onTap: () {
              AppScope.of(context).addExercise(
                Exercise(
                  name: widget.video.title,
                  detail: widget.video.focus,
                  sets: 1,
                  reps: 0,
                  weight: 0,
                  minutes: widget.video.minutes,
                  icon: Icons.play_circle_fill_rounded,
                  iconKey: 'play_circle',
                ),
              );
              appToast(context, 'Added to today\'s workout',
                  icon: Icons.check_circle_rounded);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  String _fmt(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
