import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import 'package:cabme_driver/core/constant/logdata.dart';
import 'package:cabme_driver/core/constant/show_toast_dialog.dart';
import 'package:cabme_driver/features/commission/model/commission_model.dart';
import 'package:cabme_driver/features/profile/model/driver_model.dart';
import 'package:cabme_driver/features/authentication/model/user_model.dart';
import 'package:cabme_driver/service/api.dart';
import 'package:cabme_driver/core/utils/Preferences.dart';

class CommissionController extends GetxController {
  @override
  void onInit() {
    callback();
    super.onInit();
  }

  Future<void> callback() async {
    try {
      ShowToastDialog.showLoader("Please wait");

      // await getCurrentLocation();
      // await getVehicleCategory();
      // await getDriverDetails(
      //     vehicleData.value.id?.toString() ?? '',
      //     currentLocation?.latitude.toString() ?? "",
      //     currentLocation?.longitude.toString() ?? '');
      userdata = UserData.fromJson(
          jsonDecode(Preferences.getString(Preferences.user))['data']);
      getCommission();
    } catch (e) {
      print(e);
    } finally {
      ShowToastDialog.closeLoader();
    }
  }

  UserData? userdata;
  DriverModel? driverModel;

  Future<DriverModel?> getDriverDetails(
      String typeVehicle, String lat1, String lng1) async {
    try {
      // ShowToastDialog.showLoader("Please wait");
      final response = await http.get(
          Uri.parse(
              "${API.driverDetails}?type_vehicle=$typeVehicle&lat1=$lat1&lng1=$lng1"),
          headers: API.header);
      showLog(
          "API :: URL :: ${API.driverDetails}?type_vehicle=$typeVehicle&lat1=$lat1&lng1=$lng1");
      showLog("API :: Request Header :: ${API.header.toString()} ");
      showLog("API :: responseStatus :: ${response.statusCode} ");
      showLog("API :: responseBody :: ${response.body} ");

      Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        // ShowToastDialog.closeLoader();
        driverModel = DriverModel.fromJson(responseBody);
      } else {
        // ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(
            'Something want wrong. Please try again later');
        throw Exception('Failed to load album');
      }
    } on TimeoutException catch (e) {
      // ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      // ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      // ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      // ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }

  LatLng? currentLocation;

  // Future<void> getCurrentLocation() async {
  //   bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     ShowToastDialog.showToast(
  //         'Location services are disabled. Please enable them to continue.');
  //     return;
  //   }

  //   // Check location permission
  //   LocationPermission permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       print("Location permission is denied");
  //       return;
  //     }
  //   }

  //   if (permission == LocationPermission.deniedForever) {
  //     ShowToastDialog.showToast(
  //         'Location permissions are permanently denied. Please enable them in settings.');
  //     return;
  //   }

  //   Position position = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: locationData.LocationAccuracy.high,
  //       timeLimit: const Duration(seconds: 10));
  //   // Get current location

  //   currentLocation =
  //       LatLng(position.latitude ?? 0.0, position.longitude ?? 0.0);
  // }

  // Rx<VehicleCategoryModel> vehicleCategoryModel = VehicleCategoryModel().obs;
  // Rx<VehicleData> vehicleData = VehicleData().obs;

  // Future<VehicleCategoryModel?> getVehicleCategory() async {
  //   try {
  //     // ShowToastDialog.showLoader("Please wait");

  //     update();
  //     final response = await http.get(Uri.parse(API.getVehicleCategory),
  //         headers: API.header);
  //     showLog("API :: URL :: '${API.getVehicleCategory}");
  //     showLog("API :: Request Header :: ${API.header.toString()} ");
  //     showLog("API :: responseStatus :: ${response.statusCode} ");
  //     showLog("API :: responseBody ::YY ${response.body} ");
  //     Map<String, dynamic> responseBody = json.decode(response.body);
  //     if (response.statusCode == 200) {
  //       vehicleCategoryModel.value =
  //           VehicleCategoryModel.fromJson(responseBody);
  //       vehicleData =
  //           vehicleCategoryModel.value.data?.first.obs ?? VehicleData().obs;
  //       update();
  //       // return VehicleCategoryModel.fromJson(responseBody);
  //     } else {
  //       // ShowToastDialog.closeLoader();
  //       if (responseBody['data']['message'] == 'Unauthorized') {
  //         ShowToastDialog.showToast(responseBody['data']['message'].toString());
  //         update();
  //       }
  //       ShowToastDialog.showToast(
  //           'Something want wrong. Please try again later');
  //       update();
  //       throw Exception('Failed to load album');
  //     }
  //   } on TimeoutException catch (e) {
  //     // ShowToastDialog.closeLoader();

  //     ShowToastDialog.showToast(e.message.toString());
  //     update();
  //   } on SocketException catch (e) {
  //     // ShowToastDialog.closeLoader();

  //     ShowToastDialog.showToast(e.message.toString());
  //     update();
  //   } on Error catch (e) {
  //     // ShowToastDialog.closeLoader();

  //     ShowToastDialog.showToast(e.toString());
  //     update();
  //   } catch (e) {
  //     // ShowToastDialog.closeLoader();

  //     ShowToastDialog.showToast(e.toString());
  //     update();
  //   }
  //   return null;
  // }

  CommissionModel? commissionModel;
  Future<void> getCommission() async {
    try {
      final headers = Map<String, String>.from(API.header);
      headers.remove('content-type'); // lowercase key
      headers.remove('Content-Type'); // just in case it's capitalized
      headers['Content-Type'] =
          'application/x-www-form-urlencoded'; // ✅ correct type for form data
      // UserData userdata = UserData.fromJson(
      //     jsonDecode(Preferences.getString(Preferences.user))['data']);
      final response = await http
          .get(Uri.parse(API.getCommissionUrl(driverId: userdata?.id)));

      // UserData? userData = value.userData;
      showLog("API :: URL :: ${API.getCommissionUrl(driverId: userdata?.id)}");
      showLog("API :: Request Header :: ${API.header.toString()} ");
      showLog("API :: responseStatus :: ${response.statusCode}");
      showLog("API :: responseBody :: ${response.body}");

      // packages = dt.map((e) => PackagesModel.fromJson(e)).toList();

      if (response.statusCode == 200) {
        commissionModel = CommissionModel.fromJson(jsonDecode(response.body));
        update();
        ShowToastDialog.closeLoader();
      } else if (response.statusCode == 500) {
        ShowToastDialog.closeLoader();
        showLog(response.body.toString());
      } else {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(
            'Something went wrong. Please try again later');
        throw Exception('Failed to load data');
      }
    } on TimeoutException catch (e) {
      ShowToastDialog.closeLoader();
      showLog(e.toString());
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      ShowToastDialog.closeLoader();
      showLog(e.toString());
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      ShowToastDialog.closeLoader();
      showLog(e.toString());
      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      ShowToastDialog.closeLoader();
      showLog(e.toString());
      ShowToastDialog.showToast(e.toString());
    }
    return;
  }
}
