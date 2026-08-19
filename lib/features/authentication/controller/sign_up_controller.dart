import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cabme_driver/core/constant/logdata.dart';
import 'package:cabme_driver/core/constant/show_toast_dialog.dart';
import 'package:cabme_driver/features/authentication/model/user_model.dart';
import 'package:cabme_driver/service/api.dart';
import 'package:cabme_driver/core/utils/Preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class SignUpController extends GetxController {
  var phoneNumber = TextEditingController().obs;
  final firstNameController = TextEditingController().obs;
  final lastNameController = TextEditingController().obs;
  final emailController = TextEditingController().obs;

  final passwordController = TextEditingController().obs;
  final conformPasswordController = TextEditingController().obs;

  RxString loginType = "".obs;

  @override
  void onInit() {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      loginType.value = argumentData['login_type'];
      if (loginType.value == "phoneNumber") {
        phoneNumber.value =
            TextEditingController(text: argumentData['phoneNumber'] ?? '');
      } else {
        emailController.value.text = argumentData['email'] ?? "";
        firstNameController.value.text = argumentData['firstName'] ?? "";
        lastNameController.value.text = argumentData['lastname'] ?? "";
      }
    }
    super.onInit();
  }

  Future<UserModel?> signUp(Map<String, String> bodyParams) async {
    try {
      ShowToastDialog.showLoader("Please wait");
      final response = await http.post(Uri.parse(API.userSignUP),
          headers: API.authheader, body: jsonEncode(bodyParams));
      showLog("API :: URL :: ${API.userSignUP} ");
      showLog("API :: Request Body :: ${jsonEncode(bodyParams)} ");
      showLog("API :: Request Header :: ${API.authheader.toString()} ");
      showLog("API :: responseStatus :: ${response.statusCode} ");
      showLog("API :: responseBody :: ${response.body}");
      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        ShowToastDialog.closeLoader();
        if (responseBody['success'] == "Failed") {
          ShowToastDialog.showToast(responseBody['error']);
        } else {
          Preferences.setString(Preferences.accesstoken,
              responseBody['data']['accesstoken'].toString());
          API.header['accesstoken'] =
              Preferences.getString(Preferences.accesstoken);
          return UserModel.fromJson(responseBody);
        }
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
}
