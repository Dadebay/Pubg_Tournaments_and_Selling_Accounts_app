import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:game_app/models/turnir.dart';
import 'package:game_app/views/home_page/paymant/data/team_members_provider.dart';
import 'package:game_app/views/tournament_page/qartar_groups_screen.dart';
import 'package:game_app/views/constants/constants.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:game_app/models/home_page_model.dart';
import 'package:game_app/models/tournament_model.dart';
import 'package:game_app/views/cards/tournament_image.dart';
import 'package:game_app/views/premium/lucky_page.dart';
import 'package:game_app/views/premium/premium_page.dart';
import 'package:game_app/views/support/support_chat_page.dart';
import 'package:game_app/views/tournament_page/tournament.dart';
import 'package:game_app/views/user_profil/pages/about_us.dart';
import 'package:game_app/views/orders/orders_history_page.dart';
import 'package:game_app/views/tournament_page/tournament_profil_page.dart';
import 'package:game_app/views/wallet/wallet_page.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

/// What a banner tap does. The backend sends `action` + `target_id`; a link in
/// the `url` field with the `ucdayy://` scheme works too, for example
/// `ucdayy://tournament/12`, `ucdayy://lobby/5` or `ucdayy://premium`.
/// See docs/Backend_Banner_Actions.md.
class BannerAction {
  BannerAction._();

  static const scheme = 'ucdayy';

  /// Returns true when the banner was handled; false means "show the banner's own page".
  static Future<bool> open(BannerModel banner) async {
    var action = (banner.action ?? '').trim().toLowerCase();
    var targetId = banner.targetId;
    final link = Uri.tryParse((banner.url ?? '').trim());

    // `ucdayy://tournament/12`: the host is the action, the first segment the id.
    if (link != null && link.scheme == scheme) {
      action = link.host.toLowerCase();
      targetId = int.tryParse(link.pathSegments.isEmpty ? '' : link.pathSegments.first) ?? int.tryParse(link.queryParameters['id'] ?? '');
    }

    switch (action) {
      // The server calls a regular tournament (`/turnirs/turnir/{id}/`, shown in the app's
      // "Lobbi" list) a `tournament`, and a final tournament (`/turnirs/getturnirs/`, the
      // app's "Turnir" page with its stages) a `lobby`.
      case 'tournament':
        return _openTournament(targetId, 2);
      case 'lobby':
        return _openFinalTournament(targetId);
      case 'tournaments':
        await Get.to(() => const TournamentPage(tournamentType: 2));
        return true;
      case 'lobbies':
        await Get.to(() => const TournamentPage(tournamentType: 1));
        return true;
      case 'premium':
        await Get.to(() => const PremiumPage());
        return true;
      case 'lucky':
      case 'cashback':
        await Get.to(() => const LuckyPage());
        return true;
      case 'wallet':
      case 'uc':
        await Get.to(() => const WalletPage());
        return true;
      case 'orders':
        await Get.to(() => const OrdersHistoryPage());
        return true;
      case 'about':
        await Get.to(() => const AboutUs());
        return true;
      case 'phone':
        return _call(banner.phone ?? link?.path);
      case 'support':
        await Get.to(() => const SupportChatPage());
        return true;
      case 'url':
        return _openLink(link);
    }

    // No action: a normal web link (or a `tel:` number) opens outside the app.
    if (link != null && link.scheme != scheme) {
      return _openLink(link);
    }
    return false;
  }

  /// Starts a phone call to [number] (digits, spaces, `+`, `-` and brackets are allowed).
  static Future<bool> _call(String? number) async {
    final digits = (number ?? '').replaceAll(RegExp(r'[^0-9+]'), '');
    if (digits.isEmpty) {
      return false;
    }
    await launchUrl(Uri(scheme: 'tel', path: digits));
    return true;
  }

  static Future<bool> _openLink(Uri? link) async {
    if (link != null && link.scheme == 'tel') {
      return _call(link.path);
    }
    if (link != null && link.hasScheme && await canLaunchUrl(link)) {
      await launchUrl(link, mode: LaunchMode.externalApplication);
      return true;
    }
    return false;
  }

  /// Opens a final tournament (quarter / half / final) by id, taken from `/turnirs/getturnirs/`.
  static Future<bool> _openFinalTournament(int? id) async {
    if (id == null) {
      return false;
    }
    Tournament? found;
    try {
      final response = await http.get(Uri.parse('$serverURL/api/turnirs/getturnirs/'), headers: {'Content-Type': 'application/json;charset=UTF-8'});
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data is List) {
          for (final item in data) {
            if (item is Map<String, dynamic> && item['id'] == id) {
              found = Tournament.fromJson(item);
              break;
            }
          }
        }
      }
    } catch (_) {
      found = null;
    }
    if (found == null) {
      Get.snackbar('Üns beriň!', 'noConnection3'.tr, snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return true;
    }
    final tournament = found;
    await Get.to(
      () => ChangeNotifierProvider(
        create: (_) => TeamMembersProvider(),
        child: QuarterGroupsScreen(filter: 'tournament', tournament: tournament),
      ),
    );
    return true;
  }

  /// Loads the tournament, then opens its page. [type] is 1 for a tournament, 2 for a lobby.
  static Future<bool> _openTournament(int? id, int type) async {
    if (id == null) {
      return false;
    }
    final model = await TournamentModel().getTournamentID(id);
    if (model.id == null) {
      Get.snackbar('Üns beriň!', 'noConnection3'.tr, snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return true;
    }
    final finish = DateTime.tryParse(model.finish_date ?? '');
    final finished = finish != null && finish.isBefore(DateTime.now());
    await Get.to(() => TournamentProfilPage(tag: 'banner-tournament-$id', finised: finished, tournamentType: type, image: tournamentImageUrl(model.image), tournamentId: id, winners: model));
    return true;
  }
}
