import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

import '../constants/constants.dart';

const _background = Color(0xFF08090D);
const _gold = Color(0xFFFFC44A);

/// The branded loading view shown while the first network checks complete.
/// The native launch screens use the same dark background and logo.
class AnimatedSplash extends StatefulWidget {
  const AnimatedSplash({super.key});

  @override
  State<AnimatedSplash> createState() => _AnimatedSplashState();
}

class _AnimatedSplashState extends State<AnimatedSplash> with TickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
  late final AnimationController _ambient = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400));

  bool _reduceMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.of(context).disableAnimations;
    _entrance.duration = Duration(milliseconds: _reduceMotion ? 200 : 500);
    if (_entrance.value == 0) {
      _entrance.forward();
    }
    if (_reduceMotion) {
      _ambient.stop();
      _ambient.value = 0;
    } else if (!_ambient.isAnimating) {
      _ambient.repeat();
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    _ambient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entrance = CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic);
    return Scaffold(
      backgroundColor: _background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final emblemSize = math.min(240.0, math.max(150.0, constraints.maxWidth * 0.52));
          final ringSize = emblemSize + 58;
          return Stack(
            fit: StackFit.expand,
            children: [
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(center: Alignment(0, -0.12), radius: 0.78, colors: [Color(0xFF30200E), Color(0xFF12100E), _background], stops: [0, 0.45, 1]),
                ),
              ),
              IgnorePointer(
                child: CustomPaint(painter: _SparkPainter(_ambient, animate: !_reduceMotion)),
              ),
              SafeArea(
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    SizedBox(
                      width: ringSize,
                      height: ringSize,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned.fill(
                            child: CustomPaint(painter: _OrbitPainter(_ambient, animate: !_reduceMotion)),
                          ),
                          FadeTransition(
                            opacity: entrance,
                            child: ScaleTransition(
                              scale: Tween<double>(begin: _reduceMotion ? 1 : 0.94, end: 1).animate(entrance),
                              child: Image.asset(logo, width: emblemSize, height: emblemSize, fit: BoxFit.contain),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    FadeTransition(
                      opacity: entrance,
                      child: SlideTransition(
                        position: Tween<Offset>(begin: _reduceMotion ? Offset.zero : const Offset(0, 0.25), end: Offset.zero).animate(entrance),
                        child: Text(
                          'splashTagline'.tr,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFFD4B77A), fontFamily: gilroySemiBold, fontSize: 12, letterSpacing: 2.2),
                        ),
                      ),
                    ),
                    const Spacer(flex: 2),
                    Semantics(
                      label: 'splashLoading'.tr,
                      child: ExcludeSemantics(
                        child: Column(
                          children: [
                            Text(
                              'splashLoading'.tr,
                              style: const TextStyle(color: Color(0xFFB8A27B), fontFamily: gilroyMedium, fontSize: 13, letterSpacing: 1.6),
                            ),
                            const SizedBox(height: 13),
                            AnimatedBuilder(
                              animation: _ambient,
                              builder: (context, child) => Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(3, (index) {
                                  final wave = _reduceMotion ? 0.45 : (1 + math.sin(_ambient.value * 2 * math.pi - index * 0.75)) / 2;
                                  return Container(
                                    width: index == 1 ? 22 : 8,
                                    height: 4,
                                    margin: const EdgeInsets.symmetric(horizontal: 3),
                                    decoration: BoxDecoration(
                                      color: _gold.withValues(alpha: 0.3 + wave * 0.7),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _OrbitPainter extends CustomPainter {
  _OrbitPainter(this.animation, {required this.animate}) : super(repaint: animation);

  final Animation<double> animation;
  final bool animate;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 - 6;
    final time = animate ? animation.value : 0.0;
    final circle = Paint()
      ..color = _gold.withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius - 12, circle);
    canvas.drawCircle(center, radius - 25, circle..color = _gold.withValues(alpha: 0.08));

    final outer = Rect.fromCircle(center: center, radius: radius);
    final inner = Rect.fromCircle(center: center, radius: radius - 12);
    final bright = Paint()
      ..color = _gold.withValues(alpha: 0.92)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    final soft = Paint()
      ..color = _gold.withValues(alpha: 0.38)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(outer, -math.pi / 2 + 2 * math.pi * time, math.pi * 0.48, false, bright);
    canvas.drawArc(outer, math.pi / 2 + 2 * math.pi * time, math.pi * 0.24, false, soft);
    canvas.drawArc(inner, math.pi * 0.9 - 2 * math.pi * time, math.pi * 0.7, false, soft);
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) => oldDelegate.animation != animation || oldDelegate.animate != animate;
}

class _SparkPainter extends CustomPainter {
  _SparkPainter(this.animation, {required this.animate}) : super(repaint: animation);

  final Animation<double> animation;
  final bool animate;

  static const positions = <Offset>[
    Offset(0.12, 0.13),
    Offset(0.82, 0.08),
    Offset(0.27, 0.24),
    Offset(0.71, 0.21),
    Offset(0.08, 0.38),
    Offset(0.91, 0.34),
    Offset(0.21, 0.52),
    Offset(0.76, 0.49),
    Offset(0.09, 0.67),
    Offset(0.88, 0.63),
    Offset(0.34, 0.73),
    Offset(0.68, 0.77),
    Offset(0.14, 0.88),
    Offset(0.87, 0.91),
    Offset(0.43, 0.14),
    Offset(0.57, 0.84),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final time = animate ? animation.value : 0.0;
    for (var index = 0; index < positions.length; index++) {
      final position = positions[index];
      final phase = time * 2 * math.pi + index * 0.72;
      final opacity = animate ? 0.22 + (1 + math.sin(phase)) * 0.19 : 0.3;
      final x = position.dx * size.width + (animate ? math.sin(phase) * 4 : 0);
      final y = position.dy * size.height - (animate ? math.cos(phase) * 7 : 0);
      canvas.drawCircle(Offset(x, y), index.isEven ? 1.4 : 2.1, Paint()..color = _gold.withValues(alpha: opacity));
    }
  }

  @override
  bool shouldRepaint(covariant _SparkPainter oldDelegate) => oldDelegate.animation != animation || oldDelegate.animate != animate;
}
