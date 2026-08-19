import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cabme_driver/core/constant/logdata.dart';
import 'package:cabme_driver/core/constant/show_toast_dialog.dart';
import 'package:cabme_driver/features/review/model/review_model.dart';
import 'package:cabme_driver/features/ride/model/ride_model.dart';
import 'package:cabme_driver/service/api.dart';
import 'package:cabme_driver/core/utils/Preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class AddReviewController extends GetxController {
  var rating = 1.0.obs;
  final reviewCommentController = TextEditingController().obs;

  @override
  void onInit() {
    getArgument();
    getReview();
    super.onInit();
  }

  Rx<RideData?> data = RideData().obs;
  var ratingModel = ReviewModel().obs;

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      data.value = argumentData['rideData'];
    }
    update();
  }

  var isLoading = true.obs;

  Future<dynamic> getReview() async {
    try {
      final response =
          await http.get(Uri.parse("${API.getRideReview}?user_id=${Preferences.getInt(Preferences.userId)}&ride_id=${data.value!.id}&review_of=customer"), headers: API.header);
      showLog("API :: URL :: ${API.getRideReview}?user_id=${Preferences.getInt(Preferences.userId)}&ride_id=${data.value!.id}&review_of=customer} ");
      showLog("API :: Request Header :: ${API.header.toString()} ");
      showLog("API :: responseStatus :: ${response.statusCode} ");
      showLog("API :: responseBody :: ${response.body} ");

      Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == "Success") {
        ReviewModel model = ReviewModel.fromJson(responseBody);
        ratingModel.value = model;
        rating.value = double.parse(model.data!.niveauDriver.toString());
        reviewCommentController.value.text = model.data!.comment.toString();
        isLoading.value = false;
        ShowToastDialog.closeLoader();
      } else {
        isLoading.value = false;
        ShowToastDialog.closeLoader();
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

  Future<bool?> addReview(Map<String, String> bodyParams) async {
    try {
      ShowToastDialog.showLoader("Please wait");
      final response = await http.post(Uri.parse(API.addReview), headers: API.header, body: jsonEncode(bodyParams));
      showLog("API :: URL :: ${API.addReview} ");
      showLog("API :: Request Body :: ${jsonEncode(bodyParams)} ");
      showLog("API :: Request Header :: ${API.header.toString()} ");
      showLog("API :: responseStatus :: ${response.statusCode} ");
      showLog("API :: responseBody :: ${response.body} ");

      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200 && responseBody['success'] == "Success") {
        ShowToastDialog.closeLoader();
        return true;
      } else if (response.statusCode == 200 && responseBody['success'] == "Failed") {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(responseBody['error']);
      } else {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast('Something want wrong. Please try again later');
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
