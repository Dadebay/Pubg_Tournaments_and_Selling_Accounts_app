import 'package:cached_network_image/cached_network_image.dart';
import 'package:game_app/models/uc_models.dart';
import 'package:game_app/views/cards/uc_package_card.dart';
import 'package:game_app/views/constants/index.dart';
import 'package:game_app/views/constants/shimmer.dart';

/// One product of the Premium tab, made for a two column grid: a warm gold card
/// with the product on a glowing plate, its name and
/// description and a price / quantity control.
class PremiumPackageCard extends StatelessWidget {
  const PremiumPackageCard({required this.model, super.key});

  final UcModel model;

  static const _gold = Color(0xFFFFC83D);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = UcCart.count(model) > 0;
      final description = UcCart.description(model);
      return GestureDetector(
        onTap: () => UcCart.add(model),
        onLongPress: () => UcCart.showDetail(model),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF3A2A12), Color(0xFF17130C), Color(0xFF101012)]),
            border: Border.all(color: selected ? _gold : _gold.withValues(alpha: 0.28), width: selected ? 1.6 : 1),
            boxShadow: [BoxShadow(color: _gold.withValues(alpha: selected ? 0.28 : 0.08), blurRadius: 20)],
          ),
          child: Column(
            children: [
              Expanded(child: _plate()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(model.title ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 18)),
              ),
              if (description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 3, 12, 0),
                  child: Text(description, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFC9BFA8), fontFamily: gilroyRegular, fontSize: 12, height: 1.25)),
                ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: selected ? UcStepper(key: const ValueKey('stepper'), model: model) : _priceButton(),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _plate() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(gradient: RadialGradient(radius: 0.75, colors: [_gold.withValues(alpha: 0.28), Colors.transparent])),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: CachedNetworkImage(
            imageUrl: UcCart.imageUrl(model),
            fit: BoxFit.contain,
            placeholder: (context, url) => const Shimmer(child: Center(child: ShimmerBlock(width: 80, height: 80, radius: 24))),
            errorWidget: (context, url, error) => const Center(child: Icon(IconlyBold.star, color: _gold, size: 44)),
          ),
        ),
      ],
    );
  }

  Widget _priceButton() {
    return Container(
      key: const ValueKey('price'),
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(colors: [Color(0xFFFFD866), Color(0xFFFF9800)]),
      ),
      child: Text(UcCart.priceText(model), style: const TextStyle(color: Color(0xFF1A1200), fontFamily: gilroyBold, fontSize: 16)),
    );
  }
}
