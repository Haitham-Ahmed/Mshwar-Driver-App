import 'dart:convert';
import 'package:cabme_driver/common/widget/button.dart';
import 'package:cabme_driver/core/constant/show_toast_dialog.dart';
import 'package:cabme_driver/features/authentication/controller/sign_up_controller.dart';
import 'package:cabme_driver/features/authentication/view/login_screen.dart';
import 'package:cabme_driver/features/authentication/widget/auth_widgets.dart';
import 'package:cabme_driver/features/document/view/document_status_screen.dart';
import 'package:cabme_driver/core/themes/constant_colors.dart';
import 'package:cabme_driver/core/utils/Preferences.dart';
import 'package:cabme_driver/core/utils/dark_theme_provider.dart';
import 'package:cabme_driver/common/widget/text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    bool isDarkMode = themeChange.getThem();

    return GetBuilder<SignUpController>(
      init: SignUpController(),
      builder: (controller) {
        // Strip country code (965 or +965) from phone number if present
        String phoneArg = Get.arguments?['phoneNumber'] ?? "";
        if (phoneArg.startsWith('+965')) {
          phoneArg = phoneArg.substring(4);
        } else if (phoneArg.startsWith('965')) {
          phoneArg = phoneArg.substring(3);
        }
        if (phoneArg.isNotEmpty) {
          controller.phoneNumber.value.text = phoneArg;
        }

        return AuthScreenLayout(
          title: "Create Your Account",
          subtitle:
              "Sign up for a personalized Mshwar experience. Start driving and earning in just a few taps.",
          bottomWidget: AuthBottomLink(
            text: 'Already a driver?',
            linkText: 'Login',
            onTap: () => Get.offAll(
              const LoginScreen(),
              duration: const Duration(milliseconds: 400),
              transition: Transition.rightToLeft,
            ),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // First Name & Last Name Row
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        text: 'First Name'.tr,
                        controller: controller.firstNameController.value,
                        keyboardType: TextInputType.name,
                        maxWords: 22,
                        validationType: ValidationType.name,
                        prefixIcon: Icon(
                          Iconsax.user,
                          color: isDarkMode
                              ? AppThemeData.grey400Dark
                              : AppThemeData.grey400,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        text: 'Last Name'.tr,
                        controller: controller.lastNameController.value,
                        keyboardType: TextInputType.name,
                        maxWords: 22,
                        validationType: ValidationType.name,
                        prefixIcon: Icon(
                          Iconsax.user,
                          color: isDarkMode
                              ? AppThemeData.grey400Dark
                              : AppThemeData.grey400,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Phone Number (Read-only)
                PhoneInputWidget(
                  controller: controller.phoneNumber.value,
                  readOnly: true,
                  onChanged: (value) {
                    controller.phoneNumber.value.text = value;
                  },
                ),

                const SizedBox(height: 16),

                // Email Field
                CustomTextField(
                  text: 'Email address'.tr,
                  controller: controller.emailController.value,
                  keyboardType: TextInputType.emailAddress,
                  validationType: ValidationType.email,
                  readOnly: controller.loginType.value == "google" ||
                      controller.loginType.value == "apple",
                  prefixIcon: Icon(
                    Iconsax.sms,
                    color: isDarkMode
                        ? AppThemeData.grey400Dark
                        : AppThemeData.grey400,
                    size: 22,
                  ),
                ),

                const SizedBox(height: 16),

                // Password Field (if not social login)
                if (controller.loginType.value != "google" &&
                    controller.loginType.value != "apple") ...[
                  CustomTextField(
                    text: 'Password'.tr,
                    controller: controller.passwordController.value,
                    keyboardType: TextInputType.text,
                    obscureText: !_isPasswordVisible,
                    validationType: ValidationType.password,
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
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password Field
                  CustomTextField(
                    text: 'Confirm Password'.tr,
                    controller: controller.conformPasswordController.value,
                    keyboardType: TextInputType.text,
                    obscureText: !_isConfirmPasswordVisible,
                    validationType: ValidationType.confirmPassword,
                    passwordController: controller.passwordController.value,
                    prefixIcon: Icon(
                      Iconsax.lock,
                      color: isDarkMode
                          ? AppThemeData.grey400Dark
                          : AppThemeData.grey400,
                      size: 22,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Iconsax.eye
                            : Iconsax.eye_slash,
                        color: isDarkMode
                            ? AppThemeData.grey500Dark
                            : AppThemeData.grey400,
                        size: 22,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                const SizedBox(height: 32),

                // Sign Up Button
                CustomButton(
                  btnName: 'Sign up'.tr,
                  ontap: () => _handleSignUp(controller),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleSignUp(SignUpController controller) async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      // Phone number is already OTP-verified, no need to validate again
      final phoneNumber = controller.phoneNumber.value.text.trim();

      Map<String, String> bodyParams = {
        'firstname':
            controller.firstNameController.value.text.trim().toString(),
        'lastname': controller.lastNameController.value.text.trim().toString(),
        'phone': '965$phoneNumber',
        'email': controller.emailController.value.text.trim(),
        'password': controller.passwordController.value.text,
        'login_type': controller.loginType.value,
        'tonotify': 'yes',
        'account_type': 'driver',
      };

      await controller.signUp(bodyParams).then((value) {
        if (value != null) {
          if (value.success == "success") {
            Preferences.setInt(
                Preferences.userId, int.parse(value.userData!.id.toString()));
            Preferences.setString(Preferences.user, jsonEncode(value));
            Preferences.setBoolean(Preferences.isLogin, true);
            controller.phoneNumber.value.clear();

            // Redirect to documents screen after signup
            Get.offAll(() => DocumentStatusScreen());
          } else {
            ShowToastDialog.showToast(value.error);
          }
        }
      });
    }
  }
}
