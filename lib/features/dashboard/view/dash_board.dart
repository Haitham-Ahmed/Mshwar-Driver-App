// ignore_for_file: must_be_immutable

import 'package:cabme_driver/features/dashboard/controller/dash_board_controller.dart';
import 'package:cabme_driver/features/authentication/view/waiting_approval_screen.dart';
import 'package:cabme_driver/features/authentication/model/user_model.dart';
import 'package:cabme_driver/features/vehicle/view/vehicle_info_screen.dart';
import 'package:cabme_driver/features/document/view/document_status_screen.dart';
import 'package:cabme_driver/common/screens/botton_nav_bar.dart';
import 'package:cabme_driver/core/themes/constant_colors.dart';
import 'package:cabme_driver/core/themes/responsive.dart';
import 'package:cabme_driver/core/utils/dark_theme_provider.dart';
import 'package:cabme_driver/common/widget/custom_text.dart';
import 'package:cabme_driver/core/constant/constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';

class DashBoard extends StatelessWidget {
  DashBoard({super.key});

  DateTime backPress = DateTime.now();

  @override
  Widget build(BuildContext context) {
    // Check approval status before showing dashboard
    UserModel? userModel = Constant.getUserData();
    if (userModel.userData != null) {
      final isVerified = (userModel.userData!.isVerified == "yes" ||
          userModel.userData!.isVerified == 1);
      final statut = (userModel.userData!.statut == "yes");
      final isFullyApproved = isVerified && statut;

      if (!isFullyApproved) {
        // Not approved - redirect to waiting screen
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAll(() => const WaitingApprovalScreen());
        });
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }
    }

    return GetBuilder<DashBoardController>(
      init: DashBoardController(),
      builder: (controller) {
        controller.getDrawerItem();
        return WillPopScope(
          onWillPop: () async {
            final timeGap = DateTime.now().difference(backPress);
            final cantExit = timeGap >= const Duration(seconds: 2);
            backPress = DateTime.now();
            if (cantExit) {
              var snack = SnackBar(
                content: Text(
                  'Press Back button again to Exit'.tr,
                  style: TextStyle(color: Colors.white),
                ),
                duration: Duration(seconds: 2),
                backgroundColor: Colors.black,
              );
              ScaffoldMessenger.of(context).showSnackBar(snack);
              return false; // false will do nothing when back press
            } else {
              return true; // true will exit the app
            }
          },
          child: BottomNavBar(),
        );
      },
    );
  }
}

IconData _getIconData(String iconPath) {
  // Extract icon name from path
  final iconName = iconPath.split('/').last.replaceAll('.svg', '');

  switch (iconName) {
    case 'ic_car':
      return Iconsax.car;
    case 'ic_parcel_vehicle':
      return Iconsax.box;
    case 'ic_all_car':
      return Iconsax.box_1;
    case 'ic_profile':
      return Iconsax.user;
    case 'ic_wallet':
      return Iconsax.wallet_2;
    case 'ic_bank':
      return Iconsax.bank;
    case 'ic_lang':
      return Iconsax.language_square;
    case 'ic_terms':
      return Iconsax.document_text;
    case 'ic_privacy':
      return Iconsax.shield_tick;
    case 'ic_dark':
      return Iconsax.moon;
    case 'ic_star_line':
      return Iconsax.star;
    case 'ic_logout':
      return Iconsax.logout;
    default:
      return Iconsax.home; // default
  }
}

buildAppDrawer(BuildContext context, DashBoardController controller) {
  final themeChange = Provider.of<DarkThemeProvider>(context);
  final isDarkMode = themeChange.getThem();

  var drawerOptions = <Widget>[];
  bool isFirstItem = true;

  for (var i = 0; i < controller.drawerItems.length; i++) {
    var d = controller.drawerItems[i];

    final bool isFirstItemInSection = d.section != null &&
        (i == 0 || controller.drawerItems[i - 1].section != d.section);

    // Add section header if this is the first item with this section
    if (isFirstItemInSection) {
      drawerOptions.add(
        Padding(
          padding: EdgeInsets.only(
            top: isFirstItem ? 16 : 28,
            bottom: 8,
            left: 20,
            right: 20,
          ),
          child: CustomText(
            text: d.section ?? '',
            color: ConstantColors.blue,
            size: 12,
            weight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
      );
      isFirstItem = false;
    } else if (i == 0 && d.section == null) {
      // First item without section
      isFirstItem = false;
    }

    final bool isSelected = controller.selectedDrawerIndex.value == i;
    final bool isLogout = controller.drawerItems[i].title ==
        controller.drawerItems[controller.drawerItems.length - 1].title;

    // Add divider before logout item for better visibility
    if (isLogout && i > 0) {
      drawerOptions.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Divider(
            color: isDarkMode
                ? AppThemeData.grey300Dark.withOpacity(0.3)
                : AppThemeData.grey300.withOpacity(0.3),
            thickness: 1,
          ),
        ),
      );
    }

    // Add menu item with modern card design
    drawerOptions.add(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              controller.onSelectItem(i);
            },
            borderRadius: BorderRadius.circular(16),
            splashColor: ConstantColors.blue.withOpacity(0.1),
            highlightColor: ConstantColors.blue.withOpacity(0.05),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: isSelected
                    ? ConstantColors.blue.withOpacity(0.1)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? ConstantColors.blue.withOpacity(0.3)
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isLogout
                          ? AppThemeData.error50.withOpacity(0.1)
                          : isSelected
                              ? ConstantColors.blue.withOpacity(0.15)
                              : (isDarkMode
                                  ? AppThemeData.grey800Dark.withOpacity(0.5)
                                  : AppThemeData.grey100.withOpacity(0.8)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getIconData(d.icon),
                      size: 22,
                      color: isLogout
                          ? AppThemeData.error50
                          : isSelected
                              ? ConstantColors.blue
                              : (isDarkMode
                                  ? AppThemeData.grey400Dark
                                  : AppThemeData.grey800),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: CustomText(
                      text: d.title,
                      color: isLogout
                          ? AppThemeData.error50
                          : isSelected
                              ? ConstantColors.blue
                              : (isDarkMode
                                  ? AppThemeData.grey200Dark
                                  : AppThemeData.grey900),
                      size: 15,
                      weight: isLogout
                          ? FontWeight.w600
                          : (isSelected ? FontWeight.w600 : FontWeight.w500),
                    ),
                  ),
                  d.isSwitch == null
                      ? Icon(
                          Iconsax.arrow_right_3,
                          size: 18,
                          color: isLogout
                              ? AppThemeData.error50
                              : isSelected
                                  ? ConstantColors.blue
                                  : (isDarkMode
                                      ? AppThemeData.grey500Dark
                                      : AppThemeData.grey400),
                        )
                      : Transform.scale(
                          scale: 0.85,
                          child: Switch(
                            trackOutlineColor:
                                WidgetStateProperty.resolveWith<Color>(
                                    (Set<WidgetState> states) {
                              return Colors.transparent;
                            }),
                            inactiveTrackColor: isDarkMode
                                ? AppThemeData.grey800
                                : AppThemeData.grey200,
                            activeTrackColor: ConstantColors.blue,
                            thumbColor: WidgetStateProperty.resolveWith<Color>(
                                (Set<WidgetState> states) {
                              return Colors.white;
                            }),
                            value: isDarkMode,
                            onChanged: (value) =>
                                (themeChange.darkTheme = value == true ? 0 : 1),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  return Drawer(
    width: Responsive.width(85, context),
    backgroundColor:
        isDarkMode ? AppThemeData.surface50Dark : AppThemeData.surface50,
    child: Column(
      children: [
        // Modern Header with Gradient - Dark Navy
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ConstantColors.blue,
                ConstantColors.navy,
              ],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              child: Column(
                children: [
                  // Logo with modern container
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      "assets/icons/appLogo.png",
                      height: 60,
                      width: 60,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // User Name
                  CustomText(
                    text:
                        "${controller.userModel.value.userData!.prenom ?? ''} ${controller.userModel.value.userData!.nom ?? ''}",
                    color: Colors.white,
                    size: 20,
                    weight: FontWeight.bold,
                    align: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  // User Email with icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Iconsax.sms,
                        size: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: CustomText(
                          text:
                              controller.userModel.value.userData!.email ?? '',
                          color: Colors.white.withOpacity(0.9),
                          size: 13,
                          align: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        // Menu Items
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(top: 8, bottom: 40),
            children: drawerOptions,
          ),
        ),
      ],
    ),
  );
}

Future<void> showAlertDialog(BuildContext context, String type) async {
  return showDialog(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        // <-- SEE HERE
        title: Text('Information'.tr),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                  'To start earning with Mshwar you need to fill in your information'
                      .tr),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(
              'No'.tr,
              style: TextStyle(
                fontSize: 16,
                fontFamily: AppThemeData.regular,
                color: ConstantColors.blue,
              ),
            ),
            onPressed: () {
              Get.back();
            },
          ),
          TextButton(
            child: Text(
              'Yes'.tr,
              style: TextStyle(
                fontSize: 16,
                fontFamily: AppThemeData.regular,
                color: ConstantColors.blue,
              ),
            ),
            onPressed: () {
              if (type == "document") {
                Get.back();
                Get.to(DocumentStatusScreen());
              } else {
                Get.back();
                Get.to(const VehicleInfoScreen());
              }
            },
          ),
        ],
      );
    },
  );
}

class DrawerItem {
  String? title;
  String? icon;
  String? section;
  bool? isSwitch;

  DrawerItem(this.title, this.icon, {this.section, this.isSwitch});
}
