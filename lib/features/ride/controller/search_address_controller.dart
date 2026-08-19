import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';

class SearchAddressController extends GetxController {
  //for Choose your Rider

  Rx<TextEditingController> searchTxtController = TextEditingController().obs;
  RxList<SearchInfo> suggestionsList = <SearchInfo>[].obs;
  final debouncer = Debouncer(delay: const Duration(milliseconds: 500));

  fetchAddress(text) async {
    log(":: fetchAddress :: $text");
    try {
      suggestionsList.value = await addressSuggestion(text);
    } catch (e) {
      log(e.toString());
    }
  }
}
