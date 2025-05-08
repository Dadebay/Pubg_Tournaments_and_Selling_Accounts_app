import 'dart:convert';
import 'dart:io';

import 'package:game_app/models/accouts_for_sale_model.dart';
import 'package:http/http.dart' as http;

import '../views/constants/index.dart';

class GetPostsAccountModel {
  final int? id;
  final String? pubgUserName;
  final String? pubgID;
  final String? pubgType;
  final String? price;
  final String? title;
  final String? desc;
  final String? phone;
  final String? image;
  final String? bgImage;
  final String? createdAt;
  final bool? vip;
  final PostByIdModel? user;
  final List<GetAccountVideos>? videos;
  GetPostsAccountModel({this.id, this.bgImage, this.pubgUserName, this.pubgID, this.image, this.createdAt, this.price, this.desc, this.pubgType, this.title, this.vip, this.user, this.videos, this.phone});

  factory GetPostsAccountModel.fromJson(Map<dynamic, dynamic> json) {
    return GetPostsAccountModel(
      id: json['id'] ?? 1,
      bgImage: json['bg_image'] ?? '',
      pubgUserName: json['pubg_username'] ?? 'Pubg',
      pubgID: json['pubg_id'] ?? 1,
      image: json['image'] ?? '',
      createdAt: json['created_at'] ?? '',
      phone: json['phone'] ?? '',
      price: json['price'] ?? '0.0',
      desc: json['description'] ?? '0.0',
      pubgType: json['pubg_type'] ?? '0.0',
      title: json['title'] ?? '0.0',
      vip: json['vip'] ?? '0.0',
      user: json['user'] == null ? PostByIdModel() : PostByIdModel.fromJson(json['user']),
      videos: json['videos'] == null ? [] : ((json['videos'] ?? []) as List).map((json) => GetAccountVideos.fromJson(json)).toList(),
    );
  }

  Future<List<GetPostsAccountModel>> getVIPPosts({required Map<String, String> parametrs}) async {
    final List<GetPostsAccountModel> pubgPost = [];
    print(parametrs);
    final response = await http.get(
      Uri.parse(
        '$serverURL/api/accounts/get-vip-posts/',
      ).replace(queryParameters: parametrs),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      final decoded = utf8.decode(response.bodyBytes);
      final responseJson = json.decode(decoded)['results'];
      for (final Map product in responseJson) {
        print(GetPostsAccountModel.fromJson(product).id);
        pubgPost.add(GetPostsAccountModel.fromJson(product));
      }
      return pubgPost;
    } else {
      return [];
    }
  }

  Future<List<GetPostsAccountModel>> getPosts({required Map<String, String> parametrs}) async {
    final List<GetPostsAccountModel> pubgPost = [];

    final response = await http.get(
      Uri.parse(
        '$serverURL/api/accounts/get-posts/',
      ).replace(queryParameters: parametrs),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
      },
    );
    print(parametrs);
    print(response.body);
    if (response.statusCode == 200) {
      final decoded = utf8.decode(response.bodyBytes);
      final responseJson = json.decode(decoded)['results'];

      for (final Map product in responseJson) {
        print(GetPostsAccountModel.fromJson(product).id);
        pubgPost.add(GetPostsAccountModel.fromJson(product));
      }
      return pubgPost;
    } else {
      return [];
    }
  }

  Future<GetPostsAccountModel> getPostById(int id) async {
    final response = await http.get(
      Uri.parse(
        '$serverURL/api/accounts/get-post/$id/',
      ),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      final decoded = utf8.decode(response.bodyBytes);
      final responseJson = json.decode(decoded);
      return GetPostsAccountModel.fromJson(responseJson);
    } else {
      return GetPostsAccountModel();
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

  Future<List<GetAccountVideos>> getVideosById(int id) async {
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
