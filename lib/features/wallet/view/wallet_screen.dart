import 'dart:convert';
import 'dart:io';
import 'package:cabme_driver/core/constant/constant.dart';
import 'package:cabme_driver/core/constant/logdata.dart';
import 'package:cabme_driver/core/constant/show_toast_dialog.dart';
import 'package:cabme_driver/features/dashboard/controller/dash_board_controller.dart';
import 'package:cabme_driver/features/wallet/model/payStackURLModel.dart';
import 'package:cabme_driver/features/wallet/controller/wallet_controller.dart';
import 'package:cabme_driver/features/wallet/controller/withdrawals_controller.dart';
import 'package:cabme_driver/features/wallet/model/payment_setting_model.dart';
import 'package:cabme_driver/features/ride/model/ride_model.dart';
import 'package:cabme_driver/features/wallet/model/trancation_model.dart';
import 'package:cabme_driver/features/authentication/model/user_model.dart';
import 'package:cabme_driver/features/wallet/model/xenditModel.dart';
import 'package:cabme_driver/features/bank/view/add_bank_account.dart';
import 'package:cabme_driver/features/ride/view/completed/trip_history_screen.dart';
import 'package:cabme_driver/features/wallet/view/mercadopago_screen.dart';
import 'package:cabme_driver/features/wallet/view/midtrans_screen.dart';
import 'package:cabme_driver/features/wallet/view/orangePayScreen.dart';
import 'package:cabme_driver/features/wallet/view/payStackScreen.dart';
import 'package:cabme_driver/features/wallet/view/payfast_screen.dart';
import 'package:cabme_driver/features/wallet/view/paystack_url_generator.dart';
import 'package:cabme_driver/features/wallet/view/xenditScreen.dart';
import 'package:cabme_driver/service/api.dart';
import 'package:cabme_driver/common/widget/custom_app_bar.dart';
import 'package:cabme_driver/common/widget/custom_text.dart';
import 'package:cabme_driver/common/widget/button.dart';
import 'package:cabme_driver/common/widget/text_field.dart';
import 'package:cabme_driver/core/themes/constant_colors.dart';
import 'package:cabme_driver/core/themes/radio_button.dart';
import 'package:cabme_driver/core/utils/Preferences.dart';
import 'package:cabme_driver/core/utils/dark_theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_paypal_native/flutter_paypal_native.dart';
// import 'package:flutter_paypal_native/models/custom/currency_code.dart';
// import 'package:flutter_paypal_native/models/custom/environment.dart';
// import 'package:flutter_paypal_native/models/custom/order_callback.dart';
// import 'package:flutter_paypal_native/models/custom/purchase_unit.dart';
// import 'package:flutter_paypal_native/models/custom/user_action.dart';
// import 'package:flutter_paypal_native/str_helper.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'dart:math' as maths;
import 'package:provider/provider.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
// import 'package:flutter_stripe/flutter_stripe.dart' as stripe1;
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class WalletScreen extends StatelessWidget {
  WalletScreen({super.key});

  // final Razorpay razorPayController = Razorpay();

  static final GlobalKey<FormState> _walletFormKey = GlobalKey<FormState>();
  final controllerDashBoard = Get.put(DashBoardController());
  final walletController = Get.put(WalletController());

  @override
  Widget build(BuildContext context) {
    return GetX<WalletController>(
        init: WalletController(),
        initState: (state) {
          // initPayPal();
          walletController.getTrancation();
        },
        builder: (walletController) {
          final themeChange = Provider.of<DarkThemeProvider>(context);

          return Scaffold(
            appBar: CustomAppBar(
              title: 'My Earnings'.tr,
              showBackButton: false,
            ),
            backgroundColor: themeChange.getThem()
                ? AppThemeData.surface50Dark
                : AppThemeData.surface50,
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: () => walletController.getTrancation(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Modern Earnings Card
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                ConstantColors.blue,
                                ConstantColors.navy,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Iconsax.wallet_3,
                                          size: 24,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CustomText(
                                            text: 'Total Earnings'.tr,
                                            size: 14,
                                            weight: FontWeight.w500,
                                            color:
                                                Colors.white.withOpacity(0.9),
                                          ),
                                          const SizedBox(height: 4),
                                          CustomText(
                                            text: Constant().amountShow(
                                                amount: walletController
                                                    .totalEarn
                                                    .toString()),
                                            size: 32,
                                            weight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              CustomButton(
                                btnName: 'Withdraw'.tr,
                                height: 50,
                                buttonColor: Colors.white,
                                textColor: ConstantColors.blue,
                                borderRadius: 12,
                                icon: Icon(
                                  Iconsax.arrow_down,
                                  size: 20,
                                  color: ConstantColors.blue,
                                ),
                                ontap: () {
                                  walletController
                                      .getBankDetails()
                                      .then((value) {
                                    if (value == null) {
                                      ShowToastDialog.showToast(
                                          'Please Update bank Details');
                                    } else {
                                      buildShowBottomSheet(
                                          context,
                                          walletController,
                                          themeChange.getThem());
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Transaction History Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomText(
                              text: 'Transaction History'.tr,
                              size: 20,
                              weight: FontWeight.w600,
                              color: themeChange.getThem()
                                  ? AppThemeData.grey900Dark
                                  : AppThemeData.grey900,
                            ),
                            if (walletController.transactionList.isNotEmpty)
                              CustomText(
                                text:
                                    '${walletController.transactionList.length} ${'Transactions'.tr}',
                                size: 14,
                                weight: FontWeight.w500,
                                color: themeChange.getThem()
                                    ? AppThemeData.grey500Dark
                                    : AppThemeData.grey500,
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Transaction List
                        walletController.isLoading.value
                            ? const SizedBox()
                            : walletController.transactionList.isEmpty
                                ? LayoutBuilder(
                                    builder: (context, constraints) {
                                      final screenHeight =
                                          MediaQuery.of(context).size.height;
                                      final availableHeight =
                                          screenHeight - 340;
                                      return SizedBox(
                                        height: availableHeight > 200
                                            ? availableHeight
                                            : 300,
                                        child: Center(
                                          child: Constant.emptyView(
                                              "No transaction found".tr,
                                              context),
                                        ),
                                      );
                                    },
                                  )
                                : ListView.separated(
                                    primary: false,
                                    shrinkWrap: true,
                                    itemCount:
                                        walletController.transactionList.length,
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(height: 12),
                                    itemBuilder: (context, index) {
                                      return buildTransactionCard(
                                          context,
                                          walletController
                                              .transactionList[index],
                                          themeChange.getThem());
                                    },
                                  ),
                        const SizedBox(height: 20),
                        // Withdrawal History Section
                        CustomText(
                          text: 'Withdrawal History'.tr,
                          size: 20,
                          weight: FontWeight.w600,
                          color: themeChange.getThem()
                              ? AppThemeData.grey900Dark
                              : AppThemeData.grey900,
                        ),
                        const SizedBox(height: 16),
                        GetX<WithdrawalsController>(
                          init: WithdrawalsController(),
                          builder: (withdrawalsController) {
                            return withdrawalsController.isLoading.value
                                ? const SizedBox()
                                : withdrawalsController.rideList.isEmpty
                                    ? Container(
                                        padding: const EdgeInsets.all(32),
                                        decoration: BoxDecoration(
                                          color: themeChange.getThem()
                                              ? AppThemeData.grey800Dark
                                              : Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                            color: themeChange.getThem()
                                                ? AppThemeData.grey200Dark
                                                : AppThemeData.grey200,
                                            width: 1,
                                          ),
                                        ),
                                        child: Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Iconsax.wallet_3,
                                                size: 48,
                                                color: themeChange.getThem()
                                                    ? AppThemeData.grey400Dark
                                                    : AppThemeData.grey400,
                                              ),
                                              const SizedBox(height: 16),
                                              CustomText(
                                                text:
                                                    "You don't have any Withdrawals request"
                                                        .tr,
                                                size: 16,
                                                weight: FontWeight.w500,
                                                align: TextAlign.center,
                                                color: themeChange.getThem()
                                                    ? AppThemeData.grey400Dark
                                                    : AppThemeData.grey400,
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : ListView.separated(
                                        primary: false,
                                        shrinkWrap: true,
                                        itemCount: withdrawalsController
                                            .rideList.length,
                                        separatorBuilder: (context, index) =>
                                            const SizedBox(height: 12),
                                        itemBuilder: (context, index) {
                                          return buildWithdrawalCard(
                                              context,
                                              withdrawalsController
                                                  .rideList[index],
                                              themeChange.getThem());
                                        },
                                      );
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  Widget buildTransactionCard(
      BuildContext context, TansactionData data, bool isDarkMode) {
    final isDebit = (data.orderType != null &&
            data.orderType.toString() == "ride" &&
            data.amount!.toString().contains('-')) ||
        (data.orderType != null &&
            data.orderType.toString() == "parcel" &&
            data.transactionAmount!.toString().contains('-'));

    String title = "";
    String amount = "";
    Color amountColor = AppThemeData.success300;

    if (data.orderType != null && data.orderType.toString() == "ride") {
      title = data.amount!.toString().contains('-')
          ? "Admin Commission Debited".tr
          : "Booking Amount credited".tr;
      amount = data.amount!.toString().contains('-')
          ? "(-${Constant().amountShow(amount: data.amount!.split("-").last.toString())})"
          : data.amount!.isNotEmpty
              ? Constant().amountShow(
                  amount:
                      "${double.parse(data.amount!.toString()) + double.parse(data.adminCommission!.isNotEmpty ? data.adminCommission!.toString() : "0.0")}")
              : "";
      amountColor = data.amount!.toString().contains('-')
          ? AppThemeData.error50
          : AppThemeData.success300;
    } else if (data.orderType != null &&
        data.orderType.toString() == "parcel") {
      title = data.transactionAmount!.toString().contains('-')
          ? "Admin Commission Debited".tr
          : "Parcel Amount credited".tr;
      amount = data.transactionAmount!.toString().contains('-')
          ? "(-${Constant().amountShow(amount: data.transactionAmount!.split("-").last.toString())})"
          : data.transactionAmount!.isNotEmpty
              ? Constant().amountShow(
                  amount:
                      "${double.parse(data.transactionAmount!.toString()) + double.parse(data.adminCommission!.isNotEmpty ? data.adminCommission!.toString() : "0.0")}")
              : "";
      amountColor = data.transactionAmount!.toString().contains('-')
          ? AppThemeData.error50
          : AppThemeData.success300;
    } else {
      title = "${"Wallet Topup Via".tr} ${data.libelle}";
      amount = Constant()
          .amountShow(amount: "+${double.parse(data.amount!.toString())}");
      amountColor = AppThemeData.success300;
    }

    return InkWell(
      onTap: () {
        if (data.orderType != null && data.orderType.toString() == "ride") {
          Get.to(const TripHistoryScreen(), arguments: {
            "rideData": RideData.fromJson(data.toJson()),
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? AppThemeData.grey800Dark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDarkMode ? AppThemeData.grey200Dark : AppThemeData.grey200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon Container
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isDebit
                    ? AppThemeData.error50.withOpacity(0.1)
                    : AppThemeData.success300.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isDebit ? Iconsax.arrow_down_2 : Iconsax.arrow_up_2,
                size: 24,
                color: isDebit ? AppThemeData.error50 : AppThemeData.success300,
              ),
            ),
            const SizedBox(width: 16),
            // Transaction Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: title,
                    size: 16,
                    weight: FontWeight.w600,
                    color: isDarkMode
                        ? AppThemeData.grey900Dark
                        : AppThemeData.grey900,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Iconsax.calendar,
                        size: 14,
                        color: isDarkMode
                            ? AppThemeData.grey500Dark
                            : AppThemeData.grey500,
                      ),
                      const SizedBox(width: 6),
                      CustomText(
                        text: data.creer != null
                            ? data.creer.toString()
                            : data.createdAt.toString(),
                        size: 13,
                        weight: FontWeight.w400,
                        color: isDarkMode
                            ? AppThemeData.grey500Dark
                            : AppThemeData.grey500,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CustomText(
                  text: amount,
                  size: 18,
                  weight: FontWeight.w700,
                  color: amountColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildWithdrawalCard(
      BuildContext context, dynamic withdrawalData, bool isDarkMode) {
    final isSuccess = withdrawalData.statut.toString() == "success";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppThemeData.grey800Dark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? AppThemeData.grey200Dark : AppThemeData.grey200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isSuccess
                      ? AppThemeData.success300.withOpacity(0.1)
                      : AppThemeData.error50.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Iconsax.wallet_3,
                  size: 24,
                  color: isSuccess
                      ? AppThemeData.success300
                      : AppThemeData.error50,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: withdrawalData.creer.toString(),
                      size: 16,
                      weight: FontWeight.w600,
                      color: isDarkMode
                          ? AppThemeData.grey900Dark
                          : AppThemeData.grey900,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSuccess
                            ? AppThemeData.success300.withOpacity(0.1)
                            : AppThemeData.error50.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: CustomText(
                        text: withdrawalData.statut.toString().toUpperCase(),
                        size: 12,
                        weight: FontWeight.w600,
                        color: isSuccess
                            ? AppThemeData.success300
                            : AppThemeData.error50,
                      ),
                    ),
                  ],
                ),
              ),
              CustomText(
                text: Constant()
                    .amountShow(amount: withdrawalData.amount.toString()),
                size: 18,
                weight: FontWeight.w700,
                color:
                    isSuccess ? AppThemeData.success300 : AppThemeData.error50,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(
            color: isDarkMode
                ? AppThemeData.grey200Dark.withOpacity(0.3)
                : AppThemeData.grey200,
            thickness: 1,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Iconsax.bank,
                size: 16,
                color: isDarkMode
                    ? AppThemeData.grey400Dark
                    : AppThemeData.grey400,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: withdrawalData.bankName.toString(),
                      size: 14,
                      weight: FontWeight.w600,
                      color: isDarkMode
                          ? AppThemeData.grey900Dark
                          : AppThemeData.grey900,
                    ),
                    const SizedBox(height: 2),
                    CustomText(
                      text: withdrawalData.accountNo.toString(),
                      size: 13,
                      weight: FontWeight.w400,
                      color: isDarkMode
                          ? AppThemeData.grey400Dark
                          : AppThemeData.grey400,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (withdrawalData.note != null &&
              withdrawalData.note.toString().isNotEmpty) ...[
            const SizedBox(height: 12),
            Divider(
              color: isDarkMode
                  ? AppThemeData.grey200Dark.withOpacity(0.3)
                  : AppThemeData.grey200,
              thickness: 1,
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Iconsax.note,
                  size: 16,
                  color: isDarkMode
                      ? AppThemeData.grey400Dark
                      : AppThemeData.grey400,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomText(
                    text: withdrawalData.note.toString(),
                    size: 13,
                    weight: FontWeight.w400,
                    color: isDarkMode
                        ? AppThemeData.grey400Dark
                        : AppThemeData.grey400,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  buildShowBottomSheet(
      BuildContext context, WalletController controller, bool isDarkModel) {
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
                    Center(
                      child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          height: 10,
                          width: 75,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: isDarkModel
                                ? AppThemeData.grey300Dark
                                : AppThemeData.grey300,
                          )),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    InkWell(
                        onTap: () {
                          Get.back();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 0, vertical: 0),
                          child: Transform(
                            alignment: Alignment.center,
                            transform:
                                Directionality.of(context) == TextDirection.rtl
                                    ? Matrix4.rotationY(3.14159)
                                    : Matrix4.identity(),
                            child: Icon(
                              Iconsax.arrow_left,
                              color: isDarkModel
                                  ? AppThemeData.grey900Dark
                                  : AppThemeData.grey900,
                              size: 24,
                            ),
                          ),
                        )),
                    const SizedBox(
                      height: 20,
                    ),
                    CustomText(
                      text: "Withdrawal Amount".tr,
                      size: 18,
                      weight: FontWeight.w500,
                      color: isDarkModel
                          ? AppThemeData.grey800Dark
                          : AppThemeData.grey800,
                    ),
                    const SizedBox(height: 5),
                    Container(
                      decoration: BoxDecoration(
                          color: isDarkModel
                              ? AppThemeData.surface50Dark
                              : AppThemeData.surface50,
                          border: Border.all(
                            color: isDarkModel
                                ? AppThemeData.grey200Dark
                                : AppThemeData.grey200,
                          ),
                          borderRadius: BorderRadius.circular(8)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            CustomTextField(
                              text: 'Amount'.tr,
                              controller:
                                  walletController.amountController.value,
                              keyboardType: TextInputType.number,
                              prefixIcon: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: Center(
                                  widthFactor: 0.0,
                                  child: Text(
                                    'KWD',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontFamily: AppThemeData.semiBold,
                                      color: isDarkModel
                                          ? AppThemeData.grey900Dark
                                          : AppThemeData.grey900,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              text: 'Add Note'.tr,
                              controller: walletController.noteController.value,
                              keyboardType: TextInputType.text,
                              prefixIcon: Icon(
                                Iconsax.note_text,
                                color: isDarkModel
                                    ? AppThemeData.grey400Dark
                                    : AppThemeData.grey400,
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        "Bank Details".tr,
                        style: TextStyle(
                          fontSize: 18,
                          color: isDarkModel
                              ? AppThemeData.grey800Dark
                              : AppThemeData.grey800,
                          fontFamily: AppThemeData.medium,
                        ),
                      ),
                    ),
                    controller.bankDetails.accountNo != null
                        ? Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: InkWell(
                              onTap: () {
                                showModalBottomSheet(
                                    isDismissible: true,
                                    isScrollControlled: true,
                                    context: context,
                                    backgroundColor: isDarkModel
                                        ? AppThemeData.grey50Dark
                                        : AppThemeData.grey50,
                                    builder: (context) {
                                      return const AddBankAccount();
                                    });
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0XFFFDEBE7), // Blueish
                                        Color(0XFFFFF4E6), // Lighter Blue
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  child: Stack(children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              controller.bankDetails.bankName
                                                  .toString(),
                                              style: TextStyle(
                                                color:
                                                    AppThemeData.secondary200,
                                                fontSize: 18,
                                                fontFamily:
                                                    AppThemeData.semiBold,
                                              ),
                                            ),
                                            Text(
                                              controller.bankDetails.branchName
                                                  .toString(),
                                              style: TextStyle(
                                                color:
                                                    AppThemeData.secondary300,
                                                fontSize: 12,
                                                fontFamily:
                                                    AppThemeData.regular,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                controller
                                                    .bankDetails.holderName
                                                    .toString(),
                                                style: TextStyle(
                                                  color:
                                                      AppThemeData.secondary300,
                                                  fontSize: 12,
                                                  fontFamily:
                                                      AppThemeData.regular,
                                                ),
                                              ),
                                              Text(
                                                controller.bankDetails.accountNo
                                                    .toString(),
                                                style: TextStyle(
                                                  color:
                                                      AppThemeData.secondary300,
                                                  fontSize: 12,
                                                  fontFamily:
                                                      AppThemeData.regular,
                                                  letterSpacing: 2,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Opacity(
                                        opacity: 0.10,
                                        child: Icon(
                                          Iconsax.bank,
                                          size: 70,
                                          color: AppThemeData.grey500,
                                        ),
                                      ),
                                    ),
                                  ]),
                                ),
                              ),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: CustomButton(
                              btnName: 'Add bank'.tr,
                              textColor: AppThemeData.primary400,
                              isOutlined: true,
                              outlineColor: isDarkModel
                                  ? AppThemeData.grey200Dark
                                  : AppThemeData.grey200,
                              ontap: () {
                                showModalBottomSheet(
                                    isDismissible: true,
                                    isScrollControlled: true,
                                    context: context,
                                    backgroundColor: isDarkModel
                                        ? AppThemeData.grey50Dark
                                        : AppThemeData.grey50,
                                    builder: (context) {
                                      return const AddBankAccount();
                                    });
                              },
                            )),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: CustomButton(
                            btnName: 'Withdraw'.tr,
                            buttonColor: ConstantColors.blue,
                            textColor: Colors.white,
                            ontap: () async {
                              if (controller.bankDetails.bankName.toString() !=
                                  'null') {
                                if (walletController
                                    .amountController.value.text.isNotEmpty) {
                                  if (double.parse(Constant
                                          .minimumWithdrawalAmount
                                          .toString()) >
                                      double.parse(walletController
                                          .amountController.value.text)) {
                                    ShowToastDialog.showToast(
                                        '${'Withdraw amount must be greater or equal to'.tr}${Constant().amountShow(amount: Constant.minimumWithdrawalAmount.toString())}');
                                  } else {
                                    Map<String, dynamic> bodyParams = {
                                      'driver_id': Preferences.getInt(
                                          Preferences.userId),
                                      'amount': walletController
                                          .amountController.value.text,
                                      'note': walletController
                                          .noteController.value.text,
                                    };
                                    controller
                                        .setWithdrawals(bodyParams)
                                        .then((value) {
                                      if (value != null && value) {
                                        ShowToastDialog.showToast(
                                            'Amount Withdrawals request successfully');
                                      }
                                    });
                                    Get.back();
                                  }
                                } else {
                                  ShowToastDialog.showToast(
                                      'Please enter amount');
                                }
                              } else {
                                ShowToastDialog.showToast(
                                    'Please add bank details');
                              }
                            },
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          });
        });
  }

  addToWalletAmount(BuildContext context, WalletController walletController,
      bool isDarkMode) {
    return showModalBottomSheet(
        elevation: 5,
        useRootNavigator: true,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15), topRight: Radius.circular(15))),
        context: context,
        backgroundColor: isDarkMode == true
            ? AppThemeData.surface50Dark
            : AppThemeData.surface50,
        builder: (context) {
          return GetX<WalletController>(
              init: WalletController(),
              initState: (controller) {
                // razorPayController.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
                // razorPayController.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWaller);
                // razorPayController.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
              },
              builder: (controller) {
                return SizedBox(
                  height: Get.height / 1.1,
                  child: SingleChildScrollView(
                    child: InkWell(
                      onTap: () {
                        FocusScope.of(context).unfocus();
                      },
                      child: Form(
                        key: _walletFormKey,
                        child: Column(
                          children: [
                            Center(
                              child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  height: 8,
                                  width: 75,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: isDarkMode
                                        ? AppThemeData.grey300Dark
                                        : AppThemeData.grey300,
                                  )),
                            ),
                            Row(
                              children: [
                                IconButton(
                                    onPressed: () {
                                      Get.back();
                                    },
                                    icon: Transform(
                                      alignment: Alignment.center,
                                      transform: Directionality.of(context) ==
                                              TextDirection.rtl
                                          ? Matrix4.rotationY(3.14159)
                                          : Matrix4.identity(),
                                      child: Icon(
                                        Iconsax.arrow_left,
                                        color: isDarkMode
                                            ? AppThemeData.grey900Dark
                                            : AppThemeData.grey900,
                                        size: 24,
                                      ),
                                    )),
                              ],
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0, vertical: 10),
                                  child: RichText(
                                    text: TextSpan(
                                      text: "Topup Wallet".tr,
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: isDarkMode
                                            ? AppThemeData.grey900Dark
                                            : AppThemeData.grey900,
                                        fontFamily: AppThemeData.medium,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15.0, vertical: 10),
                              child: CustomTextField(
                                text: "Enter Amount".tr,
                                controller:
                                    walletController.amountController.value,
                                keyboardType: TextInputType.number,
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: Center(
                                    widthFactor: 0.0,
                                    child: Text(
                                      'KWD',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontFamily: AppThemeData.semiBold,
                                        color: isDarkMode
                                            ? AppThemeData.grey900Dark
                                            : AppThemeData.grey900,
                                      ),
                                    ),
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Please enter the topup amount'.tr;
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0,
                                  ),
                                  child: RichText(
                                    text: TextSpan(
                                      text: "Select Payment Option".tr,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: isDarkMode
                                            ? AppThemeData.grey900Dark
                                            : AppThemeData.grey900,
                                        fontFamily: AppThemeData.medium,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isDarkMode
                                        ? AppThemeData.grey300Dark
                                        : AppThemeData.grey300,
                                  ),
                                  color: isDarkMode
                                      ? AppThemeData.surface50Dark
                                      : AppThemeData.surface50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(children: [
                                  RadioButtonCustom(
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(8),
                                        topRight: Radius.circular(8)),
                                    image: "assets/images/stripe.png",
                                    name: 'Stripe',
                                    groupValue: walletController
                                        .selectedRadioTile!.value,
                                    isEnabled: controller.paymentSettingModel
                                                .value.strip!.isEnabled ==
                                            "true"
                                        ? true
                                        : false,
                                    isSelected: controller.stripe.value,
                                    onClick: (String? value) {
                                      controller.stripe = true.obs;

                                      controller.razorPay = false.obs;

                                      controller.paypal = false.obs;
                                      controller.payStack = false.obs;
                                      controller.flutterWave = false.obs;
                                      controller.mercadoPago = false.obs;
                                      controller.payFast = false.obs;
                                      controller.xendit = false.obs;
                                      controller.midtrans = false.obs;
                                      controller.orangePay = false.obs;
                                      walletController
                                          .selectedRadioTile!.value = value!;
                                    },
                                  ),
                                  RadioButtonCustom(
                                    isEnabled: controller.paymentSettingModel
                                                .value.payStack!.isEnabled ==
                                            "true"
                                        ? true
                                        : false,
                                    name: 'PayStack',
                                    image: "assets/images/paystack.png",
                                    isSelected: controller.payStack.value,
                                    groupValue: walletController
                                        .selectedRadioTile!.value,
                                    onClick: (String? value) {
                                      controller.stripe = false.obs;
                                      controller.razorPay = false.obs;

                                      controller.paypal = false.obs;
                                      controller.payStack = true.obs;
                                      controller.flutterWave = false.obs;
                                      controller.mercadoPago = false.obs;
                                      controller.payFast = false.obs;
                                      controller.xendit = false.obs;
                                      controller.midtrans = false.obs;
                                      controller.orangePay = false.obs;
                                      walletController
                                          .selectedRadioTile!.value = value!;
                                    },
                                  ),
                                  RadioButtonCustom(
                                    isEnabled: controller.paymentSettingModel
                                                .value.flutterWave!.isEnabled ==
                                            "true"
                                        ? true
                                        : false,
                                    name: 'FlutterWave',
                                    image: "assets/images/flutterwave.png",
                                    isSelected: controller.flutterWave.value,
                                    groupValue: walletController
                                        .selectedRadioTile!.value,
                                    onClick: (String? value) {
                                      controller.stripe = false.obs;
                                      controller.razorPay = false.obs;

                                      controller.paypal = false.obs;
                                      controller.payStack = false.obs;
                                      controller.flutterWave = true.obs;
                                      controller.mercadoPago = false.obs;
                                      controller.payFast = false.obs;
                                      controller.xendit = false.obs;
                                      controller.midtrans = false.obs;
                                      controller.orangePay = false.obs;
                                      walletController
                                          .selectedRadioTile!.value = value!;
                                    },
                                  ),
                                  RadioButtonCustom(
                                    isEnabled: controller.paymentSettingModel
                                                .value.razorpay!.isEnabled ==
                                            "true"
                                        ? true
                                        : false,
                                    name: 'RazorPay',
                                    image: "assets/images/razorpay_@3x.png",
                                    isSelected: controller.razorPay.value,
                                    groupValue: walletController
                                        .selectedRadioTile!.value,
                                    onClick: (String? value) {
                                      controller.stripe = false.obs;

                                      controller.razorPay = true.obs;

                                      controller.paypal = false.obs;
                                      controller.payStack = false.obs;
                                      controller.flutterWave = false.obs;
                                      controller.mercadoPago = false.obs;
                                      controller.payFast = false.obs;
                                      controller.xendit = false.obs;
                                      controller.midtrans = false.obs;
                                      controller.orangePay = false.obs;
                                      walletController
                                          .selectedRadioTile!.value = value!;
                                    },
                                  ),
                                  RadioButtonCustom(
                                    isEnabled: controller.paymentSettingModel
                                                .value.payFast!.isEnabled ==
                                            "true"
                                        ? true
                                        : false,
                                    name: 'PayFast',
                                    image: "assets/images/payfast.png",
                                    isSelected: controller.payFast.value,
                                    groupValue: walletController
                                        .selectedRadioTile!.value,
                                    onClick: (String? value) {
                                      controller.stripe = false.obs;

                                      controller.razorPay = false.obs;

                                      controller.paypal = false.obs;
                                      controller.payStack = false.obs;
                                      controller.flutterWave = false.obs;
                                      controller.mercadoPago = false.obs;
                                      controller.payFast = true.obs;
                                      controller.xendit = false.obs;
                                      controller.midtrans = false.obs;
                                      controller.orangePay = false.obs;
                                      walletController
                                          .selectedRadioTile!.value = value!;
                                    },
                                  ),
                                  RadioButtonCustom(
                                    isEnabled: controller.paymentSettingModel
                                                .value.mercadopago!.isEnabled ==
                                            "true"
                                        ? true
                                        : false,
                                    name: 'MercadoPago',
                                    image: "assets/images/mercadopago.png",
                                    isSelected: controller.mercadoPago.value,
                                    groupValue: walletController
                                        .selectedRadioTile!.value,
                                    onClick: (String? value) {
                                      controller.stripe = false.obs;

                                      controller.razorPay = false.obs;

                                      controller.paypal = false.obs;
                                      controller.payStack = false.obs;
                                      controller.flutterWave = false.obs;
                                      controller.mercadoPago = true.obs;
                                      controller.payFast = false.obs;
                                      controller.xendit = false.obs;
                                      controller.midtrans = false.obs;
                                      controller.orangePay = false.obs;
                                      walletController
                                          .selectedRadioTile!.value = value!;
                                    },
                                  ),
                                  RadioButtonCustom(
                                    isEnabled: controller.paymentSettingModel
                                                .value.payPal!.isEnabled ==
                                            "true"
                                        ? true
                                        : false,
                                    name: 'PayPal',
                                    image: "assets/images/paypal_@3x.png",
                                    isSelected: controller.paypal.value,
                                    groupValue: walletController
                                        .selectedRadioTile!.value,
                                    onClick: (String? value) {
                                      controller.stripe = false.obs;

                                      controller.razorPay = false.obs;

                                      controller.paypal = true.obs;
                                      controller.payStack = false.obs;
                                      controller.flutterWave = false.obs;
                                      controller.mercadoPago = false.obs;
                                      controller.payFast = false.obs;
                                      controller.xendit = false.obs;
                                      controller.midtrans = false.obs;
                                      controller.orangePay = false.obs;
                                      walletController
                                          .selectedRadioTile!.value = value!;
                                    },
                                  ),
                                  RadioButtonCustom(
                                    isEnabled: controller.paymentSettingModel
                                                .value.xendit!.isEnabled ==
                                            "true"
                                        ? true
                                        : false,
                                    name: 'Xendit',
                                    image: "assets/images/xendit.png",
                                    isSelected: controller.xendit.value,
                                    groupValue: walletController
                                        .selectedRadioTile!.value,
                                    onClick: (String? value) {
                                      controller.stripe = false.obs;
                                      controller.razorPay = false.obs;

                                      controller.paypal = false.obs;
                                      controller.payStack = false.obs;
                                      controller.flutterWave = false.obs;
                                      controller.mercadoPago = false.obs;
                                      controller.payFast = false.obs;
                                      controller.xendit = true.obs;
                                      controller.midtrans = false.obs;
                                      controller.orangePay = false.obs;
                                      walletController
                                          .selectedRadioTile!.value = value!;
                                    },
                                  ),
                                  RadioButtonCustom(
                                    isEnabled: controller.paymentSettingModel
                                                .value.orangePay!.isEnabled ==
                                            "true"
                                        ? true
                                        : false,
                                    name: 'Orange Pay',
                                    image: "assets/images/orangeMoney.png",
                                    isSelected: controller.orangePay.value,
                                    groupValue: walletController
                                        .selectedRadioTile!.value,
                                    onClick: (String? value) {
                                      controller.stripe = false.obs;
                                      controller.razorPay = false.obs;

                                      controller.paypal = false.obs;
                                      controller.payStack = false.obs;
                                      controller.flutterWave = false.obs;
                                      controller.mercadoPago = false.obs;
                                      controller.payFast = false.obs;
                                      controller.xendit = false.obs;
                                      controller.midtrans = false.obs;
                                      controller.orangePay = true.obs;
                                      walletController
                                          .selectedRadioTile!.value = value!;
                                    },
                                  ),
                                  RadioButtonCustom(
                                    borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(8),
                                        bottomRight: Radius.circular(8)),
                                    isBottomborderRemove: true,
                                    isEnabled: controller.paymentSettingModel
                                                .value.midtrans!.isEnabled ==
                                            "true"
                                        ? true
                                        : false,
                                    name: 'Midtrans',
                                    image: "assets/images/midtrans.png",
                                    isSelected: controller.midtrans.value,
                                    groupValue: walletController
                                        .selectedRadioTile!.value,
                                    onClick: (String? value) {
                                      controller.stripe = false.obs;
                                      controller.razorPay = false.obs;

                                      controller.paypal = false.obs;
                                      controller.payStack = false.obs;
                                      controller.flutterWave = false.obs;
                                      controller.mercadoPago = false.obs;
                                      controller.payFast = false.obs;
                                      controller.xendit = false.obs;
                                      controller.midtrans = true.obs;
                                      controller.orangePay = false.obs;
                                      walletController
                                          .selectedRadioTile!.value = value!;
                                    },
                                  ),
                                ]),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12.0, horizontal: 15),
                              child: GestureDetector(
                                onTap: () async {
                                  if (_walletFormKey.currentState!.validate()) {
                                    if (walletController
                                                .selectedRadioTile?.value ==
                                            null ||
                                        walletController
                                                .selectedRadioTile?.value ==
                                            '') {
                                      ShowToastDialog.showToast(
                                          "Please select payment method".tr);
                                      return;
                                    } else {
                                      Get.back();
                                      showLoadingAlert(context, isDarkMode);

                                      // if (walletController.selectedRadioTile!.value == "Stripe") {
                                      //   stripeMakePayment(amount: walletController.amountController.value.text);
                                      // } else
                                      // if (walletController.selectedRadioTile!.value == "RazorPay") {
                                      //   startRazorpayPayment();
                                      // } else
                                      if (walletController
                                              .selectedRadioTile!.value ==
                                          "PayPal") {
                                        // paypalPaymentSheet(walletController.amountController.value.text);
                                        // _paypalPayment();
                                      } else if (walletController
                                              .selectedRadioTile!.value ==
                                          "PayStack") {
                                        payStackPayment(context);
                                      } else if (walletController
                                              .selectedRadioTile!.value ==
                                          "FlutterWave") {
                                        flutterWaveInitiatePayment(
                                            context: context,
                                            amount: walletController
                                                .amountController.value.text,
                                            user: walletController
                                                .userModel.value);
                                      } else if (walletController
                                              .selectedRadioTile!.value ==
                                          "PayFast") {
                                        payFastPayment(context);
                                      } else if (walletController
                                              .selectedRadioTile!.value ==
                                          "MercadoPago") {
                                        mercadoPagoMakePayment(
                                            context: context,
                                            amount: walletController
                                                .amountController.value.text,
                                            user: walletController
                                                .userModel.value);
                                      } else if (walletController
                                              .selectedRadioTile!.value ==
                                          "Xendit") {
                                        xenditPayment(
                                            context,
                                            double.parse(walletController
                                                .amountController.value.text),
                                            walletController);
                                      } else if (walletController
                                              .selectedRadioTile!.value ==
                                          "Orange Pay") {
                                        orangeMakePayment(
                                            amount: walletController
                                                .amountController.value.text
                                                .toString(),
                                            context: context,
                                            controller: walletController);
                                      } else if (walletController
                                              .selectedRadioTile!.value ==
                                          "Midtrans") {
                                        midtransMakePayment(
                                            amount: walletController
                                                .amountController.value.text
                                                .toString(),
                                            context: context,
                                            controller: walletController);
                                      } else {
                                        ShowToastDialog.showToast(
                                            "Please select payment method");
                                      }
                                    }
                                  }
                                },
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: ConstantColors.blue,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                      child: Text(
                                    "CONTINUE".tr.toUpperCase(),
                                    style: const TextStyle(color: Colors.white),
                                  )),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              });
        });
  }

  // void _handleExternalWaller(ExternalWalletResponse response) {
  //   Get.back();
  //   showSnackBarAlert(
  //     message: "${"Payment Processing Via".tr} \n${response.walletName!}",
  //     color: Colors.blue.shade400,
  //   );
  // }
  //
  // void _handlePaymentSuccess(PaymentSuccessResponse response) {
  //   Get.back();
  //   walletController.setAmount(walletController.amountController.value.text).then((value) {
  //     if (value != null) {
  //       showSnackBarAlert(
  //         message: "Payment Successful!!".tr,
  //         color: Colors.green.shade400,
  //       );
  //       _refreshAPI();
  //     }
  //   });
  // }

  showSnackBarAlert({required String message, Color color = Colors.green}) {
    return Get.showSnackbar(GetSnackBar(
      isDismissible: true,
      message: message,
      backgroundColor: color,
      duration: const Duration(seconds: 8),
    ));
  }

  Future<void> _refreshAPI() async {
    walletController.getTrancation();
    walletController.amountController.value.clear();
  }

  // void _handlePaymentError(PaymentFailureResponse response) {
  //   Get.back();
  //   showSnackBarAlert(
  //     message: "${"Payment Failed!!".tr}${jsonDecode(response.message!)['error']['description']}",
  //     color: Colors.red.shade400,
  //   );
  // }

  showLoadingAlert(BuildContext context, bool isDarkMode) {
    return showDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Constant.loader(context, isDarkMode: isDarkMode),
              Text('Please wait!!'.tr),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const SizedBox(
                  height: 15,
                ),
                Text(
                  'Please wait!! while completing Transaction'.tr,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(
                  height: 15,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  ///payFast

  payFastPayment(context) {
    PayFast? payfast = walletController.paymentSettingModel.value.payFast;
    PayStackURLGen.getPayHTML(
            payFastSettingData: payfast!,
            amount: double.parse(
                    walletController.amountController.value.text.toString())
                .round()
                .toString())
        .then((String? value) async {
      bool isDone = await Get.to(PayFastScreen(
        htmlData: value!,
        payFastSettingData: payfast,
      ));
      if (isDone) {
        Get.back();
        walletController
            .setAmount(walletController.amountController.value.text)
            .then((value) {
          if (value != null) {
            showSnackBarAlert(
              message: "Payment Successful!!".tr,
              color: Colors.green.shade400,
            );
            _refreshAPI();
          }
        });
      } else {
        Get.back();
        showSnackBarAlert(
          message: "Payment UnSuccessful!!".tr,
          color: Colors.red,
        );
      }
    });
  }

  ///MercadoPago Payment Method

  ///paypal
  ///
  // final _flutterPaypalNativePlugin = FlutterPaypalNative.instance;

  // void initPayPal() async {
  //   //set debugMode for error logging
  //   FlutterPaypalNative.isDebugMode = walletController.paymentSettingModel.value.payPal!.isLive.toString() == "false" ? true : false;

  //   //initiate payPal plugin
  //   await _flutterPaypalNativePlugin.init(
  //     //your app id !!! No Underscore!!! see readme.md for help
  //     returnUrl: "com.mshwar.appdriver://paypalpay",
  //     //client id from developer dashboard
  //     clientID: walletController.paymentSettingModel.value.payPal!.appId!,
  //     //sandbox, staging, live etc
  //     payPalEnvironment: walletController.paymentSettingModel.value.payPal!.isLive.toString() == "true" ? FPayPalEnvironment.live : FPayPalEnvironment.sandbox,
  //     //what currency do you plan to use? default is US dollars
  //     currencyCode: FPayPalCurrencyCode.usd,
  //     //action paynow?
  //     action: FPayPalUserAction.payNow,
  //   );

  //   //call backs for payment
  // }

  // paypalPaymentSheet(String amount) {
  //   //add 1 item to cart. Max is 4!
  //   if (_flutterPaypalNativePlugin.canAddMorePurchaseUnit) {
  //     _flutterPaypalNativePlugin.addPurchaseUnit(
  //       FPayPalPurchaseUnit(
  //         // random prices
  //         amount: double.parse(amount),

  //         ///please use your own algorithm for referenceId. Maybe ProductID?
  //         referenceId: FPayPalStrHelper.getRandomString(16),
  //       ),
  //     );
  //   }
  //   // initPayPal();
  //   _flutterPaypalNativePlugin.makeOrder(
  //     action: FPayPalUserAction.payNow,
  //   );
  //   _flutterPaypalNativePlugin.setPayPalOrderCallback(
  //     callback: FPayPalOrderCallback(
  //       onCancel: () {
  //         //user canceled the payment
  //         ShowToastDialog.showToast("Payment canceled");
  //       },
  //       onSuccess: (data) {
  //         //successfully paid
  //         //remove all items from queue
  //         // _flutterPaypalNativePlugin.removeAllPurchaseItems();

  //         walletController.setAmount(walletController.amountController.value.text.toString()).then((value) {
  //           Get.back();
  //           if (value != null) {
  //             showSnackBarAlert(
  //               message: "Payment Successful!!".tr,
  //               color: Colors.green.shade400,
  //             );
  //             _refreshAPI();
  //           }
  //         });

  //         ShowToastDialog.showToast("Payment Successful!!");
  //         // transactionAPI();
  //         // walletTopUp();
  //       },
  //       onError: (data) {
  //         //an error occured
  //         Get.back();
  //         ShowToastDialog.showToast("${"error:".tr} ${data.reason}");
  //       },
  //       onShippingChange: (data) {
  //         //the user updated the shipping address
  //         Get.back();
  //         ShowToastDialog.showToast("${"shipping change:".tr} ${data.shippingChangeAddress?.adminArea1 ?? ""}");
  //       },
  //     ),
  //   );
  // }

  ///PayStack Payment Method
  payStackPayment(BuildContext context) async {
    var secretKey = walletController
        .paymentSettingModel.value.payStack!.secretKey
        .toString();
    await walletController
        .payStackURLGen(
      amount: walletController.amountController.value.text,
      secretKey: secretKey,
    )
        .then((value) async {
      if (value != null) {
        PayStackUrlModel payStackModel = value;

        bool isDone = await Get.to(
          () => PayStackScreen(
            walletController: walletController,
            secretKey: secretKey,
            initialURl: payStackModel.data.authorizationUrl,
            amount: walletController.amountController.value.text,
            reference: payStackModel.data.reference,
            callBackUrl: walletController
                .paymentSettingModel.value.payStack!.callbackUrl
                .toString(),
          ),
        );
        Get.back();
        if (isDone) {
          walletController
              .setAmount(walletController.amountController.value.text)
              .then((value) {
            if (value != null) {
              showSnackBarAlert(
                message: "Payment Successful!!".tr,
                color: Colors.green.shade400,
              );
              _refreshAPI();
            }
          });
        } else {
          showSnackBarAlert(
              message: "Payment UnSuccessful!!".tr, color: Colors.red);
        }
      } else {
        showSnackBarAlert(
            message: "Error while transaction!".tr, color: Colors.red);
      }
    });
  }

  mercadoPagoMakePayment(
      {required BuildContext context,
      required String amount,
      required UserModel user}) async {
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      "items": [
        {
          "title": "Test",
          "description": "Test Payment",
          "quantity": 1,
          "currency_id": "USD", // or your preferred currency
          "unit_price": double.parse(amount),
        }
      ],
      "payer": {"email": user.userData?.email ?? ''},
      "back_urls": {
        "failure": "${API.baseUrl}payment/failure",
        "pending": "${API.baseUrl}payment/pending",
        "success": "${API.baseUrl}payment/success",
      },
      "auto_return":
          "approved" // Automatically return after payment is approved
    });

    final response = await http.post(
      Uri.parse("https://api.mercadopago.com/checkout/preferences"),
      headers: headers,
      body: body,
    );
    showLog("API :: URL :: https://api.mercadopago.com/checkout/preferences");
    showLog("API :: Request Body :: ${jsonEncode(body)} ");
    showLog("API :: Response Status :: ${response.statusCode} ");
    showLog("API :: Response Body :: ${response.body} ");
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      Get.to(MercadoPagoScreen(initialURl: data['init_point']))!
          .then((value) async {
        if (value) {
          Get.back();
          walletController
              .setAmount(walletController.amountController.value.text)
              .then((value) {
            if (value != null) {
              showSnackBarAlert(
                message: "Payment Successful!!".tr,
                color: Colors.green.shade400,
              );
              _refreshAPI();
            }
          });
        } else {
          Get.back();
          ShowToastDialog.showToast("Payment UnSuccessful!!");
        }
      });
    } else {
      print('Error creating preference: ${response.body}');
      return null;
    }
  }

  String? _ref;

  setRef() {
    maths.Random numRef = maths.Random();
    int year = DateTime.now().year;
    int refNumber = numRef.nextInt(20000);
    if (Platform.isAndroid) {
      _ref = "AndroidRef$year$refNumber";
    } else if (Platform.isIOS) {
      _ref = "IOSRef$year$refNumber";
    }
  }

  ///FlutterWave Payment Method
  flutterWaveInitiatePayment(
      {required BuildContext context,
      required String amount,
      required UserModel user}) async {
    final url = Uri.parse('https://api.flutterwave.com/v3/payments');
    final headers = {
      'Authorization':
          'Bearer ${walletController.paymentSettingModel.value.flutterWave?.secretKey}',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      "tx_ref": _ref,
      "amount": amount,
      "currency": "NGN",
      "redirect_url": "${API.baseUrl}payment/success",
      "payment_options": "ussd, card, barter, payattitude",
      "customer": {
        "email": user.userData?.email.toString(),
        "phonenumber": user.userData?.phone, // Add a real phone number
        "name":
            '${user.userData?.prenom} ${user.userData?.nom}', // Add a real customer name
      },
      "customizations": {
        "title": "Payment for Services",
        "description": "Payment for XYZ services",
      }
    });

    final response = await http.post(url, headers: headers, body: body);

    showLog("API :: URL :: $url");
    showLog("API :: Request Body :: $body");
    showLog("API :: Request Header :: ${{
      'Authorization':
          'Bearer ${walletController.paymentSettingModel.value.flutterWave?.secretKey}',
      'Content-Type': 'application/json',
    }.toString()} ");
    showLog("API :: responseStatus :: ${response.statusCode} ");
    showLog("API :: responseBody :: ${response.body} ");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      Get.to(MercadoPagoScreen(initialURl: data['data']['link']))!
          .then((value) {
        if (value) {
          Get.back();
          walletController
              .setAmount(walletController.amountController.value.text)
              .then((value) {
            if (value != null) {
              showSnackBarAlert(
                message: "Payment Successful!!".tr,
                color: Colors.green.shade400,
              );
              _refreshAPI();
            }
          });
        } else {
          Get.back();
          ShowToastDialog.showToast("Payment UnSuccessful!!");
        }
      });
    } else {
      print('Payment initialization failed: ${response.body}');
      return null;
    }
  }

  //XenditPayment
  xenditPayment(context, amount, WalletController controller) async {
    await createXenditInvoice(amount: amount, controller: controller)
        .then((model) {
      if (model.id != null) {
        Get.to(() => XenditScreen(
                  initialURl: model.invoiceUrl ?? '',
                  transId: model.id ?? '',
                  apiKey: controller.paymentSettingModel.value.xendit!.key!
                      .toString(),
                ))!
            .then((value) {
          if (value == true) {
            Get.back();
            walletController
                .setAmount(walletController.amountController.value.text)
                .then((value) {
              if (value != null) {
                showSnackBarAlert(
                  message: "Payment Successful!!".tr,
                  color: Colors.green.shade400,
                );
                _refreshAPI();
              }
            });
          } else {
            Get.back();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Payment Unsuccessful!!".tr),
              backgroundColor: Colors.red,
            ));
          }
        });
      }
    });
  }

  Future<XenditModel> createXenditInvoice(
      {required var amount, required WalletController controller}) async {
    const url = 'https://api.xendit.co/v2/invoices';
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': generateBasicAuthHeader(
          controller.paymentSettingModel.value.xendit!.key!.toString()),
      // 'Cookie': '__cf_bm=yERkrx3xDITyFGiou0bbKY1bi7xEwovHNwxV1vCNbVc-1724155511-1.0.1.1-jekyYQmPCwY6vIJ524K0V6_CEw6O.dAwOmQnHtwmaXO_MfTrdnmZMka0KZvjukQgXu5B.K_6FJm47SGOPeWviQ',
    };

    final body = jsonEncode({
      'external_id': DateTime.now().millisecondsSinceEpoch.toString(),
      'amount': amount,
      'payer_email': 'customer@domain.com',
      'description': 'Test - VA Successful invoice payment',
      'currency': 'IDR', //IDR, PHP, THB, VND, MYR
    });

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);
      showLog("API :: URL :: $url");
      showLog("API :: Request Body :: ${jsonEncode(body)}");
      showLog("API :: Request Header :: ${headers.toString()} ");
      showLog("API :: responseStatus :: ${response.statusCode} ");
      showLog("API :: responseBody :: ${response.body} ");

      if (response.statusCode == 200 || response.statusCode == 201) {
        XenditModel model = XenditModel.fromJson(jsonDecode(response.body));
        // Get.back();
        return model;
      } else {
        // Get.back();
        return XenditModel();
      }
    } catch (e) {
      // Get.back();
      return XenditModel();
    }
  }

  String generateBasicAuthHeader(String apiKey) {
    String credentials = '$apiKey:';
    String base64Encoded = base64Encode(utf8.encode(credentials));
    return 'Basic $base64Encoded';
  }

//Orangepay payment
  static String accessToken = '';
  static String payToken = '';
  static String orderId = '';
  static String amount = '';

  orangeMakePayment(
      {required String amount,
      required BuildContext context,
      required WalletController controller}) async {
    reset();

    var paymentURL = await fetchToken(
        context: context,
        orderId: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: amount,
        currency: 'USD',
        controller: controller);

    if (paymentURL.toString() != '') {
      Get.to(() => OrangeMoneyScreen(
                initialURl: paymentURL,
                accessToken: accessToken,
                amount: amount,
                orangePay: controller.paymentSettingModel.value.orangePay!,
                orderId: orderId,
                payToken: payToken,
              ))!
          .then((value) {
        if (value == true) {
          Get.back();
          walletController
              .setAmount(walletController.amountController.value.text)
              .then((value) {
            if (value != null) {
              showSnackBarAlert(
                message: "Payment Successful!!".tr,
                color: Colors.green.shade400,
              );
              _refreshAPI();
            }
          });
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Payment Unsuccessful!!".tr),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future fetchToken(
      {required String orderId,
      required String currency,
      required BuildContext context,
      required String amount,
      required WalletController controller}) async {
    String apiUrl = 'https://api.orange.com/oauth/v3/token';
    Map<String, String> requestBody = {
      'grant_type': 'client_credentials',
    };

    var response = await http.post(Uri.parse(apiUrl),
        headers: <String, String>{
          'Authorization':
              "Basic ${controller.paymentSettingModel.value.orangePay!.key!}",
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: requestBody);

    showLog("API :: URL :: $apiUrl");
    showLog("API :: Request Body :: ${jsonEncode(requestBody)}");
    showLog("API :: Request Header :: ${{
      'Authorization':
          "Basic ${controller.paymentSettingModel.value.orangePay!.key!}",
      'Content-Type': 'application/x-www-form-urlencoded',
      'Accept': 'application/json',
    }.toString()} ");
    showLog("API :: responseStatus :: ${response.statusCode} ");
    showLog("API :: responseBody :: ${response.body} ");

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);

      accessToken = responseData['access_token'];
      // ignore: use_build_context_synchronously
      return await webpayment(
          context: context,
          amountData: amount,
          currency: currency,
          orderIdData: orderId,
          controller: controller);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Color(0xff635bff),
          content: Text(
            "Something went wrong, please contact admin.".tr,
            style: TextStyle(fontSize: 17),
          )));

      return '';
    }
  }

  Future webpayment(
      {required String orderIdData,
      required BuildContext context,
      required String currency,
      required String amountData,
      required WalletController controller}) async {
    orderId = orderIdData;
    amount = amountData;
    String apiUrl =
        controller.paymentSettingModel.value.orangePay!.isSandboxEnabled! ==
                "true"
            ? 'https://api.orange.com/orange-money-webpay/dev/v1/webpayment'
            : 'https://api.orange.com/orange-money-webpay/cm/v1/webpayment';
    Map<String, String> requestBody = {
      "merchant_key":
          controller.paymentSettingModel.value.orangePay!.merchantKey ?? '',
      "currency":
          controller.paymentSettingModel.value.orangePay!.isSandboxEnabled ==
                  "true"
              ? "OUV"
              : currency,
      "order_id": orderId,
      "amount": amount,
      "reference": 'Y-Note Test',
      "lang": "en",
      "return_url":
          controller.paymentSettingModel.value.orangePay!.returnUrl!.toString(),
      "cancel_url":
          controller.paymentSettingModel.value.orangePay!.cancelUrl!.toString(),
      "notif_url":
          controller.paymentSettingModel.value.orangePay!.notifUrl!.toString(),
    };

    var response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: json.encode(requestBody),
    );

    showLog("API :: URL :: $apiUrl");
    showLog("API :: Request Body :: ${jsonEncode(requestBody)}");
    showLog("API :: Request Header :: ${{
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    }.toString()} ");
    showLog("API :: responseStatus :: ${response.statusCode} ");
    showLog("API :: responseBody :: ${response.body} ");
    if (response.statusCode == 201) {
      Get.back();
      Map<String, dynamic> responseData = jsonDecode(response.body);
      if (responseData['message'] == 'OK') {
        payToken = responseData['pay_token'];
        return responseData['payment_url'];
      } else {
        return '';
      }
    } else {
      Get.back();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Color(0xff635bff),
          content: Text(
            "Something went wrong, please contact admin.".tr,
            style: TextStyle(fontSize: 17),
          )));
      return '';
    }
  }

  static reset() {
    accessToken = '';
    payToken = '';
    orderId = '';
    amount = '';
  }

//Midtrans payment
  midtransMakePayment(
      {required String amount,
      required BuildContext context,
      required WalletController controller}) async {
    await createPaymentLink(amount: amount, controller: controller).then((url) {
      if (url != '') {
        Get.to(() => MidtransScreen(
                  initialURl: url,
                ))!
            .then((value) {
          if (value == true) {
            walletController
                .setAmount(walletController.amountController.value.text)
                .then((value) {
              if (value != null) {
                Get.back();
                showSnackBarAlert(
                  message: "Payment Successful!!".tr,
                  color: Colors.green.shade400,
                );
                _refreshAPI();
              }
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Payment Unsuccessful!!".tr),
              backgroundColor: Colors.red,
            ));
          }
        });
      }
    });
  }

  Future<String> createPaymentLink(
      {required var amount, required WalletController controller}) async {
    var ordersId = DateTime.now().millisecondsSinceEpoch.toString();
    final url = Uri.parse(controller
                .paymentSettingModel.value.midtrans!.isSandboxEnabled!
                .toString() ==
            "true"
        ? 'https://api.sandbox.midtrans.com/v1/payment-links'
        : 'https://api.midtrans.com/v1/payment-links');

    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': generateBasicAuthHeader(
            controller.paymentSettingModel.value.midtrans!.key!),
      },
      body: jsonEncode({
        'transaction_details': {
          'order_id': ordersId,
          'gross_amount': double.parse(amount.toString()).toInt(),
        },
        'usage_limit': 2,
        "callbacks": {
          "finish": "https://www.google.com?merchant_order_id=$ordersId"
        },
      }),
    );
    showLog("API :: URL :: $url");
    showLog("API :: Request Body :: ${jsonEncode({
          'transaction_details': {
            'order_id': ordersId,
            'gross_amount': double.parse(amount.toString()).toInt(),
          },
          'usage_limit': 2,
          "callbacks": {
            "finish": "https://www.google.com?merchant_order_id=$ordersId"
          },
        })}");
    showLog("API :: Request Header :: ${{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': generateBasicAuthHeader(
          controller.paymentSettingModel.value.midtrans!.key!),
    }.toString()} ");
    showLog("API :: responseStatus :: ${response.statusCode} ");
    showLog("API :: responseBody :: ${response.body} ");
    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      // Get.back();
      print('Payment link created: ${responseData['payment_url']}');
      return responseData['payment_url'];
    } else {
      // Get.back();
      return '';
    }
  }
}
