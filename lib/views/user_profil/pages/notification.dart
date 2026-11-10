// ignore_for_file: use_key_in_widget_constructors

import 'dart:async';

import 'package:game_app/controllers/notification_badge_controller.dart';
import 'package:game_app/repository/ucdayy_api.dart';
import 'package:game_app/controllers/settings_controller.dart';
import 'package:game_app/views/constants/catalog_empty_state.dart';
import 'package:game_app/views/constants/index.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../models/notifications_model.dart';

/// The notifications. Opened from the home page (the bell) it lists only the ones this account
/// has not read ([onlyUnread]); the profile page shows all of them, read ones too.
class NotificationPage extends StatefulWidget {
  const NotificationPage({this.onlyUnread = false});

  final bool onlyUnread;

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final SettingsController controller = Get.put(SettingsController());
  final NotificationBadgeController _badge = Get.isRegistered<NotificationBadgeController>() ? Get.find<NotificationBadgeController>() : Get.put(NotificationBadgeController(), permanent: true);

  late final bool _onlyUnread = widget.onlyUnread;
  late Future<List<NotifcationModel>> _future = _load();
  List<NotifcationModel> _items = [];

  /// Loads the list (with this account's read state) and the badge number.
  Future<List<NotifcationModel>> _load() async {
    final all = await NotifcationModel().getNotifcations();
    // From the home page only unread ones are listed; a card opened now stays until the page is left.
    final items = _onlyUnread ? all.where((item) => !item.read).toList() : all;
    _items = items;
    unawaited(_badge.refreshCount());
    return items;
  }

  /// A notification was opened: the server marks it read for this account.
  Future<void> _opened(NotifcationModel model) async {
    if (model.read || model.id == null) {
      return;
    }
    setState(() => model.read = true);
    _badge.decrement();
    final result = await UcdayyApi.markNotificationRead(model.id!);
    if (!result.ok && result.statusCode != 401) {
      // The server did not take it: show it unread again.
      if (mounted) {
        setState(() => model.read = false);
      }
      unawaited(_badge.refreshCount());
    }
  }

  Future<void> _readAll() async {
    final result = await UcdayyApi.markAllNotificationsRead();
    if (!mounted) {
      return;
    }
    if (result.ok) {
      setState(() {
        for (final item in _items) {
          item.read = true;
        }
      });
      _badge.clear();
    }
  }

  bool get _hasUnread => _items.any((item) => !item.read);

  /// Leaving the page counts everything on it as seen: the server marks all read, so the
  /// "new" marks and the bell badge are gone when the player is back on the home page.
  @override
  void dispose() {
    if (_hasUnread) {
      _badge.clear();
      unawaited(UcdayyApi.markAllNotificationsRead());
    }
    super.dispose();
  }

  static const _gold = Color(0xFFFFC83D);

  /// "Read all": a small gold check button in the top bar, shown while something is unread.
  Widget _readAllButton() {
    return GestureDetector(
      onTap: _readAll,
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.only(right: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _gold.withValues(alpha: 0.14),
          border: Border.all(color: _gold.withValues(alpha: 0.5)),
        ),
        child: const HugeIcon(icon: HugeIcons.strokeRoundedTick02, color: _gold, size: 20, strokeWidth: 2.2),
      ),
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColorBlack,
      appBar: MyAppBar(fontSize: 18.0, backArrow: true, iconRemove: !_hasUnread, icon: _hasUnread ? _readAllButton() : null, name: 'notification', elevationWhite: true),
      body: FutureBuilder<List<NotifcationModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: spinKit());
          } else if (snapshot.hasError) {
            return errorData(onTap: _refresh);
          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
            return Center(
              child: CatalogEmptyState(icon: Icons.notifications_none_rounded, title: 'notificationsNone'.tr, description: ''),
            );
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
              itemBuilder: (context, index) => _NotificationCard(model: items[index], onOpen: () => _opened(items[index])),
            ),
          );
        },
      ),
    );
  }
}

/// One notification: bell tile, title, date and a body that unfolds on tap.
class _NotificationCard extends StatefulWidget {
  const _NotificationCard({required this.model, required this.onOpen});

  final NotifcationModel model;

  /// Called when the card is unfolded (the page marks it read).
  final VoidCallback onOpen;

  bool get isNew => !model.read;

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
            onTap: () {
              setState(() => _open = !_open);
              if (_open) {
                widget.onOpen();
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(color: _gold.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(14)),
                    child: const Center(
                      child: HugeIcon(icon: HugeIcons.strokeRoundedNotification03, color: _gold, size: 24),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                model.title ?? '',
                                style: const TextStyle(color: Colors.white, fontFamily: gilroySemiBold, fontSize: 17),
                              ),
                            ),
                            if (widget.isNew) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(color: _gold, borderRadius: BorderRadius.circular(8)),
                                child: Text(
                                  'newLabel'.tr,
                                  style: const TextStyle(color: Colors.black, fontFamily: gilroyBold, fontSize: 10.5, height: 1.1),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (_date.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            _date,
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontFamily: gilroyRegular, fontSize: 13),
                          ),
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
                                      child: const Text(
                                        'Link',
                                        style: TextStyle(color: Colors.black, fontFamily: gilroySemiBold, fontSize: 14),
                                      ),
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
