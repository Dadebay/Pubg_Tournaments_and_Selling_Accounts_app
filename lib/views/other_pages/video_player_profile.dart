import 'package:flutter/material.dart';
import 'package:game_app/views/constants/index.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flick_video_player/flick_video_player.dart';

class VideoPlayerMine extends StatefulWidget {
  final String? videoURL;

  const VideoPlayerMine({super.key, this.videoURL});

  @override
  State<VideoPlayerMine> createState() => _VideoPlayerMineState();
}

class _VideoPlayerMineState extends State<VideoPlayerMine> {
  bool isLoading = true;
  String? errorMessage;
  double downloadProgress = 0.0;
  String downloadStatus = 'Initializing...';
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  FlickManager? flickManager;

  @override
  void initState() {
    super.initState();
    if (widget.videoURL == null || widget.videoURL!.isEmpty) {
      errorMessage = 'No video URL provided';
      isLoading = false;
    } else {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    if (Platform.isIOS) {
      // iOS: Download and play from local file
      await _downloadAndPlayVideo(widget.videoURL!);
    } else {
      // Android: Play directly from URL
      setState(() {
        downloadStatus = 'Loading video...';
      });
      _playFromURL(widget.videoURL!);
    }
  }

  void _playFromURL(String url) {
    try {
      _controller = VideoPlayerController.network(url);
      _initializeVideoPlayerFuture = _controller.initialize();

      flickManager = FlickManager(
        videoPlayerController: _controller
          ..setLooping(true)
          ..addListener(_videoListener),
      );

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error playing video: $e');
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _downloadAndPlayVideo(String url) async {
    try {
      debugPrint('Downloading video from: $url');
      setState(() {
        downloadStatus = 'Preparing download...';
        downloadProgress = 0.0;
      });

      final dir = await getTemporaryDirectory();
      final fileName = url.split('/').last;
      final filePath = '${dir.path}/$fileName';
      final file = File(filePath);

      // Check if file already exists
      if (await file.exists()) {
        debugPrint('Video already exists at $filePath');
        setState(() {
          downloadStatus = 'Loading cached video...';
          downloadProgress = 1.0;
        });
        await _initializeLocalVideo(file);
        return;
      }

      // Download with progress tracking
      final request = http.Request('GET', Uri.parse(url));
      final response = await request.send();

      if (response.statusCode == 200) {
        final contentLength = response.contentLength ?? 0;
        int downloadedBytes = 0;
        final List<int> bytes = [];

        setState(() {
          downloadStatus = 'Downloading video...';
        });

        await for (var chunk in response.stream) {
          bytes.addAll(chunk);
          downloadedBytes += chunk.length;

          if (contentLength > 0) {
            setState(() {
              downloadProgress = downloadedBytes / contentLength;
              downloadStatus = 'Downloading: ${(downloadProgress * 100).toStringAsFixed(0)}%';
            });
          }
        }

        // Write to file
        setState(() {
          downloadStatus = 'Saving video...';
        });
        await file.writeAsBytes(bytes);
        debugPrint('Video downloaded to $filePath');

        setState(() {
          downloadStatus = 'Initializing player...';
        });

        await _initializeLocalVideo(file);
      } else {
        throw Exception('Failed to download video. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error downloading video: $e');
      setState(() {
        errorMessage = 'Download failed: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<void> _initializeLocalVideo(File file) async {
    _controller = VideoPlayerController.file(file);
    _initializeVideoPlayerFuture = _controller.initialize();

    flickManager = FlickManager(
      videoPlayerController: _controller
        ..setLooping(true)
        ..addListener(_videoListener),
    );

    setState(() {
      isLoading = false;
      downloadProgress = 1.0;
    });
  }

  void _videoListener() {
    if (flickManager?.flickVideoManager?.videoPlayerController != null) {
      final controller = flickManager!.flickVideoManager!.videoPlayerController;
      if (controller!.value.hasError) {
        debugPrint('Video Player Error: ${controller.value.errorDescription}');
      }
    }
  }

  @override
  void dispose() {
    flickManager?.flickVideoManager?.videoPlayerController?.removeListener(_videoListener);
    flickManager?.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Circular Progress Indicator with Percentage
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: downloadProgress > 0 ? downloadProgress : null,
                      strokeWidth: 8,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(downloadProgress * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (Platform.isIOS)
                        const Text(
                          'iOS',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Status Text
              Text(
                downloadStatus,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              // Platform Info
              Text(
                Platform.isIOS ? 'Downloading for offline playback...' : 'Streaming video...',
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Error',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: const Text('Go Back'),
                ),
              ],
            ),
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
                          progressBarSettings: FlickProgressBarSettings(
                            playedColor: Colors.blue,
                            handleColor: Colors.blue,
                          ),
                        ),
                      ),
                      flickManager: flickManager!,
                    ),
                  ),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.blue,
                  ),
                );
              }
            },
          ),
          // Back Button
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  IconlyLight.arrowLeftCircle,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
          // Platform Indicator (Top Right)
          Positioned(
            top: 50,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Platform.isIOS ? Colors.blue : Colors.green,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Platform.isIOS ? Icons.apple : Icons.android,
                    color: Platform.isIOS ? Colors.blue : Colors.green,
                    size: 16,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    Platform.isIOS ? 'iOS (Cached)' : 'Android (Stream)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
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
