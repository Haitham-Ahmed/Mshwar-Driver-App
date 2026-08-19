import 'package:cabme_driver/core/constant/show_toast_dialog.dart';
import 'package:cabme_driver/features/dashboard/controller/dash_board_controller.dart';
import 'package:cabme_driver/features/localization/controller/localization_controller.dart';
import 'package:cabme_driver/features/authentication/view/login_screen.dart';
import 'package:cabme_driver/service/localization_service.dart';
import 'package:cabme_driver/common/widget/custom_app_bar.dart';
import 'package:cabme_driver/common/widget/custom_text.dart';
import 'package:cabme_driver/common/widget/button.dart';
import 'package:cabme_driver/core/themes/constant_colors.dart';
import 'package:cabme_driver/core/utils/Preferences.dart';
import 'package:cabme_driver/core/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class LocalizationScreens extends StatelessWidget {
  final String intentType;

  const LocalizationScreens({super.key, required this.intentType});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<LocalizationController>(
      init: LocalizationController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: themeChange.getThem()
              ? AppThemeData.surface50Dark
              : AppThemeData.surface50,
          appBar: CustomAppBar(
            title: 'Change Language'.tr,
            actions: [
              if (intentType != "dashBoard")
                InkWell(
                  splashColor: Colors.transparent,
                  onTap: () {
                    LocalizationService()
                        .changeLocale(controller.selectedLanguage.value);
                    Preferences.setString(Preferences.languageCodeKey,
                        controller.selectedLanguage.toString());
                    if (intentType == "dashBoard") {
                      ShowToastDialog.showToast("Language change successfully");
                    } else {
                      Get.offAll(const LoginScreen(),
                          transition: Transition.rightToLeft);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: CustomText(
                      text: 'Skip'.tr,
                      size: 16,
                      decoration: TextDecoration.underline,
                      decorationColor: AppThemeData.secondary200,
                      color: AppThemeData.secondary200,
                    ),
                  ),
                ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 6),
                  child: CustomText(
                    text: 'Select your language'.tr,
                    size: 22,
                    weight: FontWeight.w600,
                    color: themeChange.getThem()
                        ? AppThemeData.grey900Dark
                        : AppThemeData.grey900,
                  ),
                ),
                CustomText(
                  text:
                      'Choose a language to personalize your Mshwar experience.'
                          .tr,
                  size: 16,
                  weight: FontWeight.w400,
                  color: themeChange.getThem()
                      ? AppThemeData.grey900Dark
                      : AppThemeData.grey900,
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: ListView.separated(
                    separatorBuilder: (context, index) {
                      return Container(
                        height: 0.6,
                        color: themeChange.getThem()
                            ? AppThemeData.grey300Dark
                            : AppThemeData.grey100,
                      );
                    },
                    itemCount: controller.languageList.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Obx(
                        () => InkWell(
                          splashColor: Colors.transparent,
                          onTap: () {
                            controller.selectedLanguage.value =
                                controller.languageList[index].code.toString();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 16,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            child: Image.network(
                                              controller
                                                  .languageList[index].flag
                                                  .toString(),
                                              height: 35,
                                              width: 50,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Align(
                                              alignment: Alignment.bottomRight,
                                              child: CustomText(
                                                text: controller
                                                    .languageList[index]
                                                    .language
                                                    .toString(),
                                                size: 16,
                                                weight: FontWeight.w500,
                                                color: themeChange.getThem()
                                                    ? AppThemeData.grey900Dark
                                                    : AppThemeData.grey900,
                                              ))
                                        ],
                                      ),
                                    ),
                                    controller.languageList[index].code ==
                                            controller.selectedLanguage.value
                                        ? Icon(
                                            Iconsax.record_circle5,
                                            size: 24,
                                            color: AppThemeData.primary200,
                                          )
                                        : Icon(
                                            Iconsax.record_circle,
                                            size: 24,
                                            color: themeChange.getThem()
                                                ? AppThemeData.grey300Dark
                                                : AppThemeData.grey400,
                                          )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (intentType != "dashBoard")
                  CustomText(
                    text:
                        'You can skip this steps and change it later in your profile settings.'
                            .tr,
                    align: TextAlign.center,
                    size: 16,
                    weight: FontWeight.w400,
                    color: themeChange.getThem()
                        ? AppThemeData.grey400Dark
                        : AppThemeData.grey400,
                  ),
                const SizedBox(height: 5),
              ],
            ),
          ),
          bottomNavigationBar: Padding(
              padding: const EdgeInsets.only(bottom: 30.0, left: 16, right: 16),
              child: Center(
                heightFactor: 1,
                child: CustomButton(
                  btnName:
                      intentType == "dashBoard" ? "Update".tr : 'Continue'.tr,
                  textColor: themeChange.getThem()
                      ? AppThemeData.grey50
                      : AppThemeData.grey50Dark,
                  ontap: () async {
                    LocalizationService()
                        .changeLocale(controller.selectedLanguage.value);
                    Preferences.setString(Preferences.languageCodeKey,
                        controller.selectedLanguage.toString());
                    if (intentType == "dashBoard") {
                      ShowToastDialog.showToast(
                          "Language change successfully".tr);
                      // Refresh drawer items with new language
                      if (Get.isRegistered<DashBoardController>()) {
                        Get.find<DashBoardController>().getDrawerItem();
                      }
                      Get.back();
                    } else {
                      Get.offAll(const LoginScreen());
                    }
                  },
                ),
              )),
        );
      },
    );
  }
}
