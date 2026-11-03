// // ignore_for_file: non_constant_identifier_names

// import 'package:game_app/views/constants/index.dart';
// import 'package:game_app/views/user_profil/pages/referal_list.dart';

// import '../../../models/user_models/referal_model.dart';
// import '../../../repository/repository_referal.dart';

// // ignore: must_be_immutable
// class ReferalPage extends StatelessWidget {
//   ReferalRespositori getData = ReferalRespositori();
//   final String? referalcode;
//   final String? used_refcode;
//   ReferalPage({required this.referalcode, required this.used_refcode, super.key});

//   @override
//   Widget build(BuildContext context) {
//     final Size size = MediaQuery.of(context).size;
//     return Scaffold(
//       backgroundColor: kPrimaryColorBlack,
//       appBar: MyAppBar(
//         fontSize: 0,
//         backArrow: true,
//         iconRemove: false,
//         icon: IconButton(
//           onPressed: () {
//             showSnackBar('referalKod', 'referalSubtitle', Colors.green);
//           },
//           icon: const Icon(
//             Icons.info_outline,
//             color: kPrimaryColor,
//           ),
//         ),
//         name: 'referalKod',
//         elevationWhite: true,
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             color: kPrimaryColorBlack,
//             width: Get.size.width,
//             padding: const EdgeInsets.only(top: 12, left: 10),
//             child: Text(
//               'referalKod1'.tr,
//               style: TextStyle(color: Colors.grey, fontSize: size.width >= 800 ? 30 : 22, fontFamily: gilroySemiBold),
//             ),
//           ),
//           Container(
//             color: kPrimaryColorBlack,
//             padding: const EdgeInsets.only(left: 10, top: 8),
//             child: Row(
//               children: [
//                 Text(
//                   referalcode!,
//                   style: const TextStyle(fontFamily: gilroyBold, fontSize: 24),
//                 ),
//                 IconButton(
//                   onPressed: () {
//                     Clipboard.setData(ClipboardData(text: referalcode!)).then((value) {
//                       showSnackBar('copySucces', 'copySuccesSubtitle', Colors.green);
//                     });
//                   },
//                   icon: const Icon(
//                     Icons.copy,
//                     color: kPrimaryColor,
//                     size: 20,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           dividder(),
//           Container(
//             color: kPrimaryColorBlack,
//             width: Get.size.width,
//             padding: const EdgeInsets.only(top: 12, left: 10, bottom: 25),
//             child: Text(
//               'referalKodUsedUser'.tr,
//               style: TextStyle(color: Colors.grey, fontSize: size.width >= 800 ? 30 : 22, fontFamily: gilroySemiBold),
//             ),
//           ),
//           FutureBuilder<List<ReferalModel>>(
//             future: getData.getDryPortsModel(),
//             builder: (BuildContext context, AsyncSnapshot<List<ReferalModel>> snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return Center(child: spinKit());
//               } else if (snapshot.hasError) {
//                 return errorData(onTap: () {});
//               } else if (snapshot.data == null) {
//                 return emptyData();
//               }

//               return Expanded(
//                 child: ListView.builder(
//                   itemCount: snapshot.data!.length,
//                   itemBuilder: (BuildContext context, int index) {
//                     return ReferalUserCard(
//                       index: index,
//                       getMeModel: snapshot.data![index],
//                     );
//                   },
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Container dividder() {
//     return Container(
//       color: kPrimaryColorBlack,
//       padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
//       child: const Divider(
//         color: Colors.grey,
//       ),
//     );
//   }
// }
