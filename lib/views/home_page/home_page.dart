import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:game_app/controllers/show_all_account_controller.dart';
import 'package:game_app/controllers/wallet_controller.dart';
import 'package:game_app/models/get_posts_model.dart';
import 'package:game_app/models/home_page_model.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:game_app/models/user_models/abous_us_model.dart';
import 'package:game_app/utils/support_push.dart';
import 'package:game_app/views/constants/blocked_dialog.dart';
import 'package:game_app/views/constants/index.dart';
import 'package:game_app/views/constants/notification_bell.dart';
import 'package:game_app/views/constants/support_chat_button.dart';
import 'package:game_app/views/home_page/home_hub.dart';
import 'package:http/http.dart' as http;
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../models/user_models/auth_model.dart';
import '../../models/user_models/user_sign_in_model.dart';
import '../cards/home_page_card.dart';
import 'home_banner.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ShowAllAccountsController postsController = Get.put(
    ShowAllAccountsController(),
  );
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  late Future<List<BannerModel>> _futureBanners;

  /// The VIP accounts, shown right under the "Satlyk akkauntlar" title.
  Future<List<GetPostsAccountModel>> _futureVip = Future.value(
    const <GetPostsAccountModel>[],
  );

  /// Ids of the VIP accounts, so the normal list below does not show them twice.
  Set<int> _vipIds = {};
  bool showPage = false;

  @override
  void initState() {
    super.initState();
    SupportPush.subscribe();
    SupportPush.markHomeReady();
    getMe();
    _futureBanners = BannerModel().getBanners();
    _loadVip();

    postsController.clearData();
    postsController.fetchPosts(DANGEROUS_clearList: true);
    getData();
  }

  void _loadVip() {
    _futureVip = GetPostsAccountModel()
        .getVIPPosts(parametrs: {'page': '1', 'size': '10'})
        .then((items) {
          if (mounted) {
            setState(
              () => _vipIds = {
                for (final item in items)
                  if (item.id != null) item.id!,
              },
            );
          }
          return items;
        })
        .catchError((_) => <GetPostsAccountModel>[]);
  }

  /// A gold "VIP" label and the VIP accounts side by side, under the section title.
  Widget _vipSection(Size size) {
    return FutureBuilder<List<GetPostsAccountModel>>(
      future: _futureVip,
      builder: (context, snapshot) {
        final items = snapshot.data ?? const <GetPostsAccountModel>[];
        if (items.isEmpty) {
          return const SizedBox.shrink();
        }
        const gold = Color(0xFFFFC83D);
        final cardWidth = size.width >= 800 ? 420.0 : size.width - 40;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  const HugeIcon(
                    icon: HugeIcons.strokeRoundedCrown,
                    color: gold,
                    size: 22,
                    strokeWidth: 1.9,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'VIP',
                    style: TextStyle(
                      color: gold,
                      fontFamily: gilroyBold,
                      fontSize: 20,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: gold.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 188,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: items.length,
                separatorBuilder: (context, index) => const SizedBox(width: 4),
                itemBuilder: (context, index) => SizedBox(
                  width: cardWidth,
                  child: HomePageCard(vip: true, model: items[index]),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();

    super.dispose();
  }

  void _onRefresh() async {
    final token = await Auth().getToken();
    log('Token in HomePage initState: ${token.toString()}');
    if (!mounted) {
      return;
    }
    setState(() {
      _futureBanners = BannerModel().getBanners();
      _loadVip();
    });

    postsController.clearData();
    await postsController.fetchPosts(DANGEROUS_clearList: true);
    await Get.find<WalletController>().getUserMoney();
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

  dynamic getData() async {
    int a = 0;
    await AboutUsModel().getAboutUs().then((value) {
      for (var element in value) {
        if (element.pageShow == true) {
          a++;
        }
      }
    });
    // The page can be left while the request runs.
    if (!mounted) {
      return;
    }
    if (a == 3) {
      showPage = true;
    }
    setState(() {});
  }

  Future<GetMeModel?> getMe() async {
    final token = await Auth().getToken();
    if (token == null) {
      print('Token not found for getMe');
      return null;
    }
    try {
      final response = await http.get(
        Uri.parse('$serverURL/api/accounts/get-my-account/'),
        headers: <String, String>{
          HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        final responseJson = json.decode(decoded);
        final bool blocked = responseJson['blocked'] ?? false;

        if (blocked == true) {
          if (!mounted) {
            return null;
          }
          // The reason and a live countdown; when the time is up the player continues and the server is asked again.
          final continued = await showBlockedDialog(
            context,
            ban: BanInfo.fromJson(responseJson),
          );
          if (continued) {
            return await getMe();
          }
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
        appBar: const MyAppBar(
          fontSize: 0,
          backArrow: false,
          iconRemove: false,
          icon: NotificationBell(),
          name: appName,
          elevationWhite: false,
        ),
        body: Stack(
          children: [
            SmartRefresher(
              footer: footer(),
              controller: _refreshController,
              onRefresh: _onRefresh,
              onLoading: _onLoading,
              enablePullDown: true,
              enablePullUp: true,
              physics: const BouncingScrollPhysics(),
              header: const MaterialClassicHeader(color: kPrimaryColor),
              child: ListView(
                children: [
                  HomeBanner(future: _futureBanners),
                  if (showPage == false) ...[
                    const HomeBalanceCard(),
                    const HomeSections(),
                  ],
                  listViewName('homeVipAccounts'.tr, true, size),
                  _vipSection(size),
                  Obx(() {
                    if (postsController.isLoading.value &&
                        postsController.list.isEmpty) {
                      return Container(
                        margin: const EdgeInsets.all(8),
                        height: 220,
                        width: Get.size.width,
                        child: Center(child: spinKit()),
                      );
                    } else if (postsController.list.isEmpty &&
                        !postsController.isLoading.value) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text('noPostsFound'.tr),
                        ),
                      );
                    }

                    final items = postsController.list
                        .where((item) => !_vipIds.contains(item.id))
                        .toList();
                    return GridView.builder(
                      itemCount: items.length,
                      physics: const NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(8.0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: size.width >= 800
                            ? 3
                            : (size.width >= 600 ? 2 : 1),
                        mainAxisExtent: 188,
                        mainAxisSpacing: 4,
                        crossAxisSpacing: 8,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        return HomePageCard(
                          vip: items[index].vip == true,
                          model: items[index],
                        );
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
            // Placed by hand: the Scaffold FAB slot did not land at the corner here.
            const Positioned(
              right: 16,
              bottom: 16,
              child: SupportChatButton(floating: true),
            ),
          ],
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
        return SizedBox(height: 55.0, child: Center(child: body));
      },
    );
  }
}
