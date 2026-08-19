import 'package:cabme_driver/core/themes/constant_colors.dart';
import 'package:cabme_driver/core/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

/// Reusable OTP input widget with consistent styling
class OtpInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final int length;
  final Function(String)? onCompleted;
  final Function(String)? onChanged;

  const OtpInputWidget({
    super.key,
    required this.controller,
    this.length = 4,
    this.onCompleted,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDarkMode = themeChange.getThem();

    final defaultPinTheme = PinTheme(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: EdgeInsets.zero,
      height: 56,
      width: 48,
      textStyle: TextStyle(
        letterSpacing: 0,
        fontSize: 20,
        color: isDarkMode ? AppThemeData.grey900Dark : AppThemeData.grey900,
        fontWeight: FontWeight.w600,
        fontFamily: 'pop',
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDarkMode
            ? AppThemeData.grey300Dark.withOpacity(0.5)
            : Colors.white,
        border: Border.all(
          color: isDarkMode ? AppThemeData.grey300Dark : AppThemeData.grey200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );

    return Pinput(
      controller: controller,
      length: length,
      onCompleted: onCompleted,
      onChanged: onChanged,
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: defaultPinTheme.copyWith(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isDarkMode
              ? AppThemeData.grey300Dark.withOpacity(0.5)
              : Colors.white,
          border: Border.all(
            color: AppThemeData.primary200,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppThemeData.primary200.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
      ),
      submittedPinTheme: defaultPinTheme.copyWith(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isDarkMode
              ? AppThemeData.grey300Dark.withOpacity(0.5)
              : Colors.white,
          border: Border.all(
            color: AppThemeData.primary200.withOpacity(0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
      errorPinTheme: defaultPinTheme.copyWith(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isDarkMode
              ? AppThemeData.grey300Dark.withOpacity(0.5)
              : Colors.white,
          border: Border.all(
            color: Colors.red.shade400,
            width: 2,
          ),
        ),
      ),
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      autofocus: true,
      animationDuration: const Duration(milliseconds: 300),
      animationCurve: Curves.easeInOut,
      enableSuggestions: false,
      hapticFeedbackType: HapticFeedbackType.lightImpact,
    );
  }
}
