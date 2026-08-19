import 'package:cabme_driver/common/widget/custom_app_bar.dart';
import 'package:cabme_driver/common/widget/custom_text.dart';
import 'package:cabme_driver/core/themes/constant_colors.dart';
import 'package:cabme_driver/core/utils/Preferences.dart';
import 'package:cabme_driver/core/utils/dark_theme_provider.dart';
import 'package:cabme_driver/features/authentication/view/login_screen.dart';
import 'package:cabme_driver/features/bank/view/show_bank_details.dart';
import 'package:cabme_driver/features/car_service/view/car_service_history_screen.dart';
import 'package:cabme_driver/features/commission/view/commission_page.dart';
import 'package:cabme_driver/features/document/view/document_status_screen.dart';
import 'package:cabme_driver/features/localization/view/localization_screen.dart';
import 'package:cabme_driver/features/privacy_policy/view/privacy_policy_screen.dart';
import 'package:cabme_driver/features/profile/view/my_profile_screen.dart';
import 'package:cabme_driver/features/terms_service/view/terms_of_service_screen.dart';
import 'package:cabme_driver/features/vehicle/view/vehicle_info_screen.dart';
import 'package:cabme_driver/features/wallet/view/wallet_screen.dart';
import 'package:cabme_driver/features/notifications/view/notification_screen.dart';
import 'package:cabme_driver/service/api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDarkMode = themeChange.getThem();

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Settings'.tr,
        showBackButton: false,
      ),
      backgroundColor:
          isDarkMode ? AppThemeData.surface50Dark : AppThemeData.surface50,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Vehicle & Service Management Section
            _buildSectionHeader(
              'Vehicle & Service Management:'.tr,
              isDarkMode: isDarkMode,
            ),
            _buildSettingsCard(
              isDarkMode: isDarkMode,
              children: [
                _buildSettingsItem(
                  icon: Iconsax.document,
                  title: 'Documents'.tr,
                  isDarkMode: isDarkMode,
                  onTap: () => Get.to(DocumentStatusScreen()),
                ),
                _buildDivider(isDarkMode),
                _buildSettingsItem(
                  icon: Iconsax.car,
                  title: 'Vehicle information'.tr,
                  isDarkMode: isDarkMode,
                  onTap: () => Get.to(const VehicleInfoScreen()),
                ),
                _buildDivider(isDarkMode),
                _buildSettingsItem(
                  icon: Iconsax.box_1,
                  title: 'Car Service History'.tr,
                  isDarkMode: isDarkMode,
                  onTap: () => Get.to(const CarServiceBookHistory()),
                ),
                _buildDivider(isDarkMode),
                _buildSettingsItem(
                  icon: Iconsax.wallet_3,
                  title: 'Commission'.tr,
                  isDarkMode: isDarkMode,
                  onTap: () => Get.to(const CommissionPage()),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Account & Financials Section
            _buildSectionHeader(
              'Account & Financials:'.tr,
              isDarkMode: isDarkMode,
            ),
            _buildSettingsCard(
              isDarkMode: isDarkMode,
              children: [
                _buildSettingsItem(
                  icon: Iconsax.user,
                  title: 'My Profile'.tr,
                  isDarkMode: isDarkMode,
                  onTap: () => Get.to(() => MyProfileScreen()),
                ),
                _buildDivider(isDarkMode),
                _buildSettingsItem(
                  icon: Iconsax.wallet_2,
                  title: 'My Earnings'.tr,
                  isDarkMode: isDarkMode,
                  onTap: () => Get.to(WalletScreen()),
                ),
                _buildDivider(isDarkMode),
                _buildSettingsItem(
                  icon: Iconsax.bank,
                  title: 'Add Bank'.tr,
                  isDarkMode: isDarkMode,
                  onTap: () => Get.to(const ShowBankDetails()),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Settings & Support Section
            _buildSectionHeader(
              'Settings & Support:'.tr,
              isDarkMode: isDarkMode,
            ),
            _buildSettingsCard(
              isDarkMode: isDarkMode,
              children: [
                _buildSettingsItem(
                  icon: Iconsax.notification,
                  title: 'Notifications'.tr,
                  isDarkMode: isDarkMode,
                  onTap: () => Get.to(() => const NotificationScreen()),
                ),
                _buildDivider(isDarkMode),
                _buildSettingsItem(
                  icon: Iconsax.language_square,
                  title: 'Change Language'.tr,
                  isDarkMode: isDarkMode,
                  onTap: () => Get.to(
                      const LocalizationScreens(intentType: "dashBoard")),
                ),
                _buildDivider(isDarkMode),
                _buildSettingsItem(
                  icon: Iconsax.document_text,
                  title: 'Terms of Service'.tr,
                  isDarkMode: isDarkMode,
                  onTap: () => Get.to(const TermsOfServiceScreen()),
                ),
                _buildDivider(isDarkMode),
                _buildSettingsItem(
                  icon: Iconsax.shield_tick,
                  title: 'Privacy Policy'.tr,
                  isDarkMode: isDarkMode,
                  onTap: () => Get.to(const PrivacyPolicyScreen()),
                ),
                _buildDivider(isDarkMode),
                _buildSettingsItem(
                  icon: Iconsax.moon,
                  title: 'Dark Mode'.tr,
                  isDarkMode: isDarkMode,
                  isSwitch: true,
                  switchValue: isDarkMode,
                  onSwitchChanged: (value) {
                    themeChange.darkTheme = value ? 0 : 1;
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Feedback & Support Section
            _buildSectionHeader(
              'Feedback & Support'.tr,
              isDarkMode: isDarkMode,
            ),
            _buildSettingsCard(
              isDarkMode: isDarkMode,
              children: [
                _buildSettingsItem(
                  icon: Iconsax.star,
                  title: 'Rate the App'.tr,
                  isDarkMode: isDarkMode,
                  onTap: () async {
                    final InAppReview inAppReview = InAppReview.instance;
                    try {
                      if (await inAppReview.isAvailable()) {
                        inAppReview.requestReview();
                      } else {
                        inAppReview.openStoreListing();
                      }
                    } catch (e) {
                      // Handle error
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Log Out Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildLogoutButton(isDarkMode: isDarkMode),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {required bool isDarkMode}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: CustomText(
        text: title,
        size: 12,
        weight: FontWeight.w600,
        color: ConstantColors.blue,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildSettingsCard({
    required bool isDarkMode,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppThemeData.grey800Dark : AppThemeData.surface50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? AppThemeData.grey200Dark : AppThemeData.grey200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required bool isDarkMode,
    VoidCallback? onTap,
    bool isSwitch = false,
    bool switchValue = false,
    ValueChanged<bool>? onSwitchChanged,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: ConstantColors.blue.withOpacity(0.1),
        highlightColor: ConstantColors.blue.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ConstantColors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: ConstantColors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomText(
                  text: title,
                  size: 16,
                  weight: FontWeight.w500,
                  color: isDarkMode
                      ? AppThemeData.grey900Dark
                      : AppThemeData.grey900,
                ),
              ),
              if (isSwitch)
                Transform.scale(
                  scale: 0.85,
                  child: Switch(
                    trackOutlineColor: WidgetStateProperty.resolveWith<Color>(
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
                    value: switchValue,
                    onChanged: onSwitchChanged,
                  ),
                )
              else
                Icon(
                  Iconsax.arrow_right_3,
                  size: 18,
                  color: isDarkMode
                      ? AppThemeData.grey400Dark
                      : AppThemeData.grey400,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        thickness: 1,
        color: isDarkMode
            ? AppThemeData.grey200Dark.withOpacity(0.3)
            : AppThemeData.grey200,
      ),
    );
  }

  Widget _buildLogoutButton({required bool isDarkMode}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
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
                text: 'Are you sure you want to log out?'.tr,
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
                    color: AppThemeData.grey400,
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
            Get.offAll(const LoginScreen());
          }
        },
        borderRadius: BorderRadius.circular(16),
        splashColor: AppThemeData.error50.withOpacity(0.1),
        highlightColor: AppThemeData.error50.withOpacity(0.05),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppThemeData.error50.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppThemeData.error50.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Iconsax.logout,
                size: 22,
                color: AppThemeData.error50,
              ),
              const SizedBox(width: 12),
              CustomText(
                text: 'Log Out'.tr,
                size: 16,
                weight: FontWeight.w600,
                color: AppThemeData.error50,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
