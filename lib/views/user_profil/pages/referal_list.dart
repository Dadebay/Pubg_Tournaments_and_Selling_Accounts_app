// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';

// import '../../../models/user_models/referal_model.dart';
// import '../../constants/constants.dart';
// import '../../constants/widgets.dart';

// // ignore: must_be_immutable
// class ReferalUserCard extends StatelessWidget {
//   int index;
//   final ReferalModel getMeModel;
//   ReferalUserCard({required this.index, required this.getMeModel, super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Expanded(
//             flex: 2,
//             child: Text(
//               ' ${index + 1}.',
//               textAlign: TextAlign.center,
//               style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 20),
//             ),
//           ),
//           Expanded(
//             flex: 3,
//             child: ClipOval(
//               child: SizedBox(
//                 width: 60,
//                 height: 70,
//                 child: CachedNetworkImage(
//                   fadeInCurve: Curves.ease,
//                   imageUrl: getMeModel.image,
//                   imageBuilder: (context, imageProvider) => Container(
//                     width: double.infinity,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       image: DecorationImage(
//                         image: imageProvider,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                   placeholder: (context, url) => Center(child: spinKit()),
//                   errorWidget: (context, url, error) => Container(
//                     color: kPrimaryColor.withOpacity(0.2),
//                     child: const Center(
//                       child: Text(
//                         'Surat ýok',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(color: Colors.white, fontFamily: gilroySemiBold),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(
//             width: 10,
//           ),
//           Expanded(
//             flex: 7,
//             child: Text(
//               getMeModel.pubg_username,
//               overflow: TextOverflow.ellipsis,
//               maxLines: 1,
//               style: const TextStyle(color: Colors.white, fontFamily: gilroySemiBold, fontSize: 20),
//             ),
//           ),
//           Expanded(
//             flex: 3,
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               mainAxisAlignment: MainAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   getMeModel.points,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontFamily: gilroySemiBold,
//                   ),
//                 ),
//                 const Text(
//                   ' TMT',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 13,
//                     fontFamily: gilroySemiBold,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(
//             width: 10,
//           ),
//         ],
//       ),
//     );
//   }
// }
