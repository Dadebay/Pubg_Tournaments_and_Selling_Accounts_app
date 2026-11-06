import 'package:cached_network_image/cached_network_image.dart';

import 'package:hugeicons/hugeicons.dart';

import '../../../models/get_posts_model.dart';
import '../../other_pages/video_player_profile.dart';
import 'notice_card.dart';
import 'video_preview.dart';
import '../../constants/index.dart';

class CustomFlexibleSpace extends StatelessWidget {
  final GetPostsAccountModel model;

  const CustomFlexibleSpace({required this.model, super.key});
  @override
  Widget build(BuildContext context) {
    return FlexibleSpaceBar(
      background: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [imagePart(model), const AccountNotice(), const SizedBox(height: 8)],
      ),
    );
  }

  /// The area on top: the account's first video (its poster with a play button) in
  /// place of the banner, and the other videos as small thumbnails where the round
  /// picture used to be. An account without a video keeps the banner picture.
  Expanded imagePart(GetPostsAccountModel model) {
    final videos = model.videos ?? const <GetAccountVideos>[];
    return Expanded(
      flex: 4,
      child: Stack(
        children: [
          Positioned.fill(
            bottom: videos.length > 1 ? 70 : 20,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              child: videos.isEmpty ? _banner(model) : _videoArea(videos.first, big: true),
            ),
          ),
          if (videos.length > 1)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 84,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                itemCount: videos.length - 1,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) => SizedBox(
                  width: 116,
                  child: ClipRRect(borderRadius: BorderRadius.circular(18), child: _videoArea(videos[index + 1], big: false)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _banner(GetPostsAccountModel model) {
    return CachedNetworkImage(
      fadeInCurve: Curves.ease,
      imageUrl: "$serverURL${model.bgImage ?? ""}",
      fit: BoxFit.cover,
      width: double.infinity,
      placeholder: (context, url) => Center(child: spinKit()),
      errorWidget: (context, url, error) => Image.asset(accountBackImage, fit: BoxFit.cover),
    );
  }

  /// A video's poster with a gold play button; a tap opens the player.
  Widget _videoArea(GetAccountVideos video, {required bool big}) {
    const gold = Color(0xFFFFC83D);
    return GestureDetector(
      onTap: () => Get.to(() => VideoPLayerMine(videoURL: mediaUrl(video.video))),
      child: Stack(
        fit: StackFit.expand,
        children: [
          VideoPreview(poster: video.poster, video: video.video),
          Container(color: Colors.black.withValues(alpha: 0.3)),
          Center(
            child: Container(
              width: big ? 70 : 34,
              height: big ? 70 : 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: gold,
                boxShadow: [BoxShadow(color: gold.withValues(alpha: 0.4), blurRadius: 20)],
              ),
              child: HugeIcon(icon: HugeIcons.strokeRoundedPlay, color: const Color(0xFF1A1200), size: big ? 30 : 16, strokeWidth: 2.2),
            ),
          ),
        ],
      ),
    );
  }

  Expanded rowText(String text1, String text2, bool price) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          price
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      text1,
                      style: const TextStyle(color: kPrimaryColor, fontSize: 20, fontFamily: gilroySemiBold),
                    ),
                    const Text(
                      ' TMT',
                      style: TextStyle(color: kPrimaryColor, fontSize: 13, height: 2, fontFamily: gilroySemiBold),
                    ),
                  ],
                )
              : Text(
                  text1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(color: kPrimaryColor, fontSize: 20, fontFamily: gilroySemiBold),
                ),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              text2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: const TextStyle(color: Colors.white, fontSize: 19, fontFamily: gilroyRegular),
            ),
          ),
        ],
      ),
    );
  }
}
