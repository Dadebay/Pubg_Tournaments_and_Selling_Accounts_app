import 'package:flutter/material.dart';
import 'package:game_app/views/constants/constants.dart';
import 'package:get/get.dart';

/// The first-message invitation, also used with a retry action when the chat
/// cannot be opened. The composer below this widget remains the main action.
class SupportChatEmptyState extends StatelessWidget {
  const SupportChatEmptyState({this.onRetry, super.key});

  final VoidCallback? onRetry;

  static const _gold = Color(0xFFFFC83D);

  @override
  Widget build(BuildContext context) {
    final failed = onRetry != null;
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(center: Alignment(0, -0.32), radius: 1.05, colors: [Color(0xFF191207), Colors.black]),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final imageWidth = constraints.maxWidth.clamp(0.0, 440.0);
          return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/image/empty_support_chat.webp',
                        width: imageWidth,
                        height: imageWidth * 2 / 3,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                        excludeFromSemantics: true,
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: Column(
                            children: [
                              Text(
                                (failed ? 'supportUnavailableTitle' : 'supportWelcomeTitle').tr,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 25, height: 1.17),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                (failed ? 'supportUnavailableText' : 'supportWelcomeText').tr,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Color(0xFFC5C0B7), fontFamily: gilroyMedium, fontSize: 15, height: 1.45),
                              ),
                              if (failed) ...[
                                const SizedBox(height: 28),
                                FilledButton.icon(
                                  onPressed: onRetry,
                                  icon: const Icon(Icons.refresh_rounded, size: 19),
                                  label: Text('noConnection3'.tr, style: const TextStyle(fontFamily: gilroyBold, fontSize: 15)),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: _gold,
                                    foregroundColor: const Color(0xFF1A1200),
                                    minimumSize: const Size(0, 48),
                                    padding: const EdgeInsets.symmetric(horizontal: 23),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
