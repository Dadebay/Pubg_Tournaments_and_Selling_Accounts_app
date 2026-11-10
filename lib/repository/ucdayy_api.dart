// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import '../models/user_models/auth_model.dart';
import '../views/constants/constants.dart';

/// Result of an API call: [ok] is true for a 2xx answer, [data] is the decoded
/// JSON body (or null) and [error] the `error` string the API sends on a 400.
class ApiResult {
  const ApiResult({required this.statusCode, this.data, this.error});

  final int statusCode;
  final dynamic data;
  final String? error;

  bool get ok => statusCode >= 200 && statusCode < 300;
}

/// Endpoints of the new ucdayy mobile API that the older models do not cover.
class UcdayyApi {
  const UcdayyApi._();

  static const String _base = '$serverURL/api';

  static Future<Map<String, String>> _headers({bool auth = false, bool json = true}) async {
    final headers = <String, String>{};
    if (json) {
      headers[HttpHeaders.contentTypeHeader] = 'application/json; charset=UTF-8';
    }
    if (auth) {
      // No token (a guest): no header, so endpoints with an optional token still answer.
      final token = await Auth().getToken();
      if (token != null && token.isNotEmpty) {
        headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
      }
    }
    return headers;
  }

  static Map<String, String> _query(Map<String, Object?> params) {
    return {
      for (final entry in params.entries)
        if (entry.value != null) entry.key: '${entry.value}',
    };
  }

  static ApiResult _result(http.Response response) {
    dynamic data;
    try {
      data = json.decode(utf8.decode(response.bodyBytes));
    } catch (_) {
      data = null;
    }
    String? error;
    if (response.statusCode >= 400 && data is Map) {
      // 400 bodies carry `error`; a 401 carries DRF's `detail`.
      final message = data['error'] ?? data['detail'];
      if (message != null) {
        error = '$message';
      }
    }
    return ApiResult(statusCode: response.statusCode, data: data, error: error);
  }

  static const String _shopBase = _base;

  static Future<ApiResult> _get(String path, {bool auth = false, Map<String, Object?> query = const {}, String base = _base}) async {
    try {
      final uri = Uri.parse('$base$path').replace(queryParameters: _query(query));
      return _result(await http.get(uri, headers: await _headers(auth: auth)));
    } catch (e) {
      return ApiResult(statusCode: 0, error: '$e');
    }
  }

  static Future<ApiResult> _postJson(String path, Map<String, Object?> body, {bool auth = false, String base = _base}) async {
    try {
      final response = await http.post(
        Uri.parse('$base$path'),
        headers: await _headers(auth: auth),
        body: jsonEncode(body),
      );
      return _result(response);
    } catch (e) {
      return ApiResult(statusCode: 0, error: '$e');
    }
  }

  /// A POST whose JSON body is a list (the basket lines of `/category/paymentFromPoint/`).
  static Future<ApiResult> _postList(String path, List<Map<String, Object?>> body, {bool auth = false}) async {
    try {
      final response = await http.post(
        Uri.parse('$_base$path'),
        headers: await _headers(auth: auth),
        body: jsonEncode(body),
      );
      return _result(response);
    } catch (e) {
      return ApiResult(statusCode: 0, error: '$e');
    }
  }

  static Future<ApiResult> _postMultipart(String path, {Map<String, Object?> fields = const {}, Map<String, File?> files = const {}}) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse('$_base$path'));
      request.headers.addAll(await _headers(auth: true, json: false));
      request.fields.addAll(_query(fields));
      for (final entry in files.entries) {
        final file = entry.value;
        if (file == null) {
          continue;
        }
        request.files.add(await http.MultipartFile.fromPath(entry.key, file.path, contentType: _mediaType(file.path)));
      }
      final streamed = await request.send();
      return _result(await http.Response.fromStream(streamed));
    } catch (e) {
      return ApiResult(statusCode: 0, error: '$e');
    }
  }

  static MediaType? _mediaType(String path) {
    final mime = lookupMimeType(path);
    return mime == null ? null : MediaType.parse(mime);
  }

  // ---------------------------------------------------------------- accounts

  /// The signed-in player's own account.
  static Future<ApiResult> getMyAccount() => _get('/accounts/get-my-account/', auth: true);

  /// Buys the account of post [postId] with the wallet balance. The buyer gives the
  /// Gmail the account data is sent to and the PUBG id. 400 = not enough money or bad
  /// input, 404 = no such post, 409 = already sold (see docs/Backend_Account_Purchase.md).
  static Future<ApiResult> buyAccountPost(int postId, {required String gmail, required String pubgId}) => _postJson('/accounts/buy-post/$postId/', {'gmail': gmail, 'pubg_id': pubgId}, auth: true);

  /// Public account of any user.
  static Future<ApiResult> getAccount(int id) => _get('/accounts/get-account/$id/');

  static Future<ApiResult> changePassword({required String password, required String password2}) {
    return _postJson('/accounts/change-password/', {'password': password, 'password2': password2}, auth: true);
  }

  /// Follows the user, or unfollows when already following.
  static Future<ApiResult> toggleFollow(int userId) {
    return _postJson('/accounts/follow/', {'following_user_id': userId}, auth: true);
  }

  static Future<ApiResult> getFollowers(int userId, {int? page, int? pageSize}) {
    return _get('/accounts/get-followers/$userId/', query: {'page': page, 'page_size': pageSize});
  }

  static Future<ApiResult> getFollowings(int userId, {int? page, int? pageSize}) {
    return _get('/accounts/get-followings/$userId/', query: {'page': page, 'page_size': pageSize});
  }

  static Future<ApiResult> uploadImage(File image) => _postMultipart('/accounts/upload-image/', files: {'image': image});

  static Future<ApiResult> getImages(int userId, {int? page, int? pageSize}) {
    return _get('/accounts/get-images/$userId/', query: {'page': page, 'page_size': pageSize});
  }

  /// Username / password login, answers with `access` and `refresh`.
  static Future<ApiResult> tokenLogin({required String username, required String password}) {
    return _postJson('/token/', {'username': username, 'password': password});
  }

  // ------------------------------------------------------------------- posts

  static Future<ApiResult> getMyPosts({int? page, int? pageSize}) {
    return _get('/accounts/get-my-posts/', auth: true, query: {'page': page, 'page_size': pageSize});
  }

  static Future<ApiResult> getUserPosts(int userId, {int? page, int? pageSize}) {
    return _get('/accounts/get-user-posts/$userId/', query: {'page': page, 'page_size': pageSize});
  }

  /// The fee is charged from the user's points by the server.
  static Future<ApiResult> addPost({String? title, String? description, String? pubgUsername, String? pubgId, num? price, int? pubgType, bool? vip, int? location, File? image, File? bgImage}) {
    return _postMultipart('/accounts/add-post/', fields: {'title': title, 'description': description, 'pubg_username': pubgUsername, 'pubg_id': pubgId, 'price': price, 'pubg_type': pubgType, 'vip': vip, 'location': location}, files: {'image': image, 'bg_image': bgImage});
  }

  static Future<ApiResult> updatePost(
    int id, {
    String? title,
    String? description,
    String? pubgUsername,
    String? pubgId,
    num? price,

    /// A location id from `/accounts/locations/`; [clearLocation] removes it (sends an empty value).
    int? location,
    bool clearLocation = false,
    File? image,
    File? bgImage,
  }) {
    return _postMultipart('/accounts/update-post/$id/', fields: {'title': title, 'description': description, 'pubg_username': pubgUsername, 'pubg_id': pubgId, 'price': price, 'location': clearLocation ? '' : location}, files: {'image': image, 'bg_image': bgImage});
  }

  static Future<ApiResult> uploadPostVideo({required int postId, required File video}) {
    return _postMultipart('/accounts/upload-post-video/', fields: {'post': postId}, files: {'video': video});
  }

  // --------------------------------------------------------------------- ucs

  static Future<ApiResult> getUcCategories() => _get('/ucs/categories/', base: _shopBase);

  /// Products of one category: `{ category, count, next, results: [...] }`.
  static Future<ApiResult> getUcCategory(int id, {int? page}) {
    return _get('/ucs/categories/$id/', query: {'page': page}, base: _shopBase);
  }

  static Future<ApiResult> getUcDetail(int id) => _get('/ucs/uc/$id/', base: _shopBase);

  // ------------------------------------------------------------------ carts

  /// Creates an order from UC items; the price is charged from the user's points.
  static Future<ApiResult> addCart({required List<Map<String, int>> items, String? pubgId, bool ask = false}) {
    return _postJson('/carts/add-cart/', {'pubg_id': pubgId, 'ask': ask, 'list': items}, auth: true, base: _shopBase);
  }

  /// My orders.
  static Future<ApiResult> getCarts({int? page, int? pageSize}) {
    return _get('/carts/', auth: true, query: {'page': page, 'page_size': pageSize}, base: _shopBase);
  }

  static Future<ApiResult> getCart(int id) => _get('/carts/get-cart/$id/', auth: true, base: _shopBase);

  // ------------------------------------------------------------------- lucky

  /// The games to show and the player's cashback.
  static Future<ApiResult> getLucky() => _get('/games/lucky/', auth: true);

  /// One spin; costs 1 cashback. 400 = no cashback / game not running, 409 = no winner slots left.
  ///
  /// The server's game object has no id, so without one the id-less route is used
  /// (`/games/lucky/spin/`, then the README's `/lucky/spin/`).
  static Future<ApiResult> spinLucky(int gameId) async {
    if (gameId > 0) {
      return _postJson('/games/lucky/$gameId/spin/', {}, auth: true);
    }
    final result = await _postJson('/games/lucky/spin/', {}, auth: true);
    if (result.statusCode == 404) {
      return _postJson('/lucky/spin/', {}, auth: true);
    }
    return result;
  }

  /// Buys [count] spins (cashback) with points.
  static Future<ApiResult> buyLuckySpins(int count) => _postJson('/games/lucky/buy-spins/', {'count': count}, auth: true);

  // --------------------------------------------- games, programs, gift cards

  static String _catalogPath(String kind) => switch (kind) {
    'program' => 'programs',
    'gift' => 'gifts',
    _ => 'games',
  };

  /// The brands of one kind (`game`, `program` or `gift`), no auth.
  static Future<ApiResult> getCatalog(String kind) => _get('/${_catalogPath(kind)}/');

  /// One game / program / gift brand with its products.
  static Future<ApiResult> getCatalogItem(String kind, int id) => _get('/${_catalogPath(kind)}/$id/');

  /// Pays the basket [lines] from the balance. A game product line is
  /// `{id, count, status: 'thing', asking: <answer>}`, a gift card line `{id, count, status: 'gift'}`.
  static Future<ApiResult> payFromBalance(List<Map<String, Object?>> lines) => _postList('/category/paymentFromPoint/', lines, auth: true);

  // ---------------------------------------------------------- card payments

  /// The banks the card payment supports: `[{id, name_tm, name_ru, enabled}]`, no auth.
  static Future<ApiResult> getPaymentBanks() => _get('/payment/banks/');

  /// Registers a card top-up of [amount] whole manat: `{formUrl, orderId, bank_id, returnUrl}`.
  static Future<ApiResult> registerCardTopUp({required int amount, int? bankId}) {
    return _postJson('/paymentToPoint/', {'amount': amount, 'bank_id': ?bankId}, auth: true);
  }

  /// The server asks the bank itself; answers `{success, amount, bonus, total}`.
  static Future<ApiResult> cardTopUpStatus({required int amount, required String orderId}) {
    return _postJson('/paymentToPointStatus/', {'amount': amount, 'orderId': orderId}, auth: true);
  }

  /// Registers a card payment of a basket. The bank goes on the first line.
  static Future<ApiResult> registerBasketCard(List<Map<String, Object?>> lines, {int? bankId}) {
    final body = [
      for (var i = 0; i < lines.length; i++)
        if (i == 0 && bankId != null) {...lines[i], 'bank_id': bankId} else lines[i],
    ];
    return _postList('/category/payment/', body, auth: true);
  }

  /// [lines] are the same basket lines as in the register call, with the `orderId`.
  static Future<ApiResult> basketCardStatus(List<Map<String, Object?>> lines) => _postList('/category/paymentStatus/', lines, auth: true);

  /// Orders of games and programs, newest first.
  static Future<ApiResult> getMyGameOrders() => _get('/games/my-orders/', auth: true);

  /// The gift codes the player bought, newest first.
  static Future<ApiResult> getMyGiftCodes() => _get('/gifts/my-codes/', auth: true);

  /// The owner deletes their own post (its images and videos too).
  static Future<ApiResult> deleteAccountPost(int id) => _postJson('/accounts/delete-post/$id/', {}, auth: true);

  // ----------------------------------------------------------------- support

  /// The player's open chat with its latest messages: `{chat: {...} | null, messages: [], unread}`.
  /// A chat the admin closed, or that had no message for 72 hours, is gone: `chat` is null.
  static Future<ApiResult> getSupportChat() => _get('/support/chat/', auth: true);

  /// Writes to support without a chat id. With no open chat this opens a new one with a
  /// clean history; the answer is the new message (with its `chat_id`).
  static Future<ApiResult> sendSupportMessageNew({String body = '', File? image}) {
    if (image == null) {
      return _postJson('/support/messages/', {'body': body}, auth: true);
    }
    return _postMultipart('/support/messages/', fields: {'body': body}, files: {'image': image});
  }

  /// Creates the player's support chat, or returns the one that exists.
  static Future<ApiResult> openSupportChat() => _postJson('/support/chats/', {}, auth: true);

  /// The newest messages, or those [before] / [after] a message id.
  static Future<ApiResult> getSupportMessages(int chatId, {int? before, int? after}) {
    return _get('/support/chats/$chatId/messages/', auth: true, query: {'before': before, 'after': after});
  }

  /// Sends text, an image or both.
  static Future<ApiResult> sendSupportMessage(int chatId, {String body = '', File? image}) {
    if (image == null) {
      return _postJson('/support/chats/$chatId/messages/', {'body': body}, auth: true);
    }
    return _postMultipart('/support/chats/$chatId/messages/', fields: {'body': body}, files: {'image': image});
  }

  static Future<ApiResult> markSupportRead(int chatId) => _postJson('/support/chats/$chatId/read/', {}, auth: true);

  /// Unread answers of the support team, for the badge.
  static Future<ApiResult> getSupportUnread() => _get('/support/unread/', auth: true);

  // ----------------------------------------------------------------- premium

  /// The premium status of the player and the current price.
  static Future<ApiResult> getPremium() => _get('/accounts/premium/', auth: true);

  /// Buys or extends premium with points. 400 = not enough points / not for sale.
  static Future<ApiResult> buyPremium() => _postJson('/accounts/premium/buy/', {}, auth: true);

  // ------------------------------------------------------------------- about

  static Future<ApiResult> getPrivacy() => _get('/about/privacy/');

  /// The terms of use (same shape as the privacy policy); 404 until the server has it.
  static Future<ApiResult> getTerms() => _get('/about/terms/');

  /// Prices and constants of the app (may also carry the terms of use).
  static Future<ApiResult> getConsts() => _get('/about/consts/');

  // ----------------------------------------------------------- notifications

  /// The list, oldest first, each with `read` for this account (without a token every one is unread).
  static Future<ApiResult> getNotifications() => _get('/notifications/', auth: true);

  /// `{unread: N}` for the bell badge.
  static Future<ApiResult> getNotificationsUnread() => _get('/notifications/unread/', auth: true);

  /// One notification; with a token opening it marks it read.
  static Future<ApiResult> getNotification(int id) => _get('/notifications/$id/', auth: true);

  static Future<ApiResult> markNotificationRead(int id) => _postJson('/notifications/$id/read/', {}, auth: true);

  /// `{unread: 0}`.
  static Future<ApiResult> markAllNotificationsRead() => _postJson('/notifications/read-all/', {}, auth: true);

  // ------------------------------------------------------------------ orders

  /// Everything the player bought, newest first: `{count, page, page_size, types, results}`.
  /// [type] filters by one type or several separated by commas (`uc,gift`).
  static Future<ApiResult> getOrderHistory({int page = 1, int pageSize = 20, String? type}) => _get('/orders/history/', auth: true, query: {'page': page, 'page_size': pageSize, 'type': type});
}

/// Items of a paged answer: either a bare list or `{ results: [...] }`.
List<Map<dynamic, dynamic>> apiItems(dynamic data) {
  final list = data is Map ? data['results'] : data;
  if (list is! List) {
    return [];
  }
  return list.whereType<Map<dynamic, dynamic>>().toList();
}
