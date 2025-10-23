// ignore_for_file: camel_case_types, avoid_print

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:game_app/models/get_concurs_model.dart';
import 'package:game_app/models/get_gifts_model.dart';
import 'package:game_app/models/user_models/auth_model.dart';
import 'package:game_app/views/constants/index.dart';

import '../models/con_catigory.dart';
import '../models/pay_model.dart';

class ConCatigoryProvider with ChangeNotifier {
  bool isLoading = false;
  bool waiting = false;
  List<ConCatigory> conCatigory = [];

  static Dio dio = Dio();

  Future<void> getConCatigory(BuildContext context) async {
    isLoading = true;

    conCatigory = [];

    try {
      final response = await dio.get(
        '$serverURL/api/category/',
      );
      print(response.data);
      if (response.statusCode == 200) {
        if (response.data != null) {
          conCatigory = List<ConCatigory>.from(
            response.data.map((e) {
              return ConCatigory.fromJson(e);
            }),
          );
          isLoading = false;
          notifyListeners();
        }

        return;
      }
      // ignore: deprecated_member_use
    } on DioError {
      isLoading = false;

      notifyListeners();
    }
    return;
  }
}

class getGiftsProvider with ChangeNotifier {
  bool isLoading = false;
  bool waiting = false;
  List<GiftsMOdel> giftsCart = [];

  static Dio dio = Dio();

  Future<void> getGiftsCart(BuildContext context) async {
    isLoading = true;

    giftsCart = [];

    try {
      final response = await dio.get(
        '$serverURL/api/category/getGifts/',
      );
      print(response.data);
      if (response.statusCode == 200) {
        if (response.data != null) {
          giftsCart = List<GiftsMOdel>.from(
            response.data.map((e) {
              return GiftsMOdel.fromJson(e);
            }),
          );
          isLoading = false;
          notifyListeners();
        }

        return;
      }
      // ignore: deprecated_member_use
    } on DioError {
      isLoading = false;

      notifyListeners();
    }
    return;
  }

  Future<String> getGiftData() async {
    isLoading = true;

    try {
      final response = await dio.get(
        '$serverURL/api/category/getText/7/',
      );
      print(response.data);
      print(response.statusCode);
      if (response.statusCode == 200) {
        if (response.data != null) {
          isLoading = false;
          notifyListeners();
          return response.data[0]['toptext'];
        }

        return '';
      }
      // ignore: deprecated_member_use
    } on DioError {
      isLoading = false;

      notifyListeners();
    }
    return '';
  }
}

class getConcursProvider with ChangeNotifier {
  bool isLoading = false;
  bool waiting = false;
  List<GEtConcursModel> concursCart = [];

  static Dio dio = Dio();

  Future<void> getConcursCart(BuildContext context) async {
    isLoading = true;

    concursCart = [];

    try {
      final response = await dio.get(
        '$serverURL/api/category/getkonkurs/',
      );

      if (response.statusCode == 200) {
        if (response.data != null) {
          concursCart = List<GEtConcursModel>.from(
            response.data.map((e) {
              return GEtConcursModel.fromJson(e);
            }),
          );
          isLoading = false;
          notifyListeners();
        }

        return;
      }
      // ignore: deprecated_member_use
    } on DioError {
      isLoading = false;

      notifyListeners();
    }
    return;
  }
}

class getConcursByIDProvider with ChangeNotifier {
  bool isLoading = false;
  bool waiting = false;
  GEtConcursModel? concursCartById;

  static Dio dio = Dio();

  Future<void> getConcursCartById(BuildContext context, String id) async {
    isLoading = true;

    try {
      final response = await dio.get(
        '$serverURL/api/category/getkonkurs/$id/',
      );

      if (response.statusCode == 200) {
        if (response.data != null) {
          concursCartById = GEtConcursModel.fromJson(response.data);
          print(response.data);
          isLoading = false;
          notifyListeners();
        }

        return;
      }
      // ignore: deprecated_member_use
    } on DioError {
      isLoading = false;

      notifyListeners();
    }
    return;
  }
}

class postPaymentProvider with ChangeNotifier {
  bool isLoading = false;
  bool waiting = false;

  PayModel? payModel;

  static Dio dio = Dio();

  Future postPayment(String amount) async {
    isLoading = true;

    final token = await Auth().getToken();

    final headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };

    try {
      final response = await dio.post(
        '$serverURL/api/carts/pay/',
        data: jsonEncode({
          'amount': amount,
        }),
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        if (response.data != null) {
          payModel = PayModel.fromJson(response.data);
          print(response.data);
          isLoading = false;
          notifyListeners();
        }

        return response.statusCode;
      }
      // ignore: deprecated_member_use
    } on DioError {
      isLoading = false;

      notifyListeners();
    }
    return;
  }
}
