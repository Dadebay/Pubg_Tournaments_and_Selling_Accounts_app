// ignore_for_file: file_names

import 'package:flutter/cupertino.dart';
import 'package:game_app/controllers/wallet_controller.dart';

import '../constants/index.dart';

class AddCartButton extends StatefulWidget {
  final bool productProfil;
  final int id;
  final String price;
  final String title;
  final String image;
  final String status;

  const AddCartButton({
    required this.productProfil,
    required this.id,
    required this.price,
    required this.status,
    required this.title,
    required this.image,
    super.key,
  });

  @override
  State<AddCartButton> createState() => _AddCartButtonState();
}

class _AddCartButtonState extends State<AddCartButton> {
  int number = 1;
  int price = 0;
  bool value = false;
  final WalletController walletController = Get.put(WalletController());
  @override
  void initState() {
    super.initState();
    setState(() {
      checkInCart();
    });
  }

  dynamic checkInCart() {
    for (var element in walletController.cartList) {
      if (element['id'] == widget.id) {
        number = element['count'];
        value = true;
      }
    }
  }

  Widget numPart() {
    return Row(
      mainAxisAlignment: widget.productProfil
          ? MainAxisAlignment.start
          : MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            if (number - 1 == 0) {
              value = false;
              number = 1;
              walletController.removeCart(widget.id);
            } else {
              number--;
              walletController.minusCart(widget.id);
            }
            setState(() {
              final double b = double.parse(widget.price);
              walletController.finalCount.value = number.toDouble();
              walletController.finalPRice.value -= b;
              for (var element in walletController.cartList) {
                if (element['id'] == widget.id) {
                  number = element['count'];
                  value = true;
                }
              }
            });
          },
          child: const Icon(
            CupertinoIcons.minus_circle,
            color: Colors.white,
            size: 24,
          ),
        ),
        Padding(
          padding: widget.productProfil
              ? const EdgeInsets.symmetric(horizontal: 15)
              : EdgeInsets.zero,
          child: Text(
            number.toString(),
            style: TextStyle(
              color: kPrimaryColor,
              fontSize: widget.productProfil ? 22 : 20,
              fontFamily: gilroyBold,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            number++;
            walletController.addCart(
              id: widget.id,
              image: widget.image,
              price: widget.price,
              title: widget.title,
              status: widget.status,
            );
            setState(() {
              final double b = double.parse(widget.price);
              walletController.finalCount.value = number.toDouble();
              walletController.finalPRice.value += b;
              for (var element in walletController.cartList) {
                if (element['id'] == widget.id) {
                  number = element['count'];
                  value = true;
                }
              }
            });
          },
          child: const Icon(
            CupertinoIcons.add_circled,
            color: Colors.white,
            size: 24,
          ),
        ),
      ],
    );
  }

  int a = 0;
  dynamic checkStatus() {
    a = 0;
    for (var element in walletController.cartList) {
      if (element['id'] == widget.id) {
        a = 1;
      }
    }
    if (a == 0) {
      value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      checkStatus();
      return Container(
        width: Get.size.width,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: widget.productProfil
            ? value
                  ? numPart()
                  : Text(
                      'addCart'.tr,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: widget.productProfil ? 22 : 16,
                        fontFamily: gilroySemiBold,
                      ),
                    )
            : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColorBlack,
                  padding: EdgeInsets.symmetric(
                    vertical: widget.productProfil ? 14 : 0,
                    horizontal: value ? 15 : 0,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: widget.productProfil
                        ? borderRadius20
                        : borderRadius15,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    if (value == false) {
                      walletController.addCart(
                        id: widget.id,
                        image: widget.image,
                        price: widget.price,
                        title: widget.title,
                        status: widget.status,
                      );

                      value = !value;
                    }
                  });
                },
                child: value
                    ? numPart()
                    : Text(
                        'addCart'.tr,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: widget.productProfil ? 22 : 16,
                          fontFamily: gilroySemiBold,
                        ),
                      ),
              ),
      );
    });
  }
}
