// ignore_for_file: file_names, must_be_immutable

import 'package:game_app/models/tournament_model.dart';

import '../constants/index.dart';

class TabPage2 extends StatelessWidget {
  final TournamentModel model;

  const TabPage2({
    required this.model,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: model.awards!.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          tileColor: index % 2 == 0 ? kPrimaryColorBlack : kPrimaryColorBlack1,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  ' ${index + 1}.',
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontFamily: gilroySemiBold),
                ),
              ),
              Expanded(
                flex: 1,
                child: RichText(
                  text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: model.awards![index].award.toString().substring(0, model.awards![index].award!.length - 3),
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontFamily: gilroySemiBold),
                      ),
                      const TextSpan(
                        text: '  TMT',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontFamily: gilroyRegular),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
