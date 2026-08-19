import 'package:cabme_driver/core/themes/constant_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget dividerCust({required bool isDarkMode}) {
  return Container(
    color: isDarkMode ? AppThemeData.grey800 : Colors.grey.shade300,
    height: 1,
  );
}

Widget dividerCustHeight({required bool isDarkMode}) {
  return Container(
    color: isDarkMode ? AppThemeData.grey800 : AppThemeData.grey800Dark,
    width: 1,
    height: 55,
  );
}

Widget listTile({required bool isDarkMode, required String lbl, required String value, Color? lblColor, Color? valueColor}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    child: Row(
      children: [
        Expanded(
            child: Text(
          lbl.tr,
          style: TextStyle(
            color: lblColor ?? (isDarkMode ? AppThemeData.grey900Dark : AppThemeData.grey900),
            fontSize: 16,
            fontFamily: AppThemeData.regular,
          ),
        )),
        const SizedBox(width: 10),
        Text(value,
            style: TextStyle(
              color: valueColor ?? (isDarkMode ? AppThemeData.grey900Dark : AppThemeData.grey900),
              fontSize: 16,
              fontFamily: AppThemeData.medium,
            )),
      ],
    ),
  );
}
