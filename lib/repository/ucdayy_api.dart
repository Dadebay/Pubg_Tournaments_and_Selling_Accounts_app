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
      final token = await Auth().getToken();
      headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
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
    if (response.statusCode >= 400 && data is Map && data['error'] != null) {
      error = '${data['error']}';
    }
    return ApiResult(statusCode: response.statusCode, data: data, error: error);
  }

  static Future<ApiResult> _get(String path, {bool auth = false, Map<String, Object?> query = const {}}) async {
    try {
      final uri = Uri.parse('$_base$path').replace(queryParameters: _query(query));
      return _result(await http.get(uri, headers: await _headers(auth: auth)));
    } catch (e) {
      return ApiResult(statusCode: 0, error: '$e');
    }
  }

  static Future<ApiResult> _postJson(String path, Map<String, Object?> body, {bool auth = false}) async {
    try {
      final response = await http.post(Uri.parse('$_base$path'), headers: await _headers(auth: auth), body: jsonEncode(body));
      return _result(response);
    } catch (e) {
      return ApiResult(statusCode: 0, error: '$e');
    }
  }

  static Future<ApiResult> _postMultipart(
    String path, {
    Map<String, Object?> fields = const {},
    Map<String, File?> files = const {},
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse('$_base$path'));
      request.headers.addAll(await _headers(auth: true, json: false));
      request.fields.addAll(_query(fields));
      for (final entry in files.entries) {
        final file = entry.value;
        if (file == null) {
          continue;
        }
        request.files.add(
          await http.MultipartFile.fromPath(entry.key, file.path, contentType: _mediaType(file.path)),
        );
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
  static Future<ApiResult> addPost({
    String? title,
    String? description,
    String? pubgUsername,
    String? pubgId,
    num? price,
    int? pubgType,
    bool? vip,
    File? image,
    File? bgImage,
  }) {
    return _postMultipart(
      '/accounts/add-post/',
      fields: {
        'title': title,
        'description': description,
        'pubg_username': pubgUsername,
        'pubg_id': pubgId,
        'price': price,
        'pubg_type': pubgType,
        'vip': vip,
      },
      files: {'image': image, 'bg_image': bgImage},
    );
  }

  static Future<ApiResult> updatePost(
    int id, {
    String? title,
    String? description,
    String? pubgUsername,
    String? pubgId,
    num? price,
    File? image,
    File? bgImage,
  }) {
    return _postMultipart(
      '/accounts/update-post/$id/',
      fields: {
        'title': title,
        'description': description,
        'pubg_username': pubgUsername,
        'pubg_id': pubgId,
        'price': price,
      },
      files: {'image': image, 'bg_image': bgImage},
    );
  }

  static Future<ApiResult> uploadPostVideo({required int postId, required File video}) {
    return _postMultipart('/accounts/upload-post-video/', fields: {'post': postId}, files: {'video': video});
  }

  // --------------------------------------------------------------------- ucs

  static Future<ApiResult> getUcCategories() => _get('/ucs/categories/');

  static Future<ApiResult> getUcDetail(int id) => _get('/ucs/uc/$id/');

  // ------------------------------------------------------------------- about

  static Future<ApiResult> getPrivacy() => _get('/about/privacy/');

  // ----------------------------------------------------------- notifications

  static Future<ApiResult> getNotification(int id) => _get('/notifications/$id/');
}

/// Items of a paged answer: either a bare list or `{ results: [...] }`.
List<Map<dynamic, dynamic>> apiItems(dynamic data) {
  final list = data is Map ? data['results'] : data;
  if (list is! List) {
    return [];
  }
  return list.whereType<Map<dynamic, dynamic>>().toList();
}
