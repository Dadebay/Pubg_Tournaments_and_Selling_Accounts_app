// ignore_for_file: file_names

import 'dart:convert';
import 'dart:io';

import 'package:game_app/controllers/home_page_controller.dart';
import 'package:http/http.dart' as http;

import '../views/constants/index.dart';
import 'user_models/auth_model.dart';

class AccountsForSaleModel extends GetxController {
  final int? id;
  final String? bio;
  final String? createdDate;
  final String? email;
  final String? firstName;
  final bool? forSale;
  final String? image;
  final String? lastName;
  final int? location;
  final String? nickname;
  final String? phone;
  final String? points;
  final String? pointsFromTurnir;
  final String? price;
  final String? pubgId;
  final String? updatedDate;
  final int? user;
  final bool? verified;
  final bool? vip;

  AccountsForSaleModel({
    this.id,
    this.vip,
    this.location,
    this.user,
    this.verified,
    this.forSale,
    this.bio,
    this.createdDate,
    this.email,
    this.firstName,
    this.image,
    this.lastName,
    this.nickname,
    this.phone,
    this.points,
    this.pointsFromTurnir,
    this.price,
    this.pubgId,
    this.updatedDate,
  });

  factory AccountsForSaleModel.fromJson(Map<dynamic, dynamic> json) {
    return AccountsForSaleModel(
      id: json['id'] ?? 0,
      lastName: json['last_name'] ?? '',
      verified: json['verified'] ?? false,
      forSale: json['for_sale'] ?? false,
      bio: json['bio'] ?? '',
      createdDate: json['created_date'] ?? '',
      email: json['email'] ?? '',
      vip: json['vip'] ?? false,
      user: json['user'] ?? 0,
      location: json['location'] ?? 0,
      firstName: json['first_name'] ?? '',
      image: json['image'] ?? '',
      nickname: json['pubg_username'] ?? '',
      phone: json['phone'] ?? '',
      points: json['points'] ?? '',
      pointsFromTurnir: json['points_from_turnir'] ?? '',
      price: json['price'] ?? '',
      pubgId: json['pubg_id'] ?? '',
      updatedDate: json['updated_date'] ?? '',
    );
  }

  Future<List<AccountsForSaleModel>> getAccounts({required Map<String, String> parametrs}) async {
    final List<AccountsForSaleModel> accountList = [];
    Get.find<HomePageController>().loading.value = 0;
    final response = await http.get(
      Uri.parse(
        '$serverURL/api/accounts/get-accounts/',
      ).replace(queryParameters: parametrs),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      final decoded = utf8.decode(response.bodyBytes);
      final responseJson = json.decode(decoded);
      for (final Map product in responseJson['results']) {
        accountList.add(AccountsForSaleModel.fromJson(product));
        Get.find<HomePageController>().list.add(AccountsForSaleModel.fromJson(product));
      }
      Get.find<HomePageController>().loading.value = 1;
      return accountList;
    } else if (response.statusCode == 404) {
      Get.find<HomePageController>().loading.value = 1;
      Get.find<HomePageController>().pageNumber.value -= 1;
      return [];
    } else {
      Get.find<HomePageController>().loading.value = 2;
      return [];
    }
  }

  // Future<List<AccountsForSaleModel>> getTypeAccounts({required Map<String, String> parametrs, required int type}) async {
  //   final List<AccountsForSaleModel> accountList = [];
  //   final ShowAllAccountsController controller = Get.put(ShowAllAccountsController());
  //   final response = await http.get(
  //     Uri.parse(
  //       '$serverURL/api/accounts/type-accounts/$type/',
  //     ).replace(queryParameters: parametrs),
  //     headers: <String, String>{
  //       HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
  //     },
  //   );
  //   if (response.statusCode == 200) {
  //     final decoded = utf8.decode(response.bodyBytes);
  //     final responseJson = json.decode(decoded);
  //     for (final Map product in responseJson['results']) {
  //       if (AccountsForSaleModel.fromJson(product).forSale == true) {
  //         accountList.add(AccountsForSaleModel.fromJson(product));
  //         controller.list.add(AccountsForSaleModel.fromJson(product));
  //       }
  //     }
  //     return accountList;
  //   } else if (response.statusCode == 404) {
  //     controller.pageNumber.value -= 1;
  //     return [];
  //   } else {
  //     Get.find<HomePageController>().loading.value = 2;
  //     return [];
  //   }
  // }
}

class PostByIdModel extends GetxController {
  final int? id;
  final String? pubgUsername;
  final String? pubgId;
  final String? firsName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? bio;
  final String? points;
  final String? pointsFromTurnir;
  final String? image;
  final String? bgImage;
  final bool? verified;
  final bool? vip;
  final bool? blocked;
  final String? blockedReason;
  final String? blockedDate;
  final String? referalCode;
  final String? usedReferalCode;
  final String? createdDate;
  final int? user;
  final int? location;

  PostByIdModel({
    this.id,
    this.pubgUsername,
    this.pubgId,
    this.firsName,
    this.lastName,
    this.email,
    this.bgImage,
    this.phone,
    this.bio,
    this.points,
    this.pointsFromTurnir,
    this.image,
    this.verified,
    this.vip,
    this.createdDate,
    this.user,
    this.location,
    this.blocked,
    this.blockedDate,
    this.blockedReason,
    this.referalCode,
    this.usedReferalCode,
  });

  factory PostByIdModel.fromJson(Map<dynamic, dynamic> json) {
    return PostByIdModel(
      id: json['id'] ?? 0,
      pubgUsername: json['pubg_username'] ?? 'null',
      pubgId: json['pubg_id'] ?? 'null',
      firsName: json['first_name'] ?? 'null',
      lastName: json['last_name'] ?? 'null',
      email: json['email'] ?? 'null',
      phone: json['phone'] ?? 'null',
      bio: json['bio'] ?? 'null',
      points: json['points'] ?? 'null',
      pointsFromTurnir: json['points_from_turnir'] ?? 'null',
      image: json['image'] ?? 'null',
      bgImage: json['bg_image'] ?? 'null',
      verified: json['verified'] ?? false,
      vip: json['vip'] ?? true,
      createdDate: json['created_date'] ?? 'null',
      user: json['user'] ?? 0,
      location: json['location'] ?? 0,
      blocked: json['blocked'] ?? false,
      blockedDate: json['blocked_date'] ?? 'null',
      blockedReason: json['blocked_reason'] ?? 'null',
      referalCode: json['ref_code'] ?? 'null',
      usedReferalCode: json['used_ref_code'] ?? 'null',
    );
  }

  Future<PostByIdModel> getMe() async {
    final token = await Auth().getToken();

    final response = await http.get(
      Uri.parse(
        '$serverURL/api/accounts/get-my-account/',
      ),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final decoded = utf8.decode(response.bodyBytes);
      final responseJson = json.decode(decoded);
      return PostByIdModel.fromJson(responseJson);
    } else {
      return PostByIdModel();
    }
  }
}

class GetAccountVideos {
  final int? id;
  final String? poster;
  final String? video;
  GetAccountVideos({
    this.id,
    this.video,
    this.poster,
  });

  factory GetAccountVideos.fromJson(Map<dynamic, dynamic> json) {
    return GetAccountVideos(
      id: json['id'],
      video: json['video'],
      poster: json['poster'],
    );
  }

  Future<List<GetAccountVideos>> getVideos(int id) async {
    final List<GetAccountVideos> accountList = [];

    final response = await http.get(
      Uri.parse(
        '$serverURL/api/accounts/get-videos/$id/',
      ),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      final decoded = utf8.decode(response.bodyBytes);
      final responseJson = json.decode(decoded);
      for (final Map product in responseJson) {
        accountList.add(GetAccountVideos.fromJson(product));
      }
      return accountList;
    } else {
      return [];
    }
  }
}
