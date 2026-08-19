import 'package:cabme_driver/core/constant/show_toast_dialog.dart';
import 'package:cabme_driver/features/authentication/controller/forgot_password_controller.dart';
import 'package:cabme_driver/features/authentication/view/forgot_password_otp_screen.dart';
import 'package:cabme_driver/features/authentication/view/mobile_number_screen.dart';
import 'package:cabme_driver/features/authentication/widget/auth_widgets.dart';
import 'package:cabme_driver/core/themes/constant_colors.dart';
import 'package:cabme_driver/core/utils/dark_theme_provider.dart';
import 'package:cabme_driver/common/widget/button.dart';
import 'package:cabme_driver/common/widget/text_field.dart';
import 'package:cabme_driver/common/widget/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final controller = Get.put(ForgotPasswordController());
  final _formKey = GlobalKey<FormState>();
  final _emailTextEditController = TextEditingController();

  @override
  void dispose() {
    _emailTextEditController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    bool isDarkMode = themeChange.getThem();

    return AuthScreenLayout(
      title: "Forgot Your Password?",
      subtitle:
          "Don't worry! Enter your email, and we'll help you reset your password.",
      bottomWidget: AuthBottomLink(
        text: 'First time in Mshwar?',
        linkText: 'Create an account',
        onTap: () => Get.to(
          const MobileNumberScreen(isLogin: false),
          duration: const Duration(milliseconds: 400),
          transition: Transition.rightToLeft,
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Email Field
            CustomTextField(
              text: 'Email address'.tr,
              controller: _emailTextEditController,
              keyboardType: TextInputType.emailAddress,
              validationType: ValidationType.email,
              prefixIcon: Icon(
                Iconsax.sms,
                color: isDarkMode
                    ? AppThemeData.grey400Dark
                    : AppThemeData.grey400,
                size: 22,
              ),
            ),

            const SizedBox(height: 32),

            // Send Button
            CustomButton(
              btnName: 'Send Reset Link'.tr,
              ontap: () => _handleSendEmail(),
            ),

            const SizedBox(height: 32),

            // Divider
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: isDarkMode
                        ? AppThemeData.grey300Dark
                        : AppThemeData.grey300,
                    thickness: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CustomText(
                    text: "or continue with".tr,
                    size: 13,
                    color: isDarkMode
                        ? AppThemeData.grey500Dark
                        : AppThemeData.grey500,
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: isDarkMode
                        ? AppThemeData.grey300Dark
                        : AppThemeData.grey300,
                    thickness: 1,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Mobile Number Button
            CustomButton(
              btnName: 'Mobile number'.tr,
              ontap: () {
                Get.to(
                  const MobileNumberScreen(isLogin: true),
                  duration: const Duration(milliseconds: 400),
                  transition: Transition.rightToLeft,
                );
              },
              isOutlined: true,
              icon: Icon(
                Iconsax.mobile,
                color: ConstantColors.blue,
                size: 22,
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSendEmail() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      Map<String, String> bodyParams = {
        'email': _emailTextEditController.text.trim(),
        'user_cat': "driver",
      };
      controller.sendEmail(bodyParams).then((value) {
        if (value != null) {
          if (value == true) {
            Get.to(
              ForgotPasswordOtpScreen(
                  email: _emailTextEditController.text.trim()),
              duration: const Duration(milliseconds: 400),
              transition: Transition.rightToLeft,
            );
          } else {
            ShowToastDialog.showToast("Please try again later");
          }
        }
      });
    }
  }
}
