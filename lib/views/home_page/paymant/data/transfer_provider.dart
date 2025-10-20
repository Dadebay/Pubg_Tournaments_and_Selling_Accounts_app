import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:game_app/models/user_models/auth_model.dart';
import 'package:http/http.dart' as http;

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

    final url = Uri.parse('http://216.250.11.240/api/sendpoint/');
    final token = await Auth().getToken();

    try {
      // Convert amount to number instead of sending as string
      final numericAmount = int.tryParse(amount) ?? double.tryParse(amount);

      if (numericAmount == null) {
        _errorMessage = 'Mukdar dogry däl';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await http.post(
        url,
        headers: <String, String>{
          HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
        body: jsonEncode({
          'phone': phone,
          'amount': amount,
        }),
      );

      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _successMessage = data['message'] ?? 'Pul üstünlikli geçirildi!';
      } else {
        // Handle error responses
        try {
          final data = jsonDecode(response.body);
          if (data['error'] != null) {
            _errorMessage = data['error'];
          } else if (data['detail'] != null) {
            _errorMessage = data['detail'];
          } else {
            _errorMessage = 'Näbelli ýalňyşlyk ýüze çykdy.';
          }
        } catch (e) {
          _errorMessage = 'Server ýalňyşlygy: ${response.statusCode}';
        }
      }
    } catch (e) {
      log('Error in sendTransfer: $e');
      _errorMessage = 'Baglanyşykda ýalňyşlyk bar: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Clear messages
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
