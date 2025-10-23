// ignore_for_file: file_names

import 'package:cached_network_image/cached_network_image.dart';
import 'package:game_app/views/other_pages/video_player_profile.dart';
import 'package:lottie/lottie.dart';

import '../constants/index.dart';

class VideoCard extends StatelessWidget {
  final String videoPath;
  final String image;

  const VideoCard({
    required this.videoPath,
    required this.image,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(
          () => VideoPLayerMine(
            videoURL: videoPath,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 200,
                  width: Get.size.width,
                  child: CachedNetworkImage(
                    fadeInCurve: Curves.ease,
                    imageUrl: image,
                    imageBuilder: (context, imageProvider) => Container(
                      width: Get.size.width,
                      decoration: BoxDecoration(
                        borderRadius: borderRadius15,
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    placeholder: (context, url) => Center(child: spinKit()),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.white.withOpacity(0.2),
                      child: Center(
                        child: Text(
                          'noImageBanner'.tr,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontFamily: josefinSansSemiBold),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(color: Colors.black54, borderRadius: borderRadius15),
                  ),
                ),
                Positioned.fill(
                  child: Center(
                    child: Lottie.asset(
                      'assets/lottie/playButton.json',
                      repeat: true,
                      animate: true,
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
