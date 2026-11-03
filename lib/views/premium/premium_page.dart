import 'package:game_app/views/constants/index.dart';

/// Premium tab. The API has no premium products yet, so this only announces it.
class PremiumPage extends StatelessWidget {
  const PremiumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColorBlack,
      appBar: AppBar(
        backgroundColor: kPrimaryColorBlack,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text('premium'.tr, style: const TextStyle(color: Colors.white, fontFamily: gilroySemiBold, fontSize: 25)),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(IconlyBold.star, size: 72, color: Color(0xFFFFC83D)),
            const SizedBox(height: 16),
            Text('premiumSoon'.tr, style: const TextStyle(color: Colors.white70, fontFamily: gilroySemiBold, fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
