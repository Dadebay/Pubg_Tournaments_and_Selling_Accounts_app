import 'package:game_app/models/history_order_model.dart';
import 'package:game_app/views/constants/index.dart';
import 'package:game_app/views/user_profil/pages/bought_widgets.dart';
import 'package:hugeicons/hugeicons.dart';

/// The gift codes the user bought.
class BoughtGifts extends StatelessWidget {
  const BoughtGifts({super.key});

  @override
  Widget build(BuildContext context) {
    return BoughtListPage<BoughtGiftsModel>(
      title: 'boughtGifts',
      load: () => BoughtGiftsModel().getGifts(),
      itemBuilder: (gift) => BoughtCard(
        icon: HugeIcons.strokeRoundedGift,
        accent: const Color(0xFFFF7AB6),
        title: '${gift.giftName}',
        subtitle: gift.phone,
        code: gift.code,
      ),
    );
  }
}
