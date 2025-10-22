// ignore_for_file: file_names, deprecated_member_use

import 'package:flutter_html/flutter_html.dart';
import 'package:game_app/models/accouts_for_sale_model.dart';
import 'package:game_app/models/add_account_model.dart';
import 'package:game_app/models/get_posts_model.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../cards/video_card.dart';
import '../../constants/index.dart';
import 'page_1.dart';
import 'text_part.dart';

class AccountProfilPage extends StatefulWidget {
  final int userID;
  const AccountProfilPage({
    required this.userID,
    super.key,
  });

  @override
  State<AccountProfilPage> createState() => _AccountProfilPageState();
}

class _AccountProfilPageState extends State<AccountProfilPage> {
  @override
  void initState() {
    super.initState();
    getData();
  }

  dynamic getData() {
    AddAccountModel().getConsts().then((value) {
      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: Colors.grey.withOpacity(0.7),
        barrierLabel: 'test',
        pageBuilder: (context, animation1, animation2) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                backgroundColor: kPrimaryColorBlack,
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(IconlyLight.infoSquare, color: kPrimaryColor, size: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        'accountsForSale'.tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: josefinSansSemiBold),
                      ),
                    ),
                    const Icon(IconlyLight.infoSquare, color: kPrimaryColor, size: 30),
                  ],
                ),
                shape: const OutlineInputBorder(borderRadius: borderRadius15, borderSide: BorderSide(color: Colors.white)),
                content: SizedBox(
                  width: Get.size.width * 0.8,
                  // height: Get.size.height * 0.5,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Html(
                        data: value['text_one'],
                        style: {
                          'body': Style(
                            fontFamily: josefinSansRegular,
                            fontSize: FontSize(20.0),
                            color: Colors.white,
                            textAlign: TextAlign.center,
                          ),
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      AgreeButton(
                        onTap: () {
                          Get.back();
                        },
                        showIcon: false,
                        name: 'readAndAgree',
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: kPrimaryColorBlack,
        body: FutureBuilder<GetPostsAccountModel>(
          future: GetPostsAccountModel().getPostById(widget.userID),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: spinKit());
            } else if (snapshot.hasError) {
              return errorData(onTap: () {});
            } else if (snapshot.data == null) {
              return emptyData();
            }
            return NestedScrollView(
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return [sliverAppBar(snapshot.data!)];
              },
              body: TabBarView(
                children: [
                  TabbarPage1(
                    model: snapshot.data!,
                  ),
                  snapshot.data!.videos.toString() == '[]'
                      ? Center(
                          child: Text(
                            'account_profil_not_video'.tr,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontFamily: josefinSansSemiBold, fontSize: 18),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          itemCount: snapshot.data!.videos?.length,
                          itemBuilder: (BuildContext context, int index) {
                            return VideoCard(
                              image: '$serverURL${snapshot.data!.videos![index].poster}',
                              videoPath: '$serverURL${snapshot.data!.videos![index].video}',
                            );
                          },
                        ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  SliverAppBar sliverAppBar(GetPostsAccountModel model) {
    return SliverAppBar(
      expandedHeight: 500,
      backgroundColor: kPrimaryColorBlack,
      elevation: 0,
      leading: GestureDetector(
        onTap: () {
          Get.back();
        },
        child: Container(
          margin: const EdgeInsets.only(top: 14, left: 14),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.4), shape: BoxShape.circle),
          child: const Icon(
            IconlyLight.arrowLeft,
            color: Colors.white,
          ),
        ),
      ),
      // actions: [
      //   moreInfoButton(model.user!),
      // ],
      pinned: true,
      floating: true,
      systemOverlayStyle: const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
      flexibleSpace: CustomFlexibleSpace(model: model),
      bottom: tabbar(),
    );
  }

  Padding moreInfoButton(PostByIdModel model) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, right: 12),
      child: PopupMenuButton(
        color: kPrimaryColorBlack,
        padding: EdgeInsets.zero,
        icon: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.4), shape: BoxShape.circle),
          child: const Icon(
            Icons.more_horiz,
            color: Colors.white,
          ),
        ),
        itemBuilder: (context) => <PopupMenuEntry<Text>>[
          PopupMenuItem<Text>(
            onTap: () async {
              await launch('tel://${model.phone}');
            },
            child: Text(
              'popUP1'.tr,
              style: const TextStyle(fontFamily: josefinSansRegular),
            ),
          ),
          PopupMenuItem<Text>(
            onTap: () async {
              await launch('sms:${model.phone}?body=Pubg House');
            },
            child: Text(
              'popUp2'.tr,
              style: const TextStyle(fontFamily: josefinSansRegular),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSize tabbar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Container(
        decoration: BoxDecoration(
          color: kPrimaryColorBlack,
          border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.2))),
        ),
        child: TabBar(
          labelStyle: const TextStyle(color: kPrimaryColor, fontFamily: josefinSansSemiBold, fontSize: 18),
          unselectedLabelStyle: const TextStyle(color: Colors.grey, fontSize: 17, fontFamily: josefinSansRegular),
          labelColor: kPrimaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorSize: TabBarIndicatorSize.label,
          indicatorColor: kPrimaryColor,
          indicatorWeight: 4,
          indicatorPadding: const EdgeInsets.only(
            top: 45,
          ),
          indicator: const BoxDecoration(color: kPrimaryColor, borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          tabs: [
            Tab(
              text: 'accountInfo'.tr,
            ),
            Tab(
              text: 'accountVideos'.tr,
            ),
          ],
        ),
      ),
    );
  }
}
