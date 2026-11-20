import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../constants/constants.dart';
import 'animated_nav_icon.dart';

/// One tab of the [WheelNavBar].
class WheelNavItem {
  const WheelNavItem({required this.kind, required this.icon, required this.selectedIcon});

  final NavIconKind kind;
  final IconData icon;
  final IconData selectedIcon;
}

/// A turntable-style nav bar: the icons sit on a dome, and tapping one (or
/// dragging the bar sideways) spins the dome so that icon rises to the top
/// centre as a round button. The ring wraps, so spinning past either end
/// carries on into the icons on the other side.
class WheelNavBar extends StatefulWidget {
  const WheelNavBar({required this.items, required this.selectedIndex, required this.onTap, super.key});

  final List<WheelNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  /// Height of the whole bar without the system inset.
  static const double height = _barHeight + _domeHitOverhang;

  @override
  State<WheelNavBar> createState() => _WheelNavBarState();
}

// ── Geometry ─────────────────────────────────────────────────────────────
const _barHeight = 42.0;
const _fabSize = 56.0;
const _iconBoxSize = 40.0;
const _minTapTarget = 52.0;
const _diskR = 400.0; // radius of the dome
const _pathR = 365.0; // radius of the ring the unselected icons travel on
const _selectedR = 390.0; // radius the selected icon rides at, so it floats on the rim
const _stepRad = 14.0 * math.pi / 220.0; // angle between two icons
const _domeLift = 40.0; // how far the dome pokes above the bar's top edge
const _domeHitOverhang = _domeLift + 6; // keeps the raised dome inside the hit-test box
const _windowRad = 1.90;
const _fadeStart = 1.60;
const _pxPerStep = _pathR * _stepRad;
const _flingVelocity = 320.0; // px/s

const _gold = Color(0xFFFFC83D);
const _unselected = Color(0xFF8D9AB8);

class _WheelNavBarState extends State<WheelNavBar> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 520));
  late final Animation<double> _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);

  // Where the current settle animation started from; a double because a hand
  // turned wheel is released between two slots.
  double _fromFloat = 0;
  // The wheel's position while a finger turns it; null otherwise.
  double? _dragFloat;
  int? _lastDetent;

  int get _n => widget.items.length;

  @override
  void initState() {
    super.initState();
    _fromFloat = widget.selectedIndex.toDouble();
  }

  @override
  void didUpdateWidget(WheelNavBar old) {
    super.didUpdateWidget(old);
    if (old.selectedIndex != widget.selectedIndex) {
      // Re-aim from wherever the wheel actually is, not from the old tab.
      _fromFloat = _wrap(_dragFloat ?? _selFloatFor(old.selectedIndex));
      _dragFloat = null;
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  double _circular(double raw) {
    var x = raw % _n;
    if (x < 0) {
      x += _n;
    }
    if (x > _n / 2) {
      x -= _n;
    }
    return x;
  }

  double _wrap(double v) {
    var x = v % _n;
    if (x < 0) {
      x += _n;
    }
    return x;
  }

  double _selFloatFor(int selectedIndex) => _fromFloat + _circular(selectedIndex - _fromFloat) * _anim.value;

  void _onDragStart(DragStartDetails _) {
    _ctrl.stop();
    setState(() {
      _dragFloat = _selFloatFor(widget.selectedIndex);
      _lastDetent = _dragFloat!.round();
    });
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final drag = _dragFloat;
    if (drag == null) {
      return;
    }
    final next = _wrap(drag - details.delta.dx / _pxPerStep);
    final detent = next.round();
    if (detent != _lastDetent) {
      _lastDetent = detent;
      HapticFeedback.selectionClick();
    }
    setState(() => _dragFloat = next);
  }

  void _onDragEnd(DragEndDetails details) {
    final drag = _dragFloat;
    if (drag == null) {
      return;
    }
    final vx = details.velocity.pixelsPerSecond.dx;
    // A flick carries the wheel on in the direction it was thrown.
    final slot = vx.abs() >= _flingVelocity ? (vx < 0 ? drag.ceil() : drag.floor()) : drag.round();
    final target = ((slot % _n) + _n) % _n;
    setState(() {
      _fromFloat = drag;
      _dragFloat = null;
      _lastDetent = null;
    });
    if (target != widget.selectedIndex) {
      widget.onTap(target);
    }
    _ctrl.forward(from: 0);
  }

  void _onDragCancel() {
    final drag = _dragFloat;
    if (drag == null) {
      return;
    }
    setState(() {
      _fromFloat = drag;
      _dragFloat = null;
      _lastDetent = null;
    });
    _ctrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.viewPaddingOf(context).bottom;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final centreX = screenWidth / 2;
    final diskCenterY = _domeHitOverhang + (_diskR - _domeLift);
    final boxTop = _domeHitOverhang - (_domeLift + 2);
    final boxHeight = (_barHeight + _domeHitOverhang) - boxTop;

    return SizedBox(
      height: _barHeight + _domeHitOverhang + bottomPad,
      width: screenWidth,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragStart: _onDragStart,
        onHorizontalDragUpdate: _onDragUpdate,
        onHorizontalDragEnd: _onDragEnd,
        onHorizontalDragCancel: _onDragCancel,
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: _barHeight + _domeHitOverhang,
            child: AnimatedBuilder(
              animation: _anim,
              builder: (context, _) {
                final selFloat = _dragFloat ?? _selFloatFor(widget.selectedIndex);
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: boxTop,
                      left: 0,
                      right: 0,
                      height: boxHeight,
                      child: ClipRect(
                        child: CustomPaint(
                          size: Size(screenWidth, boxHeight),
                          painter: _DiskPainter(centerX: centreX, centerY: _diskR + 2, radius: _diskR, selFloat: selFloat),
                        ),
                      ),
                    ),
                    ..._buildIcons(centreX, diskCenterY, selFloat),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildIcons(double centreX, double diskCenterY, double selFloat) {
    // Every visible copy, including the wrap-around neighbours.
    final slots = <({int index, double angle, int copy})>[];
    for (var i = 0; i < _n; i++) {
      final rel = i - selFloat;
      final candidates = [rel, rel + _n, rel - _n];
      for (var c = 0; c < candidates.length; c++) {
        final angle = candidates[c] * _stepRad;
        if (angle.abs() < _windowRad) {
          slots.add((index: i, angle: angle, copy: c));
        }
      }
    }
    // Outermost first, so the centre icon ends up on top.
    slots.sort((a, b) => b.angle.abs().compareTo(a.angle.abs()));

    return slots.map((slot) {
      final angle = slot.angle;
      final absA = angle.abs();
      final opacity = ((_windowRad - absA) / (_windowRad - _fadeStart)).clamp(0.0, 1.0);
      if (opacity <= 0) {
        return const SizedBox.shrink();
      }
      // 1 at the very centre, 0 by the next slot.
      final fabFrac = (1 - absA / _stepRad).clamp(0.0, 1.0);
      final itemSize = ui.lerpDouble(_iconBoxSize, _fabSize, fabFrac)!;
      final iconSize = ui.lerpDouble(23.0, 27.0, fabFrac)!;
      final iconColor = Color.lerp(_unselected, Colors.white, fabFrac)!;
      final iconBottomPad = ui.lerpDouble(12.0, 0.0, fabFrac)!;
      final r = ui.lerpDouble(_pathR, _selectedR, fabFrac)!;
      final cx = centreX + r * math.sin(angle);
      final cy = diskCenterY - r * math.cos(angle);
      final shadows = fabFrac > 0.2 ? [BoxShadow(color: kPrimaryColor.withValues(alpha: 0.5 * fabFrac), blurRadius: 20, spreadRadius: 1)] : const <BoxShadow>[];
      final hitSize = math.max(itemSize, _minTapTarget);
      final item = widget.items[slot.index];
      final isSelected = slot.index == widget.selectedIndex && slot.copy == 0;

      return Positioned(
        // Keyed: the draw order changes as the wheel turns, and each icon keeps its own scene state.
        key: ValueKey('wheel-icon-${slot.index}-${slot.copy}'),
        left: cx - hitSize / 2,
        top: cy - hitSize / 2,
        child: Opacity(
          opacity: opacity,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => widget.onTap(slot.index),
            child: SizedBox(
              width: hitSize,
              height: hitSize,
              child: Center(
                child: Transform.rotate(
                  angle: angle,
                  child: Container(
                    width: itemSize,
                    height: itemSize,
                    margin: EdgeInsets.only(bottom: iconBottomPad + 10),
                    decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle, boxShadow: shadows),
                    child: Center(
                      child: AnimatedNavIcon(kind: item.kind, icon: isSelected ? item.selectedIcon : item.icon, selected: isSelected, size: iconSize, color: iconColor),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}

/// The dome, lighter at the top rim, with a hairline rim highlight.
class _DiskPainter extends CustomPainter {
  const _DiskPainter({required this.centerX, required this.centerY, required this.radius, required this.selFloat});

  final double centerX;
  final double centerY;
  final double radius;
  final double selFloat;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(centerX, centerY);
    canvas.drawCircle(center, radius, Paint()..shader = ui.Gradient.linear(Offset(center.dx, center.dy - radius), Offset(center.dx, center.dy - radius + 120), const [Color(0xFF16224A), Color(0xFF080E24)]));
    canvas.drawCircle(
      center,
      radius - 1,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = _gold.withValues(alpha: 0.22),
    );
  }

  @override
  bool shouldRepaint(_DiskPainter old) => old.centerX != centerX || old.centerY != centerY || old.radius != radius || old.selFloat != selFloat;
}
