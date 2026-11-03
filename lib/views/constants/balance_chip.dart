import 'package:flutter/material.dart';
import 'package:game_app/controllers/wallet_controller.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

import 'constants.dart';

/// The user's balance as a small pill (wallet icon and amount) for the right
/// side of a page header. It is only as wide as its content.
class BalanceChip extends StatelessWidget {
  const BalanceChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFF1B1B1E), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const HugeIcon(icon: HugeIcons.strokeRoundedWallet01, color: Color(0xFFFFC83D), size: 20, strokeWidth: 1.6),
          const SizedBox(width: 8),
          Obx(() {
            final value = double.tryParse(Get.find<WalletController>().userMoney.toString()) ?? 0;
            return Text(value.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 16));
          }),
        ],
      ),
    );
  }
}
