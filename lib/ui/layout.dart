import 'package:flutter/widgets.dart';

/// Responsive rules for the app. Width decides the layout, and a build can be
/// pinned with `--dart-define=LAYOUT=mobile|desktop` for the dedicated
/// mobile/desktop deployments.
class AppLayout {
  AppLayout._();

  static const _forced = String.fromEnvironment('LAYOUT');

  static bool get forcedDesktop => _forced == 'desktop';
  static bool get forcedMobile => _forced == 'mobile';

  static const double breakpoint = 1000;
  static const double contentMax = 1180;

  static bool isDesktop(BuildContext context) {
    if (forcedDesktop) return true;
    if (forcedMobile) return false;
    return MediaQuery.sizeOf(context).width >= breakpoint;
  }
}

/// Centres a page column so wide screens never stretch mobile cards edge to edge.
class DesktopPage extends StatelessWidget {
  const DesktopPage({
    super.key,
    required this.child,
    this.maxWidth = AppLayout.contentMax,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// Caps the width of a pushed screen's body on desktop while leaving the phone
/// layout untouched below the breakpoint.
class WideFrame extends StatelessWidget {
  const WideFrame({super.key, required this.child, this.maxWidth = 760});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    if (!AppLayout.isDesktop(context)) return child;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
