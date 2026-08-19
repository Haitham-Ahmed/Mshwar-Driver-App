import 'package:cabme_driver/core/constant/show_toast_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';

class LocationPermissionDisclosureDialog extends StatelessWidget {
  const LocationPermissionDisclosureDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Location Access Required'),
      content: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Mshwar Captain needs access to your location, including when the app is in the background, to:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 12),
            Text('• Show your availability to nearby passengers when you are online'),
            SizedBox(height: 6),
            Text('• Receive ride requests from passengers in your area'),
            SizedBox(height: 6),
            Text('• Allow passengers to track your real-time location during rides'),
            SizedBox(height: 6),
            Text('• Calculate accurate trip distance and fare'),
            SizedBox(height: 16),
            Text(
              'Background Location:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Text(
              'Your location will be collected even when the app is closed or not in use while you are marked as "Online/Active". This allows you to receive ride requests and lets passengers see your position on the map.',
            ),
            SizedBox(height: 12),
            Text(
              'Your location data is used only to provide ride services and is not shared with third parties for advertising purposes.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        MaterialButton(
          onPressed: () {
            SystemNavigator.pop();
          },
          child: const Text('Decline', style: TextStyle(color: Colors.red)),
        ),
        MaterialButton(
          onPressed: () {
            _requestLocationPermission();
          },
          child: const Text(
            'Accept',
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // Method to request location permission using permission_handler package
  void _requestLocationPermission() async {
    PermissionStatus location = await Location().requestPermission();
    if (location == PermissionStatus.granted) {
      Get.back();
    } else {
      ShowToastDialog.showToast("Permission Denied");
    }
  }
}
