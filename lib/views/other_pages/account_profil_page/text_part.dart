import 'package:cached_network_image/cached_network_image.dart';

import '../../../models/get_posts_model.dart';
import '../../constants/index.dart';

class CustomFlexibleSpace extends StatelessWidget {
  final GetPostsAccountModel model;

  const CustomFlexibleSpace({
    required this.model,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return FlexibleSpaceBar(
      background: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          imagePart(model),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, top: 20, bottom: 20),
            child: Text(
              model.desc ?? '',
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontFamily: josefinSansRegular, fontSize: 20),
            ),
          ),
          Container(
            color: kPrimaryColorBlack,
            height: 75,
            margin: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                rowText(model.price!, 'accountPrice'.tr, true),
                VerticalDivider(
                  color: Colors.white.withOpacity(0.8),
                  thickness: 1,
                ),
                rowText('Global', 'accountPubgType'.tr, false),
              ],
            ),
          ),
          const SizedBox(
            height: kToolbarHeight,
          ),
        ],
      ),
    );
  }

  Expanded imagePart(GetPostsAccountModel model) {
    return Expanded(
      flex: 4,
      child: Stack(
        children: [
          Positioned.fill(
            bottom: 70,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              child: CachedNetworkImage(
                fadeInCurve: Curves.ease,
                imageUrl: "$serverURL${model.bgImage ?? ""}",
                imageBuilder: (context, imageProvider) => Container(
                  width: Get.size.width,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                placeholder: (context, url) => Center(child: spinKit()),
                errorWidget: (context, url, error) => Image.asset(
                  accountBackImage,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    height: 110,
                    width: 110,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: kPrimaryColorBlack),
                    padding: const EdgeInsets.all(8),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        fadeInCurve: Curves.ease,
                        imageUrl: "$serverURL${model.image ?? ""}",
                        imageBuilder: (context, imageProvider) => Container(
                          width: Get.size.width,
                          decoration: BoxDecoration(
                            borderRadius: borderRadius15,
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
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
                  // Expanded(
                  //   child: Padding(
                  //     padding: const EdgeInsets.only(bottom: 15),
                  //     child: Column(
                  //       mainAxisSize: MainAxisSize.min,
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         Text(
                  //           "model.user!.firsName ?? ",
                  //           textAlign: TextAlign.start,
                  //           maxLines: 2,
                  //           overflow: TextOverflow.ellipsis,
                  //           style: const TextStyle(color: Colors.white, fontFamily: josefinSansSemiBold, fontSize: 20),
                  //         ),
                  //         const SizedBox(
                  //           height: 4,
                  //         ),
                  //         Text(
                  //           model.user!.phone ?? '',
                  //           maxLines: 2,
                  //           overflow: TextOverflow.ellipsis,
                  //           style: const TextStyle(color: Colors.grey, fontFamily: josefinSansRegular, fontSize: 16),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Expanded rowText(String text1, String text2, bool price) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          price
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      text1,
                      style: const TextStyle(
                        color: kPrimaryColor,
                        fontSize: 20,
                        fontFamily: josefinSansSemiBold,
                      ),
                    ),
                    const Text(
                      ' TMT',
                      style: TextStyle(
                        color: kPrimaryColor,
                        fontSize: 13,
                        height: 2,
                        fontFamily: josefinSansSemiBold,
                      ),
                    ),
                  ],
                )
              : Text(
                  text1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(color: kPrimaryColor, fontSize: 20, fontFamily: josefinSansSemiBold),
                ),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              text2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: const TextStyle(color: Colors.white, fontSize: 19, fontFamily: josefinSansRegular),
            ),
          ),
        ],
      ),
    );
  }
}
