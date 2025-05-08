import 'package:flutter/scheduler.dart';
import 'package:game_app/controllers/show_all_account_controller.dart';
import 'package:game_app/models/home_page_model.dart';
import 'package:game_app/views/constants/dialogs.dart';
import 'package:game_app/views/constants/index.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../cards/show_all_accounts_card.dart';

class ShowAllAccounts extends StatefulWidget {
  final String name;
  const ShowAllAccounts({
    required this.name,
    super.key,
  });

  @override
  State<ShowAllAccounts> createState() => _ShowAllAccountsState();
}

class _ShowAllAccountsState extends State<ShowAllAccounts> {
  final ShowAllAccountsController controller = Get.put(ShowAllAccountsController());
  String name = 'selectCitySubtitle';
  int value = 0;

  final TextEditingController _controller = TextEditingController();
  final TextEditingController _controller1 = TextEditingController();
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();

    name = 'selectCitySubtitle';
    value = 0;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      // Bu kod birinji kadr çekilenden soň işlär
      if (mounted) {
        // Widgetyň entek agaçda bardygyny barlaň
        controller.clearData();
        controller.fetchPosts(DANGEROUS_clearList: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _controller1.dispose();
    _refreshController.dispose();

    super.dispose();
  }

  Row leftSideAppBar() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () {
            defaultBottomSheet(
              name: 'sort'.tr,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: sortData.length,
                itemBuilder: (context, index) {
                  return RadioListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    value: index,
                    tileColor: kPrimaryColorBlack,
                    selectedTileColor: kPrimaryColorBlack,
                    activeColor: kPrimaryColor,
                    groupValue: value,
                    onChanged: (ind) {
                      setState(() {
                        value = int.parse(ind.toString());
                      });
                      controller.sortName.value = sortData[index]['sort_column'];
                      controller.sortType.value = sortData[index]['sort_direction'];
                      controller.clearAndFetch();
                      Get.back();
                    },
                    title: Text(
                      "${sortData[index]["name"]}".tr,
                      style: const TextStyle(color: Colors.white, fontFamily: josefinSansMedium),
                    ),
                  );
                },
              ),
            );
          },
          icon: const Icon(
            IconlyLight.filter,
            color: Colors.white,
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        GestureDetector(
          onTap: () {
            defaultBottomSheet(
              name: 'Filter'.tr,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Wrap(
                  children: [
                    selectCity(),
                    customDivider(),
                    twoTextEditingField(controller1: _controller, controller2: _controller1),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: AgreeButton(
                        name: 'agree',
                        onTap: () {
                          controller.sortNamePrice.value = _controller.text.isNotEmpty ? 'min' : '';
                          controller.sortTypePrice.value = _controller.text;
                          controller.sortNamePriceMax.value = _controller1.text.isNotEmpty ? 'max' : '';
                          controller.sortTypePriceMax.value = _controller1.text;
                          controller.clearAndFetch();
                          Get.back();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          child: const Icon(
            IconlyLight.filter2,
            color: Colors.white,
            size: 30,
          ),
        ),
      ],
    );
  }

  Widget twoTextEditingField({required TextEditingController controller1, required TextEditingController controller2}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 25, bottom: 20),
            child: Text('priceRange'.tr, style: const TextStyle(fontFamily: josefinSansSemiBold, fontSize: 19, color: Colors.white)),
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  style: const TextStyle(fontFamily: josefinSansMedium, fontSize: 18),
                  cursorColor: kPrimaryColor,
                  controller: controller1,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(9),
                  ],
                  decoration: InputDecoration(
                    suffixIcon: const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Text('TMT', textAlign: TextAlign.center, style: TextStyle(fontFamily: josefinSansSemiBold, fontSize: 14, color: Colors.grey)),
                    ),
                    suffixIconConstraints: const BoxConstraints(minHeight: 15),
                    isDense: true,
                    hintText: 'minPrice'.tr,
                    hintStyle: const TextStyle(fontFamily: josefinSansMedium, fontSize: 16, color: Colors.white),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: borderRadius15,
                      borderSide: BorderSide(color: kPrimaryColor, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: borderRadius15,
                      borderSide: BorderSide(color: Colors.grey.shade200, width: 2),
                    ),
                  ),
                ),
              ),
              Container(
                width: 15,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                height: 2,
                color: Colors.grey,
              ),
              Expanded(
                child: TextFormField(
                  style: const TextStyle(fontFamily: josefinSansMedium, fontSize: 18),
                  cursorColor: kPrimaryColor,
                  controller: controller2,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(9),
                  ],
                  decoration: InputDecoration(
                    suffixIcon: const Padding(padding: EdgeInsets.only(right: 8), child: Text('TMT', textAlign: TextAlign.center, style: TextStyle(fontFamily: josefinSansSemiBold, fontSize: 14, color: Colors.grey))),
                    suffixIconConstraints: const BoxConstraints(minHeight: 15),
                    isDense: true,
                    hintText: 'maxPrice'.tr,
                    hintStyle: const TextStyle(fontFamily: josefinSansMedium, fontSize: 16, color: Colors.white),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: borderRadius15,
                      borderSide: BorderSide(color: kPrimaryColor, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: borderRadius15,
                      borderSide: BorderSide(color: Colors.grey.shade200, width: 2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Padding selectCity() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('selectCityTitle'.tr, style: const TextStyle(color: Colors.grey, fontFamily: josefinSansSemiBold, fontSize: 14)),
            Text(name.tr, style: const TextStyle(color: Colors.white, fontFamily: josefinSansSemiBold, fontSize: 18)),
          ],
        ),
        leading: const Icon(
          IconlyLight.location,
          size: 30,
        ),
        trailing: const Icon(IconlyLight.arrowRightCircle),
        onTap: () {
          Get.defaultDialog(
            title: 'selectCityTitle'.tr,
            titleStyle: const TextStyle(color: Colors.white, fontFamily: josefinSansSemiBold),
            radius: 5,
            backgroundColor: kPrimaryColorBlack,
            titlePadding: const EdgeInsets.symmetric(vertical: 20),
            contentPadding: EdgeInsets.zero,
            content: FutureBuilder<List<Cities>>(
              future: Cities().getCities(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: spinKit());
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text('Error'),
                  );
                } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No cities found'),
                  );
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    snapshot.data!.length,
                    (index) => Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      alignment: WrapAlignment.center,
                      children: [
                        customDivider(),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              name = (Get.locale?.languageCode == 'tr' ? snapshot.data![index].name_tm : snapshot.data![index].name_ru)!;
                            });
                            controller.sortCityName.value = 'city';
                            controller.sortCityType.value = snapshot.data![index].id.toString();
                            controller.clearAndFetch();
                            Get.back();
                            Get.back();
                          },
                          child: Text(
                            Get.locale?.languageCode == 'tr' ? snapshot.data![index].name_tm.toString() : snapshot.data![index].name_ru.toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontFamily: josefinSansSemiBold, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _onRefresh() async {
    setState(() {
      value = 0;
    });

    controller.clearData();
    await controller.fetchPosts(DANGEROUS_clearList: true);
    _refreshController.refreshCompleted();

    if (controller.list.length < 10 && controller.list.isNotEmpty) {
      _refreshController.loadNoData();
    } else {
      _refreshController.resetNoData();
    }
  }

  void _onLoading() async {
    controller.pageNumber.value += 1;
    final int oldListLength = controller.list.length;
    await controller.fetchPosts(DANGEROUS_clearList: false);
    if (controller.list.length > oldListLength) {
      _refreshController.loadComplete();
    } else {
      _refreshController.loadNoData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        backgroundColor: kPrimaryColorBlack,
        appBar: MyAppBar(fontSize: 20.0, backArrow: true, iconRemove: false, icon: leftSideAppBar(), name: widget.name.tr, elevationWhite: true),
        body: Obx(() {
          if (controller.isLoading.value && controller.list.isEmpty) {
            return Center(child: spinKit());
          } else if (controller.list.isEmpty && !controller.isLoading.value) {
            return emptyData();
          }
          return SmartRefresher(
            footer: footer(),
            controller: _refreshController,
            onRefresh: _onRefresh,
            onLoading: _onLoading,
            enablePullDown: true,
            enablePullUp: controller.list.isNotEmpty,
            physics: const BouncingScrollPhysics(),
            header: const MaterialClassicHeader(
              color: kPrimaryColor,
            ),
            child: GridView.builder(
              itemCount: controller.list.length,
              shrinkWrap: false,
              padding: const EdgeInsets.all(8.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: size.width >= 800 ? 3 : 2,
                mainAxisSpacing: 10,
                childAspectRatio: size.width >= 800 ? 3 / 4 : 2 / 3,
                crossAxisSpacing: 10,
              ),
              itemBuilder: (BuildContext context, int index) {
                return ShowAllProductsCard(
                  fav: false,
                  model: controller.list[index],
                );
              },
            ),
          );
        }),
      ),
    );
  }

  final List<Map<String, dynamic>> sortData = [
    {'name': 'Newest', 'sort_column': 'created_at', 'sort_direction': 'desc'},
    {'name': 'Oldest', 'sort_column': 'created_at', 'sort_direction': 'asc'},
    {'name': 'Price: Low to High', 'sort_column': 'price', 'sort_direction': 'asc'},
    {'name': 'Price: High to Low', 'sort_column': 'price', 'sort_direction': 'desc'},
  ];

  CustomFooter footer() {
    return CustomFooter(
      builder: (BuildContext context, LoadStatus? mode) {
        Widget body;
        if (mode == LoadStatus.idle) {
          body = Text('Dowamyny ýüklemek üçin ýokary çekiň'.tr);
        } else if (mode == LoadStatus.loading) {
          body = const CircularProgressIndicator(color: kPrimaryColor);
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
