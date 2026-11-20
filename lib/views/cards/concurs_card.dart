// ignore_for_file: file_names

import 'package:cached_network_image/cached_network_image.dart';
import 'package:game_app/models/get_gifts_model.dart';
import 'package:game_app/views/buttons/add_cart_button.dart';
import 'package:game_app/views/constants/index.dart';

import '../constants/price.dart';

class GiftCARD extends StatelessWidget {
  final GiftsMOdel model;
  final int selectedIndex;
  const GiftCARD({required this.model, required this.selectedIndex, super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8, right: 8, top: 8),
      decoration: const BoxDecoration(borderRadius: borderRadius20, color: Colors.white60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: ClipRRect(
              borderRadius: borderRadius20,
              child: CachedNetworkImage(
                fadeInCurve: Curves.ease,
                imageUrl: '$serverURL/media/${model.image['name']}',
                imageBuilder: (context, imageProvider) => Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: borderRadius20,
                    image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                  ),
                ),
                placeholder: (context, url) => Center(child: spinKit()),
                errorWidget: (context, url, error) => Center(
                  child: Text(
                    'noImage'.tr,
                    style: const TextStyle(color: Colors.black, fontFamily: gilroySemiBold),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 6),
            child: Text(
              model.nameTm,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.black, fontSize: MediaQuery.sizeOf(context).width >= 800 ? 27 : 25, fontFamily: gilroyBold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 6),
            child: Price(showDiscountedPrice: false, textColor: Colors.black, selectedIndex: selectedIndex, price: model.price.toStringAsFixed(1)),
          ),
          model.count_left == 0
              ? Container(
                  margin: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: kPrimaryColorBlack, borderRadius: borderRadius15),
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    'noStock'.tr,
                    style: const TextStyle(color: kPrimaryColor, fontFamily: gilroySemiBold),
                  ),
                )
              : AddCartButton(productProfil: false, id: model.id, price: model.price.toString(), image: "/media/${model.image['name']}", title: model.nameTm, status: 'gift'),
        ],
      ),
    );
  }
}

class ThingsCards extends StatelessWidget {
  final ThingsMODEL model;
  final int selectedIndex;
  const ThingsCards({required this.model, required this.selectedIndex, super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8, right: 8, top: 8),
      decoration: const BoxDecoration(borderRadius: borderRadius20, color: Colors.white60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: ClipRRect(
              borderRadius: borderRadius20,
              child: CachedNetworkImage(
                fadeInCurve: Curves.ease,
                imageUrl: '$serverURL${model.image}',
                imageBuilder: (context, imageProvider) => Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: borderRadius20,
                    image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                  ),
                ),
                placeholder: (context, url) => Center(child: spinKit()),
                errorWidget: (context, url, error) => Center(
                  child: Text(
                    'noImage'.tr,
                    style: const TextStyle(color: Colors.black, fontFamily: gilroySemiBold),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 6),
            child: Text(
              model.nameTm,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.black, fontSize: MediaQuery.sizeOf(context).width >= 800 ? 27 : 25, fontFamily: gilroyBold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 6),
            child: Price(showDiscountedPrice: false, textColor: Colors.black, selectedIndex: selectedIndex, price: model.price),
          ),
          AddCartButton(productProfil: false, id: model.id, price: model.price.toString(), image: model.image, title: model.nameTm, status: 'thing'),
        ],
      ),
    );
  }
}
