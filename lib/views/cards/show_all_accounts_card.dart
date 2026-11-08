// ignore_for_file: file_names

import 'package:cached_network_image/cached_network_image.dart';
import 'package:game_app/models/get_posts_model.dart';
import 'package:game_app/views/other_pages/account_profil_page/account_profil_page.dart';
import 'package:game_app/views/other_pages/account_profil_page/video_preview.dart';
import 'package:hugeicons/hugeicons.dart';

import '../constants/index.dart';

const _gold = Color(0xFFFFC83D);
const _goldDark = Color(0xFFFF9800);

/// An account in the "Satlyk akkauntlar" grid: a dark card with a gold frame. The
/// picture is the account's image; without one the first video is shown as a preview
/// with a play button (the videos are fetched when the list did not bring them).
class ShowAllProductsCard extends StatefulWidget {
  final GetPostsAccountModel model;
  final bool fav;
  const ShowAllProductsCard({required this.fav, required this.model, super.key});

  @override
  State<ShowAllProductsCard> createState() => _ShowAllProductsCardState();
}

class _ShowAllProductsCardState extends State<ShowAllProductsCard> {
  GetAccountVideos? _video;
  bool _imageFailed = false;

  bool get _hasImage => mediaUrl(widget.model.image).isNotEmpty && !_imageFailed;

  @override
  void initState() {
    super.initState();
    _video = _firstVideo(widget.model.videos);
    if (mediaUrl(widget.model.image).isEmpty && _video == null) {
      _loadVideo();
    }
  }

  GetAccountVideos? _firstVideo(List<GetAccountVideos>? videos) {
    for (final video in videos ?? const <GetAccountVideos>[]) {
      if (mediaUrl(video.video).isNotEmpty) {
        return video;
      }
    }
    return null;
  }

  Future<void> _loadVideo() async {
    final id = widget.model.id;
    if (id == null) {
      return;
    }
    try {
      final videos = await GetAccountVideos().getVideosById(id);
      if (mounted) {
        setState(() => _video = _firstVideo(videos));
      }
    } catch (_) {}
  }

  String get _price {
    final value = double.tryParse('${widget.model.price}');
    if (value == null) {
      return '${widget.model.price}';
    }
    return value == value.roundToDouble() ? '${value.toInt()}' : value.toStringAsFixed(1);
  }

  String get _date {
    final value = widget.model.createdAt ?? '';
    return value.length >= 10 ? value.substring(0, 10) : value;
  }

  @override
  Widget build(BuildContext context) {
    final model = widget.model;
    final vip = model.vip == true;
    return GestureDetector(
      onTap: () => Get.to(() => AccountProfilPage(userID: model.id!)),
      child: Container(
        padding: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _gold.withValues(alpha: vip ? 1 : 0.55),
              _goldDark.withValues(alpha: vip ? 0.85 : 0.3),
              _gold.withValues(alpha: vip ? 1 : 0.55),
            ],
          ),
          boxShadow: [BoxShadow(color: _gold.withValues(alpha: vip ? 0.26 : 0.1), blurRadius: 16)],
        ),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22.5),
            gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF232327), Color(0xFF111113)]),
          ),
          child: Column(
            children: [
              Expanded(child: _media(vip)),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 10, 4, 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${model.title}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 17, height: 1.1),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const HugeIcon(icon: HugeIcons.strokeRoundedCalendar03, color: _gold, size: 14, strokeWidth: 1.9),
                        const SizedBox(width: 6),
                        Text(
                          _date,
                          style: const TextStyle(color: Color(0xFF9A9AA3), fontFamily: gilroyMedium, fontSize: 12.5),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Image.asset(
                          'assets/image/coin_stack.webp',
                          height: 24,
                          errorBuilder: (context, error, stackTrace) => const HugeIcon(icon: HugeIcons.strokeRoundedCoins01, color: _gold, size: 22, strokeWidth: 1.8),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text.rich(
                              TextSpan(
                                text: _price,
                                style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 22, height: 1),
                                children: const [
                                  TextSpan(
                                    text: ' TMT',
                                    style: TextStyle(color: _gold, fontFamily: gilroyBold, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The account's picture, or a video preview, or a calm placeholder; with a VIP crown when needed.
  Widget _media(bool vip) {
    final video = _video;
    final Widget content;
    if (_hasImage) {
      content = CachedNetworkImage(
        imageUrl: mediaUrl(widget.model.image),
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        fadeInCurve: Curves.ease,
        placeholder: (context, url) => Container(color: Colors.white.withValues(alpha: 0.05)),
        errorWidget: (context, url, error) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_imageFailed) {
              setState(() => _imageFailed = true);
              if (_video == null) {
                _loadVideo();
              }
            }
          });
          return Container(color: Colors.white.withValues(alpha: 0.05));
        },
      );
    } else if (video != null) {
      content = Stack(
        fit: StackFit.expand,
        children: [
          VideoPreview(poster: video.poster, video: video.video),
          Container(color: Colors.black.withValues(alpha: 0.25)),
          Center(
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _gold,
                boxShadow: [BoxShadow(color: _gold.withValues(alpha: 0.4), blurRadius: 14)],
              ),
              child: const HugeIcon(icon: HugeIcons.strokeRoundedPlay, color: Color(0xFF1A1200), size: 20, strokeWidth: 2.2),
            ),
          ),
        ],
      );
    } else {
      content = Container(
        color: const Color(0xFF1B1B1E),
        alignment: Alignment.center,
        child: HugeIcon(icon: HugeIcons.strokeRoundedImage02, color: Colors.white.withValues(alpha: 0.25), size: 38, strokeWidth: 1.6),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(17),
      child: Stack(
        fit: StackFit.expand,
        children: [
          content,
          if (vip)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(11),
                  color: Colors.black.withValues(alpha: 0.65),
                  border: Border.all(color: _gold.withValues(alpha: 0.8)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    HugeIcon(icon: HugeIcons.strokeRoundedCrown, color: _gold, size: 13, strokeWidth: 2),
                    SizedBox(width: 4),
                    Text(
                      'VIP',
                      style: TextStyle(color: _gold, fontFamily: gilroyBold, fontSize: 11.5, height: 1.1),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
