import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A route that reveals the next screen through an expanding circle.
class CircularRevealRoute<T> extends PageRouteBuilder<T> {
  CircularRevealRoute({required WidgetBuilder builder, this.originColor = Colors.black})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => builder(context),
          transitionDuration: const Duration(milliseconds: 850),
          reverseTransitionDuration: const Duration(milliseconds: 400),
          opaque: false,
        );

  final Color originColor;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final size = MediaQuery.sizeOf(context);
        final center = Offset(size.width / 2, size.height * 0.44);
        // Radius must reach the farthest corner from the reveal center,
        // otherwise the corners keep showing the previous route.
        final maxRadius = [
          (center - Offset.zero).distance,
          (center - Offset(size.width, 0)).distance,
          (center - Offset(0, size.height)).distance,
          (center - Offset(size.width, size.height)).distance,
        ].reduce(math.max);
        final t = Curves.easeInOutCubicEmphasized.transform(animation.value.clamp(0.0, 1.0));
        final radius = maxRadius * t;

        return ColoredBox(
          color: originColor,
          child: ClipPath(
            clipper: _CircleClipper(center, radius),
            child: child,
          ),
        );
      },
    );
  }
}

class _CircleClipper extends CustomClipper<Path> {
  _CircleClipper(this.center, this.radius);

  final Offset center;
  final double radius;

  @override
  Path getClip(Size size) => Path()
    ..addOval(Rect.fromCircle(center: center, radius: radius));

  @override
  bool shouldReclip(covariant _CircleClipper old) =>
      old.radius != radius || old.center != center;
}
