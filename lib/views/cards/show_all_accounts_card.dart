// ignore_for_file: file_names

import 'package:cached_network_image/cached_network_image.dart';
import 'package:game_app/models/get_posts_model.dart';
import 'package:game_app/views/other_pages/account_profil_page/account_profil_page.dart';

import '../constants/index.dart';
import '../constants/price.dart';

class ShowAllProductsCard extends StatelessWidget {
  final GetPostsAccountModel model;
  final bool fav;
  const ShowAllProductsCard({
    required this.fav,
    required this.model,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(
          () => AccountProfilPage(
            userID: model.id!,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: model.vip == true ? kPrimaryColor : Colors.grey.withOpacity(0.4),
          gradient: model.vip == true ? LinearGradient(colors: [kPrimaryColor, kPrimaryColor.withOpacity(0.3)], stops: const [0, 0.99], begin: Alignment.topLeft, end: Alignment.bottomRight) : null,
          borderRadius: borderRadius15,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              flex: 4,
              child: SizedBox(
                width: Get.size.width,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: borderRadius15,
                        child: CachedNetworkImage(
                          fadeInCurve: Curves.ease,
                          imageUrl: '$serverURL${model.image}',
                          imageBuilder: (context, imageProvider) => Container(
                            width: Get.size.width,
                            decoration: BoxDecoration(
                              borderRadius: borderRadius20,
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                                alignment: Alignment.topCenter,
                              ),
                            ),
                          ),
                          placeholder: (context, url) => Center(child: spinKit()),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.white.withOpacity(0.2),
                            child: Center(
                              child: Text(
                                'noImage'.tr,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white, fontFamily: josefinSansSemiBold),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.only(left: 6, top: 4),
                width: Get.size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      model.title.toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: josefinSansSemiBold,
                      ),
                    ),
                    Text(
                      model.createdAt.toString().substring(0, 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white70, fontFamily: josefinSansMedium, fontSize: 16),
                    ),
                    Price(showDiscountedPrice: false, textColor: Colors.white, selectedIndex: Get.locale!.languageCode.toString() == 'tr' ? 2 : 1, price: model.price.toString().substring(0, model.price!.length - 3)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
