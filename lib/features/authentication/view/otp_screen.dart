import 'package:cabme_driver/common/widget/button.dart';
import 'package:cabme_driver/common/widget/custom_text.dart';
import 'package:cabme_driver/core/constant/show_toast_dialog.dart';
import 'package:cabme_driver/features/authentication/controller/otp_controller.dart';
import 'package:cabme_driver/features/authentication/view/login_screen.dart';
import 'package:cabme_driver/features/authentication/widget/auth_widgets.dart';
import 'package:cabme_driver/core/utils/dark_theme_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:cabme_driver/core/themes/constant_colors.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    bool isDarkMode = themeChange.getThem();

    return GetX<OTPController>(
      init: OTPController(),
      initState: (state) {
        state.controller!.onInit();
      },
      builder: (controller) {
        return AuthScreenLayout(
          title: "Verify Your OTP",
          subtitle:
              "Enter the one-time password sent to your mobile number to verify your account.",
          bottomWidget: AuthBottomLink(
            text: 'Already have an account?',
            linkText: 'Log in',
            onTap: () => Get.offAll(
              const LoginScreen(),
              duration: const Duration(milliseconds: 400),
              transition: Transition.rightToLeft,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Phone Number Display
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                      Iconsax.mobile,
                      color: ConstantColors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    CustomText(
                      text: controller.phoneNumber.value,
                      size: 16,
                      color: isDarkMode
                          ? AppThemeData.grey900Dark
                          : AppThemeData.grey900,
                      weight: FontWeight.w600,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // OTP Input
              OtpInputWidget(
                controller: controller.otpController.value,
                length: 6,
              ),

              const SizedBox(height: 24),

              // Timer and Resend
              Center(
                child: Text.rich(
                  textAlign: TextAlign.center,
                  TextSpan(
                    text: controller.enableResend.value
                        ? "Didn't receive the code?".tr
                        : "Resend code in ".tr,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: AppThemeData.regular,
                      color: isDarkMode
                          ? AppThemeData.grey500Dark
                          : AppThemeData.grey500,
                    ),
                    children: <TextSpan>[
                      if (!controller.enableResend.value)
                        TextSpan(
                          text: controller.formatTime().tr,
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: AppThemeData.semiBold,
                            color: ConstantColors.blue,
                          ),
                        ),
                      if (controller.enableResend.value)
                        TextSpan(
                          text: ' ',
                        ),
                      if (controller.enableResend.value)
                        TextSpan(
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => controller.resendOTP(),
                          text: 'Resend OTP'.tr,
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: AppThemeData.semiBold,
                            color: ConstantColors.blue,
                            decoration: TextDecoration.underline,
                            decorationColor: ConstantColors.blue,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Verify Button
              CustomButton(
                btnName: 'Verify OTP'.tr,
                ontap: () async {
                  FocusScope.of(context).unfocus();
                  if (controller.otpController.value.text.length == 6) {
                    ShowToastDialog.showLoader("Verify OTP".tr);
                    controller.VerifyOTPApiMethod({
                      'mobile': controller.phoneNumber.value,
                      'otp':
                          controller.otpController.value.text.toString().isEmpty
                              ? '123456'
                              : controller.otpController.value.text
                    });
                  } else {
                    ShowToastDialog.showToast("Please enter complete OTP".tr);
                  }
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
