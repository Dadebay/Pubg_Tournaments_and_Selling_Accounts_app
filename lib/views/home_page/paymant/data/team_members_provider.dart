import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:game_app/models/team_member.dart';
import 'package:flutter/foundation.dart';
import 'package:game_app/models/team_winers.dart';
import 'package:game_app/models/user_models/auth_model.dart';

class TeamMembersProvider with ChangeNotifier {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://216.250.11.240'));

  List<TeamMember> _teamMembers = [];
  List<TeamMemberWin>  _teamMembersWin = [];
  bool _isLoading = false;
  bool _isRegistering = false;
  String? _errorMessage;

  List<TeamMember> get teamMembers => _teamMembers;
   List<TeamMemberWin> get teamMembersWin => _teamMembersWin;
  bool get isLoading => _isLoading;
  bool get isRegistering => _isRegistering;
  String? get errorMessage => _errorMessage;

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
      _errorMessage = e.response?.data.toString() ?? e.message;
      print('Dio error: $_errorMessage');
    } catch (e) {
      _errorMessage = e.toString();
      print('General error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTeamGroup(String groupId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _dio.get('/api/turnirs/getteammembers/1/?quartturnir=$groupId');

      if (response.statusCode == 200 && response.data is List) {
        final List data = response.data;
        _teamMembers = data.map((e) => TeamMember.fromJson(e)).toList();
        print('Fetched ${_teamMembers.length} team members');
      } else {
        _errorMessage = 'Unexpected response format: ${response.statusCode}';
      }
    } on DioException catch (e) {
      _errorMessage = e.response?.data.toString() ?? e.message;
      print('Dio error: $_errorMessage');
    } catch (e) {
      _errorMessage = e.toString();
      print('General error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTeamHalf(String groupId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _dio.get('/api/turnirs/getteammembers/1/?halfturnir=$groupId');

      if (response.statusCode == 200 && response.data is List) {
        final List data = response.data;
        _teamMembers = data.map((e) => TeamMember.fromJson(e)).toList();
        print('Fetched ${_teamMembers.length} team members');
      } else {
        _errorMessage = 'Unexpected response format: ${response.statusCode}';
      }
    } on DioException catch (e) {
      _errorMessage = e.response?.data.toString() ?? e.message;
      print('Dio error: $_errorMessage');
    } catch (e) {
      _errorMessage = e.toString();
      print('General error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTeamFinal() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _dio.get('/api/turnirs/getteammembers/1/?finalturnir=True');

      if (response.statusCode == 200 && response.data is List) {
        final List data = response.data;
        _teamMembers = data.map((e) => TeamMember.fromJson(e)).toList();
        print('Fetched ${_teamMembers.length} team members');
      } else {
        _errorMessage = 'Unexpected response format: ${response.statusCode}';
      }
    } on DioException catch (e) {
      _errorMessage = e.response?.data.toString() ?? e.message;
      print('Dio error: $_errorMessage');
    } catch (e) {
      _errorMessage = e.toString();
      print('General error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTeamWinner() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _dio.get('/api/turnirs/getteammembers/1/?winnerturnir=True');

      if (response.statusCode == 200 && response.data is List) {
        final List data = response.data;
        _teamMembersWin = data.map((e) => TeamMemberWin.fromJson(e)).toList();
        print('Fetched ${_teamMembersWin.length} team members');
      } else {
        _errorMessage = 'Unexpected response format: ${response.statusCode}';
      }
    } on DioException catch (e) {
      _errorMessage = e.response?.data.toString() ?? e.message;
      print('Dio error: $_errorMessage');
    } catch (e) {
      _errorMessage = e.toString();
      print('General error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> registerTeam({
    required int tournamentId,
    required String account,
    required String user1,
    required String user2,
    required String user3,
  }) async {
    _isRegistering = true;
    notifyListeners();

    try {
      // Get the token
      final token = await Auth().getToken();

      final formData = FormData.fromMap({
        'account': account,
        'user_1': user1,
        'user_2': user2,
        'user_3': user3,
      });

      final response = await _dio.post(
        '/api/turnirs/buyturnir/$tournamentId/',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
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
          if (data.containsKey('detail')) {
            _errorMessage = data['detail'].toString();
          } else if (data.containsKey('error')) {
            _errorMessage = data['error'].toString();
          } else {
            // fallback: join all key-values
            _errorMessage = data.entries.map((e) => '${e.key}: ${e.value}').join('\n');
          }
        } else {
          _errorMessage = data.toString();
        }
      } else {
        _errorMessage = e.message;
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
