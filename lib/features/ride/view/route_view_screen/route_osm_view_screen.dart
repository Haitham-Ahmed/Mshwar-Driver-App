import 'dart:io';
import 'dart:math';
import 'package:cabme_driver/core/constant/constant.dart';
import 'package:cabme_driver/core/constant/show_toast_dialog.dart';
import 'package:cabme_driver/features/dashboard/controller/dash_board_controller.dart';
import 'package:cabme_driver/features/ride/controller/ride_details_controller.dart';
import 'package:cabme_driver/features/ride/model/driver_location_update.dart';
import 'package:cabme_driver/features/ride/model/ride_model.dart';
import 'package:cabme_driver/features/chat/view/conversation_screen.dart';
import 'package:cabme_driver/core/themes/button_them.dart';
import 'package:cabme_driver/core/themes/constant_colors.dart';
import 'package:cabme_driver/core/themes/custom_alert_dialog.dart';
import 'package:cabme_driver/core/themes/custom_dialog_box.dart';
import 'package:cabme_driver/core/utils/Preferences.dart';
import 'package:cabme_driver/core/utils/dark_theme_provider.dart';
import 'package:cabme_driver/common/widget/StarRating.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class RouteOsmViewScreen extends StatefulWidget {
  const RouteOsmViewScreen({super.key});

  @override
  State<RouteOsmViewScreen> createState() => _RouteOsmViewScreenState();
}

class _RouteOsmViewScreenState extends State<RouteOsmViewScreen> {
  dynamic argumentData = Get.arguments;

  late MapController mapController;

  Map<String, GeoPoint> markers = <String, GeoPoint>{};

  RoadInfo roadInfo = RoadInfo();

  Widget? departureIcon;
  Widget? destinationIcon;
  Widget? taxiIcon;
  Widget? stopIcon;

  GeoPoint? departureLatLong;
  GeoPoint? destinationLatLong;

  String? type;
  RideData? rideData;
  double rotation = 0.0;
  String driverEstimateArrivalTime = '';

  @override
  void initState() {
    if (argumentData != null) {
      type = argumentData['type'];
      rideData = argumentData['data'];
    }
    ShowToastDialog.showLoader("Please wait");
    mapController = MapController(
        initPosition: GeoPoint(
            latitude: double.parse(rideData!.latitudeDepart!),
            longitude: double.parse(rideData!.longitudeDepart!)));
    setIcons();

    super.initState();
  }

  @override
  void dispose() {
    ShowToastDialog.closeLoader();
    super.dispose();
  }

  getArgumentData() async {
    if (argumentData != null) {
      type = argumentData['type'];
      rideData = argumentData['data'];

      departureLatLong = GeoPoint(
          latitude: double.parse(rideData!.latitudeDepart.toString()),
          longitude: double.parse(rideData!.longitudeDepart.toString()));
      destinationLatLong = GeoPoint(
          latitude: double.parse(rideData!.latitudeArrivee.toString()),
          longitude: double.parse(rideData!.longitudeArrivee.toString()));

      // Show initial route with ride's departure coordinates
      getDirections(
        dLat: double.parse(rideData!.latitudeDepart.toString()),
        dLng: double.parse(rideData!.longitudeDepart.toString()),
      );

      if (rideData!.statut == "on ride" || rideData!.statut == 'confirmed') {
        Constant.driverLocationUpdate
            .doc(rideData!.idConducteur)
            .snapshots()
            .listen((event) async {
          DriverLocationUpdate driverLocationUpdate =
              DriverLocationUpdate.fromJson(
                  event.data() as Map<String, dynamic>);

          // Validate coordinates
          double driverLat =
              double.parse(driverLocationUpdate.driverLatitude.toString());
          double driverLng =
              double.parse(driverLocationUpdate.driverLongitude.toString());

          // Only update if coordinates are valid (not 0, 0)
          if (driverLat != 0.0 && driverLng != 0.0) {
            departureLatLong =
                GeoPoint(latitude: driverLat, longitude: driverLng);
            getDirections(dLat: driverLat, dLng: driverLng);
            setState(() {});
          } else {
            print('Skipping Firebase update: Invalid coordinates 0.0, 0.0');
          }
        });
      }
    }
  }

  setIcons() async {
    departureIcon = Image.asset(
      "assets/icons/pickup.png",
      width: 30,
      height: 30,
    );

    destinationIcon = Image.asset(
      "assets/icons/dropoff.png",
      width: 30,
      height: 30,
    );

    taxiIcon = Image.asset(
      "assets/images/ic_taxi.png",
      width: Platform.isIOS ? 30 : 40,
      height: Platform.isIOS ? 30 : 80,
      fit: BoxFit.cover,
    );

    stopIcon = Image.asset(
      "assets/icons/location.png",
      width: 30,
      height: 30,
    );
  }

  // getDriver() async {
  //   String orderId = (rideData!.idUserApp! < rideData!.idConducteur!)
  //       ? '${rideData!.idUserApp}-${rideData!.id}-${rideData!.idConducteur}'
  //       : '${rideData!.idConducteur}-${rideData!.id}-${rideData!.idUserApp}';
  //   Constant.location_update.doc(orderId).get().then((value) {
  //     dynamic driverData = value.data();

  //     driverLatLong = LatLng(
  //         double.parse(driverData['driver_latitude'].toString()),
  //         double.parse(driverData['driver_longitude'].toString()));

  //     rotation = driverData['rotation'];
  //     print('\x1b[92m --------> ${value.data()}');
  //   });
  //   // driverStream.listen((event) {
  //   //   print("--->${event.location.latitude} ${event.location.longitude}");
  //   //   setState(() => _driverModel = event);
  //   //   setState(() => MyAppState.currentUser = _driverModel);

  //   //   getDirections();
  //   //   if (_driverModel!.isActive) {
  //   //     if (_driverModel!.orderRequestData != null) {
  //   //       showDriverBottomSheet(_driverModel!);
  //   //       startTimer(_driverModel!);
  //   //     }
  //   //   }
  //   //   if (_driverModel!.inProgressOrderID != null) {
  //   //     getCurrentOrder();
  //   //   }
  //   // });
  // }

  final controllerRideDetails = Get.put(RideDetailsController());
  final controllerDashBoard = Get.put(DashBoardController());

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          OSMFlutter(
              controller: mapController,
              osmOption: OSMOption(
                userLocationMarker: UserLocationMaker(
                  directionArrowMarker: MarkerIcon(
                    iconWidget: taxiIcon,
                  ),
                  personMarker: MarkerIcon(
                    iconWidget: taxiIcon,
                  ),
                ),
                userTrackingOption: const UserTrackingOption(
                  enableTracking: true,
                  unFollowUser: false,
                ),
                zoomOption: const ZoomOption(
                  initZoom: 16,
                  minZoomLevel: 2,
                  maxZoomLevel: 19,
                  stepZoom: 1.0,
                ),
                roadConfiguration: RoadOption(
                  roadWidth: Platform.isIOS ? 50 : 10,
                  roadColor: Colors.blue,
                  roadBorderWidth: Platform.isIOS
                      ? 15
                      : 10, // Set the road border width (outline)
                  roadBorderColor: Colors.black, // Border color
                  zoomInto: true,
                ),
              ),
              onMapIsReady: (active) async {
                if (active) {
                  getArgumentData();
                  ShowToastDialog.closeLoader();
                }
              }),
          Positioned(
            top: 10,
            left: 5,
            right: 5,
            child: Row(
              children: [
                SafeArea(
                  child: InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(left: 8, top: 3, right: 8),
                      child: Icon(Icons.arrow_back_ios_outlined,
                          color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 10,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: themeChange.getThem()
                          ? AppThemeData.surface50Dark
                          : AppThemeData.surface50,
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 12),
                      child: Column(
                        children: [
                          if (rideData!.statut == 'confirmed' &&
                              driverEstimateArrivalTime.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Estimate time to reach customer : '.tr,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                  Text(
                                    driverEstimateArrivalTime,
                                    style: TextStyle(
                                        color: AppThemeData.primary200,
                                        fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(60),
                                  child: CachedNetworkImage(
                                    imageUrl: rideData!.photoPath.toString(),
                                    height: 60,
                                    width: 60,
                                    fit: BoxFit.cover,
                                    errorWidget: (context, url, error) =>
                                        Image.asset(
                                      "assets/icons/appLogo.png",
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: rideData!.rideType! == 'driver' &&
                                            rideData!.existingUserId
                                                    .toString() ==
                                                "null"
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  '${rideData!.userInfo!.name}',
                                                  style: TextStyle(
                                                    color: themeChange.getThem()
                                                        ? AppThemeData
                                                            .grey900Dark
                                                        : AppThemeData.grey900,
                                                    fontSize: 16,
                                                    fontFamily:
                                                        AppThemeData.semiBold,
                                                  )),
                                              Text(
                                                  '${rideData!.userInfo!.email}',
                                                  style: TextStyle(
                                                    color: themeChange.getThem()
                                                        ? AppThemeData
                                                            .grey900Dark
                                                        : AppThemeData.grey900,
                                                    fontSize: 14,
                                                    fontFamily:
                                                        AppThemeData.regular,
                                                  )),
                                            ],
                                          )
                                        : Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  '${rideData!.prenom.toString()} ${rideData!.nom.toString()}',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color:
                                                          themeChange.getThem()
                                                              ? AppThemeData
                                                                  .grey900Dark
                                                              : AppThemeData
                                                                  .grey900,
                                                      fontFamily:
                                                          AppThemeData.medium)),
                                              StarRating(
                                                  size: 18,
                                                  rating: double.parse(rideData!
                                                      .moyenneDriver
                                                      .toString()),
                                                  color: AppThemeData.error100),
                                            ],
                                          ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      children: [
                                        Visibility(
                                          visible:
                                              rideData!.statut == "confirmed" &&
                                                      rideData!.existingUserId
                                                              .toString() !=
                                                          "null"
                                                  ? true
                                                  : false,
                                          child: InkWell(
                                              onTap: () {
                                                Get.to(ConversationScreen(),
                                                    arguments: {
                                                      'receiverId': int.parse(
                                                          rideData!.idUserApp
                                                              .toString()),
                                                      'orderId': int.parse(
                                                          rideData!.id
                                                              .toString()),
                                                      'receiverName':
                                                          '${rideData!.prenom} ${rideData!.nom}',
                                                      'receiverPhoto':
                                                          rideData!.photoPath
                                                    });
                                              },
                                              child: Image.asset(
                                                'assets/icons/chat_icon.png',
                                                height: 40,
                                                width: 40,
                                                fit: BoxFit.cover,
                                              )),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10, right: 10),
                                          child: InkWell(
                                              onTap: () {
                                                if (rideData!.existingUserId
                                                        .toString() !=
                                                    "null") {
                                                  Constant.makePhoneCall(
                                                      rideData!.phone
                                                          .toString());
                                                } else {
                                                  Constant.makePhoneCall(
                                                      rideData!.userInfo!.phone
                                                          .toString());
                                                }
                                              },
                                              child: Container(
                                                height: 40,
                                                width: 40,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 10),
                                                decoration: BoxDecoration(
                                                  color:
                                                      AppThemeData.primary200,
                                                  borderRadius:
                                                      BorderRadius.circular(40),
                                                ),
                                                child: Icon(
                                                  Icons.phone,
                                                  size: 20,
                                                  color: themeChange.getThem()
                                                      ? AppThemeData
                                                          .surface50Dark
                                                      : AppThemeData.surface50,
                                                ),
                                              )),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                        padding:
                                            const EdgeInsets.only(top: 5.0),
                                        child: Text(
                                          rideData!.dateRetour.toString(),
                                        )),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Visibility(
                        visible: rideData!.statut == "new" ||
                                rideData!.statut == "confirmed"
                            ? true
                            : false,
                        child: Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: ButtonThem.buildBorderButton(
                              context,
                              title: 'REJECT'.tr,
                              btnHeight: 45,
                              btnWidthRatio: 0.8,
                              btnColor: Colors.white,
                              txtColor: Colors.black.withOpacity(0.60),
                              btnBorderColor: Colors.black.withOpacity(0.20),
                              onPress: () async {
                                buildShowBottomSheet(context);
                              },
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: rideData!.statut == "new" ? true : false,
                        child: Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 5, left: 10),
                            child: ButtonThem.buildButton(
                              context,
                              title: 'ACCEPT'.tr,
                              btnHeight: 45,
                              btnWidthRatio: 0.8,
                              btnColor: AppThemeData.primary200,
                              txtColor: Colors.black,
                              onPress: () async {
                                showDialog(
                                  barrierColor: Colors.black26,
                                  context: context,
                                  builder: (context) {
                                    return CustomAlertDialog(
                                      title:
                                          "Do you want to confirm this booking?"
                                              .tr,
                                      onPressNegative: () {
                                        Get.back();
                                      },
                                      negativeButtonText: 'No'.tr,
                                      positiveButtonText: 'Yes'.tr,
                                      onPressPositive: () {
                                        Map<String, String> bodyParams = {
                                          'id_ride': rideData!.id.toString(),
                                          'id_user':
                                              rideData!.idUserApp.toString(),
                                          'driver_name':
                                              '${rideData!.prenomConducteur.toString()} ${rideData!.nomConducteur.toString()}',
                                          'lat_conducteur': rideData!
                                              .latitudeDepart
                                              .toString(),
                                          'lng_conducteur': rideData!
                                              .longitudeDepart
                                              .toString(),
                                          'lat_client': rideData!
                                              .latitudeArrivee
                                              .toString(),
                                          'lng_client': rideData!
                                              .longitudeArrivee
                                              .toString(),
                                          'from_id': Preferences.getInt(
                                                  Preferences.userId)
                                              .toString(),
                                        };

                                        controllerRideDetails
                                            .confirmedRide(bodyParams)
                                            .then((value) {
                                          if (value != null) {
                                            rideData!.statut = "confirmed";
                                            Get.back();
                                            showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return CustomDialogBox(
                                                    title:
                                                        "Confirmed Successfully"
                                                            .tr,
                                                    descriptions:
                                                        "Ride Successfully confirmed."
                                                            .tr,
                                                    text: "Ok".tr,
                                                    onPress: () {
                                                      Get.back();
                                                      Get.back();
                                                    },
                                                    img: Image.asset(
                                                        'assets/images/green_checked.png'),
                                                  );
                                                });
                                          }
                                        });
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: rideData!.statut == "confirmed" ? true : false,
                        child: Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 5, left: 10),
                            child: ButtonThem.buildButton(
                              context,
                              title: 'On Ride'.tr,
                              btnHeight: 45,
                              btnWidthRatio: 0.8,
                              btnColor: AppThemeData.primary200,
                              txtColor: Colors.black,
                              onPress: () async {
                                showDialog(
                                  barrierColor: Colors.black26,
                                  context: context,
                                  builder: (context) {
                                    return CustomAlertDialog(
                                      title: "Do you want to on ride this ride?"
                                          .tr,
                                      negativeButtonText: 'No'.tr,
                                      positiveButtonText: 'Yes'.tr,
                                      onPressNegative: () {
                                        Get.back();
                                      },
                                      onPressPositive: () {
                                        Get.back();
                                        if (Constant.rideOtp.toString() !=
                                                'yes' ||
                                            rideData!.rideType! == 'driver') {
                                          Map<String, String> bodyParams = {
                                            'id_ride': rideData!.id.toString(),
                                            'id_user':
                                                rideData!.idUserApp.toString(),
                                            'use_name':
                                                '${rideData!.prenomConducteur.toString()} ${rideData!.nomConducteur.toString()}',
                                            'from_id': Preferences.getInt(
                                                    Preferences.userId)
                                                .toString(),
                                          };
                                          controllerRideDetails
                                              .setOnRideRequest(bodyParams)
                                              .then((value) {
                                            if (value != null) {
                                              Get.back();
                                              showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return CustomDialogBox(
                                                      title:
                                                          "On ride Successfully"
                                                              .tr,
                                                      descriptions:
                                                          "Ride Successfully On ride."
                                                              .tr,
                                                      text: "Ok".tr,
                                                      onPress: () {
                                                        Get.back();
                                                        Get.back();
                                                      },
                                                      img: Image.asset(
                                                          'assets/images/green_checked.png'),
                                                    );
                                                  });
                                            }
                                          });
                                        } else {
                                          controllerRideDetails.otpController =
                                              TextEditingController();
                                          showDialog(
                                            barrierColor: Colors.black26,
                                            context: context,
                                            builder: (context) {
                                              return Dialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                elevation: 0,
                                                backgroundColor:
                                                    Colors.transparent,
                                                child: Container(
                                                  height: 200,
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10,
                                                          top: 20,
                                                          right: 10,
                                                          bottom: 20),
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.rectangle,
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                      boxShadow: const [
                                                        BoxShadow(
                                                            color: Colors.black,
                                                            offset:
                                                                Offset(0, 10),
                                                            blurRadius: 10),
                                                      ]),
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        "Enter OTP".tr,
                                                        style: TextStyle(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.60)),
                                                      ),
                                                      Pinput(
                                                        controller:
                                                            controllerRideDetails
                                                                .otpController,
                                                        defaultPinTheme:
                                                            PinTheme(
                                                          height: 50,
                                                          width: 50,
                                                          textStyle:
                                                              const TextStyle(
                                                                  letterSpacing:
                                                                      0.60,
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                          // margin: EdgeInsets.all(10),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            shape: BoxShape
                                                                .rectangle,
                                                            color: Colors.white,
                                                            border: Border.all(
                                                                color: ConstantColors
                                                                    .textFieldBoarderColor,
                                                                width: 0.7),
                                                          ),
                                                        ),
                                                        keyboardType:
                                                            TextInputType.phone,
                                                        textInputAction:
                                                            TextInputAction
                                                                .done,
                                                        length: 6,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: ButtonThem
                                                                .buildButton(
                                                              context,
                                                              title: 'done'.tr,
                                                              btnHeight: 45,
                                                              btnWidthRatio:
                                                                  0.8,
                                                              btnColor:
                                                                  AppThemeData
                                                                      .primary200,
                                                              txtColor:
                                                                  Colors.white,
                                                              onPress: () {
                                                                if (controllerRideDetails
                                                                        .otpController
                                                                        .text
                                                                        .toString()
                                                                        .length ==
                                                                    6) {
                                                                  controllerRideDetails
                                                                      .verifyOTP(
                                                                    userId: rideData!
                                                                        .idUserApp!
                                                                        .toString(),
                                                                    rideId: rideData!
                                                                        .id!
                                                                        .toString(),
                                                                  )
                                                                      .then(
                                                                          (value) {
                                                                    if (value !=
                                                                            null &&
                                                                        value['success'] ==
                                                                            "success") {
                                                                      Map<String,
                                                                              String>
                                                                          bodyParams =
                                                                          {
                                                                        'id_ride': rideData!
                                                                            .id
                                                                            .toString(),
                                                                        'id_user': rideData!
                                                                            .idUserApp
                                                                            .toString(),
                                                                        'use_name':
                                                                            '${rideData!.prenomConducteur.toString()} ${rideData!.nomConducteur.toString()}',
                                                                        'from_id':
                                                                            Preferences.getInt(Preferences.userId).toString(),
                                                                      };
                                                                      controllerRideDetails
                                                                          .setOnRideRequest(
                                                                              bodyParams)
                                                                          .then(
                                                                              (value) {
                                                                        if (value !=
                                                                            null) {
                                                                          Get.back();
                                                                          showDialog(
                                                                              context: context,
                                                                              builder: (BuildContext context) {
                                                                                return CustomDialogBox(
                                                                                  title: "On ride Successfully".tr,
                                                                                  descriptions: "Ride Successfully On ride.".tr,
                                                                                  text: "Ok".tr,
                                                                                  onPress: () {
                                                                                    Get.back();
                                                                                    Get.back();
                                                                                  },
                                                                                  img: Image.asset('assets/images/green_checked.png'),
                                                                                );
                                                                              });
                                                                        }
                                                                      });
                                                                    }
                                                                  });
                                                                } else {
                                                                  ShowToastDialog
                                                                      .showToast(
                                                                          'Please Enter OTP');
                                                                }
                                                              },
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 8,
                                                          ),
                                                          Expanded(
                                                            child: ButtonThem
                                                                .buildBorderButton(
                                                              context,
                                                              title:
                                                                  'cancel'.tr,
                                                              btnHeight: 45,
                                                              btnWidthRatio:
                                                                  0.8,
                                                              btnColor:
                                                                  Colors.white,
                                                              txtColor: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                      0.60),
                                                              btnBorderColor:
                                                                  Colors
                                                                      .black
                                                                      .withOpacity(
                                                                          0.20),
                                                              onPress: () {
                                                                Get.back();
                                                              },
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        }
                                        // if (rideData!.carDriverConfirmed == 1) {
                                        //
                                        // } else if (rideData!.carDriverConfirmed == 2) {
                                        //   Get.back();
                                        //   ShowToastDialog.showToast("Customer decline the confirmation of driver and car information.");
                                        // } else if (rideData!.carDriverConfirmed == 0) {
                                        //   Get.back();
                                        //   ShowToastDialog.showToast("Customer needs to verify driver and car before you can start trip.");
                                        // }
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: rideData!.statut == "on ride" ? true : false,
                        child: Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: ButtonThem.buildBorderButton(
                              context,
                              title: 'START RIDE'.tr,
                              btnHeight: 45,
                              btnWidthRatio: 0.8,
                              btnColor: Colors.white,
                              txtColor: Colors.black.withOpacity(0.60),
                              btnBorderColor: Colors.black.withOpacity(0.20),
                              onPress: () async {
                                // Focus on the destination in the in-app map
                                try {
                                  if (destinationLatLong != null &&
                                      departureLatLong != null) {
                                    print(
                                        'Current: ${departureLatLong!.latitude}, ${departureLatLong!.longitude}');
                                    print(
                                        'Destination: ${destinationLatLong!.latitude}, ${destinationLatLong!.longitude}');

                                    // Validate coordinates
                                    if (destinationLatLong!.latitude != 0 &&
                                        destinationLatLong!.longitude != 0) {
                                      // Calculate proper bounds
                                      double north =
                                          departureLatLong!.latitude >
                                                  destinationLatLong!.latitude
                                              ? departureLatLong!.latitude
                                              : destinationLatLong!.latitude;
                                      double south =
                                          departureLatLong!.latitude <
                                                  destinationLatLong!.latitude
                                              ? departureLatLong!.latitude
                                              : destinationLatLong!.latitude;
                                      double east =
                                          departureLatLong!.longitude >
                                                  destinationLatLong!.longitude
                                              ? departureLatLong!.longitude
                                              : destinationLatLong!.longitude;
                                      double west =
                                          departureLatLong!.longitude <
                                                  destinationLatLong!.longitude
                                              ? departureLatLong!.longitude
                                              : destinationLatLong!.longitude;

                                      // Add padding
                                      double latPadding = (north - south) * 0.1;
                                      double lngPadding = (east - west) * 0.1;

                                      await mapController.zoomToBoundingBox(
                                        BoundingBox(
                                          north: north + latPadding,
                                          south: south - latPadding,
                                          east: east + lngPadding,
                                          west: west - lngPadding,
                                        ),
                                        paddinInPixel: 50,
                                      );
                                      ShowToastDialog.showToast(
                                          'Following route to destination');
                                    } else {
                                      // Fallback to destination
                                      await mapController
                                          .goToLocation(destinationLatLong!);
                                      await mapController.setZoom(
                                          zoomLevel: 14);
                                      ShowToastDialog.showToast(
                                          'Showing destination');
                                    }
                                  }
                                } catch (e) {
                                  print('Error updating map view: $e');
                                  // Fallback
                                  try {
                                    if (destinationLatLong != null) {
                                      await mapController
                                          .goToLocation(destinationLatLong!);
                                      await mapController.setZoom(
                                          zoomLevel: 14);
                                    }
                                  } catch (e2) {
                                    print('Fallback failed: $e2');
                                  }
                                  ShowToastDialog.showToast('Route displayed');
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: rideData!.statut == "on ride" ? true : false,
                        child: Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 5, left: 10),
                            child: ButtonThem.buildButton(
                              context,
                              title: 'COMPLETE'.tr,
                              btnHeight: 45,
                              btnWidthRatio: 0.8,
                              btnColor: AppThemeData.primary200,
                              txtColor: Colors.black,
                              onPress: () async {
                                showDialog(
                                  barrierColor: Colors.black26,
                                  context: context,
                                  builder: (context) {
                                    return CustomAlertDialog(
                                      title:
                                          "Do you want to complete this ride?"
                                              .tr,
                                      onPressNegative: () {
                                        Get.back();
                                      },
                                      negativeButtonText: 'No'.tr,
                                      positiveButtonText: 'Yes'.tr,
                                      onPressPositive: () {
                                        Map<String, String> bodyParams = {
                                          'id_ride': rideData!.id.toString(),
                                          'id_user':
                                              rideData!.idUserApp.toString(),
                                          'driver_name':
                                              '${rideData!.prenomConducteur.toString()} ${rideData!.nomConducteur.toString()}',
                                          'from_id': Preferences.getInt(
                                                  Preferences.userId)
                                              .toString(),
                                        };
                                        controllerRideDetails
                                            .setCompletedRequest(
                                                bodyParams, rideData!)
                                            .then((value) {
                                          if (value != null) {
                                            Get.back();
                                            showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return CustomDialogBox(
                                                    title:
                                                        "Completed Successfully"
                                                            .tr,
                                                    descriptions:
                                                        "Ride Successfully completed."
                                                            .tr,
                                                    text: "Ok".tr,
                                                    onPress: () {
                                                      Get.back();
                                                      Get.back();
                                                    },
                                                    img: Image.asset(
                                                        'assets/images/green_checked.png'),
                                                  );
                                                });
                                          }
                                        });
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  final resonController = TextEditingController();

  buildShowBottomSheet(BuildContext context) {
    return showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(15), topLeft: Radius.circular(15))),
        context: context,
        isDismissible: true,
        isScrollControlled: true,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
              child: Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        "Cancel Trip".tr,
                        style:
                            const TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        "Write a reason for trip cancellation".tr,
                        style: TextStyle(color: Colors.black.withOpacity(0.50)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: TextField(
                        controller: resonController,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1.0),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: ButtonThem.buildButton(
                                context,
                                title: 'Cancel Trip'.tr,
                                btnHeight: 45,
                                btnWidthRatio: 0.8,
                                btnColor: AppThemeData.primary200,
                                txtColor: Colors.white,
                                onPress: () async {
                                  if (resonController.text.isNotEmpty) {
                                    Get.back();
                                    showDialog(
                                      barrierColor: Colors.black26,
                                      context: context,
                                      builder: (context) {
                                        return CustomAlertDialog(
                                          title:
                                              "Do you want to reject this booking?"
                                                  .tr,
                                          onPressNegative: () {
                                            Get.back();
                                          },
                                          negativeButtonText: 'No'.tr,
                                          positiveButtonText: 'Yes'.tr,
                                          onPressPositive: () {
                                            Map<String, String> bodyParams = {
                                              'id_ride':
                                                  rideData!.id.toString(),
                                              'id_user': rideData!.idUserApp
                                                  .toString(),
                                              'name':
                                                  '${rideData!.prenomConducteur.toString()} ${rideData!.nomConducteur.toString()}',
                                              'from_id': Preferences.getInt(
                                                      Preferences.userId)
                                                  .toString(),
                                              'user_cat': controllerRideDetails
                                                  .userModel!.userData!.userCat
                                                  .toString(),
                                              'reason': resonController.text
                                                  .toString(),
                                            };
                                            controllerRideDetails
                                                .canceledRide(bodyParams)
                                                .then((value) {
                                              Get.back();
                                              if (value != null) {
                                                showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return CustomDialogBox(
                                                        title:
                                                            "Reject Successfully"
                                                                .tr,
                                                        descriptions:
                                                            "Ride Successfully rejected."
                                                                .tr,
                                                        text: "Ok".tr,
                                                        onPress: () {
                                                          Get.back();
                                                          Get.back();
                                                        },
                                                        img: Image.asset(
                                                            'assets/images/green_checked.png'),
                                                      );
                                                    });
                                              }
                                            });
                                          },
                                        );
                                      },
                                    );
                                  } else {
                                    ShowToastDialog.showToast(
                                        "Please enter a reason");
                                  }
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 5, left: 10),
                              child: ButtonThem.buildBorderButton(
                                context,
                                title: 'Close'.tr,
                                btnHeight: 45,
                                btnWidthRatio: 0.8,
                                btnColor: Colors.white,
                                txtColor: AppThemeData.primary200,
                                btnBorderColor: AppThemeData.primary200,
                                onPress: () async {
                                  Get.back();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          });
        });
  }

  getDirections({required double dLat, required double dLng}) async {
    List<GeoPoint> wayPointList = [];
    for (var i = 0; i < rideData!.stops!.length; i++) {
      wayPointList.add(
        GeoPoint(
            latitude: double.parse(rideData!.stops![i].latitude.toString()),
            longitude: double.parse(
              rideData!.stops![i].longitude.toString(),
            )),
      );
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (markers.containsKey('Departure')) {
        await mapController.removeMarker(markers['Departure']!);
      }
      await mapController
          .addMarker(
              GeoPoint(
                latitude: double.parse(rideData!.latitudeDepart.toString()),
                longitude: double.parse(rideData!.longitudeDepart.toString()),
              ),
              markerIcon: MarkerIcon(iconWidget: departureIcon),
              angle: pi / 3,
              iconAnchor: IconAnchor(
                anchor: Anchor.top,
              ))
          .then((v) {
        markers['Departure'] = GeoPoint(
          latitude: double.parse(rideData!.latitudeDepart.toString()),
          longitude: double.parse(rideData!.longitudeDepart.toString()),
        );
      });

      if (markers.containsKey('Destination')) {
        await mapController.removeMarker(markers['Destination']!);
      }
      await mapController
          .addMarker(destinationLatLong!,
              markerIcon: MarkerIcon(iconWidget: destinationIcon),
              angle: pi / 3,
              iconAnchor: IconAnchor(
                anchor: Anchor.top,
              ))
          .then((v) {
        markers['Destination'] = destinationLatLong!;
      });

      for (var i = 0; i < rideData!.stops!.length; i++) {
        if (markers.containsKey('${rideData!.stops![i]}')) {
          await mapController.removeMarker(markers['${rideData!.stops![i]}']!);
        }
        await mapController
            .addMarker(
                GeoPoint(
                  latitude: double.parse(rideData!.stops![i].latitude!),
                  longitude: double.parse(rideData!.stops![i].longitude!),
                ),
                markerIcon: MarkerIcon(iconWidget: stopIcon),
                angle: pi / 3,
                iconAnchor: IconAnchor(
                  anchor: Anchor.top,
                ))
            .then((v) {
          markers['${rideData!.stops![i]}'] = GeoPoint(
            latitude: double.parse(rideData!.stops![i].latitude!),
            longitude: double.parse(rideData!.stops![i].longitude!),
          );
        });
      }
      print('rideData!.statut :: ${rideData!.statut}');
      if (rideData!.statut == "confirmed") {
        drawRoad(
            wayPointList: [],
            startPoint: GeoPoint(latitude: dLat, longitude: dLng),
            lastPoint: GeoPoint(
              latitude: departureLatLong!.latitude,
              longitude: destinationLatLong!.longitude,
            ));
      } else if (rideData!.statut == "on ride") {
        drawRoad(
          wayPointList: wayPointList,
          startPoint: GeoPoint(latitude: dLat, longitude: dLng),
          lastPoint: GeoPoint(
            latitude: destinationLatLong!.latitude,
            longitude: destinationLatLong!.longitude,
          ),
        );
      } else {
        drawRoad(
          wayPointList: wayPointList,
          startPoint: GeoPoint(
            latitude: departureLatLong!.latitude,
            longitude: departureLatLong!.longitude,
          ),
          lastPoint: GeoPoint(
            latitude: destinationLatLong!.latitude,
            longitude: destinationLatLong!.longitude,
          ),
        );
      }
    });
  }

  drawRoad(
      {required List<GeoPoint> wayPointList,
      required GeoPoint startPoint,
      required GeoPoint lastPoint}) async {
    await mapController.removeLastRoad();
    roadInfo = await mapController.drawRoad(
      startPoint,
      lastPoint,
      roadType: RoadType.car,
      intersectPoint: [...wayPointList],
      roadOption: RoadOption(
        roadWidth: Platform.isIOS ? 50 : 10,
        roadColor: Colors.blue,
        roadBorderWidth:
            Platform.isIOS ? 15 : 10, // Set the road border width (outline)
        roadBorderColor: Colors.black, // Border color
        zoomInto: true,
      ),
    );
    int hours = (roadInfo.duration! ~/ 3600);
    int minutes = ((roadInfo.duration! % 3600) / 60).round();
    setState(() {
      driverEstimateArrivalTime = '$hours hours $minutes minutes';
    });
  }

  // Future<void> updateCameraLocation(
  //   LatLng source,
  //   GoogleMapController? mapController,
  // ) async {
  //   mapController!.animateCamera(
  //     CameraUpdate.newCameraPosition(
  //       CameraPosition(
  //         target: source,
  //         zoom: rideData!.statut == "on ride" || rideData!.statut == "confirmed" ? 20 : 16,
  //       ),
  //     ),
  //   );
  // }
}
