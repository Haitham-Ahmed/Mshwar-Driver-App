import 'package:cabme_driver/core/themes/constant_colors.dart';
import 'package:cabme_driver/core/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class RadioButtonCustom extends StatelessWidget {
  final String name;
  final String groupValue;
  final bool isSelected;
  final Function(String?) onClick;
  final bool isEnabled;
  final String image;
  final bool? isBottomborderRemove;
  final BorderRadiusGeometry? borderRadius;

  const RadioButtonCustom({
    super.key,
    required this.image,
    required this.name,
    required this.groupValue,
    required this.isSelected,
    required this.onClick,
    required this.isEnabled,
    this.isBottomborderRemove = false,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Visibility(
      visible: isEnabled,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: isSelected ? AppThemeData.secondary50 : Colors.transparent,
              borderRadius: borderRadius ?? BorderRadius.circular(0),
            ),
            child: RadioListTile(
              activeColor: AppThemeData.primary200,
              tileColor: Colors.transparent,
              controlAffinity: ListTileControlAffinity.trailing,
              value: name,
              groupValue: groupValue,
              onChanged: onClick,
              selected: isSelected,
              contentPadding: const EdgeInsets.symmetric(horizontal: 6),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16),
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: Image.asset(
                        image,
                        width: 25,
                        height: 25,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: Text(
                      name.tr,
                      style: TextStyle(
                        color: isSelected
                            ? AppThemeData.grey900
                            : themeChange.getThem()
                                ? AppThemeData.grey900Dark
                                : AppThemeData.grey900,
                        fontSize: 16,
                        fontFamily: AppThemeData.medium,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Visibility(
            visible: isBottomborderRemove == false,
            child: Container(
              color: themeChange.getThem() ? AppThemeData.grey300Dark : AppThemeData.grey300,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
