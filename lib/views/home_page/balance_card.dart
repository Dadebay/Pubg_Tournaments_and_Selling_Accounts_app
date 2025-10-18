import 'package:flutter/material.dart';
import 'package:game_app/controllers/wallet_controller.dart';
import 'package:game_app/views/constants/constants.dart';
import 'package:game_app/views/constants/index.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Container(
          width: MediaQuery.of(context).size.width - 32,
          margin: const EdgeInsets.symmetric(vertical: 0),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                kPrimaryColor,
                kAccentColor,
                Color(0xFFFFCC80),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            // boxShadow: [
            //   BoxShadow(
            //     color: kPrimaryColor.withOpacity(0.4),
            //     blurRadius: 0,
            //     spreadRadius: 0,
            //     offset: const Offset(0, 8),
            //   ),
            //   BoxShadow(
            //     color: Colors.black.withOpacity(0.1),
            //     blurRadius: 15,
            //     offset: const Offset(0, 4),
            //   ),
            // ],
          ),
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                bottom: -20,
                left: -20,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),
              // Main content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            IconlyLight.wallet,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Balans (TMT)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Balance amount with animation-ready design
                    Obx(() {
                      double balance = 0.0;
                      balance = double.parse(
                        Get.find<WalletController>().userMoney.toString(),
                      );

                      // Split balance into whole and decimal parts
                      final String balanceStr = balance.toStringAsFixed(2);
                      final List<String> parts = balanceStr.split('.');
                      final String wholePart = parts[0];
                      final String decimalPart = parts[1];

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              wholePart,
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1,
                                letterSpacing: -1,
                              ),
                            ),
                            Text(
                              '.$decimalPart',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 20),
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: kDarkOrange,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () {},
                              icon: const Icon(
                                Icons.add_card,
                                size: 20,
                                color: kAccentColor,
                              ),
                              label: const Text(
                                'Doldyrmak',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: [
                                  kDarkOrange,
                                  kDarkOrange.withOpacity(0.8),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: kDarkOrange.withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                elevation: 0,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () {},
                              icon: const Icon(
                                Icons.send_rounded,
                                size: 20,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Geçirmek',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
