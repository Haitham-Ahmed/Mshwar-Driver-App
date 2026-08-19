import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cabme_driver/core/constant/logdata.dart';
import 'package:cabme_driver/core/constant/show_toast_dialog.dart';
import 'package:cabme_driver/features/authentication/model/user_model.dart';
import 'package:cabme_driver/features/authentication/view/otp_screen.dart';
import 'package:cabme_driver/features/authentication/view/signup_screen.dart';
import 'package:cabme_driver/features/dashboard/view/dash_board.dart';
import 'package:cabme_driver/service/api.dart';
import 'package:cabme_driver/core/utils/Preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class PhoneNumberController extends GetxController {
  var phoneNumber = TextEditingController().obs;

  sendCode() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+965${phoneNumber.value.text}',
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        ShowToastDialog.closeLoader();

        if (e.code == 'invalid-phone-number') {
          ShowToastDialog.showToast("The provided phone number is not valid.");
        } else {
          print(e.message.toString());
          ShowToastDialog.showToast(e.message.toString());
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        ShowToastDialog.closeLoader();
        Get.to(
          const OtpScreen(),
          arguments: {
            'phoneNumber': '+965${phoneNumber.value.text.trim()}',
            'verificationId': verificationId,
            'resendTokenData': resendToken ?? 0,
          },
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future SendOTPApiMethod(Map<String, String> bodyParams) async {
    try {
      ShowToastDialog.showLoader("Please wait");
      final response = await http.post(Uri.parse(API.sendOtp),
          headers: API.authheader, body: jsonEncode(bodyParams));
      showLog("API :: URL :: ${API.sendOtp}");
      showLog("API :: Request Body :: ${jsonEncode(bodyParams)} ");
      showLog("API :: Response Status :: ${response.statusCode} ");
      showLog("API :: Response Body :: ${response.body} ");
      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200 && responseBody['status'] == 200) {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(
            responseBody['message'] ?? 'OTP sent successfully');
        Get.to(
          const OtpScreen(),
          arguments: {
            'phoneNumber': '965${phoneNumber.value.text.trim()}',
          },
        );
      } else {
        ShowToastDialog.closeLoader();
        String errorMessage = responseBody['message'] ??
            responseBody['error'] ??
            'Something went wrong. Please try again later';
        ShowToastDialog.showToast(errorMessage);
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

  Future VerifyOTPApiMethod(Map<String, String> bodyParams) async {
    try {
      ShowToastDialog.showLoader("Please wait");
      final response = await http.post(Uri.parse(API.verifyOtp),
          headers: API.authheader, body: jsonEncode(bodyParams));
      showLog("API :: URL :: ${API.verifyOtp}");
      showLog("API :: Request Body :: ${jsonEncode(bodyParams)} ");
      showLog("API :: Response Status :: ${response.statusCode} ");
      showLog("API :: Response Body :: ${response.body} ");
      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200 && responseBody['status'] == 200) {
        print(response.body);
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(
            responseBody['message'] ?? 'OTP verified successfully');
        Map<String, String> body = {
          'phone': bodyParams['mobile'].toString(),
          'user_cat': "driver",
          'login_type': "phoneNumber"
        };
        phoneNumberIsExit(body);
      } else {
        ShowToastDialog.closeLoader();
        String errorMessage = responseBody['message'] ??
            responseBody['error'] ??
            'Something went wrong. Please try again later';
        ShowToastDialog.showToast(errorMessage);
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

  Future<bool?> phoneNumberIsExit(Map<String, String> bodyParams) async {
    try {
      ShowToastDialog.showLoader("Please wait");
      final response = await http.post(Uri.parse(API.getExistingUserOrNot),
          headers: API.header, body: jsonEncode(bodyParams));
      showLog("API :: URL :: ${API.getExistingUserOrNot} ");
      showLog("API :: Request Body :: ${jsonEncode(bodyParams)} ");
      showLog("API :: Request Header :: ${API.header.toString()} ");
      showLog("API :: responseStatus :: ${response.statusCode} ");
      showLog("API :: responseBody :: ${response.body} ");
      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200 && responseBody['success'] == "success") {
        ShowToastDialog.closeLoader();
        if (responseBody['data'] == true) {
          Map<String, String> body = {
            'phone': responseBody['mobile'].toString(),
            'user_cat': "driver",
            'login_type': "phoneNumber",
          };
          getDataByPhoneNumber(body);
          return true;
        } else {
          Get.off(SignupScreen(), arguments: {
            'phoneNumber': responseBody['mobile'].toString(),
            'login_type': "phoneNumber"
          });
          return false;
        }
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
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }

  Future<UserModel?> getDataByPhoneNumber(
      Map<String, String> bodyParams) async {
    try {
      ShowToastDialog.showLoader("Please wait");
      final response = await http.post(Uri.parse(API.getProfileByPhone),
          headers: API.header, body: jsonEncode(bodyParams));
      showLog("API :: URL :: ${API.getProfileByPhone} ");
      showLog("API :: Request Body :: ${jsonEncode(bodyParams)} ");
      showLog("API :: Request Header :: ${API.header.toString()} ");
      showLog("API :: responseStatus :: ${response.statusCode} ");
      showLog("API :: responseBody :: ${response.body} ");
      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200 && responseBody['success'] == "success") {
        ShowToastDialog.closeLoader();
        UserModel value = UserModel.fromJson(responseBody);
        Preferences.setString(Preferences.user, jsonEncode(value));
        UserData? userData = value.userData;
        Preferences.setInt(
            Preferences.userId, int.parse(userData!.id.toString()));
        Preferences.setString(
            Preferences.accesstoken, value.userData!.accesstoken.toString());
        API.header['accesstoken'] =
            Preferences.getString(Preferences.accesstoken);

        ShowToastDialog.closeLoader();
        Preferences.setBoolean(Preferences.isLogin, true);
        Get.offAll(() => DashBoard());
        update();
        return UserModel.fromJson(responseBody);
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
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }
}
