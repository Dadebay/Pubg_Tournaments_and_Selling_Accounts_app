import 'package:flutter/material.dart';
import 'package:game_app/views/constants/index.dart';
import 'package:video_player/video_player.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
// ignore: depend_on_referenced_packages
import 'package:video_player/video_player.dart';

class VideoPLayerMine extends StatefulWidget {
  final String? videoURL;
  const VideoPLayerMine({super.key, this.videoURL});

  @override
  State<VideoPLayerMine> createState() => _VideoPLayerMineState();
}

class _VideoPLayerMineState extends State<VideoPLayerMine> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  late FlickManager flickManager;

  String _convertVideoUrl(String originalUrl) {
    // Replace the domain from 216.250.11.240 to ucdayy.com.tm
    return originalUrl.replaceAll(
      'http://216.250.11.240',
      'http://ucdayy.com.tm',
    );
  }

  @override
  void initState() {
    super.initState();

   
    final convertedUrl = _convertVideoUrl(widget.videoURL!);
    debugPrint('Original URL: ${widget.videoURL}');
    debugPrint('Converted URL: $convertedUrl');

    flickManager = FlickManager(
      videoPlayerController: VideoPlayerController.network(convertedUrl),
    );
    _controller = VideoPlayerController.network(
      convertedUrl,
    );
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(true);
  }

  @override
  void dispose() {
    super.dispose();
    flickManager.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              onTap: () {
                Navigator.of(context).pop();
              },
              child: const Icon(IconlyLight.arrowLeftCircle, color: Colors.white, size: 30),
            ),
          ),
        ],
      ),
    );
  }
}
