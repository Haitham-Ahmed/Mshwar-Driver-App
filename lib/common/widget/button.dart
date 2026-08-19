import 'package:cabme_driver/common/widget/custom_text.dart';
import 'package:cabme_driver/core/themes/constant_colors.dart';
import 'package:cabme_driver/core/themes/responsive.dart';
import 'package:cabme_driver/core/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class CustomButton extends StatelessWidget {
  final String? btnName;
  final VoidCallback? ontap;
  final Color? textColor;
  final Color? buttonColor;
  final Color? outlineColor;
  final double? width;
  final double? height;
  final double? borderRadius;
  final double? fontSize;
  final bool? isLoading;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;
  final AlignmentGeometry? alignment;
  final bool isOutlined;
  final double? borderWidth;
  final Widget? icon;
  final FontWeight? fontWeight;

  const CustomButton({
    super.key,
    this.ontap,
    this.btnName,
    this.buttonColor,
    this.textColor,
    this.outlineColor,
    this.width,
    this.height,
    this.borderRadius,
    this.fontSize,
    this.isLoading = false,
    this.padding,
    this.margin,
    this.boxShadow,
    this.gradient,
    this.alignment,
    this.isOutlined = false,
    this.borderWidth,
    this.icon,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDarkMode = themeChange.getThem();

    return Container(
      margin: margin,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: (isLoading ?? false) ? null : ontap,
          borderRadius: BorderRadius.circular(borderRadius ?? 14),
          splashColor: ConstantColors.blue.withOpacity(0.1),
          highlightColor: ConstantColors.blue.withOpacity(0.05),
          child: Ink(
            width: width ?? Responsive.width(100, context),
            height: height ?? 56,
            padding: padding ??
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                  borderRadius ?? 12), // Slightly sharper corners
              boxShadow: boxShadow ??
                  (isOutlined
                      ? null
                      : [
                          BoxShadow(
                            color: AppThemeData.primary200.withOpacity(0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                          BoxShadow(
                            color: AppThemeData.primary300.withOpacity(0.15),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]),
              color: _getBackgroundColor(isDarkMode),
              gradient: isOutlined ? null : gradient,
              border: isOutlined
                  ? Border.all(
                      color: outlineColor ?? ConstantColors.blue,
                      width: borderWidth ?? 1.5,
                    )
                  : null,
            ),
            child: Center(
              child: (isLoading ?? false)
                  ? SpinKitThreeBounce(
                      size: 24,
                      color: _getTextColor(isDarkMode),
                    )
                  : icon != null
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            icon!,
                            const SizedBox(width: 12),
                            CustomText(
                              text: btnName ?? 'Get Started',
                              color: _getTextColor(isDarkMode),
                              size: fontSize ?? 16,
                              weight: fontWeight ?? FontWeight.w600,
                            ),
                          ],
                        )
                      : CustomText(
                          text: btnName ?? 'Get Started',
                          color: _getTextColor(isDarkMode),
                          size: fontSize ?? 16,
                          weight: fontWeight ?? FontWeight.w600,
                        ),
            ),
          ),
        ),
      ),
    );
  }

  // 🔹 Background logic - Dark Navy button
  Color? _getBackgroundColor(bool isDarkMode) {
    if (isOutlined) return Colors.transparent;
    if (gradient != null) return null; // gradient takes over
    return buttonColor ?? ConstantColors.blue; // Dark navy
  }

  // 🔹 Text color logic - Driver App uses white text on dark navy buttons
  Color _getTextColor(bool isDarkMode) {
    if (isOutlined) {
      return textColor ?? outlineColor ?? ConstantColors.blue;
    }
    // White text for better contrast on dark navy buttons
    return textColor ?? Colors.white;
  }
}
