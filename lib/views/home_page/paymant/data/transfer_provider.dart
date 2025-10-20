import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:game_app/models/user_models/auth_model.dart';
import 'package:dio/dio.dart';

class TransferProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<void> sendTransfer({
    required String phone,
    required String amount,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    final dio = Dio();
    const url = 'http://216.250.11.240/api/sendpoint/';
    final token = await Auth().getToken();

    try {
      final numericAmount = int.tryParse(amount) ?? double.tryParse(amount);
      if (numericAmount == null) {
        _errorMessage = 'Mukdar dogry däl';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // ✅ Create FormData
      final formData = FormData.fromMap({
        'phone': phone,
        'amount': numericAmount,
      });

      final response = await dio.post(
        url,
        data: formData,
        options: Options(
          headers: {
            HttpHeaders.authorizationHeader: 'Bearer $token',
            HttpHeaders.acceptHeader: 'application/json',
          },
        ),
      );

      log('Response status: ${response.statusCode}');
      log('Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          _successMessage = 'Pul üstünlikli geçirildi!';
        } else if (data['message'] != null) {
          _successMessage = data['message'];
        } else {
          _errorMessage = 'Näbelli ýalňyşlyk ýüze çykdy.';
        }
      } else {
        _errorMessage = 'Server ýalňyşlygy: ${response.statusCode}';
      }
    } catch (e) {
      log('Error in sendTransfer: $e');
      _errorMessage = 'Baglanyşykda ýalňyşlyk bar: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
