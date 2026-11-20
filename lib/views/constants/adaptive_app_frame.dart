import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Keeps every route and popup readable on a tablet, including pages opened
/// outside the bottom navigation bar. Phone layouts keep their full width.
class AdaptiveAppFrame extends StatelessWidget {
  const AdaptiveAppFrame({required this.child, super.key});

  final Widget child;

  static const double tabletBreakpoint = 600;
  static const double maxContentWidth = 960;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    if (media.size.shortestSide < tabletBreakpoint) {
      return child;
    }

    final width = math.min(media.size.width, maxContentWidth);
    return ColoredBox(
      color: const Color(0xFF000000),
      child: Center(
        child: SizedBox(
          width: width,
          height: media.size.height,
          child: MediaQuery(
            data: media.copyWith(size: Size(width, media.size.height)),
            child: child,
          ),
        ),
      ),
    );
  }
}
