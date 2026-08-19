import 'package:cabme_driver/common/widget/button.dart';
import 'package:cabme_driver/common/widget/custom_text.dart';
import 'package:cabme_driver/core/themes/constant_colors.dart';
import 'package:cabme_driver/core/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

/// Custom dialog widget for consistent styling across the app
class MyCustomDialog extends StatelessWidget {
  final String title;
  final String message;
  final List<Widget>? actions;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final Color? confirmButtonColor;
  final Color? cancelButtonColor;
  final bool showCancel;

  const MyCustomDialog({
    super.key,
    required this.title,
    required this.message,
    this.actions,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.confirmButtonColor,
    this.cancelButtonColor,
    this.showCancel = true,
  });

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDarkMode = themeChange.getThem();

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDarkMode
                  ? AppThemeData.surface50Dark
                  : AppThemeData.surface50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title with top padding for close button
                Padding(
                  padding: const EdgeInsets.only(top: 24, left: 24, right: 48),
                  child: CustomText(
                    text: title,
                    size: 20,
                    weight: FontWeight.bold,
                    color: isDarkMode
                        ? AppThemeData.grey900Dark
                        : AppThemeData.grey900,
                  ),
                ),
                const SizedBox(height: 12),
                // Message
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: CustomText(
                    text: message,
                    size: 16,
                    weight: FontWeight.normal,
                    color: isDarkMode
                        ? AppThemeData.grey400Dark
                        : AppThemeData.grey500,
                  ),
                ),
                const SizedBox(height: 24),
                // Actions
                if (actions != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.9,
                      ),
                      child: actions!.length == 1
                          ? actions!.first
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                for (int i = 0; i < actions!.length; i++) ...[
                                  Expanded(child: actions![i]),
                                  if (i < actions!.length - 1)
                                    const SizedBox(width: 12),
                                ],
                              ],
                            ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.9,
                      ),
                      child: showCancel
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: CustomButton(
                                    btnName: cancelText ?? "No".tr,
                                    isOutlined: true,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 12),
                                    fontSize: 13,
                                    ontap: () {
                                      if (onCancel != null) {
                                        onCancel!();
                                      } else {
                                        Get.back();
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: CustomButton(
                                    btnName: confirmText ?? "Yes".tr,
                                    buttonColor: confirmButtonColor ??
                                        AppThemeData.primary200,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 12),
                                    fontSize: 13,
                                    ontap: () {
                                      if (onConfirm != null) {
                                        onConfirm!();
                                      } else {
                                        Get.back();
                                      }
                                    },
                                  ),
                                ),
                              ],
                            )
                          : CustomButton(
                              btnName: confirmText ?? "OK".tr,
                              buttonColor:
                                  confirmButtonColor ?? AppThemeData.primary200,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 12),
                              fontSize: 13,
                              ontap: () {
                                if (onConfirm != null) {
                                  onConfirm!();
                                } else {
                                  Get.back();
                                }
                              },
                            ),
                    ),
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          // Close button in top-right corner
          Positioned(
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: () {
                if (onCancel != null) {
                  onCancel!();
                } else {
                  Get.back();
                }
              },
              child: Icon(
                Iconsax.close_circle,
                size: 20,
                color: isDarkMode
                    ? AppThemeData.grey400Dark
                    : AppThemeData.grey400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Show a simple confirm/cancel dialog
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    Color? confirmButtonColor,
    Color? cancelButtonColor,
    bool showCancel = true,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => MyCustomDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
        confirmButtonColor: confirmButtonColor,
        cancelButtonColor: cancelButtonColor,
        showCancel: showCancel,
      ),
    );
  }

  /// Show a dialog with custom actions
  static Future<void> showWithActions({
    required BuildContext context,
    required String title,
    required String message,
    required List<Widget> actions,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => MyCustomDialog(
        title: title,
        message: message,
        actions: actions,
      ),
    );
  }
}
