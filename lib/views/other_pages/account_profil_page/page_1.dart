import 'package:game_app/views/constants/index.dart';

import '../../../models/get_posts_model.dart';

const _gold = Color(0xFFFFC83D);

/// The info of an account: only its description, laid out line by line. A line with
/// `name: value` becomes a label and a value, any other line gets a gold bullet and
/// blank lines are gaps, so a long list reads like the post it came from.
class TabbarPage1 extends StatelessWidget {
  final GetPostsAccountModel model;

  const TabbarPage1({required this.model, super.key});

  @override
  Widget build(BuildContext context) {
    final lines = (model.desc ?? '').replaceAll('\r', '').split('\n');
    final rows = <Widget>[];
    for (final raw in lines) {
      final line = raw.trim();
      if (line.isEmpty) {
        if (rows.isNotEmpty) {
          rows.add(const SizedBox(height: 10));
        }
        continue;
      }
      final split = RegExp(r'^([^:：]{2,28})\s*[:：]\s*(.+)$').firstMatch(line);
      if (split != null) {
        rows.add(_pair(split.group(1)!.trim(), split.group(2)!.trim()));
      } else {
        rows.add(_bullet(line.replaceFirst(RegExp(r'^[-•*▪●◆➤>\s]+'), '')));
      }
    }
    // The basics first, so the section is never nearly empty: account name, id and the date.
    final created = model.createdAt ?? '';
    final basics = <Widget>[
      if ((model.pubgUserName ?? '').trim().isNotEmpty && model.pubgUserName != 'null') _pair('accountSaleName'.tr, model.pubgUserName!.trim()),
      if ((model.pubgID ?? '').trim().isNotEmpty && '${model.pubgID}' != 'null') _pair('accountSaleId'.tr, '${model.pubgID}'.trim()),
      if (created.length >= 10) _pair('accountDetaile6'.tr.replaceAll(':', '').trim(), created.substring(0, 10)),
    ];
    return ListView(
      physics: const BouncingScrollPhysics(),
      // Room for the buy bar that sits over the bottom of the page.
      padding: EdgeInsets.fromLTRB(16, 14, 16, 130 + MediaQuery.paddingOf(context).bottom),
      children: [
        if (rows.isNotEmpty || basics.isNotEmpty)
          Container(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: const Color(0xFF1B1B1E),
              border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 18,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), color: _gold),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'accountInfo'.tr,
                      style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 19),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ...basics,
                if (basics.isNotEmpty && rows.isNotEmpty) ...[const SizedBox(height: 4), Container(height: 1, color: _gold.withValues(alpha: 0.2)), const SizedBox(height: 14)],
                ...rows,
              ],
            ),
          ),
      ],
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 7,
            height: 7,
            margin: const EdgeInsets.only(top: 8, right: 12),
            decoration: const BoxDecoration(shape: BoxShape.circle, color: _gold),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Color(0xFFE6E6EA), fontFamily: gilroyMedium, fontSize: 16, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pair(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: Colors.white.withValues(alpha: 0.05)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF9A9AA3), fontFamily: gilroyMedium, fontSize: 15, height: 1.25),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 16, height: 1.25),
            ),
          ),
        ],
      ),
    );
  }
}
