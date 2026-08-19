import 'package:cabme_driver/core/constant/constant.dart';
import 'package:cabme_driver/core/constant/show_toast_dialog.dart';
import 'package:cabme_driver/features/review/controller/add_review_controller.dart';
import 'package:cabme_driver/core/themes/button_them.dart';
import 'package:cabme_driver/core/themes/constant_colors.dart';
import 'package:cabme_driver/common/widget/custom_app_bar.dart';
import 'package:cabme_driver/common/widget/text_field.dart';
import 'package:cabme_driver/core/themes/responsive.dart';
import 'package:cabme_driver/core/utils/dark_theme_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class AddReviewScreen extends StatelessWidget {
  const AddReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetX<AddReviewController>(
      init: AddReviewController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppThemeData.primary200,
          appBar: CustomAppBar(
            title: controller.ratingModel.value.data != null
                ? "Edit Review".tr
                : "Add review".tr,
            backgroundColor: AppThemeData.primary200,
            centerTitle: false,
            titleColor: AppThemeData.surface50,
          ),
          body: controller.isLoading.value
              ? SizedBox()
              : Padding(
                  padding: const EdgeInsets.only(
                      left: 20, right: 20, top: 20, bottom: 20),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding:
                            const EdgeInsets.only(top: 20, right: 16, left: 16),
                        child: Column(
                          children: [
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
                                    imageUrl: controller.data.value!.photoPath
                                        .toString(),
                                    height: 110,
                                    width: 110,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        Constant.loader(context,
                                            isDarkMode: themeChange.getThem()),
                                    errorWidget: (context, url, error) =>
                                        Image.asset("assets/icons/appLogo.png"),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                  '${controller.data.value!.prenom.toString()} ${controller.data.value!.nom.toString()}',
                                  style: TextStyle(
                                      color: themeChange.getThem()
                                          ? AppThemeData.grey900Dark
                                          : AppThemeData.grey900,
                                      fontFamily: AppThemeData.semiBold,
                                      fontSize: 18)),
                            ),
                            if (controller.data.value == null)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6.0),
                                child: RatingBar.builder(
                                  initialRating: double.parse(controller
                                      .data.value!.moyenne
                                      .toString()),
                                  minRating: 1,
                                  direction: Axis.horizontal,
                                  allowHalfRating: true,
                                  itemCount: 5,
                                  itemSize: 22,
                                  ignoreGestures: true,
                                  tapOnlyMode: false,
                                  updateOnDrag: false,
                                  itemBuilder: (context, _) => Icon(
                                    Icons.star,
                                    color: AppThemeData.error100,
                                  ),
                                  onRatingUpdate: (double value) {},
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.only(top: 40),
                              child: Text(
                                'Review Customer'.tr,
                                style: TextStyle(
                                  color: themeChange.getThem()
                                      ? AppThemeData.grey900Dark
                                      : AppThemeData.grey900,
                                  fontSize: 18,
                                  fontFamily: AppThemeData.semiBold,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Your feedback helps us improve and provide a better experience. Rate your customer and leave a comment!'
                                    .tr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: themeChange.getThem()
                                      ? AppThemeData.grey900Dark
                                      : AppThemeData.grey900,
                                  fontSize: 14,
                                  fontFamily: AppThemeData.regular,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  color: themeChange.getThem()
                                      ? AppThemeData.surface50Dark
                                      : AppThemeData.surface50,
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10)),
                                  border: Border.all(
                                      color: (themeChange.getThem()
                                          ? AppThemeData.grey200Dark
                                          : AppThemeData.grey200))),
                              width: Responsive.width(100, context),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              child: Center(
                                child: RatingBar.builder(
                                  initialRating: controller.rating.value,
                                  minRating: 1,
                                  direction: Axis.horizontal,
                                  allowHalfRating: true,
                                  itemCount: 5,
                                  itemSize: 32,
                                  itemPadding: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
                                  itemBuilder: (context, _) => Icon(
                                    Icons.star,
                                    color: AppThemeData.primary200,
                                  ),
                                  onRatingUpdate: (rating) {
                                    controller.rating(rating);
                                  },
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: CustomTextField(
                                text: 'Leave a comment'.tr,
                                controller:
                                    controller.reviewCommentController.value,
                                keyboardType: TextInputType.multiline,
                                maxLines: 3,
                                minLines: 3,
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
                                    return 'required'.tr;
                                  }
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 20, left: 20, right: 20, bottom: 20),
                              child: ButtonThem.buildButton(context,
                                  btnHeight: 45,
                                  title: "Submit review".tr,
                                  btnColor: AppThemeData.primary200,
                                  txtColor: Colors.black, onPress: () async {
                                Map<String, String> bodyParams = {
                                  'ride_id':
                                      controller.data.value!.id.toString(),
                                  'id_user_app': controller
                                      .data.value!.idUserApp
                                      .toString(),
                                  'id_conducteur': controller
                                      .data.value!.idConducteur
                                      .toString(),
                                  'note_value':
                                      controller.rating.value.toString(),
                                  'comment': controller
                                      .reviewCommentController.value.text,
                                };

                                await controller
                                    .addReview(bodyParams)
                                    .then((value) {
                                  if (value != null) {
                                    if (value == true) {
                                      ShowToastDialog.showToast(
                                          "Review added successfully!");
                                      Get.back();
                                    } else {
                                      ShowToastDialog.showToast(
                                          "Something went wrong");
                                    }
                                  }
                                });
                              }),
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
