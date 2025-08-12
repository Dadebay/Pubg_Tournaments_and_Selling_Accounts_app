import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_html/flutter_html.dart';

import '../constants/index.dart';

class BannerProfileView extends GetView {
  final String description;
  final String pageName;
  final String image;

  const BannerProfileView(this.pageName, this.image, this.description);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: kPrimaryColorBlack,
      appBar: AppBar(
        title: Text(
          pageName,
          style: const TextStyle(color: kPrimaryColor, fontFamily: josefinSansBold, fontSize: 20),
        ),
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(
            IconlyLight.arrowLeftCircle,
            color: kPrimaryColor,
          ),
        ),
        backgroundColor: kPrimaryColorBlack,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(statusBarColor: kPrimaryColorBlack, statusBarIconBrightness: Brightness.light),
      ),
      body: ListView(
        children: [
          CachedNetworkImage(
            fadeInCurve: Curves.ease,
            imageUrl: image,
            imageBuilder: (context, imageProvider) => Container(
              width: size.width,
              height: 240,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.fill,
                ),
              ),
            ),
            placeholder: (context, url) => Center(child: spinKit()),
            errorWidget: (context, url, error) => noBannerImage(),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Html(
              data: description,
              style: {
                'body': Style(fontFamily: josefinSansMedium, fontSize: FontSize(20.0), textAlign: TextAlign.left),
              },
            ),
          )
        ],
      ),
    );
  }
}
