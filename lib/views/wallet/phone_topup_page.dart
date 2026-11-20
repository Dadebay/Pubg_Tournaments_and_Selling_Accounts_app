import 'dart:io' show Platform;

import 'package:game_app/controllers/wallet_controller.dart';
import 'package:game_app/repository/ucdayy_api.dart';
import 'package:game_app/views/catalog/catalog_common.dart';
import 'package:game_app/views/constants/catalog_empty_state.dart';
import 'package:game_app/views/constants/centered_header.dart';
import 'package:game_app/views/support/support_chat_page.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/index.dart';

/// Top up with TMCell balance: the player sends phone balance from the number registered in their
/// account to one of our SIM numbers, and the server adds the points by itself (1 manat = 1 point,
/// no bonus). There is no status call: the balance is simply asked again.
class PhoneTopUpPage extends StatefulWidget {
  const PhoneTopUpPage({super.key});

  @override
  State<PhoneTopUpPage> createState() => _PhoneTopUpPageState();
}

class _SimNumber {
  _SimNumber(this.local, this.full, this.leftToday);

  final String local;
  final String full;
  final int leftToday;
}

class _PhoneTopUpPageState extends State<PhoneTopUpPage>
    with WidgetsBindingObserver {
  final WalletController _wallet = Get.find<WalletController>();
  List<_SimNumber> _numbers = [];
  bool _loading = true;
  bool _failed = false;
  String _myPhone = '';

  /// The SMS number of the operator that moves the balance: "number amount" is sent to it.
  static const _smsNumber = '0804';

  /// The amount is always 50 manat; the player can not change it.
  static const _fixedAmount = 50;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
    _loadMyPhone();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// The player comes back from the phone or SMS app: the list is asked again (a SIM may be full now).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _load(quiet: true);
        _wallet.getUserMoney();
    }
  }

  Future<void> _load({bool quiet = false}) async {
    if (!quiet) {
      setState(() {
        _loading = true;
        _failed = false;
      });
    }
    final result = await UcdayyApi.getPhoneTopUpNumbers();
    if (!mounted) {
      return;
    }
    final data = result.data;
    if (!result.ok || data is! List) {
      setState(() {
        _loading = false;
        _failed = _numbers.isEmpty;
      });
      return;
    }
    final items = [
      for (final item in data.whereType<Map>())
        _SimNumber(
          '${item['phone'] ?? ''}',
          '${item['phone_full'] ?? item['phone'] ?? ''}',
          int.tryParse('${item['left_today']}') ?? 0,
        ),
    ];
    // The SIM with the most transfers left first.
    items.sort((a, b) => b.leftToday.compareTo(a.leftToday));
    setState(() {
      _numbers = items;
      _loading = false;
      _failed = false;
    });
  }

  Future<void> _loadMyPhone() async {
    final result = await UcdayyApi.getMyAccount();
    final data = result.data;
    if (!mounted || !result.ok || data is! Map) {
      return;
    }
    final phone = '${data['phone'] ?? ''}'.trim();
    if (phone.isNotEmpty && phone != 'null') {
      setState(() => _myPhone = phone);
    }
  }

  /// "+99364030911" -> "+993 64 03 09 11".
  String _pretty(String full) {
    final digits = full.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length == 11 && digits.startsWith('993')) {
      final rest = digits.substring(3);
      return '+993 ${rest.substring(0, 2)} ${rest.substring(2, 4)} ${rest.substring(4, 6)} ${rest.substring(6)}';
    }
    return full;
  }

  /// The text of the sms: the first SIM number the server gave and the amount, "+99362990344 50".
  String? get _smsBody {
    if (_numbers.isEmpty) {
      return null;
    }
    return '${_numbers.first.full} $_fixedAmount';
  }

  /// Opens the SMS app with the operator number and the text filled in; the player only presses send.
  Future<void> _sendMoney() async {
    final body = _smsBody;
    if (body == null) {
      showSnackBar('Ýalňyşlyk', 'phoneTopUpAmountError', Colors.red);
      return;
    }
    final text = Uri.encodeComponent(body);
    // iOS separates the text with "&", Android with "?".
    final uri = Uri.parse(
      Platform.isIOS
          ? 'sms:$_smsNumber&body=$text'
          : 'sms:$_smsNumber?body=$text',
    );
    var opened = false;
    try {
      opened = await launchUrl(uri);
    } catch (_) {
      opened = false;
    }
    if (!opened) {
      // No SMS app: the text is copied so it can be pasted by hand.
      await Clipboard.setData(ClipboardData(text: body));
      showSnackBar('phoneTopUpSend', 'phoneTopUpSmsFailed', Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColorBlack,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            CenteredHeader(
              title: 'tmcell'.tr,
              onBack: Get.back,
            ),
            Expanded(child: _body()),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: catalogGold));
    }
    if (_failed) {
      return Center(
        child: CatalogEmptyState(
          icon: Icons.cloud_off_outlined,
          title: 'catalogLoadFailed'.tr,
          description: '',
          actionLabel: 'noConnection3'.tr,
          actionIcon: Icons.refresh_rounded,
          onAction: _load,
        ),
      );
    }
    return RefreshIndicator(
      color: catalogGold,
      backgroundColor: const Color(0xFF1C1C20),
      onRefresh: () async {
        await _load(quiet: true);
        await _wallet.getUserMoney();
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          _howCard(),
          const SizedBox(height: 16),
          if (_numbers.isEmpty) _emptyCard() else _sendSection(),
          const SizedBox(height: 14),
          _helpLink(),
        ],
      ),
    );
  }

  /// The three things the player has to know before sending.
  Widget _howCard() {
    Widget line(List<List<dynamic>> icon, String text) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: catalogGold.withValues(alpha: 0.14),
            ),
            child: HugeIcon(
              icon: icon,
              color: catalogGold,
              size: 18,
              strokeWidth: 1.8,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                text,
                style: const TextStyle(
                  color: Color(0xFFE6E6EA),
                  fontFamily: gilroyMedium,
                  fontSize: 14.5,
                  height: 1.35,
                ),
              ),
            ),
          ),
        ],
      ),
    );
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: catalogGold.withValues(alpha: 0.3)),
        color: const Color(0xFF1B1B1F),
      ),
      child: Column(
        children: [
          line(
            HugeIcons.strokeRoundedSmartPhone01,
            _myPhone.isEmpty
                ? 'phoneTopUpFrom'.tr
                : 'phoneTopUpFromNumber'.trParams({
                    'phone': _pretty(
                      _myPhone.startsWith('+') ? _myPhone : '+993$_myPhone',
                    ),
                  }),
          ),
          line(HugeIcons.strokeRoundedAlert02, 'phoneTopUpOtherNumber'.tr),
          line(HugeIcons.strokeRoundedCoins01, 'phoneTopUpRate'.tr),
          _warning(),
        ],
      ),
    );
  }

  /// The rule that must not be missed: only 50 manat, through 0804; less freezes the account.
  Widget _warning() {
    const red = Color(0xFFFF5A5F);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: red.withValues(alpha: 0.12),
        border: Border.all(color: red.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: red, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'phoneTopUpWarning'.tr,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: gilroySemiBold,
                fontSize: 14,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The number to send the balance to, the amount (50 manat to begin with) and the one button
  /// that opens the SMS app. Nothing else: no copying, no quick amounts.
  Widget _sendSection() {
    final number = _numbers.first;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        color: const Color(0xFF1B1B1F),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'phoneTopUpSendTo'.tr,
            style: const TextStyle(
              color: Color(0xFF9A9AA3),
              fontFamily: gilroyMedium,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _pretty(number.full),
            style: const TextStyle(
              color: Colors.white,
              fontFamily: gilroyBold,
              fontSize: 25,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'phoneTopUpAmount'.tr,
            style: const TextStyle(
              color: Color(0xFF9A9AA3),
              fontFamily: gilroyMedium,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              '$_fixedAmount TMT',
              style: const TextStyle(
                color: Colors.white,
                fontFamily: gilroyBold,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _sendMoney,
            child: Opacity(
              opacity: 1,
              child: Container(
                height: 54,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: catalogGold,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const HugeIcon(
                      icon: HugeIcons.strokeRoundedSent,
                      color: Color(0xFF1A1200),
                      size: 20,
                      strokeWidth: 2,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'phoneTopUpSend'.tr,
                      style: const TextStyle(
                        color: Color(0xFF1A1200),
                        fontFamily: gilroyBold,
                        fontSize: 16.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// No number is free right now: try later or pay by card.
  Widget _emptyCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: CatalogEmptyState(
        icon: Icons.phone_disabled_outlined,
        title: 'phoneTopUpNone'.tr,
        description: 'phoneTopUpNoneText'.tr,
        actionLabel: 'phoneTopUpByCard'.tr,
        actionIcon: Icons.credit_card,
        onAction: Get.back,
      ),
    );
  }

  /// If the points do not come in a few minutes: write to support.
  Widget _helpLink() {
    return GestureDetector(
      onTap: () => Get.to(() => const SupportChatPage()),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(
          'phoneTopUpHelp'.tr,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF9A9AA3),
            fontFamily: gilroyMedium,
            fontSize: 13.5,
            height: 1.35,
            decoration: TextDecoration.underline,
            decorationColor: Color(0xFF9A9AA3),
          ),
        ),
      ),
    );
  }
}
