import 'package:cabme_driver/core/themes/constant_colors.dart';
import 'package:cabme_driver/core/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart'; // If using GetX for navigation

class AppbarCustom extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onClick;
  final Color? bgColor;
  final List<Widget>? actions;
  final double? elevation;
  final Widget? leading;
  final bool isLeadingIcon;

  const AppbarCustom({
    super.key,
    required this.title,
    this.onClick,
    this.bgColor,
    this.actions,
    this.elevation,
    this.isLeadingIcon = false,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context); // Example usage of theme
    return AppBar(
        backgroundColor: bgColor ?? (themeChange.getThem() ? AppThemeData.surface50Dark : AppThemeData.surface50),
        elevation: elevation ?? 0,
        centerTitle: false,
        titleSpacing: 4,
        title: Text(
          title.tr, // Localization if using GetX
          style: TextStyle(
            fontSize: 18,
            fontFamily: AppThemeData.semiBold,
            color: themeChange.getThem() ? AppThemeData.grey900Dark : AppThemeData.grey900,
          ),
        ),
        leading: isLeadingIcon == true
            ? leading
            : (leading == null)
                ? IconButton(
                    onPressed: onClick ?? () => Get.back(),
                    icon: Transform(
                      alignment: Alignment.center,
                      transform: Directionality.of(context) == TextDirection.rtl ? Matrix4.rotationY(3.14159) : Matrix4.identity(),
                      child: SvgPicture.asset(
                        "assets/icons/ic_back_arrow.svg",
                        colorFilter: ColorFilter.mode(
                          themeChange.getThem() ? AppThemeData.grey900Dark : AppThemeData.grey900,
                          BlendMode.srcIn,
                        ),
                      ),
                    ))
                : null,
        actions: actions);
  }

  // Required by PreferredSizeWidget to define the size of the AppBar
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
