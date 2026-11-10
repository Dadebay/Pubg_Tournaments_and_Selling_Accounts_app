import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:game_app/models/team_member.dart';
import 'package:flutter/foundation.dart';
import 'package:game_app/models/team_winers.dart';
import 'package:game_app/models/user_models/auth_model.dart';
import 'package:game_app/views/constants/constants.dart';
import 'package:get/get.dart' hide FormData, Response;

/// A message the player can read. A server crash answers with a whole HTML page (the Django
/// error page) and a 5xx status; that must never reach the screen, so it becomes a short notice.
String friendlyError(dynamic data, int? status, [String? fallback]) {
  final text = '${data ?? ''}'.trim();
  final looksLikeHtml = text.startsWith('<') || text.toLowerCase().contains('<!doctype') || text.toLowerCase().contains('<html');
  if (looksLikeHtml || (status != null && status >= 500)) {
    return 'serverError'.tr;
  }
  if (text.isNotEmpty) {
    return text.length > 200 ? '${text.substring(0, 200)}…' : text;
  }
  return (fallback ?? '').isEmpty ? 'tournamentInfo14'.tr : fallback!;
}

class TeamMembersProvider with ChangeNotifier {
  final Dio _dio = Dio(BaseOptions(baseUrl: serverURL));

  List<TeamMember> _teamMembers = [];
  List<TeamMemberWin> _teamMembersWin = [];
  bool _isLoading = false;
  bool _isRegistering = false;
  String? _errorMessage;

  List<TeamMember> get teamMembers => _teamMembers;
  List<TeamMemberWin> get teamMembersWin => _teamMembersWin;
  bool get isLoading => _isLoading;
  bool get isRegistering => _isRegistering;
  String? get errorMessage => _errorMessage;

  /// Why the last team registration failed (kept apart so it never shows in the team lists).
  String? _registerError;
  String? get registerError => _registerError;

  Future<void> fetchTeamMembers(int tournamentId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _dio.get('/api/turnirs/getteammembers/$tournamentId/');

      if (response.statusCode == 200 && response.data is List) {
        final List data = response.data;
        _teamMembers = data.map((e) => TeamMember.fromJson(e)).toList();
        print('Fetched ${_teamMembers.length} team members');
      } else {
        _errorMessage = 'Unexpected response format: ${response.statusCode}';
      }
    } on DioException catch (e) {
      _errorMessage = friendlyError(e.response?.data, e.response?.statusCode, e.message);
      print('Dio error: $_errorMessage');
    } catch (e) {
      _errorMessage = e.toString();
      print('General error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTeamGroup(String groupId, int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _dio.get('/api/turnirs/getteammembers/$id/?quartturnir=$groupId');

      if (response.statusCode == 200 && response.data is List) {
        final List data = response.data;
        _teamMembers = data.map((e) => TeamMember.fromJson(e)).toList();
        print('Fetched ${_teamMembers.length} team members');
      } else {
        _errorMessage = 'Unexpected response format: ${response.statusCode}';
      }
    } on DioException catch (e) {
      _errorMessage = friendlyError(e.response?.data, e.response?.statusCode, e.message);
      print('Dio error: $_errorMessage');
    } catch (e) {
      _errorMessage = e.toString();
      print('General error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTeamHalf(String groupId, int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _dio.get('/api/turnirs/getteammembers/$id/?halfturnir=$groupId');

      if (response.statusCode == 200 && response.data is List) {
        final List data = response.data;
        _teamMembers = data.map((e) => TeamMember.fromJson(e)).toList();
        print('Fetched ${_teamMembers.length} team members');
      } else {
        _errorMessage = 'Unexpected response format: ${response.statusCode}';
      }
    } on DioException catch (e) {
      _errorMessage = friendlyError(e.response?.data, e.response?.statusCode, e.message);
      print('Dio error: $_errorMessage');
    } catch (e) {
      _errorMessage = e.toString();
      print('General error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTeamFinal(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _dio.get('/api/turnirs/getteammembers/$id/?finalturnir=True');

      if (response.statusCode == 200 && response.data is List) {
        final List data = response.data;
        _teamMembers = data.map((e) => TeamMember.fromJson(e)).toList();
        print('Fetched ${_teamMembers.length} team members');
      } else {
        _errorMessage = 'Unexpected response format: ${response.statusCode}';
      }
    } on DioException catch (e) {
      _errorMessage = friendlyError(e.response?.data, e.response?.statusCode, e.message);
      print('Dio error: $_errorMessage');
    } catch (e) {
      _errorMessage = e.toString();
      print('General error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTeamWinner(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _dio.get('/api/turnirs/getteammembers/$id/?winnerturnir=True');

      if (response.statusCode == 200 && response.data is List) {
        final List data = response.data;
        _teamMembersWin = data.map((e) => TeamMemberWin.fromJson(e)).toList();
        print('Fetched ${_teamMembersWin.length} team members');
      } else {
        _errorMessage = 'Unexpected response format: ${response.statusCode}';
      }
    } on DioException catch (e) {
      _errorMessage = friendlyError(e.response?.data, e.response?.statusCode, e.message);
      print('Dio error: $_errorMessage');
    } catch (e) {
      _errorMessage = e.toString();
      print('General error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> registerTeam({required int tournamentId, required String account, required String extra_name, required String user1, required String user2, required String user3}) async {
    _isRegistering = true;
    notifyListeners();

    try {
      // Get the token
      final token = await Auth().getToken();

      // `tournamentId` is the slot id (`id` from getteammembers). Text fields only, no files.
      final response = await _dio.post(
        '/api/turnirs/buyturnir/$tournamentId/',
        data: {'name': account, 'extra_name': extra_name, 'user_1': user1, 'user_2': user2, 'user_3': user3},
        options: Options(headers: {'Authorization': 'Bearer $token'}, contentType: Headers.jsonContentType),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Team registered successfully');
        _isRegistering = false;
        notifyListeners();

        // Refresh team members list
        await fetchTeamMembers(tournamentId);
        return true;
      } else {
        _isRegistering = false;
        notifyListeners();
        return false;
      }
    } on DioException catch (e) {
      _isRegistering = false;

      // Improved error parsing
      if (e.response != null && e.response!.data != null) {
        final data = e.response!.data;

        if (data is Map<String, dynamic>) {
          if (data['premium_required'] == true) {
            _registerError = 'premiumRequired'.tr;
          } else if (data['code'] == 'blocked') {
            _registerError = 'accountBlocked'.tr;
          } else if (data['error'] == "You don't have enough money") {
            _registerError = 'money_error_subtitle'.tr;
          } else if (data.containsKey('detail')) {
            _registerError = data['detail'].toString();
          } else if (data.containsKey('error')) {
            _registerError = data['error'].toString();
          } else {
            // fallback: join all key-values
            _registerError = data.entries.map((e) => '${e.key}: ${e.value}').join('\n');
          }
        } else {
          _registerError = friendlyError(data, e.response?.statusCode, e.message);
        }
      } else {
        _registerError = friendlyError(null, null, e.message);
      }

      notifyListeners();
      log('Registration error: ${e.response?.data ?? e.message}');
      return false;
    } catch (e) {
      _isRegistering = false;
      notifyListeners();
      print('General error: $e');
      return false;
    }
  }

  void clearData() {
    _teamMembers = [];
    _errorMessage = null;
    notifyListeners();
  }
}
