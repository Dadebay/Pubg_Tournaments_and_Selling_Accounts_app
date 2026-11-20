import 'package:material_ui/material_ui.dart';
import 'package:hugeicons/hugeicons.dart';

import 'constants.dart';

/// The top bar of a page: a round back button on the left and the title centered.
class CenteredHeader extends StatelessWidget {
  const CenteredHeader({required this.title, this.onBack, this.trailing, this.size = 22, super.key});

  /// Shown as given; pass it translated.
  final String title;

  /// Back button action; null hides the button.
  final VoidCallback? onBack;
  final Widget? trailing;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: SizedBox(
        height: 46,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Room on both sides, so the title stays centered whatever the buttons are.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 56),
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: size),
              ),
            ),
            if (onBack != null)
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: onBack,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.06),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
                    ),
                    child: const Center(
                      child: HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01, color: Colors.white, size: 20, strokeWidth: 2),
                    ),
                  ),
                ),
              ),
            if (trailing != null) Align(alignment: Alignment.centerRight, child: trailing),
          ],
        ),
      ),
    );
  }
}
