import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:game_app/controllers/settings_controller.dart';
import 'package:game_app/models/tournament_model.dart';
import 'package:game_app/views/constants/widgets.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
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

  const TabPage1({required this.finised, required this.tournamentType, required this.buttonName, required this.model, super.key});
  String formatDateString(String dateString) {
    final DateTime parsedDate = DateTime.parse(dateString);

    // Adjust the parsed date to the local time zone
    final DateTime localTime = parsedDate.toLocal();

    final DateFormat formatter = DateFormat('dd.MM.yyyy  HH:mm');
    return formatter.format(localTime);
  }

  @override
  Widget build(BuildContext context) {
    final price = double.tryParse(model.price ?? '');
    final priceText = price == null ? null : (price == price.roundToDouble() ? '${price.toInt()}' : price.toStringAsFixed(1));
    final description = Get.locale?.languageCode == 'tr' ? model.description_tm ?? '' : model.description_ru ?? '';
    return Stack(
      children: [
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16, 16, 16, finised ? 40 : 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _statusChip(),
                  const Spacer(),
                  if (priceText != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: const LinearGradient(colors: [Color(0xFFFFD866), Color(0xFFFF9800)]),
                      ),
                      child: Text(
                        '$priceText TMT',
                        style: const TextStyle(color: Colors.black, fontFamily: gilroyBold, fontSize: 15, height: 1.1),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                model.title.toString(),
                style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 28, height: 1.1),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(child: _infoTile(HugeIcons.strokeRoundedGameController03, 'tournamentInfo5'.tr, model.mode ?? '-')),
                  const SizedBox(width: 10),
                  Expanded(child: _infoTile(HugeIcons.strokeRoundedMapsLocation01, 'tournamentInfo6'.tr, model.map ?? '-')),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(flex: 3, child: _infoTile(HugeIcons.strokeRoundedCalendar03, 'tournamentInfo7'.tr, formatDateString(model.start_date.toString()))),
                  const SizedBox(width: 10),
                  Expanded(flex: 2, child: _infoTile(HugeIcons.strokeRoundedUserMultiple, 'tournamentInfo4'.tr, '${model.participated_users?.length ?? 0}')),
                ],
              ),
              if (description.trim().isNotEmpty) ...[
                const SizedBox(height: 22),
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 18,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), color: const Color(0xFFFFC83D)),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'tournamentInfo15'.tr.replaceAll(':', ''),
                      style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
                    color: const Color(0xFF1B1B1E),
                  ),
                  child: Html(
                    data: description,
                    style: {'body': Style(fontFamily: gilroyRegular, fontSize: FontSize(16.0), color: Colors.white70, textAlign: TextAlign.left, lineHeight: const LineHeight(1.4))},
                  ),
                ),
              ],
            ],
          ),
        ),
        if (!finised)
          Positioned(
            bottom: 18,
            left: 20,
            right: 20,
            child: AgreeButton(
              onTap: () async {
                final settingsController = Get.find<SettingsController>();
                settingsController.agreeButton.value = !settingsController.agreeButton.value;
                final token = await Auth().getToken();
                if (token == null || token.isEmpty) {
                  showSnackBar('Üns beriň!', 'Ulgama Giriň!', Colors.red);
                } else {
                  if (buttonName != 'tournamentInfo12') {
                    subscribeTurnir(price: model.price!, id: model.id!, tournamentType: tournamentType, turnir: model);
                  } else {
                    await TournamentModel().checkStatus(tournamentID: model.id!, value: true);
                  }
                }
                settingsController.agreeButton.value = !settingsController.agreeButton.value;
              },
              name: buttonName,
            ),
          ),
      ],
    );
  }

  Widget _statusChip() {
    final color = finised ? const Color(0xFFFF5A5F) : const Color(0xFF34D399);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: color.withValues(alpha: 0.14),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 7),
          Text(
            finised ? 'tournamentInfo9'.tr : 'tournamentInfo10'.tr,
            style: TextStyle(color: color, fontFamily: gilroySemiBold, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(List<List<dynamic>> icon, String label, String value) {
    const gold = Color(0xFFFFC83D);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF232327), Color(0xFF161618)]),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: gold.withValues(alpha: 0.14)),
            child: HugeIcon(icon: icon, color: gold, size: 19, strokeWidth: 1.8),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.replaceAll(':', '').trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF9A9AA3), fontFamily: gilroyMedium, fontSize: 11),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 14, height: 1.15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Padding text(String name) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Text(
        name.tr,
        textAlign: TextAlign.left,
        style: const TextStyle(color: Colors.white70, fontSize: 18, fontFamily: gilroyRegular),
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
              style: const TextStyle(color: Colors.grey, fontSize: 18, fontFamily: gilroyRegular),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              name2.tr,
              maxLines: 2,
              textAlign: TextAlign.left,
              style: const TextStyle(color: Colors.white70, fontSize: 18, fontFamily: gilroySemiBold),
            ),
          ),
        ],
      ),
    );
  }
}
