import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:game_app/views/constants/constants.dart';
import 'package:get/get.dart';

/// The red "Satyldy" (sold) stamp for an account that was bought. [big] is for the middle of a card
/// picture (tilted a little, over a dimmed picture), the small one sits in a corner of the detail page.
class SoldBadge extends StatelessWidget {
  const SoldBadge({this.big = true, super.key});

  final bool big;

  static const _red = Color(0xFFFF5A5F);

  @override
  Widget build(BuildContext context) {
    final badge = Container(
      padding: EdgeInsets.symmetric(horizontal: big ? 16 : 12, vertical: big ? 7 : 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: _red.withValues(alpha: 0.92),
        border: Border.all(color: Colors.white.withValues(alpha: 0.85), width: big ? 1.6 : 1.2),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 10)],
      ),
      child: Text(
        'accountSoldBadge'.tr,
        style: TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: big ? 17 : 13.5, height: 1.1, letterSpacing: 0.5),
      ),
    );
    return big ? Transform.rotate(angle: -0.22, child: badge) : badge;
  }
}

/// A dimmed layer with the [SoldBadge] in the middle, to put over the picture of a sold account.
class SoldOverlay extends StatelessWidget {
  const SoldOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.black.withValues(alpha: 0.5), alignment: Alignment.center, child: const SoldBadge());
  }
}

/// A red ribbon across the top-right corner of a card: "SATYLDY" on a band that runs from the upper
/// left to the lower right. It is as big as [size] and only paints inside that square, so the card
/// that clips its corners clips the ribbon as well.
class SoldCornerRibbon extends StatelessWidget {
  const SoldCornerRibbon({this.size = 112, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    // The band's centre sits on the line x - y = size - t near the corner.
    // Far enough from the corner that the whole word fits on the part of the band that is inside the square.
    final t = size * 0.54;
    final width = size * 1.4;
    const height = 24.0;
    return IgnorePointer(
      child: SizedBox(
        width: size,
        height: size,
        child: ClipRect(
          child: Stack(
            children: [
              Positioned(
                left: size - t / 2 - width / 2,
                top: t / 2 - height / 2,
                child: Transform.rotate(
                  angle: math.pi / 4,
                  child: Container(
                    width: width,
                    height: height,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFFF6B6F), Color(0xFFE53935)]),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.45), blurRadius: 6, offset: const Offset(0, 2))],
                    ),
                    child: Text(
                      'accountSoldBadge'.tr.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 12, height: 1.1, letterSpacing: 1),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
