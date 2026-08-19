import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cabme_driver/core/constant/logdata.dart';
import 'package:cabme_driver/core/constant/show_toast_dialog.dart';
import 'package:cabme_driver/features/bank/model/bank_details_model.dart';
import 'package:cabme_driver/service/api.dart';
import 'package:cabme_driver/core/utils/Preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class BankDetailsController extends GetxController {
  var bankNameController = TextEditingController().obs;
  var branchNameController = TextEditingController().obs;
  var holderNameController = TextEditingController().obs;
  var accountNumberController = TextEditingController().obs;
  var otherInformationController = TextEditingController().obs;
  var ifscCodeController = TextEditingController().obs;
  final formKey = GlobalKey<FormState>();
  @override
  void onInit() {
    getBankDetails();

    super.onInit();
  }

  iniData() {
    bankNameController.value = TextEditingController(text: bankDetails.value.bankName);
    branchNameController.value = TextEditingController(text: bankDetails.value.branchName);
    holderNameController.value = TextEditingController(text: bankDetails.value.holderName);
    accountNumberController.value = TextEditingController(text: bankDetails.value.accountNo);
    otherInformationController.value = TextEditingController(text: bankDetails.value.otherInfo);
    ifscCodeController.value = TextEditingController(text: bankDetails.value.ifscCode);
    ShowToastDialog.closeLoader();
  }

  var isLoading = true.obs;
  var bankDetails = BankData().obs;

  Future<dynamic> getBankDetails() async {
    try {
      ShowToastDialog.showLoader("Please wait");
      final response = await http.get(Uri.parse("${API.bankDetails}?driver_id=${Preferences.getInt(Preferences.userId)}"), headers: API.header);
      showLog("API :: URL :: ${API.bankDetails}?driver_id=${Preferences.getInt(Preferences.userId)} ");
      showLog("API :: Request Header :: ${API.header.toString()} ");
      showLog("API :: responseStatus :: ${response.statusCode} ");
      showLog("API :: responseBody :: ${response.body} ");

      Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == "success") {
        isLoading.value = false;
        BankDetailsModel model = BankDetailsModel.fromJson(responseBody);
        bankDetails.value = model.data!;
        iniData();
      } else if (response.statusCode == 200 && responseBody['success'] == "Failed") {
        isLoading.value = false;
        ShowToastDialog.closeLoader();
      } else {
        isLoading.value = false;
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast('Something want wrong. Please try again later');
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

  Future<dynamic> setBankDetails(Map<String, String> bodyParams) async {
    try {
      ShowToastDialog.showLoader("Please wait");
      final response = await http.post(Uri.parse(API.addBankDetails), headers: API.header, body: jsonEncode(bodyParams));
      showLog("API :: URL :: ${jsonEncode(bodyParams)} ");
      showLog("API :: Request Body :: ${API.addBankDetails} ");
      showLog("API :: Request Header :: ${API.header.toString()} ");
      showLog("API :: responseStatus :: ${response.statusCode} ");
      showLog("API :: responseBody :: ${response.body} ");
      Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == "success") {
        ShowToastDialog.closeLoader();
        return responseBody;
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
    }
    ShowToastDialog.closeLoader();
    return null;
  }
}
