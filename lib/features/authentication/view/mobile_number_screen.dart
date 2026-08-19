import 'package:cabme_driver/core/constant/show_toast_dialog.dart';
import 'package:cabme_driver/features/authentication/controller/otp_controller.dart';
import 'package:cabme_driver/features/authentication/controller/phone_number_controller.dart';
import 'package:cabme_driver/features/authentication/view/login_screen.dart';
import 'package:cabme_driver/features/authentication/widget/phone_input_widget.dart';
import 'package:cabme_driver/core/themes/constant_colors.dart';
import 'package:cabme_driver/core/utils/dark_theme_provider.dart';
import 'package:cabme_driver/common/widget/button.dart';
import 'package:cabme_driver/common/widget/custom_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';

class MobileNumberScreen extends StatefulWidget {
  final bool? isLogin;

  const MobileNumberScreen({super.key, this.isLogin});

  @override
  State<MobileNumberScreen> createState() => _MobileNumberScreenState();
}

class _MobileNumberScreenState extends State<MobileNumberScreen>
    with SingleTickerProviderStateMixin {
  final PhoneNumberController controller = Get.put(PhoneNumberController());
  final OTPController otpCtrl = Get.put(OTPController());

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    bool isDarkMode = themeChange.getThem();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          // Dark Navy Theme
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.6, 1.0],
            colors: [
              ConstantColors.navyLight, // Lighter navy
              ConstantColors.blue, // Dark navy
              ConstantColors.navy, // Darkest navy
            ],
          ),
        ),
        child: Stack(
          children: [
            // Decorative Background Circles with green accent
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ConstantColors.primary.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ConstantColors.primary.withOpacity(0.08),
                    width: 1.5,
                  ),
                ),
              ),
            ),

            // Main Content
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      SizedBox(height: MediaQuery.of(context).padding.top + 20),
                      // Header Section
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                IconButton(
                                  onPressed: () => Get.back(),
                                  icon: Icon(
                                    Iconsax.arrow_left_2,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  padding: EdgeInsets.zero,
                                  alignment: Alignment.centerLeft,
                                ),
                                const SizedBox(height: 20),
                                CustomText(
                                  text: widget.isLogin == true
                                      ? "Log in with Mobile".tr
                                      : "Sign Up with Mobile".tr,
                                  size: 32,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                  height: 1.2,
                                ),
                                const SizedBox(height: 12),
                                CustomText(
                                  text: widget.isLogin == true
                                      ? "Enter your mobile number to log in securely and get access to your Mshwar account."
                                          .tr
                                      : "Register using your mobile number for a fast and simple Mshwar sign-up process."
                                          .tr,
                                  size: 15,
                                  color: Colors.white.withOpacity(0.9),
                                  height: 1.5,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Form Card
                      Expanded(
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? AppThemeData.surface50Dark
                                  : AppThemeData.surface50,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(32),
                                topRight: Radius.circular(32),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, -5),
                                ),
                              ],
                            ),
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // Drag Handle
                                    Center(
                                      child: Container(
                                        width: 40,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: isDarkMode
                                              ? AppThemeData.grey300Dark
                                              : AppThemeData.grey300,
                                          borderRadius:
                                              BorderRadius.circular(2),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 32),

                                    // Phone Number Field
                                    PhoneInputWidget(
                                      controller: controller.phoneNumber.value,
                                      onChanged: (value) {
                                        controller.phoneNumber.value.text =
                                            value;
                                      },
                                    ),

                                    const SizedBox(height: 32),

                                    // Send OTP Button
                                    CustomButton(
                                      btnName: 'Send OTP'.tr,
                                      ontap: () => _handleSendOTP(),
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
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16),
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

                                    // Email Login Button
                                    CustomButton(
                                      btnName: widget.isLogin == true
                                          ? 'Email address'.tr
                                          : 'Log in with email address'.tr,
                                      ontap: () {
                                        FocusScope.of(context).unfocus();
                                        Get.back();
                                      },
                                      isOutlined: true,
                                      icon: Icon(
                                        Iconsax.sms,
                                        color: ConstantColors.blue,
                                        size: 22,
                                      ),
                                    ),

                                    const SizedBox(height: 24),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Sign Up/Login Link - Bottom Section
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 20),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? AppThemeData.surface50Dark
                              : AppThemeData.surface50,
                          border: Border(
                            top: BorderSide(
                              color: isDarkMode
                                  ? AppThemeData.grey300Dark.withOpacity(0.3)
                                  : AppThemeData.grey300.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Center(
                          child: widget.isLogin == true
                              ? Text.rich(
                                  TextSpan(
                                    text: 'First time in Mshwar?'.tr,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontFamily: 'pop',
                                      color: isDarkMode
                                          ? AppThemeData.grey500Dark
                                          : AppThemeData.grey800,
                                    ),
                                    children: <TextSpan>[
                                      TextSpan(text: ' '),
                                      TextSpan(
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () => Get.offAll(
                                                MobileNumberScreen(
                                                  isLogin: false,
                                                ),
                                                duration: const Duration(
                                                    milliseconds: 400),
                                                transition:
                                                    Transition.rightToLeft,
                                              ),
                                        text: 'Create an account'.tr,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontFamily: 'pop',
                                          fontWeight: FontWeight.bold,
                                          color: ConstantColors.blue,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Text.rich(
                                  TextSpan(
                                    text: 'Already book rides?'.tr,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontFamily: 'pop',
                                      color: isDarkMode
                                          ? AppThemeData.grey500Dark
                                          : AppThemeData.grey800,
                                    ),
                                    children: <TextSpan>[
                                      TextSpan(text: ' '),
                                      TextSpan(
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () => Get.offAll(
                                                const LoginScreen(),
                                                duration: const Duration(
                                                    milliseconds: 400),
                                                transition:
                                                    Transition.rightToLeft,
                                              ),
                                        text: 'Login'.tr,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontFamily: 'pop',
                                          fontWeight: FontWeight.bold,
                                          color: ConstantColors.blue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSendOTP() async {
    FocusScope.of(context).unfocus();

    final phoneNumber = controller.phoneNumber.value.text.trim();

    // Validate phone number
    if (phoneNumber.isEmpty) {
      ShowToastDialog.showToast('Please enter mobile number'.tr);
      return;
    }

    if (phoneNumber.length != 8) {
      ShowToastDialog.showToast('Kuwait number must be 8 digits'.tr);
      return;
    }

    // Check if number starts with valid prefix
    // Mobile: 5 (STC), 6 (Ooredoo), 9 (Zain), 41 (Virgin Mobile)
    // Landline: 2
    // Test: 999 (for testing purposes - use OTP: 123456)
    final kuwaitPhoneRegex = RegExp(r'^(41\d{6}|[5692]\d{7}|999\d{5})$');
    if (!kuwaitPhoneRegex.hasMatch(phoneNumber)) {
      ShowToastDialog.showToast('Invalid Kuwait phone number'.tr);
      return;
    }

    // If validation passes, send OTP
    ShowToastDialog.showLoader("Code sending".tr);
    otpCtrl.otpController.value.clear();
    controller.SendOTPApiMethod({
      'mobile': '965$phoneNumber',
    });
  }
}
