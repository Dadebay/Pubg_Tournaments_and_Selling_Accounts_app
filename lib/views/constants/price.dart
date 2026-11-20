// ignore_for_file: file_names

import 'package:material_ui/material_ui.dart';
import 'package:game_app/views/constants/constants.dart';

class Price extends StatelessWidget {
  final bool showDiscountedPrice;
  final String price;
  final String? discountedPrice;
  final int selectedIndex;
  final Color textColor;
  const Price({required this.textColor, required this.showDiscountedPrice, required this.price, required this.selectedIndex, super.key, this.discountedPrice});
  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: showDiscountedPrice ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(price, style: TextStyle(color: textColor, fontSize: 25, fontFamily: gilroyBold)),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              selectedIndex == 1 ? ' RUB' : ' TMT',
              style: TextStyle(color: textColor, fontSize: 14, fontFamily: gilroyBold),
            ),
          ),
        ],
      ),
    );
  }
}
