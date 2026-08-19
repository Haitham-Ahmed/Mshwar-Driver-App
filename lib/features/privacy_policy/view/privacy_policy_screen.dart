import 'package:cabme_driver/features/privacy_policy/controller/privacy_policy_controller.dart';
import 'package:cabme_driver/common/widget/custom_app_bar.dart';
import 'package:cabme_driver/common/widget/custom_text.dart';
import 'package:cabme_driver/core/constant/constant.dart';
import 'package:cabme_driver/core/themes/constant_colors.dart';
import 'package:cabme_driver/core/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDarkMode = themeChange.getThem();

    return GetX<PrivacyPolicyController>(
        init: PrivacyPolicyController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: isDarkMode
                ? AppThemeData.surface50Dark
                : AppThemeData.surface50,
            appBar: CustomAppBar(
              title: 'Privacy & Policy'.tr,
              backgroundColor: ConstantColors.blue,
            ),
            body: Stack(
              children: [
                // Background gradient
                Column(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        color: ConstantColors.blue,
                      ),
                    ),
                    Expanded(
                      flex: 8,
                      child: Container(
                        color: isDarkMode
                            ? AppThemeData.surface50Dark
                            : AppThemeData.surface50,
                      ),
                    ),
                  ],
                ),
                SafeArea(
                  child: Column(
                    children: [
                      // Content
                      Expanded(
                        child: controller.privacyData.value.isEmpty
                            ? _buildLoadingState(isDarkMode)
                            : SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Column(
                                  children: [
                                    const SizedBox(height: 8),
                                    // Header Card
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            ConstantColors.blue,
                                            ConstantColors.navy,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: ConstantColors.blue
                                                .withOpacity(0.3),
                                            blurRadius: 20,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Icon(
                                              Iconsax.shield_tick,
                                              size: 32,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                CustomText(
                                                  text:
                                                      'Your Privacy Matters'.tr,
                                                  size: 18,
                                                  weight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                                const SizedBox(height: 4),
                                                CustomText(
                                                  text:
                                                      'Read how we protect your data'
                                                          .tr,
                                                  size: 13,
                                                  color: Colors.white
                                                      .withOpacity(0.9),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 20),

                                    // Content Card
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: isDarkMode
                                            ? AppThemeData.grey800Dark
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: isDarkMode
                                            ? []
                                            : [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.05),
                                                  blurRadius: 20,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                      ),
                                      child: Html(
                                        data: controller.privacyData.value,
                                        style: {
                                          "body": Style(
                                            fontSize: FontSize(15),
                                            lineHeight: LineHeight(1.6),
                                            color: isDarkMode
                                                ? AppThemeData.grey400Dark
                                                : AppThemeData.grey500,
                                            fontFamily: 'pop',
                                          ),
                                          "h1": Style(
                                            fontSize: FontSize(24),
                                            fontWeight: FontWeight.w700,
                                            color: isDarkMode
                                                ? AppThemeData.grey900Dark
                                                : AppThemeData.grey900,
                                            margin: Margins.only(
                                                top: 20, bottom: 12),
                                          ),
                                          "h2": Style(
                                            fontSize: FontSize(20),
                                            fontWeight: FontWeight.w600,
                                            color: isDarkMode
                                                ? AppThemeData.grey900Dark
                                                : AppThemeData.grey900,
                                            margin: Margins.only(
                                                top: 16, bottom: 8),
                                          ),
                                          "h3": Style(
                                            fontSize: FontSize(18),
                                            fontWeight: FontWeight.w600,
                                            color: ConstantColors.blue,
                                            margin: Margins.only(
                                                top: 14, bottom: 8),
                                          ),
                                          "p": Style(
                                            fontSize: FontSize(15),
                                            margin: Margins.only(bottom: 12),
                                          ),
                                          "ul": Style(
                                            margin: Margins.only(
                                                left: 16, bottom: 12),
                                          ),
                                          "li": Style(
                                            fontSize: FontSize(15),
                                            margin: Margins.only(bottom: 8),
                                          ),
                                          "strong": Style(
                                            fontWeight: FontWeight.w600,
                                            color: isDarkMode
                                                ? AppThemeData.grey900Dark
                                                : AppThemeData.grey900,
                                          ),
                                          "a": Style(
                                            color: ConstantColors.blue,
                                            textDecoration:
                                                TextDecoration.underline,
                                          ),
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                  ],
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget _buildLoadingState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Constant.loader(Get.context!, isDarkMode: isDarkMode),
          const SizedBox(height: 16),
          CustomText(
            text: 'Loading Privacy Policy...'.tr,
            size: 14,
            color: isDarkMode ? AppThemeData.grey400Dark : AppThemeData.grey500,
          ),
        ],
      ),
    );
  }
}
