import 'package:cabme_driver/features/car_service/model/car_service_book_model.dart';
import 'package:cabme_driver/common/widget/custom_app_bar.dart';
import 'package:cabme_driver/core/themes/constant_colors.dart';
import 'package:cabme_driver/core/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class ShowServiceDocScreen extends StatelessWidget {
  final ServiceData serviceData;

  const ShowServiceDocScreen({super.key, required this.serviceData});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CustomAppBar(
        title: serviceData.fileName.toString(),
      ),
      backgroundColor: themeChange.getThem()
          ? AppThemeData.surface50Dark
          : AppThemeData.surface50,
      body: SfPdfViewerTheme(
        data: SfPdfViewerThemeData(
          progressBarColor: AppThemeData.primary200,
          backgroundColor: themeChange.getThem()
              ? AppThemeData.surface50Dark
              : AppThemeData.surface50,
        ),
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: SfPdfViewer.network(
            serviceData.photoCarServiceBookPath.toString(),
          ),
        ),
      ),
    );
  }
}
