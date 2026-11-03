import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

/// Which tab an [AnimatedNavIcon] belongs to; each one plays its own scene when
/// it becomes selected.
enum NavIconKind { home, list, gift, wallet, profile }

/// A bottom-nav icon that plays a short drawn scene each time its tab gets
/// selected:
///
/// - home    — the PUBG frying pan winds up and whacks, with an impact burst
/// - list    — a checklist gets ticked off row by row
/// - gift    — the lid springs open and UC coins, a star and a ticket fly out
/// - wallet  — coins drop into the wallet, which squashes on each catch
/// - profile — the head turns left, then right, then back to centre
///
/// Scenes are drawn filled, on a 24x24 grid, to match the filled icon shown
/// for a selected tab; they cross-fade with it at the start and the end. At
/// rest (and when the OS asks for reduced motion) it is a plain [Icon].
///
/// The scene is painted straight from the animation (no widget rebuilds per
/// frame) inside its own [RepaintBoundary], and every motion is eased or
/// spring-damped so velocity never jumps.
class AnimatedNavIcon extends StatefulWidget {
  const AnimatedNavIcon({required this.kind, required this.icon, required this.selected, super.key, this.size = 24, this.color = Colors.white, this.hugeIcon, this.hugeStrokeWidth});

  final NavIconKind kind;
  final IconData icon;
  final bool selected;
  final double size;
  final Color color;

  /// When set, the resting glyph is drawn from this HugeIcons data instead of [icon].
  final List<List<dynamic>>? hugeIcon;
  final double? hugeStrokeWidth;

  @override
  State<AnimatedNavIcon> createState() => _AnimatedNavIconState();
}

class _AnimatedNavIconState extends State<AnimatedNavIcon> with SingleTickerProviderStateMixin {
  late final AnimationController _scene = AnimationController(vsync: this, duration: const Duration(milliseconds: 1900));
  late final Animation<double> _restOpacity = _scene.drive(_RestFade());

  @override
  void initState() {
    super.initState();
    // Swap between the plain icon and the scene when a run starts or ends.
    _scene.addStatusListener((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void didUpdateWidget(AnimatedNavIcon old) {
    super.didUpdateWidget(old);
    if (widget.selected && !old.selected && !MediaQuery.disableAnimationsOf(context)) {
      _scene.forward(from: 0);
    } else if (!widget.selected && old.selected) {
      _scene.reset();
    }
  }

  @override
  void dispose() {
    _scene.dispose();
    super.dispose();
  }

  Widget _rest() {
    final huge = widget.hugeIcon;
    if (huge != null) {
      return HugeIcon(icon: huge, size: widget.size, color: widget.color, strokeWidth: widget.hugeStrokeWidth);
    }
    return Icon(widget.icon, size: widget.size, color: widget.color);
  }

  _ScenePainter _painter() => switch (widget.kind) {
    NavIconKind.home => _PanPainter(_scene, widget.color),
    NavIconKind.list => _ChecklistPainter(_scene, widget.color),
    NavIconKind.gift => _GiftPainter(_scene, widget.color),
    NavIconKind.wallet => _WalletPainter(_scene, widget.color),
    NavIconKind.profile => _ProfilePainter(_scene, widget.color),
  };

  Widget _wobble(Widget glyph) {
    final u = _scene.value * 1.4;
    final decay = math.exp(-5 * u);
    final pulse = decay * math.sin(14 * u);
    return Transform.rotate(
      angle: 0.14 * decay * math.sin(18 * u),
      child: Transform.scale(scaleX: 1 + 0.22 * pulse, scaleY: 1 - 0.26 * pulse, child: glyph),
    );
  }

  // Two coins fall into the wallet one after the other; the wallet squashes
  // a little each time it catches one.
  static const _coinDrops = [(x: 0.40, a: 0.06, b: 0.42), (x: 0.60, a: 0.38, b: 0.74)];

  Widget _coinsIntoWallet(Widget glyph) {
    final size = widget.size;
    final s = _scene.value;
    var squash = 0.0;
    for (final d in _coinDrops) {
      final u = _seg(s, d.b - 0.02, d.b + 0.22);
      squash += 1.8 * math.exp(-5 * u) * math.sin(12 * u);
    }
    squash = squash.clamp(-0.6, 1.0);

    final coins = <Widget>[];
    for (final d in _coinDrops) {
      final t = _seg(s, d.a, d.b);
      if (t <= 0 || t >= 1) {
        continue;
      }
      final y = _lerp(-0.25, 0.30, Curves.easeInQuad.transform(t)) * size;
      final fade = Curves.easeOut.transform((t / 0.2).clamp(0.0, 1.0));
      // The coin spins on its way down: its width follows |cos|.
      final w = size * 0.30 * (0.45 + 0.55 * math.cos(t * 3 * math.pi).abs());
      coins.add(
        Positioned(
          // Relative to the clip box below, which starts half a size left of and a full size above the glyph.
          left: d.x * size - w / 2 + size * 0.5,
          top: y - size * 0.15 + size,
          child: Container(
            width: w,
            height: size * 0.30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _amber.withValues(alpha: fade),
              border: Border.all(color: _amberDark.withValues(alpha: fade), width: 1),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Transform(alignment: Alignment.bottomCenter, transform: Matrix4.diagonal3Values(1 + 0.06 * squash, 1 - 0.09 * squash, 1), child: glyph),
          // Clipped at the wallet's top edge, so the coin seems to go in the slot.
          Positioned(
            left: -size * 0.5,
            right: -size * 0.5,
            top: -size,
            height: size * 1.28,
            child: ClipRect(
              child: Stack(clipBehavior: Clip.none, children: [for (final c in coins) c]),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_scene.isAnimating) {
      return _rest();
    }
    if (widget.hugeIcon != null) {
      // A HugeIcons glyph keeps its own shape, so the scene is played with the
      // glyph itself: coins drop into a wallet, anything else squashes and wobbles.
      return AnimatedBuilder(animation: _scene, builder: (context, child) => widget.kind == NavIconKind.wallet ? _coinsIntoWallet(child!) : _wobble(child!), child: _rest());
    }
    return RepaintBoundary(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            FadeTransition(opacity: _restOpacity, child: _rest()),
            CustomPaint(size: Size.square(widget.size), painter: _painter()),
          ],
        ),
      ),
    );
  }
}

// ── shared helpers ───────────────────────────────────────────────────────────

const _amber = Color(0xFFFFC83D);
const _amberDark = Color(0xFFB57F00);
const _green = Color(0xFF34C759);
const _layerBounds = Rect.fromLTWH(-10, -10, 44, 44);

double _seg(double s, double a, double b) => ((s - a) / (b - a)).clamp(0.0, 1.0);

double _lerp(double a, double b, double t) => ui.lerpDouble(a, b, t)!;

/// 0 at both ends of a run, 1 in between; the eased cross-fade between the
/// real icon and the drawn scene.
double _sceneAlpha(double s) => Curves.easeInOut.transform(math.min(1.0, math.min(s / 0.14, (1 - s) / 0.14)).clamp(0.0, 1.0));

/// A damped spring from 0 that overshoots and settles at 1: smooth in both
/// position and velocity, unlike a hand-picked back curve.
double _spring(double u) => u <= 0 ? 0 : 1 - math.exp(-6.5 * u) * math.cos(10 * u);

/// Fades in over the first [inEnd] and out over the last [1 - outStart] of a
/// 0..1 window, with no hard edge.
double _window(double t, {double inEnd = 0.2, double outStart = 0.65}) {
  final a = Curves.easeOut.transform((t / inEnd).clamp(0.0, 1.0));
  final b = Curves.easeIn.transform(((1 - t) / (1 - outStart)).clamp(0.0, 1.0));
  return math.min(a, b);
}

class _RestFade extends Animatable<double> {
  @override
  double transform(double t) => 1 - _sceneAlpha(t);
}

Paint _clear() => Paint()..blendMode = BlendMode.clear;

Paint _clearStroke(double w) => Paint()
  ..blendMode = BlendMode.clear
  ..style = PaintingStyle.stroke
  ..strokeWidth = w
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;

Paint _strokeOf(Color c, double w) => Paint()
  ..color = c
  ..style = PaintingStyle.stroke
  ..strokeWidth = w
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;

/// Base painter: scales to the 24x24 grid and draws the glyph in its own layer
/// so [_clear] shapes punch real holes through it, then fades it by [alpha].
/// It repaints from [anim] directly, so no widget is rebuilt per frame.
abstract class _ScenePainter extends CustomPainter {
  _ScenePainter(this.anim, this.color) : super(repaint: anim);

  final Animation<double> anim;
  final Color color;

  double get s => anim.value;
  double get alpha => _sceneAlpha(s);

  /// The filled glyph (may use [_clear] to cut details out of it).
  void glyph(Canvas canvas, Paint fill);

  /// Extras drawn over the glyph, outside its layer (coins, bursts, ...).
  void extras(Canvas canvas) {}

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24);
    // Drawn a little larger than the 24 grid: the filled icon font fills more of its box.
    canvas.translate(12, 12);
    canvas.scale(1.2);
    canvas.translate(-12, -12);
    canvas.saveLayer(_layerBounds, Paint()..color = Color.fromRGBO(255, 255, 255, alpha));
    glyph(canvas, Paint()..color = color);
    canvas.restore();
    extras(canvas);
  }

  @override
  bool shouldRepaint(_ScenePainter old) => old.anim != anim || old.color != color;
}

// ── profile: the head glances left, then right ───────────────────────────────

class _ProfilePainter extends _ScenePainter {
  _ProfilePainter(super.anim, super.color);

  static final Path _shoulders = Path()
    ..moveTo(4.4, 21)
    ..cubicTo(4.4, 16.8, 7.8, 14.2, 12, 14.2)
    ..cubicTo(16.2, 14.2, 19.6, 16.8, 19.6, 21)
    ..close();

  @override
  void glyph(Canvas canvas, Paint fill) {
    // One continuous swing: left, through the centre, right, settling with
    // zero speed at both ends. 0.7698 normalises the peak to +-1.
    final u = _seg(s, 0.06, 0.94);
    final look = -math.sin(2 * math.pi * u) * math.sin(math.pi * u) / 0.7698;

    canvas.save();
    canvas.translate(-look * 0.6, 0);
    canvas.drawPath(_shoulders, fill);
    canvas.restore();

    canvas.save();
    canvas.translate(12 + look * 1.9, 7.5 + look.abs() * 0.3);
    canvas.rotate(look * 0.1);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 8.8 * (1 - 0.2 * look.abs()), height: 8.8), fill);
    // Eyes follow the turn, so the glance actually reads as a glance.
    final eyes = Curves.easeInOut.transform(_seg(s, 0.04, 0.2)) * (1 - Curves.easeInOut.transform(_seg(s, 0.84, 0.96)));
    for (final dx in const [-1.7, 1.7]) {
      canvas.drawCircle(Offset(look * 1.0 + dx * (1 - 0.45 * look.abs()), -0.1), 0.9 * eyes, _clear());
    }
    canvas.restore();
  }
}

// ── wallet: coins drop in ────────────────────────────────────────────────────

class _WalletPainter extends _ScenePainter {
  _WalletPainter(super.anim, super.color);

  // Coin drop windows; each lands at the end of its window.
  static const _drops = [(x: 9.2, a: 0.08, b: 0.46), (x: 13.2, a: 0.38, b: 0.76)];

  @override
  void glyph(Canvas canvas, Paint fill) {
    // The wallet squashes a little each time it catches a coin, then springs back.
    var squash = 0.0;
    for (final d in _drops) {
      final u = _seg(s, d.b - 0.02, d.b + 0.22);
      // A quick dip right at the catch, then a damped rebound.
      squash += 1.8 * math.exp(-5 * u) * math.sin(12 * u);
    }
    squash = squash.clamp(-0.6, 1.0);
    canvas.save();
    canvas.translate(12, 20.5);
    canvas.scale(1 + 0.06 * squash, 1 - 0.09 * squash);
    canvas.translate(-12, -20.5);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTRB(3, 7.5, 21, 20.5), const Radius.circular(3.6)), fill);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTRB(13.4, 11.9, 21.6, 16.1), const Radius.circular(2.1)), _clear());
    canvas.drawCircle(const Offset(16.6, 14), 1.0, fill);
    canvas.restore();
  }

  @override
  void extras(Canvas canvas) {
    // The coin drops behind the wallet's top edge, so it seems to go in the slot.
    canvas.save();
    canvas.clipRect(const Rect.fromLTRB(-8, -14, 32, 8.4));
    for (final d in _drops) {
      final t = _seg(s, d.a, d.b);
      if (t <= 0 || t >= 1) {
        continue;
      }
      final y = _lerp(-3, 10.5, Curves.easeInQuad.transform(t));
      final fade = Curves.easeOut.transform((t / 0.2).clamp(0.0, 1.0));
      // The coin spins on its way down: its width follows |cos|.
      final w = 3.3 * (0.45 + 0.55 * math.cos(t * 3 * math.pi).abs());
      canvas.drawOval(Rect.fromCenter(center: Offset(d.x, y), width: w * 2, height: 6.6), Paint()..color = _amber.withValues(alpha: fade));
      canvas.drawOval(Rect.fromCenter(center: Offset(d.x, y), width: w * 1.1, height: 3.8), _strokeOf(_amberDark.withValues(alpha: fade), 0.8));
    }
    canvas.restore();
  }
}

// ── gift: lid springs open, UC and goodies fly out ───────────────────────────

class _GiftPainter extends _ScenePainter {
  _GiftPainter(super.anim, super.color);

  // (x spread, start, end, kind) — 0 coin, 1 star, 2 ticket.
  static const _items = [(dx: -5.0, a: 0.16, b: 0.8, kind: 0), (dx: 0.0, a: 0.22, b: 0.88, kind: 1), (dx: 5.2, a: 0.18, b: 0.84, kind: 0), (dx: -2.0, a: 0.34, b: 0.94, kind: 2)];

  @override
  void glyph(Canvas canvas, Paint fill) {
    final open = _spring(_seg(s, 0.02, 0.5)) * (1 - Curves.easeInOut.transform(_seg(s, 0.8, 0.97)));
    // Body.
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTRB(4.5, 11, 19.5, 21.5), const Radius.circular(2.3)), fill);
    canvas.drawRect(const Rect.fromLTRB(10.9, 11, 13.1, 21.6), _clear());
    // Lid hinged at its lower left corner, tilting back as it opens.
    canvas.save();
    canvas.translate(4, 10.6);
    canvas.rotate(-0.62 * open);
    canvas.translate(-4, -10.6);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTRB(3, 7, 21, 11.4), const Radius.circular(1.8)), fill);
    canvas.drawRect(const Rect.fromLTRB(10.9, 6.9, 13.1, 11.5), _clear());
    canvas.restore();
  }

  @override
  void extras(Canvas canvas) {
    for (final it in _items) {
      final t = _seg(s, it.a, it.b);
      if (t <= 0 || t >= 1) {
        continue;
      }
      final rise = Curves.easeOutCubic.transform(t);
      final c = Offset(12 + it.dx * rise, _lerp(10.5, -2.5, rise));
      final a = _window(t);
      final pop = _spring((t / 0.45).clamp(0.0, 1.0)).clamp(0.0, 1.15);
      final paint = Paint()..color = _amber.withValues(alpha: a);
      switch (it.kind) {
        case 0:
          canvas.drawCircle(c, 3.0 * pop, paint);
          canvas.drawCircle(c, 1.7 * pop, _strokeOf(_amberDark.withValues(alpha: a), 0.8));
        case 1:
          _star(canvas, c, 3.8 * pop, t * 2.4, paint);
        default:
          canvas.save();
          canvas.translate(c.dx, c.dy);
          canvas.rotate(-0.5 + t * 1.2);
          final r = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: 6 * pop, height: 3.6 * pop), const Radius.circular(0.9));
          canvas.drawRRect(r, Paint()..color = Colors.white.withValues(alpha: a));
          canvas.drawCircle(Offset.zero, 0.8 * pop, paint);
          canvas.restore();
      }
    }
  }

  void _star(Canvas canvas, Offset c, double r, double rot, Paint paint) {
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(rot);
    final p = Path()
      ..moveTo(0, -r)
      ..quadraticBezierTo(0, 0, r, 0)
      ..quadraticBezierTo(0, 0, 0, r)
      ..quadraticBezierTo(0, 0, -r, 0)
      ..quadraticBezierTo(0, 0, 0, -r)
      ..close();
    canvas.drawPath(p, paint);
    canvas.restore();
  }
}

// ── list: rows get ticked off ────────────────────────────────────────────────

class _ChecklistPainter extends _ScenePainter {
  _ChecklistPainter(super.anim, super.color);

  static final Path _tick = Path()
    ..moveTo(0, 0)
    ..lineTo(1.5, 1.6)
    ..lineTo(4.1, -1.7);

  static final ui.PathMetric _tickMetric = _tick.computeMetrics().first;

  double _row(int i) => _seg(s, 0.1 + 0.2 * i, 0.34 + 0.2 * i);

  @override
  void glyph(Canvas canvas, Paint fill) {
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTRB(4.5, 3, 19.5, 21), const Radius.circular(3.2)), fill);
    for (var i = 0; i < 3; i++) {
      final y = 8.2 + 4.3 * i;
      // The row's line retracts to make room for its tick.
      final startX = _lerp(7.6, 11.2, Curves.easeInOut.transform(_row(i)));
      canvas.drawLine(Offset(startX, y), Offset(16.4, y), _clearStroke(1.7));
    }
  }

  @override
  void extras(Canvas canvas) {
    for (var i = 0; i < 3; i++) {
      final y = 8.2 + 4.3 * i;
      final p = _row(i);
      if (p <= 0) {
        continue;
      }
      final bump = 1 + 0.22 * math.sin(math.pi * Curves.easeInOut.transform(p));
      canvas.save();
      canvas.translate(6.6, y);
      canvas.scale(bump);
      final tick = _tickMetric.extractPath(0, _tickMetric.length * Curves.easeInOut.transform(p));
      canvas.drawPath(tick, _strokeOf(_green.withValues(alpha: alpha.clamp(0.0, 1.0)), 1.8));
      canvas.restore();
    }
  }
}

// ── home: the PUBG frying pan ────────────────────────────────────────────────

class _PanPainter extends _ScenePainter {
  _PanPainter(super.anim, super.color);

  static const _hand = Offset(21, 9.5);

  /// Wind up, strike, then a damped wobble that settles flat: the strike's
  /// speed carries straight into the wobble, so there is no jump at impact.
  double get _angle {
    if (s < 0.3) {
      return 0.5 * Curves.easeInOut.transform(_seg(s, 0.04, 0.3));
    }
    if (s < 0.42) {
      return _lerp(0.5, -0.3, Curves.easeInCubic.transform(_seg(s, 0.3, 0.42)));
    }
    final u = _seg(s, 0.42, 1.0);
    return -0.3 * math.exp(-5.5 * u) * math.cos(9 * u);
  }

  @override
  void glyph(Canvas canvas, Paint fill) {
    canvas.save();
    canvas.translate(_hand.dx, _hand.dy);
    canvas.rotate(_angle);
    canvas.translate(-_hand.dx, -_hand.dy);
    // Handle, then the pan head with its inner rim.
    final handle = Paint()
      ..color = fill.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.7
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(14.4, 13), const Offset(22.2, 9.3), handle);
    canvas.drawCircle(const Offset(9, 14.5), 6.4, fill);
    canvas.drawCircle(const Offset(9, 14.5), 4.5, _clearStroke(0.9));
    canvas.drawCircle(const Offset(21.4, 9.5), 0.7, _clear());
    canvas.restore();
  }

  @override
  void extras(Canvas canvas) {
    // Impact burst where the pan lands.
    final t = _seg(s, 0.4, 0.8);
    if (t <= 0 || t >= 1) {
      return;
    }
    const c = Offset(3.4, 19.4);
    final r = Curves.easeOutCubic.transform(t);
    final a = 1 - Curves.easeIn.transform(t);
    final paint = _strokeOf(_amber.withValues(alpha: a), 1.5);
    for (var i = 0; i < 7; i++) {
      final ang = -math.pi * 0.95 + i * (math.pi * 1.3 / 6);
      final d = Offset(math.cos(ang), math.sin(ang));
      canvas.drawLine(c + d * (1.8 + 1.2 * r), c + d * (3.0 + 3.6 * r), paint);
    }
    canvas.drawCircle(c, 1.6 * (1 - r) + 0.4, Paint()..color = Colors.white.withValues(alpha: a));
  }
}
