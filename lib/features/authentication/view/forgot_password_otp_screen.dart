import 'package:cabme_driver/core/constant/show_toast_dialog.dart';
import 'package:cabme_driver/features/authentication/controller/forgot_password_controller.dart';
import 'package:cabme_driver/features/authentication/view/login_screen.dart';
import 'package:cabme_driver/features/authentication/widget/auth_widgets.dart';
import 'package:cabme_driver/core/themes/constant_colors.dart';
import 'package:cabme_driver/common/widget/button.dart';
import 'package:cabme_driver/common/widget/text_field.dart';
import 'package:cabme_driver/common/widget/custom_text.dart';
import 'package:cabme_driver/core/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class ForgotPasswordOtpScreen extends StatefulWidget {
  final String? email;

  const ForgotPasswordOtpScreen({super.key, required this.email});

  @override
  State<ForgotPasswordOtpScreen> createState() =>
      _ForgotPasswordOtpScreenState();
}

class _ForgotPasswordOtpScreenState extends State<ForgotPasswordOtpScreen> {
  final controller = Get.put(ForgotPasswordController());
  final _formKey = GlobalKey<FormState>();
  final textEditingController = TextEditingController();
  final _passwordController = TextEditingController();
  final _conformPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    textEditingController.dispose();
    _passwordController.dispose();
    _conformPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    bool isDarkMode = themeChange.getThem();

    return AuthScreenLayout(
      title: "Reset Your Password",
      subtitle:
          "Enter the OTP sent to your email, then create a new password for your account.",
      bottomWidget: Center(
        child: InkWell(
          onTap: () {
            Get.offAll(
              const LoginScreen(),
              duration: const Duration(milliseconds: 400),
              transition: Transition.rightToLeft,
            );
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomText(
              text: 'Back to Login'.tr,
              size: 15,
              color: ConstantColors.blue,
              weight: FontWeight.bold,
            ),
          ),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Email Display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? AppThemeData.grey300Dark.withOpacity(0.3)
                    : AppThemeData.grey100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDarkMode
                      ? AppThemeData.grey300Dark
                      : AppThemeData.grey200,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.sms,
                    color: ConstantColors.blue,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: CustomText(
                      text: widget.email ?? '',
                      size: 16,
                      color: isDarkMode
                          ? AppThemeData.grey900Dark
                          : AppThemeData.grey900,
                      weight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // OTP Label
            CustomText(
              text: 'Enter OTP Code'.tr,
              size: 14,
              color:
                  isDarkMode ? AppThemeData.grey500Dark : AppThemeData.grey500,
              weight: FontWeight.w500,
            ),

            const SizedBox(height: 12),

            // OTP Input
            OtpInputWidget(
              controller: textEditingController,
              length: 4,
            ),

            const SizedBox(height: 32),

            // Password Field
            CustomTextField(
              text: 'New Password'.tr,
              controller: _passwordController,
              keyboardType: TextInputType.text,
              obscureText: !_isPasswordVisible,
              prefixIcon: Icon(
                Iconsax.lock,
                color: isDarkMode
                    ? AppThemeData.grey400Dark
                    : AppThemeData.grey400,
                size: 22,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Iconsax.eye : Iconsax.eye_slash,
                  color: isDarkMode
                      ? AppThemeData.grey500Dark
                      : AppThemeData.grey400,
                  size: 22,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              validator: (String? value) {
                if (value!.length >= 6) {
                  return null;
                } else {
                  return 'Password required at least 6 characters'.tr;
                }
              },
            ),

            const SizedBox(height: 16),

            // Confirm Password Field
            CustomTextField(
              text: 'Confirm Password'.tr,
              controller: _conformPasswordController,
              keyboardType: TextInputType.text,
              obscureText: !_isConfirmPasswordVisible,
              prefixIcon: Icon(
                Iconsax.lock,
                color: isDarkMode
                    ? AppThemeData.grey400Dark
                    : AppThemeData.grey400,
                size: 22,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordVisible ? Iconsax.eye : Iconsax.eye_slash,
                  color: isDarkMode
                      ? AppThemeData.grey500Dark
                      : AppThemeData.grey400,
                  size: 22,
                ),
                onPressed: () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                },
              ),
              validator: (String? value) {
                if (_passwordController.text.trim() !=
                    value!.toString().trim()) {
                  return 'Confirm password is invalid'.tr;
                } else {
                  return null;
                }
              },
            ),

            const SizedBox(height: 32),

            // Reset Password Button
            CustomButton(
              btnName: 'Reset Password'.tr,
              ontap: () => _handleResetPassword(),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _handleResetPassword() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      if (textEditingController.text.length != 4) {
        ShowToastDialog.showToast("Please enter complete OTP".tr);
        return;
      }

      Map<String, String> bodyParams = {
        'email': widget.email.toString(),
        'otp': textEditingController.text.trim(),
        'new_password': _passwordController.text.trim(),
        'confirm_password': _passwordController.text.trim(),
        'user_cat': "driver",
      };
      controller.resetPassword(bodyParams).then((value) {
        if (value != null) {
          if (value == true) {
            Get.offAll(const LoginScreen(),
                duration: const Duration(milliseconds: 400),
                transition: Transition.rightToLeft);
            ShowToastDialog.showToast("Password changed successfully!");
          } else {
            ShowToastDialog.showToast("Please try again later");
          }
        }
      });
    }
  }
}
