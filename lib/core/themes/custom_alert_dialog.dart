import 'package:cabme_driver/core/themes/button_them.dart';
import 'package:cabme_driver/core/themes/constant_colors.dart';
import 'package:cabme_driver/core/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomAlertDialog extends StatefulWidget {
  final String title;
  final String positiveButtonText;
  final String negativeButtonText;
  final Function()? onPressPositive;
  final Function()? onPressNegative;

  const CustomAlertDialog({
    super.key,
    required this.title,
    required this.positiveButtonText,
    required this.negativeButtonText,
    this.onPressPositive,
    this.onPressNegative,
  });

  @override
  CustomAlertDialogState createState() => CustomAlertDialogState();
}

class CustomAlertDialogState extends State<CustomAlertDialog> {
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
    return Stack(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.only(left: 20, top: 20, right: 20, bottom: 20),
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: themeChange.getThem() ? AppThemeData.surface50Dark : AppThemeData.surface50,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: Colors.black, offset: Offset(0, 10), blurRadius: 10),
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                widget.title.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: themeChange.getThem() ? AppThemeData.grey500Dark : AppThemeData.grey500,
                  fontSize: 16,
                  fontFamily: AppThemeData.medium,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                children: [
                  widget.onPressPositive != null
                      ? Expanded(
                          child: ButtonThem.buildButton(
                            context,
                            title: widget.positiveButtonText,
                            btnHeight: 45,
                            btnWidthRatio: 0.8,
                            btnColor: AppThemeData.primary200,
                            txtColor: Colors.white,
                            onPress: widget.onPressPositive!,
                          ),
                        )
                      : Container(),
                  const SizedBox(
                    width: 8,
                  ),
                  widget.onPressNegative != null
                      ? Expanded(
                          child: ButtonThem.buildBorderButton(
                            context,
                            title: widget.negativeButtonText,
                            btnHeight: 45,
                            btnWidthRatio: 0.8,
                            btnColor: themeChange.getThem() ? AppThemeData.grey800 : AppThemeData.grey100,
                            txtColor: themeChange.getThem() ? AppThemeData.grey900Dark : AppThemeData.grey900,
                            btnBorderColor: themeChange.getThem() ? AppThemeData.grey800 : AppThemeData.grey100,
                            onPress: widget.onPressNegative!,
                          ),
                        )
                      : Container()
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}
