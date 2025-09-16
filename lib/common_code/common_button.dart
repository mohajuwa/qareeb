// ignore_for_file: avoid_print
// ignore_for_file: unused_field, unused_element, depend_on_referenced_packages, camel_case_types, non_constant_identifier_names, prefer_typing_uninitialized_variables, avoid_init_to_null, use_build_context_synchronously, unnecessary_brace_in_string_interps, prefer_final_fields
// ignore_for_file: unused_import, must_be_immutable, use_super_parameters,
// ignore_for_file: use_key_in_widget_constructors, prefer_interpolation_to_compose_strings, unnecessary_string_interpolations, await_only_futures, prefer_const_constructors, avoid_unnecessary_containers, file_names, void_checks, deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:qareeb/common_code/font_helper.dart';

import 'colore_screen.dart';

Widget CommonButton(
    {String? txt1,
    String? txt2,
    required Color containcolore,
    context,
    required void Function() onPressed1}) {
  return Container(
      height: 50,
      // width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: containcolore,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ElevatedButton(
        style: ButtonStyle(
            elevation: const WidgetStatePropertyAll(0),
            backgroundColor: MaterialStatePropertyAll(containcolore),
            shape: const MaterialStatePropertyAll(RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))))),
        onPressed: onPressed1,
        child: Center(
          child: RichText(
              text: TextSpan(children: [
            TextSpan(
                text: txt1,
                style: TextStyle(
                  fontSize: 15,
                  fontFamily: FontHelper.getCurrentFont(),
                )),
            TextSpan(
                text: txt2,
                style: TextStyle(
                  fontSize: 15,
                  fontFamily: FontHelper.getCurrentFont(),
                )),
          ])),
        ),
      ));
}

Widget CommonOutLineButton(
    {String? txt1,
    String? txt2,
    required Color bordercolore,
    context,
    required void Function() onPressed1,
    Color? clore}) {
  // notifier = Provider.of<ColorNotifier>(context, listen: true);
  return Container(
      height: 50,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: OutlinedButton(
        style: ButtonStyle(
            shape: const MaterialStatePropertyAll(RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)))),
            side: MaterialStatePropertyAll(BorderSide(color: bordercolore))),
        onPressed: onPressed1,
        child: Center(
          child: RichText(
              text: TextSpan(children: [
            TextSpan(
                text: txt1,
                style: TextStyle(
                  fontSize: 15,
                  color: notifier.textColor,
                  fontFamily: FontHelper.getCurrentFont(),
                )),
            TextSpan(
                text: txt2,
                style: TextStyle(
                  fontSize: 15,
                  color: clore,
                  fontFamily: FontHelper.getCurrentFont(),
                )),
          ])),
        ),
      ));
}

ColorNotifier notifier = ColorNotifier();
Widget CommonTextfiled200(
    {required String txt,
    TextEditingController? controller,
    required BuildContext context}) {
  notifier = Provider.of<ColorNotifier>(context, listen: true);
  return TextFormField(
    controller: controller,
    style: TextStyle(color: notifier.textColor),
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Please enter some text'.tr;
      }
      return null;
    },
    decoration: InputDecoration(
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Colors.red)),
      enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.4))),
      hintText: txt,
      hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
      focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: theamcolore)),
    ),
  );
}

Widget CommonTextfiled400(
    {required TextInputType? keyboardType,
    required String txt,
    TextEditingController? controller,
    required BuildContext context,
    required String? Function(String?) validator}) {
  notifier = Provider.of<ColorNotifier>(context, listen: true);
  return TextFormField(
    controller: controller,
    style: TextStyle(color: notifier.textColor),
    validator: validator,
    keyboardType: keyboardType,
    decoration: InputDecoration(
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Colors.red)),
      enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.4))),
      hintText: txt,
      hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
      focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: theamcolore)),
    ),
  );
}

Widget CommonTextfiled2(
    {required String txt,
    TextEditingController? controller,
    required BuildContext context}) {
  return TextField(
    controller: controller,
    style: TextStyle(color: Colors.black),
    decoration: InputDecoration(
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Colors.red)),
      enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.4))),
      hintText: txt,
      hintStyle: const TextStyle(
          color: Colors.grey, fontFamily: "SofiaProBold", fontSize: 14),
      focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: theamcolore)),
    ),
  );
}

void snackbar({
  required BuildContext context,
  required String text,
  Color? backgroundColor,
  Color? textColor,
  IconData? icon,
  Duration duration = const Duration(seconds: 3),
  bool isError = false,
  bool isSuccess = false,
  bool showAppIcon = true,
}) {
  final notifier = Provider.of<ColorNotifier>(context, listen: false);

  Color bgColor = backgroundColor ??
      (Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade800.withOpacity(0.85)
          : Colors.grey.shade900.withOpacity(0.85));

  Color borderColor = isError
      ? Colors.red.shade400
      : isSuccess
          ? Colors.green.shade400
          : theamcolore;

  Color txtColor = textColor ?? Colors.white;
  Widget? leadingWidget;

  if (icon != null) {
    leadingWidget = Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.2),
        border: Border.all(
          color: borderColor,
          width: 1.5,
        ),
      ),
      child: Icon(
        icon,
        color: txtColor,
        size: 22,
      ),
    );
  } else if (isError) {
    leadingWidget = Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.2),
        border: Border.all(
          color: borderColor,
          width: 1.5,
        ),
      ),
      child: Icon(
        Icons.error_outline,
        color: txtColor,
        size: 22,
      ),
    );
  } else if (isSuccess) {
    leadingWidget = Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.2),
        border: Border.all(
          color: borderColor,
          width: 1.5,
        ),
      ),
      child: Icon(
        Icons.check_circle_outline,
        color: txtColor,
        size: 22,
      ),
    );
  } else if (showAppIcon) {
    leadingWidget = Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.2),
        border: Border.all(
          color: borderColor,
          width: 1.5,
        ),
      ),
      child: Center(
        child: SvgPicture.asset(
          notifier.isDark == true
              ? "assets/svgpicture/app_logo_dark.svg"
              : "assets/svgpicture/app_logo_light.svg",
          height: 24,
          width: 24,
        ),
      ),
    );
  }

  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).size.height * 0.15,
      left: MediaQuery.of(context).size.width * 0.15,
      right: MediaQuery.of(context).size.width * 0.15,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: borderColor,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: bgColor.withOpacity(0.6),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              if (leadingWidget != null) ...[
                leadingWidget,
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: txtColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);

  Timer(duration, () {
    overlayEntry.remove();
  });
}
