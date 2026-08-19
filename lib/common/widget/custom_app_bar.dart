import 'package:cabme_driver/common/widget/custom_text.dart';
import 'package:cabme_driver/core/themes/constant_colors.dart';
import 'package:cabme_driver/core/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final Color? titleColor;
  final double? elevation;
  final bool centerTitle;
  final Widget? leading;
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    super.key,
    this.title = "",
    this.titleWidget,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
    this.backgroundColor,
    this.titleColor,
    this.elevation = 0,
    this.centerTitle = false,
    this.leading,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context, listen: false);
    final isDarkMode = themeChange.getThem();
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    // Determine background color - default to theme surface color for consistency
    final bgColor = backgroundColor ??
        (isDarkMode ? AppThemeData.surface50Dark : AppThemeData.surface50);

    // Determine title color
    final textColor = titleColor ??
        (bgColor == AppThemeData.primary200
            ? AppThemeData.surface50
            : (isDarkMode ? AppThemeData.grey900Dark : AppThemeData.grey900));

    // Determine back button container color
    final backButtonBgColor = bgColor == AppThemeData.primary200
        ? Colors.white.withOpacity(0.2)
        : (isDarkMode
            ? AppThemeData.grey200Dark.withOpacity(0.3)
            : AppThemeData.grey200.withOpacity(0.5));

    // Determine back button icon color
    final backButtonIconColor = bgColor == AppThemeData.primary200
        ? Colors.white
        : (isDarkMode ? AppThemeData.grey900Dark : AppThemeData.grey900);

    return AppBar(
      backgroundColor: backgroundColor ?? Colors.white,
      elevation: elevation,
      centerTitle: centerTitle,
      automaticallyImplyLeading: false,
      toolbarHeight: 48,
      titleSpacing: 0,
      leadingWidth: (showBackButton || leading != null) ? 48 : 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: (showBackButton || leading != null)
          ? Center(
              child: Padding(
                padding: EdgeInsets.only(
                  left: isRTL ? 0 : 4,
                  right: isRTL ? 4 : 0,
                ),
                child: leading ??
                    InkWell(
                      onTap: onBackPressed ?? () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: backButtonBgColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Transform(
                          alignment: Alignment.center,
                          transform: isRTL
                              ? Matrix4.rotationY(3.14159)
                              : Matrix4.identity(),
                          child: Icon(
                            Iconsax.arrow_left_2,
                            color: backButtonIconColor,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
              ),
            )
          : null,
      title: titleWidget != null
          ? Padding(
              padding: EdgeInsets.only(
                left: showBackButton ? 4 : 16,
                right: 0,
              ),
              child: titleWidget,
            )
          : title.isNotEmpty
              ? Padding(
                  padding: EdgeInsets.only(
                    left: showBackButton ? 4 : 16,
                    right: 0,
                  ),
                  child: CustomText(
                    text: title.tr,
                    size: 17,
                    weight: FontWeight.w600,
                    color: textColor,
                  ),
                )
              : null,
      actions: actions != null
          ? [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: actions!,
                ),
              ),
            ]
          : null,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(48 + (bottom?.preferredSize.height ?? 0));
}

// Convenience function for backward compatibility
PreferredSizeWidget myCustomAppBar(
  BuildContext context,
  String title, {
  Widget? action,
  List<Widget>? actions,
  bool showBackIcon = true,
  VoidCallback? onBackPressed,
  Color? backgroundColor,
  Color? titleColor,
  double? elevation = 0,
  bool centerTitle = false,
}) {
  return CustomAppBar(
    title: title,
    actions: actions ?? (action != null ? [action] : null),
    showBackButton: showBackIcon,
    onBackPressed: onBackPressed,
    backgroundColor: backgroundColor,
    titleColor: titleColor,
    elevation: elevation,
    centerTitle: centerTitle,
  );
}
