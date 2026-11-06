// ignore_for_file: prefer_const_constructors, file_names, use_key_in_widget_constructors, avoid_implementing_value_types

import 'package:game_app/views/constants/index.dart';

class MyAppBar extends StatelessWidget implements PreferredSize {
  final bool backArrow;
  final bool elevationWhite;
  final double? fontSize;
  final Widget? icon;

  /// Shown on the left when there is no back arrow.
  final Widget? leadingIcon;
  final bool iconRemove;
  final String name;
  final double dividerOpacity;

  const MyAppBar({
    required this.fontSize,
    required this.backArrow,
    required this.iconRemove,
    required this.name,
    required this.elevationWhite,
    this.icon,
    this.leadingIcon,
    this.dividerOpacity = 1.0,
    super.key,
  });

  @override
  Widget get child => Text('ad');

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    final double sizeWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        AppBar(
          systemOverlayStyle: const SystemUiOverlayStyle(statusBarColor: kPrimaryColorBlack, statusBarIconBrightness: Brightness.dark),
          elevation: 0,
          scrolledUnderElevation: 0.0,
          centerTitle: true,
          leadingWidth: 60,
          leading: backArrow
              ? IconButton(
                  icon: Icon(
                    IconlyLight.arrowLeftCircle,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Get.back();
                  },
                )
              : (leadingIcon ?? SizedBox.shrink()),
          actions: [
            if (iconRemove)
              SizedBox.shrink()
            else
              Padding(
                padding: const EdgeInsets.only(right: 5),
                child: icon,
              ),
          ],
          automaticallyImplyLeading: false,
          backgroundColor: kPrimaryColorBlack,
          title: Text(
            name.tr,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontFamily: gilroySemiBold,
              fontSize: fontSize == 0.0
                  ? sizeWidth > 800
                      ? 35
                      : 25
                  : fontSize,
            ),
          ),
        ),
        elevationWhite ? Opacity(opacity: dividerOpacity, child: customDivider()) : SizedBox.shrink(),
      ],
    );
  }
}

class MyAppBarNew extends StatelessWidget implements PreferredSize {
  final bool backArrow;
  final bool elevationWhite;
  final double? fontSize;
  final Widget? icon;
  final bool iconRemove;
  final String name;

  const MyAppBarNew({
    required this.fontSize,
    required this.backArrow,
    required this.iconRemove,
    required this.name,
    required this.elevationWhite,
    this.icon,
    super.key,
  });

  @override
  Widget get child => Text('ad');

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    final double sizeWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        AppBar(
          elevation: 0,
          centerTitle: true,
          leadingWidth: 60,
          leading: backArrow
              ? IconButton(
                  icon: Icon(
                    IconlyLight.arrowLeftCircle,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              : SizedBox.shrink(),
          actions: [
            if (iconRemove)
              SizedBox.shrink()
            else
              Padding(
                padding: const EdgeInsets.only(right: 5),
                child: icon,
              ),
          ],
          automaticallyImplyLeading: false,
          backgroundColor: kPrimaryColorBlack,
          title: Text(
            name.tr,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontFamily: gilroySemiBold,
              fontSize: fontSize == 0.0
                  ? sizeWidth > 800
                      ? 35
                      : 25
                  : fontSize,
            ),
          ),
        ),
        elevationWhite ? customDivider() : SizedBox.shrink(),
      ],
    );
  }
}
