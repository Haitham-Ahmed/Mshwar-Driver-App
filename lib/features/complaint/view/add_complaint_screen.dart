import 'package:cabme_driver/core/constant/constant.dart';
import 'package:cabme_driver/core/constant/show_toast_dialog.dart';
import 'package:cabme_driver/features/complaint/controller/add_complaint_controller.dart';
import 'package:cabme_driver/common/widget/custom_app_bar.dart';
import 'package:cabme_driver/common/widget/button.dart';
import 'package:cabme_driver/common/widget/custom_text.dart';
import 'package:cabme_driver/common/widget/text_field.dart';
import 'package:cabme_driver/core/themes/constant_colors.dart';
import 'package:cabme_driver/core/utils/dark_theme_provider.dart';
import 'package:cabme_driver/common/widget/StarRating.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class AddComplaintScreen extends StatelessWidget {
  AddComplaintScreen({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetX<AddComplaintController>(
      init: AddComplaintController(),
      builder: (controller) {
        return Scaffold(
          appBar: CustomAppBar(
            title: "Complaint".tr,
          ),
          body: Padding(
            padding:
                const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
            child: Container(
              decoration: BoxDecoration(
                  color: themeChange.getThem()
                      ? AppThemeData.grey50Dark
                      : AppThemeData.grey50,
                  borderRadius: BorderRadius.circular(10)),
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(60),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.15),
                                blurRadius: 8,
                                spreadRadius: 6,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: CachedNetworkImage(
                              imageUrl: controller.rideData.value.photoPath
                                  .toString(),
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Constant.loader(
                                  context,
                                  isDarkMode: themeChange.getThem()),
                              errorWidget: (context, url, error) =>
                                  Image.asset("assets/icons/appLogo.png"),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: CustomText(
                          text: '${controller.rideData.value.prenom.toString()} ${controller.rideData.value.nom.toString()}',
                          color: themeChange.getThem()
                              ? AppThemeData.grey900Dark
                              : AppThemeData.grey900,
                          size: 18,
                          weight: FontWeight.w600,
                        ),
                      ),
                      if (controller.rideType.value == 'ride')
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            StarRating(
                                size: 18,
                                rating: double.parse(controller
                                    .rideData.value.moyenneDriver
                                    .toString()),
                                color: AppThemeData.warning200),
                          ],
                        ),
                      if (controller.complaintStatus.value.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomText(
                                text: 'Status : '.tr,
                                size: 16,
                                color: themeChange.getThem()
                                    ? AppThemeData.grey900Dark
                                    : AppThemeData.grey900,
                                weight: FontWeight.bold,
                              ),
                              CustomText(
                                text: controller.complaintStatus.value,
                                align: TextAlign.center,
                                color: themeChange.getThem()
                                    ? AppThemeData.grey900Dark
                                    : AppThemeData.grey900,
                                letterSpacing: 0.8,
                              ),
                            ],
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: CustomText(
                          text: controller.isReviewScreen.value == false
                              ? 'Submit a Complaint Against a Customer'.tr
                              : 'Review Customer'.tr,
                          align: TextAlign.center,
                          color: themeChange.getThem()
                              ? AppThemeData.grey900Dark
                              : AppThemeData.grey900,
                          size: 18,
                          weight: FontWeight.w600,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: CustomText(
                          text: controller.isReviewScreen.value == false
                              ? "Facing any inconvenience with a customer? File a complaint, and we'll address the issue to help improve your driving experience."
                                  .tr
                              : "Your feedback helps us improve and provide a better experience. Rate your customer and leave a comment!"
                                  .tr,
                          align: TextAlign.center,
                          color: themeChange.getThem()
                              ? AppThemeData.grey500Dark
                              : AppThemeData.grey500,
                          size: 14,
                          weight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            CustomTextField(
                              text: 'Complain Title'.tr,
                              controller: controller.complaintTitleController,
                              keyboardType: TextInputType.text,
                              prefixIcon: Icon(
                                Iconsax.message_text,
                                color: themeChange.getThem()
                                    ? AppThemeData.grey400Dark
                                    : AppThemeData.grey400,
                                size: 22,
                              ),
                              validator: (String? value) {
                                if (value!.isNotEmpty) {
                                  return null;
                                } else {
                                  return 'Title is required'.tr;
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              text: 'Description'.tr,
                              controller:
                                  controller.complaintDiscriptionController,
                              keyboardType: TextInputType.multiline,
                              maxLines: 5,
                              minLines: 5,
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
                                  return 'Description is required'.tr;
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 20),
                        child: CustomButton(
                          btnName: "Submit Complaint".tr,
                          buttonColor: AppThemeData.primary200,
                          textColor: Colors.white,
                          ontap: () async {
                            if (_formKey.currentState!.validate()) {
                              Map<String, String> bodyParams = {
                                'id_user_app': controller
                                    .rideData.value.idUserApp
                                    .toString(),
                                'id_conducteur': controller
                                    .rideData.value.idConducteur
                                    .toString(),
                                'user_type': 'driver',
                                'description': controller
                                    .complaintDiscriptionController.text
                                    .toString(),
                                'title': controller
                                    .complaintTitleController.text
                                    .toString(),
                                'order_id':
                                    controller.rideData.value.id.toString(),
                                'ride_type': 'ride'
                              };

                              await controller
                                  .addComplaint(bodyParams)
                                  .then((value) {
                                if (value != null) {
                                  if (value == true) {
                                    ShowToastDialog.showToast(
                                        "Complaint added successfully!");
                                    Get.back();
                                  } else {
                                    ShowToastDialog.showToast(
                                        "Something went wrong.");
                                  }
                                }
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
