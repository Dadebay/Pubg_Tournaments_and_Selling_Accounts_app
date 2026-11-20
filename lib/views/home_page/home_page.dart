import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:game_app/controllers/show_all_account_controller.dart';
import 'package:game_app/controllers/wallet_controller.dart';
import 'package:game_app/models/get_posts_model.dart';
import 'package:game_app/models/home_page_model.dart';
import 'package:game_app/models/user_models/abous_us_model.dart';
import 'package:game_app/utils/support_push.dart';
import 'package:game_app/views/constants/blocked_dialog.dart';
import 'package:game_app/views/constants/index.dart';
import 'package:game_app/views/constants/notification_bell.dart';
import 'package:game_app/views/constants/support_chat_button.dart';
import 'package:game_app/views/home_page/home_hub.dart';
import 'package:http/http.dart' as http;
import 'package:game_app/views/constants/refresh_header.dart';
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
  final ShowAllAccountsController postsController = Get.put(ShowAllAccountsController());
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  late Future<List<BannerModel>> _futureBanners;

  /// The VIP accounts, shown right under the "Satlyk akkauntlar" title.
  Future<List<GetPostsAccountModel>> _futureVip = Future.value(const <GetPostsAccountModel>[]);

  bool showPage = false;

  @override
  void initState() {
    super.initState();
    SupportPush.subscribe();
    SupportPush.markHomeReady();
    getMe();
    _futureBanners = BannerModel().getBanners();
    _loadVip();

    getData();
  }

  void _loadVip() {
    _futureVip = GetPostsAccountModel()
        .getVIPPosts(parametrs: {'page': '1', 'size': '10'})
        // Only VIP accounts are shown on the home page.
        .then(
          (items) => [
            for (final item in items)
              if (item.vip == true) item,
          ],
        )
        .catchError((_) => <GetPostsAccountModel>[]);
  }

  /// The VIP accounts one under another, right under the section title.
  Widget _vipSection() {
    return FutureBuilder<List<GetPostsAccountModel>>(
      future: _futureVip,
      builder: (context, snapshot) {
        final items = snapshot.data ?? const <GetPostsAccountModel>[];
        if (items.isEmpty) {
          return const SizedBox.shrink();
        }
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 480, mainAxisExtent: 188, mainAxisSpacing: 4, crossAxisSpacing: 8),
          itemBuilder: (context, index) => HomePageCard(vip: true, model: items[index]),
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

    await Get.find<WalletController>().getUserMoney();
    _refreshController.refreshCompleted();
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
      final response = await http.get(Uri.parse('$serverURL/api/accounts/get-my-account/'), headers: <String, String>{HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8', HttpHeaders.authorizationHeader: 'Bearer $token'});
      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        final responseJson = json.decode(decoded);
        final bool blocked = responseJson['blocked'] ?? false;

        if (blocked == true) {
          if (!mounted) {
            return null;
          }
          // The reason and a live countdown; when the time is up the player continues and the server is asked again.
          final continued = await showBlockedDialog(context, ban: BanInfo.fromJson(responseJson));
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
        appBar: const MyAppBar(fontSize: 0, backArrow: false, iconRemove: false, icon: NotificationBell(), name: appName, elevationWhite: false),
        body: Stack(
          children: [
            SmartRefresher(
              footer: footer(),
              controller: _refreshController,
              onRefresh: _onRefresh,
              enablePullDown: true,
              enablePullUp: false,
              physics: const BouncingScrollPhysics(),
              header: appRefreshHeader(),
              child: ListView(
                children: [
                  HomeBanner(future: _futureBanners),
                  if (showPage == false) ...[const HomeBalanceCard(), const HomeSections()],
                  const SizedBox(height: 10),
                  listViewName('homeVipAccounts'.tr, true, size, vipOnly: true),
                  _vipSection(),
                ],
              ),
            ),
            // Placed by hand: the Scaffold FAB slot did not land at the corner here.
            const Positioned(right: 16, bottom: 16, child: SupportChatButton(floating: true)),
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
