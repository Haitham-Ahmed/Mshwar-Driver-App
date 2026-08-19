import 'package:cabme_driver/common/widget/custom_text.dart';
import 'package:cabme_driver/core/constant/constant.dart';
import 'package:cabme_driver/features/wallet/controller/withdrawals_controller.dart';
import 'package:cabme_driver/core/themes/constant_colors.dart';
import 'package:cabme_driver/core/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class WithdrawalsScreen extends StatelessWidget {
  const WithdrawalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDarkMode = themeChange.getThem();
    return GetX<WithdrawalsController>(
      init: WithdrawalsController(),
      builder: (controller) {
        return Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => controller.getWithdrawals(),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: controller.isLoading.value
                      ? SizedBox()
                      : controller.rideList.isEmpty
                          ? Constant.emptyView(
                              "Your don't have any Withdrawals request",
                              context)
                          : ListView.builder(
                              itemCount: controller.rideList.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isDarkMode
                                          ? AppThemeData.grey800Dark
                                          : AppThemeData.surface50,
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isDarkMode
                                            ? AppThemeData.grey200Dark
                                            : AppThemeData.grey200,
                                        width: 1,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Image.asset(
                                            'assets/icons/walltet_icons.png',
                                            width: 52,
                                            height: 52,
                                          ),
                                          Expanded(
                                              child: Padding(
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: CustomText(
                                                        text: controller
                                                            .rideList[index]
                                                            .creer
                                                            .toString(),
                                                        size: 16,
                                                        weight: FontWeight.w600,
                                                        color: isDarkMode
                                                            ? AppThemeData
                                                                .grey900Dark
                                                            : AppThemeData
                                                                .grey900,
                                                      ),
                                                    ),
                                                    CustomText(
                                                      text: Constant()
                                                          .amountShow(
                                                              amount: controller
                                                                  .rideList[
                                                                      index]
                                                                  .amount
                                                                  .toString()),
                                                      size: 16,
                                                      weight: FontWeight.w700,
                                                      color: controller
                                                                  .rideList[
                                                                      index]
                                                                  .statut
                                                                  .toString() ==
                                                              "success"
                                                          ? AppThemeData
                                                              .success300
                                                          : AppThemeData
                                                              .error50,
                                                    ),
                                                  ],
                                                ),
                                                CustomText(
                                                  text: controller
                                                      .rideList[index].statut
                                                      .toString(),
                                                  size: 16,
                                                  weight: FontWeight.w700,
                                                  color: controller
                                                              .rideList[index]
                                                              .statut
                                                              .toString() ==
                                                          "success"
                                                      ? AppThemeData.success300
                                                      : AppThemeData.error50,
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 8.0),
                                                  child: Divider(
                                                    color: isDarkMode
                                                        ? AppThemeData
                                                            .grey200Dark
                                                            .withOpacity(0.3)
                                                        : AppThemeData.grey200,
                                                    thickness: 1,
                                                  ),
                                                ),
                                                CustomText(
                                                  text: controller
                                                      .rideList[index].bankName
                                                      .toString(),
                                                  size: 16,
                                                  weight: FontWeight.w600,
                                                  color: isDarkMode
                                                      ? AppThemeData.grey900Dark
                                                      : AppThemeData.grey900,
                                                ),
                                                const SizedBox(
                                                  height: 4,
                                                ),
                                                CustomText(
                                                  text: controller
                                                      .rideList[index].accountNo
                                                      .toString(),
                                                  size: 16,
                                                  weight: FontWeight.w500,
                                                  color: isDarkMode
                                                      ? AppThemeData.grey400Dark
                                                      : AppThemeData.grey400,
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 8.0),
                                                  child: Divider(
                                                    color: isDarkMode
                                                        ? AppThemeData
                                                            .grey200Dark
                                                            .withOpacity(0.3)
                                                        : AppThemeData.grey200,
                                                    thickness: 1,
                                                  ),
                                                ),
                                                CustomText(
                                                  text: "Note".tr,
                                                  size: 16,
                                                  weight: FontWeight.w600,
                                                  color: isDarkMode
                                                      ? AppThemeData.grey900Dark
                                                      : AppThemeData.grey900,
                                                ),
                                                const SizedBox(
                                                  height: 4,
                                                ),
                                                CustomText(
                                                  text: controller
                                                      .rideList[index].note
                                                      .toString(),
                                                  size: 16,
                                                  weight: FontWeight.w500,
                                                  color: isDarkMode
                                                      ? AppThemeData.grey400Dark
                                                      : AppThemeData.grey400,
                                                ),
                                              ],
                                            ),
                                          )),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
