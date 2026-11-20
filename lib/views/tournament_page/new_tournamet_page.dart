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
          icon: Padding(padding: const EdgeInsets.only(right: 8), child: userAppBarMoney()),
          iconRemove: false,
          name: 'tournament',
          elevationWhite: true,
        ),
        backgroundColor: kPrimaryColorBlack,
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: ListView(
              children: [
                tournamentCard(2),
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: 2,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) => tournamentCard(index),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
