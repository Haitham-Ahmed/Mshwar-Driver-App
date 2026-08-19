import 'dart:convert';
import 'package:cabme_driver/common/widget/button.dart';
import 'package:cabme_driver/common/widget/custom_app_bar.dart';
import 'package:cabme_driver/common/widget/custom_text.dart';
import 'package:cabme_driver/core/themes/constant_colors.dart';
import 'package:cabme_driver/core/utils/dark_theme_provider.dart';
import 'package:cabme_driver/features/authentication/model/user_model.dart';
import 'package:cabme_driver/features/authentication/view/login_screen.dart';
import 'package:cabme_driver/features/dashboard/view/dash_board.dart';
import 'package:cabme_driver/core/constant/constant.dart';
import 'package:cabme_driver/core/utils/Preferences.dart';
import 'package:cabme_driver/service/api.dart';
import 'package:cabme_driver/core/constant/show_toast_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class WaitingApprovalScreen extends StatefulWidget {
  const WaitingApprovalScreen({super.key});

  @override
  State<WaitingApprovalScreen> createState() => _WaitingApprovalScreenState();
}

class _WaitingApprovalScreenState extends State<WaitingApprovalScreen> {
  bool _isRefreshing = false;

  Future<void> _refreshStatus() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      UserModel? currentUserModel = Constant.getUserData();
      if (currentUserModel.userData == null) {
        ShowToastDialog.showToast('No user data found'.tr);
        setState(() {
          _isRefreshing = false;
        });
        return;
      }

      Map<String, String> bodyParams = {
        'phone': currentUserModel.userData!.phone.toString(),
        'user_cat': "driver",
        'email': currentUserModel.userData!.email.toString(),
        'login_type': currentUserModel.userData!.loginType.toString(),
      };

      final response = await http.post(
        Uri.parse(API.getProfileByPhone),
        headers: API.header,
        body: jsonEncode(bodyParams),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        if (responseBody['success'] == "success") {
          UserModel? updatedUserModel = UserModel.fromJson(responseBody);
          Preferences.setString(Preferences.user, jsonEncode(updatedUserModel));

          final isVerified = (updatedUserModel.userData?.isVerified == "yes" ||
              updatedUserModel.userData?.isVerified == 1);
          final statut = (updatedUserModel.userData?.statut == "yes");
          final isFullyApproved = isVerified && statut;

          if (isFullyApproved) {
            // Status updated - approved!
            ShowToastDialog.showToast('Your account has been approved!'.tr);
            Get.offAll(() => DashBoard());
          } else {
            // Still waiting
            ShowToastDialog.showToast('Your account is still under review.'.tr);
            setState(() {
              _isRefreshing = false;
            });
          }
        } else {
          ShowToastDialog.showToast(
              responseBody['error'] ?? 'Failed to check status'.tr);
          setState(() {
            _isRefreshing = false;
          });
        }
      } else {
        ShowToastDialog.showToast('Failed to check status'.tr);
        setState(() {
          _isRefreshing = false;
        });
      }
    } catch (e) {
      ShowToastDialog.showToast('Error checking status: ${e.toString()}'.tr);
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDarkMode = themeChange.getThem();

    UserModel? userModel = Constant.getUserData();
    final isVerified = (userModel.userData?.isVerified == "yes" ||
        // ignore: unrelated_type_equality_checks
        userModel.userData?.isVerified == 1);
    final statut = (userModel.userData?.statut == "yes");

    // Check if fully approved
    final isFullyApproved = isVerified && statut;

    return Scaffold(
      appBar: CustomAppBar(
        title: "Account Status".tr,
        showBackButton: false,
      ),
      backgroundColor:
          isDarkMode ? AppThemeData.surface50Dark : AppThemeData.surface50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: isFullyApproved
                      ? AppThemeData.success50
                      : AppThemeData.yellow,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isFullyApproved ? Iconsax.tick_circle : Iconsax.clock,
                  size: 80,
                  color: isFullyApproved
                      ? AppThemeData.success300
                      : AppThemeData.warning200,
                ),
              ),
              const SizedBox(height: 32),

              // Title
              CustomText(
                text: isFullyApproved
                    ? "Account Approved!".tr
                    : "Waiting for Approval".tr,
                size: 24,
                weight: FontWeight.bold,
                align: TextAlign.center,
                color: isDarkMode
                    ? AppThemeData.grey900Dark
                    : AppThemeData.grey900,
              ),
              const SizedBox(height: 16),

              // Message
              CustomText(
                text: isFullyApproved
                    ? "Congratulations! Your driver account has been approved. You can now start receiving ride requests."
                        .tr
                    : "Your account is currently under review. Our admin team will review your documents and vehicle information. You will receive a notification once your account is approved."
                        .tr,
                size: 16,
                weight: FontWeight.w400,
                align: TextAlign.center,
                color: isDarkMode
                    ? AppThemeData.grey500Dark
                    : AppThemeData.grey500,
              ),
              const SizedBox(height: 48),

              // Status indicators
              if (!isFullyApproved) ...[
                _buildStatusItem(
                  context,
                  "Documents Submitted".tr,
                  "Your documents are being reviewed".tr,
                  Iconsax.document,
                  isDarkMode,
                ),
                const SizedBox(height: 16),
                _buildStatusItem(
                  context,
                  "Vehicle Information Submitted".tr,
                  "Your vehicle details are being reviewed".tr,
                  Iconsax.car,
                  isDarkMode,
                ),
                const SizedBox(height: 32),
              ],

              // Action button
              if (isFullyApproved)
                CustomButton(
                  btnName: "Go to Dashboard".tr,
                  ontap: () {
                    Get.offAll(() => DashBoard());
                  },
                ),

              // Action buttons for waiting approval
              if (!isFullyApproved) ...[
                const SizedBox(height: 24),
                // Check Status button
                CustomButton(
                  btnName: _isRefreshing
                      ? "Checking Status...".tr
                      : "Check Status".tr,
                  ontap: _isRefreshing ? null : _refreshStatus,
                  isOutlined: false,
                ),
                const SizedBox(height: 16),
                // Logout button
                TextButton(
                  onPressed: () async {
                    // Show confirmation dialog
                    final shouldLogout = await Get.dialog<bool>(
                      AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: CustomText(
                          text: 'Log Out'.tr,
                          size: 20,
                          weight: FontWeight.w600,
                        ),
                        content: CustomText(
                          text:
                              'Are you sure you want to log out? You can log in again with a different account.'
                                  .tr,
                          size: 16,
                          weight: FontWeight.w400,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(result: false),
                            child: CustomText(
                              text: 'Cancel'.tr,
                              size: 16,
                              weight: FontWeight.w500,
                              color: isDarkMode
                                  ? AppThemeData.grey400Dark
                                  : AppThemeData.grey400,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Get.back(result: true),
                            child: CustomText(
                              text: 'Log Out'.tr,
                              size: 16,
                              weight: FontWeight.w600,
                              color: AppThemeData.error50,
                            ),
                          ),
                        ],
                      ),
                    );

                    if (shouldLogout == true) {
                      // Clear all preferences
                      Preferences.clearKeyData(Preferences.isLogin);
                      Preferences.clearKeyData(Preferences.user);
                      Preferences.clearKeyData(Preferences.userId);
                      Preferences.clearKeyData(Preferences.accesstoken);
                      // Clear API header
                      API.header['accesstoken'] = '';
                      Get.offAll(() => const LoginScreen());
                    }
                  },
                  child: CustomText(
                    text: "Log Out".tr,
                    size: 16,
                    weight: FontWeight.w500,
                    color: isDarkMode
                        ? AppThemeData.grey500Dark
                        : AppThemeData.grey500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppThemeData.grey800Dark : AppThemeData.surface50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? AppThemeData.grey200Dark : AppThemeData.grey200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppThemeData.primary200.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppThemeData.primary200,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: title,
                  size: 14,
                  weight: FontWeight.w600,
                  color: isDarkMode
                      ? AppThemeData.grey900Dark
                      : AppThemeData.grey900,
                ),
                const SizedBox(height: 4),
                CustomText(
                  text: subtitle,
                  size: 12,
                  weight: FontWeight.w400,
                  color: isDarkMode
                      ? AppThemeData.grey500Dark
                      : AppThemeData.grey500,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
