import 'package:game_app/models/history_order_model.dart';
import 'package:game_app/views/constants/index.dart';
import 'package:game_app/views/user_profil/pages/bought_widgets.dart';
import 'package:hugeicons/hugeicons.dart';

/// The contest tickets the user bought.
class BoughtKonkurs extends StatelessWidget {
  const BoughtKonkurs({super.key});

  @override
  Widget build(BuildContext context) {
    return BoughtListPage<BoughtKonkursModel>(
      title: 'boughtKonkurs',
      load: () => BoughtKonkursModel().getMyKonkurs(),
      itemBuilder: (konkurs) => BoughtCard(
        icon: HugeIcons.strokeRoundedAward01,
        accent: const Color(0xFFFFC83D),
        title: '${konkurs.konkursName}',
        price: konkurs.price,
        code: konkurs.code,
      ),
    );
  }
}

/// The things (codes) the user bought, with the id they were ordered for.
class BoughtCODES extends StatelessWidget {
  const BoughtCODES({super.key});

  @override
  Widget build(BuildContext context) {
    return BoughtListPage<BoughtThingsModel>(
      title: 'boughtCODES',
      load: () => BoughtThingsModel().getGifts(),
      itemBuilder: (thing) => BoughtCard(
        icon: HugeIcons.strokeRoundedKey01,
        accent: const Color(0xFF60A5FA),
        title: '${thing.thingName}',
        subtitle: thing.asking,
        price: thing.thingCommonPrice,
        count: thing.thingCount,
      ),
    );
  }
}
