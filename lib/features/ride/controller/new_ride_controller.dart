import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cabme_driver/core/constant/constant.dart';
import 'package:cabme_driver/core/constant/logdata.dart';
import 'package:cabme_driver/core/constant/show_toast_dialog.dart';
import 'package:cabme_driver/features/ride/model/ride_model.dart';
import 'package:cabme_driver/features/authentication/model/user_model.dart';
import 'package:cabme_driver/service/api.dart';
import 'package:cabme_driver/core/utils/Preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class NewRideController extends GetxController with WidgetsBindingObserver {
  var isLoading = true.obs;
  var rideList = <RideData>[].obs;
  String checkRideRejectBttnStatus = 'Hide';
  var isScreenActive = false.obs;

  // Filter state
  var selectedFilter = 'all'.obs;

  // Filter options
  static const List<String> filterOptions = [
    'all',
    'new',
    'confirmed',
    'on ride',
    'completed'
  ];

  // Get filtered rides
  List<RideData> get filteredRideList {
    if (selectedFilter.value == 'all') {
      return rideList;
    }
    return rideList.where((ride) {
      final status = ride.statut?.toLowerCase() ?? '';
      final filter = selectedFilter.value.toLowerCase();

      if (filter == 'on ride') {
        return status == 'on ride' || status == 'onride';
      }
      return status == filter;
    }).toList();
  }

  // Set filter
  void setFilter(String filter) {
    selectedFilter.value = filter;
    update();
  }

  Timer? timer;

  void startTimer() {
    stopTimer(); // Stop any existing timer first
    timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (isScreenActive.value) {
        getNewRide();
      }
    });
    update();
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    getNewRide(isInit: true);
    getRejectBtnstatus();
    getUsrData();
    startTimer();
  }

  // Called when screen becomes visible
  void onScreenVisible() {
    isScreenActive.value = true;
    getNewRide(); // Immediately fetch new rides
    startTimer();
  }

  // Called when screen is hidden
  void onScreenHidden() {
    isScreenActive.value = false;
  }

  // Handle app lifecycle changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // App came to foreground - refresh rides immediately
      getNewRide();
      startTimer();
    } else if (state == AppLifecycleState.paused) {
      // App went to background
      stopTimer();
    }
  }

  void stopTimer() {
    timer?.cancel();
    timer = null;
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    stopTimer();
    super.onClose();
  }

  Rx<UserModel> userModel = UserModel().obs;

  getUsrData() async {
    userModel.value = Constant.getUserData();

    Map<String, String> bodyParams = {
      'phone': userModel.value.userData!.phone.toString(),
      'user_cat': "driver",
      'email': userModel.value.userData!.email.toString(),
      'login_type': userModel.value.userData!.loginType.toString(),
    };
    final response = await http.post(Uri.parse(API.getProfileByPhone),
        headers: API.header, body: jsonEncode(bodyParams));
    showLog("API :: URL :: ${API.getProfileByPhone}");
    showLog("API :: Request Body :: ${jsonEncode(bodyParams)}");
    showLog("API :: Request Header :: ${API.header.toString()} ");
    showLog("API :: responseStatus :: ${response.statusCode} ");
    showLog("API :: responseBody :: ${response.body} ");
    Map<String, dynamic> responseBodyPhone = json.decode(response.body);
    if (response.statusCode == 200 &&
        responseBodyPhone['success'] == "success") {
      ShowToastDialog.closeLoader();
      UserModel? value = UserModel.fromJson(responseBodyPhone);
      Preferences.setString(Preferences.user, jsonEncode(value));
      userModel.value = value;
      update();
    }

    print("=======>${userModel.value.userData!.amount}");
  }

  Future<dynamic> getRejectBtnstatus() async {
    final response =
        await http.post(Uri.parse(API.rejectbtnRides), headers: API.header);
    Map<String, dynamic> responseBody = json.decode(response.body);
    print('Cabme: ${response.body}');
    if (response.statusCode == 200 && responseBody['status'] == 200) {
      print('Cabme: $responseBody');
      checkRideRejectBttnStatus = responseBody['message'];
      update();
    } else {}
  }

  Future<dynamic> getNewRide({bool isInit = false}) async {
    try {
      if (isInit) {
        ShowToastDialog.showLoader("Please wait");
      }
      final response = await http.get(
          Uri.parse(
              "${API.driverAllRides}?id_driver=${Preferences.getInt(Preferences.userId)}"),
          headers: API.header);

      Map<String, dynamic> responseBody = json.decode(response.body);

      showLog(
          "API :: URL :: ${API.driverAllRides}?id_driver=${Preferences.getInt(Preferences.userId)}");
      showLog("API :: Request Body :: ${API.header.toString()} ");
      showLog("API :: responseStatus :: ${response.statusCode} ");
      showLog("API :: responseBody :: ${response.body} ");

      if (response.statusCode == 200 && responseBody['success'] == "success") {
        isLoading.value = false;
        try {
          RideModel model = RideModel.fromJson(responseBody);
          rideList.value = model.data!;
        } catch (e) {
          print(e);
          return null;
        }

        // clearDriverRide(model.timeduration!, model.data!);
        ShowToastDialog.closeLoader();
        update();
      } else {
        rideList.clear();
        isLoading.value = false;
        ShowToastDialog.closeLoader();
      }
    } on TimeoutException catch (e) {
      isLoading.value = false;
      ShowToastDialog.closeLoader();
      // ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      isLoading.value = false;
      ShowToastDialog.closeLoader();
      // ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      print(e);
      isLoading.value = false;
      ShowToastDialog.closeLoader();
      // ShowToastDialog.showToast(e.toString());
    } catch (e) {
      ShowToastDialog.closeLoader();
      // ShowToastDialog.showToast(e.toString());
    }
    return null;
  }

  clearDriverRide(int seconds, List<RideData> list) {
    if (seconds != 0) {
      Timer.periodic(Duration(seconds: seconds), (timer) {
        if (list.isNotEmpty) {
          for (int a = 0; a < list.length; a++) {}
        }
      });
    }
  }

  TextEditingController otpController = TextEditingController();

  Future<dynamic> feelNotSafe(Map<String, dynamic> bodyParams) async {
    try {
      ShowToastDialog.showLoader("Please wait");
      final response = await http.post(Uri.parse(API.feelSafeAtDestination),
          headers: API.header, body: jsonEncode(bodyParams));
      showLog("API :: URL :: ${API.feelSafeAtDestination}");
      showLog("API :: Request Body :: ${jsonEncode(bodyParams)}");
      showLog("API :: Request Header :: ${API.header.toString()} ");
      showLog("API :: responseStatus :: ${response.statusCode} ");
      showLog("API :: responseBody :: ${response.body} ");
      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        ShowToastDialog.closeLoader();
        return responseBody;
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

  Future<dynamic> confirmedRide(Map<String, String> bodyParams) async {
    try {
      ShowToastDialog.showLoader("Please wait");
      final response = await http.post(Uri.parse(API.conformRide),
          headers: API.header, body: jsonEncode(bodyParams));
      showLog("API :: URL :: ${API.conformRide}");
      showLog("API :: Request Body :: ${jsonEncode(bodyParams)}");
      showLog("API :: Request Header :: ${API.header.toString()} ");
      showLog("API :: responseStatus :: ${response.statusCode} ");
      showLog("API :: responseBody :: ${response.body} ");
      Map<String, dynamic> responseBody = json.decode(response.body);
      log(responseBody.toString());
      if (response.statusCode == 200 && responseBody['success'] == "success") {
        ShowToastDialog.closeLoader();
        return responseBody;
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "Failed") {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(responseBody['error']);
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
    }
    ShowToastDialog.closeLoader();
    return null;
  }

  Future<dynamic> canceledRide(Map<String, String> bodyParams) async {
    try {
      ShowToastDialog.showLoader("Please wait");
      final response = await http.post(Uri.parse(API.rejectRide),
          headers: API.header, body: jsonEncode(bodyParams));
      showLog("API :: URL :: ${API.rejectRide}");
      showLog("API :: Request Body :: ${jsonEncode(bodyParams)}");
      showLog("API :: Request Header :: ${API.header.toString()} ");
      showLog("API :: responseStatus :: ${response.statusCode} ");
      showLog("API :: responseBody :: ${response.body} ");
      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200 && responseBody['success'] == "success") {
        ShowToastDialog.closeLoader();
        return responseBody;
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "Failed") {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(responseBody['error']);
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
    }
    ShowToastDialog.closeLoader();
    return null;
  }

  Future<dynamic> setOnRideRequest(Map<String, String> bodyParams) async {
    try {
      ShowToastDialog.showLoader("Please wait");
      final response = await http.post(Uri.parse(API.onRideRequest),
          headers: API.header, body: jsonEncode(bodyParams));
      showLog("API :: URL :: ${API.onRideRequest}");
      showLog("API :: Request Body :: ${jsonEncode(bodyParams)}");
      showLog("API :: Request Header :: ${API.header.toString()} ");
      showLog("API :: responseStatus :: ${response.statusCode} ");
      showLog("API :: responseBody :: ${response.body} ");
      Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == "success") {
        ShowToastDialog.closeLoader();
        return responseBody;
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "Failed") {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(responseBody['error']);
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
    }
    ShowToastDialog.closeLoader();
    return null;
  }

  Future<dynamic> setCompletedRequest(
      Map<String, String> bodyParams, RideData data) async {
    try {
      ShowToastDialog.showLoader("Please wait");
      final response = await http.post(Uri.parse(API.setCompleteRequest),
          headers: API.header, body: jsonEncode(bodyParams));
      showLog("API :: URL :: ${API.setCompleteRequest}");
      showLog("API :: Request Body :: ${jsonEncode(bodyParams)}");
      showLog("API :: Request Header :: ${API.header.toString()} ");
      showLog("API :: responseStatus :: ${response.statusCode} ");
      showLog("API :: responseBody :: ${response.body} ");
      Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == "success") {
        if (data.rideType!.toString() == "driver") {
          await cashPaymentRequest(data);
        }
        ShowToastDialog.closeLoader();
        return responseBody;
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "Failed") {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(responseBody['error']);
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
    }
    ShowToastDialog.closeLoader();
    return null;
  }

  Future<dynamic> verifyOTP(
      {required String userId, required String rideId}) async {
    try {
      ShowToastDialog.showLoader("Please wait");
      final response = await http.get(
          Uri.parse(
              "${API.rideOtpVerify}?id_user_app=$userId&otp=${otpController.text.toString()}&ride_id=$rideId&ride_type="),
          headers: API.header);
      showLog(
          "API :: URL :: ${API.rideOtpVerify}?id_user_app=$userId&otp=${otpController.text.toString()}&ride_id=$rideId&ride_type=");
      showLog("API :: Request Header :: ${API.header.toString()} ");
      showLog("API :: responseStatus :: ${response.statusCode} ");
      showLog("API :: responseBody :: ${response.body} ");
      Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == "success") {
        ShowToastDialog.closeLoader();
        return responseBody;
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "Failed") {
        await http.get(
            Uri.parse(
                "${API.reGenerateOtp}?id_user_app=$userId&ride_id=$rideId"),
            headers: API.header);

        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(responseBody['error'].toString());
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

  Future<dynamic> cashPaymentRequest(RideData data) async {
    List taxList = [];

    for (var v in Constant.taxList) {
      taxList.add(v.toJson());
    }
    Map<String, dynamic> bodyParams = {
      'id_ride': data.id.toString(),
      'id_driver': data.idConducteur.toString(),
      'id_user_app': data.idUserApp.toString(),
      'amount': data.montant.toString(),
      'paymethod': "Cash",
      'discount': data.discount.toString(),
      'tip': data.tipAmount.toString(),
      'tax': taxList,
      'transaction_id': DateTime.now().microsecondsSinceEpoch.toString(),
      'commission': Preferences.getString(Preferences.admincommission),
      'payment_status': "success",
    };
    try {
      // ShowToastDialog.showLoader("Please wait");
      final response = await http.post(Uri.parse(API.payRequestCash),
          headers: API.header, body: jsonEncode(bodyParams));

      showLog("API :: URL :: ${API.payRequestCash}");
      showLog("API :: Request Body :: ${jsonEncode(bodyParams)}");
      showLog("API :: Request Header :: ${API.header.toString()} ");
      showLog("API :: responseStatus :: ${response.statusCode} ");
      showLog("API :: responseBody :: ${response.body} ");
      Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200 &&
          responseBody['success'].toString().toLowerCase() ==
              "Success".toString().toLowerCase()) {
        ShowToastDialog.showToast("Successfully completed");

        Get.back();
        // ShowToastDialog.closeLoader();

        return responseBody;
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "Failed") {
        // ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(responseBody['error']);
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
    }
    // ShowToastDialog.closeLoader();
    return null;
  }
}
