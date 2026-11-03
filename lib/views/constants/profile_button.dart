// ignore_for_file: file_names

import 'index.dart';

/// A row of the profile menu: a tinted icon box, the title and a chevron, on its own card.
class ProfilButton extends StatelessWidget {
  final String name;
  final Function() onTap;
  final IconData icon;
  final bool danger;
  const ProfilButton({
    required this.name,
    required this.onTap,
    required this.icon,
    this.danger = false,
    super.key,
  });

  static const _gold = Color(0xFFFFC83D);
  static const _red = Color(0xFFFF5A5F);

  @override
  Widget build(BuildContext context) {
    final accent = danger ? _red : _gold;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: danger ? _red.withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.07)),
            gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF232327), Color(0xFF151517)]),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: accent.withValues(alpha: 0.13), borderRadius: BorderRadius.circular(14)),
                    child: Icon(icon, color: accent, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      name.tr,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(color: danger ? _red : Colors.white, fontFamily: gilroySemiBold, fontSize: 16),
                    ),
                  ),
                  if (!danger) Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.35)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
