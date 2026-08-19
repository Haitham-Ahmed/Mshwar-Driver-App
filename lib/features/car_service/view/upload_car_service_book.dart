import 'dart:io';
import 'package:cabme_driver/core/constant/show_toast_dialog.dart';
import 'package:cabme_driver/features/car_service/controller/car_service_history_controller.dart';
import 'package:cabme_driver/common/widget/custom_app_bar.dart';
import 'package:cabme_driver/common/widget/custom_text.dart';
import 'package:cabme_driver/common/widget/button.dart';
import 'package:cabme_driver/common/widget/text_field.dart';
import 'package:cabme_driver/core/themes/constant_colors.dart';
import 'package:cabme_driver/core/utils/dark_theme_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class AddCarServiceBookHistory extends StatelessWidget {
  const AddCarServiceBookHistory({super.key});

  static final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<CarServiceHistoryController>(
      init: CarServiceHistoryController(),
      builder: (controller) {
        return Scaffold(
          appBar: CustomAppBar(title: 'Upload Car Service Book'.tr),
          backgroundColor: themeChange.getThem()
              ? AppThemeData.surface50Dark
              : AppThemeData.surface50,
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  controller.carServiceBook.isNotEmpty
                      ? Obx(
                          () => Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
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
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: SizedBox(
                                height: 400,
                                child: SfPdfViewerTheme(
                                  data: SfPdfViewerThemeData(
                                    progressBarColor: AppThemeData.primary200,
                                    backgroundColor: themeChange.getThem()
                                        ? AppThemeData.surface50Dark
                                        : AppThemeData.surface50,
                                  ),
                                  child: SfPdfViewer.file(
                                    File(controller.carServiceBook.value),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 40,
                            horizontal: 24,
                          ),
                          decoration: BoxDecoration(
                            color: themeChange.getThem()
                                ? AppThemeData.grey800Dark
                                : AppThemeData.surface50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: themeChange.getThem()
                                  ? AppThemeData.grey200Dark
                                  : AppThemeData.grey200,
                              width: 1.5,
                              style: BorderStyle.solid,
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
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color:
                                      AppThemeData.primary200.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Iconsax.document_upload,
                                  size: 40,
                                  color: AppThemeData.primary200,
                                ),
                              ),
                              const SizedBox(height: 24),
                              CustomText(
                                text: 'Upload File'.tr,
                                size: 18,
                                weight: FontWeight.w600,
                                color: themeChange.getThem()
                                    ? AppThemeData.grey900Dark
                                    : AppThemeData.grey900,
                                align: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              CustomText(
                                text:
                                    'Take a clear picture of your file or choose an pdf from your gallery to ensure service details.'
                                        .tr,
                                align: TextAlign.center,
                                size: 13,
                                weight: FontWeight.w400,
                                color: themeChange.getThem()
                                    ? AppThemeData.grey400Dark
                                    : AppThemeData.grey400,
                                maxLines: 3,
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: themeChange.getThem()
                                      ? AppThemeData.grey800Dark
                                      : AppThemeData.grey50,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: CustomText(
                                  text: 'Max. 5MB, Accepted: pdf'.tr,
                                  size: 12,
                                  weight: FontWeight.w500,
                                  color: themeChange.getThem()
                                      ? AppThemeData.grey400Dark
                                      : AppThemeData.grey400,
                                ),
                              ),
                              const SizedBox(height: 32),
                              CustomButton(
                                btnName: 'Click to Upload'.tr,
                                ontap: () async {
                                  pickDoc(controller);
                                },
                              ),
                            ],
                          ),
                        ),
                  const SizedBox(height: 24),
                  CustomText(
                    text: 'ADD KM'.tr,
                    size: 16,
                    weight: FontWeight.w600,
                    color: themeChange.getThem()
                        ? AppThemeData.grey900Dark
                        : AppThemeData.grey900,
                  ),
                  const SizedBox(height: 12),
                  Form(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    key: _formKey,
                    child: CustomTextField(
                      text: 'ADD KM'.tr,
                      controller: controller.kmDrivenController.value,
                      keyboardType: TextInputType.number,
                      maxWords: 10,
                      prefixIcon: Icon(
                        Iconsax.speedometer,
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
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CustomButton(
                btnName: 'Save Details'.tr,
                ontap: () {
                  if (controller.carServiceBook.isNotEmpty &&
                      _formKey.currentState!.validate()) {
                    controller
                        .userCarServiceBook(
                            kmDriven: controller.kmDrivenController.value.text)
                        .then((value) {
                      if (value != null) {
                        if (value["success"] == "Success") {
                          controller.getCarServiceBooks();
                          Get.back();
                        } else {
                          ShowToastDialog.showToast(value['error']);
                        }
                      }
                    });
                  } else {
                    if (controller.carServiceBook.isEmpty) {
                      ShowToastDialog.showToast("Please Choose Image");
                    }
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }

  pickDoc(
    CarServiceHistoryController controller,
  ) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc'],
        allowMultiple: false,
      );
      if (result!.files.isEmpty) return;
      PlatformFile file = result.files.last;
      controller.carServiceBook.value = file.path!;
    } on PlatformException catch (e) {
      ShowToastDialog.showToast("${"Failed to Pick".tr}: \n $e");
    }
  }
}
