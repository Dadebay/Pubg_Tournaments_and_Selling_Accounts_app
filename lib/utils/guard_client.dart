import 'dart:convert';

import 'package:game_app/utils/server_status.dart';
import 'package:game_app/views/constants/blocked_dialog.dart';
import 'package:http/http.dart' as http;

/// Wraps every `http` call of the app and reacts to two answers the server sends for any endpoint:
/// - `503` with `code: "maintenance"`: the app is locked, the maintenance notice opens;
/// - `403` with `code: "blocked"`: the player is banned, the ban dialog opens (reason and countdown).
/// The answer itself is passed on unchanged.
class GuardClient extends http.BaseClient {
  GuardClient(this._inner);

  final http.Client _inner;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await _inner.send(request);
    if (response.statusCode != 503 && response.statusCode != 403) {
      return response;
    }
    final bytes = await response.stream.toBytes();
    _inspect(response.statusCode, bytes);
    return http.StreamedResponse(
      http.ByteStream.fromBytes(bytes),
      response.statusCode,
      contentLength: bytes.length,
      request: response.request,
      headers: response.headers,
      isRedirect: response.isRedirect,
      persistentConnection: response.persistentConnection,
      reasonPhrase: response.reasonPhrase,
    );
  }

  void _inspect(int status, List<int> bytes) {
    try {
      final data = json.decode(utf8.decode(bytes));
      if (data is! Map) {
        return;
      }
      if (status == 503 && data['code'] == 'maintenance') {
        ServerStatus.instance.reportMaintenance(ServerStatus.fromBody(data));
      } else if (status == 403 && data['code'] == 'blocked') {
        BlockGuard.show(BanInfo.fromJson(data));
      }
    } catch (_) {
      // Not a JSON body: nothing to react to.
    }
  }
}
