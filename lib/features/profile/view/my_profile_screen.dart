// ignore_for_file: must_be_immutable

import 'dart:convert';
import 'dart:io';
import 'package:cabme_driver/core/constant/constant.dart';
import 'package:cabme_driver/core/constant/show_toast_dialog.dart';
import 'package:cabme_driver/features/dashboard/controller/dash_board_controller.dart';
import 'package:cabme_driver/features/profile/controller/my_profile_controller.dart';
import 'package:cabme_driver/features/authentication/model/user_model.dart';
import 'package:cabme_driver/features/authentication/view/login_screen.dart';
import 'package:cabme_driver/features/profile/view/change_password_screen.dart';
import 'package:cabme_driver/features/profile/view/edit_profile_screen.dart';
import 'package:cabme_driver/features/ride/view/new_ride_screens/new_ride_screen.dart';
import 'package:cabme_driver/common/widget/custom_app_bar.dart';
import 'package:cabme_driver/common/widget/custom_text.dart';
import 'package:cabme_driver/common/widget/button.dart';
import 'package:cabme_driver/core/themes/constant_colors.dart';
import 'package:cabme_driver/core/themes/custom_widget.dart';
import 'package:cabme_driver/core/themes/text_field_them.dart';
import 'package:cabme_driver/core/utils/Preferences.dart';
import 'package:cabme_driver/core/utils/dark_theme_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class MyProfileScreen extends StatelessWidget {
  MyProfileScreen({super.key});

  final GlobalKey<FormState> _passwordKey = GlobalKey();

  TextEditingController vColorController = TextEditingController();
  TextEditingController vCarRegistrationController = TextEditingController();

  final dashboardController = Get.put(DashBoardController());

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<MyProfileController>(
        init: MyProfileController(),
        builder: (myProfileController) {
          return WillPopScope(
            onWillPop: () async {
              Get.off(() => NewRideScreen());
              return false;
            },
            child: Scaffold(
              appBar: CustomAppBar(title: 'My Profile'.tr),
              backgroundColor: themeChange.getThem()
                  ? AppThemeData.surface50Dark
                  : AppThemeData.surface50,
              body: Column(
                children: [
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: ConstantColors.blue,
                          width: 3,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: myProfileController.profileImage.isEmpty
                                ? CachedNetworkImage(
                                    imageUrl:
                                        "https://cabme.siswebapp.com/assets/images/placeholder_image.jpg",
                                    height: 140,
                                    width: 140,
                                    fit: BoxFit.cover,
                                    progressIndicatorBuilder: (context, url,
                                            downloadProgress) =>
                                        Constant.loader(context,
                                            isDarkMode: themeChange.getThem()),
                                    errorWidget: (context, url, error) =>
                                        Image.asset(
                                      "assets/icons/appLogo.png",
                                      height: 140,
                                      width: 140,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : CachedNetworkImage(
                                    imageUrl: myProfileController.profileImage
                                        .toString(),
                                    height: 140,
                                    width: 140,
                                    fit: BoxFit.cover,
                                    progressIndicatorBuilder: (context, url,
                                            downloadProgress) =>
                                        Constant.loader(context,
                                            isDarkMode: themeChange.getThem()),
                                    errorWidget: (context, url, error) =>
                                        Image.asset(
                                      "assets/icons/appLogo.png",
                                      height: 140,
                                      width: 140,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: InkWell(
                              onTap: () => buildBottomSheet(context,
                                  myProfileController, themeChange.getThem()),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: ConstantColors.blue,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: themeChange.getThem()
                                        ? AppThemeData.surface50Dark
                                        : AppThemeData.surface50,
                                    width: 3,
                                  ),
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 20,
                                  color: AppThemeData.surface50,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        buildShowDetails(
                          isDarkMode: themeChange.getThem(),
                          title: "Edit Profile".tr,
                          icon: Iconsax.user_edit,
                          onPress: () {
                            Get.to(EditProfileScreen());
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: dividerCust(isDarkMode: themeChange.getThem()),
                        ),
                        buildShowDetails(
                          isDarkMode: themeChange.getThem(),
                          title: "Change Password".tr,
                          icon: Iconsax.lock,
                          onPress: () {
                            Get.to(ChangePasswordScreen());
                          },
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CustomButton(
                        btnName: "Delete Account".tr,
                        buttonColor: AppThemeData.error50,
                        textColor: Colors.white,
                        icon: const Icon(
                          Iconsax.trash,
                          size: 20,
                          color: Colors.white,
                        ),
                        ontap: () async {
                          await showDialog(
                              context: context,
                              useSafeArea: true,
                              builder: (context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  title: CustomText(
                                    text:
                                        'Are you sure you want to delete account?'
                                            .tr,
                                    size: 18,
                                    weight: FontWeight.w600,
                                    align: TextAlign.center,
                                  ),
                                  content: CustomText(
                                    text: 'This action cannot be undone.'.tr,
                                    size: 14,
                                    weight: FontWeight.w400,
                                    align: TextAlign.center,
                                  ),
                                  actions: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: CustomButton(
                                            btnName: 'No'.tr,
                                            buttonColor: Colors.red,
                                            textColor: Colors.white,
                                            ontap: () {
                                              Get.back();
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: CustomButton(
                                            btnName: 'Yes'.tr,
                                            buttonColor: ConstantColors.blue,
                                            textColor: Colors.white,
                                            ontap: () {
                                              myProfileController
                                                  .deleteAccount(
                                                      myProfileController.userID
                                                          .toString())
                                                  .then((value) {
                                                if (value != null) {
                                                  if (value["success"] ==
                                                      "success") {
                                                    ShowToastDialog.showToast(
                                                        value['message']);
                                                    Get.back();
                                                    Preferences
                                                        .clearSharPreference();
                                                    Get.offAll(
                                                        const LoginScreen());
                                                  }
                                                }
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                );
                              });
                        },
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
    Color? textIconColor,
    bool? isTrailingShow = true,
  }) {
    return ListTile(
      splashColor: Colors.transparent,
      leading: Icon(
        icon,
        size: 22,
        color: textIconColor ??
            (isDarkMode ? AppThemeData.grey900Dark : AppThemeData.grey900),
      ),
      title: CustomText(
        text: title,
        size: 16,
        weight: FontWeight.w500,
        color: textIconColor ??
            (isDarkMode ? AppThemeData.grey900Dark : AppThemeData.grey900),
      ),
      onTap: onPress,
      trailing: isTrailingShow == false
          ? null
          : Icon(
              Iconsax.arrow_right_3,
              size: 20,
              color:
                  isDarkMode ? AppThemeData.grey300Dark : AppThemeData.grey400,
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
      titlePadding: const EdgeInsets.only(top: 20),
      radius: 6,
      title: "Change Information".tr,
      titleStyle: const TextStyle(
        fontSize: 20,
      ),
      content: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFieldThem.boxBuildTextField(
                  hintText: title,
                  controller: controller,
                  validators: validators),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      btnName: "Save".tr,
                      buttonColor: ConstantColors.blue,
                      textColor: Colors.white,
                      ontap: onSubmitBtn,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      btnName: "cancel".tr,
                      isOutlined: true,
                      outlineColor: ConstantColors.blue,
                      textColor: ConstantColors.blue,
                      ontap: () => Get.back(),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  buildAlertChangePassword(
    BuildContext context, {
    required MyProfileController myProfileController,
  }) {
    return Get.defaultDialog(
      titlePadding: const EdgeInsets.only(top: 20),
      radius: 6,
      title: "change password".tr,
      titleStyle: const TextStyle(
        fontSize: 20,
      ),
      content: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _passwordKey,
          autovalidateMode: AutovalidateMode.disabled,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFieldThem.boxBuildTextField(
                hintText: "Current Password".tr,
                obscureText: false,
                controller: myProfileController.currentPasswordController.value,
                validators: (valve) {
                  if (valve!.isNotEmpty) {
                    return null;
                  } else {
                    return "required".tr;
                  }
                },
              ),
              const SizedBox(
                height: 10,
              ),
              TextFieldThem.boxBuildTextField(
                hintText: "New Password".tr,
                obscureText: false,
                controller: myProfileController.newPasswordController.value,
                validators: (valve) {
                  if (valve!.isNotEmpty) {
                    return null;
                  } else {
                    return "required".tr;
                  }
                },
              ),
              const SizedBox(
                height: 10,
              ),
              TextFieldThem.boxBuildTextField(
                hintText: "Confirm Password".tr,
                obscureText: false,
                controller: myProfileController.confirmPasswordController.value,
                validators: (valve) {
                  if (valve!.isNotEmpty) {
                    if (valve ==
                        myProfileController.newPasswordController.value.text) {
                      return null;
                    } else {
                      return "Password Field do not match  !!".tr;
                    }
                  } else {
                    return "required".tr;
                  }
                },
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      btnName: "Save".tr,
                      buttonColor: ConstantColors.blue,
                      textColor: Colors.white,
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
                            Get.back();
                            if (value == true) {
                              ShowToastDialog.showToast("Password Updated!!");
                            } else {
                              ShowToastDialog.showToast(value.toString());
                            }
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      btnName: "cancel".tr,
                      isOutlined: true,
                      outlineColor: ConstantColors.blue,
                      textColor: ConstantColors.blue,
                      ontap: () => Get.back(),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  buildBottomSheet(
      BuildContext context, MyProfileController controller, bool isDarkMode) {
    return showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Container(
              decoration: BoxDecoration(
                color: isDarkMode
                    ? AppThemeData.surface50Dark
                    : AppThemeData.surface50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? AppThemeData.grey200Dark
                              : AppThemeData.grey200,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 20),
                      CustomText(
                        text: "Please Select".tr,
                        size: 20,
                        weight: FontWeight.w600,
                        color: isDarkMode
                            ? AppThemeData.grey900Dark
                            : AppThemeData.grey900,
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => pickFile1(controller,
                                  source: ImageSource.camera),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 24),
                                decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? AppThemeData.grey800Dark
                                      : AppThemeData.grey50,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isDarkMode
                                        ? AppThemeData.grey200Dark
                                        : AppThemeData.grey200,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: ConstantColors.blue
                                            .withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.camera_alt,
                                        size: 32,
                                        color: ConstantColors.blue,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    CustomText(
                                      text: "camera".tr,
                                      size: 14,
                                      weight: FontWeight.w500,
                                      color: isDarkMode
                                          ? AppThemeData.grey900Dark
                                          : AppThemeData.grey900,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: () => pickFile1(controller,
                                  source: ImageSource.gallery),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 24),
                                decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? AppThemeData.grey800Dark
                                      : AppThemeData.grey50,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isDarkMode
                                        ? AppThemeData.grey200Dark
                                        : AppThemeData.grey200,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: ConstantColors.blue
                                            .withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.photo_library_sharp,
                                        size: 32,
                                        color: ConstantColors.blue,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    CustomText(
                                      text: "gallery".tr,
                                      size: 14,
                                      weight: FontWeight.w500,
                                      color: isDarkMode
                                          ? AppThemeData.grey900Dark
                                          : AppThemeData.grey900,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }

  requiredValidator(String? value) {
    if (value != null || value!.isNotEmpty) {
      return null;
    } else {
      return "required".tr;
    }
  }

  final ImagePicker _imagePicker = ImagePicker();

  Future pickFile1(MyProfileController controller,
      {required ImageSource source}) async {
    try {
      XFile? image = await _imagePicker.pickImage(source: source);
      if (image == null) return;
      Get.back();
      controller.uploadPhoto(File(image.path)).then((value) async {
        if (value != null) {
          if (value["success"] == "Success") {
            UserModel userModel = Constant.getUserData();
            userModel.userData!.photoPath = value['data']['photo_path'];
            Preferences.setString(
                Preferences.user, jsonEncode(userModel.toJson()));
            controller.getUsrData();
            dashboardController.getUsrData();
            ShowToastDialog.showToast("Upload successfully!");
          } else {
            ShowToastDialog.showToast(value['error']);
          }
        }
      });
    } on PlatformException catch (e) {
      ShowToastDialog.showToast("${"Failed to Pick".tr} : \n $e");
    }
  }
}
