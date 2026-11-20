// ignore_for_file: file_names

import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

import '../constants/constants.dart';

class WalletPageCard extends StatelessWidget {
  final String image;
  final String text;
  final Size size;
  final Function() ontapp;
  const WalletPageCard({required this.image, required this.text, required this.size, required this.ontapp, super.key});

  @override
  Widget build(BuildContext context) {
    final cardHeight = (size.height / 4).clamp(150.0, 240.0);
    return GestureDetector(
      onTap: ontapp,
      child: Stack(
        children: [
          Container(
            height: cardHeight,
            width: double.infinity,
            margin: const EdgeInsets.only(left: 15, right: 15, top: 15),
            decoration: BoxDecoration(
              color: kPrimaryColorBlack,
              borderRadius: borderRadius25,
              boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.15), blurRadius: 10, spreadRadius: 3)],
            ),
            child: ClipRRect(
              borderRadius: borderRadius25,
              child: Image.asset(image, fit: BoxFit.cover),
            ),
          ),
          Container(
            height: cardHeight,
            width: double.infinity,
            margin: const EdgeInsets.only(left: 15, right: 15, top: 15),
            decoration: BoxDecoration(borderRadius: borderRadius25, color: Colors.black12.withValues(alpha: 0.6)),
            child: Center(
              child: Text(
                text.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontFamily: gilroySemiBold, fontSize: 35),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
