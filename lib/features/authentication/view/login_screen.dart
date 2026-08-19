import 'dart:convert';
import 'dart:io';
import 'package:cabme_driver/core/constant/show_toast_dialog.dart';
import 'package:cabme_driver/features/authentication/controller/login_conroller.dart';
import 'package:cabme_driver/features/authentication/model/user_model.dart';
import 'package:cabme_driver/features/authentication/view/forgot_password.dart';
import 'package:cabme_driver/features/authentication/view/mobile_number_screen.dart';
import 'package:cabme_driver/features/authentication/view/waiting_approval_screen.dart';
import 'package:cabme_driver/features/authentication/widget/auth_widgets.dart';
import 'package:cabme_driver/features/dashboard/view/dash_board.dart';
import 'package:cabme_driver/core/themes/constant_colors.dart';
import 'package:cabme_driver/core/utils/Preferences.dart';
import 'package:cabme_driver/core/utils/dark_theme_provider.dart';
import 'package:cabme_driver/common/widget/permission_dialog.dart';
import 'package:cabme_driver/common/widget/button.dart';
import 'package:cabme_driver/common/widget/text_field.dart';
import 'package:cabme_driver/common/widget/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    try {
      PermissionStatus location = await Location().hasPermission();
      if (PermissionStatus.granted != location && mounted) {
        showDialogPermission(context);
      }
    } on PlatformException catch (e) {
      ShowToastDialog.showToast("${e.message}");
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    bool isDarkMode = themeChange.getThem();

    return GetBuilder<LoginController>(
      init: LoginController(),
      builder: (controller) {
        return AuthScreenLayout(
          title: "Welcome Back!",
          subtitle:
              "Log in to your Mshwar account and continue your journey with seamless rides.",
          showBackButton: false,
          bottomWidget: AuthBottomLink(
            text: 'First time in Mshwar?',
            linkText: 'Create an account',
            onTap: () => Get.to(
              MobileNumberScreen(isLogin: false),
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
                  controller: _emailController,
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

                const SizedBox(height: 16),

                // Password Field
                CustomTextField(
                  text: 'Enter password'.tr,
                  controller: _passwordController,
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

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () {
                      Get.to(
                        const ForgotPasswordScreen(),
                        duration: const Duration(milliseconds: 400),
                        transition: Transition.rightToLeft,
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CustomText(
                        text: "Forgot password".tr,
                        size: 14,
                        color: ConstantColors.blue,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Login Button
                CustomButton(
                  btnName: 'Login'.tr,
                  ontap: () => _handleLogin(controller),
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
                      MobileNumberScreen(isLogin: true),
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

                if (!Platform.isIOS && !Platform.isAndroid) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          btnName: 'Google'.tr,
                          ontap: () {
                            controller.loginWithGoogle();
                          },
                          isOutlined: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomButton(
                          btnName: 'Apple'.tr,
                          ontap: () {
                            controller.loginWithApple();
                          },
                          isOutlined: true,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleLogin(LoginController controller) async {
    if (_emailController.text.isEmpty) {
      ShowToastDialog.showToast('Please enter the email address');
      return;
    }

    if (_passwordController.text.isEmpty) {
      ShowToastDialog.showToast('Please enter the password');
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    Map<String, String> bodyParams = {
      'email': _emailController.text.trim(),
      'mdp': _passwordController.text,
      'user_cat': "driver",
      'login_type': 'email'
    };

    await controller.loginAPI(bodyParams).then((value) {
      if (value != null) {
        if (value.success == "success") {
          Preferences.setString(Preferences.user, jsonEncode(value));
          UserData? userData = value.userData;
          Preferences.setInt(
              Preferences.userId, int.parse(userData!.id.toString()));

          // Check approval status
          final isVerified =
              userData.isVerified == "yes" || userData.isVerified == 1;
          final statut = userData.statut == "yes";
          final isFullyApproved = isVerified && statut;

          if (isFullyApproved) {
            // Fully approved - go to dashboard
            Get.offAll(DashBoard(),
                duration: const Duration(milliseconds: 400),
                transition: Transition.rightToLeft);
          } else {
            // Not fully approved - show waiting screen
            Get.offAll(() => const WaitingApprovalScreen(),
                duration: const Duration(milliseconds: 400),
                transition: Transition.rightToLeft);
          }
        } else {
          ShowToastDialog.showToast(value.error);
        }
      }
    });
  }

  void showDialogPermission(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const LocationPermissionDisclosureDialog(),
    );
  }
}
