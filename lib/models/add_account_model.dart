// ignore_for_file: file_names, non_constant_identifier_names

import 'dart:convert';
import 'dart:io';

import 'package:game_app/views/constants/index.dart';
import 'package:http/http.dart' as http;

import 'user_models/auth_model.dart';

class AddAccountModel extends GetxController {
  final int? id;
  final String? nickname;

  final String? price_for_vip;
  final String? price_for_not_vip;
  final String? price_for_ref;
  final String? phone_one;
  final String? phone_two;
  final String? phone_three;
  final String? text;

  final int? pubgType;
  final int? location;
  final bool? forSale;
  final bool? vip;
  final String? phone;
  final String? bio;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? image;
  final String? price;
  final String? pubgId;

  final String? text_one;
  final String? text_two;
  final String? text_three;

  AddAccountModel({
    this.id,
    this.pubgType,
    this.vip,
    this.location,
    this.forSale,
    this.bio,
    this.email,
    this.firstName,
    this.image,
    this.lastName,
    this.nickname,
    this.phone,
    this.price,
    this.pubgId,
    this.price_for_vip,
    this.price_for_not_vip,
    this.price_for_ref,
    this.phone_one,
    this.phone_two,
    this.phone_three,
    this.text,
    this.text_one,
    this.text_two,
    this.text_three,
  });

  factory AddAccountModel.fromJson(Map<dynamic, dynamic> json) {
    return AddAccountModel(
      id: json['id'],
      pubgType: json['pubg_type'],
      lastName: json['last_name'],
      forSale: json['for_sale'],
      bio: json['bio'],
      email: json['email'],
      vip: json['vip'],
      location: json['location'],
      firstName: json['first_name'],
      image: json['image'],
      nickname: json['pubg_username'],
      phone: json['phone'],
      price: json['price'],
      pubgId: json['pubg_id'],
      price_for_vip: json['price_for_vip'],
      price_for_not_vip: json['price_for_not_vip'],
      price_for_ref: json['price_for_ref'],
      phone_one: json['phone_one'],
      phone_two: json['phone_two'],
      phone_three: json['phone_three'],
      text: json['text'],
      text_one: json['text_one'],
      text_two: json['text_two'],
      text_three: json['text_three'],
    );
  }

  // Future getConsts() async {
  //   final response = await http.get(
  //     Uri.parse('$serverURL/api/about/consts/'),
  //     headers: <String, String>{
  //       HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
  //     },
  //   );
  //   if (response.statusCode == 200) {
  //     final decoded = utf8.decode(response.bodyBytes);
  //     return json.decode(decoded);
  //   } else {
  //     return false;
  //   }
  // }

  Future getConsts() async {
    final response = await http.get(
      Uri.parse('$serverURL/api/about/nomerler/'),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      final decoded = utf8.decode(response.bodyBytes);
      return json.decode(decoded);
    } else {
      return false;
    }
  }

  Future deleteVideo({
    required int id,
  }) async {
    final token = await Auth().getToken();
    final response = await http.post(
      Uri.parse('$serverURL/api/accounts/delete-video/$id'),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );
    return response.statusCode;
  }
}
