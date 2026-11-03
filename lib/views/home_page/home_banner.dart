import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:game_app/models/home_page_model.dart';
import 'package:game_app/views/constants/shimmer.dart';
import 'package:game_app/views/home_page/banner_profil.dart';
import 'package:get/get.dart';

import '../constants/constants.dart';

/// The banners of `GET /api/banners/` at the top of the home page: a rounded
/// carousel that plays by itself, with the title over the picture and a dot bar.
/// Nothing is shown when there are no banners or the request fails.
class HomeBanner extends StatefulWidget {
  const HomeBanner({required this.future, super.key});

  final Future<List<BannerModel>> future;

  @override
  State<HomeBanner> createState() => _HomeBannerState();
}

class _HomeBannerState extends State<HomeBanner> {
  static const _gold = Color(0xFFFFC83D);

  final ValueNotifier<int> _index = ValueNotifier(0);

  @override
  void dispose() {
    _index.dispose();
    super.dispose();
  }

  String _imageUrl(String? image) {
    final value = image ?? '';
    return value.startsWith('http') ? value : '$serverURL$value';
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = width >= 800 ? 280.0 : (width * 0.46).clamp(150.0, 220.0);
    return FutureBuilder<List<BannerModel>>(
      future: widget.future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Shimmer(child: ShimmerBlock(height: height, radius: 26)),
          );
        }
        final banners = snapshot.data ?? const <BannerModel>[];
        if (snapshot.hasError || banners.isEmpty) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            children: [
              CarouselSlider.builder(
                itemCount: banners.length,
                itemBuilder: (context, index, realIndex) => _card(banners[index]),
                options: CarouselOptions(
                  height: height,
                  viewportFraction: banners.length == 1 ? 0.94 : 0.9,
                  enableInfiniteScroll: banners.length > 1,
                  autoPlay: banners.length > 1,
                  autoPlayInterval: const Duration(seconds: 5),
                  autoPlayAnimationDuration: const Duration(milliseconds: 700),
                  autoPlayCurve: Curves.easeOutCubic,
                  onPageChanged: (index, reason) => _index.value = index,
                ),
              ),
              if (banners.length > 1) _dots(banners.length),
            ],
          ),
        );
      },
    );
  }

  Widget _card(BannerModel banner) {
    final title = banner.title ?? '';
    final content = banner.content ?? '';
    final image = _imageUrl(banner.image);
    return GestureDetector(
      onTap: () => Get.to(() => BannerProfileView(title, image, content)),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          color: const Color(0xFF1B1B1E),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 18, offset: const Offset(0, 8))],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: image,
              fit: BoxFit.cover,
              fadeInCurve: Curves.ease,
              placeholder: (context, url) => const Shimmer(child: ShimmerBlock(radius: 0)),
              errorWidget: (context, url, error) => const Center(child: Icon(Icons.image_not_supported_outlined, color: Colors.white24, size: 36)),
            ),
            // Darkens the bottom so the title stays readable over any picture.
            if (title.isNotEmpty)
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.center, end: Alignment.bottomCenter, colors: [Colors.transparent, Color(0xCC000000)]),
                ),
              ),
            if (title.isNotEmpty)
              Positioned(
                left: 16,
                right: 16,
                bottom: 14,
                child: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 18, height: 1.15)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _dots(int count) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: ValueListenableBuilder<int>(
        valueListenable: _index,
        builder: (context, current, _) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < count; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == current ? 22 : 7,
                height: 7,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: i == current ? _gold : Colors.white.withValues(alpha: 0.25)),
              ),
          ],
        ),
      ),
    );
  }
}
