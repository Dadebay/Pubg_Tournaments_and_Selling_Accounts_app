// ignore_for_file: file_names

import 'index.dart';

class ProfilButton extends StatelessWidget {
  final String name;
  final Function() onTap;
  final IconData icon;
  const ProfilButton({
    required this.name,
    required this.onTap,
    required this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      tileColor: kPrimaryColorBlack,
      minVerticalPadding: 23,
      title: Text(
        name.tr,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: const TextStyle(color: Colors.white, fontFamily: gilroyMedium),
      ),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: kPrimaryColorBlack1.withOpacity(0.8), borderRadius: borderRadius15),
        child: Icon(
          icon,
          color: Colors.white,
        ),
      ),
      trailing: const Icon(
        IconlyLight.arrowRightCircle,
        color: Colors.white,
      ),
    );
  }
}
