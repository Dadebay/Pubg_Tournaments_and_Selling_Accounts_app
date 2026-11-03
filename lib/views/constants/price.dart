// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:game_app/views/constants/constants.dart';

class Price extends StatelessWidget {
  final bool showDiscountedPrice;
  final String price;
  final String? discountedPrice;
  final int selectedIndex;
  final Color textColor;
  const Price({
    required this.textColor,
    required this.showDiscountedPrice,
    required this.price,
    required this.selectedIndex,
    super.key,
    this.discountedPrice,
  });
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: showDiscountedPrice ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Text(
          price,
          style: TextStyle(
            color: textColor,
            fontSize: size.width >= 800 ? 27 : 25,
            fontFamily: gilroyBold,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            selectedIndex == 1 ? ' RUB' : ' TMT',
            style: TextStyle(
              color: textColor,
              fontSize: size.width >= 800 ? 20 : 14,
              fontFamily: gilroyBold,
            ),
          ),
        ),
      ],
    );
  }
}
