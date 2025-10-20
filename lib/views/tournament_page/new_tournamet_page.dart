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
        body: Column(
          children: [
            tournamentCard(2),
            GridView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: 2, // same as your ListView
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // number of columns in the grid
                mainAxisSpacing: 10, // vertical spacing
                crossAxisSpacing: 0, // horizontal spacing
                childAspectRatio: 220 / 220, // width/height ratio of each card
              ),
              itemBuilder: (context, index) {
                return tournamentCard(index); // your custom card widget
              },
            ),
          ],
        ),
      ),
    );
  }
}
