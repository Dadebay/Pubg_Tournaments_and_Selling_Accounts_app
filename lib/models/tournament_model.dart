// ignore_for_file: non_constant_identifier_names, unnecessary_statements

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:game_app/controllers/tournament_controller.dart';
import 'package:game_app/models/user_models/auth_model.dart';
import 'package:http/http.dart' as http;

import '../views/constants/index.dart';
import 'accouts_for_sale_model.dart';

class TournamentModel {
  final List<Awards>? awards;
  final String? description_ru;
  final String? description_tm;
  final String? finish_date;
  final int? id;
  final String? image;
  final String? map;
  final String? mode;
  final String? type;
  final List<ParticipatedUsers>? participated_users;
  final String? price;
  final String? start_date;
  final String? title;
  final List<Winners>? winners;
  final List<Teams>? teams;

  TournamentModel({this.id, this.awards, this.description_ru, this.teams, this.description_tm, this.finish_date, this.image, this.map, this.mode, this.type, this.participated_users, this.price, this.start_date, this.title, this.winners});

  factory TournamentModel.fromJson(Map<dynamic, dynamic> json) {
    return TournamentModel(
      id: json['id'],
      title: json['title'],
      mode: json['mode'],
      type: json['type'],
      map: json['map'],
      start_date: json['start_date'],
      finish_date: json['finish_date'],
      description_tm: json['description_tm'],
      description_ru: json['description_ru'],
      image: json['image'],
      price: json['price'].toString(),
      awards: ((json['awards'] ?? []) as List).map((json) => Awards.fromJson(json)).toList(),
      winners: ((json['winners'] ?? []) as List).map((json) => Winners.fromJson(json)).toList(),
      participated_users: ((json['participated_users'] ?? []) as List).map((json) => ParticipatedUsers.fromJson(json)).toList(),
      teams: ((json['teams'] ?? []) as List).map((json) => Teams.fromJson(json)).toList(),
    );
  }

  Future<List<TournamentModel>> getTournaments({required int type}) async {
    final TournamentController controller = Get.put(TournamentController());
    final List<TournamentModel> abc = [];
    controller.tournamentLoading.value = 0;
    final response = await http.get(
      Uri.parse(
        type == 1
            ? '$serverURL/api/turnirs/by-type/squad/'
            : type == 2
                ?'$serverURL/api/turnirs/by-type/squad/' 
                : '$serverURL/api/turnirs/by-type/duo/',
      ).replace(
        queryParameters: {
          'page': '1',
          'size': '20',
        },
      ),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
      },
    );
    log(response.body);
    if (response.statusCode == 200) {
      controller.tournamentLoading.value = 2;
      final decoded = utf8.decode(response.bodyBytes);
      final responseJson = json.decode(decoded);
      for (final Map product in responseJson['results']) {
        abc.add(TournamentModel.fromJson(product));
      }
      controller.addToList(list: abc);
      return abc;
    } else {
      controller.tournamentLoading.value = 1;
      return [];
    }
  }

  Future<TournamentModel> getTournamentID(int id) async {
    final response = await http.get(
      Uri.parse(
        '$serverURL/api/turnirs/turnir/$id/',
      ),
      headers: <String, String>{
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8',
      },
    );
    if (response.statusCode == 200) {
      final decoded = utf8.decode(response.bodyBytes);
      final responseJson = json.decode(decoded);
      return TournamentModel.fromJson(responseJson);
    } else {
      return TournamentModel();
    }
  }

  Future checkStatus({required int tournamentID, required bool value}) async {
    final token = await Auth().getToken();
    final response = await http.get(
      Uri.parse('$serverURL/api/turnirs/get-code/$tournamentID'),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final decoded = utf8.decode(response.bodyBytes);
      final responseJson = json.decode(decoded);
      if (value) {
        Get.snackbar(
          'tournamentInfo15',
          "${responseJson["code"]}",
          snackStyle: SnackStyle.FLOATING,
          titleText: title == ''
              ? const SizedBox.shrink()
              : Text(
                  'tournamentInfo15'.tr,
                  style: const TextStyle(fontFamily: josefinSansSemiBold, fontSize: 18, color: Colors.white),
                ),
          messageText: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'lobid'.tr,
                    style: const TextStyle(fontFamily: josefinSansSemiBold, fontSize: 18, color: Colors.white),
                  ),
                  Text(
                    "${responseJson["lobb_id"]}".tr,
                    style: const TextStyle(fontFamily: josefinSansRegular, fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.back();
                      Clipboard.setData(ClipboardData(text: responseJson['lobb_id'].toString())).then((value) {
                        showSnackBar('copySucces', 'copySuccesSubtitle', Colors.green);
                      });
                    },
                    child: const Icon(
                      Icons.copy_all,
                      color: Colors.black,
                      size: 30,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'code'.tr,
                    style: const TextStyle(fontFamily: josefinSansSemiBold, fontSize: 18, color: Colors.white),
                  ),
                  Text(
                    "${responseJson["code"]}".tr,
                    style: const TextStyle(fontFamily: josefinSansRegular, fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.back();
                      Clipboard.setData(ClipboardData(text: responseJson['code'].toString())).then((value) {
                        showSnackBar('copySucces', 'copySuccesSubtitle', Colors.green);
                      });
                    },
                    child: const Icon(
                      Icons.copy_all,
                      color: Colors.black,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ],
          ),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: kPrimaryColor,
          borderRadius: 20.0,
          animationDuration: const Duration(milliseconds: 800),
          margin: const EdgeInsets.all(8),
        );
      }
      return response.statusCode;
    } else {
      value ? showSnackBar('tournamentInfo15', 'tournamentInfo16', kPrimaryColor) : null;
      return response.statusCode;
    }
  }

  Future participateTournament({required int tournamentID}) async {
    final token = await Auth().getToken();
    final response = await http.post(
      Uri.parse('$serverURL/api/turnirs/participate/'),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'turnir_id': tournamentID,
      }),
    );
    return response.statusCode;
  }

  Future participateTournamentCode({required int tournamentID}) async {
    final token = await Auth().getToken();
    final response = await http.post(
      Uri.parse('$serverURL/api/turnirs/participate/'),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'turnir_id': tournamentID,
      }),
    );
    return response.statusCode;
  }

  Future participateTournamentPost({required int teamId}) async {
    final token = await Auth().getToken();
    final response = await http.post(
      Uri.parse('$serverURL/api/turnirs/participate/'),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'team_id': teamId,
      }),
    );
    final bodys = jsonDecode(response.body);
    response.statusCode == 200 ? showSnackBar('Üns beriň!', 'Siz üstunlikli turnire goşulduňyz!', Colors.green) : null;
    response.statusCode != 200
        ? showSnackBar(
            'Üns beriň!',
            bodys['error'] == 'User has not enough money to participate!'
                ? 'Ulanyjynyň gatnaşmak üçin ýeterlik puly ýok!'
                : bodys['error'] == 'User already participated!'
                    ? 'Ulanyjy eýýäm gatnaşdy!'
                    : bodys['error'],
            Colors.red,
          )
        : null;
    return response.statusCode;
  }

  Future participateTournamentSQUAD({required int teamId, required String pubgID1, required String pubgID2, required String pubgID3}) async {
    final token = await Auth().getToken();
    final response = await http.post(
      Uri.parse('$serverURL/api/turnirs/participatesquad/'),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
      body: jsonEncode(<String, String>{
        'team_id': teamId.toString(),
        'pubg_id1': pubgID1,
        'pubg_id2': pubgID2,
        'pubg_id3': pubgID3,
      }),
    );
    final bodys = jsonDecode(response.body);

    response.statusCode == 200 ? showSnackBar('Üns beriň!', 'Siz üstunlikli turnire goşulduňyz!', Colors.green) : showSnackBar('Üns beriň!', 'tournamentInfo14', Colors.red);
    // Get.to(() => BottomNavBar());
    response.statusCode != 200
        ? showSnackBar(
            'Üns beriň!',
            bodys['error'] == 'User has not enough money to participate!'
                ? 'Ulanyjynyň gatnaşmak üçin ýeterlik puly ýok!'
                : bodys['error'] == 'User already participated!'
                    ? 'Ulanyjy eýýäm gatnaşdy!'
                    : bodys['error'],
            Colors.red,
          )
        : null;
    return response.statusCode;
  }

  Future editSQUAD({required int turnirID, required int id, required String pubgID1}) async {
    final token = await Auth().getToken();
    final response = await http.post(
      Uri.parse('$serverURL/api/turnirs/turnir/$turnirID/'),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
      body: jsonEncode(<String, String>{
        'id': id.toString(),
        'pubg_id': pubgID1,
      }),
    );
    final bodys = jsonDecode(response.body);

    response.statusCode == 200 ? showSnackBar('Üns beriň!', 'Siz üstunlikli turnire goşulduňyz!', Colors.green) : showSnackBar('Üns beriň!', 'tournamentInfo14', Colors.red);
    // Get.to(() => BottomNavBar());
    response.statusCode != 200
        ? showSnackBar(
            'Üns beriň!',
            bodys['error'] == 'Siz bu ulanyjy id üýtgedip bilmersiňiz!'
                ? 'Ulanyjynyň gatnaşmak üçin ýeterlik puly ýok!'
                : bodys['error'] == 'User already participated!'
                    ? 'Ulanyjy eýýäm gatnaşdy!'
                    : bodys['error'],
            Colors.red,
          )
        : null;
    return response.statusCode;
  }

  Future participateTournamentDUAL({required int teamId, required String pubgID1}) async {
    final token = await Auth().getToken();
    final response = await http.post(
      Uri.parse('$serverURL/api/turnirs/participateduall/'),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'team_id': teamId,
        'pubg_id': pubgID1,
      }),
    );
    final bodys = jsonDecode(response.body);
    response.statusCode == 200 ? showSnackBar('Üns beriň!', 'Siz üstunlikli turnire goşulduňyz!', Colors.green) : null;
    response.statusCode != 200
        ? showSnackBar(
            'Üns beriň!',
            bodys['error'] == 'User has not enough money to participate!'
                ? 'Ulanyjynyň gatnaşmak üçin ýeterlik puly ýok!'
                : bodys['error'] == 'User already participated!'
                    ? 'Ulanyjy eýýäm gatnaşdy!'
                    : bodys['error'],
            Colors.red,
          )
        : null;
    return response.statusCode;
  }
}

class Awards {
  final String? award;
  final int? id;
  final int? place;
  final int? turnir;
  Awards({this.id, this.award, this.place, this.turnir});

  factory Awards.fromJson(Map<String, dynamic> json) {
    return Awards(
      id: json['id'],
      award: json['award'],
      place: json['place'],
      turnir: json['turnir'],
    );
  }
}

class Teams {
  final int? id;
  final int? number;
  final int? turnir;
  final List<TeamUsers>? teamUsers;
  Teams({this.id, this.number, this.turnir, this.teamUsers});

  factory Teams.fromJson(Map<String, dynamic> json) {
    return Teams(
      id: json['id'],
      number: json['number'],
      turnir: json['turnir'],
      teamUsers: ((json['teamusers'] ?? []) as List).map((json) => TeamUsers.fromJson(json)).toList(),
    );
  }
}

class TeamUsers {
  final int? id;
  final int? number;
  final int? turnir;
  final AccountsForSaleModel? user;
  TeamUsers({this.id, this.number, this.turnir, this.user});

  factory TeamUsers.fromJson(Map<String, dynamic> json) {
    return TeamUsers(
      id: json['id'],
      number: json['number'],
      turnir: json['turnir'],
      user: AccountsForSaleModel.fromJson(json['user']),
    );
  }
}

class Winners {
  final int? id;
  final int? turnir;
  final int? user;
  final String? account_image;
  final String? account_nickname;
  final String? account_location_tm;
  final String? account_location_ru;
  final String? created_date;
  final int? team_number;
  final int? award;
  final List<TeamUsers>? teamUsers;
  Winners({this.teamUsers, this.id, this.team_number, this.award, this.account_image, this.account_location_ru, this.account_location_tm, this.account_nickname, this.created_date, this.turnir, this.user});

  factory Winners.fromJson(Map<String, dynamic> json) {
    return Winners(
      id: json['id'] ?? 0,
      turnir: json['turnir'] ?? 0,
      user: json['user'] ?? 0,
      award: json['award'] ?? '0.0',
      account_image: json['account_image'] ?? '',
      account_location_ru: json['account_location_ru'] ?? '',
      account_location_tm: json['account_location_tm'] ?? '',
      account_nickname: json['account_nickname'] ?? '',
      created_date: json['created_date'] ?? '',
      team_number: json['team_number'] ?? 0,
      teamUsers: ((json['teamusers'] ?? []) as List).map((json) => TeamUsers.fromJson(json)).toList(),
    );
  }
}

class ParticipatedUsers {
  final String? account_location_ru;
  final String? account_location_tm;
  final String? created_date;
  final int? id;
  final int? turnir;
  final int? user;
  final int team;
  final String? userImage;
  final String? userName;
  ParticipatedUsers({required this.team, this.id, this.account_location_ru, this.account_location_tm, this.userImage, this.userName, this.created_date, this.user, this.turnir});

  factory ParticipatedUsers.fromJson(Map<String, dynamic> json) {
    return ParticipatedUsers(
      team: json['team'],
      id: json['id'],
      created_date: json['created_date'],
      user: json['user'],
      turnir: json['turnir'],
      userImage: json['account_image'],
      userName: json['account_nickname'],
      account_location_tm: json['account_location_tm'],
      account_location_ru: json['account_location_ru'],
    );
  }
}
