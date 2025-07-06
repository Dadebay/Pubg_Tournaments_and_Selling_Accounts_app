import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:game_app/controllers/show_all_account_controller.dart';
import 'package:game_app/models/home_page_model.dart';
import 'package:game_app/views/constants/index.dart';
import 'package:http/http.dart' as http;
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../models/user_models/auth_model.dart';
import '../../models/user_models/user_sign_in_model.dart';
import '../cards/home_page_card.dart';
import 'Banners.dart';
import 'pubg_types.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ShowAllAccountsController postsController = Get.put(ShowAllAccountsController());
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  late Future<List<BannerModel>> _futureBanners;

  @override
  void initState() {
    super.initState();
    getMe();
    _futureBanners = BannerModel().getBanners();

    postsController.clearData();
    postsController.fetchPosts(DANGEROUS_clearList: true);
  }

  @override
  void dispose() {
    _refreshController.dispose();

    super.dispose();
  }

  void _onRefresh() async {
    setState(() {
      _futureBanners = BannerModel().getBanners();
    });

    postsController.clearData();
    await postsController.fetchPosts(DANGEROUS_clearList: true);

    _refreshController.refreshCompleted();

    if (postsController.list.length < 10 && postsController.list.isNotEmpty) {
      _refreshController.loadNoData();
    } else if (postsController.list.isEmpty) {
      _refreshController.loadNoData();
    } else {
      _refreshController.resetNoData();
    }
  }

  void _onLoading() async {
    postsController.pageNumber.value++;
    final int oldListLength = postsController.list.length;
    await postsController.fetchPosts(DANGEROUS_clearList: false);

    if (postsController.list.length > oldListLength) {
      _refreshController.loadComplete();
    } else {
      _refreshController.loadNoData();
    }
  }

  Future<GetMeModel?> getMe() async {
    final token = await Auth().getToken();
    if (token == null) {
      print('Token not found for getMe');
      return null;
    }
    try {
      final response = await http.get(
        Uri.parse(
          '$serverURL/api/accounts/get-my-account/',
        ),
        headers: <String, String>{
          HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        final responseJson = json.decode(decoded);
        final bool blocked = responseJson['blocked'] ?? false;
        final String blockReason = responseJson['block_reason'] ?? 'Sebäbi görkezilmedi';
        final String blockEndDate = responseJson['block_end_date'] ?? 'Möhleti görkezilmedi';

        if (blocked == true) {
          if (!mounted) return null;
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctxt) => AlertDialog(
              backgroundColor: kPrimaryColorBlack,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
              title: Text('Üns Beriň!'.tr, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontFamily: josefinSansSemiBold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Siz Blocklandyňyz!'.tr,
                      style: const TextStyle(fontSize: 18, color: Colors.redAccent, fontFamily: josefinSansBold),
                    ),
                    const SizedBox(height: 15),
                    Text('Sebäbi:'.tr, style: const TextStyle(fontSize: 14, color: Colors.grey, fontFamily: josefinSansRegular)),
                    Text(blockReason.tr, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.white, fontFamily: josefinSansMedium)),
                    const SizedBox(height: 15),
                    Text('Blok möhleti:'.tr, style: const TextStyle(fontSize: 14, color: Colors.grey, fontFamily: josefinSansRegular)),
                    Text(blockEndDate.tr, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.normal, fontFamily: josefinSansRegular)),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Auth().removeToken();

                    exit(0);
                  },
                  child: Text('Düşnükli'.tr, style: const TextStyle(color: kPrimaryColor)),
                ),
              ],
            ),
          );
        }
        return GetMeModel.fromJson(responseJson);
      } else {
        print('GetMe request failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error in getMe: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        backgroundColor: kPrimaryColorBlack,
        appBar: const MyAppBar(fontSize: 0, backArrow: false, iconRemove: true, name: appName, elevationWhite: false),
        body: SmartRefresher(
          footer: footer(),
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          enablePullDown: true,
          enablePullUp: true,
          physics: const BouncingScrollPhysics(),
          header: const MaterialClassicHeader(
            color: kPrimaryColor,
          ),
          child: ListView(
            children: [
              FutureBuilder<List<BannerModel>>(
                future: _futureBanners,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(height: size.height * 0.2, child: Center(child: spinKit()));
                  } else if (snapshot.hasError) {
                    return SizedBox(height: size.height * 0.2, child: Center(child: Text('bannerError'.tr)));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Banners(future: _futureBanners);
                },
              ),
              listViewName('pubgTypes'.tr, false, size),
              PubgTypes(),
              listViewName('accountsForSale'.tr, true, size),
              Obx(() {
                if (postsController.isLoading.value && postsController.list.isEmpty) {
                  return Container(
                    margin: const EdgeInsets.all(8),
                    height: 220,
                    width: Get.size.width,
                    child: Center(child: spinKit()),
                  );
                } else if (postsController.list.isEmpty && !postsController.isLoading.value) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('noPostsFound'.tr),
                    ),
                  );
                }

                return GridView.builder(
                  itemCount: postsController.list.length,
                  physics: const NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: size.width >= 800 ? 3 : (size.width >= 600 ? 2 : 1),
                    childAspectRatio: size.width >= 800 ? (3 / 4.5) : (size.width >= 600 ? (2 / 3.2) : (1 / 0.6)),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return HomePageCard(vip: postsController.list[index].vip!, model: postsController.list[index]);
                  },
                );
              }),
              Obx(() {
                if (postsController.isLoadingMore.value) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(child: spinKit()),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        ),
      ),
    );
  }

  CustomFooter footer() {
    return CustomFooter(
      builder: (BuildContext context, LoadStatus? mode) {
        Widget body;
        if (mode == LoadStatus.idle) {
          body = Text('Dowamyny ýüklemek üçin ýokary çekiň'.tr);
        } else if (mode == LoadStatus.failed) {
          body = Text('Ýüklemek başa barmady'.tr);
        } else if (mode == LoadStatus.canLoading) {
          body = Text('Dowamyny ýüklemek üçin goýberiň'.tr);
        } else {
          body = Text('Başga maglumat ýok'.tr);
        }
        return SizedBox(
          height: 55.0,
          child: Center(child: body),
        );
      },
    );
  }
}
