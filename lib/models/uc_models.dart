// ignore_for_file: non_constant_identifier_names, file_names

import 'dart:convert';
import 'dart:io';

import 'package:game_app/repository/ucdayy_api.dart';
import 'package:game_app/views/constants/index.dart';
import 'package:game_app/views/wallet/open_online_payment_url.dart';
import 'package:game_app/views/wallet/payment_banks.dart';
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

  /// Orders the UC items of [list] through `/carts/add-cart/` and answers with the
  /// status code. Items that are not UC packages are not part of the shop API.
  Future<int> addCart(List list, {String? pubgId}) async {
    final items = [
      for (final item in list)
        if (item['status'] == 'uc') {'uc': item['id'] as int, 'count': item['count'] as int},
    ];
    final result = await UcdayyApi.addCart(items: items, pubgId: pubgId);
    return result.statusCode;
  }

  Future addCartPlasticCARD(List list, bool buything, bool buykonkurs) async {
    final bankId = await PaymentFlow.pickBank();
    if (bankId == null) {
      return null;
    }
    final result = await UcdayyApi.registerBasketCard([for (final line in list) Map<String, Object?>.from(line as Map)], bankId: bankId);
    final registration = result.ok ? CardRegistration.tryParse(result.data) : null;
    if (registration == null) {
      showSnackBar('noConnection3', PaymentFlow.errorKey(result), Colors.red);
      return null;
    }
    // The page answers with the status code of the status call (200 paid, 409 stock ran out).
    return Get.to(
      () => OpenOnlinePaymentWebsite(
        registration: registration,
        list: list,
        thingBuy: buything,
        konkursBuy: buykonkurs,
      ),
    );
  }

  /// Every product of one category, following the pages of the answer.
  /// Null when the request fails, so the page can offer a retry.
  static Future<List<UcModel>?> getByCategory(int id) async {
    final List<UcModel> items = [];
    int page = 1;
    while (true) {
      final result = await UcdayyApi.getUcCategory(id, page: page > 1 ? page : null);
      if (!result.ok) {
        return page == 1 ? null : items;
      }
      items.addAll(apiItems(result.data).map(UcModel.fromJson));
      final data = result.data;
      if (data is! Map || data['next'] == null) {
        return items;
      }
      page++;
    }
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
