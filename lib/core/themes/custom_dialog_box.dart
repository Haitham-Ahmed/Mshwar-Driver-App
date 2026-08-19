import 'package:cabme_driver/core/themes/constant_colors.dart';
import 'package:cabme_driver/core/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomDialogBox extends StatefulWidget {
  final String title, descriptions, text;
  final Image img;
  final Function() onPress;

  const CustomDialogBox(
      {super.key,
      required this.title,
      required this.descriptions,
      required this.text,
      required this.img,
      required this.onPress});

  @override
  CustomDialogBoxState createState() => CustomDialogBoxState();
}

class CustomDialogBoxState extends State<CustomDialogBox> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Container(
      padding: const EdgeInsets.only(left: 20, top: 20, right: 20, bottom: 20),
      decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: themeChange.getThem()
              ? AppThemeData.surface50Dark
              : AppThemeData.surface50,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
                color: Colors.black, offset: Offset(0, 10), blurRadius: 10),
          ]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(
            height: 10,
          ),
          CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 45,
            child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(45)),
                child: widget.img),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            widget.title.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 24,
                color: themeChange.getThem()
                    ? AppThemeData.grey900Dark
                    : AppThemeData.grey900,
                fontFamily: AppThemeData.medium),
          ),
          const SizedBox(
            height: 15,
          ),
          Text(
            widget.descriptions.toString(),
            style: TextStyle(
                fontSize: 16,
                color: themeChange.getThem()
                    ? AppThemeData.grey900Dark
                    : AppThemeData.grey900,
                fontFamily: AppThemeData.regular),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 10,
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: TextButton(
                onPressed: () {
                  // First try to close using Navigator, then call the onPress callback
                  Navigator.of(context, rootNavigator: true).pop();
                  widget.onPress();
                },
                child: Text(
                  widget.text.toString(),
                  style: TextStyle(
                      fontSize: 18,
                      color: AppThemeData.primary200,
                      fontFamily: AppThemeData.medium),
                )),
          ),
        ],
      ),
    );
  }
}
