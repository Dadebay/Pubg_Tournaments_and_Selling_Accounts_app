import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';
import 'package:game_app/views/constants/constants.dart';

String tournamentFallbackAsset({required bool finished, required int id}) {
  if (finished) {
    return id.isEven ? 'assets/image/lobby_finished_trophy.webp' : 'assets/image/lobby_finished_battlefield.webp';
  }
  return id.isEven ? 'assets/image/lobby_active_plane.webp' : 'assets/image/lobby_active_dawn.webp';
}

String tournamentImageUrl(String? image) {
  final path = image?.trim() ?? '';
  if (path.isEmpty || path.toLowerCase() == 'null' || path.toLowerCase() == 'none') {
    return '';
  }
  if (Uri.tryParse(path)?.hasScheme ?? false) {
    return path;
  }
  return '$serverURL${path.startsWith('/') ? '' : '/'}$path';
}

class TournamentImage extends StatelessWidget {
  const TournamentImage({required this.imageUrl, required this.fallbackAsset, super.key});

  final String imageUrl;
  final String fallbackAsset;

  @override
  Widget build(BuildContext context) {
    Widget fallback() => Image.asset(fallbackAsset, fit: BoxFit.cover);

    if (imageUrl.isEmpty) {
      return fallback();
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      fadeInDuration: const Duration(milliseconds: 200),
      placeholder: (context, url) => fallback(),
      errorWidget: (context, url, error) => fallback(),
    );
  }
}
