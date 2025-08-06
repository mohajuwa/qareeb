// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:provider/provider.dart';
import 'package:qareeb/common_code/colore_screen.dart';
import 'package:qareeb/common_code/modern_loading_widget.dart';

class Page_List_description extends StatefulWidget {
  final String title;
  final String description;

  const Page_List_description(
      {super.key, required this.title, required this.description});

  @override
  State<Page_List_description> createState() => _Page_List_descriptionState();
}

class _Page_List_descriptionState extends State<Page_List_description> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  ColorNotifier notifier = ColorNotifier();
  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      backgroundColor: notifier.background,
      appBar: AppBar(
        backgroundColor: notifier.background,
        elevation: 0,
        iconTheme: IconThemeData(
          color: notifier.textColor,
        ),
        title: Text(widget.title,
            style: TextStyle(color: notifier.textColor, fontSize: 16)),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              HtmlWidget(
                onLoadingBuilder: (context, element, loadingProgress) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: Center(child: modernCircularProgress()),
                  );
                },
                widget.description,
                textStyle: TextStyle(
                  color: notifier.textColor,
                  fontSize: 17,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
