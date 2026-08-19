// ignore_for_file: must_be_immutable
import 'package:cabme_driver/core/constant/show_toast_dialog.dart';
import 'package:cabme_driver/features/dashboard/controller/dash_board_controller.dart';
import 'package:cabme_driver/features/profile/controller/my_profile_controller.dart';
import 'package:cabme_driver/common/widget/custom_app_bar.dart';
import 'package:cabme_driver/common/widget/custom_text.dart';
import 'package:cabme_driver/common/widget/button.dart';
import 'package:cabme_driver/common/widget/text_field.dart';
import 'package:cabme_driver/core/themes/constant_colors.dart';
import 'package:cabme_driver/core/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class ChangePasswordScreen extends StatelessWidget {
  ChangePasswordScreen({super.key});

  final GlobalKey<FormState> _passwordKey = GlobalKey();

  /// For Profile Information

  final dashboardController = Get.put(DashBoardController());

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<MyProfileController>(
        init: MyProfileController(),
        builder: (myProfileController) {
          return Scaffold(
            appBar: CustomAppBar(title: 'Change Password'.tr),
            backgroundColor: themeChange.getThem()
                ? AppThemeData.surface50Dark
                : AppThemeData.surface50,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: themeChange.getThem()
                          ? AppThemeData.grey800Dark
                          : AppThemeData.surface50,
                      border: Border.all(
                        color: themeChange.getThem()
                            ? AppThemeData.grey200Dark
                            : AppThemeData.grey200,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _passwordKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CustomTextField(
                              text: 'Current Password'.tr,
                              controller: myProfileController
                                  .currentPasswordController.value,
                              keyboardType: TextInputType.text,
                              obscureText: true,
                              prefixIcon: Icon(
                                Iconsax.lock,
                                color: themeChange.getThem()
                                    ? AppThemeData.grey400Dark
                                    : AppThemeData.grey400,
                                size: 22,
                              ),
                              validator: (String? value) {
                                if (value!.isNotEmpty) {
                                  return null;
                                } else {
                                  return "required".tr;
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              text: 'New Password'.tr,
                              controller: myProfileController
                                  .newPasswordController.value,
                              keyboardType: TextInputType.text,
                              obscureText: true,
                              prefixIcon: Icon(
                                Iconsax.lock,
                                color: themeChange.getThem()
                                    ? AppThemeData.grey400Dark
                                    : AppThemeData.grey400,
                                size: 22,
                              ),
                              validator: (String? value) {
                                if (value!.isNotEmpty) {
                                  return null;
                                } else {
                                  return "required".tr;
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              text: 'Confirm Password'.tr,
                              controller: myProfileController
                                  .confirmPasswordController.value,
                              keyboardType: TextInputType.text,
                              obscureText: true,
                              prefixIcon: Icon(
                                Iconsax.lock,
                                color: themeChange.getThem()
                                    ? AppThemeData.grey400Dark
                                    : AppThemeData.grey400,
                                size: 22,
                              ),
                              validator: (String? value) {
                                if (value!.isNotEmpty) {
                                  if (value ==
                                      myProfileController
                                          .newPasswordController.value.text) {
                                    return null;
                                  } else {
                                    return "Password Field do not match!!".tr;
                                  }
                                } else {
                                  return "required".tr;
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: CustomButton(
                  btnName: 'Save Password'.tr,
                  ontap: () {
                    if (_passwordKey.currentState!.validate()) {
                      myProfileController.updatePassword({
                        "id_driver": myProfileController.userID.value,
                        "anc_mdp": myProfileController
                            .currentPasswordController.value.text,
                        "new_mdp": myProfileController
                            .newPasswordController.value.text,
                        "user_cat": "driver",
                      }).then((value) {
                        if (value == true) {
                          myProfileController.currentPasswordController.value
                              .clear();
                          myProfileController.newPasswordController.value
                              .clear();
                          myProfileController.confirmPasswordController.value
                              .clear();
                          Get.back();
                          ShowToastDialog.showToast("Password Updated!!");
                        } else {
                          ShowToastDialog.showToast(value.toString());
                        }
                      });
                    }
                  },
                ),
              ),
            ),
          );
        });
  }

  buildShowDetails({
    required String title,
    required IconData icon,
    required Function()? onPress,
    required bool isDarkMode,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        size: 22,
        color: isDarkMode ? AppThemeData.grey900Dark : AppThemeData.grey900,
      ),
      title: CustomText(
        text: title,
        size: 16,
        weight: FontWeight.w500,
        color: isDarkMode ? AppThemeData.grey900Dark : AppThemeData.grey900,
      ),
      onTap: onPress,
      trailing: Icon(
        Iconsax.arrow_right_3,
        size: 20,
        color: isDarkMode ? AppThemeData.grey300Dark : AppThemeData.grey400,
      ),
    );
  }
}
