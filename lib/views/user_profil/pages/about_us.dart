// ignore_for_file: file_names, deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:game_app/models/user_models/abous_us_model.dart';
import 'package:game_app/views/constants/app_bar.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/constants.dart';
import '../../constants/widgets.dart';

class AboutUs extends StatefulWidget {
  const AboutUs({super.key});

  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  late Future<List<AboutUsModel>> _future = AboutUsModel().getAboutUs();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColorBlack,
      appBar: const MyAppBar(backArrow: true, iconRemove: true, elevationWhite: true, name: 'aboutUs', fontSize: 0.0, dividerOpacity: 0.4),
      body: FutureBuilder<List<AboutUsModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: spinKit());
          } else if (snapshot.hasError) {
            return errorData(
              onTap: () => setState(() => _future = AboutUsModel().getAboutUs()),
            );
          } else if (snapshot.data == null) {
            return emptyData();
          }
          final items = snapshot.data!;
          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
            children: [
              _header(),
              const SizedBox(height: 28),
              Text(
                'contactInformation'.tr,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontFamily: gilroySemiBold, fontSize: 14),
              ),
              const SizedBox(height: 10),
              _list(items),
            ],
          );
        },
      ),
    );
  }

  /// The app's logo, name and version, centred on the plain background.
  Widget _header() {
    return Column(
      children: [
        SizedBox(
          width: 72,
          height: 72,
          child: Image.asset(
            'assets/image/logo.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stack) => const HugeIcon(icon: HugeIcons.strokeRoundedGameController01, color: kPrimaryColor, size: 40),
          ),
        ),
        const SizedBox(height: 12),
        const Text('UC Dayy', style: TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 24)),
        const SizedBox(height: 2),
        Text('1.0.1', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontFamily: gilroyMedium, fontSize: 14)),
      ],
    );
  }

  /// One flat card holding every contact as a row, with thin dividers.
  Widget _list(List<AboutUsModel> items) {
    return Container(
      decoration: BoxDecoration(color: kPrimaryColorBlack1, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) Divider(height: 1, thickness: 1, indent: 68, color: Colors.white.withValues(alpha: 0.06)),
            _row(items[i]),
          ],
        ],
      ),
    );
  }

  Widget _row(AboutUsModel item) {
    final name = item.name ?? '';
    final link = item.link ?? '';
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => handleLink(link),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            SizedBox(width: 36, child: Center(child: _logo(item, 28))),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontFamily: gilroySemiBold, fontSize: 16)),
                  const SizedBox(height: 2),
                  Text(_subtitle(link), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontFamily: gilroyMedium, fontSize: 13)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.35), size: 22),
          ],
        ),
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

  /// The link without its scheme, for the small line under the contact name.
  String _subtitle(String link) {
    return link.replaceFirst(RegExp(r'^(https?://|tel:|mailto:)'), '').replaceFirst(RegExp(r'^www\.'), '').replaceFirst(RegExp(r'/$'), '');
  }

  bool _isPhone(String name, String link) {
    final key = '${name.toLowerCase()} ${link.toLowerCase()}';
    return link.startsWith('+') || link.startsWith('tel:') || key.contains('telefon') || key.contains('phone');
  }

  Widget _logo(AboutUsModel item, double size) {
    final name = item.name ?? '';
    final link = item.link ?? '';
    final brand = _brandAsset(name, link);
    if (brand != null) {
      return SvgPicture.asset(brand, width: size, height: size, fit: BoxFit.contain);
    }
    if (_isPhone(name, link)) {
      return HugeIcon(icon: HugeIcons.strokeRoundedCall02, color: kPrimaryColor, size: size);
    }
    return CachedNetworkImage(
      imageUrl: '$serverURL${item.icon}',
      width: size,
      height: size,
      fit: BoxFit.contain,
      placeholder: (context, url) => const SizedBox.shrink(),
      errorWidget: (context, url, error) => HugeIcon(icon: HugeIcons.strokeRoundedLink01, color: kPrimaryColor, size: size),
    );
  }

  Future<void> handleLink(String link) async {
    final Uri uri;
    if (link.startsWith('+') || link.startsWith('tel:')) {
      uri = Uri(scheme: 'tel', path: link.startsWith('tel:') ? link.substring(4) : link);
    } else {
      uri = Uri.parse(link);
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      showSnackBar('tournamentInfo14', 'errorLoadEmptyData', Colors.red);
    }
  }
}
