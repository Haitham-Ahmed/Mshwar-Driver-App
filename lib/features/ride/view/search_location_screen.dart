import 'package:cabme_driver/features/ride/controller/search_address_controller.dart';
import 'package:cabme_driver/common/widget/custom_app_bar.dart';
import 'package:cabme_driver/common/widget/text_field.dart';
import 'package:cabme_driver/core/themes/constant_colors.dart';
import 'package:cabme_driver/core/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class AddressSearchScreen extends StatelessWidget {
  const AddressSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: SearchAddressController(),
        builder: (controller) {
          return Scaffold(
            appBar: CustomAppBar(
              title: 'Search Address'.tr,
            ),
            body: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          text: 'Enter address or location'.tr,
                          controller: controller.searchTxtController.value,
                          keyboardType: TextInputType.text,
                          prefixIcon: Icon(
                            Iconsax.search_normal,
                            color: themeChange.getThem()
                                ? AppThemeData.grey400Dark
                                : AppThemeData.grey400,
                            size: 22,
                          ),
                          onChanged: (v) {
                            controller
                                .debouncer(() => controller.fetchAddress(v));
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    primary: true,
                    itemCount: controller.suggestionsList.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(controller.suggestionsList[index].address
                            .toString()),
                        onTap: () {
                          Get.back(result: controller.suggestionsList[index]);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        });
  }
}
