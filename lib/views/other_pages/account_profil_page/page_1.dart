// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:game_app/views/constants/index.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../../models/get_posts_model.dart';

class TabbarPage1 extends StatefulWidget {
  final GetPostsAccountModel model;

  const TabbarPage1({
    required this.model,
    super.key,
  });

  @override
  State<TabbarPage1> createState() => _TabbarPage1State();
}

class _TabbarPage1State extends State<TabbarPage1> {
  bool showAlarts = false;

  Future getConstsPhone() async {
    final response = await http.get(
      Uri.parse('$serverURL/api/about/consts/'),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      final decoded = utf8.decode(response.bodyBytes);
      final data = json.decode(response.body);

      final String phone = data['text_three'];
      unawaited(phone != ''
          ? showDialog(
              context: context,
              builder: (ctxt) => AlertDialog(
                backgroundColor: kPrimaryColorBlack,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(32.0))),
                title: Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10, bottom: 20, top: 20),
                    child: Column(
                      children: [
                        const Text('Ünus Beriň!'),
                        Container(
                          color: Colors.white,
                          height: 1,
                          width: 115,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          data['text_three'],
                          style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.normal, fontFamily: gilroyRegular),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          // ignore: require_trailing_commas
          : null);

      return json.decode(decoded);
    } else {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    getConstsPhone();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        infoPartText('accountDetaile1', widget.model.pubgUserName ?? '', false),
        infoPartText('accountDetaile2', widget.model.pubgID ?? '', false),
        infoPartText('accountDetaile5', widget.model.price!, true),
        infoPartText('accountDetaile6', widget.model.createdAt!.substring(0, 10), false),
        // infoPartText('verifed', widget.model.user!.verified == true ? 'yes' : 'no', false),
        // infoPartText('points', widget.model.user!.points.toString(), false),
        // infoPartText('pointsFromTurnir', widget.model.pubgType!.toString(), false),
        // infoPartText('referalKod', widget.model.user!.referalCode!, false),
        Padding(
          padding: const EdgeInsets.only(left: 20, bottom: 25, top: 15),
          child: Text(
            'accountDetaile11'.tr,
            maxLines: 2,
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontFamily: gilroyRegular, fontSize: 20),
          ),
        ),
        // infoPartText('accountDetaile7', widget.model.user!.firsName ?? '', false),
        infoPartText('accountDetaile9', widget.model.phone ?? '', false),
        Padding(
          padding: const EdgeInsets.only(left: 25, right: 25),
          child: AgreeButton(
            name: 'popUP1',
            onTap: () async {
              await launch('tel://${widget.model.phone}');
            },
          ),
        ),
      ],
    );
  }

  Padding infoPartText(String text1, String text2, bool price) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 15, bottom: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              text1.tr,
              maxLines: 2,
              textAlign: TextAlign.start,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70, fontFamily: gilroyRegular, fontSize: 20),
            ),
          ),
          Expanded(
            child: price
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        text2,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: gilroySemiBold,
                        ),
                      ),
                      const Text(
                        ' TMT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontFamily: gilroySemiBold,
                        ),
                      ),
                    ],
                  )
                : Text(
                    text2,
                    maxLines: 8,
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontFamily: gilroySemiBold, fontSize: 18),
                  ),
          ),
        ],
      ),
    );
  }

  Padding infoPartTextAlart(String text1, String text2, bool price) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 15, bottom: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              text1.tr,
              maxLines: 2,
              textAlign: TextAlign.start,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70, fontFamily: gilroyRegular, fontSize: 20),
            ),
          ),
          Expanded(
            child: price
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        text2,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: gilroySemiBold,
                        ),
                      ),
                      const Text(
                        ' TMT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontFamily: gilroySemiBold,
                        ),
                      ),
                    ],
                  )
                : Text(
                    text2,
                    maxLines: 8,
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.red, fontFamily: gilroySemiBold, fontSize: 18),
                  ),
          ),
        ],
      ),
    );
  }
}
