import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cabme_driver/core/constant/constant.dart';
import 'package:cabme_driver/core/constant/show_toast_dialog.dart';
import 'package:cabme_driver/features/dashboard/controller/dash_board_controller.dart';
import 'package:cabme_driver/features/ride/controller/ride_details_controller.dart';
import 'package:cabme_driver/features/ride/model/driver_location_update.dart';
import 'package:cabme_driver/features/ride/model/ride_model.dart';
import 'package:cabme_driver/features/chat/view/conversation_screen.dart';
import 'package:cabme_driver/core/themes/constant_colors.dart';
import 'package:cabme_driver/core/themes/responsive.dart';
import 'package:cabme_driver/common/widget/button.dart';
import 'package:cabme_driver/core/themes/custom_alert_dialog.dart';
import 'package:cabme_driver/core/themes/custom_dialog_box.dart';
import 'package:cabme_driver/core/utils/Preferences.dart';
import 'package:cabme_driver/core/utils/dark_theme_provider.dart';
import 'package:cabme_driver/common/widget/StarRating.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

import 'package:cabme_driver/core/constant/logdata.dart';
import 'package:cabme_driver/features/authentication/model/user_model.dart';
import 'package:cabme_driver/service/api.dart';

class RouteViewScreen extends StatefulWidget {
  const RouteViewScreen({super.key});

  @override
  State<RouteViewScreen> createState() => _RouteViewScreenState();
}

class _RouteViewScreenState extends State<RouteViewScreen> {
  dynamic argumentData = Get.arguments;

  GoogleMapController? _mapcontroller;

  Map<PolylineId, Polyline> polyLines = {};

  PolylinePoints polylinePoints = PolylinePoints();

  BitmapDescriptor? departureIcon;
  BitmapDescriptor? destinationIcon;
  BitmapDescriptor? taxiIcon;
  BitmapDescriptor? stopIcon;

  late LatLng departureLatLong;
  late LatLng destinationLatLong;

  final Map<String, Marker> _markers = {};

  String? type;
  RideData? rideData;
  double rotation = 0.0;
  String driverEstimateArrivalTime = '';

  // Add StreamSubscription to manage Firebase listener
  StreamSubscription? _driverLocationSubscription;
  StreamSubscription? _locationSubscription; // For updating driver location

  // Add flag to control navigation mode
  bool isNavigationMode = false;
  bool isTrackingDriver = true;

  // Navigation instructions
  String currentInstruction = "";
  String nextInstruction = "";
  String distanceToNextStep = "";
  String durationToNextStep = "";
  List<dynamic> routeSteps = [];
  int currentStepIndex = 0;

  // Navigation states
  String navigationPhase =
      "heading_to_pickup"; // heading_to_pickup, at_pickup, heading_to_destination, at_destination

  @override
  void initState() {
    getArgumentData();
    setIcons();

    super.initState();
  }

  @override
  void dispose() {
    // Cancel all subscriptions when widget is disposed
    _driverLocationSubscription?.cancel();
    _locationSubscription?.cancel();
    _mapcontroller?.dispose();
    super.dispose();
  }

  getArgumentData() async {
    if (argumentData != null) {
      type = argumentData['type'];
      rideData = argumentData['data'];

      departureLatLong = LatLng(
          double.parse(rideData!.latitudeDepart.toString()),
          double.parse(rideData!.longitudeDepart.toString()));
      destinationLatLong = LatLng(
          double.parse(rideData!.latitudeArrivee.toString()),
          double.parse(rideData!.longitudeArrivee.toString()));

      // The route must always start at the driver's real position.  Before the
      // ride starts its destination is the pickup point; once it starts it is
      // the passenger's final destination (see getDirections below).
      _showRouteFromCurrentLocation();

      // Set up the appropriate listener based on status (will update with real-time location)
      _setupDriverLocationListener();

      // Start actively updating driver's location to Firebase
      _startUpdatingLocationToFirebase();
    }
  }

  /// Gets one immediate GPS fix so the first route is not drawn from the
  /// pickup location. Firebase updates continue to keep it current afterwards.
  Future<void> _showRouteFromCurrentLocation() async {
    try {
      final location = await Location().getLocation();
      if (location.latitude == null || location.longitude == null) return;

      _updateDriverPosition(
        latitude: location.latitude!,
        longitude: location.longitude!,
        heading: location.heading ?? 0.0,
      );
    } catch (error) {
      // A later Firebase/GPS update will draw the route if an immediate fix is
      // unavailable (for example while the location permission is resolving).
      print('Unable to get current driver location: $error');
    }
  }

  void _updateDriverPosition({
    required double latitude,
    required double longitude,
    required double heading,
  }) {
    if (!mounted || latitude == 0.0 || longitude == 0.0) return;

    final position = LatLng(latitude, longitude);
    setState(() {
      departureLatLong = position;
      _markers['driver'] = Marker(
        markerId: const MarkerId('driver'),
        infoWindow: InfoWindow(title: rideData!.prenomConducteur.toString()),
        position: position,
        icon: taxiIcon ?? BitmapDescriptor.defaultMarker,
        rotation: heading,
      );
    });
    getDirections(dLat: latitude, dLng: longitude);
  }

  // Helper method to set up driver location listener based on current status
  void _setupDriverLocationListener() {
    // Cancel existing subscription first
    _driverLocationSubscription?.cancel();

    if (rideData!.statut == "on ride" || rideData!.statut == 'confirmed') {
      _driverLocationSubscription = Constant.driverLocationUpdate
          .doc(rideData!.idConducteur)
          .snapshots()
          .listen((event) async {
        try {
          // Check if widget is still mounted before calling setState
          if (!mounted) return;

          DriverLocationUpdate driverLocationUpdate =
              DriverLocationUpdate.fromJson(
                  event.data() as Map<String, dynamic>);

          // Validate coordinates before updating
          double driverLat =
              double.parse(driverLocationUpdate.driverLatitude.toString());
          double driverLng =
              double.parse(driverLocationUpdate.driverLongitude.toString());

          // Only update if coordinates are valid (not 0, 0)
          if (driverLat != 0.0 && driverLng != 0.0) {
            // Update the route from the driver's live location. This targets
            // pickup while confirmed and the final destination while on ride.
            _updateDriverPosition(
              latitude: driverLat,
              longitude: driverLng,
              heading: double.tryParse(
                    driverLocationUpdate.rotation.toString(),
                  ) ??
                  0.0,
            );

            // Auto-follow driver position if in navigation mode
            if (isNavigationMode &&
                isTrackingDriver &&
                _mapcontroller != null) {
              _mapcontroller!.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: LatLng(driverLat, driverLng),
                    zoom: 17.0,
                    tilt: 45.0, // Add tilt for 3D navigation view
                    bearing: double.parse(driverLocationUpdate.rotation
                        .toString()), // Rotate map based on driver's direction
                  ),
                ),
              );
            }
          } else {
            print('Skipping Firebase update: Invalid coordinates 0.0, 0.0');
          }

          // Get estimated arrival time with proper error handling
          try {
            Dio dio = Dio();
            dynamic response = await dio.get(
                "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=${rideData!.latitudeDepart},${rideData!.longitudeDepart}&destinations=${double.parse(driverLocationUpdate.driverLatitude.toString())},${double.parse(driverLocationUpdate.driverLongitude.toString())}&key=${Constant.kGoogleApiKey}");

            // Check if widget is still mounted before calling setState
            if (!mounted) return;

            // Check if response is valid and has the expected structure
            if (response.data != null &&
                response.data['rows'] != null &&
                response.data['rows'].isNotEmpty &&
                response.data['rows'][0]['elements'] != null &&
                response.data['rows'][0]['elements'].isNotEmpty &&
                response.data['rows'][0]['elements'][0]['duration'] != null &&
                response.data['rows'][0]['elements'][0]['duration']['text'] !=
                    null) {
              setState(() {
                driverEstimateArrivalTime = response.data['rows'][0]['elements']
                        [0]['duration']['text']
                    .toString();
              });
            } else {
              // If API response is invalid, set default or keep previous value
              if (driverEstimateArrivalTime.isEmpty) {
                setState(() {
                  driverEstimateArrivalTime = 'Calculating...';
                });
              }
            }
          } catch (e) {
            // If API call fails, just keep the previous estimate or set default
            if (!mounted) return;
            if (driverEstimateArrivalTime.isEmpty) {
              setState(() {
                driverEstimateArrivalTime = 'Calculating...';
              });
            }
            print('Error getting estimated arrival time: $e');
          }
        } catch (e) {
          print('Error updating driver location: $e');
        }
      });
    } else {
      // For other statuses, show route from departure to destination without driver location
      getDirections(
          dLat: double.parse(rideData!.latitudeDepart.toString()),
          dLng: double.parse(rideData!.longitudeDepart.toString()));
    }
  }

  // NEW: Actively update driver's current location to Firebase during ride
  void _startUpdatingLocationToFirebase() {
    _locationSubscription?.cancel(); // Cancel any existing subscription

    if (rideData!.statut == "on ride" || rideData!.statut == 'confirmed') {
      print('🚗 Driver App - Starting active location updates to Firebase...');

      Location location = Location();

      location.changeSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // Update every 5 meters
        interval: 3000, // Update every 3 seconds
      );

      _locationSubscription = location.onLocationChanged
          .listen((LocationData currentLocation) async {
        try {
          // Validate location
          if (currentLocation.latitude == null ||
              currentLocation.longitude == null) {
            print('🚗 Driver App - Invalid location data');
            return;
          }

          // Do not wait for Firebase to echo the update back before changing
          // the route, especially just after the driver starts the trip.
          _updateDriverPosition(
            latitude: currentLocation.latitude!,
            longitude: currentLocation.longitude!,
            heading: currentLocation.heading ?? 0.0,
          );

          print(
              '🚗 Driver App - Updating location to Firebase: ${currentLocation.latitude}, ${currentLocation.longitude}');

          // Determine driver status based on ride status
          String driverStatus = 'en-route';
          if (rideData!.statut == 'confirmed') {
            driverStatus = 'heading-to-pickup';
          } else if (rideData!.statut == 'on ride') {
            driverStatus = 'on-trip';
          }

          // Create location update object
          DriverLocationUpdate driverLocationUpdate = DriverLocationUpdate(
            rotation: (currentLocation.heading ?? 0.0).toString(),
            active: true,
            driverId: Preferences.getInt(Preferences.userId).toString(),
            driverLatitude: currentLocation.latitude.toString(),
            driverLongitude: currentLocation.longitude.toString(),
            status: driverStatus,
          );

          // Update to Firebase
          await Constant.driverLocationUpdate
              .doc(Preferences.getInt(Preferences.userId).toString())
              .set(driverLocationUpdate.toJson());

          print('🚗 Driver App - Location updated successfully to Firebase');
        } catch (e) {
          print('🚗 Driver App - Error updating location to Firebase: $e');
        }
      });
    } else {
      print('🚗 Driver App - Ride not active, not starting location updates');
    }
  }

  setIcons() async {
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(10, 10)),
            "assets/icons/pickup.png")
        .then((value) {
      departureIcon = value;
    });

    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(10, 10)),
            "assets/icons/dropoff.png")
        .then((value) {
      destinationIcon = value;
    });

    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(10, 10)),
            "assets/images/ic_taxi.png")
        .then((value) {
      taxiIcon = value;
    });
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(10, 10)),
            "assets/icons/location.png")
        .then((value) {
      stopIcon = value;
    });
  }

  final controllerRideDetails = Get.put(RideDetailsController());
  final controllerDashBoard = Get.put(DashBoardController());

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          GoogleMap(
            zoomControlsEnabled: true,
            myLocationButtonEnabled: false,
            initialCameraPosition: CameraPosition(
              target: LatLng(double.parse(rideData!.latitudeDepart!),
                  double.parse(rideData!.longitudeDepart!)),
              zoom: 14.0,
            ),
            onMapCreated: (GoogleMapController controller) {
              _mapcontroller = controller;
              _mapcontroller!
                  .moveCamera(CameraUpdate.newLatLngZoom(departureLatLong, 12));
            },
            onCameraMove: (CameraPosition position) {
              // User is manually moving the map, stop auto-tracking
              if (isNavigationMode && isTrackingDriver) {
                setState(() {
                  isTrackingDriver = false;
                });
              }
            },
            polylines: Set<Polyline>.of(polyLines.values),
            myLocationEnabled: false,
            markers: _markers.values.toSet(),
          ),
          // Navigation Instruction Panel (shown when navigation is active)
          if (isNavigationMode && currentInstruction.isNotEmpty)
            Positioned(
              top: 70,
              left: 10,
              right: 10,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: themeChange.getThem()
                        ? AppThemeData.surface50Dark
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Current instruction
                      Text(
                        currentInstruction,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: themeChange.getThem()
                              ? AppThemeData.grey900Dark
                              : AppThemeData.grey900,
                        ),
                      ),
                      if (distanceToNextStep.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              Icon(Icons.straighten,
                                  size: 16, color: AppThemeData.primary200),
                              const SizedBox(width: 4),
                              Text(
                                distanceToNextStep,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppThemeData.primary200,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (durationToNextStep.isNotEmpty) ...[
                                const SizedBox(width: 16),
                                Icon(Icons.access_time,
                                    size: 16, color: AppThemeData.primary200),
                                const SizedBox(width: 4),
                                Text(
                                  durationToNextStep,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppThemeData.primary200,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          Positioned(
            top: 10,
            left: 5,
            right: 5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SafeArea(
                  child: InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.arrow_back_ios_outlined,
                          color: Colors.black, size: 20),
                    ),
                  ),
                ),
                SafeArea(
                  child: InkWell(
                    onTap: () {
                      // Re-center on driver's current location
                      if (_mapcontroller != null &&
                          departureLatLong.latitude != 0.0) {
                        _mapcontroller!.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(
                              target: departureLatLong,
                              zoom: 18.0,
                              tilt: isNavigationMode ? 60.0 : 0.0,
                            ),
                          ),
                        );
                        setState(() {
                          isTrackingDriver = true;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.my_location,
                        color: isTrackingDriver
                            ? AppThemeData.primary200
                            : Colors.grey,
                        size: 24,
                      ),
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
                          // Hide estimate time when in navigation mode
                          if (rideData!.statut == 'confirmed' &&
                              !isNavigationMode)
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                            onTap: () async {
                                              try {
                                                UserData userdata =
                                                    UserData.fromJson(
                                                        jsonDecode(Preferences
                                                                .getString(
                                                                    Preferences
                                                                        .user))[
                                                            'data']);
                                                ShowToastDialog.showLoader(
                                                    "Please wait");
                                                final headers = {
                                                  'Content-Type':
                                                      'application/json',
                                                  'Accept': 'application/json',
                                                  // Include your auth token if needed:
                                                  // 'Authorization': 'Bearer ${API.token}',
                                                };
                                                print({
                                                  "driver_id": userdata.id,
                                                  "ride_id": rideData?.id
                                                });
                                                final response =
                                                    await http.post(
                                                  headers: headers,
                                                  Uri.parse(API.notifyUser),
                                                  body: jsonEncode({
                                                    "driver_id": userdata.id,
                                                    "ride_id": rideData?.id
                                                  }),
                                                );
                                                showLog(
                                                    "API :: URL :: ${API.notifyUser}");
                                                showLog(
                                                    "API :: responseStatus :: ${response.statusCode}");
                                                showLog(
                                                    "API :: responseBody :: ${response.body}");
                                                if (response.statusCode ==
                                                        200 ||
                                                    response.statusCode ==
                                                        201) {
                                                  ShowToastDialog.closeLoader();
                                                  ShowToastDialog.showToast(
                                                      jsonDecode(response.body)[
                                                          'message']);
                                                } else if (response
                                                        .statusCode ==
                                                    500) {
                                                  ShowToastDialog.closeLoader();
                                                  ShowToastDialog.showToast(
                                                      response.body.toString());
                                                } else {
                                                  ShowToastDialog.closeLoader();
                                                  ShowToastDialog.showToast(
                                                      'Something went wrong. Please try again later');
                                                  throw Exception(
                                                      'Failed to load data');
                                                }
                                              } on TimeoutException catch (e) {
                                                ShowToastDialog.closeLoader();
                                                showLog(e.toString());
                                                ShowToastDialog.showToast(
                                                    e.message.toString());
                                              } on SocketException catch (e) {
                                                ShowToastDialog.closeLoader();
                                                showLog(e.toString());
                                                ShowToastDialog.showToast(
                                                    e.message.toString());
                                              } on Error catch (e) {
                                                ShowToastDialog.closeLoader();
                                                showLog(e.toString());
                                                ShowToastDialog.showToast(
                                                    e.toString());
                                              } catch (e) {
                                                ShowToastDialog.closeLoader();
                                                showLog(e.toString());
                                                ShowToastDialog.showToast(
                                                    e.toString());
                                              }
                                            },
                                            child: Column(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10,
                                                      vertical: 10),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        AppThemeData.primary200,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            40),
                                                  ),
                                                  child: const Icon(
                                                    CupertinoIcons.alarm,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                const Text("Notify")
                                              ],
                                            ),
                                          ),
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
                                                    rideData!.phone.toString());
                                              } else {
                                                Constant.makePhoneCall(rideData!
                                                    .userInfo!.phone
                                                    .toString());
                                              }
                                            },
                                            child: Column(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10,
                                                      vertical: 10),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        AppThemeData.primary200,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            40),
                                                  ),
                                                  child: Icon(
                                                    Icons.phone,
                                                    size: 20,
                                                    color: themeChange.getThem()
                                                        ? AppThemeData
                                                            .surface50Dark
                                                        : AppThemeData
                                                            .surface50,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                const Text("Call")
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5.0),
                                      child: Text(
                                        rideData!.dateRetour.toString(),
                                      ),
                                    ),
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
                            child: CustomButton(
                              btnName: 'REJECT'.tr,
                              width: Responsive.width(100, context) * 0.8,
                              buttonColor: Colors.white,
                              textColor: Colors.black.withOpacity(0.60),
                              outlineColor: Colors.black.withOpacity(0.20),
                              isOutlined: true,
                              borderRadius: 10,
                              ontap: () async {
                                buildShowBottomSheet(
                                    context, themeChange.getThem());
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
                            child: CustomButton(
                              btnName: 'ACCEPT'.tr,
                              width: Responsive.width(100, context) * 0.8,
                              buttonColor: AppThemeData.primary200,
                              textColor: Colors.black,
                              borderRadius: 10,
                              ontap: () async {
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
                                            Get.back(); // Close the confirmation dialog

                                            // Update status and rebuild UI
                                            setState(() {
                                              rideData!.statut = "confirmed";
                                            });

                                            // Restart the listener with new status
                                            _setupDriverLocationListener();
                                            // Restart location updates to Firebase
                                            _startUpdatingLocationToFirebase();

                                            // Use Get.dialog to avoid context issues
                                            if (mounted) {
                                              Get.dialog(
                                                CustomDialogBox(
                                                  title:
                                                      "Confirmed Successfully"
                                                          .tr,
                                                  descriptions:
                                                      "Ride Successfully confirmed."
                                                          .tr,
                                                  text: "Ok".tr,
                                                  onPress: () {
                                                    // Close dialog and any overlays
                                                    if (Get.isDialogOpen ??
                                                        false) {
                                                      Get.back();
                                                    }
                                                  },
                                                  img: Image.asset(
                                                      'assets/images/green_checked.png'),
                                                ),
                                                barrierDismissible: false,
                                              );
                                            }
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
                            child: CustomButton(
                              btnName: 'On Ride'.tr,
                              width: Responsive.width(100, context) * 0.8,
                              buttonColor: AppThemeData.primary200,
                              textColor: Colors.black,
                              borderRadius: 10,
                              ontap: () async {
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
                                              // Update status and rebuild UI
                                              setState(() {
                                                rideData!.statut = "on ride";
                                              });

                                              // Restart the listener with new status
                                              _setupDriverLocationListener();
                                              // Restart location updates to Firebase
                                              _startUpdatingLocationToFirebase();
                                              // Switch immediately from the pickup route
                                              // to the final-destination route.
                                              _showRouteFromCurrentLocation();

                                              // Use Get.dialog to avoid context issues
                                              if (mounted) {
                                                Get.dialog(
                                                  CustomDialogBox(
                                                    title:
                                                        "On ride Successfully"
                                                            .tr,
                                                    descriptions:
                                                        "Ride Successfully On ride."
                                                            .tr,
                                                    text: "Ok".tr,
                                                    onPress: () {
                                                      // Close dialog and any overlays
                                                      if (Get.isDialogOpen ??
                                                          false) {
                                                        Get.back();
                                                      }
                                                    },
                                                    img: Image.asset(
                                                        'assets/images/green_checked.png'),
                                                  ),
                                                  barrierDismissible: false,
                                                );
                                              }
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
                                                            child: CustomButton(
                                                              btnName:
                                                                  'done'.tr,
                                                              width: Responsive
                                                                      .width(
                                                                          100,
                                                                          context) *
                                                                  0.8,
                                                              buttonColor:
                                                                  AppThemeData
                                                                      .primary200,
                                                              textColor:
                                                                  Colors.white,
                                                              borderRadius: 10,
                                                              ontap: () {
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
                                                                          Get.back(); // Close OTP dialog

                                                                          // Update status and rebuild UI
                                                                          setState(
                                                                              () {
                                                                            rideData!.statut =
                                                                                "on ride";
                                                                          });

                                                                          // Restart the listener with new status
                                                                          _setupDriverLocationListener();
                                                                          // Restart location updates to Firebase
                                                                          _startUpdatingLocationToFirebase();
                                                                          // Switch immediately from the pickup route
                                                                          // to the final-destination route.
                                                                          _showRouteFromCurrentLocation();

                                                                          // Use Get.dialog to avoid context issues
                                                                          if (mounted) {
                                                                            Get.dialog(
                                                                              CustomDialogBox(
                                                                                title: "On ride Successfully".tr,
                                                                                descriptions: "Ride Successfully On ride.".tr,
                                                                                text: "Ok".tr,
                                                                                onPress: () {
                                                                                  Get.back();
                                                                                },
                                                                                img: Image.asset('assets/images/green_checked.png'),
                                                                              ),
                                                                              barrierDismissible: false,
                                                                            );
                                                                          }
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
                                                            child: CustomButton(
                                                              btnName:
                                                                  'cancel'.tr,
                                                              width: Responsive
                                                                      .width(
                                                                          100,
                                                                          context) *
                                                                  0.8,
                                                              buttonColor:
                                                                  Colors.white,
                                                              textColor: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                      0.60),
                                                              outlineColor: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                      0.20),
                                                              isOutlined: true,
                                                              borderRadius: 10,
                                                              ontap: () {
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
                            child: CustomButton(
                              btnName: isNavigationMode
                                  ? 'STOP NAVIGATION'.tr
                                  : 'START NAVIGATION'.tr,
                              width: Responsive.width(100, context) * 0.8,
                              buttonColor: isNavigationMode
                                  ? AppThemeData.primary200
                                  : Colors.white,
                              textColor: isNavigationMode
                                  ? Colors.white
                                  : Colors.black.withOpacity(0.60),
                              outlineColor: Colors.black.withOpacity(0.20),
                              isOutlined: !isNavigationMode,
                              borderRadius: 10,
                              ontap: () async {
                                setState(() {
                                  isNavigationMode = !isNavigationMode;
                                  isTrackingDriver = isNavigationMode;

                                  if (isNavigationMode) {
                                    // Set navigation phase
                                    if (rideData!.statut == "confirmed") {
                                      navigationPhase = "heading_to_pickup";
                                    } else if (rideData!.statut == "on ride") {
                                      navigationPhase =
                                          "heading_to_destination";
                                    }
                                  } else {
                                    currentInstruction = "";
                                    routeSteps = [];
                                  }
                                });

                                if (isNavigationMode) {
                                  // Start turn-by-turn navigation
                                  if (departureLatLong.latitude != 0.0) {
                                    await getTurnByTurnDirections(
                                      dLat: departureLatLong.latitude,
                                      dLng: departureLatLong.longitude,
                                    );

                                    if (_mapcontroller != null) {
                                      await _mapcontroller!.animateCamera(
                                        CameraUpdate.newCameraPosition(
                                          CameraPosition(
                                            target: departureLatLong,
                                            zoom: 18.0,
                                            tilt: 60.0,
                                            bearing: 0.0,
                                          ),
                                        ),
                                      );
                                    }
                                    ShowToastDialog.showToast(
                                        'Navigation started');
                                  } else {
                                    ShowToastDialog.showToast(
                                        'Waiting for GPS...');
                                  }
                                } else {
                                  // Stop navigation - show full route
                                  try {
                                    if (_mapcontroller != null &&
                                        polyLines.isNotEmpty) {
                                      List<LatLng> allPoints = [];
                                      polyLines.values.forEach((polyline) {
                                        allPoints.addAll(polyline.points);
                                      });

                                      if (allPoints.isNotEmpty) {
                                        double minLat =
                                            allPoints.first.latitude;
                                        double maxLat =
                                            allPoints.first.latitude;
                                        double minLng =
                                            allPoints.first.longitude;
                                        double maxLng =
                                            allPoints.first.longitude;

                                        for (var point in allPoints) {
                                          if (point.latitude < minLat)
                                            minLat = point.latitude;
                                          if (point.latitude > maxLat)
                                            maxLat = point.latitude;
                                          if (point.longitude < minLng)
                                            minLng = point.longitude;
                                          if (point.longitude > maxLng)
                                            maxLng = point.longitude;
                                        }

                                        LatLngBounds bounds = LatLngBounds(
                                          southwest: LatLng(minLat, minLng),
                                          northeast: LatLng(maxLat, maxLng),
                                        );

                                        await _mapcontroller!.animateCamera(
                                          CameraUpdate.newLatLngBounds(
                                              bounds, 80),
                                        );
                                      }
                                    }
                                    ShowToastDialog.showToast(
                                        'Navigation stopped');
                                  } catch (e) {
                                    print('Error: $e');
                                  }
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
                            child: CustomButton(
                              btnName: 'COMPLETE'.tr,
                              width: Responsive.width(100, context) * 0.8,
                              buttonColor: AppThemeData.primary200,
                              textColor: Colors.black,
                              borderRadius: 10,
                              ontap: () async {
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
                                            Get.back(); // Close confirmation dialog

                                            // Cancel subscription since ride is completed
                                            _driverLocationSubscription
                                                ?.cancel();

                                            // Update status
                                            setState(() {
                                              rideData!.statut = "complete";
                                            });

                                            // Use Get.dialog to avoid context issues
                                            if (mounted) {
                                              Get.dialog(
                                                CustomDialogBox(
                                                  title:
                                                      "Completed Successfully"
                                                          .tr,
                                                  descriptions:
                                                      "Ride Successfully completed."
                                                          .tr,
                                                  text: "Ok".tr,
                                                  onPress: () {
                                                    Get.back(); // Close dialog
                                                    Get.back(); // Go back to previous screen
                                                  },
                                                  img: Image.asset(
                                                      'assets/images/green_checked.png'),
                                                ),
                                                barrierDismissible: false,
                                              );
                                            }
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

  buildShowBottomSheet(BuildContext context, bool isDarkMode) {
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
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        "Write a reason for trip cancellation".tr,
                        style: const TextStyle(fontSize: 16),
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
                              child: CustomButton(
                                btnName: 'Cancel Trip'.tr,
                                width: Responsive.width(100, context) * 0.8,
                                buttonColor: AppThemeData.primary200,
                                textColor: !isDarkMode
                                    ? AppThemeData.grey900
                                    : AppThemeData.grey900Dark,
                                borderRadius: 10,
                                ontap: () async {
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
                                              Get.back(); // Close confirmation dialog
                                              if (value != null) {
                                                // Cancel subscription since ride is rejected
                                                _driverLocationSubscription
                                                    ?.cancel();

                                                // Update status
                                                setState(() {
                                                  rideData!.statut = "rejected";
                                                });

                                                // Use Get.dialog to avoid context issues
                                                if (mounted) {
                                                  Get.dialog(
                                                    CustomDialogBox(
                                                      title:
                                                          "Reject Successfully"
                                                              .tr,
                                                      descriptions:
                                                          "Ride Successfully rejected."
                                                              .tr,
                                                      text: "Ok".tr,
                                                      onPress: () {
                                                        Get.back(); // Close dialog
                                                        Get.back(); // Go back to previous screen
                                                      },
                                                      img: Image.asset(
                                                          'assets/images/green_checked.png'),
                                                    ),
                                                    barrierDismissible: false,
                                                  );
                                                }
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
                          const SizedBox(width: 5),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 5, left: 10),
                              child: CustomButton(
                                btnName: 'Close'.tr,
                                width: Responsive.width(100, context) * 0.8,
                                buttonColor: isDarkMode
                                    ? AppThemeData.grey900
                                    : AppThemeData.grey900Dark,
                                textColor: !isDarkMode
                                    ? AppThemeData.grey900
                                    : AppThemeData.grey900Dark,
                                outlineColor: AppThemeData.primary200,
                                isOutlined: true,
                                borderRadius: 10,
                                ontap: () async {
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

  // Get turn-by-turn navigation instructions
  Future<void> getTurnByTurnDirections(
      {required double dLat, required double dLng}) async {
    try {
      String origin = "$dLat,$dLng";
      String destination = "";

      // Determine destination based on navigation phase
      if (navigationPhase == "heading_to_pickup" ||
          rideData!.statut == "confirmed") {
        destination =
            "${rideData!.latitudeDepart},${rideData!.longitudeDepart}";
      } else {
        destination =
            "${rideData!.latitudeArrivee},${rideData!.longitudeArrivee}";
      }

      Dio dio = Dio();
      var response = await dio.get(
        "https://maps.googleapis.com/maps/api/directions/json",
        queryParameters: {
          "origin": origin,
          "destination": destination,
          "key": Constant.kGoogleApiKey,
          "mode": "driving",
        },
      );

      if (response.data['status'] == 'OK' &&
          response.data['routes'].isNotEmpty) {
        var route = response.data['routes'][0];
        var legs = route['legs'][0];

        setState(() {
          routeSteps = legs['steps'];
          currentStepIndex = 0;

          if (routeSteps.isNotEmpty) {
            var step = routeSteps[0];
            currentInstruction = _parseInstruction(step['html_instructions']);
            distanceToNextStep = step['distance']['text'];
            durationToNextStep = step['duration']['text'];

            // Check if close to destination
            double distanceValue = step['distance']['value'].toDouble();
            if (distanceValue < 100) {
              if (navigationPhase == "heading_to_pickup") {
                navigationPhase = "at_pickup";
                currentInstruction =
                    "🎯 Arrived at pickup location!\nWait for passenger";
              } else if (navigationPhase == "heading_to_destination") {
                navigationPhase = "at_destination";
                currentInstruction =
                    "✅ Arrived at destination!\nComplete the ride";
              }
            }
          }
        });
      }
    } catch (e) {
      print('Error getting turn-by-turn directions: $e');
    }
  }

  String _parseInstruction(String htmlInstruction) {
    // Remove HTML tags and parse instruction
    String instruction = htmlInstruction
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&#160;', ' ');

    // Add emoji based on instruction type
    if (instruction.toLowerCase().contains('left')) {
      return '⬅️ $instruction';
    } else if (instruction.toLowerCase().contains('right')) {
      return '➡️ $instruction';
    } else if (instruction.toLowerCase().contains('straight') ||
        instruction.toLowerCase().contains('continue')) {
      return '⬆️ $instruction';
    } else if (instruction.toLowerCase().contains('u-turn')) {
      return '↩️ $instruction';
    } else {
      return '📍 $instruction';
    }
  }

  getDirections({required double dLat, required double dLng}) async {
    // Validate coordinates
    if (dLat == 0.0 && dLng == 0.0) {
      print('Invalid coordinates: Cannot get directions with 0.0, 0.0');
      return;
    }

    // Get turn-by-turn instructions if in navigation mode
    if (isNavigationMode) {
      getTurnByTurnDirections(dLat: dLat, dLng: dLng);
    }

    List<LatLng> polylineCoordinates = [];
    PolylineResult result;
    List<PolylineWayPoint> wayPointList = [];
    for (var i = 0; i < rideData!.stops!.length; i++) {
      wayPointList
          .add(PolylineWayPoint(location: rideData!.stops![i].location!));
    }
    if (rideData!.statut == "confirmed") {
      PolylineRequest resultdata = PolylineRequest(
        origin: PointLatLng(dLat, dLng),
        destination: PointLatLng(
            double.parse(rideData!.latitudeDepart.toString()),
            double.parse(rideData!.longitudeDepart.toString())),
        mode: TravelMode.driving,
        optimizeWaypoints: true,
        // wayPoints: wayPointList,
      );
      result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: Constant.kGoogleApiKey.toString(),
        request: resultdata,
      );
    } else if (rideData!.statut == "on ride") {
      PolylineRequest resultdata = PolylineRequest(
        origin: PointLatLng(dLat, dLng),
        destination: PointLatLng(
            destinationLatLong.latitude, destinationLatLong.longitude),
        mode: TravelMode.driving,
        optimizeWaypoints: true,
        wayPoints: wayPointList,
      );
      result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: Constant.kGoogleApiKey.toString(),
        request: resultdata,
      );
    } else {
      PolylineRequest resultdata = PolylineRequest(
        origin:
            PointLatLng(departureLatLong.latitude, departureLatLong.longitude),
        destination: PointLatLng(
            destinationLatLong.latitude, destinationLatLong.longitude),
        mode: TravelMode.driving,
        optimizeWaypoints: true,
        wayPoints: wayPointList,
      );
      result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: Constant.kGoogleApiKey.toString(),
        request: resultdata,
      );
    }

    // Check if result has an error
    if (result.errorMessage != null && result.errorMessage!.isNotEmpty) {
      print('Error getting route: ${result.errorMessage}');
      // Still show markers even if route fails
      _addMarkersOnly();
      return;
    }

    //  PolylineRequest resultdata = PolylineRequest(
    //     origin: PointLatLng(departureLatLong.latitude, departureLatLong.longitude),
    //      destination: PointLatLng(destinationLatLong.latitude, destinationLatLong.longitude),
    //     mode: TravelMode.driving,
    //     optimizeWaypoints: true,
    //     wayPoints: wayPointList,
    //   );

    _markers['Departure'] = Marker(
      markerId: const MarkerId('Departure'),
      infoWindow: InfoWindow(title: "Departure".tr),
      position: LatLng(double.parse(rideData!.latitudeDepart.toString()),
          double.parse(rideData!.longitudeDepart.toString())),
      icon: departureIcon!,
    );

    _markers['Destination'] = Marker(
      markerId: const MarkerId('Destination'),
      infoWindow: InfoWindow(title: "Destination".tr),
      position: destinationLatLong,
      icon: destinationIcon!,
    );

    for (var i = 0; i < rideData!.stops!.length; i++) {
      _markers['${rideData!.stops![i]}'] = Marker(
        markerId: MarkerId('${rideData!.stops![i]}'),
        infoWindow: InfoWindow(title: rideData!.stops![i].location!),
        position: LatLng(double.parse(rideData!.stops![i].latitude!),
            double.parse(rideData!.stops![i].longitude!)),
        icon: stopIcon!,
      );
    }

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }

    addPolyLine(polylineCoordinates);
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: AppThemeData.primary200,
      points: polylineCoordinates,
      width: 6,
      geodesic: true,
    );
    polyLines[id] = polyline;
    updateCameraLocation(polylineCoordinates.first, _mapcontroller);

    setState(() {});
  }

  Future<void> updateCameraLocation(
    LatLng source,
    GoogleMapController? mapController,
  ) async {
    mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: source,
          zoom: rideData!.statut == "on ride" || rideData!.statut == "confirmed"
              ? 20
              : 16,
        ),
      ),
    );
  }

  // Helper method to add markers without route when route calculation fails
  void _addMarkersOnly() {
    _markers['Departure'] = Marker(
      markerId: const MarkerId('Departure'),
      infoWindow: InfoWindow(title: "Departure".tr),
      position: LatLng(double.parse(rideData!.latitudeDepart.toString()),
          double.parse(rideData!.longitudeDepart.toString())),
      icon: departureIcon!,
    );

    _markers['Destination'] = Marker(
      markerId: const MarkerId('Destination'),
      infoWindow: InfoWindow(title: "Destination".tr),
      position: destinationLatLong,
      icon: destinationIcon!,
    );

    for (var i = 0; i < rideData!.stops!.length; i++) {
      _markers['${rideData!.stops![i]}'] = Marker(
        markerId: MarkerId('${rideData!.stops![i]}'),
        infoWindow: InfoWindow(title: rideData!.stops![i].location!),
        position: LatLng(double.parse(rideData!.stops![i].latitude!),
            double.parse(rideData!.stops![i].longitude!)),
        icon: stopIcon!,
      );
    }

    setState(() {});
  }
}
