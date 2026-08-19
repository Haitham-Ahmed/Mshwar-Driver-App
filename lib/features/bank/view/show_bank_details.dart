import 'package:cabme_driver/features/bank/controller/bank_details_controller.dart';
import 'package:cabme_driver/features/bank/view/add_bank_account.dart';
import 'package:cabme_driver/common/widget/custom_app_bar.dart';
import 'package:cabme_driver/common/widget/custom_text.dart';
import 'package:cabme_driver/common/widget/button.dart';
import 'package:cabme_driver/core/themes/constant_colors.dart';
import 'package:cabme_driver/core/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class ShowBankDetails extends StatelessWidget {
  const ShowBankDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<BankDetailsController>(
      init: BankDetailsController(),
      builder: (controller) {
        return Scaffold(
          appBar: CustomAppBar(title: 'Add Bank Details'.tr),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: controller.isLoading.value
                ? SizedBox()
                : controller.bankDetails.value.bankName == null &&
                        controller.bankDetails.value.branchName == null &&
                        controller.bankDetails.value.holderName == null &&
                        controller.bankDetails.value.accountNo == null &&
                        controller.bankDetails.value.otherInfo == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Image.asset(
                                'assets/images/add_bank_placeholder.png'),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 16, top: 100),
                            child: CustomText(
                              text:
                                  'You have not  added bank account \n please add bank account'
                                      .tr,
                              align: TextAlign.center,
                              size: 16,
                              weight: FontWeight.w400,
                              color: themeChange.getThem()
                                  ? AppThemeData.grey400Dark
                                  : AppThemeData.grey400,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 40, left: 25, right: 25),
                            child: CustomButton(
                              btnName: "Add Bank".tr,
                              buttonColor: AppThemeData.primary200,
                              textColor: Colors.white,
                              ontap: () {
                                showModalBottomSheet(
                                    isDismissible: true,
                                    isScrollControlled: true,
                                    context: context,
                                    backgroundColor: themeChange.getThem()
                                        ? AppThemeData.grey50Dark
                                        : AppThemeData.grey50,
                                    builder: (context) {
                                      return const AddBankAccount();
                                    });
                              },
                            ),
                          )
                        ],
                      )
                    : Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        decoration: BoxDecoration(
                          color: themeChange.getThem()
                              ? AppThemeData.surface50Dark
                              : AppThemeData.surface50,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 30),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Iconsax.bank,
                                          size: 25,
                                          color: themeChange.getThem()
                                              ? AppThemeData.grey200
                                              : AppThemeData.grey500Dark,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 16),
                                          child: CustomText(
                                            text: 'Bank Name'.tr,
                                            size: 16,
                                            weight: FontWeight.w400,
                                            color: themeChange.getThem()
                                                ? AppThemeData.grey200
                                                : AppThemeData.grey500Dark,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 2.0, left: 38),
                                      child: CustomText(
                                        text: controller
                                            .bankDetails.value.bankName
                                            .toString(),
                                        size: 16,
                                        weight: FontWeight.w500,
                                        color: themeChange.getThem()
                                            ? AppThemeData.grey900Dark
                                            : AppThemeData.grey900,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, top: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Iconsax.building,
                                          size: 23,
                                          color: themeChange.getThem()
                                              ? AppThemeData.grey200
                                              : AppThemeData.grey500Dark,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 16),
                                          child: CustomText(
                                            text: 'Branch Name'.tr,
                                            size: 16,
                                            weight: FontWeight.w400,
                                            color: themeChange.getThem()
                                                ? AppThemeData.grey200
                                                : AppThemeData.grey500Dark,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 2.0, left: 38),
                                      child: CustomText(
                                        text: controller
                                            .bankDetails.value.branchName
                                            .toString(),
                                        size: 16,
                                        weight: FontWeight.w500,
                                        color: themeChange.getThem()
                                            ? AppThemeData.grey900Dark
                                            : AppThemeData.grey900,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, top: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Iconsax.user,
                                          size: 23,
                                          color: themeChange.getThem()
                                              ? AppThemeData.grey200
                                              : AppThemeData.grey500Dark,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 16),
                                          child: CustomText(
                                            text: 'Holder Name'.tr,
                                            size: 16,
                                            weight: FontWeight.w400,
                                            color: themeChange.getThem()
                                                ? AppThemeData.grey200
                                                : AppThemeData.grey500Dark,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 2.0, left: 38),
                                      child: CustomText(
                                        text: controller
                                            .bankDetails.value.holderName
                                            .toString(),
                                        size: 16,
                                        weight: FontWeight.w500,
                                        color: themeChange.getThem()
                                            ? AppThemeData.grey900Dark
                                            : AppThemeData.grey900,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, top: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Iconsax.card,
                                          size: 23,
                                          color: themeChange.getThem()
                                              ? AppThemeData.grey200
                                              : AppThemeData.grey500Dark,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 16),
                                          child: CustomText(
                                            text: 'Account Number'.tr,
                                            size: 16,
                                            weight: FontWeight.w400,
                                            color: themeChange.getThem()
                                                ? AppThemeData.grey200
                                                : AppThemeData.grey500Dark,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 2.0, left: 38),
                                      child: CustomText(
                                        text: controller
                                            .bankDetails.value.accountNo
                                            .toString(),
                                        size: 16,
                                        weight: FontWeight.w500,
                                        color: themeChange.getThem()
                                            ? AppThemeData.grey900Dark
                                            : AppThemeData.grey900,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, top: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Iconsax.scan_barcode,
                                          size: 23,
                                          color: themeChange.getThem()
                                              ? AppThemeData.grey200
                                              : AppThemeData.grey500Dark,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 16),
                                          child: CustomText(
                                            text: 'IFSC Code'.tr,
                                            size: 16,
                                            weight: FontWeight.w400,
                                            color: themeChange.getThem()
                                                ? AppThemeData.grey200
                                                : AppThemeData.grey500Dark,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 2.0, left: 38),
                                      child: CustomText(
                                        text: controller
                                            .bankDetails.value.ifscCode
                                            .toString(),
                                        size: 16,
                                        weight: FontWeight.w500,
                                        color: themeChange.getThem()
                                            ? AppThemeData.grey900Dark
                                            : AppThemeData.grey900,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, top: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Iconsax.clipboard_text,
                                          size: 23,
                                          color: themeChange.getThem()
                                              ? AppThemeData.grey200
                                              : AppThemeData.grey500Dark,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 16),
                                          child: CustomText(
                                            text: 'Other Information'.tr,
                                            size: 16,
                                            weight: FontWeight.w500,
                                            color: themeChange.getThem()
                                                ? AppThemeData.grey200
                                                : AppThemeData.grey500Dark,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 2.0, left: 38),
                                      child: CustomText(
                                        text: controller
                                            .bankDetails.value.otherInfo
                                            .toString(),
                                        size: 16,
                                        weight: FontWeight.w500,
                                        color: themeChange.getThem()
                                            ? AppThemeData.grey900Dark
                                            : AppThemeData.grey900,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                  padding: const EdgeInsets.only(
                                      top: 30, left: 12, right: 12),
                                  child: CustomButton(
                                    btnName: "Edit bank".tr,
                                    buttonColor: AppThemeData.primary200,
                                    textColor: Colors.white,
                                    ontap: () {
                                      showModalBottomSheet(
                                          isDismissible: true,
                                          isScrollControlled: true,
                                          context: context,
                                          backgroundColor: themeChange.getThem()
                                              ? AppThemeData.grey50Dark
                                              : AppThemeData.grey50,
                                          builder: (context) {
                                            return const AddBankAccount();
                                          });
                                    },
                                  ))

                              //  if (value != null) {
                              //       if (value == true) {
                              //         controller.getBankDetails();
                              //       }
                              //     }
                            ],
                          ),
                        ),
                      ),
          ),
        );
      },
    );
  }
}
