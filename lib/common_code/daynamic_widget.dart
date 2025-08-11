import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:qareeb/api_code/map_api_get.dart';
import 'package:qareeb/common_code/colore_screen.dart';

bool uthertextfilde = false;

class DynamicWidget extends StatelessWidget {
  MapSuggestGetApiController mapSuggestGetApiController =
      Get.put(MapSuggestGetApiController());
  final TextEditingController destinationcontroller = TextEditingController();
  ColorNotifier notifier = ColorNotifier();
  DynamicWidget({super.key});

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);

    return Padding(
      padding: EdgeInsets.only(bottom: 8.0),
      child: TextFormField(
        style: TextStyle(color: notifier.textColor),
        controller: destinationcontroller,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '';
          }
          return null;
        },
        onTap: () {
          uthertextfilde = true;
        },
        onChanged: (value) {
          mapSuggestGetApiController.mapApi(
              context: context, suggestkey: destinationcontroller.text);
        },
        decoration: InputDecoration(
            errorStyle: const TextStyle(fontSize: 0.1),
            counterText: "",
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 13, horizontal: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.pink),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: theamcolore),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.4)),
            ),
            hintText: 'Destination'.tr,
            hintStyle: TextStyle(color: notifier.textColor)),
      ),
    );
  }
}
