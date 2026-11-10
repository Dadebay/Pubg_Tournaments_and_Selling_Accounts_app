import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:game_app/utils/guard_client.dart' show GuardClient;
import 'package:game_app/views/constants/constants.dart';
import 'package:game_app/views/constants/maintenance_dialog.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

enum ServerHealth { up, maintenance, down, noInternet }

class ServerState {
  const ServerState(this.health, {this.message, this.since});

  final ServerHealth health;

  /// The notice text (`message_tm` / `message_ru` of `GET /api/app-status/`), when there is one.
  final String? message;

  /// When the maintenance started (`since`), when the server says so.
  final DateTime? since;

  bool get isUp => health == ServerHealth.up;
}

/// Watches the server. When it stops answering, or says it is under maintenance, a notice
/// covers the app until it is back: "technical work is going on". It is checked when the app
/// starts, every 30 seconds while it runs and when it returns from the background.
///
/// `GET /api/app-status/` (public, always answers) tells `{maintenance, message_tm, message_ru, since}`.
/// While maintenance is on every other endpoint answers 503 with `code: "maintenance"`; the
/// [GuardClient] sees that answer and calls [reportMaintenance].
class ServerStatus with WidgetsBindingObserver {
  ServerStatus._();

  static final ServerStatus instance = ServerStatus._();

  Timer? _timer;
  int _failures = 0;
  bool _dialogOpen = false;

  /// Starts the periodic check. Safe to call more than once.
  void start() {
    if (_timer != null) {
      return;
    }
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _watch());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _watch();
    }
  }

  /// One quiet check: two failures in a row open the notice (a single hiccup does not).
  Future<void> _watch() async {
    if (_dialogOpen) {
      return;
    }
    final state = await check();
    if (state.isUp || state.health == ServerHealth.noInternet) {
      _failures = 0;
      return;
    }
    _failures++;
    // A maintenance announcement from the server is shown at once.
    if (_failures >= 2 || state.health == ServerHealth.maintenance) {
      await _show(state);
    }
  }

  /// Reads a status body (`app-status` or a 503) into a maintenance state.
  static ServerState fromBody(dynamic data) {
    final ru = Get.locale?.languageCode == 'ru';
    final map = data is Map ? data : const {};
    final message = map[ru ? 'message_ru' : 'message_tm'] ?? map['message_tm'] ?? map['message_ru'];
    return ServerState(ServerHealth.maintenance, message: message == null ? null : '$message', since: DateTime.tryParse('${map['since'] ?? ''}')?.toLocal());
  }

  /// Asks the server once.
  static Future<ServerState> check() async {
    try {
      final response = await http.get(Uri.parse('$serverURL/api/app-status/'), headers: {'Content-Type': 'application/json;charset=UTF-8'}).timeout(const Duration(seconds: 8));
      dynamic data;
      try {
        data = json.decode(utf8.decode(response.bodyBytes));
      } catch (_) {
        data = null;
      }
      if (response.statusCode == 503) {
        return fromBody(data);
      }
      if (response.statusCode >= 500) {
        return const ServerState(ServerHealth.down);
      }
      if (response.statusCode == 200 && data is Map && data['maintenance'] == true) {
        return fromBody(data);
      }
      // A 404 means a server without this endpoint yet: nothing to announce.
      return const ServerState(ServerHealth.up);
    } on TimeoutException {
      return await _hasInternet() ? const ServerState(ServerHealth.down) : const ServerState(ServerHealth.noInternet);
    } catch (_) {
      return await _hasInternet() ? const ServerState(ServerHealth.down) : const ServerState(ServerHealth.noInternet);
    }
  }

  /// An API answered 503 `maintenance`: the notice opens at once.
  Future<void> reportMaintenance(ServerState state) => _show(state);

  static Future<bool> _hasInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com').timeout(const Duration(seconds: 4));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Used at start-up: returns when the server is up, showing the notice while it is not.
  Future<void> ensureUp() async {
    final state = await check();
    if (state.isUp || state.health == ServerHealth.noInternet) {
      return;
    }
    await _show(state);
  }

  /// Shows the notice and returns when the server is back (the notice closes itself then).
  Future<void> _show(ServerState state) async {
    if (_dialogOpen) {
      return;
    }
    _dialogOpen = true;
    try {
      await Get.dialog<void>(MaintenanceDialog(first: state), barrierDismissible: false, barrierColor: Colors.black.withValues(alpha: 0.88));
    } finally {
      _dialogOpen = false;
      _failures = 0;
    }
  }
}
