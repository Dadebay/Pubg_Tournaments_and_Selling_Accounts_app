import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

import 'centered_header.dart';
import 'constants.dart';

const _gold = Color(0xFFFFC83D);

/// One tab of a [SegmentedTabs] control.
class SegmentTab {
  const SegmentTab({required this.label, this.icon});

  final String label;
  final List<List<dynamic>>? icon;
}

/// Segmented control: a gold pill slides under the selected tab.
class SegmentedTabs extends StatelessWidget {
  const SegmentedTabs({required this.tabs, required this.selectedIndex, required this.onChanged, super.key});

  final List<SegmentTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final n = tabs.length;
    return Container(
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C20),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            // x runs from -1 (first slot) to 1 (last slot).
            alignment: Alignment(n == 1 ? 0 : -1 + 2 * selectedIndex / (n - 1), 0),
            child: FractionallySizedBox(
              widthFactor: 1 / n,
              heightFactor: 1,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(colors: [Color(0xFFFFD96B), _gold]),
                  boxShadow: [BoxShadow(color: _gold.withValues(alpha: 0.35), blurRadius: 14)],
                ),
              ),
            ),
          ),
          Row(
            children: [
              for (var i = 0; i < n; i++)
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (i != selectedIndex) {
                        HapticFeedback.selectionClick();
                        onChanged(i);
                      }
                    },
                    child: _label(i),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _label(int i) {
    final selected = i == selectedIndex;
    final color = selected ? Colors.black : Colors.white70;
    final tab = tabs[i];
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (tab.icon != null) ...[
            TweenAnimationBuilder<Color?>(
              tween: ColorTween(end: color),
              duration: const Duration(milliseconds: 220),
              builder: (context, value, _) => HugeIcon(icon: tab.icon!, color: value ?? color, size: 18),
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              style: TextStyle(color: color, fontFamily: selected ? gilroyBold : gilroySemiBold, fontSize: 15),
              child: Text(tab.label, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ),
        ],
      ),
    );
  }
}

/// A page whose header scrolls away with the content while the tab bar stays
/// pinned to the top: scrolling up hides the title and the tabs take its place.
class CollapsingTabsPage extends StatelessWidget {
  const CollapsingTabsPage({required this.title, required this.tabs, required this.selectedIndex, required this.onTabChanged, required this.body, this.subtitle, this.actions, this.onBack, this.onRefresh, this.bottomPadding = 0, this.titleSize = 26, this.centerTitle = false, super.key});

  /// Translation key of the page title.
  final String title;
  final String? subtitle;
  final Widget? actions;
  final VoidCallback? onBack;
  final List<SegmentTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  /// The tab's content; laid out at its natural height inside the page's scroll.
  final Widget body;
  final Future<void> Function()? onRefresh;
  final double bottomPadding;

  /// Font size of the page title.
  final double titleSize;

  /// Centers the title between the back button and the actions.
  final bool centerTitle;

  @override
  Widget build(BuildContext context) {
    final scroll = CustomScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        SliverToBoxAdapter(child: _header()),
        SliverPersistentHeader(
          pinned: true,
          delegate: _TabsHeader(tabs: tabs, selectedIndex: selectedIndex, onChanged: onTabChanged),
        ),
        // A plain box adapter, not SliverFillRemaining: that one asks its child for
        // intrinsic sizes, which a shrink-wrapped grid or a Stack cannot give.
        // The body gets the viewport height left under the tabs as its minimum, so
        // a `Center` in it (an empty or loading state) is centered in the page.
        SliverLayoutBuilder(
          builder: (context, constraints) {
            final minHeight = (constraints.viewportMainAxisExtent - constraints.precedingScrollExtent - bottomPadding).clamp(0.0, double.infinity);
            return SliverToBoxAdapter(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOutCubic,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween(begin: const Offset(0, 0.025), end: Offset.zero).animate(animation),
                    child: child,
                  ),
                ),
                layoutBuilder: (current, previous) => Stack(alignment: Alignment.topCenter, children: [...previous, ?current]),
                child: KeyedSubtree(
                  key: ValueKey(selectedIndex),
                  child: Column(
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(minHeight: minHeight),
                        child: body,
                      ),
                      SizedBox(height: bottomPadding),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
    return Container(
      color: Colors.black,
      // The status bar area stays black while the content scrolls beneath it.
      padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
      child: onRefresh == null ? scroll : RefreshIndicator(color: _gold, backgroundColor: const Color(0xFF1C1C20), onRefresh: onRefresh!, child: scroll),
    );
  }

  Widget _header() {
    if (centerTitle) {
      return CenteredHeader(title: title.tr, onBack: onBack, trailing: actions, size: titleSize);
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Row(
        children: [
          if (onBack != null)
            GestureDetector(
              onTap: onBack,
              child: Container(
                width: 44,
                height: 44,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.08)),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: titleSize),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontFamily: gilroyMedium, fontSize: 14),
                  ),
                ],
              ],
            ),
          ),
          ?actions,
        ],
      ),
    );
  }
}

class _TabsHeader extends SliverPersistentHeaderDelegate {
  const _TabsHeader({required this.tabs, required this.selectedIndex, required this.onChanged});

  final List<SegmentTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  static const _height = 76.0;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // The header must fill its whole extent, or the sliver reports a paint
    // extent smaller than its layout extent: fixed height, centred content.
    return SizedBox(
      height: _height,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.black,
          // A hairline appears only once content scrolls beneath the pinned tabs.
          border: Border(
            bottom: BorderSide(color: Colors.white.withValues(alpha: overlapsContent ? 0.08 : 0)),
          ),
        ),
        child: SegmentedTabs(tabs: tabs, selectedIndex: selectedIndex, onChanged: onChanged),
      ),
    );
  }

  @override
  bool shouldRebuild(_TabsHeader old) => old.selectedIndex != selectedIndex || old.tabs != tabs;
}
