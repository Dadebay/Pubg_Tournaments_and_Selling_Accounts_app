import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';
import 'package:video_player/video_player.dart';

import '../../constants/constants.dart';

/// Full url of a file the server sends: a path on our server or an absolute url.
String mediaUrl(String? value) {
  final path = (value ?? '').trim();
  if (path.isEmpty || path == 'null') {
    return '';
  }
  final url = path.startsWith('http') ? path : '$serverURL${path.startsWith('/') ? '' : '/'}$path';
  return url.replaceAll('http://216.250.11.240', 'http://ucdayy.com.tm');
}

/// The picture shown for a video: its poster when there is one and it loads,
/// otherwise a frame taken from the video itself, so the area is never black.
class VideoPreview extends StatefulWidget {
  const VideoPreview({required this.poster, required this.video, super.key});

  final String? poster;
  final String? video;

  @override
  State<VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  VideoPlayerController? _controller;
  bool _frameReady = false;
  bool _started = false;

  /// Loads the video and stops on a frame a little after the start (the very first one is often black).
  Future<void> _loadFrame() async {
    if (_started) {
      return;
    }
    _started = true;
    final url = mediaUrl(widget.video);
    if (url.isEmpty) {
      return;
    }
    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    _controller = controller;
    try {
      await controller.initialize();
      await controller.setVolume(0);
      final at = controller.value.duration.inMilliseconds > 2000 ? const Duration(seconds: 1) : Duration.zero;
      await controller.seekTo(at);
      if (mounted) {
        setState(() => _frameReady = true);
      }
    } catch (_) {
      // The player screen reports a broken video; here the dark placeholder stays.
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Widget _placeholder() => Container(color: const Color(0xFF1B1B1E));

  Widget _frame() {
    final controller = _controller;
    if (!_frameReady || controller == null) {
      return _placeholder();
    }
    return FittedBox(
      fit: BoxFit.cover,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(width: controller.value.size.width, height: controller.value.size.height, child: VideoPlayer(controller)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final poster = mediaUrl(widget.poster);
    if (poster.isEmpty) {
      _loadFrame();
      return _frame();
    }
    return CachedNetworkImage(
      imageUrl: poster,
      fit: BoxFit.cover,
      fadeInCurve: Curves.ease,
      placeholder: (context, url) => _placeholder(),
      errorWidget: (context, url, error) {
        // A missing poster: take a frame from the video instead.
        WidgetsBinding.instance.addPostFrameCallback((_) => _loadFrame());
        return _frame();
      },
    );
  }
}
