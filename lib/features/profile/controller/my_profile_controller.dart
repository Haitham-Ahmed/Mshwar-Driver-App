import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cabme_driver/core/constant/constant.dart';
import 'package:cabme_driver/core/constant/logdata.dart';
import 'package:cabme_driver/core/constant/show_toast_dialog.dart';
import 'package:cabme_driver/features/authentication/model/user_model.dart';
import 'package:cabme_driver/features/vehicle/model/zone_model.dart';
import 'package:cabme_driver/service/api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class MyProfileController extends GetxController {
  var isLoading = true.obs;

  RxList selectedZone = <int>[].obs;
  RxList<ZoneData> zoneList = <ZoneData>[].obs;

  @override
  void onInit() {
    getUsrData();

    super.onInit();
  }

  UserModel? userModel;

  // RxString name = "".obs;
  // RxString lastName = "".obs;
  // RxString email = "".obs;
  // RxString phoneNo = "".obs;

  RxString userCat = "".obs;
  RxString profileImage = "".obs;
  RxString userID = "".obs;

  getUsrData() async {
    UserModel userModel = Constant.getUserData();
    nameController.value.text = userModel.userData!.prenom!;
    lastNameController.value.text = userModel.userData!.nom!;
    emailController.value.text = userModel.userData!.email!;
    phoneController.value.text = userModel.userData!.phone!;
    log("Country Code :: ${userModel.userData!.country.toString()}");
    userCat.value = userModel.userData!.userCat!;
    profileImage.value = userModel.userData!.photoPath ?? "";
    userID.value = userModel.userData!.id.toString();
  }

  Future<dynamic> uploadPhoto(File image) async {
    try {
      ShowToastDialog.showLoader("Please wait");
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(API.userUpdateProfile),
      );
      request.headers.addAll(API.header);

      request.files.add(http.MultipartFile.fromBytes(
          'image', image.readAsBytesSync(),
          filename: image.path.split('/').last));
      request.fields['id_user'] = userID.value;
      request.fields['user_cat'] = userCat.value;

      var res = await request.send();
      var responseData = await res.stream.toBytes();
      showLog("API :: URL :: ${API.userUpdateProfile}");
      showLog("API :: Request Body :: ${jsonEncode(request.fields)} ");
      showLog("API :: Response Status :: ${res.statusCode} ");
      showLog("API :: Response Body :: ${String.fromCharCodes(responseData)} ");
      Map<String, dynamic> response =
          jsonDecode(String.fromCharCodes(responseData));
      if (res.statusCode == 200) {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("Uploaded!");
        return response;
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
  }

  Future<dynamic> updateFirstName(Map<String, String> bodyParams) async {
    try {
      ShowToastDialog.showLoader("Please wait");
      final response = await http.post(Uri.parse(API.updatePreName),
          headers: API.header, body: jsonEncode(bodyParams));
      showLog("API :: URL :: ${API.updatePreName}");
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

  Future<dynamic> updateLastName(Map<String, String> bodyParams) async {
    try {
      ShowToastDialog.showLoader("Please wait");
      final response = await http.post(Uri.parse(API.updateLastName),
          headers: API.header, body: jsonEncode(bodyParams));
      showLog("API :: URL :: ${API.updateLastName}");
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

  Future<dynamic> updatePhone(Map<String, String> bodyParams) async {
    try {
      ShowToastDialog.showLoader("Please wait");
      final response = await http.post(Uri.parse(API.updateUserPhone),
          headers: API.header, body: jsonEncode(bodyParams));
      showLog("API :: URL :: ${API.updateUserPhone}");
      showLog("API :: Request Body :: ${jsonEncode(bodyParams)}");
      showLog("API :: Request Header :: ${API.header.toString()} ");
      showLog("API :: responseStatus :: ${response.statusCode} ");
      showLog("API :: responseBody :: ${response.body} ");
      Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == "success") {
        UserModel userData = UserModel.fromJson(responseBody);
        phoneController.value.text = userData.userData!.phone!;
        return true;
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "Failed") {
        ShowToastDialog.closeLoader();
        return false;
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

  Future<dynamic> updateEmail(Map<String, String> bodyParams) async {
    try {
      ShowToastDialog.showLoader("Please wait");
      final response = await http.post(Uri.parse(API.updateUserEmail),
          headers: API.header, body: jsonEncode(bodyParams));
      showLog("API :: URL :: ${API.updateUserEmail}");
      showLog("API :: Request Body :: ${jsonEncode(bodyParams)}");
      showLog("API :: Request Header :: ${API.header.toString()} ");
      showLog("API :: responseStatus :: ${response.statusCode} ");
      showLog("API :: responseBody :: ${response.body} ");
      Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == "success") {
        UserModel userData = UserModel.fromJson(responseBody);
        emailController.value.text = userData.userData!.email!;
        return responseBody;
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "Failed") {
        ShowToastDialog.closeLoader();
        return false;
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

  Future<dynamic> updatePassword(Map<String, String> bodyParams) async {
    try {
      ShowToastDialog.showLoader("Please wait");
      final response = await http.post(Uri.parse(API.changePassword),
          headers: API.header, body: jsonEncode(bodyParams));
      showLog("API :: URL :: ${API.changePassword}");
      showLog("API :: Request Body :: ${jsonEncode(bodyParams)}");
      showLog("API :: Request Header :: ${API.header.toString()} ");
      showLog("API :: responseStatus :: ${response.statusCode} ");
      showLog("API :: responseBody :: ${response.body} ");
      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200 && responseBody['success'] == "success") {
        ShowToastDialog.closeLoader();
        return true;
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "Failed") {
        ShowToastDialog.closeLoader();
        return responseBody['error'];
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

  Future<dynamic> deleteAccount(String userId) async {
    try {
      ShowToastDialog.showLoader("Please wait");
      final response = await http.get(
        Uri.parse("${API.deleteUser(userId)}&user_cat=driver"),
        headers: API.header,
      );
      showLog("API :: URL :: ${"${API.deleteUser}$userId&user_cat=driver"}");
      showLog("API :: Request Header :: ${API.header.toString()} ");
      showLog("API :: responseStatus :: ${response.statusCode} ");
      showLog("API :: responseBody :: ${response.body} ");
      Map<String, dynamic> responseBody = json.decode(response.body);
      if (responseBody['success'] != 'Failed') {
        ShowToastDialog.closeLoader();
        return responseBody;
      } else {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(responseBody['error'].toString());
        // throw Exception('Failed to load album');
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

  var nameController = TextEditingController().obs;
  var lastNameController = TextEditingController().obs;
  var emailController = TextEditingController().obs;
  var phoneController = TextEditingController().obs;
  var currentPasswordController = TextEditingController().obs;
  var newPasswordController = TextEditingController().obs;
  var confirmPasswordController = TextEditingController().obs;
}
