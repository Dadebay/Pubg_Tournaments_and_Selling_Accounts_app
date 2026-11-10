import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:game_app/models/support_model.dart';
import 'package:game_app/repository/ucdayy_api.dart';
import 'package:game_app/utils/support_push.dart';
import 'package:game_app/views/constants/index.dart';
import 'package:game_app/views/support/support_chat_empty_state.dart';
import 'package:hugeicons/hugeicons.dart';

/// Chat with the support team. One thread per player: it is created on the
/// first visit, new answers are polled every 3 seconds while the page is open.
class SupportChatPage extends StatefulWidget {
  const SupportChatPage({this.initialText, super.key});

  /// Put in the message field when the page opens (the player only presses send).
  final String? initialText;

  @override
  State<SupportChatPage> createState() => _SupportChatPageState();
}

class _SupportChatPageState extends State<SupportChatPage> with WidgetsBindingObserver {
  static const _gold = Color(0xFFFFC83D);
  static const _maxImageBytes = 10 * 1024 * 1024;

  final TextEditingController _text = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final FocusNode _focus = FocusNode();

  /// Plays the short sound when the support team has answered.
  final AudioPlayer _sound = AudioPlayer();

  /// Oldest first; shown reversed so the list sticks to the newest message.
  final List<SupportMessage> _messages = [];
  int? _chatId;

  /// When the chat closes by itself: 72 hours after it was started.
  DateTime? _closesAt;
  bool _loading = true;
  bool _failed = false;
  bool _hasMore = false;
  bool _loadingMore = false;
  bool _sending = false;
  File? _image;
  int _lastId = 0;
  int _tempId = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SupportPush.chatOpen = true;
    _scroll.addListener(_onScroll);
    if ((widget.initialText ?? '').isNotEmpty) {
      _text.text = widget.initialText!;
    }
    _text.addListener(() => setState(() {}));
    _focus.addListener(() => setState(() {}));
    _start();
  }

  @override
  void dispose() {
    SupportPush.chatOpen = false;
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _text.dispose();
    _focus.dispose();
    _sound.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startPolling();
      _poll();
    } else {
      _timer?.cancel();
    }
  }

  Future<void> _start() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    // A chat the admin closed, or that was quiet for 72 hours, is gone: `chat` is null and the
    // player simply starts a new conversation by writing (the old messages stay hidden).
    final result = await UcdayyApi.getSupportChat();
    final data = result.data;
    if (!result.ok || data is! Map) {
      if (mounted) {
        setState(() {
          _loading = false;
          _failed = true;
        });
      }
      return;
    }
    if (!mounted) {
      return;
    }
    final chat = data['chat'];
    if (chat is! Map) {
      setState(() {
        _chatId = null;
        _closesAt = null;
        _messages.clear();
        _hasMore = false;
        _lastId = 0;
        _loading = false;
      });
      SupportPush.unread.value = 0;
      return;
    }
    final model = SupportChat.fromJson(chat);
    _chatId = model.id;
    final started = DateTime.tryParse('${chat['created_date'] ?? ''}')?.toLocal();
    _closesAt = started?.add(const Duration(hours: 72));
    final parsed = SupportMessages.fromJson(data);
    setState(() {
      _messages
        ..clear()
        ..addAll(parsed.messages);
      _hasMore = parsed.hasMore;
      _lastId = _maxId();
      _loading = false;
    });
    SupportPush.unread.value = 0;
    unawaited(UcdayyApi.markSupportRead(model.id));
    _startPolling();
  }

  int _maxId() => _messages.fold(0, (m, e) => e.pending || e.id < m ? m : e.id);

  void _startPolling() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _poll());
  }

  Future<void> _poll() async {
    final id = _chatId;
    if (id == null || !mounted) {
      return;
    }
    final result = await UcdayyApi.getSupportMessages(id, after: _lastId);
    if (!result.ok || !mounted) {
      return;
    }
    final parsed = SupportMessages.fromJson(result.data);
    final known = _messages.map((e) => e.id).toSet();
    final fresh = parsed.messages.where((e) => !known.contains(e.id)).toList();
    final closed = parsed.status == 'closed';
    if (closed) {
      // The admin closed the chat: it disappears and the player can start a new one.
      _timer?.cancel();
      setState(() {
        _chatId = null;
        _messages.clear();
        _hasMore = false;
        _lastId = 0;
      });
      return;
    }
    if (fresh.isEmpty) {
      return;
    }
    setState(() {
      // A sent message is already shown as a pending bubble; the server copy replaces it.
      if (fresh.any((e) => e.mine)) {
        _messages.removeWhere((e) => e.pending);
      }
      _messages.addAll(fresh);
      _lastId = _maxId();
    });
    if (fresh.any((e) => !e.mine)) {
      unawaited(_playReplySound());
      unawaited(UcdayyApi.markSupportRead(id));
    }
  }

  /// A missing or blocked sound must never break the chat.
  Future<void> _playReplySound() async {
    try {
      await _sound.play(AssetSource('sounds/support_reply.wav'));
    } catch (_) {}
  }

  void _onScroll() {
    if (_scroll.hasClients && _scroll.position.pixels >= _scroll.position.maxScrollExtent - 120) {
      _loadOlder();
    }
  }

  Future<void> _loadOlder() async {
    final id = _chatId;
    final first = _messages.where((e) => !e.pending).firstOrNull;
    if (id == null || first == null || !_hasMore || _loadingMore) {
      return;
    }
    _loadingMore = true;
    final result = await UcdayyApi.getSupportMessages(id, before: first.id);
    _loadingMore = false;
    if (!result.ok || !mounted) {
      return;
    }
    final parsed = SupportMessages.fromJson(result.data);
    setState(() {
      _messages.insertAll(0, parsed.messages);
      _hasMore = parsed.hasMore;
    });
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) {
      return;
    }
    final file = File(picked.path);
    if (await file.length() > _maxImageBytes) {
      showSnackBar('error', 'supportImageTooBig'.tr, Colors.red);
      return;
    }
    setState(() => _image = file);
  }

  bool get _canSend => !_sending && (_text.text.trim().isNotEmpty || _image != null);

  Future<void> _send() async {
    final id = _chatId;
    if (!_canSend) {
      return;
    }
    final body = _text.text.trim();
    final image = _image;
    final temp = SupportMessage(id: --_tempId, mine: true, body: body, image: image?.path, createdAt: DateTime.now(), admin: null, pending: true);
    setState(() {
      _sending = true;
      _messages.add(temp);
      _text.clear();
      _image = null;
    });
    if (_scroll.hasClients) {
      unawaited(_scroll.animateTo(0, duration: const Duration(milliseconds: 250), curve: Curves.easeOut));
    }
    // Without an open chat the first message opens a new one.
    final result = id == null ? await UcdayyApi.sendSupportMessageNew(body: body, image: image) : await UcdayyApi.sendSupportMessage(id, body: body, image: image);
    if (!mounted) {
      return;
    }
    setState(() {
      _sending = false;
      final index = _messages.indexWhere((e) => e.id == temp.id);
      if (result.ok && result.data is Map) {
        final saved = SupportMessage.fromJson(result.data as Map);
        if (index >= 0) {
          _messages.removeAt(index);
        }
        if (!_messages.any((e) => e.id == saved.id)) {
          _messages.add(saved);
        }
        _lastId = _maxId();
        if (id == null && (saved.chatId ?? 0) > 0) {
          _chatId = saved.chatId;
        }
      } else if (index >= 0) {
        _messages[index] = temp.copyWith(pending: false, failed: true);
      }
    });
    if (result.ok && id == null) {
      // The new chat is open: poll it (and learn its id when the answer did not carry it).
      if (_chatId == null) {
        await _start();
      } else {
        _startPolling();
      }
    }
    if (!result.ok && result.error != null) {
      showSnackBar('error', result.error!, Colors.red);
    }
  }

  Future<void> _retry(SupportMessage message) async {
    setState(() {
      _messages.removeWhere((e) => e.id == message.id);
      _text.text = message.body;
      _image = message.image == null ? null : File(message.image!);
    });
    await _send();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColorBlack,
      appBar: const MyAppBar(backArrow: true, iconRemove: true, fontSize: 18.0, name: 'support', elevationWhite: true),
      body: SafeArea(
        child: Column(
          children: [
            if (_closesAt != null && _chatId != null) _closesChip(),
            Expanded(child: _body()),
            if (!_loading && !_failed) _composer(),
          ],
        ),
      ),
    );
  }

  /// "This chat closes at ...": a chat lasts 72 hours from its start.
  Widget _closesChip() {
    final at = _closesAt!;
    String two(int n) => n.toString().padLeft(2, '0');
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(20)),
        child: Text(
          '${'supportClosesAt'.tr}: ${two(at.day)}.${two(at.month)} ${two(at.hour)}:${two(at.minute)}',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontFamily: gilroyMedium, fontSize: 12),
        ),
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return Center(child: spinKit());
    }
    if (_failed) {
      return SupportChatEmptyState(onRetry: _start);
    }
    if (_messages.isEmpty) {
      return const SupportChatEmptyState();
    }
    final items = _messages.reversed.toList();
    return ListView.builder(
      controller: _scroll,
      reverse: true,
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      itemCount: items.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == items.length) {
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Center(child: spinKit()),
          );
        }
        final message = items[index];
        // `items` is newest first, so the "previous" message in time is index + 1.
        final older = index + 1 < items.length ? items[index + 1] : null;
        final newDay = older == null || !_sameDay(older.createdAt, message.createdAt);
        final groupStart = older == null || older.mine != message.mine || newDay;
        final newer = index > 0 ? items[index - 1] : null;
        final groupEnd = newer == null || newer.mine != message.mine || !_sameDay(newer.createdAt, message.createdAt);
        return Column(
          children: [
            if (newDay) _dayChip(message.createdAt),
            _Bubble(message: message, groupStart: groupStart, groupEnd: groupEnd, onRetry: () => _retry(message), onImage: _openImage),
          ],
        );
      },
    );
  }

  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  Widget _dayChip(DateTime date) {
    final text = '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(20)),
        child: Text(
          text,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontFamily: gilroyMedium, fontSize: 12),
        ),
      ),
    );
  }

  Widget _composer() {
    final ready = _canSend;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF101012),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_image != null)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10, left: 2),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(_image!, width: 80, height: 80, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: -8,
                      right: -8,
                      child: GestureDetector(
                        onTap: () => setState(() => _image = null),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A2A2E),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          child: const Center(
                            child: HugeIcon(icon: HugeIcons.strokeRoundedCancel01, color: Colors.white, size: 14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1B1B1E),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
                  ),
                  child: Center(
                    child: HugeIcon(icon: HugeIcons.strokeRoundedAttachment01, color: _image == null ? Colors.white70 : _gold, size: 22),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B1B1E),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _text,
                    focusNode: _focus,
                    minLines: 1,
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                    cursorColor: _gold,
                    style: const TextStyle(color: Colors.white, fontFamily: gilroyMedium, fontSize: 16, height: 1.3),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      hintText: 'supportHint'.tr,
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.38), fontFamily: gilroyMedium),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: ready ? _send : null,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ready ? _gold : const Color(0xFF1B1B1E),
                    border: ready ? null : Border.all(color: Colors.white.withValues(alpha: 0.09)),
                  ),
                  child: Center(
                    child: _sending
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.4, color: Color(0xFF1A1200)))
                        : HugeIcon(icon: HugeIcons.strokeRoundedSent, color: ready ? const Color(0xFF1A1200) : Colors.white30, size: 22),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openImage(String source) {
    Get.to(
      () => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const HugeIcon(icon: HugeIcons.strokeRoundedCancel01, color: Colors.white, size: 24),
            onPressed: Get.back,
          ),
        ),
        body: SizedBox.expand(
          child: InteractiveViewer(
            minScale: 1,
            maxScale: 5,
            child: source.startsWith('http')
                ? CachedNetworkImage(
                    imageUrl: source,
                    fit: BoxFit.contain,
                    placeholder: (_, _) => Center(child: spinKit()),
                  )
                : Image.file(File(source), fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, required this.groupStart, required this.groupEnd, required this.onRetry, required this.onImage});

  final SupportMessage message;
  final bool groupStart;

  /// The last bubble of a run carries the small corner, as in Telegram.
  final bool groupEnd;
  final VoidCallback onRetry;
  final void Function(String source) onImage;

  static const _gold = Color(0xFFFFC83D);
  static const _red = Color(0xFFFF5A5F);

  String get _time => '${message.createdAt.hour.toString().padLeft(2, '0')}:${message.createdAt.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final mine = message.mine;
    final ink = mine ? const Color(0xFF1A1200) : Colors.white;
    final image = message.image;
    final imageOnly = image != null && message.body.isEmpty;
    const big = Radius.circular(16);
    const small = Radius.circular(4);
    final footer = _footer(ink, onImage: imageOnly);
    final width = (MediaQuery.sizeOf(context).width * 0.68).clamp(180.0, 280.0);
    // The picture sits inside the 1.5 px frame, so its corners are that much tighter
    // than the bubble's; this keeps the picture and the frame curving together.
    const inner = Radius.circular(14.5);
    const innerSmall = Radius.circular(2.5);
    final hasName = !mine && groupStart && (message.admin ?? '').isNotEmpty;
    final imageRadius = BorderRadius.only(
      topLeft: hasName ? Radius.zero : inner,
      topRight: hasName ? Radius.zero : inner,
      bottomLeft: !imageOnly ? Radius.zero : (mine || !groupEnd ? inner : innerSmall),
      bottomRight: !imageOnly ? Radius.zero : (!mine || !groupEnd ? inner : innerSmall),
    );
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(top: groupStart ? 8 : 2, left: mine ? 56 : 0, right: mine ? 0 : 56),
        constraints: BoxConstraints(maxWidth: image != null ? width : MediaQuery.sizeOf(context).width * 0.8),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: mine ? _gold : const Color(0xFF212125),
          // A grey frame around bubbles that carry a picture.
          border: image != null ? Border.all(color: const Color(0xFF8E8E93), width: 1.5) : null,
          borderRadius: BorderRadius.only(topLeft: big, topRight: big, bottomLeft: mine || !groupEnd ? big : small, bottomRight: !mine || !groupEnd ? big : small),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!mine && groupStart && (message.admin ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 6, 10, 0),
                child: Text(
                  message.admin!,
                  style: const TextStyle(color: _gold, fontFamily: gilroyBold, fontSize: 13),
                ),
              ),
            if (image != null)
              GestureDetector(
                onTap: () => onImage(image),
                child: ClipRRect(
                  borderRadius: imageRadius,
                  child: ConstrainedBox(
                    // Wide pictures stay wide, tall screenshots are cut at 300 and shown whole when opened.
                    constraints: const BoxConstraints(maxHeight: 300),
                    child: Stack(
                      children: [
                        image.startsWith('http')
                            ? CachedNetworkImage(
                                imageUrl: image,
                                width: width,
                                fit: BoxFit.cover,
                                placeholder: (_, _) => SizedBox(width: width, height: 180),
                                errorWidget: (_, _, _) => SizedBox(
                                  width: width,
                                  height: 120,
                                  child: const Center(
                                    child: HugeIcon(icon: HugeIcons.strokeRoundedImage01, color: Colors.white38, size: 28),
                                  ),
                                ),
                              )
                            : Image.file(File(image), width: width, fit: BoxFit.cover),
                        if (imageOnly)
                          Positioned(
                            right: 8,
                            bottom: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(10)),
                              child: _footer(Colors.white, onImage: true),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            if (message.body.isNotEmpty)
              // The time sits at the bottom right of the last line; the invisible
              // spacer after the text keeps the words from running under it.
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 6, 10, 5),
                child: Stack(
                  children: [
                    Text.rich(
                      TextSpan(
                        style: TextStyle(color: ink, fontFamily: gilroyMedium, fontSize: 15.5, height: 1.25),
                        children: [
                          TextSpan(text: message.body),
                          WidgetSpan(child: SizedBox(width: message.failed ? 70 : (mine ? 58 : 40), height: 12)),
                        ],
                      ),
                    ),
                    Positioned(right: 0, bottom: 0, child: footer),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Time and state: a clock while sending, a red retry when it failed.
  Widget _footer(Color ink, {required bool onImage}) {
    if (message.failed) {
      return GestureDetector(
        onTap: onRetry,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const HugeIcon(icon: HugeIcons.strokeRoundedAlertCircle, color: _red, size: 14),
            const SizedBox(width: 3),
            Text(
              'premiumRetry'.tr,
              style: const TextStyle(color: _red, fontFamily: gilroyBold, fontSize: 11),
            ),
          ],
        ),
      );
    }
    final color = onImage ? Colors.white : ink.withValues(alpha: message.mine ? 0.6 : 0.5);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _time,
          style: TextStyle(color: color, fontFamily: gilroyMedium, fontSize: 11),
        ),
        if (message.mine) ...[const SizedBox(width: 3), HugeIcon(icon: message.pending ? HugeIcons.strokeRoundedClock01 : HugeIcons.strokeRoundedTick02, color: color, size: 13)],
      ],
    );
  }
}
