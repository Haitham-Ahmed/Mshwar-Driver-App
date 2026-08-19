import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cabme_driver/core/constant/logdata.dart';
import 'package:cabme_driver/core/constant/show_toast_dialog.dart';
import 'package:cabme_driver/service/api.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordController extends GetxController {
  Future<bool?> sendEmail(Map<String, String> bodyParams) async {
    try {
      ShowToastDialog.showLoader("Please wait");
      final response = await http.post(
        Uri.parse(API.sendResetPasswordOtp),
        headers: API.header,
        body: jsonEncode(bodyParams),
      );
      showLog("API :: URL :: ${API.sendResetPasswordOtp}");
      showLog("API :: Request Body :: ${jsonEncode(bodyParams)}");
      showLog("API :: Request Header :: ${API.header.toString()} ");
      showLog("API :: responseStatus :: ${response.statusCode} ");
      showLog("API :: responseBody :: ${response.body} ");

      log("responseBody :: ${response.body}");

      ShowToastDialog.closeLoader();

      // Try to parse JSON response
      Map<String, dynamic> responseBody;
      try {
        responseBody = json.decode(response.body);
      } catch (e) {
        log("JSON Parse Error: $e");
        ShowToastDialog.showToast('Server error. Please try again.');
        return false;
      }

      if (response.statusCode == 200 && responseBody['success'] == "success") {
        ShowToastDialog.showToast("OTP sent to your email!");
        return true;
      } else {
        // Show error message from API - check all possible keys
        String errorMessage = responseBody['error']?.toString() ??
            responseBody['message']?.toString() ??
            responseBody['msg']?.toString() ??
            'Email not found or invalid request';
        ShowToastDialog.showToast(errorMessage);
        return false;
      }
    } on TimeoutException {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(
          'Connection timeout. Please check your internet connection.');
      return false;
    } on SocketException catch (e) {
      ShowToastDialog.closeLoader();
      log("SocketException: $e");
      ShowToastDialog.showToast(
          'No internet connection. Please check your network.');
      return false;
    } on FormatException catch (e) {
      ShowToastDialog.closeLoader();
      log("FormatException: $e");
      ShowToastDialog.showToast(
          'Invalid response from server. Please try again.');
      return false;
    } catch (e) {
      ShowToastDialog.closeLoader();
      log("Catch Error: $e");
      // Show the actual error for debugging
      ShowToastDialog.showToast(e.toString());
      return false;
    }
  }

  Future<bool?> resetPassword(Map<String, String> bodyParams) async {
    try {
      ShowToastDialog.showLoader("Please wait");
      final response = await http.post(
        Uri.parse(API.resetPasswordOtp),
        headers: API.header,
        body: jsonEncode(bodyParams),
      );

      showLog("API :: URL :: ${API.resetPasswordOtp}");
      showLog("API :: Request Body :: ${jsonEncode(bodyParams)}");
      showLog("API :: Request Header :: ${API.header.toString()} ");
      showLog("API :: responseStatus :: ${response.statusCode} ");
      showLog("API :: responseBody :: ${response.body} ");

      ShowToastDialog.closeLoader();

      // Try to parse JSON response
      Map<String, dynamic> responseBody;
      try {
        responseBody = json.decode(response.body);
      } catch (e) {
        log("JSON Parse Error: $e");
        ShowToastDialog.showToast('Server error. Please try again.');
        return false;
      }

      if (response.statusCode == 200 && responseBody['success'] == "success") {
        return true;
      } else {
        // Show error message from API
        String errorMessage = responseBody['error']?.toString() ??
            responseBody['message']?.toString() ??
            'Invalid OTP or request failed';
        ShowToastDialog.showToast(errorMessage);
        return false;
      }
    } on TimeoutException {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(
          'Connection timeout. Please check your internet connection.');
      return false;
    } on SocketException catch (e) {
      ShowToastDialog.closeLoader();
      log("SocketException: $e");
      ShowToastDialog.showToast(
          'No internet connection. Please check your network.');
      return false;
    } on FormatException catch (e) {
      ShowToastDialog.closeLoader();
      log("FormatException: $e");
      ShowToastDialog.showToast(
          'Invalid response from server. Please try again.');
      return false;
    } catch (e) {
      ShowToastDialog.closeLoader();
      log("Catch Error: $e");
      ShowToastDialog.showToast(e.toString());
      return false;
    }
  }
}
