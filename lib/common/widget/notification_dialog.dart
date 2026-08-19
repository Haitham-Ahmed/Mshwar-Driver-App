import 'package:cabme_driver/common/widget/custom_text.dart';
import 'package:cabme_driver/core/themes/constant_colors.dart';
import 'package:cabme_driver/core/utils/dark_theme_provider.dart';
import 'package:cabme_driver/features/notifications/view/notification_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class NotificationDialog {
  static bool _isDialogShowing = false;
  static Map<String, String>? _pendingNotification;

  /// Store a pending notification to show when app opens
  static void setPendingNotification(String title, String message) {
    _pendingNotification = {'title': title, 'message': message};
  }

  /// Check and show pending notification if exists
  static void showPendingNotification(BuildContext context) {
    if (_pendingNotification != null) {
      final notification = _pendingNotification!;
      _pendingNotification = null;

      // Delay slightly to ensure context is ready
      Future.delayed(const Duration(milliseconds: 500), () {
        show(
          context: context,
          title: notification['title'] ?? 'Notification',
          message: notification['message'] ?? '',
        );
      });
    }
  }

  /// Show the notification dialog
  static void show({
    required BuildContext context,
    required String title,
    required String message,
  }) {
    // Prevent multiple dialogs
    if (_isDialogShowing) return;
    _isDialogShowing = true;

    final themeChange = Provider.of<DarkThemeProvider>(context, listen: false);
    final isDarkMode = themeChange.getThem();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Notification',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Container();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );

        return ScaleTransition(
          scale: curvedAnimation,
          child: FadeTransition(
            opacity: animation,
            child: AlertDialog(
              backgroundColor:
                  isDarkMode ? AppThemeData.grey800Dark : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              contentPadding: EdgeInsets.zero,
              content: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Notification Icon with animation
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppThemeData.primary200,
                                  AppThemeData.primary200.withOpacity(0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppThemeData.primary200.withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Iconsax.notification,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    // Title
                    CustomText(
                      text: title,
                      size: 20,
                      weight: FontWeight.bold,
                      color: isDarkMode
                          ? AppThemeData.grey900Dark
                          : AppThemeData.grey900,
                      align: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    // Message
                    Container(
                      constraints: const BoxConstraints(maxHeight: 150),
                      child: SingleChildScrollView(
                        child: CustomText(
                          text: message,
                          size: 15,
                          color: isDarkMode
                              ? AppThemeData.grey500Dark
                              : AppThemeData.grey500,
                          align: TextAlign.center,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Buttons
                    Row(
                      children: [
                        // View All Button
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _isDialogShowing = false;
                              Navigator.of(context).pop();
                              Get.to(() => const NotificationScreen());
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppThemeData.primary200,
                              side: BorderSide(
                                color: AppThemeData.primary200,
                                width: 1.5,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: CustomText(
                              text: 'View All'.tr,
                              size: 14,
                              weight: FontWeight.w600,
                              color: AppThemeData.primary200,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // OK Button
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _isDialogShowing = false;
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppThemeData.primary200,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: CustomText(
                              text: 'OK'.tr,
                              size: 14,
                              weight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ).then((_) {
      _isDialogShowing = false;
    });
  }
}
