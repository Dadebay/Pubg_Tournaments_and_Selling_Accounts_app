import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:game_app/repository/ucdayy_api.dart';
import 'package:game_app/views/constants/catalog_empty_state.dart';
import 'package:game_app/views/constants/centered_header.dart';
import 'package:game_app/views/constants/constants.dart';
import 'package:game_app/views/constants/shimmer.dart';
import 'package:get/get.dart';

enum LegalKind { terms, privacy }

/// The terms of use or the privacy policy as a page, read from the `/about/` API.
class LegalPage extends StatefulWidget {
  const LegalPage({required this.kind, super.key});

  final LegalKind kind;

  @override
  State<LegalPage> createState() => _LegalPageState();
}

class _LegalPageState extends State<LegalPage> {
  late Future<String?> _future = _load();

  bool get _isTerms => widget.kind == LegalKind.terms;

  Future<String?> _load() async {
    if (_isTerms) {
      // The terms live in the constants when the server has them there;
      // otherwise the privacy policy is the document that covers the use of the app.
      final consts = await UcdayyApi.getConsts();
      final text = consts.ok ? _pickText(consts.data, const ['terms', 'terms_of_use', 'user_agreement', 'agreement', 'rules']) : null;
      if (text != null) {
        return text;
      }
    }
    final privacy = await UcdayyApi.getPrivacy();
    return privacy.ok ? _pickText(privacy.data, const ['privacy', 'text', 'content', 'body']) : null;
  }

  /// A text out of `{ key_tm / key_ru / key }`, a list of such maps or a plain string.
  String? _pickText(dynamic data, List<String> keys) {
    if (data is String) {
      return data.isEmpty ? null : data;
    }
    final items = apiItems(data);
    final map = items.isNotEmpty ? items.first : (data is Map ? data : null);
    if (map == null) {
      return null;
    }
    final lang = Get.locale?.languageCode == 'ru' ? 'ru' : 'tm';
    for (final key in keys) {
      for (final name in ['${key}_$lang', key]) {
        final value = map[name];
        if (value is String && value.trim().isNotEmpty) {
          return value;
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColorBlack,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            CenteredHeader(title: (_isTerms ? 'termsOfUse' : 'privacy').tr, onBack: Get.back),
            Expanded(
              child: FutureBuilder<String?>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Shimmer(
                      child: ListView(
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        children: [for (var i = 0; i < 6; i++) ...const [ShimmerBlock(height: 18, radius: 9), SizedBox(height: 12)]],
                      ),
                    );
                  }
                  final text = snapshot.data;
                  if (text == null) {
                    return Center(
                      child: CatalogEmptyState(
                        icon: Icons.description_outlined,
                        title: 'legalNotFound'.tr,
                        description: '',
                        actionLabel: 'premiumRetry'.tr,
                        actionIcon: Icons.refresh_rounded,
                        onAction: () => setState(() => _future = _load()),
                      ),
                    );
                  }
                  return ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
                          color: const Color(0xFF1B1B1E),
                        ),
                        child: Html(
                          data: text,
                          style: {'body': Style(color: Colors.white70, fontFamily: gilroyRegular, fontSize: FontSize(16), lineHeight: const LineHeight(1.45))},
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
