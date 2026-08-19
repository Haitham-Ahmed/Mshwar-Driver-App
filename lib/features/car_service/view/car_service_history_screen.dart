import 'package:cabme_driver/features/car_service/controller/car_service_history_controller.dart';
import 'package:cabme_driver/features/car_service/model/car_service_book_model.dart';
import 'package:cabme_driver/features/car_service/view/show_service_doc_screen.dart';
import 'package:cabme_driver/features/car_service/view/upload_car_service_book.dart';
import 'package:cabme_driver/common/widget/custom_app_bar.dart';
import 'package:cabme_driver/common/widget/custom_text.dart';
import 'package:cabme_driver/common/widget/button.dart';
import 'package:cabme_driver/core/themes/constant_colors.dart';
import 'package:cabme_driver/core/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class CarServiceBookHistory extends StatelessWidget {
  const CarServiceBookHistory({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<CarServiceHistoryController>(
        init: CarServiceHistoryController(),
        builder: (controller) {
          return RefreshIndicator(
            onRefresh: () => controller.getCarServiceBooks(),
            child: Scaffold(
              appBar: CustomAppBar(title: 'Car Service'.tr),
              backgroundColor: themeChange.getThem()
                  ? AppThemeData.surface50Dark
                  : AppThemeData.surface50,
              body: controller.isLoading.value
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : controller.serviceList.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.history_outlined,
                                  size: 80,
                                  color: themeChange.getThem()
                                      ? AppThemeData.grey400Dark
                                      : AppThemeData.grey400,
                                ),
                                const SizedBox(height: 24),
                                CustomText(
                                  text:
                                      'No car service history not available'.tr,
                                  size: 16,
                                  weight: FontWeight.w500,
                                  color: themeChange.getThem()
                                      ? AppThemeData.grey400Dark
                                      : AppThemeData.grey400,
                                  align: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: controller.serviceList.length,
                          itemBuilder: (context, index) {
                            return showServiceBookDetails(
                                serviceData: controller.serviceList[index],
                                isDarkMode: themeChange.getThem());
                          }),
              bottomNavigationBar: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CustomButton(
                    btnName: 'Add Service History'.tr,
                    icon: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                    ontap: () {
                      controller.carServiceBook.value = '';
                      controller.kmDrivenController.value.text = '';
                      Get.to(() => const AddCarServiceBookHistory());
                    },
                  ),
                ),
              ),
            ),
          );
        });
  }

  showServiceBookDetails(
      {required ServiceData serviceData, required bool isDarkMode}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: GestureDetector(
        onTap: () => Get.to(() => ShowServiceDocScreen(
              serviceData: serviceData,
            )),
        child: Container(
          decoration: BoxDecoration(
            color:
                isDarkMode ? AppThemeData.grey800Dark : AppThemeData.surface50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  isDarkMode ? AppThemeData.grey200Dark : AppThemeData.grey200,
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppThemeData.success300.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Iconsax.calendar,
                            size: 20,
                            color: AppThemeData.success300,
                          ),
                        ),
                        const SizedBox(width: 12),
                        CustomText(
                          text: serviceData.modifier.toString(),
                          size: 16,
                          weight: FontWeight.w600,
                          color: isDarkMode
                              ? AppThemeData.grey900Dark
                              : AppThemeData.grey900,
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppThemeData.primary200.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Iconsax.speedometer,
                            size: 16,
                            color: AppThemeData.primary200,
                          ),
                          const SizedBox(width: 6),
                          CustomText(
                            text: "${serviceData.km.toString()} KM".tr,
                            size: 14,
                            weight: FontWeight.w600,
                            color: AppThemeData.primary200,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomText(
                        text: serviceData.fileName.toString(),
                        size: 14,
                        weight: FontWeight.w500,
                        color: AppThemeData.new200,
                        decoration: TextDecoration.underline,
                        decorationColor: AppThemeData.new200,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
