// ignore_for_file: file_names

import 'package:cached_network_image/cached_network_image.dart';
import 'package:game_app/controllers/settings_controller.dart';
import 'package:game_app/models/user_models/user_sign_in_model.dart';
import 'package:game_app/views/constants/dialogs.dart';
import 'package:game_app/views/constants/index.dart';
import 'package:game_app/views/home_page/paymant/add_monay.dart';
import 'package:game_app/views/user_profil/auth/tab_bar_view.dart';
import 'package:game_app/views/user_profil/pages/about_us.dart';
import 'package:game_app/views/user_profil/pages/legal_page.dart';
import 'package:game_app/views/user_profil/pages/my_posts_page.dart';
import 'package:game_app/views/user_profil/pages/notification.dart';
import 'package:game_app/views/user_profil/pages/profile_settings.dart';
import 'package:game_app/views/user_profil/pages/settings.dart' as page;

import '../../controllers/wallet_controller.dart';

const _gold = Color(0xFFFFC83D);
const _cardTop = Color(0xFF232327);
const _cardBottom = Color(0xFF151517);

class NewUserProfil extends StatefulWidget {
  const NewUserProfil({super.key});

  @override
  State<NewUserProfil> createState() => _NewUserProfilState();
}

class _NewUserProfilState extends State<NewUserProfil> {
  final SettingsController settingsController = Get.put(SettingsController());

  /// My account; the same answer updates the balance, so one request is enough.
  late Future<GetMeModel> _me = GetMeModel().getMeAndBalance();

  Future<void> _reload() async {
    final future = GetMeModel().getMeAndBalance();
    setState(() => _me = future);
    await future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColorBlack,
      appBar: const MyAppBar(
        backArrow: false,
        fontSize: 0.0,
        iconRemove: true,
        name: 'profil',
        elevationWhite: true,
        dividerOpacity: 0.4,
      ),
      body: FutureBuilder<GetMeModel>(
        future: _me,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: spinKit());
          } else if (snapshot.hasError) {
            return errorData(onTap: _reload);
          } else if (snapshot.data == null) {
            return emptyData();
          }
          final me = snapshot.data!;
          return Obx(() {
            final loggedIn = settingsController.loginUser.value;
            return RefreshIndicator(
              color: _gold,
              backgroundColor: _cardTop,
              onRefresh: _reload,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                children: [
                  if (loggedIn) ...[
                    _ProfileHeader(me: me),
                    const SizedBox(height: 14),
                    _BalanceCard(
                      onTopUp: () => Get.to(() => const TopUpScreen()),
                    ),
                    const SizedBox(height: 22),
                    _Group(
                      children: [
                        _MenuTile(
                          icon: IconlyLight.profile,
                          title: 'profil',
                          onTap: () async {
                            await Get.to(
                              () => ProfileSettings(
                                medata: me,
                                image: me.image ?? '',
                              ),
                            );
                            _reload();
                          },
                        ),
                        _MenuTile(
                          icon: IconlyLight.paper,
                          title: 'myPosts',
                          onTap: () => Get.to(() => const MyPostsPage()),
                        ),
                      ],
                    ),
                  ] else
                    _GuestCard(
                      onTap: () => Get.to(() => const TabBarViewPage()),
                    ),
                  const SizedBox(height: 14),
                  _Group(
                    children: [
                      _MenuTile(
                        icon: IconlyLight.setting,
                        title: 'settings',
                        onTap: () => Get.to(() => const page.Settings()),
                      ),
                      _MenuTile(
                        icon: IconlyLight.notification,
                        title: 'notification',
                        onTap: () => Get.to(() => NotificationPage()),
                      ),
                      _MenuTile(
                        icon: IconlyLight.infoSquare,
                        title: 'aboutUs',
                        onTap: () => Get.to(() => const AboutUs()),
                      ),
                      _MenuTile(
                        icon: IconlyLight.document,
                        title: 'termsOfUse',
                        onTap: () => Get.to(() => const LegalPage(kind: LegalKind.terms)),
                      ),
                      _MenuTile(
                        icon: IconlyLight.shieldDone,
                        title: 'privacy',
                        onTap: () => Get.to(() => const LegalPage(kind: LegalKind.privacy)),
                      ),
                    ],
                  ),
                  if (loggedIn) ...[
                    const SizedBox(height: 14),
                    _Group(
                      children: [
                        _MenuTile(
                          icon: IconlyLight.logout,
                          title: 'log_out',
                          danger: true,
                          onTap: () => logOut(context),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          });
        },
      ),
    );
  }
}

BoxDecoration _cardDecoration() => BoxDecoration(
  borderRadius: BorderRadius.circular(24),
  gradient: const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [_cardTop, _cardBottom],
  ),
  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
);

/// Avatar, name, phone and the PUBG id of the signed-in user.
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.me});

  final GetMeModel me;

  static String? _clean(String? value) {
    final text = value?.trim();
    return text == null || text.isEmpty || text == 'null' ? null : text;
  }

  String get _name {
    final nickname = _clean(me.nickname);
    if (nickname != null) {
      return nickname;
    }
    final full = [
      _clean(me.firstName),
      _clean(me.lastName),
    ].whereType<String>().join(' ');
    return full.isNotEmpty ? full : _clean(me.phone) ?? 'profil'.tr;
  }

  String? get _imageUrl {
    final image = _clean(me.image);
    if (image == null) {
      return null;
    }
    return image.startsWith('http') ? image : '$serverURL$image';
  }

  @override
  Widget build(BuildContext context) {
    final phone = _clean(me.phone);
    final pubgId = _clean(me.pubgId);
    final refCode = _clean(me.ref_code);
    final url = _imageUrl;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 30, 18, 18),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2.5),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFD866), Color(0xFFFF9800)],
                  ),
                ),
                child: ClipOval(
                  child: SizedBox(
                    width: 68,
                    height: 68,
                    child: url == null
                        ? _initial()
                        : CachedNetworkImage(
                            imageUrl: url,
                            fit: BoxFit.cover,
                            placeholder: (context, _) => _initial(),
                            errorWidget: (context, _, _) => _initial(),
                          ),
                  ),
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
                            _name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: gilroyBold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        if (me.verified == true) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.verified_rounded,
                            color: Color(0xFF3DA5FF),
                            size: 18,
                          ),
                        ],
                        if (me.vip == true) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.workspace_premium_rounded,
                            color: _gold,
                            size: 18,
                          ),
                        ],
                      ],
                    ),
                    if (phone != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        phone,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontFamily: gilroyMedium,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (pubgId != null || refCode != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                if (pubgId != null)
                  Expanded(
                    child: _Chip(label: 'PUBG ID', value: pubgId),
                  ),
                if (pubgId != null && refCode != null)
                  const SizedBox(width: 10),
                if (refCode != null)
                  Expanded(
                    child: _Chip(
                      label: 'referalKod'.tr,
                      value: refCode,
                      copyable: true,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _initial() {
    final letter = _name.characters.first.toUpperCase();
    return ColoredBox(
      color: const Color(0xFF2C2C31),
      child: Center(
        child: Text(
          letter,
          style: const TextStyle(
            color: _gold,
            fontFamily: gilroyBold,
            fontSize: 28,
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.value,
    this.copyable = false,
  });

  final String label;
  final String value;
  final bool copyable;

  @override
  Widget build(BuildContext context) {
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontFamily: gilroyMedium,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: gilroyBold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (copyable)
            Icon(
              Icons.copy_rounded,
              size: 16,
              color: Colors.white.withValues(alpha: 0.5),
            ),
        ],
      ),
    );
    if (!copyable) {
      return chip;
    }
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        Clipboard.setData(ClipboardData(text: value));
        showSnackBar('copy'.tr, value, kPrimaryColor);
      },
      child: chip,
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.onTopUp});

  final VoidCallback onTopUp;

  @override
  Widget build(BuildContext context) {
    final wallet = Get.find<WalletController>();
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_gold.withValues(alpha: 0.22), _cardBottom],
        ),
        border: Border.all(color: _gold.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'balance'.tr,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontFamily: gilroyMedium,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Obx(
                  () => Text(
                    '${wallet.userMoney.value} TMT',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _gold,
                      fontFamily: gilroyBold,
                      fontSize: 26,
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onTopUp,
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD866), Color(0xFFFF9800)],
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.add_rounded,
                    color: Color(0xFF1A1200),
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'cashHistory'.tr,
                    style: const TextStyle(
                      color: Color(0xFF1A1200),
                      fontFamily: gilroyBold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuestCard extends StatelessWidget {
  const _GuestCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _gold.withValues(alpha: 0.12),
            ),
            child: const Icon(IconlyBold.profile, color: _gold, size: 34),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onTap,
            child: Container(
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD866), Color(0xFFFF9800)],
                ),
              ),
              child: Text(
                'signUp'.tr,
                style: const TextStyle(
                  color: Color(0xFF1A1200),
                  fontFamily: gilroyBold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Rounded block that stacks menu tiles with hairline dividers between them.
class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                indent: 70,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? const Color(0xFFFF5A5F) : Colors.white;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: (danger ? const Color(0xFFFF5A5F) : _gold).withValues(
                  alpha: 0.12,
                ),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: danger ? color : _gold, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title.tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontFamily: gilroyMedium,
                  fontSize: 16,
                ),
              ),
            ),
            if (!danger)
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white.withValues(alpha: 0.35),
              ),
          ],
        ),
      ),
    );
  }
}
