import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:game_app/views/constants/constants.dart';

/// The picture of a player: the photo the API sends, or the logo of the app on a dark tile
/// when there is none or it does not load. Fills the space it is given; the caller clips it.
class PlayerPhoto extends StatelessWidget {
  const PlayerPhoto({required this.image, super.key});

  /// What the API sent: a path, a full address, empty or null.
  final String? image;

  @override
  Widget build(BuildContext context) {
    final url = apiImageUrl(image);
    if (url == null) {
      return const PlayerPhotoPlaceholder();
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      fadeInDuration: const Duration(milliseconds: 200),
      placeholder: (context, url) => const ColoredBox(color: Color(0xFF1B1B1E)),
      errorWidget: (context, url, error) => const PlayerPhotoPlaceholder(),
    );
  }
}

/// The logo of the app on a dark tile, for a player without a photo.
class PlayerPhotoPlaceholder extends StatelessWidget {
  const PlayerPhotoPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF1B1B1E),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Image.asset(
          'assets/image/logo.png',
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );
  }
}
