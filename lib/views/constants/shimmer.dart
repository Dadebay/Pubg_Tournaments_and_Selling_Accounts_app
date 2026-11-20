import 'package:material_ui/material_ui.dart';

/// Sweeps a soft highlight over [child] while something loads. Only the painted
/// parts of the child get the highlight, so build the child from solid blocks.
class Shimmer extends StatefulWidget {
  const Shimmer({required this.child, super.key});

  final Widget child;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) => ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (bounds) => LinearGradient(
          begin: const Alignment(-1, -0.3),
          end: const Alignment(1, 0.3),
          colors: [Colors.white.withValues(alpha: 0), Colors.white.withValues(alpha: 0.12), Colors.white.withValues(alpha: 0)],
          stops: const [0.35, 0.5, 0.65],
          transform: _SlideGradient(_controller.value),
        ).createShader(bounds),
        child: child,
      ),
    );
  }
}

/// Moves the gradient from one side of the box to the other.
class _SlideGradient extends GradientTransform {
  const _SlideGradient(this.progress);

  final double progress;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * (progress * 2 - 1), 0, 0);
  }
}

/// A rounded solid block of a skeleton.
class ShimmerBlock extends StatelessWidget {
  const ShimmerBlock({this.width, this.height, this.radius = 12, super.key});

  final double? width;
  final double? height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: const Color(0xFF2B2B30), borderRadius: BorderRadius.circular(radius)),
    );
  }
}

/// Placeholder grid shaped like the UC / premium cards, shown while a tab loads.
class CatalogSkeletonGrid extends StatelessWidget {
  const CatalogSkeletonGrid({this.premium = false, this.count = 6, super.key});

  final bool premium;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: GridView.builder(
        itemCount: count,
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 320, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: premium ? 0.7 : 0.78),
        itemBuilder: (context, index) => _SkeletonCard(premium: premium),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.premium});

  final bool premium;

  @override
  Widget build(BuildContext context) {
    final border = premium ? const Color(0xFFFFC83D).withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.08);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: premium ? const [Color(0xFF3A2A12), Color(0xFF17130C), Color(0xFF101012)] : const [Color(0xFF26262B), Color(0xFF121214)]),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          const Expanded(child: Center(child: ShimmerBlock(width: 96, height: 96, radius: 28))),
          const SizedBox(height: 10),
          const ShimmerBlock(width: 86, height: 20, radius: 8),
          if (premium) ...[const SizedBox(height: 8), const ShimmerBlock(width: 120, height: 12, radius: 6)],
          const SizedBox(height: 14),
          const ShimmerBlock(height: 42, radius: 14),
        ],
      ),
    );
  }
}
