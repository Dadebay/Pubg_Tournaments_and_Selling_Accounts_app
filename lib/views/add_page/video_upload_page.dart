// ignore_for_file: deprecated_member_use, file_names, depend_on_referenced_packages, avoid_void_async, always_declare_return_types, type_annotate_public_apis, unnecessary_statements, unrelated_type_equality_checks

import 'dart:io';

import 'package:async/async.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:game_app/connection_check.dart';
import 'package:game_app/controllers/settings_controller.dart';
import 'package:game_app/models/add_account_model.dart';
import 'package:game_app/models/user_models/auth_model.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
// import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';

import '../constants/index.dart';

class VideoUploadPage extends StatefulWidget {
  const VideoUploadPage({super.key});

  @override
  State<VideoUploadPage> createState() => _VideoUploadPageState();
}

class _VideoUploadPageState extends State<VideoUploadPage> {
  VideoPlayerController? _controller;
  Future<void>? _initializeVideoPlayerFuture;
  File? selectedVideo;

  Future pickVideo() async {
    try {
      if (a >= myNumber) {
        XFile? video = await ImagePicker().pickVideo(source: ImageSource.gallery, maxDuration: const Duration(seconds: 30));
        Get.find<SettingsController>().agreeButton.value = false;
        if (video == null) {
          return;
        }
        final imageTemporary = File(video.path);
        final bytes = imageTemporary.readAsBytesSync().lengthInBytes;
        final kb = bytes / 1024;
        final mb = kb / 1024;
        final VideoPlayerController testLengthController = VideoPlayerController.file(File(video.path)); //Your file here
        await testLengthController.initialize();
        if (testLengthController.value.duration.inSeconds > 60) {
          showSnackBar('noConnection3', 'video_upload_subtitle_error', Colors.red);
          video = null;
        } else {
          if (30.0 >= mb) {
            setState(() {
              selectedVideo = imageTemporary;
              _controller = VideoPlayerController.file(selectedVideo!);
              _controller!.pause();
              _initializeVideoPlayerFuture = _controller!.initialize();
              flickManager = FlickManager(videoPlayerController: VideoPlayerController.file(selectedVideo!));
            });
          } else {
            showSnackBar('noConnection3', 'video_size_error', Colors.amber);
            video = null;
          }
        }
      }
    } catch (error) {
      showSnackBar('noConnection3', '$error', Colors.red);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller!.dispose();
  }

  int a = 0;
  dynamic changeLimit() {
    AddAccountModel().getConsts().then((value) {
      a = value['video_limit'];
      setState(() {});
    });
  }

  FlickManager? flickManager;
  @override
  void initState() {
    super.initState();
    Get.find<SettingsController>().agreeButton.value = false;

    changeLimit();
  }

  int myNumber = 0;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: kPrimaryColorBlack,
        appBar: const MyAppBar(fontSize: 20, backArrow: false, iconRemove: false, name: 'videoUpload', elevationWhite: true),
        body: Container(
          color: kPrimaryColorBlack,
          width: Get.size.width,
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 5),
          child: ListView(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 5, bottom: 15),
                child: Column(
                  children: [
                    Text(
                      'video_upload_title'.tr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontFamily: gilroySemiBold, fontSize: 22),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'cannot_upload_video'.tr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey, fontFamily: gilroyRegular, fontSize: 16),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  '$myNumber/$a',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontFamily: gilroySemiBold, fontSize: 25),
                ),
              ),
              videoPlayer(),
              const SizedBox(height: 20),
              Center(
                child: AgreeButton(onTap: onTapp, name: 'agree'),
              ),
              SizedBox(
                width: Get.size.width,
                child: ElevatedButton(
                  onPressed: () async {
                    await Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const ConnectionCheck()), (Route<dynamic> route) => false);
                    await _controller!.pause();
                    flickManager!.dispose();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColorBlack,
                    elevation: 0.0,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: const RoundedRectangleBorder(borderRadius: borderRadius20),
                  ),
                  child: Text(
                    'pass'.tr,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: kPrimaryColor, fontFamily: gilroyMedium, fontSize: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  FutureBuilder<void> videoPlayer() {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && selectedVideo != null) {
          return GestureDetector(
            onTap: () {
              pickVideo();
            },
            child: SizedBox(
              height: 250,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: borderRadius15,
                      child: FlickVideoPlayer(
                        flickVideoWithControls: FlickVideoWithControls(
                          controls: FlickPortraitControls(progressBarSettings: FlickProgressBarSettings()),
                          videoFit: BoxFit.fitHeight,
                        ),
                        preferredDeviceOrientation: const [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp],
                        preferredDeviceOrientationFullscreen: const [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp],
                        flickManager: flickManager!,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      onPressed: () {
                        pickVideo();
                      },
                      icon: const Icon(CupertinoIcons.xmark_circle, color: Colors.white, size: 30),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return GestureDetector(
            onTap: () {
              pickVideo();
            },
            child: Container(
              height: 250,
              padding: const EdgeInsets.only(top: 10, bottom: 10, left: 10),
              child: DottedBorder(
                options: RoundedRectDottedBorderOptions(radius: const Radius.circular(12), padding: const EdgeInsets.all(6), strokeWidth: 2, color: kPrimaryColor),
                child: const Center(child: Icon(Icons.add, color: kPrimaryColor, size: 50)),
              ),
            ),
          );
        }
      },
    );
  }

  Future<void> onTapp() async {
    if (a >= myNumber) {
      if (Get.find<SettingsController>().agreeButton.value == false) {
        Get.find<SettingsController>().agreeButton.value = !Get.find<SettingsController>().agreeButton.value;

        final token = await Auth().getToken();
        final headers = {'Authorization': 'Bearer $token'};
        final request = http.MultipartRequest('POST', Uri.parse('$serverURL/api/accounts/upload-video/'));
        request.headers.addAll(headers);

        //Video Thumbnail Image
        // final thumbnailFile = await VideoCompress.getFileThumbnail(
        //   selectedVideo!.path,
        //   quality: 100, // default(100)
        //   position: -1, // default(-1)
        // );
        // final String fileName = thumbnailFile.path.split('/').last;
        // final stream = http.ByteStream(DelegatingStream.typed(thumbnailFile.openRead()));
        // final length = await thumbnailFile.length();
        // final mimeTypeData = lookupMimeType(thumbnailFile.path, headerBytes: [0xFF, 0xD8])!.split('/');
        // final multipartFileSign = http.MultipartFile('poster', stream, length, filename: fileName, contentType: MediaType(mimeTypeData.first, mimeTypeData[1]));
        // request.files.add(multipartFileSign);
        //Video Thumbnail Image

        final String fileName1 = selectedVideo!.path.split('/').last;
        final stream1 = http.ByteStream(DelegatingStream.typed(selectedVideo!.openRead()));
        final length1 = await selectedVideo!.length();
        final mimeTypeData1 = lookupMimeType(selectedVideo!.path, headerBytes: [0xFF, 0xD8])!.split('/');
        final multipartFileSign1 = http.MultipartFile('video', stream1, length1, filename: fileName1, contentType: MediaType(mimeTypeData1.first, mimeTypeData1[1]));
        request.files.add(multipartFileSign1);

        final http.StreamedResponse response = await request.send();
        if (response.statusCode == 200) {
          myNumber++;
          selectedVideo = null;
          await _controller!.pause();
          flickManager!.dispose();
          showSnackBar('done', 'done1', Colors.green);
          setState(() {});
        } else {
          showSnackBar('noConnection3', 'tournamentInfo14', Colors.red);
        }
        Get.find<SettingsController>().agreeButton.value = !Get.find<SettingsController>().agreeButton.value;
      } else {
        showSnackBar('videoUploading', 'videoUploading1', Colors.red);
      }
    } else {
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (BuildContext context) {
            return const ConnectionCheck();
          },
        ),
      );
      showSnackBar('allUploadMax', 'allUpload', Colors.red);
    }
  }
}
