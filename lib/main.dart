import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cabme_driver/features/dashboard/controller/dash_board_controller.dart';
import 'package:cabme_driver/features/profile/controller/settings_controller.dart';
import 'package:cabme_driver/features/dashboard/view/dash_board.dart';
import 'package:cabme_driver/features/splash/splash_screen.dart';
import 'package:cabme_driver/service/api.dart';
import 'package:cabme_driver/core/themes/styles.dart';
import 'package:cabme_driver/core/utils/dark_theme_provider.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'features/chat/view/conversation_screen.dart';
import 'service/localization_service.dart';
import 'core/utils/Preferences.dart';
import 'service/firebase_options.dart';
import 'package:cabme_driver/common/widget/notification_dialog.dart';

// Initialize notification plugin for background handler
final FlutterLocalNotificationsPlugin backgroundNotificationPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  log('📨 Background Message received: ${jsonEncode(message.data)}');
  log('📨 Notification: ${message.notification?.title} - ${message.notification?.body}');

  // Initialize notification channel for Android
  if (Platform.isAndroid) {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'Notifications for important updates and broadcasts',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    await backgroundNotificationPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: DarwinInitializationSettings(),
    );

    await backgroundNotificationPlugin.initialize(initSettings);
  }

  // Display notification if it has notification payload
  if (message.notification != null) {
    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // Get title and body from notification or data payload
    String title =
        message.notification?.title ?? message.data['title'] ?? 'Notification';
    String body = message.notification?.body ??
        message.data['body'] ??
        message.data['message'] ??
        '';

    const NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await backgroundNotificationPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: jsonEncode(message.data),
    );

    log('✅ Background notification displayed');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Preferences.initPref();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    androidProvider: AndroidProvider.playIntegrity,
    appleProvider: AppleProvider.appAttest,
  );

  // Register background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    getCurrentAppTheme();
    setupInteractedMessage(context);
    Future.delayed(const Duration(seconds: 3), () {
      if (Preferences.getString(Preferences.languageCodeKey)
          .toString()
          .isNotEmpty) {
        LocalizationService().changeLocale(
            Preferences.getString(Preferences.languageCodeKey).toString());
      }
      API.header['accesstoken'] =
          Preferences.getString(Preferences.accesstoken);
    });
    super.initState();
  }

  DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    getCurrentAppTheme();
  }

  void getCurrentAppTheme() async {
    themeChangeProvider.darkTheme =
        await themeChangeProvider.darkThemePreference.getTheme();
  }

  Future<void> setupInteractedMessage(BuildContext context) async {
    initialize(context);

    // For iOS, wait for APNS token before subscribing to topics
    if (Platform.isIOS) {
      try {
        String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        if (apnsToken == null) {
          // Retry getting APNS token with a delay
          await Future.delayed(const Duration(seconds: 2));
          apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        }
        if (apnsToken != null) {
          log('✅ APNS token obtained: $apnsToken');
        } else {
          log('⚠️ APNS token still not available, but proceeding...');
        }
      } catch (e) {
        log('⚠️ Error getting APNS token: $e');
      }
    }

    // Subscribe to topic after ensuring APNS token is available (iOS) or directly (Android)
    try {
      await FirebaseMessaging.instance.subscribeToTopic("cabme_driver");
      log('✅ Subscribed to topic: cabme_driver');
    } catch (e) {
      log('❌ Error subscribing to topic: $e');
      // Retry after a delay if it fails
      await Future.delayed(const Duration(seconds: 2));
      try {
        await FirebaseMessaging.instance.subscribeToTopic("cabme_driver");
        log('✅ Subscribed to topic after retry: cabme_driver');
      } catch (retryError) {
        log('❌ Error subscribing to topic after retry: $retryError');
      }
    }

    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      // Store the notification to show dialog after splash screen
      String title = initialMessage.notification?.title ??
          initialMessage.data['title'] ??
          'Notification';
      String body = initialMessage.notification?.body ??
          initialMessage.data['body'] ??
          initialMessage.data['message'] ??
          '';
      NotificationDialog.setPendingNotification(title, body);
      _handleNotificationTap(initialMessage);
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('📨 Foreground message received');
      log('🔍 Data: ${jsonEncode(message.data)}');
      log('🔍 Notification: ${message.notification?.title} - ${message.notification?.body}');
      log('🔍 Type: ${message.data['type'] ?? 'none'}');

      if (message.notification != null) {
        display(message);
      } else if (message.data.isNotEmpty) {
        // Handle data-only messages (for broadcast or other types)
        log('📨 Data-only message received, displaying notification');
        display(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Listen for token refresh and update it automatically
    FirebaseMessaging.instance.onTokenRefresh.listen((String newToken) {
      print('═══════════════════════════════════════════════════════');
      print('🔄 FCM TOKEN REFRESHED');
      print('═══════════════════════════════════════════════════════');
      print('New Token: $newToken');
      print('═══════════════════════════════════════════════════════');
      log('🔄 FCM Token refreshed: $newToken', name: 'FCM_TOKEN');
      _updateTokenToBackend(newToken);
    });

    // Get initial token and update it
    _getAndUpdateToken();
  }

  Future<void> _getAndUpdateToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        print('═══════════════════════════════════════════════════════');
        print('📱 FCM TOKEN RETRIEVED (App Initialization)');
        print('═══════════════════════════════════════════════════════');
        print('Token: $token');
        print('═══════════════════════════════════════════════════════');
        log('📱 Initial FCM Token: $token', name: 'FCM_TOKEN');
        _updateTokenToBackend(token);
      } else {
        print('⚠️ FCM Token is null');
        log('FCM Token is null');
      }
    } catch (e) {
      print('❌ Error getting initial FCM token: $e');
      log('❌ Error getting initial FCM token: $e');
    }
  }

  Future<void> _updateTokenToBackend(String token) async {
    try {
      // Check if user is logged in
      final userId = Preferences.getInt(Preferences.userId);
      if (userId == 0) {
        log('⚠️ User not logged in, skipping token update');
        return;
      }

      // Try to get dashboard controller if it exists, otherwise update directly
      try {
        if (Get.isRegistered<DashBoardController>()) {
          final dashBoardController = Get.find<DashBoardController>();
          await dashBoardController.updateFCMToken(token);
          log('✅ FCM Token updated successfully via controller');
        } else {
          // Controller not initialized yet, update directly
          await _updateFCMTokenDirectly(token);
          log('✅ FCM Token updated successfully (direct)');
        }
      } catch (e) {
        // Fallback to direct update if controller access fails
        log('⚠️ Controller access failed, trying direct update: $e');
        await _updateFCMTokenDirectly(token);
      }
    } catch (e) {
      log('❌ Error updating FCM token to backend: $e');
    }
  }

  Future<void> _updateFCMTokenDirectly(String token) async {
    try {
      final Map<String, dynamic> bodyParams = {
        'user_id': Preferences.getInt(Preferences.userId),
        'fcm_id': token,
        'device_id': "",
        'user_cat': "driver", // Driver app always uses "driver"
      };

      final response = await http.post(
        Uri.parse(API.updateToken),
        headers: API.header,
        body: jsonEncode(bodyParams),
      );

      log('📤 Token update API response: ${response.statusCode}');
      if (response.statusCode == 200) {
        log('✅ FCM Token updated successfully');
      }
    } catch (e) {
      log('❌ Error in direct token update: $e');
    }
  }

  void _handleNotificationTap(RemoteMessage message) async {
    final data = message.data;
    log('🖱️ Notification tapped: ${jsonEncode(data)}');

    // Get title and body for dialog
    String title =
        message.notification?.title ?? data['title'] ?? 'Notification';
    String body =
        message.notification?.body ?? data['body'] ?? data['message'] ?? '';

    // Handle broadcast notifications - show dialog and navigate to dashboard
    if (data['type'] == 'broadcast') {
      log('📢 Broadcast notification tapped');

      // Store pending notification to show after app is ready
      NotificationDialog.setPendingNotification(title, body);

      try {
        DashBoardController dashBoardController =
            Get.put(DashBoardController());
        dashBoardController.selectedDrawerIndex.value = 0;
        await Get.to(DashBoard());

        // Show dialog after navigation
        Future.delayed(const Duration(milliseconds: 800), () {
          if (navigatorKey.currentContext != null) {
            NotificationDialog.showPendingNotification(
                navigatorKey.currentContext!);
          }
        });
      } catch (e) {
        log('⚠️ Error navigating to dashboard: $e');
      }
      return;
    }

    // For other notification types, also show dialog
    NotificationDialog.setPendingNotification(title, body);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (navigatorKey.currentContext != null) {
        NotificationDialog.showPendingNotification(
            navigatorKey.currentContext!);
      }
    });

    if (message.notification != null) {
      if (data['status'] == "done") {
        await Get.to(ConversationScreen(), arguments: {
          'receiverId':
              int.parse(json.decode(data['message'])['senderId'].toString()),
          'orderId':
              int.parse(json.decode(data['message'])['orderId'].toString()),
          'receiverName': json.decode(data['message'])['senderName'].toString(),
          'receiverPhoto':
              json.decode(data['message'])['senderPhoto'].toString(),
        });
      } else if (data['statut'] == "new" && data['statut'] == "rejected") {
        await Get.to(DashBoard());
      } else if (data['type'] == "payment received") {
        DashBoardController dashBoardController =
            Get.put(DashBoardController());
        dashBoardController.selectedDrawerIndex.value = 4;
        await Get.to(DashBoard());
      }
    }
  }

  Future<void> initialize(BuildContext context) async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'Notifications for important updates and broadcasts',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInitializationSettings = const DarwinInitializationSettings();
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: iosInitializationSettings);
    await FlutterLocalNotificationsPlugin().initialize(initializationSettings,
        onDidReceiveNotificationResponse: (payload) async {});

    await FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void display(RemoteMessage message) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      // Get title and body from notification or data payload
      String title = message.notification?.title ??
          message.data['title'] ??
          'Notification';
      String body = message.notification?.body ??
          message.data['body'] ??
          message.data['message'] ??
          '';

      // Always show system notification with sound for audio feedback
      const NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          enableVibration: true,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      // Show system notification with sound (even if dialog is shown)
      await FlutterLocalNotificationsPlugin().show(
        id,
        title,
        body,
        notificationDetails,
        payload: jsonEncode(message.data),
      );

      // Also show beautiful dialog if app is in foreground
      if (navigatorKey.currentContext != null) {
        NotificationDialog.show(
          context: navigatorKey.currentContext!,
          title: title,
          message: body,
        );
      }

      log('✅ Notification displayed: $title - $body');
    } on Exception catch (e) {
      log('❌ Error displaying notification: $e');
    }
  }

  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        return themeChangeProvider;
      },
      child: Consumer<DarkThemeProvider>(
        builder: (context, value, child) {
          return GetMaterialApp(
            navigatorKey: navigatorKey,
            title: 'Mshwar Driver'.tr,
            debugShowCheckedModeBanner: false,
            theme: Styles.themeData(
                themeChangeProvider.darkTheme == 0
                    ? true
                    : themeChangeProvider.darkTheme == 1
                        ? false
                        : themeChangeProvider.getSystemThem(),
                context),
            locale: LocalizationService.locale,
            fallbackLocale: LocalizationService.locale,
            translations: LocalizationService(),
            builder: EasyLoading.init(),
            home: GetBuilder(
              init: SettingsController(),
              builder: (controller) {
                return const SplashScreen();
              },
            ),
          );
        },
      ),
    );
  }
}
