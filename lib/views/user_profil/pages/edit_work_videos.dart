// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:game_app/models/accouts_for_sale_model.dart';
// import 'package:game_app/models/add_account_model.dart';
// import 'package:game_app/views/add_page/video_upload_page.dart';
// import 'package:game_app/views/constants/app_bar.dart';
// import 'package:game_app/views/constants/constants.dart';
// import 'package:game_app/views/constants/dialogs.dart';
// import 'package:game_app/views/constants/widgets.dart';
// import 'package:get/get.dart';

// import '../../cards/video_card.dart';

// class EditWorkVideos extends StatefulWidget {
//   final int userId;

//   const EditWorkVideos({
//     required this.userId,
//     super.key,
//   });

//   @override
//   State<EditWorkVideos> createState() => _EditWorkVideosState();
// }

// class _EditWorkVideosState extends State<EditWorkVideos> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: kPrimaryColorBlack,
//       appBar: const MyAppBar(backArrow: true, fontSize: 0.0, iconRemove: true, elevationWhite: true, name: 'editVideo'),
//       body: FutureBuilder<List<GetAccountVideos>>(
//         future: GetAccountVideos().getVideos(widget.userId),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: spinKit());
//           } else if (snapshot.hasError) {
//             return Center(
//               child: Text(
//                 'account_profil_not_video'.tr,
//                 maxLines: 2,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(color: Colors.white, fontFamily: gilroySemiBold, fontSize: 18),
//               ),
//             );
//           } else if (snapshot.data!.isEmpty) {
//             return Center(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     'account_profil_not_video'.tr,
//                     maxLines: 2,
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(color: Colors.white, fontFamily: gilroySemiBold, fontSize: 18),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 10),
//                     child: TextButton(
//                       onPressed: () {
//                         Get.to(
//                           () => const VideoUploadPage(),
//                         );
//                       },
//                       child: Text(
//                         'videoUpload'.tr,
//                         style: const TextStyle(color: kPrimaryColor, fontFamily: gilroyMedium),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }
//           return Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: ListView.builder(
//               shrinkWrap: true,
//               physics: const BouncingScrollPhysics(),
//               itemCount: snapshot.data!.length,
//               itemBuilder: (BuildContext context, int index) {
//                 return Stack(
//                   children: [
//                     VideoCard(
//                       // ignore: prefer_single_quotes
//                       image: "$serverURL${snapshot.data![index].poster}",
//                       // ignore: prefer_single_quotes
//                       videoPath: "$serverURL${snapshot.data![index].video}",
//                     ),
//                     Positioned(
//                       right: 10,
//                       top: 5,
//                       child: IconButton(
//                         onPressed: () {
//                           showDeleteDialog(context, 'video_delete_title', 'video_delete', () {
//                             AddAccountModel().deleteVideo(id: snapshot.data![index].id!).then((value) {
//                               setState(() {});
//                               Get.back();
//                               showSnackBar('deleted', 'deleted_title', Colors.green);
//                             });
//                           });
//                         },
//                         icon: const Icon(
//                           CupertinoIcons.xmark_circle,
//                           color: Colors.white,
//                           size: 30,
//                         ),
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
