import 'package:cabme_driver/core/constant/constant.dart';
import 'package:cabme_driver/core/constant/show_toast_dialog.dart';
import 'package:cabme_driver/features/dashboard/controller/dash_board_controller.dart';
import 'package:cabme_driver/features/ride/controller/new_ride_controller.dart';
import 'package:cabme_driver/features/ride/model/ride_model.dart';
import 'package:cabme_driver/features/complaint/view/add_complaint_screen.dart';
import 'package:cabme_driver/features/ride/view/completed/trip_history_screen.dart';
import 'package:cabme_driver/features/dashboard/view/dash_board.dart';
import 'package:cabme_driver/features/review/view/add_review_screen.dart';
import 'package:cabme_driver/core/themes/button_them.dart';
import 'package:cabme_driver/core/themes/constant_colors.dart';
import 'package:cabme_driver/core/themes/responsive.dart';
import 'package:cabme_driver/common/widget/button.dart';
import 'package:cabme_driver/core/themes/custom_alert_dialog.dart';
import 'package:cabme_driver/core/themes/custom_dialog_box.dart';
import 'package:cabme_driver/core/utils/Preferences.dart';
import 'package:cabme_driver/core/utils/dark_theme_provider.dart';
import 'package:cabme_driver/common/widget/StarRating.dart';
import 'package:cabme_driver/common/widget/custom_text.dart';
import 'package:cabme_driver/common/widget/custom_app_bar.dart';
import 'package:cabme_driver/common/screens/botton_nav_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:text_scroll/text_scroll.dart';

class NewRideScreen extends StatefulWidget {
  const NewRideScreen({super.key});

  @override
  State<NewRideScreen> createState() => _NewRideScreenState();
}

class _NewRideScreenState extends State<NewRideScreen>
    with WidgetsBindingObserver {
  final controllerDashBoard = Get.put(DashBoardController());

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final NewRideController rideController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Use Get.put with permanent: true to keep controller alive
    rideController = Get.put(NewRideController(), permanent: true);
    // Mark screen as active
    rideController.onScreenVisible();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Mark screen as inactive when disposed
    if (Get.isRegistered<NewRideController>()) {
      Get.find<NewRideController>().onScreenHidden();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // App came back to foreground - refresh rides
      if (Get.isRegistered<NewRideController>()) {
        Get.find<NewRideController>().getNewRide();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetX<NewRideController>(
      builder: (controller) {
        final userData = controller.userModel.value.userData;
        return Scaffold(
            key: _scaffoldKey,
            appBar: CustomAppBar(
              title: 'All Rides'.tr,
              showBackButton: false,
            ),
            backgroundColor: themeChange.getThem()
                ? AppThemeData.grey50Dark
                : AppThemeData.grey50,
            drawer: buildAppDrawer(context, controllerDashBoard),
            body: RefreshIndicator(
              onRefresh: () => controller.getNewRide(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                children: [
                  if (userData != null &&
                      (double.tryParse(userData.amount.toString()) ?? 0) <
                          (double.tryParse(
                                  Constant.minimumWalletBalance ?? '0') ??
                              0))
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: ConstantColors.blue),
                      child: Text(
                        "${"Your wallet balance must".tr} ${Constant().amountShow(amount: Constant.minimumWalletBalance!.toString())} ${"to get ride.".tr}",
                        style: TextStyle(
                          color: AppThemeData.grey50,
                          fontSize: 14,
                          fontFamily: AppThemeData.medium,
                        ),
                      ),
                    ),
                  _buildFilterTabs(controller, themeChange.getThem()),
                  const SizedBox(height: 12),
                  if (controller.isLoading.value)
                    const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (controller.filteredRideList.isEmpty)
                    SizedBox(
                      height: 400,
                      child: Constant.emptyView(
                        controller.selectedFilter.value == 'all'
                            ? "You don't have any ride booked."
                            : "No ${controller.selectedFilter.value} rides found.",
                        context,
                      ),
                    )
                  else
                    ...controller.filteredRideList.map(
                      (ride) => newRideWidgets(
                        context,
                        ride,
                        controller,
                        themeChange.getThem(),
                      ),
                    ),
                ],
              ),
            ));
      },
    );
  }

  Widget _buildFilterTabs(NewRideController controller, bool isDarkMode) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: NewRideController.filterOptions.map((filter) {
          final isSelected = controller.selectedFilter.value == filter;
          final displayName = filter == 'all'
              ? 'All'.tr
              : filter == 'on ride'
                  ? 'On Ride'.tr
                  : Constant().capitalizeWords(filter).tr;

          // Get count for each filter
          int count = 0;
          if (filter == 'all') {
            count = controller.rideList.length;
          } else {
            count = controller.rideList.where((ride) {
              final status = ride.statut?.toLowerCase() ?? '';
              if (filter == 'on ride') {
                return status == 'on ride' || status == 'onride';
              }
              return status == filter;
            }).length;
          }

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => controller.setFilter(filter),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? ConstantColors.blue
                      : isDarkMode
                          ? AppThemeData.grey800Dark
                          : AppThemeData.grey100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? ConstantColors.blue
                        : isDarkMode
                            ? AppThemeData.grey300Dark
                            : AppThemeData.grey300,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomText(
                      text: displayName,
                      size: 13,
                      color: isSelected
                          ? Colors.white
                          : isDarkMode
                              ? AppThemeData.grey300Dark
                              : AppThemeData.grey800,
                      weight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                    if (count > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withOpacity(0.2)
                              : isDarkMode
                                  ? AppThemeData.grey300Dark
                                  : AppThemeData.grey200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: CustomText(
                          text: count.toString(),
                          size: 11,
                          color: isSelected
                              ? Colors.white
                              : isDarkMode
                                  ? AppThemeData.grey400Dark
                                  : AppThemeData.grey400,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget newRideWidgets(BuildContext context, RideData data,
      NewRideController controller, bool isDarkMode) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return InkWell(
      onTap: () async {
        if (data.statut == "completed") {
          var isDone = await Get.to(const TripHistoryScreen(), arguments: {
            "rideData": data,
          });
          if (isDone != null) {
            controller.getNewRide();
          }
        } else {
          // Open external map with directions
          await Constant.redirectMap(
            departureName: data.departName.toString(),
            originLat: double.tryParse(data.latitudeDepart.toString()),
            originLng: double.tryParse(data.longitudeDepart.toString()),
            arriveName: data.destinationName.toString(),
            latitude: double.tryParse(data.latitudeArrivee.toString()),
            longLatitude: double.tryParse(data.longitudeArrivee.toString()),
          );
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color:
              isDarkMode ? AppThemeData.surface50Dark : AppThemeData.surface50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDarkMode
                ? AppThemeData.grey300Dark.withOpacity(0.3)
                : AppThemeData.grey200,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          children: [
            // Status Badge and Route Section
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Status Badge Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Pickup Location
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: AppThemeData.success300,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: InkWell(
                                    onTap: () async {
                                      // Open external map with directions to pickup
                                      await Constant.redirectMap(
                                        departureName:
                                            data.departName.toString(),
                                        originLat: double.tryParse(
                                            data.latitudeDepart.toString()),
                                        originLng: double.tryParse(
                                            data.longitudeDepart.toString()),
                                        arriveName:
                                            data.destinationName.toString(),
                                        latitude: double.tryParse(
                                            data.latitudeArrivee.toString()),
                                        longLatitude: double.tryParse(
                                            data.longitudeArrivee.toString()),
                                      );
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CustomText(
                                          text: 'Pickup'.tr,
                                          size: 11,
                                          color: isDarkMode
                                              ? AppThemeData.grey500Dark
                                              : AppThemeData.grey500,
                                          weight: FontWeight.w500,
                                          letterSpacing: 0.5,
                                        ),
                                        const SizedBox(height: 4),
                                        CustomText(
                                          text: data.departName.toString(),
                                          size: 14,
                                          color: isDarkMode
                                              ? AppThemeData.grey900Dark
                                              : AppThemeData.grey900,
                                          weight: FontWeight.w600,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Route Line
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Container(
                                width: 2,
                                height: 20,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      ConstantColors.blue.withOpacity(0.3),
                                      ConstantColors.blue.withOpacity(0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Destination Location
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: AppThemeData.warning200,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: InkWell(
                                    onTap: () async {
                                      // Open external map with directions to destination
                                      await Constant.redirectMap(
                                        departureName:
                                            data.departName.toString(),
                                        originLat: double.tryParse(
                                            data.latitudeDepart.toString()),
                                        originLng: double.tryParse(
                                            data.longitudeDepart.toString()),
                                        arriveName:
                                            data.destinationName.toString(),
                                        latitude: double.tryParse(
                                            data.latitudeArrivee.toString()),
                                        longLatitude: double.tryParse(
                                            data.longitudeArrivee.toString()),
                                      );
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CustomText(
                                          text: 'Destination'.tr,
                                          size: 11,
                                          color: isDarkMode
                                              ? AppThemeData.grey500Dark
                                              : AppThemeData.grey500,
                                          weight: FontWeight.w500,
                                          letterSpacing: 0.5,
                                        ),
                                        const SizedBox(height: 4),
                                        CustomText(
                                          text: data.destinationName.toString(),
                                          size: 14,
                                          color: isDarkMode
                                              ? AppThemeData.grey900Dark
                                              : AppThemeData.grey900,
                                          weight: FontWeight.w600,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Status Badge only
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Constant.statusColor(data),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Constant.statusColor(data).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: CustomText(
                          text: Constant()
                              .capitalizeWords(data.statut.toString()),
                          size: 12,
                          color: Constant.statusTextColor(data),
                          weight: FontWeight.w600,
                          align: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  // Stops if any
                  if (data.stops != null && data.stops!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    ...data.stops!.asMap().entries.map((entry) {
                      int index = entry.key;
                      return Padding(
                        padding: const EdgeInsets.only(left: 10, bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: ConstantColors.blue,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                              ),
                              child: Center(
                                child: CustomText(
                                  text: String.fromCharCode(index + 65),
                                  size: 10,
                                  color: Colors.white,
                                  weight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                    text: 'Stop ${index + 1}'.tr,
                                    size: 11,
                                    color: isDarkMode
                                        ? AppThemeData.grey500Dark
                                        : AppThemeData.grey500,
                                    weight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                  const SizedBox(height: 4),
                                  CustomText(
                                    text: entry.value.location.toString(),
                                    size: 14,
                                    color: isDarkMode
                                        ? AppThemeData.grey900Dark
                                        : AppThemeData.grey900,
                                    weight: FontWeight.w600,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            if (index < data.stops!.length - 1)
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Container(
                                  width: 2,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        ConstantColors.blue.withOpacity(0.3),
                                        ConstantColors.blue.withOpacity(0.1),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
            // Stats Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? AppThemeData.grey800Dark.withOpacity(0.5)
                    : AppThemeData.grey100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      icon: Iconsax.routing_2,
                      value:
                          '${(double.tryParse(data.distance.toString()) ?? 0).toStringAsFixed(int.tryParse(Constant.decimal ?? '2') ?? 2)} ${Constant.distanceUnit ?? 'km'}',
                      label: 'Distance'.tr,
                      color: ConstantColors.blue,
                      isDarkMode: isDarkMode,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: isDarkMode
                        ? AppThemeData.grey300Dark.withOpacity(0.3)
                        : AppThemeData.grey300,
                  ),
                  Expanded(
                    child: _buildStatItem(
                      icon: Iconsax.wallet_3,
                      value: '${data.montant.toString()} KWD',
                      label: 'Trip Price'.tr,
                      color: AppThemeData.success300,
                      isDarkMode: isDarkMode,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Payment Method
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? AppThemeData.grey800Dark.withOpacity(0.3)
                      : AppThemeData.grey100.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Iconsax.wallet_1,
                      size: 16,
                      color: ConstantColors.blue,
                    ),
                    const SizedBox(width: 8),
                    CustomText(
                      text: 'Payment Method: '.tr,
                      size: 12,
                      color: isDarkMode
                          ? AppThemeData.grey500Dark
                          : AppThemeData.grey500,
                    ),
                    CustomText(
                      text: data.payment.toString(),
                      size: 12,
                      color: isDarkMode
                          ? AppThemeData.grey900Dark
                          : AppThemeData.grey900,
                      weight: FontWeight.w600,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Customer Info Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? AppThemeData.grey800Dark.withOpacity(0.3)
                      : AppThemeData.grey50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDarkMode
                        ? AppThemeData.grey300Dark.withOpacity(0.2)
                        : AppThemeData.grey200,
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                        // Avatar
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: ConstantColors.blue.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: data.photoPath.toString(),
                              height: 50,
                              width: 50,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                height: 50,
                                width: 50,
                                color: AppThemeData.grey200,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: AppThemeData.grey200,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Iconsax.user,
                                  color: AppThemeData.grey400,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Customer Info
                        Expanded(
                          child: data.rideType! == 'driver' &&
                                  data.existingUserId.toString() == "null"
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomText(
                                      text: data.userInfo?.name ??
                                          '${data.prenom ?? ''} ${data.nom ?? ''}'
                                              .trim(),
                                      size: 15,
                                      color: isDarkMode
                                          ? AppThemeData.grey900Dark
                                          : AppThemeData.grey900,
                                      weight: FontWeight.w600,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    CustomText(
                                      text: data.userInfo?.email ??
                                          data.phone ??
                                          '',
                                      size: 12,
                                      color: isDarkMode
                                          ? AppThemeData.grey500Dark
                                          : AppThemeData.grey500,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomText(
                                      text:
                                          '${data.prenom.toString()} ${data.nom.toString()}',
                                      size: 15,
                                      color: isDarkMode
                                          ? AppThemeData.grey900Dark
                                          : AppThemeData.grey900,
                                      weight: FontWeight.w600,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    FittedBox(
                                      alignment: Alignment.centerLeft,
                                      fit: BoxFit.scaleDown,
                                      child: StarRating(
                                        size: 16,
                                        rating: double.tryParse(data
                                                .moyenneDriver
                                                .toString()) ??
                                            0.0,
                                        color: AppThemeData.warning200,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                    const SizedBox(width: 12),
                    // Keep the controls in the same row as in the original
                    // card design, while reserving a fixed width for them.
                    // This leaves the middle section flexible on narrow phones.
                    SizedBox(
                      width: 84,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              // Navigate Button - Open external maps
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () async {
                                    // Open external map with directions
                                    await Constant.redirectMap(
                                      departureName: data.departName.toString(),
                                      originLat: double.tryParse(
                                          data.latitudeDepart.toString()),
                                      originLng: double.tryParse(
                                          data.longitudeDepart.toString()),
                                      arriveName:
                                          data.destinationName.toString(),
                                      latitude: double.tryParse(
                                          data.latitudeArrivee.toString()),
                                      longLatitude: double.tryParse(
                                          data.longitudeArrivee.toString()),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppThemeData.secondary200,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppThemeData.secondary200
                                              .withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Iconsax.routing_2,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Phone Button
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    if (data.rideType! == 'driver' &&
                                        data.existingUserId.toString() ==
                                            "null") {
                                      Constant.makePhoneCall(
                                          (data.userInfo?.phone ?? data.phone)
                                              .toString());
                                    } else {
                                      Constant.makePhoneCall(
                                          data.phone.toString());
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: ConstantColors.blue,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: ConstantColors.blue
                                              .withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Iconsax.call,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          CustomText(
                            text:
                                '${data.dateRetour.toString()} ${data.heureRetour.toString()}',
                            size: 11,
                            color: isDarkMode
                                ? AppThemeData.grey500Dark
                                : AppThemeData.grey500,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Action Buttons Section
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: [
                  Visibility(
                    visible: data.statut == "completed",
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Expanded(
                              child: CustomButton(
                                  width: Responsive.width(100, context),
                                  btnName: data.statutPaiement == "yes"
                                      ? "Paid".tr
                                      : "Not paid".tr,
                                  buttonColor: data.statutPaiement == "yes"
                                      ? AppThemeData.success300
                                      : AppThemeData.success300,
                                  textColor: themeChange.getThem()
                                      ? AppThemeData.grey900
                                      : AppThemeData.grey900Dark,
                                  borderRadius: 10,
                                  ontap: () {})),
                          if (data.existingUserId.toString() != "null")
                            const SizedBox(width: 12),
                          if (data.existingUserId.toString() != "null")
                            Expanded(
                              child: CustomButton(
                                btnName: 'Add Review'.tr,
                                width: Responsive.width(100, context),
                                buttonColor: ConstantColors.blue,
                                textColor: AppThemeData.grey50,
                                borderRadius: 10,
                                ontap: () async {
                                  Get.to(const AddReviewScreen(), arguments: {
                                    'rideData': data,
                                  });
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Visibility(
                    visible: data.statut == "completed" &&
                        data.existingUserId.toString() != "null",
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: CustomButton(
                        btnName: 'Add Complaint'.tr,
                        width: Responsive.width(100, context),
                        borderRadius: 10,
                        ontap: () async {
                          Get.to(AddComplaintScreen(), arguments: {
                            "isReviewScreen": false,
                            "data": data,
                            "ride_type": "ride",
                          });
                        },
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      controller.checkRideRejectBttnStatus == 'Hide'
                          ? Container()
                          : Visibility(
                              visible: data.statut == "new" ||
                                      data.statut == "confirmed"
                                  ? true
                                  : false,
                              child: Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: CustomButton(
                                    btnName: 'REJECT'.tr,
                                    width: Responsive.width(100, context),
                                    buttonColor: AppThemeData.warning200,
                                    textColor: themeChange.getThem()
                                        ? AppThemeData.grey900
                                        : AppThemeData.grey900Dark,
                                    borderRadius: 10,
                                    ontap: () async {
                                      buildShowBottomSheet(context, data,
                                          controller, isDarkMode);
                                    },
                                  ),
                                ),
                              ),
                            ),
                      Visibility(
                        visible: data.statut == "new" ? true : false,
                        child: Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: CustomButton(
                              btnName: 'ACCEPT'.tr,
                              width: Responsive.width(100, context),
                              buttonColor: AppThemeData.success300,
                              textColor: themeChange.getThem()
                                  ? AppThemeData.grey900
                                  : AppThemeData.grey900Dark,
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
                                          'id_ride': data.id.toString(),
                                          'id_user': data.idUserApp.toString(),
                                          'driver_name':
                                              '${data.prenomConducteur.toString()} ${data.nomConducteur.toString()}',
                                          'lat_conducteur':
                                              data.latitudeDepart.toString(),
                                          'lng_conducteur':
                                              data.longitudeDepart.toString(),
                                          'lat_client':
                                              data.latitudeArrivee.toString(),
                                          'lng_client':
                                              data.longitudeArrivee.toString(),
                                          'from_id': Preferences.getInt(
                                                  Preferences.userId)
                                              .toString(),
                                        };
                                        Get.back();
                                        controller
                                            .confirmedRide(bodyParams)
                                            .then((value) {
                                          if (value != null) {
                                            data.statut = "confirmed";

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
                                                    Get.back();
                                                    controller.getNewRide();
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
                        visible: data.statut == "confirmed" ? true : false,
                        child: Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: CustomButton(
                              btnName: 'On Ride'.tr,
                              width: Responsive.width(100, context),
                              buttonColor: ConstantColors.blue,
                              textColor: themeChange.getThem()
                                  ? AppThemeData.grey900
                                  : AppThemeData.grey900Dark,
                              borderRadius: 10,
                              ontap: () async {
                                showDialog(
                                  barrierColor:
                                      const Color.fromARGB(66, 20, 14, 14),
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
                                            data.rideType! == 'driver') {
                                          Map<String, String> bodyParams = {
                                            'id_ride': data.id.toString(),
                                            'id_user':
                                                data.idUserApp.toString(),
                                            'use_name':
                                                '${data.prenomConducteur.toString()} ${data.nomConducteur.toString()}',
                                            'from_id': Preferences.getInt(
                                                    Preferences.userId)
                                                .toString(),
                                          };
                                          controller
                                              .setOnRideRequest(bodyParams)
                                              .then((value) {
                                            if (value != null) {
                                              Get.back();
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
                                                      controller.getNewRide();
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
                                          controller.otpController =
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
                                                      color: isDarkMode
                                                          ? AppThemeData
                                                              .surface50Dark
                                                          : AppThemeData
                                                              .surface50,
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
                                                        style: const TextStyle(
                                                            fontSize: 16),
                                                      ),
                                                      const SizedBox(
                                                        height: 20,
                                                      ),
                                                      Pinput(
                                                        controller: controller
                                                            .otpController,
                                                        defaultPinTheme:
                                                            PinTheme(
                                                          height: 50,
                                                          width: 50,
                                                          textStyle:
                                                              const TextStyle(
                                                            letterSpacing: 0.60,
                                                            fontSize: 16,
                                                          ),
                                                          // margin: EdgeInsets.all(10),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            shape: BoxShape
                                                                .rectangle,
                                                            color: isDarkMode
                                                                ? AppThemeData
                                                                    .surface50Dark
                                                                : AppThemeData
                                                                    .surface50,
                                                            border: Border.all(
                                                                color: AppThemeData
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
                                                      const SizedBox(
                                                        height: 16,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: ButtonThem
                                                                .buildButton(
                                                              context,
                                                              title: 'done'.tr,
                                                              btnHeight: 45,
                                                              btnWidthRatio: 1,
                                                              btnColor:
                                                                  AppThemeData
                                                                      .primary200,
                                                              txtColor: isDarkMode
                                                                  ? AppThemeData
                                                                      .grey900Dark
                                                                  : AppThemeData
                                                                      .grey900,
                                                              onPress: () {
                                                                if (controller
                                                                        .otpController
                                                                        .text
                                                                        .toString()
                                                                        .length ==
                                                                    6) {
                                                                  Navigator.pop(
                                                                      context);
                                                                  controller
                                                                      .verifyOTP(
                                                                    userId: data
                                                                        .idUserApp!
                                                                        .toString(),
                                                                    rideId: data
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
                                                                        'id_ride': data
                                                                            .id
                                                                            .toString(),
                                                                        'id_user': data
                                                                            .idUserApp
                                                                            .toString(),
                                                                        'use_name':
                                                                            '${data.prenomConducteur.toString()} ${data.nomConducteur.toString()}',
                                                                        'from_id':
                                                                            Preferences.getInt(Preferences.userId).toString(),
                                                                      };

                                                                      controller
                                                                          .setOnRideRequest(
                                                                              bodyParams)
                                                                          .then(
                                                                              (value) {
                                                                        if (value !=
                                                                            null) {
                                                                          if (mounted) {
                                                                            Get.dialog(
                                                                              CustomDialogBox(
                                                                                title: "On ride Successfully".tr,
                                                                                descriptions: "Ride Successfully On ride.".tr,
                                                                                text: "Ok".tr,
                                                                                onPress: () {
                                                                                  Get.back();
                                                                                  controller.getNewRide();
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
                                                            child: ButtonThem
                                                                .buildBorderButton(
                                                              context,
                                                              title:
                                                                  'cancel'.tr,
                                                              btnHeight: 45,
                                                              btnWidthRatio: 1,
                                                              btnColor: isDarkMode
                                                                  ? AppThemeData
                                                                      .grey800
                                                                  : AppThemeData
                                                                      .grey100,
                                                              txtColor: isDarkMode
                                                                  ? AppThemeData
                                                                      .grey900Dark
                                                                  : AppThemeData
                                                                      .grey900,
                                                              btnBorderColor: isDarkMode
                                                                  ? AppThemeData
                                                                      .grey800
                                                                  : AppThemeData
                                                                      .grey100,
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
                                        // if (data.carDriverConfirmed == 1) {
                                        //
                                        // } else if (data.carDriverConfirmed == 2) {
                                        //   Get.back();
                                        //   ShowToastDialog.showToast("Customer decline the confirmation of driver and car information.");
                                        // } else if (data.carDriverConfirmed == 0) {
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
                        visible: data.statut == "on ride" ? true : false,
                        child: Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: CustomButton(
                              btnName: 'START NAVIGATION'.tr,
                              width: Responsive.width(100, context),
                              buttonColor: AppThemeData.secondary200,
                              textColor: isDarkMode
                                  ? AppThemeData.grey900
                                  : AppThemeData.grey100,
                              borderRadius: 10,
                              ontap: () async {
                                // Open external map with directions
                                await Constant.redirectMap(
                                  departureName: data.departName.toString(),
                                  originLat: double.tryParse(
                                      data.latitudeDepart.toString()),
                                  originLng: double.tryParse(
                                      data.longitudeDepart.toString()),
                                  arriveName: data.destinationName.toString(),
                                  latitude: double.tryParse(
                                      data.latitudeArrivee.toString()),
                                  longLatitude: double.tryParse(
                                      data.longitudeArrivee.toString()),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: data.statut == "on ride" ? true : false,
                        child: Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: CustomButton(
                              btnName: 'COMPLETE'.tr,
                              width: Responsive.width(100, context),
                              buttonColor: AppThemeData.success300,
                              textColor: isDarkMode
                                  ? AppThemeData.surface50
                                  : AppThemeData.surface50,
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
                                        Navigator.pop(context);
                                        Map<String, String> bodyParams = {
                                          'id_ride': data.id.toString(),
                                          'id_user': data.idUserApp.toString(),
                                          'driver_name':
                                              '${data.prenomConducteur.toString()} ${data.nomConducteur.toString()}',
                                          'from_id': Preferences.getInt(
                                                  Preferences.userId)
                                              .toString(),
                                        };
                                        controller
                                            .setCompletedRequest(
                                                bodyParams, data)
                                            .then(
                                          (value) {
                                            if (value != null) {
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
                                                      Get.back();
                                                      controller.getNewRide();
                                                    },
                                                    img: Image.asset(
                                                        'assets/images/green_checked.png'),
                                                  ),
                                                  barrierDismissible: false,
                                                );
                                              }
                                            }
                                          },
                                        );
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
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required bool isDarkMode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: TextScroll(
                value,
                mode: TextScrollMode.bouncing,
                pauseBetween: const Duration(seconds: 2),
                style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontFamily: AppThemeData.semiBold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        CustomText(
          text: label,
          size: 11,
          color: isDarkMode ? AppThemeData.grey500Dark : AppThemeData.grey500,
          weight: FontWeight.w500,
        ),
      ],
    );
  }

  final resonController = TextEditingController();

  buildShowBottomSheet(BuildContext context, RideData data,
      NewRideController controller, bool isDarkMode) {
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
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        "Write a reason for trip cancellation".tr,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
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
                                buttonColor: ConstantColors.blue,
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
                                              'id_ride': data.id.toString(),
                                              'id_user':
                                                  data.idUserApp.toString(),
                                              'name':
                                                  '${data.prenomConducteur.toString()} ${data.nomConducteur.toString()}',
                                              'from_id': Preferences.getInt(
                                                      Preferences.userId)
                                                  .toString(),
                                              'user_cat': controller.userModel
                                                  .value.userData!.userCat
                                                  .toString(),
                                              'reason': resonController.text
                                                  .toString(),
                                            };
                                            Get.back();
                                            controller
                                                .canceledRide(bodyParams)
                                                .then((value) {
                                              if (value != null) {
                                                resonController.clear();
                                                setState(() {});
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
                                                        Get.back();
                                                        controller.getNewRide();
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
                                outlineColor: ConstantColors.blue,
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
}
