import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/constants.dart';
import 'animated_nav_icon.dart';

/// One tab of the [FloatingNavBar].
class FloatingNavItem {
  const FloatingNavItem({
    required this.kind,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.hugeIcon,
  });

  final NavIconKind kind;
  final IconData icon;
  final IconData selectedIcon;

  /// HugeIcons glyph used for both states instead of [icon] / [selectedIcon];
  /// the selected state is drawn with a heavier stroke.
  final List<List<dynamic>>? hugeIcon;

  /// Translation key of the tab's label.
  final String label;
}

/// A full-width black bar above the page with an icon and a label per tab;
/// the selected tab turns gold and plays its icon scene in place.
class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({
    required this.items,
    required this.selectedIndex,
    required this.onTap,
    super.key,
  });

  final List<FloatingNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  static const Color _gold = Color(0xFFFFC83D);
  static const Color _muted = Color(0xFF8D9AB8);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: Color(0xFF3A3A3F))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++) Expanded(child: _tab(i)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tab(int i) {
    final item = items[i];
    final selected = i == selectedIndex;
    final color = selected ? _gold : _muted;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(i),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Fixed box: the scene plays inside it, so nothing moves on selection.
          SizedBox(
            width: 28,
            height: 28,
            child: Center(
              child: AnimatedNavIcon(
                kind: item.kind,
                icon: selected ? item.selectedIcon : item.icon,
                hugeIcon: item.hugeIcon,
                hugeStrokeWidth: selected ? 2.2 : 1.5,
                selected: selected,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 4),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 220),
            style: TextStyle(
              color: color,
              fontFamily: selected ? gilroySemiBold : gilroyRegular,
              fontSize: 12,
              height: 1.2,
            ),
            child: Text(
              item.label.tr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
