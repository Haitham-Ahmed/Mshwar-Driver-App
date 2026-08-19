import 'package:cabme_driver/core/constant/constant.dart';
import 'package:cabme_driver/core/themes/constant_colors.dart';
import 'package:cabme_driver/core/themes/responsive.dart';
import 'package:cabme_driver/core/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ButtonThem {
  const ButtonThem({Key? key});

  static buildButton(
    BuildContext context, {
    required String title,
    Color? btnColor,
    required Color txtColor,
    double btnHeight = 50,
    double txtSize = 16,
    double btnWidthRatio = 1,
    double radius = 10,
    required Function() onPress,
    bool isVisible = true,
  }) {
    return Visibility(
      visible: isVisible,
      child: SizedBox(
        width: Responsive.width(100, context) * btnWidthRatio,
        child: MaterialButton(
          onPressed: onPress,
          height: btnHeight,
          elevation: 0.5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          color: btnColor ?? AppThemeData.primary200,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: txtColor,
              fontSize: txtSize,
              fontFamily: AppThemeData.medium,
            ),
          ),
        ),
      ),
    );
  }

  static statusButton(
    BuildContext context, {
    required String title,
    Color? btnColor,
    required Color txtColor,
    double btnHeight = 50,
    double txtSize = 14,
    double btnWidthRatio = 1,
    double radius = 10,
    required Function() onPress,
    bool isVisible = true,
  }) {
    return Visibility(
      visible: isVisible,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: btnColor!.withAlpha(50),
          borderRadius: BorderRadius.circular(4),
        ),
        height: btnHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            Constant().capitalizeWords(title),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: txtColor,
              fontSize: txtSize,
              fontFamily: AppThemeData.medium,
            ),
          ),
        ),
      ),
    );
  }

  static buildBorderButton(
    BuildContext context, {
    required String title,
    required Color btnColor,
    required Color btnBorderColor,
    required Color txtColor,
    double btnHeight = 50,
    double txtSize = 14,
    double btnWidthRatio = 0.9,
    required Function() onPress,
    bool isVisible = true,
  }) {
    return Visibility(
      visible: isVisible,
      child: SizedBox(
        width: Responsive.width(100, context) * btnWidthRatio,
        height: btnHeight,
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all<Color>(btnColor),
            foregroundColor: WidgetStateProperty.all<Color>(txtColor),
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.0),
                side: BorderSide(color: btnBorderColor, width: 1.5),
              ),
            ),
          ),
          onPressed: onPress,
          child: Text(title.toString()),
        ),
      ),
    );
  }

  static buildIconButton(
    BuildContext context, {
    required String title,
    required Color btnColor,
    required Color txtColor,
    required Color iconColor,
    required IconData icon,
    double btnHeight = 50,
    double txtSize = 16,
    double btnWidthRatio = 0.9,
    required Function() onPress,
    bool isVisible = true,
  }) {
    return Visibility(
      visible: isVisible,
      child: SizedBox(
        width: Responsive.width(100, context) * btnWidthRatio,
        height: btnHeight,
        child: TextButton.icon(
          style: TextButton.styleFrom(
            backgroundColor: btnColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.0),
            ),
          ),
          onPressed: onPress,
          label: Text(
            title.toString(),
            style: TextStyle(color: txtColor, fontSize: txtSize),
          ),
          icon: Icon(icon, color: iconColor),
        ),
      ),
    );
  }

  static buildIconButtonWidget(
      BuildContext context, {
        required String title,
        Color? btnColor,
        Color? txtColor,
        required Color iconColor,
        required Widget icon,
        double btnHeight = 50,
        double txtSize = 16,
        double btnWidthRatio = 0.9,
        iconSize = 18.0,
        required Function() onPress,
        double radius = 10,
        bool isVisible = true,
      }) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Visibility(
      visible: isVisible,
      child: SizedBox(
        // width: Responsive.width(100, context) * btnWidthRatio,
        width: double.infinity,
        height: btnHeight,
        child: TextButton.icon(
          style: TextButton.styleFrom(
            backgroundColor: btnColor ?? AppThemeData.primary200,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
          onPressed: onPress,
          label: Text(
            title,
            style: TextStyle(
              color: txtColor ?? (themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey50Dark),
              fontFamily: AppThemeData.medium,
              fontSize: txtSize,
            ),
          ),
          icon: icon,
        ),
      ),
    );
  }
}
