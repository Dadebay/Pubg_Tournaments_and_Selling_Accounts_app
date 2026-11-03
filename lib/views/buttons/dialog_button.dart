import '../constants/index.dart';

class DialogButton extends StatelessWidget {
  final String name;
  final Function() onTapp;
  final bool color;
  const DialogButton({
    required this.name,
    required this.onTapp,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onTapp,
        style: ElevatedButton.styleFrom(
          shape: const RoundedRectangleBorder(borderRadius: borderRadius20),
          backgroundColor: color ? kPrimaryColor : kPrimaryColorBlack1,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: Text(
          name.tr,
          style: TextStyle(
            color: color ? kPrimaryColorBlack1 : kPrimaryColor,
            fontFamily: gilroySemiBold,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
