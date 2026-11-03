// ignore_for_file: use_key_in_widget_constructors

import 'package:game_app/controllers/notification_badge_controller.dart';
import 'package:game_app/controllers/settings_controller.dart';
import 'package:game_app/views/constants/index.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../models/notifications_model.dart';

class NotificationPage extends StatefulWidget {
  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final SettingsController controller = Get.put(SettingsController());
  final NotificationBadgeController _badge = Get.isRegistered<NotificationBadgeController>() ? Get.find<NotificationBadgeController>() : Get.put(NotificationBadgeController(), permanent: true);

  /// The newest notification seen before this visit; anything above it is new here.
  late final int _seenBefore = _badge.lastSeenId;
  late Future<List<NotifcationModel>> _future = _load();

  /// Loads the list and counts it all as seen.
  Future<List<NotifcationModel>> _load() async {
    final items = await NotifcationModel().getNotifcations();
    await _badge.markSeen(items);
    return items;
  }

  static const _gold = Color(0xFFFFC83D);

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColorBlack,
      appBar: const MyAppBar(fontSize: 18.0, backArrow: true, iconRemove: true, name: 'notification', elevationWhite: true),
      body: FutureBuilder<List<NotifcationModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: spinKit());
          } else if (snapshot.hasError) {
            return errorData(onTap: _refresh);
          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
            return noBannerImage();
          }
          final items = snapshot.data!;
          return RefreshIndicator(
            color: _gold,
            backgroundColor: kPrimaryColorBlack,
            onRefresh: _refresh,
            child: ListView.builder(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: items.length,
              itemBuilder: (context, index) => _NotificationCard(model: items[index], isNew: (items[index].id ?? 0) > _seenBefore),
            ),
          );
        },
      ),
    );
  }
}

/// One notification: bell tile, title, date and a body that unfolds on tap.
class _NotificationCard extends StatefulWidget {
  const _NotificationCard({required this.model, required this.isNew});

  final NotifcationModel model;
  final bool isNew;

  @override
  State<_NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<_NotificationCard> {
  static const _gold = Color(0xFFFFC83D);
  bool _open = false;

  /// `dd.MM.yyyy  HH:mm` from the API's ISO date, or the raw text if it does not parse.
  String get _date {
    final raw = widget.model.createdAt;
    if (raw == null || raw.isEmpty) {
      return '';
    }
    final date = DateTime.tryParse(raw)?.toLocal();
    if (date == null) {
      return raw;
    }
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(date.day)}.${two(date.month)}.${date.year}  ${two(date.hour)}:${two(date.minute)}';
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      showSnackBar('tournamentInfo14', 'errorLoadEmptyData', Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = widget.model;
    final content = model.content ?? '';
    final url = model.url ?? '';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF232327), Color(0xFF151517)]),
            border: Border.all(color: _open || widget.isNew ? _gold.withValues(alpha: widget.isNew ? 0.55 : 0.4) : Colors.white.withValues(alpha: 0.07)),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => setState(() => _open = !_open),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(color: _gold.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(14)),
                    child: const Center(child: HugeIcon(icon: HugeIcons.strokeRoundedNotification03, color: _gold, size: 24)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(child: Text(model.title ?? '', style: const TextStyle(color: Colors.white, fontFamily: gilroySemiBold, fontSize: 17))),
                            if (widget.isNew) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(color: _gold, borderRadius: BorderRadius.circular(8)),
                                child: Text('newLabel'.tr, style: const TextStyle(color: Colors.black, fontFamily: gilroyBold, fontSize: 10.5, height: 1.1)),
                              ),
                            ],
                          ],
                        ),
                        if (_date.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(_date, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontFamily: gilroyRegular, fontSize: 13)),
                        ],
                        AnimatedSize(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  content,
                                  maxLines: _open ? null : 2,
                                  overflow: _open ? TextOverflow.visible : TextOverflow.ellipsis,
                                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontFamily: gilroyMedium, fontSize: 15, height: 1.35),
                                ),
                                if (_open && url.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  GestureDetector(
                                    onTap: () => _openUrl(url),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(color: _gold, borderRadius: BorderRadius.circular(12)),
                                      child: const Text('Link', style: TextStyle(color: Colors.black, fontFamily: gilroySemiBold, fontSize: 14)),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(Icons.keyboard_arrow_down_rounded, color: _gold),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
