import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart' show AssetManifest, rootBundle;

import 'constants.dart';

/// The pack pictures bundled in `assets/image/<amount>.webp` (60, 325, 660 …),
/// found by scanning the asset list, so a new picture needs no code change.
class UcAssets {
  const UcAssets._();

  static Map<String, String>? _byAmount;
  static Future<void>? _loading;

  static bool get isLoaded => _byAmount != null;

  static Future<void> load() {
    return _loading ??= () async {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final found = <String, String>{};
      // The numbered `.png` files in the folder are other pictures; only `.webp` counts.
      final pattern = RegExp(r'^assets/image/(\d+)\.webp$');
      for (final path in manifest.listAssets()) {
        final match = pattern.firstMatch(path);
        if (match != null) {
          found[match.group(1)!] = path;
        }
      }
      _byAmount = found;
    }();
  }

  /// The asset of the first number in [name] that has a picture: "660 UC",
  /// "UC 660" and "1 800 UC" all find theirs.
  static String? assetFor(String? name) {
    final assets = _byAmount;
    if (name == null || assets == null || assets.isEmpty) {
      return null;
    }
    // "1 800" / "1,800" → "1800", so a grouped amount is one number.
    final text = name.replaceAllMapped(RegExp(r'(\d)[\s,.](?=\d{3}\b)'), (m) => m.group(1)!);
    for (final match in RegExp(r'\d+').allMatches(text)) {
      final path = assets[match.group(0)];
      if (path != null) {
        return path;
      }
    }
    return null;
  }
}

/// The picture of a bought UC: the bundled pack image of its amount, else the
/// one the API sends, else a gold "UC" mark.
class UcPicture extends StatefulWidget {
  const UcPicture({this.name, this.image, super.key});

  final String? name;
  final String? image;

  @override
  State<UcPicture> createState() => _UcPictureState();
}

class _UcPictureState extends State<UcPicture> {
  static const _gold = Color(0xFFFFC83D);

  @override
  void initState() {
    super.initState();
    if (!UcAssets.isLoaded) {
      UcAssets.load().then((_) {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  Widget _mark() => const Center(
    child: Text(
      'UC',
      style: TextStyle(color: _gold, fontFamily: gilroyBold, fontSize: 22),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final asset = UcAssets.assetFor(widget.name);
    if (asset != null) {
      return Image.asset(asset, fit: BoxFit.contain, cacheWidth: 240, filterQuality: FilterQuality.medium, errorBuilder: (context, error, stack) => _mark());
    }
    final image = widget.image;
    if (image != null && image.isNotEmpty && image != 'null') {
      return CachedNetworkImage(imageUrl: image.startsWith('http') ? image : '$serverURL$image', fit: BoxFit.contain, fadeInCurve: Curves.ease, placeholder: (context, url) => const SizedBox.shrink(), errorWidget: (context, url, error) => _mark());
    }
    return _mark();
  }
}
