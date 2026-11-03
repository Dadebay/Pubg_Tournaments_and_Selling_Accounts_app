// ignore_for_file: file_names, deprecated_member_use, prefer_typing_uninitialized_variables, depend_on_referenced_packages

import 'dart:io';

import 'package:async/async.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:game_app/controllers/settings_controller.dart';
import 'package:game_app/models/user_models/abous_us_model.dart';
import 'package:game_app/models/user_models/user_sign_in_model.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vibration/vibration.dart';
import '../../../models/user_models/auth_model.dart';
import '../../constants/index.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({required this.image, required this.medata, super.key});
  final String image;
  final GetMeModel medata;
  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  TextEditingController pubgNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController pubgIDController = TextEditingController();

  File? selectedImage;

  dynamic changeData(String name, String phone, String pubgID) {
    pubgNameController.text = name;
    phoneController.text = phone;
    pubgIDController.text = pubgID;
  }

  @override
  void initState() {
    super.initState();
    Get.find<SettingsController>().agreeButton.value = false;
    getData();
  }

  dynamic getData() async {
    int a = 0;
    
    GetMeModel().getMe();
    await AboutUsModel().getAboutUs().then((value) {
      print(value);
      for (var element in value) {
        if (element.pageShow == true) {
          a++;
        }
      }
    });
    if (a == 3) {}
    setState(() {});
  }

  // Compress image before uploading
  Future<File?> compressImage(File file) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_compressed.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 70, // Adjust quality (0-100), lower = smaller size
        minWidth: 1024, // Max width
        minHeight: 1024, // Max height
        format: CompressFormat.jpeg,
      );

      if (result != null) {
        return File(result.path);
      }
      return null;
    } catch (e) {
      print('Compression error: $e');
      return file; // Return original if compression fails
    }
  }

  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );
      if (image == null) {
        return;
      }

      final imageTemporary = File(image.path);

      // Compress the image
      final compressedImage = await compressImage(imageTemporary);

      setState(() {
        selectedImage = compressedImage ?? imageTemporary;
      });

      onTapp();
    } catch (error) {
      showSnackBar('noConnection3', '$error', Colors.red);
    }
  }

  dynamic onTapp() async {
  if (selectedImage == null) {
    showSnackBar('noImage', 'noImageBanner', Colors.red);
    await Vibration.vibrate();
  } else {
    final settingsController = Get.find<SettingsController>();
    settingsController.agreeButton.value = !settingsController.agreeButton.value;

    final token = await Auth().getToken();
    final headers = {'Authorization': 'Bearer $token'};

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$serverURL/api/accounts/short-update/'),
    );

    request.fields.addAll({
      'pubg_username': pubgNameController.text,
      'pubg_id': pubgIDController.text,
    });

    request.headers.addAll(headers);

    final String fileName = selectedImage!.path.split('/').last;
    final stream = http.ByteStream(DelegatingStream.typed(selectedImage!.openRead()));
    final length = await selectedImage!.length();
    final mimeTypeData = lookupMimeType(
      selectedImage!.path,
      headerBytes: [0xFF, 0xD8],
    )!.split('/');

    // ✅ Send same file twice, under two different field names
    final multipartFileBg = http.MultipartFile(
      'bg_image',
      stream,
      length,
      filename: fileName,
      contentType: MediaType(mimeTypeData.first, mimeTypeData[1]),
    );

    // Create a new stream for the second upload (cannot reuse the same one)
    final secondStream = http.ByteStream(DelegatingStream.typed(selectedImage!.openRead()));
    final multipartFileImage = http.MultipartFile(
      'image',
      secondStream,
      length,
      filename: fileName,
      contentType: MediaType(mimeTypeData.first, mimeTypeData[1]),
    );

    request.files.addAll([multipartFileBg, multipartFileImage]);

    final http.StreamedResponse response = await request.send();
    settingsController.agreeButton.value = false;

    if (response.statusCode == 200) {
        setState(() {
           getData();
        });
      showSnackBar('copySucces', 'changedData', Colors.green);
      getData();
      pubgNameController.clear();
      pubgIDController.clear();
    } else {
      showSnackBar('noConnection3', 'tournamentInfo14', Colors.red);
    }
  }
}


  static const _gold = Color(0xFFFFC83D);

  bool get _hasNetworkImage => widget.image.isNotEmpty && widget.image != 'null';

  String get _networkImageUrl => widget.image.startsWith('http') ? widget.image : '$serverURL${widget.image}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColorBlack,
      appBar: const MyAppBar(backArrow: true, fontSize: 0.0, iconRemove: true, elevationWhite: true, name: 'profil', dividerOpacity: 0.4),
      body: FutureBuilder<GetMeModel>(
        future: GetMeModel().getMe(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: spinKit());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error'));
          } else if (snapshot.data == null) {
            return const Center(child: Text('Empty'));
          }
          changeData(snapshot.data!.nickname!, snapshot.data!.phone!, snapshot.data!.pubgId!);
          final teams = widget.medata.teams ?? [];
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: _avatar()),
                const SizedBox(height: 28),
                _card(
                  children: [
                    _infoRow(HugeIcons.strokeRoundedUser, 'signIn1', pubgNameController.text),
                    _infoRow(HugeIcons.strokeRoundedIdentityCard, 'signIn2', pubgIDController.text),
                    _infoRow(HugeIcons.strokeRoundedCall, 'userPhoneNumber', phoneController.text),
                  ],
                ),
                if (teams.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Padding(
                    padding: EdgeInsets.only(left: 6, bottom: 12),
                    child: Text('Teams', style: TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 18)),
                  ),
                  for (var i = 0; i < teams.length; i++) _teamCard(teams[i], i),
                ],
                const SizedBox(height: 28),
                Center(
                  child: _saveButton(
                    name: 'agree',
                    onTap: () {
                      if (selectedImage != null) {
                        onTapp();
                        Get.find<SettingsController>().agreeButton.value = !Get.find<SettingsController>().agreeButton.value;
                      } else {
                        Get.find<SettingsController>().agreeButton.value = !Get.find<SettingsController>().agreeButton.value;
                        GetMeModel().shortUpdate(pubgUserId: pubgIDController.text, pubgUserName: pubgNameController.text).then((value) {
                          if (value == 200) {
                            getData();
                            Get.back();

                            showSnackBar('copySucces', 'changedData', Colors.green);
                            pubgNameController.clear();
                            pubgIDController.clear();
                          } else {
                            showSnackBar('noConnection3', 'tournamentInfo14', Colors.red);
                          }
                          Get.find<SettingsController>().agreeButton.value = !Get.find<SettingsController>().agreeButton.value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Gold save button; shrinks to a spinner while the request runs.
  Widget _saveButton({required String name, required VoidCallback onTap}) {
    final controller = Get.find<SettingsController>();
    return Obx(() {
      final busy = controller.agreeButton.value;
      return GestureDetector(
        onTap: busy ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          height: 54,
          width: busy ? 54 : double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(busy ? 27 : 18),
            color: Colors.black,
            border: Border.all(color: _gold.withValues(alpha: 0.5)),
          ),
          child: busy
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: _gold))
              : Text(name.tr, style: const TextStyle(color: _gold, fontFamily: gilroyBold, fontSize: 18)),
        ),
      );
    });
  }

  /// Round photo with a camera badge; tapping it opens the gallery.
  Widget _avatar() {
    final Widget photo;
    if (selectedImage != null) {
      photo = Image.file(selectedImage!, fit: BoxFit.cover);
    } else if (_hasNetworkImage) {
      photo = CachedNetworkImage(
        fadeInCurve: Curves.ease,
        imageUrl: _networkImageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Center(child: spinKit()),
        errorWidget: (context, url, error) => _avatarPlaceholder(),
      );
    } else {
      photo = _avatarPlaceholder();
    }
    return GestureDetector(
      onTap: () async {
        if (!_hasNetworkImage && selectedImage == null) {
          await Permission.camera.request();
          await Permission.photos.request();
        }
        await pickImage();
      },
      child: SizedBox(
        width: 136,
        height: 136,
        child: Stack(
          children: [
            Container(
              width: 136,
              height: 136,
              padding: const EdgeInsets.all(1.2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFFFD866), Color(0xFFFF9800)]),
                
              ),
              child: ClipOval(child: SizedBox.expand(child: photo)),
            ),
            Positioned(
              right: 2,
              bottom: 2,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _gold,
                  border: Border.all(color: kPrimaryColorBlack, width: 3),
                ),
                child: const Center(child: HugeIcon(icon: HugeIcons.strokeRoundedCamera01, color: Color(0xFF1A1200), size: 20)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatarPlaceholder() {
    return const ColoredBox(
      color: Color(0xFF2C2C31),
      child: Center(child: HugeIcon(icon: HugeIcons.strokeRoundedUser, color: _gold, size: 54)),
    );
  }

  BoxDecoration get _cardDecoration => BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF232327), Color(0xFF151517)]),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      );

  Widget _card({required List<Widget> children}) {
    return Container(
      decoration: _cardDecoration,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) Divider(height: 1, indent: 70, color: Colors.white.withValues(alpha: 0.07)),
            children[i],
          ],
        ],
      ),
    );
  }

  Widget _infoRow(List<List<dynamic>> icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: _gold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(13)),
            child: Center(child: HugeIcon(icon: icon, color: _gold, size: 22)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label.tr, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontFamily: gilroyMedium, fontSize: 12)),
                const SizedBox(height: 3),
                Text(value.isEmpty || value == 'null' ? '—' : value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 16)),
              ],
            ),
          ),
          HugeIcon(icon: HugeIcons.strokeRoundedSquareLock01, size: 18, color: Colors.white.withValues(alpha: 0.25)),
        ],
      ),
    );
  }

  Widget _teamCard(dynamic team, int index) {
    final teamName = team.name ?? 'Team ${team.id}';
    final users = [team.account, team.user1, team.user2, team.user3].where((u) => u != null && u.isNotEmpty).toList();
    final stage = team.quartturnir?.name;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: _gold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
            child: Text('${index + 1}', style: const TextStyle(color: _gold, fontFamily: gilroyBold, fontSize: 15)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$teamName', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(users.join(', '), style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontFamily: gilroyMedium, fontSize: 12)),
              ],
            ),
          ),
          if (stage != null && '$stage'.isNotEmpty) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: const Color(0xFF3DA5FF).withValues(alpha: 0.18), borderRadius: BorderRadius.circular(12)),
              child: Text('$stage', style: const TextStyle(color: Color(0xFF3DA5FF), fontFamily: gilroyMedium, fontSize: 12)),
            ),
          ],
        ],
      ),
    );
  }
}
