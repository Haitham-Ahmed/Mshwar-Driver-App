import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cabme_driver/core/constant/logdata.dart';
import 'package:cabme_driver/core/constant/show_toast_dialog.dart';
import 'package:cabme_driver/features/wallet/model/withdrawals_model.dart';
import 'package:cabme_driver/service/api.dart';
import 'package:cabme_driver/core/utils/Preferences.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class WithdrawalsController extends GetxController {
  var isLoading = true.obs;
  var rideList = <WithdrawalsData>[].obs;

  @override
  void onInit() {
    getWithdrawals();
    super.onInit();
  }

  Future<dynamic> getWithdrawals() async {
    try {
      ShowToastDialog.showLoader("Please wait");
      final response = await http.get(Uri.parse("${API.withdrawalsList}?driver_id=${Preferences.getInt(Preferences.userId)}"), headers: API.header);
      showLog("API :: URL :: ${API.withdrawalsList}?driver_id=${Preferences.getInt(Preferences.userId)}");
      showLog("API :: Request Header :: ${API.header.toString()} ");
      showLog("API :: responseStatus :: ${response.statusCode} ");
      showLog("API :: responseBody :: ${response.body} ");
      Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == "success") {
        isLoading.value = false;
        WithdrawalsModel model = WithdrawalsModel.fromJson(responseBody);
        rideList.value = model.data!;
        ShowToastDialog.closeLoader();
      } else {
        rideList.clear();
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
      isLoading.value = false;
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }
}
