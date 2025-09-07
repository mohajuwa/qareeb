// ignore_for_file: avoid_print
// ignore_for_file: unused_field, unused_element, depend_on_referenced_packages, camel_case_types, non_constant_identifier_names, prefer_typing_uninitialized_variables, avoid_init_to_null, use_build_context_synchronously, unnecessary_brace_in_string_interps, prefer_final_fields
// ignore_for_file: unused_import, must_be_immutable, use_super_parameters,
// ignore_for_file: use_key_in_widget_constructors, prefer_interpolation_to_compose_strings, unnecessary_string_interpolations, await_only_futures, prefer_const_constructors, avoid_unnecessary_containers, file_names, void_checks, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
                style: const TextStyle(fontSize: 15, fontFamily: "Khebrat")),
            TextSpan(
                text: txt2,
                style: const TextStyle(fontSize: 15, fontFamily: "Khebrat")),
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
                    fontFamily: "Khebrat")),
            TextSpan(
                text: txt2,
                style: TextStyle(
                    fontSize: 15, color: clore, fontFamily: "Khebrat")),
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
        return 'Please enter some text';
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

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> snackbar(
    {required context, required String text}) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
      backgroundColor: Colors.black,
      elevation: 10,
    ),
  );
}
