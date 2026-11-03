// ignore_for_file: non_constant_identifier_names, file_names

import 'dart:convert';
import 'dart:io';

import 'package:game_app/models/user_models/auth_model.dart';
import 'package:http/http.dart' as http;

import '../repository/ucdayy_api.dart';
import '../views/constants/constants.dart';

/// The entries of a list answer: a bare list, or `{ results: [...] }` when paged.
Iterable<Map<dynamic, dynamic>> _listOf(dynamic json) {
  final list = json is Map ? json['results'] : json;
  return list is List ? list.whereType<Map<dynamic, dynamic>>() : const [];
}

class HistoryOrderModel {
  final int? id;
  final String? status;
  final String? created_date;
  final String? price;
  final String? pubgID;
  final String? note;
  final bool? ask;

  /// The order's UC items when the list answer carries them (same shape as the order detail).
  final List<CartItems> items;
  HistoryOrderModel({this.id, this.ask, this.pubgID, this.status, this.created_date, this.note, this.price, this.items = const []});

  factory HistoryOrderModel.fromJson(Map<dynamic, dynamic> json) {
    final rawItems = json['cart_items'] ?? json['items'];
    return HistoryOrderModel(
      id: json['id'],
      status: '${json['status'] ?? 'pending'}',
      pubgID: json['pubg_id']?.toString() ?? '',
      ask: json['ask'] ?? false,
      price: '${json['price'] ?? 0}',
      note: json['note']?.toString() ?? '',
      created_date: json['created_date']?.toString() ?? json['created_at']?.toString(),
      items: rawItems is List ? rawItems.whereType<Map>().map((e) => CartItems.fromJson(Map<String, dynamic>.from(e))).toList() : const [],
    );
  }

  /// My orders from `/carts/` (paged: `{ results: [...] }`, or a bare list).
  /// Throws when the request fails, so the page can show its error state.
  Future<List<HistoryOrderModel>> getOrders() async {
    final result = await UcdayyApi.getCarts(page: 1, pageSize: 100);
    if (!result.ok) {
      throw Exception(result.error ?? 'status ${result.statusCode}');
    }
    return apiItems(result.data).map(HistoryOrderModel.fromJson).toList();
  }
}

class BoughtGiftsModel {
  final int? id;
  final String? phone;
  final String? giftName;
  final String? code;
  BoughtGiftsModel({this.id, this.code, this.giftName, this.phone});

  factory BoughtGiftsModel.fromJson(Map<dynamic, dynamic> json) {
    return BoughtGiftsModel(
      id: json['id'],
      phone: json['phone'] ?? '+99362990344',
      code: json['code']?.toString() ?? '',
      giftName: json['gift_name'].toString(),
    );
  }

  Future<List<BoughtGiftsModel>> getGifts() async {
    final token = await Auth().getToken();
    final List<BoughtGiftsModel> tournamentList = [];
    final response = await http.get(
      Uri.parse(
        '$serverURL/api/category/getPromocodes/',
      ),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final decoded = utf8.decode(response.bodyBytes);
      final responseJson = json.decode(decoded);
      for (final product in _listOf(responseJson)) {
        tournamentList.add(BoughtGiftsModel.fromJson(product));
      }
      return tournamentList;
    } else {
      return [];
    }
  }
}

class BoughtThingsModel {
  final String? thingCommonPrice;
  final String? thingName;
  final String? thingCount;
  final String? asking;
  BoughtThingsModel({this.thingCommonPrice, this.thingCount, this.asking, this.thingName});

  factory BoughtThingsModel.fromJson(Map<dynamic, dynamic> json) {
    return BoughtThingsModel(
      thingName: json['thing_name'].toString(),
      thingCount: json['thing_count'].toString(),
      asking: json['asking'].toString(),
      thingCommonPrice: json['thingCommonPrice'].toString(),
    );
  }

  Future<List<BoughtThingsModel>> getGifts() async {
    final token = await Auth().getToken();
    // const token = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzYwNjkyODIxLCJpYXQiOjE3MjkxNTY4MjEsImp0aSI6IjY4NDRlNjVkMWZmODQ3MDY4NDc4MDg0NzhkZTJmY2M3IiwidXNlcl9pZCI6NDc4fQ.-CqApdrLph6D1cS7Px_delAVCyPkG_ZvPe-91SzwQk8';
    final List<BoughtThingsModel> testList = [];
    final response = await http.get(
      Uri.parse(
        '$serverURL/api/category/getMyThings/',
      ),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final decoded = utf8.decode(response.bodyBytes);
      final responseJson = json.decode(decoded);
      for (final product in _listOf(responseJson)) {
        testList.add(BoughtThingsModel.fromJson(product));
      }
      return testList;
    } else {
      return [];
    }
  }
}

class BoughtKonkursModel {
  final int? id;
  final String? phone;
  final String? code;

  final String? konkursName;
  final String? price;
  final String? finishDate;
  final String? finishTime;
  BoughtKonkursModel({this.id, this.code, this.phone, this.finishDate, this.finishTime, this.konkursName, this.price});

  factory BoughtKonkursModel.fromJson(Map<dynamic, dynamic> json) {
    return BoughtKonkursModel(
      id: json['id'],
      phone: json['phone'] ?? '+99362990344',
      code: json['code']?.toString() ?? '',
      konkursName: json['Konkurs_name'].toString(),
      price: json['price'].toString(),
      finishDate: json['finished_date'].toString(),
      finishTime: json['finished_time'].toString(),
    );
  }

  Future<List<BoughtKonkursModel>> getMyKonkurs() async {
    final token = await Auth().getToken();
    final List<BoughtKonkursModel> tournamentList = [];
    final response = await http.get(
      Uri.parse(
        '$serverURL/api/category/getKonkursKart/',
      ),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final decoded = utf8.decode(response.bodyBytes);
      final responseJson = json.decode(decoded);
      for (final product in _listOf(responseJson)) {
        tournamentList.add(BoughtKonkursModel.fromJson(product));
      }
      return tournamentList;
    } else {
      return [];
    }
  }
}

class GetBoughtKonkursByIDModel {
  final String? code;

  final String? konkursName;
  final String? price;
  GetBoughtKonkursByIDModel({this.code, this.konkursName, this.price});

  factory GetBoughtKonkursByIDModel.fromJson(Map<dynamic, dynamic> json) {
    return GetBoughtKonkursByIDModel(
      code: json['code']?.toString() ?? '',
      konkursName: json['kon_name'].toString(),
      price: json['kon_price'].toString(),
    );
  }

  Future<List<GetBoughtKonkursByIDModel>> getMyKonkursByID({required int id}) async {
    final token = await Auth().getToken();
    final List<GetBoughtKonkursByIDModel> tournamentList = [];
    final response = await http.get(
      Uri.parse(
        '$serverURL/api/category/getMyKonkursId/$id/',
      ),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final decoded = utf8.decode(response.bodyBytes);
      final responseJson = json.decode(decoded);
      for (final product in _listOf(responseJson)) {
        tournamentList.add(GetBoughtKonkursByIDModel.fromJson(product));
      }
      return tournamentList;
    } else {
      return [];
    }
  }
}

class HistoryIDModel {
  final int? id;
  final String? price;
  final String? status;
  final String? note;
  final String? pubgID;
  final String? created_date;
  final List<CartItems>? cartItems;
  HistoryIDModel({this.id, this.pubgID, this.status, this.created_date, this.note, this.price, this.cartItems});

  factory HistoryIDModel.fromJson(Map<dynamic, dynamic> json) {
    return HistoryIDModel(
      id: json['id'],
      pubgID: json['pubg_id']?.toString(),
      status: '${json['status'] ?? 'pending'}',
      price: '${json['price'] ?? 0}',
      note: json['note']?.toString(),
      created_date: json['created_date']?.toString(),
      cartItems: (json['cart_items'] is List ? json['cart_items'] as List : const []).whereType<Map>().map((e) => CartItems.fromJson(Map<String, dynamic>.from(e))).toList(),
    );
  }

  /// One order from `/carts/get-cart/{id}/`.
  Future<HistoryIDModel> getOrderByID(int id) async {
    final result = await UcdayyApi.getCart(id);
    final data = result.data;
    if (!result.ok || data is! Map) {
      throw Exception(result.error ?? 'status ${result.statusCode}');
    }
    return HistoryIDModel.fromJson(data);
  }
}

class CartItems {
  final int? id;
  final int? count;
  final List<Codes>? code;
  final String? ucName;
  final String? ucImage;

  /// The price of one piece when the order was made (`this_time_price`).
  final String? unitPrice;
  CartItems({this.id, this.code, this.count, this.ucImage, this.ucName, this.unitPrice});

  factory CartItems.fromJson(Map<String, dynamic> json) {
    // The product is either flat on the item or nested under `uc`.
    final uc = json['uc'] is Map ? Map<String, dynamic>.from(json['uc'] as Map) : const <String, dynamic>{};
    final codes = json['codes'];
    return CartItems(
      id: json['id'],
      code: codes is List ? codes.whereType<Map>().map((e) => Codes.fromJson(Map<String, dynamic>.from(e))).toList() : const [],
      count: json['count'] is int ? json['count'] as int : int.tryParse('${json['count']}'),
      ucImage: (json['image'] ?? uc['image'])?.toString(),
      ucName: (json['name'] ?? json['title'] ?? uc['title'] ?? uc['name'])?.toString(),
      unitPrice: (json['this_time_price'] ?? uc['price'])?.toString(),
    );
  }
}

class Codes {
  final int? id;
  final String? code;
  Codes({
    this.id,
    this.code,
  });

  factory Codes.fromJson(Map<String, dynamic> json) {
    return Codes(
      id: json['id'],
      code: json['code'],
    );
  }
}

class TransactionHistoryModel {
  final int? id;
  final String? count;
  final bool? fromTurnir;
  final String? created_date;
  TransactionHistoryModel({
    this.id,
    this.count,
    this.fromTurnir,
    this.created_date,
  });

  factory TransactionHistoryModel.fromJson(Map<dynamic, dynamic> json) {
    return TransactionHistoryModel(
      id: json['id'],
      count: json['count'],
      fromTurnir: json['from_turnir'],
      created_date: json['created_date'],
    );
  }

  Future<List<TransactionHistoryModel>> getTransactions() async {
    final token = await Auth().getToken();
    final List<TransactionHistoryModel> tournamentList = [];
    final response = await http.get(
      Uri.parse(
        '$serverURL/api/accounts/points/',
      ),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final decoded = utf8.decode(response.bodyBytes);
      final responseJson = json.decode(decoded);
      for (final Map product in responseJson) {
        tournamentList.add(TransactionHistoryModel.fromJson(product));
      }

      return tournamentList;
    } else {
      return [];
    }
  }

  Future requestCash({
    required String fullname,
    required String phone,
    required String message,
  }) async {
    final token = await Auth().getToken();
    final response = await http.post(
      Uri.parse('$serverURL/api/about/add-message/'),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'phone': phone,
        'name': fullname,
        'message': message,
      }),
    );
    return response.statusCode;
  }
}
