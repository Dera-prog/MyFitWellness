import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'site_pages.dart';

class MarketingSiteApp extends StatelessWidget {
  const MarketingSiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = buildAppTheme();
    return MaterialApp(
      title: 'MyFitWellness — your gym, your plan, your progress',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const _SiteScrollBehavior(),
      theme: base.copyWith(
        scaffoldBackgroundColor: AppColors.bg,
        textTheme: base.textTheme.apply(
          bodyColor: AppColors.ink,
          displayColor: AppColors.ink,
        ),
      ),
      onGenerateRoute: SitePageView.generateRoute,
      onGenerateInitialRoutes: SitePageView.initialRoutes,
      onUnknownRoute: (settings) =>
          SitePageView.generateRoute(const RouteSettings(name: '/')),
    );
  }
}

/// Lets a mouse drag the page like a touch screen, so the landing page is
/// comfortable to scroll on a desktop.
class _SiteScrollBehavior extends MaterialScrollBehavior {
  const _SiteScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}