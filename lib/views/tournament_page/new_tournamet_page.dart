// ignore_for_file: file_names
import 'package:game_app/views/constants/index.dart';

import '../../controllers/wallet_controller.dart';
import 'local_widgets.dart';

class NewTournamentPage extends StatefulWidget {
  const NewTournamentPage({super.key});

  @override
  State<NewTournamentPage> createState() => _NewTournamentPageState();
}

class _NewTournamentPageState extends State<NewTournamentPage> {
  @override
  void initState() {
    super.initState();
    Get.find<WalletController>().getUserMoney();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: MyAppBar(
          fontSize: 22.0,
          backArrow: false,
          icon: userAppBarMoney(),
          iconRemove: false,
          name: 'tournament',
          elevationWhite: true,
        ),
        backgroundColor: kPrimaryColorBlack,
        body: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemExtent: 220,
          itemCount: 2,
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            return tournamentCard(index);
          },
        ),
      ),
    );
  }
}
