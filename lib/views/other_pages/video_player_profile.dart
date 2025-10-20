// ignore_for_file: file_names, deprecated_member_use

import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
// ignore: depend_on_referenced_packages
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class VideoPlayerMine extends StatefulWidget {
  final String? videoURL;

  const VideoPlayerMine({super.key, this.videoURL});

  @override
  State<VideoPlayerMine> createState() => _VideoPlayerMineState();
}

class _VideoPlayerMineState extends State<VideoPlayerMine> {
  // FlickManager? flickManager;
  bool isLoading = true;
  String? errorMessage;
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  late FlickManager flickManager;

  @override
  void initState() {
    super.initState();
    if (widget.videoURL == null || widget.videoURL!.isEmpty) {
      errorMessage = 'No video URL provided';
      isLoading = false;
    } else {
      _downloadAndPlayVideo(widget.videoURL!);
    }
    _controller = VideoPlayerController.network(
      widget.videoURL!,
    );
    _initializeVideoPlayerFuture = _controller.initialize();
  }

  Future<void> _downloadAndPlayVideo(String url) async {
    try {
      debugPrint('Downloading video from: $url');

      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/${url.split('/').last}';
      final file = File(filePath);

      if (!await file.exists()) {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          await file.writeAsBytes(response.bodyBytes);
          debugPrint('Video downloaded to $filePath');
        } else {
          throw Exception('Failed to download video. Status code: ${response.statusCode}');
        }
      } else {
        debugPrint('Video already exists at $filePath');
      }

      flickManager = FlickManager(
        videoPlayerController: VideoPlayerController.file(file)
          ..setLooping(true)
          ..addListener(_videoListener),
      );

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error downloading video: $e');
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void _videoListener() {
    final controller = flickManager.flickVideoManager!.videoPlayerController;
    if (controller!.value.hasError) {
      debugPrint('Video Player Error: ${controller.value.errorDescription}');
    }
    debugPrint(
      'Video Player State: isPlaying=${controller.value.isPlaying}, position=${controller.value.position}',
    );
  }

  @override
  void dispose() {
    flickManager.flickVideoManager!.videoPlayerController?.removeListener(_videoListener);
    flickManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            errorMessage!,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          FutureBuilder(
            future: _initializeVideoPlayerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Center(
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: FlickVideoPlayer(
                      flickVideoWithControls: FlickVideoWithControls(
                        controls: FlickPortraitControls(
                          progressBarSettings: FlickProgressBarSettings(),
                        ),
                      ),
                      flickManager: flickManager,
                    ),
                  ),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: const Icon(
                IconlyLight.arrowLeftCircle,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
