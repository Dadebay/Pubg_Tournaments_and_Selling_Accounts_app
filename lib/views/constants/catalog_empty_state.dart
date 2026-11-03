import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

import 'constants.dart';

/// A compact message for catalog tabs with no content or a load error.
class CatalogEmptyState extends StatelessWidget {
  const CatalogEmptyState({
    required this.icon,
    required this.title,
    required this.description,
    this.imageAsset,
    this.actionLabel,
    this.actionIcon = IconlyLight.arrowRight,
    this.onAction,
    super.key,
  });

  final IconData icon;
  final String title;
  final String description;
  final String? imageAsset;
  final String? actionLabel;
  final IconData actionIcon;
  final VoidCallback? onAction;

  static const _gold = Color(0xFFFFC83D);

  @override
  Widget build(BuildContext context) {
    final imageWidth = (MediaQuery.sizeOf(context).width - 56).clamp(
      220.0,
      340.0,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (imageAsset != null)
            Image.asset(
              imageAsset!,
              width: imageWidth,
              height: imageWidth * 0.67,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              excludeFromSemantics: true,
            )
          else
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: const Color(0xFF1B1B1E),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
              ),
              child: Icon(icon, color: _gold, size: 38),
            ),
          SizedBox(height: imageAsset == null ? 26 : 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: gilroyBold,
              fontSize: 22,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 290),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFB8B8C0),
                fontFamily: gilroyRegular,
                fontSize: 15,
                height: 1.45,
              ),
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: onAction,
              style: FilledButton.styleFrom(
                backgroundColor: _gold,
                foregroundColor: Colors.black,
                minimumSize: const Size(0, 48),
                padding: const EdgeInsets.symmetric(horizontal: 22),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: Icon(actionIcon, size: 18),
              label: Text(
                actionLabel!,
                style: const TextStyle(fontFamily: gilroyBold, fontSize: 15),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
