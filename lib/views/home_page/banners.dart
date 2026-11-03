import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:game_app/controllers/settings_controller.dart';
import 'package:game_app/models/home_page_model.dart';
import 'package:game_app/views/cards/banner_card.dart';
import 'package:get/get.dart';

import '../constants/constants.dart';
import '../constants/widgets.dart';

class Banners extends StatelessWidget {
  final Future<List<BannerModel>> future;

  const Banners({required this.future, super.key});
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return FutureBuilder<List<BannerModel>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            margin: const EdgeInsets.all(8),
            height: 220,
            width: Get.size.width,
            decoration: BoxDecoration(borderRadius: borderRadius15, color: Colors.grey.withValues(alpha: 0.4)),
            child: Center(child: spinKit()),
          );
        } else if (snapshot.hasError) {
          return noBannerImage();
        } else if (snapshot.data.toString() == '[]') {
          return noBannerImage();
        }
        return Column(
          children: [
            CarouselSlider.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index, count) {
                return BannerCard(image: '$serverURL${snapshot.data![index].image}', content: snapshot.data![index].content!, title: snapshot.data![index].title!);
              },
              options: CarouselOptions(
                onPageChanged: (index, CarouselPageChangedReason a) {
                  Get.find<SettingsController>().bannerSelectedIndex.value = index;
                },
                height: size.width >= 800 ? 320 : 220,
                viewportFraction: 1.0,
                autoPlay: true,
                scrollPhysics: const BouncingScrollPhysics(),
                autoPlayCurve: Curves.fastLinearToSlowEaseIn,
                autoPlayAnimationDuration: const Duration(milliseconds: 2000),
              ),
            ),
            dots(snapshot, size),
          ],
        );
      },
    );
  }

  SizedBox dots(AsyncSnapshot<List<BannerModel>> snapshot, Size size) {
    return SizedBox(
      height: size.width >= 800 ? 40 : 20,
      width: Get.size.width,
      child: Center(
        child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: snapshot.data!.length,
          itemBuilder: (BuildContext context, int index) {
            return Obx(() {
              return AnimatedContainer(
                margin: EdgeInsets.symmetric(horizontal: size.width >= 800 ? 8 : 4),
                duration: const Duration(milliseconds: 500),
                curve: Curves.decelerate,
                height: Get.find<SettingsController>().bannerSelectedIndex.value == index
                    ? size.width >= 800
                          ? 22
                          : 16
                    : size.width >= 800
                    ? 16
                    : 10,
                width: Get.find<SettingsController>().bannerSelectedIndex.value == index
                    ? size.width >= 800
                          ? 21
                          : 15
                    : size.width >= 800
                    ? 16
                    : 10,
                decoration: BoxDecoration(
                  color: Get.find<SettingsController>().bannerSelectedIndex.value == index ? Colors.transparent : Colors.grey,
                  shape: BoxShape.circle,
                  border: Get.find<SettingsController>().bannerSelectedIndex.value == index ? Border.all(color: kPrimaryColor, width: 3) : Border.all(color: Colors.white),
                ),
              );
            });
          },
        ),
      ),
    );
  }
}
