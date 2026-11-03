import 'dart:convert';

import 'package:http/http.dart' as http;

import '../views/constants/index.dart';

/// The first non-empty text among [keys], or null.
String? _firstText(Map<dynamic, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }
  }
  return null;
}

class BestPlayersModel {
  final int? id;
  final String? pubgUsername;
  final String? image;
  final String? points;
  BestPlayersModel({
    this.id,
    this.pubgUsername,
    this.image,
    this.points,
  });

  factory BestPlayersModel.fromJson(Map<dynamic, dynamic> json) {
    return BestPlayersModel(id: json['id'], pubgUsername: json['pubg_username'], points: '${json['points_from_turnir'] ?? json['points'] ?? '0'}', image: _firstText(json, ['image', 'avatar', 'photo', 'img', 'profile_image', 'picture']));
  }

  Future<List<BestPlayersModel>> getBestPlayers() async {
    final List<BestPlayersModel> bannerList = [];
    final response = await http.get(
      Uri.parse('$serverURL/api/accounts/best-players/'),
      headers: <String, String>{'Content-Type': 'application/json;charset=UTF-8', 'Charset': 'utf-8'},
    );
    if (response.statusCode == 200) {
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      for (final Map product in responseJson['results']) {
        bannerList.add(BestPlayersModel.fromJson(product));
      }

      return bannerList;
    } else {
      return [];
    }
  }
}

class GetKonkursUsers {
  final String? phone;
  final String? img;
  final String? pubgUsername;
  final String? pubgID;
  GetKonkursUsers({
    this.img,
    this.phone,
    this.pubgUsername,
    this.pubgID,
  });

  factory GetKonkursUsers.fromJson(Map<dynamic, dynamic> json) {
    return GetKonkursUsers(img: json['img'], pubgUsername: json['pubgUsername'], phone: json['phone'], pubgID: json['pubgID']);
  }

  Future<List<GetKonkursUsers>> getKonkustUsers({required int id}) async {
    final List<GetKonkursUsers> bannerList = [];
    final response = await http.get(
      Uri.parse('$serverURL/api/category/konkursAttends/$id/'),
      headers: <String, String>{'Content-Type': 'application/json;charset=UTF-8', 'Charset': 'utf-8'},
    );
    if (response.statusCode == 200) {
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      for (final Map product in responseJson) {
        bannerList.add(GetKonkursUsers.fromJson(product));
      }

      return bannerList;
    } else {
      return [];
    }
  }

  Future<List<GetKonkursUsers>> getKonkursWINS({required int id}) async {
    final List<GetKonkursUsers> bannerList = [];
    final response = await http.get(
      Uri.parse('$serverURL/api/category/konkursWins/$id/'),
      headers: <String, String>{'Content-Type': 'application/json;charset=UTF-8', 'Charset': 'utf-8'},
    );
    if (response.statusCode == 200) {
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      for (final Map product in responseJson) {
        bannerList.add(GetKonkursUsers.fromJson(product));
      }

      return bannerList;
    } else {
      return [];
    }
  }
}
