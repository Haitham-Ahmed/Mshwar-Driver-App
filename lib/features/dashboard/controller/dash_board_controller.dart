import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cabme_driver/core/constant/constant.dart';
import 'package:cabme_driver/core/constant/logdata.dart';
import 'package:cabme_driver/core/constant/show_toast_dialog.dart';
import 'package:cabme_driver/features/ride/model/driver_location_update.dart';
import 'package:cabme_driver/features/authentication/model/user_model.dart';
import 'package:cabme_driver/features/bank/view/show_bank_details.dart';
import 'package:cabme_driver/features/authentication/view/login_screen.dart';
import 'package:cabme_driver/features/vehicle/view/vehicle_info_screen.dart';
import 'package:cabme_driver/features/vehicle/model/get_vehicle_data_model.dart';
import 'package:cabme_driver/features/vehicle/model/zone_model.dart';
import 'package:cabme_driver/features/car_service/view/car_service_history_screen.dart';
import 'package:cabme_driver/features/commission/view/commission_page.dart';
import 'package:cabme_driver/features/dashboard/view/dash_board.dart';
import 'package:cabme_driver/features/document/view/document_status_screen.dart';
import 'package:cabme_driver/features/localization/view/localization_screen.dart';
import 'package:cabme_driver/features/profile/view/my_profile_screen.dart';
import 'package:cabme_driver/features/privacy_policy/view/privacy_policy_screen.dart';
import 'package:cabme_driver/features/terms_service/view/terms_of_service_screen.dart';
import 'package:cabme_driver/features/wallet/view/wallet_screen.dart';
import 'package:cabme_driver/service/api.dart';
import 'package:cabme_driver/core/utils/Preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_review/in_app_review.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';

class DashBoardController extends GetxController {
  static const MethodChannel _locationServiceChannel =
      MethodChannel('com.mshwar.appdriver/location_service');
  Location location = Location();
  StreamSubscription<LocationData>? locationSubscription;
  Timer? _locationHeartbeat;
  LocationData? _lastLocation;
  bool _locationPublishInFlight = false;

  // Zone-related variables
  RxList<ZoneData> driverZones = <ZoneData>[].obs;
  RxString driverZoneNames = "".obs;
  RxBool isZoneLoading = false.obs;

  @override
  void onInit() {
    getUsrData();
    getCurrentLocation();
    updateToken();
    updateCurrentLocation();
    getPaymentSettingData();
    getDriverZoneInfo(); // Fetch zone info on init

    super.onInit();
  }

  @override
  void onClose() {
    _locationHeartbeat?.cancel();
    locationSubscription?.cancel();
    super.onClose();
  }

  updateToken() async {
    try {
      // For iOS, wait for APNS token before getting FCM token
      if (Platform.isIOS) {
        try {
          String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
          if (apnsToken == null) {
            // Retry getting APNS token with a delay
            await Future.delayed(const Duration(seconds: 2));
            apnsToken = await FirebaseMessaging.instance.getAPNSToken();
          }
          if (apnsToken != null) {
            log('✅ APNS token obtained: $apnsToken');
          } else {
            log('⚠️ APNS token still not available, but proceeding...');
          }
        } catch (e) {
          log('⚠️ Error getting APNS token: $e');
        }
      }

      // Get FCM token
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        log('✅ FCM Token retrieved: $token');
        updateFCMToken(token);
      } else {
        log('⚠️ FCM Token is null');
      }
    } catch (e) {
      log('❌ Error getting FCM token: $e');
      // Don't throw - allow the app to continue even if token retrieval fails
    }
  }

  getCurrentLocation() async {
    LocationData location = await Location().getLocation();
    List<geocoding.Placemark> placeMarks =
        await geocoding.placemarkFromCoordinates(
            location.latitude ?? 0.0, location.longitude ?? 0.0);
    for (var i = 0; i < Constant.allTaxList.length; i++) {
      if (placeMarks.first.country.toString().toUpperCase() ==
          Constant.allTaxList[i].country!.toUpperCase()) {
        Constant.taxList.add(Constant.allTaxList[i]);
      }
    }
    print(Constant.taxList.length);
    setCurrentLocation(
        location.latitude.toString(), location.longitude.toString());
  }

  getDrawerItem() {
    drawerItems.clear();
    drawerItems.addAll([
      DrawerItem('All Rides'.tr, 'assets/icons/ic_car.svg',
          section: "Rides:".tr),
      DrawerItem('Documents'.tr, 'assets/icons/ic_car.svg',
          section: 'Vehicle & Service Management:'.tr),
      DrawerItem(
          'Vehicle information'.tr, 'assets/icons/ic_parcel_vehicle.svg'),
      DrawerItem('Car Service History'.tr, 'assets/icons/ic_all_car.svg'),
      DrawerItem('Commission'.tr, 'assets/icons/ic_all_car.svg'),
      DrawerItem('My Profile'.tr, 'assets/icons/ic_profile.svg',
          section: 'Account & Financials:'.tr),
      DrawerItem('My Earnings'.tr, 'assets/icons/ic_wallet.svg'),
      DrawerItem('Add Bank'.tr, 'assets/icons/ic_bank.svg'),
      DrawerItem('Change Language'.tr, 'assets/icons/ic_lang.svg',
          section: 'Settings & Support:'.tr),
      DrawerItem('Terms of Service'.tr, 'assets/icons/ic_terms.svg'),
      DrawerItem('Privacy Policy'.tr, 'assets/icons/ic_privacy.svg'),
      DrawerItem('Dark Mode'.tr, 'assets/icons/ic_dark.svg', isSwitch: true),
      DrawerItem('Rate the App'.tr, 'assets/icons/ic_star_line.svg',
          section: 'Feedback & Support'.tr),
      DrawerItem('Log Out'.tr, 'assets/icons/ic_logout.svg'),
    ]);
  }

  getDrawerItemWidget(int pos) {
    if (pos == 1) {
      Get.to(DocumentStatusScreen());
    } else if (pos == 2) {
      Get.to(const VehicleInfoScreen());
    } else if (pos == 3) {
      Get.to(const CarServiceBookHistory());
    } else if (pos == 4) {
      Get.to(const CommissionPage());
    } else if (pos == 5) {
      Get.to(() => MyProfileScreen());
    } else if (pos == 6) {
      Get.to(WalletScreen());
    } else if (pos == 7) {
      Get.to(const ShowBankDetails());
    } else if (pos == 8) {
      Get.to(const LocalizationScreens(intentType: "dashBoard"));
    } else if (pos == 9) {
      Get.to(const TermsOfServiceScreen());
    } else if (pos == 10) {
      Get.to(const PrivacyPolicyScreen());
    }
  }

  Rx<UserModel> userModel = UserModel().obs;

  getUsrData() async {
    userModel.value = Constant.getUserData();
    isActive.value = userModel.value.userData?.online == "yes";
    try {
      Map<String, String> bodyParams = {
        'phone': userModel.value.userData!.phone.toString(),
        'user_cat': "driver",
        'email': userModel.value.userData!.email.toString(),
        'login_type': userModel.value.userData!.loginType.toString(),
      };
      final response = await http.post(Uri.parse(API.getProfileByPhone),
          headers: API.header, body: jsonEncode(bodyParams));
      showLog("API :: URL :: ${API.getProfileByPhone} ");
      showLog("API :: Request Body :: ${jsonEncode(bodyParams)} ");
      showLog("API :: Request Header :: ${API.header.toString()} ");
      showLog("API :: responseStatus :: ${response.statusCode} ");
      showLog("API :: responseBody :: ${response.body} ");
      Map<String, dynamic> responseBodyPhone = json.decode(response.body);
      if (response.statusCode == 200 &&
          responseBodyPhone['success'] == "success") {
        print(
            "userModel.value.userData!.online :: ${response.body.toString()}");
        ShowToastDialog.closeLoader();
        UserModel? value = UserModel.fromJson(responseBodyPhone);
        Preferences.setString(Preferences.user, jsonEncode(value));
        userModel.value = value;
        isActive.value =
            userModel.value.userData!.online == "yes" ? true : false;
      }
    } catch (e) {
      rethrow;
    }
    getDrawerItem();
  }

  RxBool isActive = true.obs;
  RxInt selectedDrawerIndex = 0.obs;
  var drawerItems = [].obs;
  final InAppReview inAppReview = InAppReview.instance;
  onSelectItem(int index) async {
    Get.back();
    log("INDEX :: $index");

    // Get the last item index (logout)
    final lastIndex = drawerItems.length - 1;
    final isLogout = index == lastIndex;

    if (isLogout) {
      await _stopNativeLocationService();
      // Clear all preferences and navigate to login
      Preferences.clearKeyData(Preferences.isLogin);
      Preferences.clearKeyData(Preferences.user);
      Preferences.clearKeyData(Preferences.userId);
      Preferences.clearKeyData(Preferences.accesstoken);
      // Clear API header
      API.header['accesstoken'] = '';
      // Cancel location subscription
      try {
        _locationHeartbeat?.cancel();
        await locationSubscription?.cancel();
      } catch (e) {
        log('Error canceling location subscription: $e');
      }
      Get.offAll(const LoginScreen());
      return;
    }

    if (index == 12) {
      try {
        if (await inAppReview.isAvailable()) {
          inAppReview.requestReview();
        } else {
          inAppReview.openStoreListing();
        }
      } catch (e) {
        log("Error triggering in-app review: $e");
      }
    } else {
      getDrawerItemWidget(index);
    }
  }

  // Helper method to determine driver status
  // Note: Backend will also determine status based on active rides
  String _getDriverStatus() {
    if (!isActive.value) {
      return 'offline';
    }
    // Default to online - backend will update based on ride status
    return 'online';
  }

  updateCurrentLocation() async {
    _locationHeartbeat?.cancel();
    await locationSubscription?.cancel();

    if (isActive.value) {
      PermissionStatus permissionStatus = await location.hasPermission();
      if (permissionStatus == PermissionStatus.granted) {
        if (Platform.isAndroid) {
          await _startNativeLocationService();
          return;
        }
        try {
          await location.enableBackgroundMode(enable: true);
        } catch (e) {
          log('⚠️ Background location permission not granted: $e');
          // Continue without background mode if permission is denied
        }
        location.changeSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter:
                double.parse(Constant.driverLocationUpdateUnit.toString()));
        _startLocationPublishing();
      } else {
        location.requestPermission().then((permissionStatus) async {
          if (permissionStatus == PermissionStatus.granted) {
            if (Platform.isAndroid) {
              await _startNativeLocationService();
              return;
            }
            try {
              location.enableBackgroundMode(enable: true);
            } catch (e) {
              log('⚠️ Background location permission not granted: $e');
              // Continue without background mode if permission is denied
            }
            location.changeSettings(
                accuracy: LocationAccuracy.high,
                distanceFilter:
                    double.parse(Constant.driverLocationUpdateUnit.toString()));
            _startLocationPublishing();
          }
        });
      }
    } else {
      if (Platform.isAndroid) {
        await _stopNativeLocationService();
      }
      try {
        await location.enableBackgroundMode(enable: false);
      } catch (e) {
        log('⚠️ Unable to disable background location mode: $e');
      }
      DriverLocationUpdate driverLocationUpdate = DriverLocationUpdate(
          rotation: "0",
          active: false,
          driverId: Preferences.getInt(Preferences.userId).toString(),
          driverLatitude: "0",
          driverLongitude: "0",
          status: 'offline');
      try {
        await Constant.driverLocationUpdate
            .doc(Preferences.getInt(Preferences.userId).toString())
            .set(driverLocationUpdate.toJson());
      } catch (e) {
        log('⚠️ Firestore write failed (permission denied or network issue): $e');
        // Continue without Firestore - offline status is still set
      }
    }
  }

  Future<void> _startNativeLocationService() async {
    try {
      await _locationServiceChannel.invokeMethod('start', {
        'driverId': Preferences.getInt(Preferences.userId),
        'accessToken': Preferences.getString(Preferences.accesstoken),
        'apiKey': API.apiKey,
      });
      log('✅ Native foreground location service started');
    } on PlatformException catch (e) {
      log('⚠️ Unable to start native location service: ${e.message}');
    }
  }

  Future<void> _stopNativeLocationService() async {
    if (!Platform.isAndroid) return;
    try {
      await _locationServiceChannel.invokeMethod('stop');
      log('✅ Native foreground location service stopped');
    } on PlatformException catch (e) {
      log('⚠️ Unable to stop native location service: ${e.message}');
    }
  }

  void _startLocationPublishing() {
    locationSubscription = location.onLocationChanged.listen((locationData) {
      _lastLocation = locationData;
      _publishCurrentLocation(locationData);
    });

    // Movement filters can suppress callbacks while the driver is stationary.
    // Keep the server timestamp fresh so the live map still shows the driver.
    // A stationary driver may not trigger a GPS movement callback.  Refresh
    // their last-seen timestamp every five seconds while they are online so
    // the admin live map keeps the driver green and current.
    _locationHeartbeat = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (!isActive.value || _locationPublishInFlight) return;
      try {
        final current = _lastLocation ?? await location.getLocation();
        _lastLocation = current;
        await _publishCurrentLocation(current);
      } catch (e) {
        log('⚠️ Location heartbeat failed: $e');
      }
    });
  }

  Future<void> _publishCurrentLocation(LocationData currentLocation) async {
    if (!isActive.value || _locationPublishInFlight) return;
    if (currentLocation.latitude == null || currentLocation.longitude == null) {
      return;
    }

    _locationPublishInFlight = true;
    try {
      Constant.currentLocation = currentLocation;
      final driverLocationUpdate = DriverLocationUpdate(
        rotation: (currentLocation.heading ?? 0).toString(),
        active: true,
        driverId: Preferences.getInt(Preferences.userId).toString(),
        driverLatitude: currentLocation.latitude.toString(),
        driverLongitude: currentLocation.longitude.toString(),
        status: _getDriverStatus(),
      );

      // The server powers the admin live map, so publish there first. A Firebase
      // outage must not prevent the server heartbeat from being refreshed.
      await setCurrentLocation(
        currentLocation.latitude.toString(),
        currentLocation.longitude.toString(),
      );

      try {
        await Constant.driverLocationUpdate
            .doc(Preferences.getInt(Preferences.userId).toString())
            .set(driverLocationUpdate.toJson())
            .timeout(const Duration(seconds: 5));
      } catch (e) {
        log('⚠️ Firestore write failed (permission denied or network issue): $e');
      }
    } finally {
      _locationPublishInFlight = false;
    }
  }

  // deleteCurrentOrderLocation() {
//   RideData? rideData = Constant.getCurrentRideData();
//   if (rideData != null) {
//     String orderId = "";
//     if (rideData.rideType! == 'driver') {
//       orderId = '${rideData.idUserApp}-${rideData.id}-${rideData.idConducteur}';
//     } else {
//       orderId = (double.parse(rideData.idUserApp.toString()) < double.parse(rideData.idConducteur!))
//           ? '${rideData.idUserApp}-${rideData.id}-${rideData.idConducteur}'
//           : '${rideData.idConducteur}-${rideData.id}-${rideData.idUserApp}';
//     }
//     Location location = Location();
//     location.enableBackgroundMode(enable: false);
//     Constant.locationUpdate.doc(orderId).delete().then((value) async {
//       await updateCurrentLocation(data: rideData);
//       Preferences.clearKeyData(Preferences.currentRideData);
//       locationSubscription.cancel();
//     });
//   }
// }

  Future<dynamic> setCurrentLocation(String latitude, String longitude) async {
    try {
      Map<String, dynamic> bodyParams = {
        'id_user': Preferences.getInt(Preferences.userId),
        'user_cat': userModel.value.userData!.userCat,
        'latitude': latitude,
        'longitude': longitude
      };
      final response = await http.post(Uri.parse(API.updateLocation),
          headers: API.header, body: jsonEncode(bodyParams));
      showLog("API :: URL :: ${API.updateLocation} ");
      showLog("API :: Request Body :: ${jsonEncode(bodyParams)} ");
      showLog("API :: Request Header :: ${API.header.toString()} ");
      showLog("API :: responseStatus :: ${response.statusCode} ");
      showLog("API :: responseBody :: ${response.body} ");
      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        return responseBody;
      }
    } on TimeoutException catch (e) {
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }

  Future<dynamic> updateFCMToken(String token) async {
    try {
      Map<String, dynamic> bodyParams = {
        'user_id': Preferences.getInt(Preferences.userId),
        'fcm_id': token,
        'device_id': "",
        'user_cat': userModel.value.userData!.userCat
      };
      final response = await http.post(Uri.parse(API.updateToken),
          headers: API.header, body: jsonEncode(bodyParams));
      showLog("API :: URL :: ${API.updateToken} ");
      showLog("API :: Request Body :: ${jsonEncode(bodyParams)} ");
      showLog("API :: Request Header :: ${API.header.toString()} ");
      showLog("API :: responseStatus :: ${response.statusCode} ");
      showLog("API :: responseBody :: ${response.body} ");
      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        return responseBody;
      } else {}
    } on TimeoutException catch (e) {
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }

  Future<dynamic> changeOnlineStatus(bodyParams) async {
    try {
      ShowToastDialog.showLoader("Please wait");
      final response = await http.post(Uri.parse(API.changeStatus),
          headers: API.header, body: jsonEncode(bodyParams));
      showLog("API :: URL :: ${API.changeStatus} ");
      showLog("API :: Request Body :: ${jsonEncode(bodyParams)} ");
      showLog("API :: Request Header :: ${API.header.toString()} ");
      showLog("API :: responseStatus :: ${response.statusCode} ");
      showLog("API :: responseBody :: ${response.body} ");
      Map<String, dynamic> responseBody = json.decode(response.body);
      print("====>");
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {
        ShowToastDialog.closeLoader();
        // Refresh user data to get updated status
        await getUsrData();
        // Update location tracking (Firestore errors are handled inside)
        updateCurrentLocation();
        return responseBody;
      } else {
        ShowToastDialog.closeLoader();
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

  updateActiveStatus(bool value) async {
    try {
      // Update UI immediately
      isActive.value = value;

      Map<String, String> bodyParams = {
        'id_user': Preferences.getInt(Preferences.userId).toString(),
        'online': value ? "yes" : "no",
      };
      await changeOnlineStatus(bodyParams);
    } catch (e) {
      log('Error updating active status: $e');
      // Revert on error
      isActive.value = !value;
    }
  }

  Future<dynamic> getPaymentSettingData() async {
    try {
      final response =
          await http.get(Uri.parse(API.paymentSetting), headers: API.header);
      showLog("API :: URL :: ${API.paymentSetting} ");
      showLog("API :: Request Header :: ${API.header.toString()} ");
      showLog("API :: responseStatus :: ${response.statusCode} ");
      showLog("API :: responseBody :: ${response.body} ");
      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200 && responseBody['success'] == "success") {
        Preferences.setString(
            Preferences.paymentSetting, jsonEncode(responseBody));
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "Failed") {
      } else {}
    } on TimeoutException catch (e) {
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }

  /// Fetches driver's zone information from vehicle data and zone list
  Future<void> getDriverZoneInfo() async {
    try {
      isZoneLoading.value = true;

      // First, get the driver's vehicle data to get zone IDs
      final vehicleResponse = await http.get(
        Uri.parse(API
            .getVehicleData(Preferences.getInt(Preferences.userId).toString())),
        headers: API.header,
      );

      showLog(
          "API :: URL :: ${API.getVehicleData(Preferences.getInt(Preferences.userId).toString())} ");
      showLog("API :: responseStatus :: ${vehicleResponse.statusCode} ");
      showLog("API :: responseBody :: ${vehicleResponse.body} ");

      Map<String, dynamic> vehicleResponseBody =
          json.decode(vehicleResponse.body);

      if (vehicleResponse.statusCode == 200 &&
          vehicleResponseBody['success'] == "success") {
        GetVehicleDataModel vehicleDataModel =
            GetVehicleDataModel.fromJson(vehicleResponseBody);
        List<dynamic> zoneIds = vehicleDataModel.vehicleData?.zone_id ?? [];

        if (zoneIds.isEmpty) {
          driverZoneNames.value = "No zone assigned";
          isZoneLoading.value = false;
          return;
        }

        // Now fetch the zone list to get zone names
        final zoneResponse = await http.get(
          Uri.parse(API.getZone),
          headers: API.authheader,
        );

        showLog("API :: URL :: ${API.getZone} ");
        showLog("API :: responseStatus :: ${zoneResponse.statusCode} ");
        showLog("API :: responseBody :: ${zoneResponse.body} ");

        Map<String, dynamic> zoneResponseBody = json.decode(zoneResponse.body);

        if (zoneResponse.statusCode == 200 &&
            zoneResponseBody['success'] == "success") {
          ZoneModel zoneModel = ZoneModel.fromJson(zoneResponseBody);

          if (zoneModel.data != null && zoneModel.data!.isNotEmpty) {
            driverZones.clear();
            List<String> zoneNames = [];

            for (var zoneId in zoneIds) {
              var parsedId = int.tryParse(zoneId.toString().trim());
              if (parsedId != null) {
                var matchingZone =
                    zoneModel.data!.where((zone) => zone.id == parsedId);
                if (matchingZone.isNotEmpty) {
                  driverZones.add(matchingZone.first);
                  zoneNames.add(matchingZone.first.name ?? "Unknown");
                }
              }
            }

            driverZoneNames.value = zoneNames.isNotEmpty
                ? zoneNames.join(", ")
                : "No zone assigned";
          } else {
            driverZoneNames.value = "No zones available";
          }
        } else {
          driverZoneNames.value = "Unable to load zones";
        }
      } else {
        driverZoneNames.value = "No vehicle registered";
      }

      isZoneLoading.value = false;
    } on TimeoutException catch (e) {
      isZoneLoading.value = false;
      driverZoneNames.value = "Connection timeout";
      log('Zone fetch timeout: ${e.message}');
    } on SocketException catch (e) {
      isZoneLoading.value = false;
      driverZoneNames.value = "Network error";
      log('Zone fetch socket error: ${e.message}');
    } catch (e) {
      isZoneLoading.value = false;
      driverZoneNames.value = "Error loading zone";
      log('Zone fetch error: $e');
    }
  }
}
