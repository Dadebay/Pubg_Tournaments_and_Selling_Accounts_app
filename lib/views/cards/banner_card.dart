import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';
import 'package:game_app/views/home_page/banner_profil.dart';
import 'package:get/get.dart';

import '../constants/constants.dart';
import '../constants/widgets.dart';

class BannerCard extends StatelessWidget {
  final String image;
  final String content;
  final String title;

  const BannerCard({required this.image, required this.title, required this.content, super.key});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => BannerProfileView(title, image, content));
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        width: double.infinity,
        decoration: const BoxDecoration(borderRadius: borderRadius15),
        child: ClipRRect(
          borderRadius: borderRadius15,
          child: CachedNetworkImage(
            fadeInCurve: Curves.ease,
            imageUrl: image,
            imageBuilder: (context, imageProvider) => Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: borderRadius20,
                image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
              ),
            ),
            placeholder: (context, url) => Center(child: spinKit()),
            errorWidget: (context, url, error) => noBannerImage(),
          ),
        ),
      ),
    );
  }
}
