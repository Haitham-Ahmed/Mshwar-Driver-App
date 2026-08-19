// ignore_for_file: unused_local_variable

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cabme_driver/core/constant/constant.dart';
import 'package:cabme_driver/core/constant/logdata.dart';
import 'package:cabme_driver/core/constant/show_toast_dialog.dart';
import 'package:cabme_driver/features/document/model/uploaded_document_model.dart';
import 'package:cabme_driver/features/authentication/model/user_model.dart';
import 'package:cabme_driver/service/api.dart';
import 'package:cabme_driver/core/utils/Preferences.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class DocumentStatusController extends GetxController {
  String userCat = "driver";

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

  var isLoading = true.obs;
  var documentList = <UploadedDocumentData>[].obs;

  Future<dynamic> getCarServiceBooks() async {
    try {
      ShowToastDialog.showLoader("Please wait");
      final response = await http.get(Uri.parse("${API.getDriverUploadedDocument}?driver_id=${Preferences.getInt(Preferences.userId)}"), headers: API.header);
      showLog("API :: URL :: ${API.getDriverUploadedDocument}?driver_id=${Preferences.getInt(Preferences.userId)} ");
      showLog("API :: Request Header :: ${API.header.toString()} ");
      showLog("API :: responseStatus :: ${response.statusCode} ");
      showLog("API :: responseBody :: ${response.body} ");
      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200 && responseBody['success'] == "success") {
        isLoading.value = false;
        UploadedDocumentModel model = UploadedDocumentModel.fromJson(responseBody);
        documentList.value = model.data!;
        ShowToastDialog.closeLoader();
        update();
      } else if (response.statusCode == 200 && responseBody['success'] == "Failed") {
        ShowToastDialog.closeLoader();
        isLoading.value = false;
        update();
      } else {
        isLoading.value = false;
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast('Something want wrong. Please try again later');
        update();
        throw Exception('Failed to load album');
      }
    } on TimeoutException catch (e) {
      isLoading.value = false;
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
      update();
    } on SocketException catch (e) {
      isLoading.value = false;
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
      update();
    } on Error catch (e) {
      isLoading.value = false;
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
      update();
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
      update();
    }
    return null;
  }

  Future<dynamic> updateDocument(String driverDocumentId, String path) async {
    try {
      ShowToastDialog.showLoader("Please wait");

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(API.driverDocumentUpdate),
      );
      request.headers.addAll(API.header);

      request.files.add(http.MultipartFile.fromBytes('attachment', File(path).readAsBytesSync(), filename: File(path).path.split('/').last));
      request.fields['document_id'] = driverDocumentId;
      request.fields['driver_id'] = Preferences.getInt(Preferences.userId).toString();

      var res = await request.send();
      var responseData = await res.stream.toBytes();

      Map<String, dynamic> response = jsonDecode(String.fromCharCodes(responseData));
      showLog("API :: URL :: ${API.driverDocumentUpdate}");
      showLog("API :: Request Body :: ${jsonEncode(request.fields)} ");
      showLog("API :: Response Status :: ${res.statusCode} ");
      showLog("API :: Response Body :: ${String.fromCharCodes(responseData)} ");
      if (res.statusCode == 200) {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("Uploaded!");
        return true;
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
  }
}
