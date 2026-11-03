import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:game_app/controllers/settings_controller.dart';
import 'package:game_app/models/tournament_model.dart';
import 'package:game_app/views/constants/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../models/user_models/auth_model.dart';
import '../buttons/agree_button.dart';
import '../constants/constants.dart';
import 'local_widgets.dart';

class TabPage1 extends StatelessWidget {
  final bool finised;
  final String buttonName;
  final int tournamentType;
  final TournamentModel model;

  const TabPage1({
    required this.finised,
    required this.tournamentType,
    required this.buttonName,
    required this.model,
    super.key,
  });
  String formatDateString(String dateString) {
    final DateTime parsedDate = DateTime.parse(dateString);

    // Adjust the parsed date to the local time zone
    final DateTime localTime = parsedDate.toLocal();

    final DateFormat formatter = DateFormat('yyyy-MM-dd  -  HH:mm');
    return formatter.format(localTime);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: kPrimaryColorBlack,
          margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    model.title.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: gilroySemiBold,
                      fontSize: 26,
                    ),
                  ),
                ),
                twoText(name1: 'tournamentInfo5'.tr, name2: model.mode ?? ''),
                twoText(name1: 'tournamentInfo6'.tr, name2: model.map ?? ''),
                twoText(name1: 'tournamentInfo7'.tr, name2: formatDateString(model.start_date.toString())),
                twoText(name1: 'tournamentInfo8'.tr, name2: finised ? 'tournamentInfo9'.tr : 'tournamentInfo10'.tr),
                const SizedBox(height: 25),
                Html(
                  data: Get.locale?.languageCode == 'tr' ? model.description_tm ?? '' : model.description_ru ?? '',
                  style: {
                    'body': Style(
                      fontFamily: gilroyRegular,
                      fontSize: FontSize(18.0),
                      color: Colors.white70,
                      textAlign: TextAlign.left,
                    ),
                  },
                ),
                const SizedBox(height: 70),
              ],
            ),
          ),
        ),
        if (!finised)
          Positioned(
            bottom: 15,
            left: 25,
            right: 25,
            child: SizedBox(
              width: Get.size.width,
              child: Center(
                child: AgreeButton(
                  onTap: () async {
                    final settingsController = Get.find<SettingsController>();
                    settingsController.agreeButton.value = !settingsController.agreeButton.value;
                    final token = await Auth().getToken();
                    if (token == null || token.isEmpty) {
                      showSnackBar('Üns beriň!', 'Ulgama Giriň!', Colors.red);
                    } else {
                      if (buttonName != 'tournamentInfo12') {
                        subscribeTurnir(
                          price: model.price!,
                          id: model.id!,
                          tournamentType: tournamentType,
                          turnir: model,
                        );
                      } else {
                        await TournamentModel().checkStatus(
                          tournamentID: model.id!,
                          value: true,
                        );
                      }
                    }
                    settingsController.agreeButton.value = !settingsController.agreeButton.value;
                  },
                  name: buttonName,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Padding text(String name) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Text(
        name.tr,
        textAlign: TextAlign.left,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 18,
          fontFamily: gilroyRegular,
        ),
      ),
    );
  }

  Padding twoText({required String name1, required String name2}) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              name1.tr,
              textAlign: TextAlign.left,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 18,
                fontFamily: gilroyRegular,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              name2.tr,
              maxLines: 2,
              textAlign: TextAlign.left,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontFamily: gilroySemiBold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
