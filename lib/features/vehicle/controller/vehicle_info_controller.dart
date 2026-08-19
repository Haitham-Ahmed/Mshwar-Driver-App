import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cabme_driver/core/constant/constant.dart';
import 'package:cabme_driver/core/constant/logdata.dart';
import 'package:cabme_driver/core/constant/show_toast_dialog.dart';
import 'package:cabme_driver/features/vehicle/model/brand_model.dart';
import 'package:cabme_driver/features/vehicle/model/get_vehicle_data_model.dart'
    as prefix;
import 'package:cabme_driver/features/vehicle/model/get_vehicle_getegory.dart';
import 'package:cabme_driver/features/ride/model/model.dart';
import 'package:cabme_driver/features/authentication/model/user_model.dart';
import 'package:cabme_driver/features/vehicle/model/vehicle_register_model.dart';
import 'package:cabme_driver/features/vehicle/model/zone_model.dart';
import 'package:cabme_driver/service/api.dart';
import 'package:cabme_driver/core/utils/Preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class VehicleInfoController extends GetxController {
  Rx<TextEditingController> brandController = TextEditingController().obs;
  Rx<TextEditingController> modelController = TextEditingController().obs;
  Rx<TextEditingController> colorController = TextEditingController().obs;
  Rx<TextEditingController> carMakeController = TextEditingController().obs;
  Rx<TextEditingController> millageController = TextEditingController().obs;
  Rx<TextEditingController> kmDrivenController = TextEditingController().obs;
  Rx<TextEditingController> numberPlateController = TextEditingController().obs;
  Rx<TextEditingController> numberOfPassengersController =
      TextEditingController().obs;
  Rx<TextEditingController> zoneNameController = TextEditingController().obs;

  UserModel? userModel;

  RxList selectedZone = <int>[].obs;
  RxList<ZoneData> zoneList = <ZoneData>[].obs;

  @override
  void onInit() {
    getUserdata();
    // getVehicleDataAPI();
    getVehicleDataAPI();
    super.onInit();
  }

  RxBool isLoading = true.obs;

  getUserdata() async {
    userModel = Constant.getUserData();
  }

  /// Vehicle profile API
  Future<dynamic> getVehicleDataAPI() async {
    try {
      ShowToastDialog.showLoader("Please wait");
      final response = await http.get(
          Uri.parse(API.getVehicleData(
              Preferences.getInt(Preferences.userId).toString())),
          headers: API.header);

      showLog(
          "API :: URL :: ${API.getVehicleData(Preferences.getInt(Preferences.userId).toString())} ");
      showLog("API :: Request Header :: ${API.header.toString()} ");
      showLog("API :: responseStatus :: ${response.statusCode} ");
      showLog("API :: responseBody :: ${response.body} ");
      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200 && responseBody['success'] == "success") {
        await getVehicleData(prefix.GetVehicleDataModel.fromJson(responseBody));
        await getVehicleCategory();
        await getZone();
        await getBrand();
        Map<String, String> bodyParams = {
          'brand': brandController.value.text,
          'vehicle_type': selectedCategoryID.value,
        };
        ShowToastDialog.closeLoader();
        getModel(bodyParams);
        isLoading.value = false;
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "Failed") {
        await getVehicleCategory();
        await getZone();
        ShowToastDialog.closeLoader();
        isLoading.value = false;
      } else {
        isLoading.value = false;
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(
            'Something want wrong. Please try again later');
        throw Exception('Failed to load album');
      }
    } on TimeoutException catch (e) {
      isLoading.value = false;
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      isLoading.value = false;
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      isLoading.value = false;
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }

  getVehicleData(prefix.GetVehicleDataModel getVehicleDataModel) async {
    final prefix.VehicleData vehicleData = getVehicleDataModel.vehicleData!;
    selectedBrandID.value = vehicleData.brand!;
    selectedModelID.value = vehicleData.model!;
    colorController.value.text = vehicleData.color!;
    carMakeController.value.text = vehicleData.carMake!;
    numberPlateController.value.text = vehicleData.numberplate!;
    numberOfPassengersController.value.text = vehicleData.passenger!;
    kmDrivenController.value.text = vehicleData.km!;
    millageController.value.text = vehicleData.milage!;
    selectedCategoryID.value = vehicleData.idTypeVehicule!.toString();

    // Safely parse zone_id list
    if (vehicleData.zone_id != null && vehicleData.zone_id!.isNotEmpty) {
      for (var element in vehicleData.zone_id!) {
        var parsed = int.tryParse(element.toString().trim());
        if (parsed != null) {
          selectedZone.add(parsed);
        }
      }
    }
  }

  RxString selectedCategoryID = "".obs;
  RxString selectedBrandID = "".obs;
  RxString selectedModelID = "".obs;

  List<VehicleData> vehicleCategoryList = [];

  Future<VehicleRegisterModel?> vehicleRegister(
      Map<String, String> bodyParams) async {
    try {
      ShowToastDialog.showLoader("Please wait");
      final response = await http.post(Uri.parse(API.vehicleRegister),
          headers: API.header, body: jsonEncode(bodyParams));
      showLog("API :: URL :: ${API.vehicleRegister} ");
      showLog("API :: Request Body :: ${jsonEncode(bodyParams)} ");
      showLog("API :: Request Header :: ${API.header.toString()} ");
      showLog("API :: responseStatus :: ${response.statusCode} ");
      showLog("API :: responseBody :: ${response.body} ");

      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        ShowToastDialog.closeLoader();
        return VehicleRegisterModel.fromJson(responseBody);
      } else {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(
            'Something want wrong. Please try again later');
        throw Exception('Failed to load album');
      }
    } on TimeoutException catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
      log(e.toString());
    }
    ShowToastDialog.closeLoader();
    return null;
  }

  Future<VehicleData?> getVehicleCategory() async {
    try {
      ShowToastDialog.showLoader("Please wait");
      final response = await http.get(
        Uri.parse(API.vehicleCategory),
        headers: API.header,
      );
      showLog("API :: URL :: ${API.vehicleRegister} ");
      showLog("API :: Request Header :: ${API.header.toString()} ");
      showLog("API :: responseStatus :: ${response.statusCode} ");
      showLog("API :: responseBody :: ${response.body} ");
      Map<String, dynamic> responseBody = json.decode(response.body);
      isLoading.value = false;
      print("====>$responseBody");
      if (response.statusCode == 200) {
        final VehicleCategoryModel getVehicleCategory =
            VehicleCategoryModel.fromJson(responseBody);

        vehicleCategoryList = getVehicleCategory.vehicleData!;

        update();
        ShowToastDialog.closeLoader();
        return VehicleData.fromJson(responseBody);
      } else {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(
            'Something want wrong. Please try again later');
      }
    } on TimeoutException catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
      log(e.toString());
    }
    ShowToastDialog.closeLoader();
    return null;
  }

  Future<List<BrandData>?> getBrand() async {
    try {
      ShowToastDialog.showLoader("Please wait");
      final response =
          await http.get(Uri.parse(API.brand), headers: API.header);
      showLog("API :: URL :: ${API.brand} ");
      showLog("API :: Request Header :: ${API.header.toString()} ");
      showLog("API :: responseStatus :: ${response.statusCode} ");
      showLog("API :: responseBody :: ${response.body} ");
      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200 && responseBody['success'] == "success") {
        ShowToastDialog.closeLoader();
        BrandModel model = BrandModel.fromJson(responseBody);
        for (int i = 0; i < model.data!.length; i++) {
          if (selectedBrandID.value.toString() ==
              model.data![i].id.toString()) {
            brandController.value.text = model.data![i].name.toString();
          }
        }
        return model.data!;
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "Failed") {
        ShowToastDialog.closeLoader();
      } else {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(
            'Something want wrong. Please try again later');
      }
    } on TimeoutException catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }

  Future<List<ZoneData>?> getZone() async {
    try {
      ShowToastDialog.showLoader("Please wait");
      final response =
          await http.get(Uri.parse(API.getZone), headers: API.authheader);
      showLog("API :: URL :: ${API.getZone} ");
      showLog("API :: Request Header :: ${API.header.toString()} ");
      showLog("API :: responseStatus :: ${response.statusCode} ");
      showLog("API :: responseBody :: ${response.body} ");
      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200 && responseBody['success'] == "success") {
        ShowToastDialog.closeLoader();
        ZoneModel model = ZoneModel.fromJson(responseBody);

        // Safely update zone name controller for selected zones
        if (model.data != null && model.data!.isNotEmpty) {
          zoneNameController.value.text = "";
          for (var element in selectedZone) {
            var matchingZone = model.data!.where((p0) => p0.id == element);
            if (matchingZone.isNotEmpty) {
              zoneNameController.value.text =
                  "${zoneNameController.value.text}${zoneNameController.value.text.isEmpty ? "" : ","} ${matchingZone.first.name}";
            }
          }
          zoneList.value = model.data!;
          return model.data;
        } else {
          return [];
        }
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "Failed") {
        ShowToastDialog.closeLoader();
      } else {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(
            'Something want wrong. Please try again later');
        throw Exception('Failed to load album');
      }
    } on TimeoutException catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }

  Future<List<ModelData>?> getModel(bodyParams) async {
    try {
      ShowToastDialog.showLoader("Please wait");
      final response = await http.post(Uri.parse(API.model),
          headers: API.header, body: jsonEncode(bodyParams));
      showLog("API :: URL :: ${API.model} ");
      showLog("API :: Request Body :: ${jsonEncode(bodyParams)} ");
      showLog("API :: Request Header :: ${API.header.toString()} ");
      showLog("API :: responseStatus :: ${response.statusCode} ");
      showLog("API :: responseBody :: ${response.body} ");
      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200 && responseBody['success'] == "success") {
        ShowToastDialog.closeLoader();
        Model model = Model.fromJson(responseBody);
        for (int i = 0; i < model.data!.length; i++) {
          if (selectedModelID.value.toString() ==
              model.data![i].id.toString()) {
            modelController.value.text = model.data![i].name.toString();
          }
        }
        return model.data!;
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "Failed") {
        ShowToastDialog.showToast(responseBody['error']);
        ShowToastDialog.closeLoader();
      } else {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(
            'Something want wrong. Please try again later');
        throw Exception('Failed to load album');
      }
    } on TimeoutException catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    brandController.value.clear();
    modelController.value.clear();
    colorController.value.clear();
    carMakeController.value.clear();
    millageController.value.clear();
    kmDrivenController.value.clear();
    numberPlateController.value.clear();
    numberOfPassengersController.value.clear();
    zoneNameController.value.clear();
    selectedCategoryID.value = "";
    selectedBrandID.value = "";
    selectedModelID.value = "";

    super.dispose();
  }
}
