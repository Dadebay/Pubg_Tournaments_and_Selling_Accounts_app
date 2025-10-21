import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:game_app/models/turnir.dart';

class TournamentProvider with ChangeNotifier {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://216.250.11.240'));

  List<Tournament> _tournaments = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Tournament> get tournaments => _tournaments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchTournaments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _dio.get('/api/turnirs/getturnirs/');

      if (response.statusCode == 200 && response.data is List) {
        final List data = response.data;
        _tournaments = data.map((e) => Tournament.fromJson(e)).toList();
        // if (kDebugMode) {
        print('Fetched ${response.data} tournaments');
        // }
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
}
