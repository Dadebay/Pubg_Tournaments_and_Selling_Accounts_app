// ignore_for_file: file_names, prefer_typing_uninitialized_variables, deprecated_member_use, depend_on_referenced_packages

import 'dart:io';

import 'package:async/async.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:game_app/controllers/settings_controller.dart';
import 'package:game_app/models/home_page_model.dart';
import 'package:game_app/models/user_models/auth_model.dart';
import 'package:game_app/models/user_models/user_sign_in_model.dart';
import 'package:game_app/views/add_page/video_upload_page.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../constants/index.dart';

class EditWorkProfile extends StatefulWidget {
  final GetMeModel model;

  const EditWorkProfile({required this.model, super.key});

  @override
  State<EditWorkProfile> createState() => _EditWorkProfileState();
}

class _EditWorkProfileState extends State<EditWorkProfile> {
  TextEditingController bioController = TextEditingController();
  FocusNode bioFocusNode = FocusNode();
  FocusNode firstNameFocusNode = FocusNode();
  TextEditingController fisrtNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  FocusNode lastNameFocusNode = FocusNode();
  int locationID = -1;
  String locationName = '';
  TextEditingController priceController = TextEditingController();
  FocusNode priceFocusNode = FocusNode();
  int pubgID = -1;
  TextEditingController pubgIDController = TextEditingController();
  FocusNode pubgIDFocusNode = FocusNode();
  String pubgName = '';
  File? selectedImage;
  File? selectedImage1;
  TextEditingController userNameController = TextEditingController();
  FocusNode userNameFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    changeData();
    Get.find<SettingsController>().agreeButton.value = false;
  }

  dynamic changeData() async {
    userNameController.text = widget.model.firstName.toString();
    pubgIDController.text = widget.model.pubgId.toString();
    fisrtNameController.text = widget.model.firstName.toString();
    lastNameController.text = widget.model.lastName.toString();
    priceController.text = widget.model.price.toString();
    bioController.text = widget.model.bio.toString();
    await Cities().getCities().then((value) {
      for (var element in value) {
        if (widget.model.location == element.id) {
          locationName = Get.locale?.languageCode == 'tr' ? element.name_tm.toString() : element.name_ru.toString();
          setState(() {});
        }
      }
    });
  }

  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) {
        return;
      }
      final imageTemporary = File(image.path);
      setState(() {
        selectedImage = imageTemporary;
      });
    } catch (error) {
      showSnackBar('noConnection3', '$error', Colors.red);
    }
  }

  Future pickImage1() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) {
        return;
      }
      final imageTemporary = File(image.path);
      setState(() {
        selectedImage1 = imageTemporary;
      });
    } catch (error) {
      showSnackBar('noConnection3', '$error', Colors.red);
    }
  }

  Padding selectCity() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15),
        shape: const RoundedRectangleBorder(borderRadius: borderRadius20, side: BorderSide(color: Colors.white, width: 2)),
        title: Text(locationName, style: const TextStyle(color: Colors.white, fontFamily: josefinSansSemiBold, fontSize: 18)),
        trailing: const Icon(IconlyLight.arrowRightCircle),
        onTap: () {
          Get.defaultDialog(
            title: 'selectCityTitle'.tr,
            titleStyle: const TextStyle(color: Colors.white, fontFamily: josefinSansSemiBold),
            radius: 5,
            backgroundColor: kPrimaryColorBlack,
            titlePadding: const EdgeInsets.symmetric(vertical: 20),
            content: FutureBuilder<List<Cities>>(
              future: Cities().getCities(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: spinKit());
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text('Error'),
                  );
                } else if (snapshot.data == null) {
                  return const Center(
                    child: Text('Null'),
                  );
                }
                return Column(
                  children: List.generate(
                    snapshot.data!.length,
                    (index) => Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      alignment: WrapAlignment.center,
                      children: [
                        customDivider(),
                        TextButton(
                          onPressed: () {
                            locationName = Get.locale?.languageCode == 'tr' ? snapshot.data![index].name_tm.toString() : snapshot.data![index].name_ru.toString();
                            locationID = snapshot.data![index].id!;
                            Get.back();

                            setState(() {});
                          },
                          child: Text(
                            Get.locale?.languageCode == 'tr' ? snapshot.data![index].name_tm.toString() : snapshot.data![index].name_ru.toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontFamily: josefinSansSemiBold, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // Padding selectPubgType() {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 14),
  //     child: ListTile(
  //       contentPadding: const EdgeInsets.symmetric(horizontal: 15),
  //       shape: const RoundedRectangleBorder(borderRadius: borderRadius20, side: BorderSide(color: Colors.white, width: 2)),
  //       title: Text(pubgName, style: const TextStyle(color: Colors.white, fontFamily: josefinSansSemiBold, fontSize: 18)),
  //       trailing: const Icon(IconlyLight.arrowRightCircle),
  //       onTap: () {
  //         Get.defaultDialog(
  //           title: 'pubgTypes'.tr,
  //           titleStyle: const TextStyle(color: Colors.white, fontFamily: josefinSansSemiBold),
  //           radius: 5,
  //           backgroundColor: kPrimaryColorBlack,
  //           titlePadding: const EdgeInsets.symmetric(vertical: 20),
  //           content: FutureBuilder<List<PubgTypesModel>>(
  //             future: PubgTypesModel().getTypes(),
  //             builder: (context, snapshot) {
  //               if (snapshot.connectionState == ConnectionState.waiting) {
  //                 return Center(child: spinKit());
  //               } else if (snapshot.hasError) {
  //                 return const Center(
  //                   child: Text('Error'),
  //                 );
  //               } else if (snapshot.data == null) {
  //                 return const Center(
  //                   child: Text('Null'),
  //                 );
  //               }
  //               return Column(
  //                 children: List.generate(
  //                   snapshot.data!.length,
  //                   (index) => Wrap(
  //                     crossAxisAlignment: WrapCrossAlignment.center,
  //                     alignment: WrapAlignment.center,
  //                     children: [
  //                       customDivider(),
  //                       TextButton(
  //                         onPressed: () {
  //                           pubgName = snapshot.data![index].title.toString();
  //                           pubgID = snapshot.data![index].id!;
  //                           Get.back();
  //                           setState(() {});
  //                         },
  //                         child: Text(
  //                           snapshot.data![index].title.toString(),
  //                           textAlign: TextAlign.center,
  //                           style: const TextStyle(color: Colors.white, fontFamily: josefinSansSemiBold, fontSize: 16),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               );
  //             },
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }

  dynamic selectImageDesign() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 30, left: 20),
          child: Text(
            'select_user_image'.tr,
            style: const TextStyle(color: Colors.white, fontFamily: josefinSansSemiBold, fontSize: 22),
          ),
        ),
        if (widget.model.image != null && selectedImage == null)
          GestureDetector(
            onTap: () {
              pickImage();
            },
            child: Container(
              width: 120,
              height: 120,
              margin: const EdgeInsets.only(top: 25),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.white30, blurRadius: 15.0, offset: Offset(1.0, 1.0), spreadRadius: 5.0)],
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  fadeInCurve: Curves.ease,
                  imageUrl: '$serverURL${widget.model.image}',
                  imageBuilder: (context, imageProvider) => Container(
                    width: Get.size.width,
                    decoration: BoxDecoration(
                      borderRadius: borderRadius20,
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  placeholder: (context, url) => Center(child: spinKit()),
                  errorWidget: (context, url, error) => const Text('No Image'),
                ),
              ),
            ),
          )
        else
          selectedImage != null
              ? GestureDetector(
                  onTap: () {
                    pickImage();
                  },
                  child: Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      margin: const EdgeInsets.only(top: 25),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.white30, blurRadius: 15.0, offset: Offset(1.0, 1.0), spreadRadius: 5.0)],
                      ),
                      child: ClipOval(child: Material(elevation: 3, child: Image.file(selectedImage!, fit: BoxFit.cover))),
                    ),
                  ),
                )
              : GestureDetector(
                  onTap: () async {
                    await Permission.camera.request();
                    await Permission.photos.request();
                    await pickImage();
                  },
                  child: Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      margin: const EdgeInsets.only(top: 25),
                      child: DottedBorder(
                        borderType: BorderType.Oval,
                        radius: const Radius.circular(12),
                        padding: const EdgeInsets.all(6),
                        strokeWidth: 2,
                        color: kPrimaryColor,
                        child: const Center(
                          child: Icon(
                            Icons.add_circle_outline_sharp,
                            color: kPrimaryColor,
                            size: 35,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
      ],
    );
  }

  dynamic selectBackImage() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 40, left: 20, bottom: 20),
          child: Text(
            'select_user_bg_image'.tr,
            style: const TextStyle(color: Colors.white, fontFamily: josefinSansSemiBold, fontSize: 22),
          ),
        ),
        if (selectedImage1 == null)
          GestureDetector(
            onTap: () {
              pickImage();
            },
            child: Container(
              margin: const EdgeInsets.only(left: 20, bottom: 20, right: 20, top: 10),
              height: 170,
              width: double.infinity,
              decoration: const BoxDecoration(
                boxShadow: [BoxShadow(color: Colors.white30, blurRadius: 15.0, offset: Offset(1.0, 1.0), spreadRadius: 5.0)],
              ),
              child: Material(
                elevation: 2,
                borderRadius: borderRadius15,
                child: ClipRRect(
                  borderRadius: borderRadius15,
                  child: CachedNetworkImage(
                    fadeInCurve: Curves.ease,
                    imageUrl: '$serverURL${widget.model.bgImage}',
                    imageBuilder: (context, imageProvider) => Container(
                      width: Get.size.width,
                      decoration: BoxDecoration(
                        borderRadius: borderRadius20,
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    placeholder: (context, url) => Center(child: spinKit()),
                    errorWidget: (context, url, error) => const Text('No Image'),
                  ),
                ),
              ),
            ),
          )
        else
          selectedImage1 != null
              ? GestureDetector(
                  onTap: () {
                    pickImage1();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(left: 20, bottom: 20, right: 20, top: 10),
                    height: 170,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      boxShadow: [BoxShadow(color: Colors.white30, blurRadius: 15.0, offset: Offset(1.0, 1.0), spreadRadius: 5.0)],
                    ),
                    child: Material(
                      elevation: 2,
                      borderRadius: borderRadius15,
                      child: ClipRRect(
                        borderRadius: borderRadius15,
                        child: Image.file(selectedImage1!, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                )
              : GestureDetector(
                  onTap: () async {
                    await pickImage1();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(left: 10, bottom: 25, right: 10, top: 10),
                    height: 150,
                    width: double.infinity,
                    child: DottedBorder(
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(12),
                      padding: const EdgeInsets.all(6),
                      strokeWidth: 2,
                      color: kPrimaryColor,
                      child: const Center(
                        child: Icon(
                          Icons.add,
                          color: kPrimaryColor,
                          size: 50,
                        ),
                      ),
                    ),
                  ),
                ),
      ],
    );
  }

  Padding textpart(String name) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 25),
      child: Text(
        name.tr,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: const TextStyle(fontSize: 18, fontFamily: josefinSansMedium),
      ),
    );
  }

  dynamic onTapp() async {
    Get.find<SettingsController>().agreeButton.value = !Get.find<SettingsController>().agreeButton.value;
    final token = await Auth().getToken();
    final headers = {'Authorization': 'Bearer $token'};
    final request = http.MultipartRequest('POST', Uri.parse('$serverURL/api/accounts/update-account/'));
    request.fields.addAll({
      'pubg_username': userNameController.text.toString(),
      'pubg_id': pubgIDController.text.toString(),
      'first_name': fisrtNameController.text.toString(),
      'last_name': lastNameController.text.toString(),
      'email': '',
      'bio': bioController.text.toString(),
      'location': '${locationID == -1 ? widget.model.location : locationID}',
      'pubg_type': '${pubgID == -1 ? int.parse(widget.model.pubgId!) : pubgID}',
      'for_sale': '1',
      'vip': '${widget.model.vip == true ? 1 : 0}',
      'edit': '1',
      'price': priceController.text,
    });

    request.headers.addAll(headers);
    if (selectedImage != null) {
      final String fileName = selectedImage!.path.split('/').last;
      final stream = http.ByteStream(DelegatingStream.typed(selectedImage!.openRead()));
      final length = await selectedImage!.length();
      final mimeTypeData = lookupMimeType(selectedImage!.path, headerBytes: [0xFF, 0xD8])!.split('/');
      final multipartFileSign = http.MultipartFile('image', stream, length, filename: fileName, contentType: MediaType(mimeTypeData.first, mimeTypeData[1]));
      request.files.add(multipartFileSign);
    } else {
      request.fields.addAll({'image': '${widget.model.image}'});
    }
    if (selectedImage1 != null) {
      final String fileName1 = selectedImage1!.path.split('/').last;
      final stream1 = http.ByteStream(DelegatingStream.typed(selectedImage1!.openRead()));
      final length1 = await selectedImage1!.length();
      final mimeTypeData1 = lookupMimeType(selectedImage1!.path, headerBytes: [0xFF, 0xD8])!.split('/');
      final multipartFileSign1 = http.MultipartFile('bg_image', stream1, length1, filename: fileName1, contentType: MediaType(mimeTypeData1.first, mimeTypeData1[1]));
      request.files.add(multipartFileSign1);
    } else {
      request.fields.addAll({'bg_image': '${widget.model.bgImage}'});
    }
    final http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      Get.back();
      showSnackBar('agree', 'changedData', Colors.green);
      Get.find<SettingsController>().agreeButton.value = !Get.find<SettingsController>().agreeButton.value;
    } else {
      showSnackBar('noConnection3', 'tournamentInfo14', Colors.red);
      Get.find<SettingsController>().agreeButton.value = !Get.find<SettingsController>().agreeButton.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColorBlack,
      appBar: const MyAppBar(backArrow: true, fontSize: 0.0, iconRemove: true, elevationWhite: true, name: 'profil'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              CustomTextField(labelName: 'signIn1', controller: userNameController, focusNode: userNameFocusNode, requestfocusNode: pubgIDFocusNode, isNumber: false, borderRadius: true),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: CustomTextField(labelName: 'signIn2', controller: pubgIDController, focusNode: pubgIDFocusNode, requestfocusNode: firstNameFocusNode, isNumber: false, borderRadius: true),
              ),
              CustomTextField(labelName: 'enterUserName', controller: fisrtNameController, focusNode: firstNameFocusNode, requestfocusNode: lastNameFocusNode, isNumber: false, borderRadius: true),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: CustomTextField(labelName: 'enterSurname', controller: lastNameController, focusNode: lastNameFocusNode, requestfocusNode: priceFocusNode, isNumber: false, borderRadius: true),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: CustomTextField(labelName: 'accountPrice', controller: priceController, focusNode: priceFocusNode, requestfocusNode: bioFocusNode, isNumber: true, borderRadius: true),
              ),
              CustomTextField(
                labelName: 'add_page1',
                controller: bioController,
                focusNode: bioFocusNode,
                requestfocusNode: userNameFocusNode,
                isNumber: false,
                borderRadius: true,
                maxline: 6,
              ),
              const SizedBox(
                height: 10,
              ),
              selectCity(),
              // selectPubgType(),
              selectImageDesign(),
              selectBackImage(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: AgreeButton(
                  onTap: onTapp,
                  name: 'agree',
                ),
              ),
              TextButton(
                onPressed: () {
                  // Get.to(
                  //   () => EditWorkVideos(
                  //     userId: widget.model.user!,
                  //   ),
                  // );
                },
                child: Text(
                  'editVideo'.tr,
                  style: const TextStyle(color: kPrimaryColor, fontFamily: josefinSansMedium),
                ),
              ),
              TextButton(
                onPressed: () {
                  Get.to(
                    () => const VideoUploadPage(),
                  );
                },
                child: Text(
                  'videoUpload'.tr,
                  style: const TextStyle(color: kPrimaryColor, fontFamily: josefinSansMedium),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
