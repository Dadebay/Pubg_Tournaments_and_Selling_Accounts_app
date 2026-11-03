// ignore_for_file: file_names, must_be_immutable, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_app/views/constants/constants.dart';
import 'package:get/get.dart';

class PhoneNumber extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode mineFocus;
  final FocusNode requestFocus;
  final bool style;
  final bool? disabled;
  const PhoneNumber({required this.mineFocus, required this.controller, required this.requestFocus, required this.style, this.disabled});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: TextFormField(
        enabled: disabled ?? true,
        style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: gilroyMedium),
        cursorColor: Colors.white,
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.number,
        focusNode: mineFocus,
        controller: controller,
        validator: (value) {
          if (value!.isEmpty) {
            return 'errorEmpty'.tr;
          } else if (value.length != 8) {
            return 'errorPhoneCount'.tr;
          }
          return null;
        },
        inputFormatters: [
          LengthLimitingTextInputFormatter(8),
        ],
        onEditingComplete: () {
          requestFocus.requestFocus();
        },
        enableSuggestions: false,
        autocorrect: false,
        decoration: InputDecoration(
          errorMaxLines: 2,
          errorStyle: const TextStyle(fontFamily: gilroyMedium),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 15, bottom: 2),
            child: Text(
              '+ 993',
              style: TextStyle(color: Colors.grey, fontSize: 18, fontFamily: gilroyMedium),
            ),
          ),
          contentPadding: const EdgeInsets.only(left: 25, top: 18, bottom: 18),
          prefixIconConstraints: const BoxConstraints(minWidth: 80),
          hintText: '65 656565 ',
          filled: style,
          fillColor: backgroundColor,
          alignLabelWithHint: true,
          hintStyle: const TextStyle(color: Colors.grey, fontFamily: gilroyMedium),
          border: OutlineInputBorder(
            borderRadius: style ? borderRadius10 : borderRadius20,
            borderSide: BorderSide(color: style ? backgroundColor : Colors.grey, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: style ? borderRadius10 : borderRadius20,
            borderSide: BorderSide(color: style ? backgroundColor : Colors.grey.shade200, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: style ? borderRadius10 : borderRadius20,
            borderSide: const BorderSide(color: kPrimaryColor, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: style ? borderRadius10 : borderRadius20,
            borderSide: const BorderSide(color: kPrimaryColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: style ? borderRadius10 : borderRadius20,
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
      ),
    );
  }
}
