import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'site_content.dart';
import 'site_home.dart';
import 'site_sections.dart';
import 'site_shell.dart';
import 'site_widgets.dart';

/// Builds the shell (header, footer, scroll) around the body for one page.
class SitePageView extends StatelessWidget {
  const SitePageView({super.key, required this.page});

  final SitePage page;

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final page = SitePage.fromPath(settings.name);
    return _route(page, RouteSettings(name: page.path));
  }

  /// Keeps the home page underneath every deep link so the back button always
  /// has somewhere to go.
  static List<Route<dynamic>> initialRoutes(String name) {
    final page = SitePage.fromPath(name);
    final home = _route(SitePage.home, const RouteSettings(name: '/'));
    if (page == SitePage.home) return [home];
    return [home, _route(page, RouteSettings(name: page.path))];
  }

  static Route<dynamic> _route(SitePage page, RouteSettings settings) {
    return PageRouteBuilder<dynamic>(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 260),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) =>
          SitePageView(page: page),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.015),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Title(
      title: page == SitePage.home
          ? 'MyFitWellness — your gym, your plan, your progress'
          : '${page.label} — MyFitWellness',
      color: AppColors.bg,
      child: SiteShell(
        page: page,
        child: switch (page) {
          SitePage.home => const SiteHomeBody(),
          SitePage.features => const _FeaturesPage(),
          SitePage.howItWorks => const _HowItWorksPage(),
          SitePage.plans => const _PlansPage(),
          SitePage.faq => const _FaqPage(),
        },
      ),
    );
  }
}

// ---------------------------------------------------------------- features

class _FeaturesPage extends StatelessWidget {
  const _FeaturesPage();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SitePageIntro(
          eyebrow: 'Features',
          title: 'Everything the app does, in one place.',
          lead:
              'Six parts that cover the whole week: the daily plan, the streak, '
              'the goals, the coach, the videos and the meals.',
        ),
        SiteBand(
          child: SiteWrap(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SiteSectionHead(
                  eyebrow: 'In detail',
                  title: 'What each part actually does.',
                ),
                const SizedBox(height: 36),
                const SiteFeatureDetails(features: siteFeatures),
              ],
            ),
          ),
        ),
        SiteBand(
          alt: true,
          child: SiteWrap(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SiteSectionHead(
                  eyebrow: 'Around the workout',
                  title: 'The small things that keep it usable.',
                ),
                const SizedBox(height: 36),
                const SiteInfoCards(cards: siteFeatureDetails),
              ],
            ),
          ),
        ),
        const SiteCtaBand(),
      ],
    );
  }
}

// ---------------------------------------------------------------- how it works

class _HowItWorksPage extends StatelessWidget {
  const _HowItWorksPage();

  @override
  Widget build(BuildContext context) {
    final sessionCols = Site.wide(context) ? 4 : (Site.tablet(context) ? 2 : 1);
    return Column(
      children: [
        const SitePageIntro(
          eyebrow: 'How it works',
          title: 'Three minutes from sign-up to your first checkmark.',
          lead:
              "Set up an account, pick your gym, and today's session is already "
              'built. Nothing else to configure before you train.',
        ),
        SiteBand(
          child: SiteWrap(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SiteSectionHead(
                  eyebrow: 'Getting started',
                  title: 'From sign-up to your first checkmark.',
                ),
                const SizedBox(height: 36),
                const SiteStepCards(steps: siteSteps, showBullets: true),
              ],
            ),
          ),
        ),
        SiteBand(
          alt: true,
          child: SiteWrap(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SiteSectionHead(
                  eyebrow: 'A real session',
                  title: 'What a Tuesday looks like.',
                  lead: 'Nothing to choose, nothing to configure — open the app and go.',
                ),
                const SizedBox(height: 36),
                SiteInfoCards(cards: siteSessionCards, cols: sessionCols),
              ],
            ),
          ),
        ),
        SiteBand(
          child: SiteWrap(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SiteSectionHead(
                  eyebrow: 'Built for real gyms',
                  title: 'It works where you train.',
                ),
                const SizedBox(height: 36),
                const SiteInfoCards(cards: siteRobustCards),
              ],
            ),
          ),
        ),
        const SiteCtaBand(),
      ],
    );
  }
}

// ---------------------------------------------------------------- plans

class _PlansPage extends StatelessWidget {
  const _PlansPage();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SitePageIntro(
          eyebrow: 'Plans',
          title: 'Simple pricing. Upgrade when you want a coach in the loop.',
          lead:
              'Every plan includes the daily workout, streaks, goals, history '
              'and reminders. Premium adds the human side.',
        ),
        SiteBand(
          child: SiteWrap(
            child: SitePlanGrid(plans: sitePlans),
          ),
        ),
        SiteBand(
          alt: true,
          child: SiteWrap(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SiteSectionHead(
                  eyebrow: 'Compare',
                  title: 'General vs Premium.',
                ),
                const SizedBox(height: 36),
                SiteCompareTable(rows: siteCompareRows),
              ],
            ),
          ),
        ),
        SiteBand(
          child: SiteWrap(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SiteSectionHead(
                  eyebrow: 'Billing',
                  title: 'Change or cancel whenever.',
                ),
                const SizedBox(height: 36),
                const SiteInfoCards(cards: siteBillingCards),
              ],
            ),
          ),
        ),
        const SiteCtaBand(),
      ],
    );
  }
}

// ---------------------------------------------------------------- faq

class _FaqPage extends StatelessWidget {
  const _FaqPage();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SitePageIntro(
          eyebrow: 'FAQ',
          title: 'The short answers.',
          lead:
              'Everything members ask before signing up, grouped so you can '
              'find it.',
        ),
        SiteBand(
          child: SiteWrap(
            maxWidth: 860,
            child: const SiteFaqGroups(groups: siteFaqGroups),
          ),
        ),
        const SiteCtaBand(),
      ],
    );
  }
}