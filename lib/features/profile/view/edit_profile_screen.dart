import 'dart:convert';
import 'package:cabme_driver/core/constant/constant.dart';
import 'package:cabme_driver/core/constant/show_toast_dialog.dart';
import 'package:cabme_driver/features/dashboard/controller/dash_board_controller.dart';
import 'package:cabme_driver/features/profile/controller/my_profile_controller.dart';
import 'package:cabme_driver/features/authentication/model/user_model.dart';
import 'package:cabme_driver/common/widget/custom_app_bar.dart';
import 'package:cabme_driver/common/widget/custom_text.dart';
import 'package:cabme_driver/common/widget/button.dart';
import 'package:cabme_driver/common/widget/text_field.dart';
import 'package:cabme_driver/core/themes/constant_colors.dart';
import 'package:cabme_driver/core/utils/Preferences.dart';
import 'package:cabme_driver/core/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatelessWidget {
  EditProfileScreen({super.key});

  final GlobalKey<FormState> passwordKey = GlobalKey();

  /// For Profile Information

  final dashboardController = Get.put(DashBoardController());

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<MyProfileController>(
        init: MyProfileController(),
        builder: (myProfileController) {
          return Scaffold(
            appBar: CustomAppBar(title: 'Edit Profile'.tr),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  text: 'First Name'.tr,
                                  controller:
                                      myProfileController.nameController.value,
                                  keyboardType: TextInputType.text,
                                  prefixIcon: Icon(
                                    Iconsax.user,
                                    color: themeChange.getThem()
                                        ? AppThemeData.grey400Dark
                                        : AppThemeData.grey400,
                                    size: 22,
                                  ),
                                  validator: (String? value) {
                                    if (value != null && value.isNotEmpty) {
                                      return null;
                                    } else {
                                      return "required".tr;
                                    }
                                  },
                                  onChanged: (v) {
                                    if (myProfileController
                                        .nameController.value.text.isNotEmpty) {
                                      myProfileController.updateFirstName({
                                        "id_user":
                                            myProfileController.userID.value,
                                        "prenom": myProfileController
                                            .nameController.value.text,
                                        "user_cat": "driver",
                                      }).then((value) {
                                        if (value != null) {
                                          if (value["success"] == "success") {
                                            UserModel userModel =
                                                Constant.getUserData();
                                            userModel.userData!.prenom =
                                                value['data']['prenom'];
                                            Preferences.setString(
                                                Preferences.user,
                                                jsonEncode(userModel.toJson()));
                                            myProfileController.getUsrData();
                                            dashboardController.getUsrData();
                                            ShowToastDialog.showToast(
                                                value['message']);
                                          }
                                        } else {
                                          ShowToastDialog.showToast(
                                              value['error']);
                                        }
                                      });
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: CustomTextField(
                                  text: 'Last Name'.tr,
                                  controller: myProfileController
                                      .lastNameController.value,
                                  keyboardType: TextInputType.text,
                                  prefixIcon: Icon(
                                    Iconsax.user,
                                    color: themeChange.getThem()
                                        ? AppThemeData.grey400Dark
                                        : AppThemeData.grey400,
                                    size: 22,
                                  ),
                                  validator: (String? value) {
                                    if (value != null && value.isNotEmpty) {
                                      return null;
                                    } else {
                                      return "required".tr;
                                    }
                                  },
                                  onChanged: (v) {
                                    if (myProfileController.lastNameController
                                        .value.text.isNotEmpty) {
                                      myProfileController.updateLastName({
                                        "id_user":
                                            myProfileController.userID.value,
                                        "nom": myProfileController
                                            .lastNameController.value.text,
                                        "user_cat": "driver",
                                      }).then((value) {
                                        if (value != null) {
                                          if (value["success"] == "success") {
                                            UserModel userModel =
                                                Constant.getUserData();
                                            userModel.userData!.nom =
                                                value['data']['nom'];
                                            Preferences.setString(
                                                Preferences.user,
                                                jsonEncode(userModel.toJson()));
                                            myProfileController.getUsrData();
                                            dashboardController.getUsrData();
                                            ShowToastDialog.showToast(
                                                value['message']);
                                          } else {
                                            ShowToastDialog.showToast(
                                                value['error']);
                                          }
                                        }
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller:
                                myProfileController.phoneController.value,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              prefixIcon: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "🇰🇼 +965",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: themeChange.getThem()
                                            ? Colors.white
                                            : Colors
                                                .black, // Adjust color based on theme
                                      ),
                                    ),
                                    const SizedBox(
                                        width:
                                            8), // Space between prefix and input field
                                  ],
                                ),
                              ),
                              hintText: 'Enter mobile number',
                              hintStyle: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                              border: InputBorder.none,
                            ),
                            style: const TextStyle(fontSize: 16),
                            cursorColor: Colors.blue, // Adjust based on theme
                            onChanged: (value) {
                              myProfileController.phoneController.value.text =
                                  value;
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            text: 'Email'.tr,
                            controller:
                                myProfileController.emailController.value,
                            keyboardType: TextInputType.emailAddress,
                            readOnly: true,
                            prefixIcon: Icon(
                              Iconsax.sms,
                              color: themeChange.getThem()
                                  ? AppThemeData.grey400Dark
                                  : AppThemeData.grey400,
                              size: 22,
                            ),
                            validator: (String? value) {
                              if (value != null && value.isNotEmpty) {
                                return null;
                              } else {
                                return "required".tr;
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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

  buildAlertChangeData(
    BuildContext context, {
    required String title,
    required TextEditingController controller,
    required String? Function(String?) validators,
    required Function() onSubmitBtn,
  }) {
    final GlobalKey<FormState> formKey = GlobalKey();
    return Get.defaultDialog(
      titlePadding: EdgeInsets.zero,
      radius: 16,
      title: "",
      contentPadding: const EdgeInsets.all(20),
      content: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: "Change Information".tr,
              size: 20,
              weight: FontWeight.w600,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              text: title,
              controller: controller,
              keyboardType: TextInputType.text,
              validator: validators,
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    btnName: "Save".tr,
                    buttonColor: AppThemeData.primary200,
                    textColor: Colors.white,
                    ontap: onSubmitBtn,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    btnName: "cancel".tr,
                    isOutlined: true,
                    outlineColor: AppThemeData.primary200,
                    textColor: AppThemeData.primary200,
                    ontap: () => Get.back(),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
