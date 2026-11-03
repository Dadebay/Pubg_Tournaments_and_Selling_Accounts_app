// ignore_for_file: file_names, deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:game_app/models/user_models/abous_us_model.dart';
import 'package:game_app/views/constants/app_bar.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/constants.dart';
import '../../constants/widgets.dart';

// import '../../constants/index.dart';

class AboutUs extends StatefulWidget {
  const AboutUs({super.key});

  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColorBlack,
      appBar: const MyAppBar(backArrow: true, iconRemove: true, elevationWhite: true, name: 'aboutUs', fontSize: 0.0),
      body: FutureBuilder<List<AboutUsModel>>(
        future: AboutUsModel().getAboutUs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: spinKit());
          } else if (snapshot.hasError) {
            return errorData(
              onTap: () {
                AboutUsModel().getAboutUs();
              },
            );
          } else if (snapshot.data == null) {
            return emptyData();
          }
          final items = snapshot.data!;
          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              _header(),
              const SizedBox(height: 24),
              Text(
                'contactInformation'.tr,
                style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 20),
              ),
              const SizedBox(height: 12),
              for (final item in items) _contactCard(brand: _brandAsset(item.name ?? '', item.link ?? ''), phone: _isPhone(item.name ?? '', item.link ?? ''), icon: '$serverURL${item.icon}', name: item.name!, onTap: () => handleLink(item.link!)),
            ],
          );
        },
      ),
    );
  }

  static const _gold = Color(0xFFFFC83D);

  /// The app's name on a navy card with a soft gold glow.
  Widget _header() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF2A2A2F), Color(0xFF151517)]),
        border: Border.all(color: _gold.withValues(alpha: 0.25)),
        boxShadow: [BoxShadow(color: _gold.withValues(alpha: 0.12), blurRadius: 30)],
      ),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.06),
              border: Border.all(color: _gold.withValues(alpha: 0.5), width: 1.5),
            ),
            child: Image.asset(
              'assets/image/logo.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stack) => const Icon(IconlyBold.game, color: _gold, size: 36),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'UC Dayy',
            style: TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 26),
          ),
          const SizedBox(height: 4),
          Text(
            '1.0.1',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontFamily: gilroyMedium, fontSize: 15),
          ),
        ],
      ),
    );
  }

  /// The brand's own logo, bundled with the app, for the contact kinds the
  /// server's pictures render badly; null for anything else.
  String? _brandAsset(String name, String link) {
    final key = '${name.toLowerCase()} ${link.toLowerCase()}';
    if (key.contains('telegram') || key.contains('t.me')) {
      return 'assets/icons/brands/telegram.svg';
    }
    if (key.contains('tiktok')) {
      return 'assets/icons/brands/tiktok.svg';
    }
    if (key.contains('instagram')) {
      return 'assets/icons/brands/instagram.svg';
    }
    if (key.contains('whatsapp') || key.contains('wa.me')) {
      return 'assets/icons/brands/whatsapp.svg';
    }
    return null;
  }

  bool _isPhone(String name, String link) {
    final key = '${name.toLowerCase()} ${link.toLowerCase()}';
    return link.startsWith('+') || link.startsWith('tel:') || key.contains('telefon') || key.contains('phone');
  }

  Widget _contactCard({required String icon, required String name, required VoidCallback onTap, String? brand, bool phone = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF232327), Color(0xFF151517)]),
            border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(14)),
                    child: brand != null
                        ? SvgPicture.asset(brand, fit: BoxFit.contain)
                        : phone
                        ? const HugeIcon(icon: HugeIcons.strokeRoundedCall02, color: _gold, size: 26)
                        : CachedNetworkImage(
                            imageUrl: icon,
                            fadeInCurve: Curves.ease,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => const SizedBox.shrink(),
                            errorWidget: (context, url, error) => const Icon(IconlyLight.call, color: _gold),
                          ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontFamily: gilroySemiBold, fontSize: 17, color: Colors.white),
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: _gold.withValues(alpha: 0.14)),
                    child: const Icon(IconlyLight.arrowRight2, color: _gold, size: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void handleLink(String link) async {
    final Uri uri;
    if (link.startsWith('+') || link.startsWith('tel:')) {
      uri = Uri(scheme: 'tel', path: link.startsWith('tel:') ? link.substring(4) : link);
    } else {
      uri = Uri.parse(link);
    }
    if (await canLaunch(uri.toString())) {
      await launch(uri.toString());
    } else {
      showSnackBar('tournamentInfo14', 'errorLoadEmptyData', Colors.red);
    }
  }
}
