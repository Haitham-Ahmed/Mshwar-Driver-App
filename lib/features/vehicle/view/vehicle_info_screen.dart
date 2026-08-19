import 'dart:developer';

import 'package:cabme_driver/core/constant/show_toast_dialog.dart';
import 'package:cabme_driver/features/vehicle/controller/vehicle_info_controller.dart';
import 'package:cabme_driver/features/vehicle/model/brand_model.dart';
import 'package:cabme_driver/features/ride/model/model.dart';
import 'package:cabme_driver/features/authentication/view/waiting_approval_screen.dart';
import 'package:cabme_driver/common/widget/custom_app_bar.dart';
import 'package:cabme_driver/common/widget/custom_text.dart';
import 'package:cabme_driver/common/widget/text_field.dart';
import 'package:cabme_driver/core/themes/button_them.dart';
import 'package:cabme_driver/core/themes/constant_colors.dart';
import 'package:cabme_driver/core/themes/responsive.dart';
import 'package:cabme_driver/core/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class VehicleInfoScreen extends StatelessWidget {
  const VehicleInfoScreen({super.key});

  static final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: VehicleInfoController(),
        builder: (vehicleInfoController) {
          return Scaffold(
            appBar: CustomAppBar(
              title: "Enter Vehicle Information".tr,
            ),
            backgroundColor: themeChange.getThem()
                ? AppThemeData.surface50Dark
                : AppThemeData.surface50,
            body: vehicleInfoController.isLoading.value
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          CustomText(
                            text:
                                "Accurate information helps match you with the right ride requests and ensures a smooth driving experience."
                                    .tr,
                            size: 14,
                            weight: FontWeight.w400,
                            align: TextAlign.start,
                          ),
                          const SizedBox(height: 24),
                          Container(
                            decoration: BoxDecoration(
                              color: themeChange.getThem()
                                  ? AppThemeData.grey800Dark
                                  : AppThemeData.surface50,
                              border: Border.all(
                                color: themeChange.getThem()
                                    ? AppThemeData.grey200Dark
                                    : AppThemeData.grey200,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(16),
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
                                children: [
                                  // Vehicle Type Selection - Simple dropdown style
                                  if (vehicleInfoController
                                      .vehicleCategoryList.isNotEmpty)
                                    Wrap(
                                      spacing: 12,
                                      runSpacing: 8,
                                      alignment: WrapAlignment.center,
                                      children: vehicleInfoController
                                          .vehicleCategoryList
                                          .map((category) {
                                        final isSelected = vehicleInfoController
                                                .selectedCategoryID.value ==
                                            category.id.toString();
                                        return GestureDetector(
                                          onTap: () {
                                            vehicleInfoController
                                                .selectedCategoryID
                                                .value = category.id.toString();
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 10),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? AppThemeData.primary200
                                                  : (themeChange.getThem()
                                                      ? AppThemeData.grey800Dark
                                                      : AppThemeData.grey100),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: isSelected
                                                    ? AppThemeData.primary200
                                                    : Colors.transparent,
                                                width: 1,
                                              ),
                                            ),
                                            child: CustomText(
                                              text: category.libelle.toString(),
                                              size: 14,
                                              weight: FontWeight.w500,
                                              color: isSelected
                                                  ? Colors.white
                                                  : (themeChange.getThem()
                                                      ? AppThemeData.grey300Dark
                                                      : AppThemeData.grey500),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  const SizedBox(height: 16),
                                  Form(
                                    key: _formKey,
                                    autovalidateMode: AutovalidateMode.disabled,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  vehicleInfoController
                                                      .getBrand()
                                                      .then((value) {
                                                    if (value != null &&
                                                        value.isNotEmpty) {
                                                      brandDialog(
                                                          context,
                                                          value,
                                                          vehicleInfoController);
                                                    } else {
                                                      ShowToastDialog.showToast(
                                                          "Please contact administrator");
                                                    }
                                                  });
                                                },
                                                child: AbsorbPointer(
                                                  child: CustomTextField(
                                                    text: 'Brand'.tr,
                                                    controller:
                                                        vehicleInfoController
                                                            .brandController
                                                            .value,
                                                    keyboardType:
                                                        TextInputType.text,
                                                    prefixIcon: Icon(
                                                      Iconsax.car,
                                                      color:
                                                          themeChange.getThem()
                                                              ? AppThemeData
                                                                  .grey400Dark
                                                              : AppThemeData
                                                                  .grey400,
                                                      size: 22,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  if (vehicleInfoController
                                                      .selectedCategoryID
                                                      .value
                                                      .isNotEmpty) {
                                                    if (vehicleInfoController
                                                        .brandController
                                                        .value
                                                        .text
                                                        .isNotEmpty) {
                                                      Map<String, String>
                                                          bodyParams = {
                                                        'brand':
                                                            vehicleInfoController
                                                                .brandController
                                                                .value
                                                                .text,
                                                        'vehicle_type':
                                                            vehicleInfoController
                                                                .selectedCategoryID
                                                                .value,
                                                      };
                                                      vehicleInfoController
                                                          .getModel(bodyParams)
                                                          .then((value) {
                                                        if (value != null &&
                                                            value.isNotEmpty) {
                                                          modelDialog(
                                                              context,
                                                              value,
                                                              vehicleInfoController);
                                                        } else {
                                                          ShowToastDialog.showToast(
                                                              "Car Model not Found.");
                                                        }
                                                      });
                                                    } else {
                                                      ShowToastDialog.showToast(
                                                          "Please select brand");
                                                    }
                                                  } else {
                                                    ShowToastDialog.showToast(
                                                        'Please select Vehicle Type');
                                                  }
                                                },
                                                child: AbsorbPointer(
                                                  child: CustomTextField(
                                                    text: 'Model'.tr,
                                                    controller:
                                                        vehicleInfoController
                                                            .modelController
                                                            .value,
                                                    keyboardType:
                                                        TextInputType.text,
                                                    readOnly: true,
                                                    prefixIcon: Icon(
                                                      Iconsax.car,
                                                      color:
                                                          themeChange.getThem()
                                                              ? AppThemeData
                                                                  .grey400Dark
                                                              : AppThemeData
                                                                  .grey400,
                                                      size: 22,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        GestureDetector(
                                          onTap: () {
                                            vehicleInfoController
                                                .getZone()
                                                .then((value) {
                                              if (value != null &&
                                                  value.isNotEmpty) {
                                                vehicleInfoController
                                                    .zoneList.value = value;
                                                zoneDialog(context,
                                                    vehicleInfoController);
                                              } else {
                                                ShowToastDialog.showToast(
                                                    "No zones available. Please contact administrator.");
                                              }
                                            });
                                          },
                                          child: AbsorbPointer(
                                            child: CustomTextField(
                                              text: 'Select Zone'.tr,
                                              controller: vehicleInfoController
                                                  .zoneNameController.value,
                                              keyboardType: TextInputType.text,
                                              readOnly: true,
                                              prefixIcon: Icon(
                                                Iconsax.location,
                                                color: themeChange.getThem()
                                                    ? AppThemeData.grey400Dark
                                                    : AppThemeData.grey400,
                                                size: 22,
                                              ),
                                              suffixIcon: Icon(
                                                Iconsax.arrow_down_1,
                                                color: themeChange.getThem()
                                                    ? AppThemeData.grey400Dark
                                                    : AppThemeData.grey400,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        CustomTextField(
                                          text: 'Color'.tr,
                                          controller: vehicleInfoController
                                              .colorController.value,
                                          keyboardType: TextInputType.text,
                                          maxWords: 20,
                                          prefixIcon: Icon(
                                            Iconsax.paintbucket,
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
                                        Row(
                                          children: [
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        title: CustomText(
                                                          text:
                                                              "Select Year".tr,
                                                          size: 18,
                                                          weight:
                                                              FontWeight.w600,
                                                        ),
                                                        content: SizedBox(
                                                          // Need to use container to add size constraint.
                                                          width: 300,
                                                          height: 300,
                                                          child: YearPicker(
                                                            firstDate: DateTime(
                                                                DateTime.now()
                                                                        .year -
                                                                    30,
                                                                1),
                                                            lastDate: DateTime(
                                                                DateTime.now()
                                                                    .year,
                                                                1),
                                                            initialDate: DateTime(
                                                                DateTime.now()
                                                                    .year,
                                                                1),
                                                            selectedDate:
                                                                DateTime(
                                                                    DateTime.now()
                                                                        .year,
                                                                    1),
                                                            onChanged: (DateTime
                                                                dateTime) {
                                                              // close the dialog when year is selected.
                                                              vehicleInfoController
                                                                      .carMakeController
                                                                      .value
                                                                      .text =
                                                                  dateTime.year
                                                                      .toString();
                                                              Get.back();
                                                            },
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                                child: AbsorbPointer(
                                                  child: CustomTextField(
                                                    text:
                                                        'Car Registration year'
                                                            .tr,
                                                    controller:
                                                        vehicleInfoController
                                                            .carMakeController
                                                            .value,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    maxWords: 40,
                                                    readOnly: true,
                                                    prefixIcon: Icon(
                                                      Iconsax.calendar,
                                                      color:
                                                          themeChange.getThem()
                                                              ? AppThemeData
                                                                  .grey400Dark
                                                              : AppThemeData
                                                                  .grey400,
                                                      size: 22,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: CustomTextField(
                                                text: 'Number Plate'.tr,
                                                controller:
                                                    vehicleInfoController
                                                        .numberPlateController
                                                        .value,
                                                keyboardType:
                                                    TextInputType.text,
                                                maxWords: 40,
                                                prefixIcon: Icon(
                                                  Iconsax.document_text,
                                                  color: themeChange.getThem()
                                                      ? AppThemeData.grey400Dark
                                                      : AppThemeData.grey400,
                                                  size: 22,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: CustomTextField(
                                                text: 'Millage'.tr,
                                                controller:
                                                    vehicleInfoController
                                                        .millageController
                                                        .value,
                                                keyboardType:
                                                    TextInputType.number,
                                                maxWords: 40,
                                                prefixIcon: Icon(
                                                  Iconsax.speedometer,
                                                  color: themeChange.getThem()
                                                      ? AppThemeData.grey400Dark
                                                      : AppThemeData.grey400,
                                                  size: 22,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: CustomTextField(
                                                text: 'KM Driven'.tr,
                                                controller:
                                                    vehicleInfoController
                                                        .kmDrivenController
                                                        .value,
                                                keyboardType:
                                                    TextInputType.number,
                                                maxWords: 40,
                                                prefixIcon: Icon(
                                                  Iconsax.routing,
                                                  color: themeChange.getThem()
                                                      ? AppThemeData.grey400Dark
                                                      : AppThemeData.grey400,
                                                  size: 22,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        CustomTextField(
                                          text: 'Number Of Passengers'.tr,
                                          controller: vehicleInfoController
                                              .numberOfPassengersController
                                              .value,
                                          keyboardType: TextInputType.number,
                                          maxWords: 40,
                                          prefixIcon: Icon(
                                            Iconsax.people,
                                            color: themeChange.getThem()
                                                ? AppThemeData.grey400Dark
                                                : AppThemeData.grey400,
                                            size: 22,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: ButtonThem.buildButton(
                              context,
                              title: 'Continue'.tr,
                              btnHeight: 50,
                              btnWidthRatio: 1,
                              btnColor: AppThemeData.primary200,
                              txtColor: AppThemeData.surface50,
                              onPress: () async {
                                if (_formKey.currentState!.validate()) {
                                  if (vehicleInfoController
                                      .selectedCategoryID.value.isEmpty) {
                                    ShowToastDialog.showToast(
                                        "Please select vehicle type");
                                  } else if (vehicleInfoController
                                      .selectedBrandID.value.isEmpty) {
                                    ShowToastDialog.showToast(
                                        "Please select vehicle brand");
                                  } else if (vehicleInfoController
                                      .selectedModelID.value.isEmpty) {
                                    ShowToastDialog.showToast(
                                        "Please select vehicle model");
                                  } else if (vehicleInfoController
                                      .zoneList.isEmpty) {
                                    ShowToastDialog.showToast(
                                        "Please select Zone");
                                  } else if (vehicleInfoController
                                      .numberPlateController
                                      .value
                                      .text
                                      .isEmpty) {
                                    ShowToastDialog.showToast(
                                        "Please enter number plate");
                                  } else if (vehicleInfoController
                                      .millageController.value.text.isEmpty) {
                                    ShowToastDialog.showToast(
                                        "Please enter millage");
                                  } else if (vehicleInfoController
                                      .kmDrivenController.value.text.isEmpty) {
                                    ShowToastDialog.showToast(
                                        "Please enter Kilometer driven");
                                  } else if (vehicleInfoController
                                      .numberOfPassengersController
                                      .value
                                      .text
                                      .isEmpty) {
                                    ShowToastDialog.showToast(
                                        "Please enter number of passenger");
                                  } else {
                                    ShowToastDialog.showLoader("Please wait");
                                    Map<String, String> bodyParams1 = {
                                      "brand": vehicleInfoController
                                          .selectedBrandID.value,
                                      "model": vehicleInfoController
                                          .selectedModelID.value,
                                      "color": vehicleInfoController
                                          .colorController.value.text,
                                      "carregistration": vehicleInfoController
                                          .numberPlateController.value.text
                                          .toUpperCase(),
                                      "passenger": vehicleInfoController
                                          .numberOfPassengersController
                                          .value
                                          .text,
                                      "id_driver": vehicleInfoController
                                          .userModel!.userData!.id
                                          .toString(),
                                      "id_categorie_vehicle":
                                          vehicleInfoController
                                              .selectedCategoryID.value,
                                      "car_make": vehicleInfoController
                                          .carMakeController.value.text,
                                      "milage": vehicleInfoController
                                          .millageController.value.text,
                                      "km_driven": vehicleInfoController
                                          .kmDrivenController.value.text,
                                      "zone_id": vehicleInfoController
                                          .selectedZone
                                          .join(",")
                                    };
                                    log(bodyParams1.toString());
                                    await vehicleInfoController
                                        .vehicleRegister(bodyParams1)
                                        .then((value) {
                                      if (value != null) {
                                        if (value.success == "Success" ||
                                            value.success == "success") {
                                          ShowToastDialog.closeLoader();
                                          // Redirect to waiting approval screen after vehicle registration
                                          Get.offAll(() =>
                                              const WaitingApprovalScreen());
                                          ShowToastDialog.showToast(
                                              "Vehicle Information save successfully");
                                        } else {
                                          ShowToastDialog.closeLoader();
                                          ShowToastDialog.showToast(
                                              value.error);
                                        }
                                      }
                                    });
                                  }
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          );
        });
  }

  brandDialog(BuildContext context, List<BrandData>? brandList,
      VehicleInfoController vehicleInfoController) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: CustomText(
              text: 'Brand list'.tr,
              size: 18,
              weight: FontWeight.w600,
            ),
            content: SizedBox(
              height: 300.0, // Change as per your requirement
              width: 300.0, // Change as per your requirement
              child: brandList!.isEmpty
                  ? Container()
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: brandList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: InkWell(
                              onTap: () {
                                vehicleInfoController.brandController.value
                                    .text = brandList[index].name.toString();
                                vehicleInfoController.selectedBrandID.value =
                                    brandList[index].id.toString();
                                Get.back();
                              },
                              child: CustomText(
                                text: brandList[index].name.toString(),
                                size: 16,
                                weight: FontWeight.w400,
                              )),
                        );
                      },
                    ),
            ),
          );
        });
  }

  modelDialog(BuildContext context, List<ModelData>? brandList,
      VehicleInfoController vehicleInfoController) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: CustomText(
              text: 'Model list'.tr,
              size: 18,
              weight: FontWeight.w600,
            ),
            content: SizedBox(
              height: 300.0, // Change as per your requirement
              width: 300.0, // Change as per your requirement
              child: brandList!.isEmpty
                  ? Container()
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: brandList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: InkWell(
                              onTap: () {
                                vehicleInfoController.modelController.value
                                    .text = brandList[index].name.toString();
                                vehicleInfoController.selectedModelID.value =
                                    brandList[index].id.toString();

                                Get.back();
                              },
                              child: CustomText(
                                text: brandList[index].name.toString(),
                                size: 16,
                                weight: FontWeight.w400,
                              )),
                        );
                      },
                    ),
            ),
          );
        });
  }

  zoneDialog(
      BuildContext context, VehicleInfoController vehicleInfoController) {
    Widget cancelButton = TextButton(
      child: CustomText(
        text: "Cancel".tr,
        size: 16,
        weight: FontWeight.w500,
        color: AppThemeData.primary200,
      ),
      onPressed: () {
        Get.back();
      },
    );
    Widget continueButton = TextButton(
      child: CustomText(
        text: "Continue".tr,
        size: 16,
        weight: FontWeight.w500,
      ),
      onPressed: () {
        if (vehicleInfoController.selectedZone.isEmpty) {
          ShowToastDialog.showToast("Please select zone");
        } else {
          String nameValue = "";
          for (var element in vehicleInfoController.selectedZone) {
            nameValue =
                "$nameValue${nameValue.isEmpty ? "" : ","} ${vehicleInfoController.zoneList.where((p0) => p0.id == element).first.name}";
          }
          vehicleInfoController.zoneNameController.value.text = nameValue;
          Get.back();
        }
      },
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: CustomText(
              text: 'Zone list'.tr,
              size: 18,
              weight: FontWeight.w600,
            ),
            content: SizedBox(
              width: Responsive.width(
                  90, context), // Change as per your requirement
              child: vehicleInfoController.zoneList.isEmpty
                  ? Container()
                  : Obx(
                      () => ListView.builder(
                        shrinkWrap: true,
                        itemCount: vehicleInfoController.zoneList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Obx(
                            () => CheckboxListTile(
                              value: vehicleInfoController.selectedZone
                                  .contains(
                                      vehicleInfoController.zoneList[index].id),
                              onChanged: (value) {
                                if (vehicleInfoController.selectedZone.contains(
                                    vehicleInfoController.zoneList[index].id)) {
                                  vehicleInfoController.selectedZone.remove(
                                      vehicleInfoController
                                          .zoneList[index].id); // unselect
                                } else {
                                  vehicleInfoController.selectedZone.add(
                                      vehicleInfoController
                                          .zoneList[index].id); // select
                                }
                              },
                              title: CustomText(
                                text: vehicleInfoController.zoneList[index].name
                                    .toString(),
                                size: 16,
                                weight: FontWeight.w400,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
            actions: [
              cancelButton,
              continueButton,
            ],
          );
        });
  }
}
