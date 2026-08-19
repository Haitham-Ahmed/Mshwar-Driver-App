import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class ShowToastDialog {
  static showToast(String? message, {EasyLoadingToastPosition position = EasyLoadingToastPosition.top}) {
    EasyLoading.showToast(message!.tr, toastPosition: position);
  }

  static showLoader(String message) {
    EasyLoading.show(
      status: message.tr,
      dismissOnTap: false,
      maskType: EasyLoadingMaskType.clear,
    );
  }

  static showBlackLoader(String message) {
    EasyLoading.show(
      status: message.tr,
      maskType: EasyLoadingMaskType.black,
    );
  }

  static closeLoader() {
    EasyLoading.dismiss();
  }
}
