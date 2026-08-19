// ignore_for_file: must_be_immutable

import 'package:cabme_driver/common/widget/custom_text.dart';
import 'package:cabme_driver/common/widget/button.dart';
import 'package:cabme_driver/common/widget/text_field.dart';
import 'package:cabme_driver/core/constant/show_toast_dialog.dart';
import 'package:cabme_driver/features/bank/controller/bank_details_controller.dart';
import 'package:cabme_driver/core/themes/constant_colors.dart';
import 'package:cabme_driver/core/utils/Preferences.dart';
import 'package:cabme_driver/core/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class AddBankAccount extends StatelessWidget {
  const AddBankAccount({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<BankDetailsController>(
        init: BankDetailsController(),
        builder: (controller) {
          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        height: 10,
                        width: 75,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: themeChange.getThem()
                              ? AppThemeData.grey300Dark
                              : AppThemeData.grey300,
                        )),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Transform(
                          alignment: Alignment.center,
                          transform:
                              Directionality.of(context) == TextDirection.rtl
                                  ? Matrix4.rotationY(3.14159)
                                  : Matrix4.identity(),
                          child: Icon(
                            Iconsax.arrow_left,
                            color: themeChange.getThem()
                                ? AppThemeData.grey900Dark
                                : AppThemeData.grey900,
                            size: 24,
                          ),
                        ),
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                  Form(
                    key: controller.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: CustomText(
                            text: 'Add Bank'.tr,
                            align: TextAlign.center,
                            size: 18,
                            weight: FontWeight.w600,
                            color: themeChange.getThem()
                                ? AppThemeData.grey900Dark
                                : AppThemeData.grey900,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                          decoration: BoxDecoration(
                              color: themeChange.getThem()
                                  ? AppThemeData.surface50Dark
                                  : AppThemeData.surface50,
                              border: Border.all(
                                  color: themeChange.getThem()
                                      ? AppThemeData.grey200Dark
                                      : AppThemeData.grey200,
                                  width: 1),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(12))),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                CustomTextField(
                                  text: 'Bank Name'.tr,
                                  controller:
                                      controller.bankNameController.value,
                                  keyboardType: TextInputType.text,
                                  prefixIcon: Icon(
                                    Iconsax.bank,
                                    color: themeChange.getThem()
                                        ? AppThemeData.grey400Dark
                                        : AppThemeData.grey400,
                                    size: 22,
                                  ),
                                  validator: (String? value) {
                                    if (value!.isNotEmpty) {
                                      return null;
                                    } else {
                                      return 'required'.tr;
                                    }
                                  },
                                ),
                                const SizedBox(height: 16),
                                CustomTextField(
                                  text: 'Branch Name'.tr,
                                  controller:
                                      controller.branchNameController.value,
                                  keyboardType: TextInputType.text,
                                  prefixIcon: Icon(
                                    Iconsax.building,
                                    color: themeChange.getThem()
                                        ? AppThemeData.grey400Dark
                                        : AppThemeData.grey400,
                                    size: 22,
                                  ),
                                  validator: (String? value) {
                                    if (value!.isNotEmpty) {
                                      return null;
                                    } else {
                                      return 'required'.tr;
                                    }
                                  },
                                ),
                                const SizedBox(height: 16),
                                CustomTextField(
                                  text: 'Holder Name'.tr,
                                  controller:
                                      controller.holderNameController.value,
                                  keyboardType: TextInputType.text,
                                  prefixIcon: Icon(
                                    Iconsax.user,
                                    color: themeChange.getThem()
                                        ? AppThemeData.grey400Dark
                                        : AppThemeData.grey400,
                                    size: 22,
                                  ),
                                  validator: (String? value) {
                                    if (value!.isNotEmpty) {
                                      return null;
                                    } else {
                                      return 'required'.tr;
                                    }
                                  },
                                ),
                                const SizedBox(height: 16),
                                CustomTextField(
                                  text: 'Account Number'.tr,
                                  controller:
                                      controller.accountNumberController.value,
                                  keyboardType: TextInputType.number,
                                  prefixIcon: Icon(
                                    Iconsax.card,
                                    color: themeChange.getThem()
                                        ? AppThemeData.grey400Dark
                                        : AppThemeData.grey400,
                                    size: 22,
                                  ),
                                  validator: (String? value) {
                                    if (value!.isNotEmpty) {
                                      return null;
                                    } else {
                                      return 'required'.tr;
                                    }
                                  },
                                ),
                                const SizedBox(height: 16),
                                CustomTextField(
                                  text: 'IFSC Code'.tr,
                                  controller:
                                      controller.ifscCodeController.value,
                                  keyboardType: TextInputType.text,
                                  prefixIcon: Icon(
                                    Iconsax.barcode,
                                    color: themeChange.getThem()
                                        ? AppThemeData.grey400Dark
                                        : AppThemeData.grey400,
                                    size: 22,
                                  ),
                                  validator: (String? value) {
                                    if (value!.isNotEmpty) {
                                      return null;
                                    } else {
                                      return 'required'.tr;
                                    }
                                  },
                                ),
                                const SizedBox(height: 16),
                                CustomTextField(
                                  text: 'Other Informations'.tr,
                                  controller: controller
                                      .otherInformationController.value,
                                  keyboardType: TextInputType.text,
                                  prefixIcon: Icon(
                                    Iconsax.note_text,
                                    color: themeChange.getThem()
                                        ? AppThemeData.grey400Dark
                                        : AppThemeData.grey400,
                                    size: 22,
                                  ),
                                  validator: (String? value) {
                                    if (value!.isNotEmpty) {
                                      return null;
                                    } else {
                                      return 'required'.tr;
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: 16, left: 16, right: 16, top: 16),
                          child: CustomButton(
                              btnName: "Save Bank Details".tr,
                              buttonColor: AppThemeData.primary200,
                              textColor: AppThemeData.grey900Dark,
                              ontap: () {
                                if (controller.formKey.currentState!
                                    .validate()) {
                                  Map<String, String> bodyParams = {
                                    'driver_id':
                                        Preferences.getInt(Preferences.userId)
                                            .toString(),
                                    'bank_name': controller
                                        .bankNameController.value.text,
                                    'branch_name': controller
                                        .branchNameController.value.text,
                                    'holder_name': controller
                                        .holderNameController.value.text,
                                    'account_no': controller
                                        .accountNumberController.value.text,
                                    'information': controller
                                        .otherInformationController.value.text,
                                    'ifsc_code':
                                        controller.ifscCodeController.value.text
                                  };

                                  controller
                                      .setBankDetails(bodyParams)
                                      .then((value) {
                                    if (value != null) {
                                      Get.back(result: true);
                                      controller.getBankDetails();
                                    } else {
                                      ShowToastDialog.showToast(
                                          "Something want wrong.");
                                    }
                                  });
                                }
                              }),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }
}
