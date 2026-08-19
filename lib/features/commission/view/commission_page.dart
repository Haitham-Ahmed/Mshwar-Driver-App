import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cabme_driver/common/widget/custom_app_bar.dart';
import 'package:cabme_driver/common/widget/custom_text.dart';
import 'package:cabme_driver/core/themes/constant_colors.dart';
import 'package:cabme_driver/core/utils/dark_theme_provider.dart';
import 'package:provider/provider.dart';

import '../controller/commission_controller.dart';

class CommissionPage extends StatefulWidget {
  const CommissionPage({super.key});

  @override
  State<CommissionPage> createState() => _CommissionPageState();
}

class _CommissionPageState extends State<CommissionPage> {
  final commissionController = Get.put(CommissionController());
  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Scaffold(
      appBar: CustomAppBar(
        title: "Rides Commission".tr,
      ),
      backgroundColor: themeChange.getThem()
          ? AppThemeData.surface50Dark
          : AppThemeData.surface50,
      body: GetBuilder<CommissionController>(builder: (controller) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _buildInfoCard(
                context: context,
                themeChange: themeChange,
                title: "Driver Name".tr,
                value:
                    "${controller.userdata?.nom ?? ""} ${controller.userdata?.prenom ?? ""}",
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                context: context,
                themeChange: themeChange,
                title: "Total Rides".tr,
                value:
                    controller.commissionModel?.totalRides?.toString() ?? "0",
                icon: Icons.directions_car_outlined,
                valueColor: AppThemeData.primary200,
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                context: context,
                themeChange: themeChange,
                title: "Commission Rate".tr,
                value:
                    "${controller.commissionModel?.commissionRate?.toString() ?? "0"}%",
                icon: Icons.percent_outlined,
                valueColor: AppThemeData.success300,
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                context: context,
                themeChange: themeChange,
                title: "Driver Earnings".tr,
                value: controller.commissionModel?.totalDriverEarnings
                        ?.toString() ??
                    "0",
                icon: Icons.account_balance_wallet_outlined,
                valueColor: AppThemeData.success300,
                isEarnings: true,
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required DarkThemeProvider themeChange,
    required String title,
    required String value,
    required IconData icon,
    Color? valueColor,
    bool isEarnings = false,
  }) {
    final isDarkMode = themeChange.getThem();
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (valueColor ?? AppThemeData.primary200).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 24,
              color: valueColor ?? AppThemeData.primary200,
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
                  weight: FontWeight.w500,
                  color: isDarkMode
                      ? AppThemeData.grey400Dark
                      : AppThemeData.grey400,
                ),
                const SizedBox(height: 4),
                CustomText(
                  text: isEarnings && value != "0" ? value : value,
                  size: 20,
                  weight: FontWeight.w700,
                  color: valueColor ??
                      (isDarkMode
                          ? AppThemeData.grey900Dark
                          : AppThemeData.grey900),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
