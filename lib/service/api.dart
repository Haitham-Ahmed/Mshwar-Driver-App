import 'dart:io';

import 'package:cabme_driver/core/utils/Preferences.dart';

class API {
  // ============ LOCAL DEVELOPMENT (COMMENTED) ============
  // For iOS Simulator: use http://localhost or http://127.0.0.1
  // For Android Emulator: use http://10.0.2.2 (special IP to access host machine)
  // For Physical Device: use your computer's local IP (e.g., http://192.168.1.100)
  // static String get _baseServerUrl {
  //   // iOS Simulator uses localhost (same network stack as Mac)
  //   if (Platform.isIOS) {
  //     return "http://127.0.0.1:8000";
  //   }
  //   // Android Emulator uses special IP to access host machine
  //   return "http://10.0.2.2:8000";
  // }
  // static const apiKey = "base64:s/Dkb2SuqpA8n33wB7WktW6qqhNlc2s8Gi5rsu551UA=";

  // ============ TESTING SERVER (COMMENTED) ============
  // static const String _baseServerUrl = "http://93.127.202.7";
  // static const apiKey = "base64:s/Dkb2SuqpA8n33wB7WktW6qqhNlc2s8Gi5rsu551UA=";

  // ============ LIVE SERVER ============
  static const String _baseServerUrl = "https://mshwar-app.com";
  static const apiKey = "base64:Npu3FfBZFo1sxlY/LBzHY/VwL59xbfNoCJUZzCkYtKY=";

  // Base URL for API v1 endpoints
  static String get baseUrl => "$_baseServerUrl/api/v1/";

  // Base URL for API endpoints (non-v1)
  static String get baseApiUrl => "$_baseServerUrl/api/";

  static Map<String, String> authheader = {
    HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
    'apikey': apiKey,
  };
  static Map<String, String> header = {
    HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
    'apikey': apiKey,
    'accesstoken': Preferences.getString(Preferences.accesstoken)
  };
  static String getCommissionUrl({required driverId}) {
    return "$baseApiUrl/calculate-commission/$driverId";
  }

  static String get notifyUser => "$baseApiUrl/driver/arrived";
  static String get userSignUP => "${baseUrl}user";
  static String get userLogin => "${baseUrl}user-login";
  static String get sendOtp => "${baseUrl}send-otp";
  static String get verifyOtp => "${baseUrl}verify-otp";
  static String get resendOtp => "${baseUrl}resend-otp";
  static String get getProfileByPhone => "${baseUrl}profilebyphone";
  static String get getExistingUserOrNot => "${baseUrl}existing-user";
  static String get sendResetPasswordOtp => "${baseUrl}reset-password-otp";
  static String get getCustomer => "${baseUrl}users";

  static String get resetPasswordOtp => "${baseUrl}resert-password";

  static String get updatePreName => "${baseUrl}user-pre-name";
  static String get updateLastName => "${baseUrl}user-name";

  static String get updateLocation => "${baseUrl}update-position";
  static String get contactUs => "${baseUrl}contact-us";
  static String get changeStatus => "${baseUrl}change-status";
  static String get updateToken => "${baseUrl}update-fcm";
  static String get feelSafeAtDestination => "${baseUrl}feel-safe";
  static String get conformPaymentByCash => "${baseUrl}payment-by-cash";
  static String get getFcmToken => "${baseUrl}fcm-token";
  static String get getRideReview => "${baseUrl}get-ride-review";

  static String get userUpdateProfile => "${baseUrl}update-user-photo";
  static String get documentList => "${baseUrl}documents";
  static String get getDriverUploadedDocument => "${baseUrl}driver-documents";
  static String get driverDocumentAdd => "${baseUrl}driver-documents-add";
  static String get driverDocumentUpdate => "${baseUrl}driver-documents-update";

  static String get conformRide => "${baseUrl}confirm-requete";
  static String get rejectRide => "${baseUrl}set-rejected-requete";

  static String get updateUserName => "${baseUrl}user-name";
  static String get updateUserPhone => "${baseUrl}user-phone";
  static String get updateUserEmail => "${baseUrl}update-user-email";
  static String get changePassword => "${baseUrl}update-user-mdp";
  static String get walletHistory => "${baseUrl}wallet-history";

  static String get userLicence => "${baseUrl}update-user-licence";
  static String get userRoadWorthyDoc => "${baseUrl}update-user-roadworthy";
  static String get userCarServiceBook => "${baseUrl}update-user-carservice";
  static String getCarServiceBook(String driverId) =>
      "${baseUrl}car-service-book?id_driver=$driverId";

  static String get bookRides => "${baseUrl}requete-register";
  static String get onRideRequest => "${baseUrl}onride-requete";
  static String get getConformRide => "${baseUrl}requete-confirm";
  static String get getOnRide => "${baseUrl}requete-onride";
  static String get getCompletedRide => "${baseUrl}requete-complete";
  static String get setCompleteRequest => "${baseUrl}complete-requete";
  static String get getRejectRequest => "${baseUrl}requete-reject";

  static String getVehicleData(String driverId) =>
      "${baseUrl}vehicle-driver?id_driver=$driverId";

  static String get uploadCarServiceBook => "${baseUrl}car-service";

  static String get updateVBrand => "${baseUrl}update-vehicle-brand";

  static String get updateVColors => "${baseUrl}update-vehicle-color";
  static String get updateVNoPlate => "${baseUrl}update-vehicle-numberplate";
  static String get updateVModel => "${baseUrl}update-vehicle-model";
  static String get categoryVModel => "${baseUrl}update-Vehicle-category";
  static String get zoneUpdate => "${baseUrl}zone-update";

  static String get vehicleRegister => "${baseUrl}vehicle";
  static String get vehicleCategory => "${baseUrl}Vehicle-category";

  static String get driverAllRides => "${baseUrl}driver-all-rides";
  static String get rejectbtnRides => "${baseUrl}show-hide-reject";
  static String get newRide => "${baseUrl}requete";
  static String get brand => "${baseUrl}brand";
  static String get model => "${baseUrl}model";
  static String get getZone => "${baseUrl}zone";
  static String get bankDetails => "${baseUrl}bank-details";
  static String get addBankDetails => "${baseUrl}add-bank-details";
  static String get withdrawalsRequest => "${baseUrl}withdrawals";
  static String get withdrawalsList => "${baseUrl}withdrawals-list";

  static String get addReview => "${baseUrl}user-note";
  static String get addComplaint => "${baseUrl}complaints";
  static String get getComplaint => "${baseUrl}complaintsList";

  static String get getLanguage => "${baseUrl}language";
  static String deleteUser(String userId) =>
      "${baseUrl}user-delete?user_id=$userId";
  static String get settings => "${baseUrl}settings";
  static String get privacyPolicy => "${baseUrl}privacy-policy";
  static String get termsOfCondition => "${baseUrl}terms-of-condition";
  static String get rideOtpVerify => "${baseUrl}otp_verify";
  static String get reGenerateOtp => "${baseUrl}otp";

  static String get rideDetails => "${baseUrl}ridedetails";

  static String get getPaymentMethod => "${baseUrl}payment-method";
  static String get amount => "${baseUrl}amount";
  static String get paymentSetting => "${baseUrl}payment-settings";
  static String get payRequestCash => "${baseUrl}payment-by-cash";

  static String get driverDetails => "${baseUrl}driver";

  //Parcel Service
  static String get parcelContirm => "${baseUrl}parcel-confirm";
  static String get parcelOnride => "${baseUrl}parcel-onride";
  static String get parcelComplete => "${baseUrl}parcel-complete";
  static String get parcelRejected => "${baseUrl}parcel-rejected";
  static String get parcelSearch => "${baseUrl}search-driver-parcel-order";
  static String get getDriverParcel => "${baseUrl}get-driver-parcel-orders";
  static String get getParcelDetails => "${baseUrl}get-parcel-detail";

  // Broadcast Notifications
  static String get getBroadcastNotifications => "${baseUrl}broadcast-driver";

  /* Professional Notification System */
  static String getNotifications({int? limit, int? offset, bool? unreadOnly}) {
    String url = "${baseUrl}notifications/?user_type=driver";
    if (limit != null) url += "&limit=$limit";
    if (offset != null) url += "&offset=$offset";
    if (unreadOnly == true) url += "&unread_only=true";
    return url;
  }

  static String getUnreadCount() =>
      "${baseUrl}notifications/unread-count?user_type=driver";
  static String markAsRead(int id) =>
      "${baseUrl}notifications/$id/read?user_type=driver";
  static String markAllAsRead() =>
      "${baseUrl}notifications/read-all?user_type=driver";
  static String deleteNotification(int id) =>
      "${baseUrl}notifications/$id?user_type=driver";
  static String deleteAllNotifications() =>
      "${baseUrl}notifications/?user_type=driver";
}
