import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:game_app/views/other_users/other_user_product_profil.dart';
import 'package:get/get.dart';

import '../constants/constants.dart';
import '../constants/widgets.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:game_app/views/other_users/other_user_product_profil.dart';
import 'package:get/get.dart';

import '../constants/constants.dart';
import '../constants/widgets.dart';

class BestPlayersCard extends StatelessWidget {
  final String? points;
  final String name;
  final String? image;
  final int index;
  final bool referalPage;
  const BestPlayersCard({
    required this.name,
    required this.image,
    required this.index,
    required this.points,
    required this.referalPage,
    super.key,
  });

  Color _getRankColor(int index) {
    if (index == 0) return const Color(0xFFFFD700); // Gold
    if (index == 1) return const Color(0xFFC0C0C0); // Silver
    if (index == 2) return const Color(0xFFCD7F32); // Bronze
    return kPrimaryColor;
  }

  IconData _getRankIcon(int index) {
    if (index == 0) return Icons.emoji_events; // Trophy
    if (index == 1) return Icons.military_tech;
    if (index == 2) return Icons.star;
    return Icons.trending_up;
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final rankColor = _getRankColor(index);
    final isTopThree = index < 3;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isTopThree
              ? [
                  rankColor.withOpacity(0.15),
                  rankColor.withOpacity(0.05),
                  Colors.transparent,
                ]
              : [
                  const Color(0xFF1a1f3a),
                  const Color(0xFF0f1229),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isTopThree ? rankColor.withOpacity(0.5) : Colors.white.withOpacity(0.1),
          width: isTopThree ? 2 : 1,
        ),
        boxShadow: isTopThree
            ? [
                BoxShadow(
                  color: rankColor.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Get.to(
              () => OtherUserProductProfil(
                points: points,
                name: name,
                image: image,
                index: index,
              ),
              transition: Transition.fadeIn,
              duration: const Duration(milliseconds: 300),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                // Rank Number with Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        rankColor.withOpacity(0.3),
                        rankColor.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: rankColor.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (isTopThree)
                        Positioned(
                          top: 2,
                          right: 2,
                          child: Icon(
                            _getRankIcon(index),
                            color: rankColor,
                            size: 14,
                          ),
                        ),
                      Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: rankColor,
                          fontFamily: josefinSansBold,
                          fontSize: isTopThree ? 22 : 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // Player Image
                if (!referalPage)
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: rankColor.withOpacity(0.5),
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: rankColor.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        fadeInCurve: Curves.easeIn,
                        imageUrl: image!,
                        imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        placeholder: (context, url) => Container(
                          color: rankColor.withOpacity(0.1),
                          child: Center(child: spinKit()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: kPrimaryColor.withOpacity(0.2),
                          child: const Center(
                            child: Icon(
                              Icons.person,
                              color: Colors.white54,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (!referalPage) const SizedBox(width: 16),

                // Player Name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        name.isEmpty ? 'Unknoun' : name,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: josefinSansBold,
                          fontSize: 18,
                          letterSpacing: 0.5,
                          shadows: isTopThree
                              ? [
                                  Shadow(
                                    color: rankColor.withOpacity(0.5),
                                    blurRadius: 10,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                      if (isTopThree)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: rankColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: rankColor.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            index == 0
                                ? 'Champion'
                                : index == 1
                                    ? 'Runner-up'
                                    : '3rd Place',
                            style: TextStyle(
                              color: rankColor,
                              fontFamily: josefinSansSemiBold,
                              fontSize: 10,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Points
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        kPrimaryColor.withOpacity(0.3),
                        kPrimaryColor.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: kPrimaryColor.withOpacity(0.4),
                    ),
                  ),
                  child: referalPage
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              points!.substring(0, points!.length >= 5 ? 5 : points!.length),
                              style: const TextStyle(
                                color: kPrimaryColor,
                                fontSize: 18,
                                fontFamily: josefinSansBold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'TMT',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontFamily: josefinSansSemiBold,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          points!.substring(0, points!.length >= 5 ? 5 : points!.length),
                          style: const TextStyle(
                            color: kPrimaryColor,
                            fontFamily: josefinSansBold,
                            fontSize: 20,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
