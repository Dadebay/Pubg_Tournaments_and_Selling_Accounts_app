import 'package:material_ui/material_ui.dart';
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

class _LegalDoc {
  const _LegalDoc({required this.title, required this.body});

  final String? title;
  final String body;
}

class _LegalPageState extends State<LegalPage> {
  static const _gold = Color(0xFFFFC83D);

  late Future<_LegalDoc?> _future = _load();

  bool get _isTerms => widget.kind == LegalKind.terms;

  Future<_LegalDoc?> _load() async {
    if (_isTerms) {
      final terms = await UcdayyApi.getTerms();
      final doc = terms.ok ? _pickDoc(terms.data, const ['content', 'text', 'body']) : null;
      if (doc != null) {
        return doc;
      }
      // The endpoint exists but the admin has not written the text yet: show the empty state.
      if (terms.ok) {
        return null;
      }
      // The terms live in the constants when the server has them there;
      // otherwise the privacy policy is the document that covers the use of the app.
      final consts = await UcdayyApi.getConsts();
      final fromConsts = consts.ok ? _pickDoc(consts.data, const ['terms', 'terms_of_use', 'user_agreement', 'agreement', 'rules']) : null;
      if (fromConsts != null) {
        return fromConsts;
      }
    }
    final privacy = await UcdayyApi.getPrivacy();
    return privacy.ok ? _pickDoc(privacy.data, const ['privacy', 'text', 'content', 'body']) : null;
  }

  /// A document out of `{ title_tm / title_ru, key_tm / key_ru / key }`, a list of such maps or a plain string.
  _LegalDoc? _pickDoc(dynamic data, List<String> keys) {
    if (data is String) {
      return data.trim().isEmpty ? null : _LegalDoc(title: null, body: data);
    }
    final items = apiItems(data);
    final map = items.isNotEmpty ? items.first : (data is Map ? data : null);
    if (map == null) {
      return null;
    }
    final lang = Get.locale?.languageCode == 'ru' ? 'ru' : 'tm';
    String? read(List<String> names) {
      for (final key in names) {
        for (final name in ['${key}_$lang', key]) {
          final value = map[name];
          if (value is String && value.trim().isNotEmpty) {
            return value.trim();
          }
        }
      }
      return null;
    }

    final body = read(keys);
    return body == null ? null : _LegalDoc(title: read(const ['title']), body: body);
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
              child: FutureBuilder<_LegalDoc?>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Shimmer(
                      child: ListView(
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        children: [
                          const ShimmerBlock(height: 110, radius: 24),
                          const SizedBox(height: 16),
                          for (var i = 0; i < 6; i++) ...const [ShimmerBlock(height: 18, radius: 9), SizedBox(height: 12)],
                        ],
                      ),
                    );
                  }
                  final doc = snapshot.data;
                  if (doc == null) {
                    return Center(
                      child: CatalogEmptyState(
                        icon: Icons.description_outlined,
                        title: 'legalNotFound'.tr,
                        description: '',
                        actionLabel: 'premiumRetry'.tr,
                        actionIcon: Icons.refresh_rounded,
                        onAction: () {
                          setState(() {
                            _future = _load();
                          });
                        },
                      ),
                    );
                  }
                  return _document(doc);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static final _htmlTag = RegExp(r'<\s*(p|div|h[1-6]|ul|ol|li|br|strong|b|span|a)[\s>/]', caseSensitive: false);
  static final _updated = RegExp(r'^(soňky täzelenen sene|дата последнего обновления|last updated)\s*:\s*(.+)$', caseSensitive: false);
  static final _heading = RegExp(r'^(\d+)[.)]\s+(.+)$');
  static final _bullet = RegExp(r'^[•·\-\*]\s*(.+)$');

  Widget _document(_LegalDoc doc) {
    final title = doc.title ?? (_isTerms ? 'termsOfUse' : 'privacy').tr;
    if (_htmlTag.hasMatch(doc.body)) {
      return ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
        children: [
          _hero(title, null),
          const SizedBox(height: 16),
          _card(
            Html(
              data: doc.body,
              style: {'body': Style(margin: Margins.zero, color: Colors.white70, fontFamily: gilroyRegular, fontSize: FontSize(16), lineHeight: const LineHeight(1.5))},
            ),
          ),
        ],
      );
    }
    final parsed = _parse(doc.body);
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
      children: [
        _hero(title, parsed.updated),
        if (parsed.intro.isNotEmpty) ...[
          const SizedBox(height: 16),
          _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [for (final line in parsed.intro) line.isBullet ? _bulletRow(line.text) : _paragraph(line.text)])),
        ],
        for (final section in parsed.sections) ...[const SizedBox(height: 14), _section(section)],
      ],
    );
  }

  _Parsed _parse(String body) {
    final lines = body.replaceAll('\r\n', '\n').split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty);
    String? updated;
    final intro = <_Line>[];
    final sections = <_Section>[];
    for (final line in lines) {
      final date = _updated.firstMatch(line);
      if (date != null && updated == null && sections.isEmpty) {
        updated = date.group(2)!.trim();
        continue;
      }
      final heading = _heading.firstMatch(line);
      if (heading != null && !_bullet.hasMatch(line) && heading.group(2)!.length <= 90 && !heading.group(2)!.endsWith('.')) {
        sections.add(_Section(number: heading.group(1)!, title: heading.group(2)!, lines: []));
        continue;
      }
      final bullet = _bullet.firstMatch(line);
      final item = _Line(bullet == null ? line : bullet.group(1)!.trim(), isBullet: bullet != null);
      (sections.isEmpty ? intro : sections.last.lines).add(item);
    }
    return _Parsed(updated: updated, intro: intro, sections: sections);
  }

  Widget _hero(String title, String? updated) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_gold.withValues(alpha: 0.2), const Color(0xFF151517)]),
        border: Border.all(color: _gold.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17),
              gradient: const LinearGradient(colors: [Color(0xFFFFD866), Color(0xFFFF9800)]),
            ),
            child: Icon(_isTerms ? Icons.description_rounded : Icons.shield_rounded, color: const Color(0xFF1A1200), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 21, height: 1.15),
                ),
                if (updated != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.update_rounded, size: 14, color: Colors.white.withValues(alpha: 0.6)),
                        const SizedBox(width: 5),
                        Text(
                          updated,
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontFamily: gilroySemiBold, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF232327), Color(0xFF151517)]),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: child,
    );
  }

  Widget _section(_Section section) {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: _gold.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(10)),
                child: Text(
                  section.number,
                  style: const TextStyle(color: _gold, fontFamily: gilroyBold, fontSize: 15),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    section.title,
                    style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 17, height: 1.2),
                  ),
                ),
              ),
            ],
          ),
          if (section.lines.isNotEmpty) const SizedBox(height: 12),
          for (final line in section.lines) line.isBullet ? _bulletRow(line.text) : _paragraph(line.text),
        ],
      ),
    );
  }

  Widget _paragraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(color: Colors.white.withValues(alpha: 0.78), fontFamily: gilroyMedium, fontSize: 15.5, height: 1.45),
      ),
    );
  }

  /// A bullet; a short "Label: text" start is set in bold.
  Widget _bulletRow(String text) {
    final split = text.indexOf(': ');
    final hasLabel = split >= 2 && split <= 40;
    final base = TextStyle(color: Colors.white.withValues(alpha: 0.78), fontFamily: gilroyMedium, fontSize: 15.5, height: 1.45);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 9, right: 12, left: 4),
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(color: _gold, shape: BoxShape.circle),
            ),
          ),
          Expanded(
            child: hasLabel
                ? Text.rich(
                    TextSpan(
                      style: base,
                      children: [
                        TextSpan(
                          text: '${text.substring(0, split)}: ',
                          style: const TextStyle(color: Colors.white, fontFamily: gilroySemiBold),
                        ),
                        TextSpan(text: text.substring(split + 2)),
                      ],
                    ),
                  )
                : Text(text, style: base),
          ),
        ],
      ),
    );
  }
}

class _Line {
  const _Line(this.text, {required this.isBullet});

  final String text;
  final bool isBullet;
}

class _Section {
  const _Section({required this.number, required this.title, required this.lines});

  final String number;
  final String title;
  final List<_Line> lines;
}

class _Parsed {
  const _Parsed({required this.updated, required this.intro, required this.sections});

  final String? updated;
  final List<_Line> intro;
  final List<_Section> sections;
}
