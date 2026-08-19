import 'package:cabme_driver/core/constant/constant.dart';
import 'package:cabme_driver/core/constant/show_toast_dialog.dart';
import 'package:cabme_driver/features/document/controller/document_status_contoller.dart';
import 'package:cabme_driver/common/widget/custom_app_bar.dart';
import 'package:cabme_driver/common/widget/custom_text.dart';
import 'package:cabme_driver/core/themes/button_them.dart';
import 'package:cabme_driver/core/themes/constant_colors.dart';
import 'package:cabme_driver/core/themes/custom_alert_dialog.dart';
import 'package:cabme_driver/core/themes/responsive.dart';
import 'package:cabme_driver/core/utils/dark_theme_provider.dart';
import 'package:cabme_driver/features/vehicle/view/vehicle_info_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class DocumentStatusScreen extends StatelessWidget {
  DocumentStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetX<DocumentStatusController>(
      init: DocumentStatusController(),
      builder: (controller) {
        return Scaffold(
          appBar: CustomAppBar(
            title: "Upload Your Documents".tr,
          ),
          backgroundColor: themeChange.getThem()
              ? AppThemeData.surface50Dark
              : AppThemeData.surface50,
          body: controller.isLoading.value
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          CustomText(
                            text:
                                "Securely upload your driving license, vehicle registration, and insurance documents."
                                    .tr,
                            size: 14,
                            weight: FontWeight.w400,
                            align: TextAlign.start,
                          ),
                          const SizedBox(height: 24),
                          Expanded(
                            child: RefreshIndicator(
                              onRefresh: () => controller.getCarServiceBooks(),
                              child: ListView.builder(
                                itemCount: controller.documentList.length,
                                shrinkWrap: true,
                                padding: const EdgeInsets.only(bottom: 100),
                                itemBuilder: (context, index) {
                                  final document =
                                      controller.documentList[index];
                                  final status =
                                      document.documentStatus.toString();
                                  final isApproved = status == "Approved";
                                  final isDisapproved = status == "Disapprove";
                                  final isPending = status == "Pending";

                                  Color statusColor;
                                  Color statusBgColor;
                                  if (isApproved) {
                                    statusColor = AppThemeData.success300;
                                    statusBgColor = AppThemeData.success50;
                                  } else if (isDisapproved || isPending) {
                                    statusColor = AppThemeData.error50;
                                    statusBgColor = AppThemeData.error200;
                                  } else {
                                    statusColor = AppThemeData.grey400;
                                    statusBgColor = AppThemeData.grey100;
                                  }

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                      color: themeChange.getThem()
                                          ? AppThemeData.grey800Dark
                                          : AppThemeData.surface50,
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
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: CustomText(
                                                  text: document.documentName
                                                      .toString(),
                                                  size: 18,
                                                  weight: FontWeight.w600,
                                                  color: themeChange.getThem()
                                                      ? AppThemeData.grey900Dark
                                                      : AppThemeData.grey900,
                                                ),
                                              ),
                                              if (isDisapproved)
                                                InkWell(
                                                  onTap: () {
                                                    showDialog(
                                                      barrierColor:
                                                          Colors.black26,
                                                      context: context,
                                                      builder: (context) {
                                                        return CustomAlertDialog(
                                                          title:
                                                              "${"Reason :".tr} ${document.comment!.isEmpty ? "Under Verification".tr : document.comment.toString()}",
                                                          negativeButtonText:
                                                              'Ok'.tr,
                                                          positiveButtonText:
                                                              'Ok'.tr,
                                                          onPressPositive: () {
                                                            Get.back();
                                                          },
                                                        );
                                                      },
                                                    );
                                                  },
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: themeChange
                                                              .getThem()
                                                          ? AppThemeData
                                                              .grey200Dark
                                                              .withOpacity(0.3)
                                                          : AppThemeData
                                                              .grey100,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    child: Icon(
                                                      Icons.visibility_outlined,
                                                      size: 20,
                                                      color:
                                                          themeChange.getThem()
                                                              ? AppThemeData
                                                                  .grey900Dark
                                                              : AppThemeData
                                                                  .grey900,
                                                    ),
                                                  ),
                                                ),
                                              if (isDisapproved)
                                                const SizedBox(width: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 6,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: statusBgColor,
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: CustomText(
                                                  text: status.tr,
                                                  size: 12,
                                                  weight: FontWeight.w600,
                                                  color: statusColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          document.documentPath!.isEmpty
                                              ? Container(
                                                  decoration: BoxDecoration(
                                                    color: themeChange.getThem()
                                                        ? AppThemeData
                                                            .grey800Dark
                                                        : AppThemeData.grey50,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    border: Border.all(
                                                      color:
                                                          themeChange.getThem()
                                                              ? AppThemeData
                                                                  .grey200Dark
                                                              : AppThemeData
                                                                  .grey200,
                                                      width: 1.5,
                                                      style: BorderStyle.solid,
                                                    ),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      vertical: 32,
                                                      horizontal: 24,
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(16),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: AppThemeData
                                                                .primary200
                                                                .withOpacity(
                                                                    0.1),
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          child: Icon(
                                                            Iconsax
                                                                .document_upload,
                                                            size: 32,
                                                            color: AppThemeData
                                                                .primary200,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 16),
                                                        CustomText(
                                                          text:
                                                              "${"Upload".tr} ${document.title} ${"Image".tr}",
                                                          size: 16,
                                                          weight:
                                                              FontWeight.w600,
                                                          color: themeChange
                                                                  .getThem()
                                                              ? AppThemeData
                                                                  .grey900Dark
                                                              : AppThemeData
                                                                  .grey900,
                                                          align:
                                                              TextAlign.center,
                                                        ),
                                                        const SizedBox(
                                                            height: 8),
                                                        CustomText(
                                                          text:
                                                              "${"Take a clear picture of your".tr} ${document.title} ${"or choose an image from your gallery to ensure document verify.".tr}",
                                                          size: 12,
                                                          weight:
                                                              FontWeight.w400,
                                                          color: themeChange
                                                                  .getThem()
                                                              ? AppThemeData
                                                                  .grey400Dark
                                                              : AppThemeData
                                                                  .grey400,
                                                          align:
                                                              TextAlign.center,
                                                          maxLines: 3,
                                                        ),
                                                        const SizedBox(
                                                            height: 24),
                                                        ButtonThem.buildButton(
                                                          context,
                                                          title:
                                                              'Click to Upload'
                                                                  .tr,
                                                          btnWidthRatio: 0.50,
                                                          btnHeight: 44,
                                                          btnColor: AppThemeData
                                                              .primary200,
                                                          txtColor: AppThemeData
                                                              .surface50,
                                                          onPress: () async {
                                                            buildBottomSheet(
                                                              context,
                                                              controller,
                                                              index,
                                                              document.id
                                                                  .toString(),
                                                              themeChange
                                                                  .getThem(),
                                                            );
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              : Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    border: Border.all(
                                                      color:
                                                          themeChange.getThem()
                                                              ? AppThemeData
                                                                  .grey200Dark
                                                              : AppThemeData
                                                                  .grey200,
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    child: Stack(
                                                      children: [
                                                        CachedNetworkImage(
                                                          height:
                                                              Responsive.height(
                                                                  25, context),
                                                          width:
                                                              double.infinity,
                                                          fit: BoxFit.cover,
                                                          imageUrl: document
                                                              .documentPath!,
                                                          placeholder:
                                                              (context, url) =>
                                                                  Container(
                                                            height: Responsive
                                                                .height(25,
                                                                    context),
                                                            color: themeChange
                                                                    .getThem()
                                                                ? AppThemeData
                                                                    .grey800Dark
                                                                : AppThemeData
                                                                    .grey100,
                                                            child: Center(
                                                              child: Constant
                                                                  .loader(
                                                                context,
                                                                isDarkMode:
                                                                    themeChange
                                                                        .getThem(),
                                                              ),
                                                            ),
                                                          ),
                                                          errorWidget: (context,
                                                                  url, error) =>
                                                              Container(
                                                            height: Responsive
                                                                .height(25,
                                                                    context),
                                                            color: themeChange
                                                                    .getThem()
                                                                ? AppThemeData
                                                                    .grey800Dark
                                                                : AppThemeData
                                                                    .grey100,
                                                            child: Icon(
                                                              Icons
                                                                  .error_outline,
                                                              color: themeChange.getThem()
                                                                  ? AppThemeData
                                                                      .grey400Dark
                                                                  : AppThemeData
                                                                      .grey400,
                                                            ),
                                                          ),
                                                        ),
                                                        if (isApproved)
                                                          Positioned(
                                                            top: 8,
                                                            right: 8,
                                                            child: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                horizontal: 10,
                                                                vertical: 6,
                                                              ),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: AppThemeData
                                                                    .success300,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20),
                                                              ),
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  const Icon(
                                                                    Icons
                                                                        .check_circle,
                                                                    size: 16,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  const SizedBox(
                                                                      width: 4),
                                                                  CustomText(
                                                                    text:
                                                                        "Approved"
                                                                            .tr,
                                                                    size: 12,
                                                                    weight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                          if (isDisapproved) ...[
                                            const SizedBox(height: 16),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                ButtonThem.buildButton(
                                                  context,
                                                  title: 'Upload'.tr,
                                                  btnHeight: 40,
                                                  btnWidthRatio: 0.35,
                                                  btnColor:
                                                      AppThemeData.primary200,
                                                  txtColor:
                                                      AppThemeData.surface50,
                                                  onPress: () async {
                                                    buildBottomSheet(
                                                      context,
                                                      controller,
                                                      index,
                                                      document.id.toString(),
                                                      themeChange.getThem(),
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Next button - show when at least one document is uploaded, positioned at bottom
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Obx(() {
                        final hasUploadedDocument = controller.documentList.any(
                          (doc) =>
                              doc.documentPath != null &&
                              doc.documentPath!.isNotEmpty,
                        );

                        if (!hasUploadedDocument) {
                          return const SizedBox.shrink();
                        }

                        return Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 16),
                          decoration: BoxDecoration(
                            color: themeChange.getThem()
                                ? AppThemeData.surface50Dark
                                : AppThemeData.surface50,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, -2),
                              ),
                            ],
                          ),
                          child: SafeArea(
                            child: ButtonThem.buildButton(
                              context,
                              title: 'Next'.tr,
                              btnHeight: 50,
                              btnWidthRatio: 1.0,
                              btnColor: AppThemeData.primary200,
                              txtColor: AppThemeData.surface50,
                              onPress: () {
                                Get.to(() => const VehicleInfoScreen());
                              },
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
        );
      },
    );
  }

  buildBottomSheet(BuildContext context, DocumentStatusController controller,
      int index, String documentId, bool isDarkMode) {
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
                        text: 'Please Select'.tr,
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
                              onTap: () => pickFile(
                                controller,
                                source: ImageSource.camera,
                                index: index,
                                documentId: documentId,
                              ),
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
                                        color: AppThemeData.primary200
                                            .withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.camera_alt,
                                        size: 32,
                                        color: AppThemeData.primary200,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    CustomText(
                                      text: 'camera'.tr,
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
                              onTap: () => pickFile(
                                controller,
                                source: ImageSource.gallery,
                                index: index,
                                documentId: documentId,
                              ),
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
                                        color: AppThemeData.primary200
                                            .withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.photo_library_sharp,
                                        size: 32,
                                        color: AppThemeData.primary200,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    CustomText(
                                      text: 'gallery'.tr,
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

  final ImagePicker _imagePicker = ImagePicker();

  Future pickFile(DocumentStatusController controller,
      {required ImageSource source,
      required int index,
      required String documentId}) async {
    try {
      XFile? image = await _imagePicker.pickImage(source: source);
      if (image == null) return;

      controller.updateDocument(documentId, image.path).then((value) {
        controller.isLoading.value = true;
        controller.getCarServiceBooks();
      });
      Get.back();
    } on PlatformException catch (e) {
      ShowToastDialog.showToast("${"Failed to Pick".tr}: \n $e");
    }
  }

  buildAlertSendInformation(
    BuildContext context,
  ) {
    return Get.defaultDialog(
      radius: 6,
      title: "",
      titleStyle: const TextStyle(fontSize: 0.0),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                "assets/images/green_checked.png",
                height: 100,
                width: 100,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: CustomText(
                text:
                    "${"Your information send well. We will treat them and inform you after the treatment.".tr} ${"Your account will be active after validation of your information.".tr}",
                align: TextAlign.center,
                size: 14,
                weight: FontWeight.w400,
                color: AppThemeData.grey400,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ButtonThem.buildButton(context,
                title: "Close".tr,
                btnHeight: 40,
                btnWidthRatio: 0.6,
                btnColor: AppThemeData.primary200,
                txtColor: Colors.white,
                onPress: () => Get.back()),
          ],
        ),
      ),
    );
  }
}
