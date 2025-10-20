// ignore_for_file: file_names, must_be_immutable

import 'package:carousel_slider/carousel_slider.dart';
import 'package:game_app/views/cards/mini_category_card.dart';

import '../constants/index.dart';

class PubgTypes extends StatelessWidget {
  List names = [
    'accountsForSale',
    'orders',
    // 'cashHistory',
    'notification',
  ];
  List images = [
    'assets/image/8.png',
    'assets/image/6.png',
    // 'assets/image/5.png',
    'assets/image/7.png',
  ];

  PubgTypes({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Container(
      height: size.width >= 800 ? 300 : 150,
      margin: const EdgeInsets.only(
        top: 25,
        bottom: 25,
      ),
      color: kPrimaryColorBlack,
      alignment: Alignment.center,
      child: CarouselSlider.builder(
        itemCount: 3,
        itemBuilder: (context, index, count) {
          return MiniCategoryCard(
            index: index,
            image: images[index],
            name: names[index],
          );
        },
        options: CarouselOptions(
          onPageChanged: (index, CarouselPageChangedReason a) {},
          height: size.width >= 800 ? 300 : 150,
          viewportFraction: 0.6,
          autoPlay: true,
          enableInfiniteScroll: true,
          scrollPhysics: const BouncingScrollPhysics(),
          autoPlayCurve: Curves.fastLinearToSlowEaseIn,
          autoPlayAnimationDuration: const Duration(milliseconds: 2000),
        ),
      ),
    );
  }
}
