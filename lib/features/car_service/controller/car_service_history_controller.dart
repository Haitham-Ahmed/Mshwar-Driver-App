import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cabme_driver/core/constant/constant.dart';
import 'package:cabme_driver/core/constant/logdata.dart';
import 'package:cabme_driver/core/constant/show_toast_dialog.dart';
import 'package:cabme_driver/features/car_service/model/car_service_book_model.dart';
import 'package:cabme_driver/features/authentication/model/user_model.dart';
import 'package:cabme_driver/service/api.dart';
import 'package:cabme_driver/core/utils/Preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class CarServiceHistoryController extends GetxController {
  String userCat = "driver";

  var isLoading = true.obs;
  var serviceList = <ServiceData>[].obs;

  @override
  void onInit() {
    getUserdata();
    getCarServiceBooks();
    super.onInit();
  }

  getUserdata() async {
    UserModel? userModel = Constant.getUserData();
    userCat = userModel.userData!.userCat!;
  }

  Rx<TextEditingController> kmDrivenController = TextEditingController().obs;
  RxString carServiceBook = "".obs;

  Future<dynamic> userCarServiceBook({kmDriven = 0}) async {
    try {
      ShowToastDialog.showLoader("Please wait");

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(API.uploadCarServiceBook),
      );
      request.headers.addAll(API.header);

      request.files.add(http.MultipartFile.fromBytes(
          'image', File(carServiceBook.value).readAsBytesSync(),
          filename: File(carServiceBook.value).path.split('/').last));
      request.fields['id_driver'] =
          Preferences.getInt(Preferences.userId).toString();
      request.fields['km_driven'] = kmDriven.toString();

      var res = await request.send();
      var responseData = await res.stream.toBytes();
      showLog("API :: URL :: ${API.uploadCarServiceBook}");
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

  Future<dynamic> getCarServiceBooks() async {
    try {
      ShowToastDialog.showLoader("Please wait");
      final response = await http.get(
          Uri.parse(API.getCarServiceBook(
              Preferences.getInt(Preferences.userId).toString())),
          headers: API.header);
      showLog(
          "API :: URL :: ${API.getCarServiceBook(Preferences.getInt(Preferences.userId).toString())} ");
      showLog("API :: Request Header :: ${API.header.toString()} ");
      showLog("API :: responseStatus :: ${response.statusCode} ");
      showLog("API :: responseBody :: ${response.body} ");
      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200 && responseBody['success'] == "success") {
        isLoading.value = false;
        CarServiceHistoryModel model =
            CarServiceHistoryModel.fromJson(responseBody);
        serviceList.value = model.data!;
        ShowToastDialog.closeLoader();
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "Failed") {
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
}
