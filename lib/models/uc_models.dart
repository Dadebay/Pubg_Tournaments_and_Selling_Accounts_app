// ignore_for_file: non_constant_identifier_names, file_names

import 'dart:convert';
import 'dart:io';

import 'package:game_app/models/user_models/auth_model.dart';
import 'package:game_app/views/constants/index.dart';
import 'package:game_app/views/wallet/open_online_payment_url.dart';
import 'package:http/http.dart' as http;

class UcModel {
  final int? id;
  final String? price;
  final String? liraPrice;
  final String? rublePrice;
  final String? title;
  final String? description_tm;
  final String? description_ru;
  final String? image;
  final String? created_date;
  UcModel({
    this.id,
    this.title,
    this.liraPrice,
    this.rublePrice,
    this.description_tm,
    this.description_ru,
    this.image,
    this.created_date,
    this.price,
  });

  factory UcModel.fromJson(Map<dynamic, dynamic> json) {
    return UcModel(
      id: json['id'] ?? 0,
      price: json['price'] ?? 'null',
      rublePrice: json['ruble_price'] ?? 'null',
      liraPrice: json['lira_price'] ?? 'null',
      title: json['title'] ?? 'null',
      image: json['image'] ?? 'null',
      description_tm: json['description_tm'] ?? 'null',
      description_ru: json['description_ru'] ?? 'null',
      created_date: json['created_date'] ?? 'null',
    );
  }

  Future addCart(List list) async {
    final String? token = await Auth().getToken();
    final response = await http.post(
      Uri.parse('$serverURL/api/category/paymentFromPoint/'),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
      body: jsonEncode(list),
    );
    return response.statusCode;
  }

  Future addCartPlasticCARD(List list, bool buything, bool buykonkurs) async {
    final String? token = await Auth().getToken();
    final response = await http.post(
      Uri.parse('$serverURL/api/category/payment/'),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
      body: jsonEncode(list),
    );
    await Get.to(
      () => OpenOnlinePaymentWebsite(
        url: jsonDecode(response.body)['formUrl'],
        list: list,
        thingBuy: buything,
        konkursBuy: buykonkurs,
      ),
    );
  }

  Future<List<UcModel>> getUCS({int? category}) async {
    final List<UcModel> ucList = [];
    final response = await http.get(
      Uri.parse(
        '$serverURL/api/ucs/',
      ).replace(queryParameters: category == null ? null : {'category': '$category'}),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      final decoded = utf8.decode(response.bodyBytes);
      final responseJson = json.decode(decoded);
      for (final Map product in responseJson['results']) {
        ucList.add(UcModel.fromJson(product));
      }
      return ucList;
    } else {
      return [];
    }
  }
}
