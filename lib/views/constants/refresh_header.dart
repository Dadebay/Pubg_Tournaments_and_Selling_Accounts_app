import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart' show CircularProgressIndicator, Icons;
import 'package:pull_to_refresh/pull_to_refresh.dart';

const _gold = Color(0xFFFFC83D);

/// The pull-to-refresh header of the app: an arrow while pulling, a gold spinner
/// while loading. Built from plain widgets and the `material_ui` spinner, because
/// pull_to_refresh's own `MaterialClassicHeader` uses Flutter's old material widgets,
/// which fail to build next to the `material_ui` ones.
CustomHeader appRefreshHeader() {
  return CustomHeader(
    height: 70,
    refreshStyle: RefreshStyle.Follow,
    builder: (context, mode) {
      final Widget icon;
      switch (mode) {
        case RefreshStatus.refreshing:
          icon = const SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(strokeWidth: 3, color: _gold),
          );
        case RefreshStatus.completed:
          icon = const Icon(Icons.check_rounded, color: _gold, size: 28);
        case RefreshStatus.failed:
          icon = const Icon(Icons.error_outline_rounded, color: Color(0xFFFF5A5F), size: 28);
        default:
          icon = AnimatedRotation(
            turns: mode == RefreshStatus.canRefresh ? 0.5 : 0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(Icons.arrow_downward_rounded, color: _gold, size: 26),
          );
      }
      return SizedBox(height: 70, child: Center(child: icon));
    },
  );
}
