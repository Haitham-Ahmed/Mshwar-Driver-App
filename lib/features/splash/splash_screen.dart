import 'dart:async';
import 'dart:io';
import 'package:cabme_driver/core/utils/Preferences.dart';
import 'package:cabme_driver/core/themes/constant_colors.dart';
import 'package:cabme_driver/features/authentication/view/login_screen.dart';
import 'package:cabme_driver/features/authentication/view/waiting_approval_screen.dart';
import 'package:cabme_driver/features/authentication/model/user_model.dart';
import 'package:cabme_driver/features/dashboard/view/dash_board.dart';
import 'package:cabme_driver/features/localization/view/localization_screen.dart';
import 'package:cabme_driver/features/splash/server_down_screen.dart';
import 'package:cabme_driver/common/widget/custom_text.dart';
import 'package:cabme_driver/core/constant/constant.dart';
import 'package:cabme_driver/service/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _fadeController;
  late AnimationController _waveController;
  late AnimationController _shimmerController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _waveAnimation;

  bool _imageLoaded = false;

  @override
  void initState() {
    super.initState();
    // Dismiss any existing toasts/loaders on splash screen
    EasyLoading.dismiss();
    _initAnimations();
    // Wait for widget to be fully built before checking server
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkServerImmediately(); // Check server after first frame
    });
    _startSplashTimer();
  }

  /// Check server immediately - navigate if down
  Future<void> _checkServerImmediately() async {
    // Check server connectivity immediately
    bool serverAvailable = await _checkServerConnection();

    debugPrint('🔍 Server check result: $serverAvailable');

    if (!serverAvailable) {
      // Server is down - navigate immediately to server down screen
      debugPrint('❌ Server is DOWN - Navigating to ServerDownScreen');
      if (mounted) {
        Get.offAll(
          () => const ServerDownScreen(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 500),
        );
      }
      return;
    }

    debugPrint('✅ Server is UP - App will continue normally');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pre-cache the logo image so it appears instantly
    if (!_imageLoaded) {
      precacheImage(const AssetImage('assets/icons/appLogo.png'), context)
          .then((_) {
        if (mounted) {
          setState(() {
            _imageLoaded = true;
          });
        }
      });
    }
  }

  void _initAnimations() {
    // Logo scale and rotation animation
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Fade animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeIn,
      ),
    );

    // Wave animation
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _waveController,
        curve: Curves.linear,
      ),
    );

    // Shimmer animation
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    // Start animations
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _fadeController.forward();
    });
  }

  void _startSplashTimer() {
    Timer(const Duration(milliseconds: 3500), () {
      // Only navigate if we haven't already navigated (server check might have navigated)
      if (mounted) {
        _checkServerAndNavigate();
      }
    });
  }

  Future<void> _checkServerAndNavigate() async {
    // Double check server connectivity before navigation
    bool serverAvailable = await _checkServerConnection();

    if (!serverAvailable) {
      if (mounted) {
        Get.offAll(
          () => const ServerDownScreen(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 500),
        );
      }
      return;
    }

    // Server is available, proceed with normal navigation
    _navigateToNextScreen();
  }

  Future<bool> _checkServerConnection() async {
    try {
      debugPrint('🌐 Checking server at: ${API.baseUrl}settings');
      final response = await http
          .get(
            Uri.parse('${API.baseUrl}settings'),
            headers: API.authheader,
          )
          .timeout(const Duration(seconds: 5));

      debugPrint('📡 Server response: ${response.statusCode}');
      // Server is reachable if we get any response (even 401/500 means server is up)
      final isUp = response.statusCode >= 200 && response.statusCode < 600;
      debugPrint('✅ Server status: ${isUp ? "UP" : "DOWN"}');
      return isUp;
    } on SocketException catch (e) {
      // No internet or server unreachable
      debugPrint('❌ SocketException: $e');
      return false;
    } on TimeoutException catch (e) {
      // Server timeout
      debugPrint('❌ TimeoutException: $e');
      return false;
    } catch (e) {
      // Any other error means server is down
      debugPrint('❌ Exception: $e');
      return false;
    }
  }

  void _navigateToNextScreen() {
    if (!mounted) return;

    // ✅ FIX: Use WidgetsBinding to ensure navigation happens after frame is rendered
    // This prevents the '_history.isNotEmpty' assertion error
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      try {
        if (Preferences.getString(Preferences.languageCodeKey).isEmpty) {
          Get.offAll(
            () => const LocalizationScreens(intentType: "main"),
            transition: Transition.fadeIn,
            duration: const Duration(milliseconds: 500),
          );
        } else if (Preferences.getBoolean(Preferences.isLogin)) {
          // Check driver approval status before navigating
          UserModel? userModel = Constant.getUserData();
          if (userModel.userData != null) {
            final isVerified = (userModel.userData!.isVerified == "yes" ||
                userModel.userData!.isVerified == 1);
            final statut = (userModel.userData!.statut == "yes");
            final isFullyApproved = isVerified && statut;

            if (isFullyApproved) {
              // Fully approved - go to dashboard
              Get.offAll(
                () => DashBoard(),
                transition: Transition.fadeIn,
                duration: const Duration(milliseconds: 500),
              );
            } else {
              // Not fully approved - show waiting approval screen
              Get.offAll(
                () => const WaitingApprovalScreen(),
                transition: Transition.fadeIn,
                duration: const Duration(milliseconds: 500),
              );
            }
          } else {
            // No user data - go to login
            Get.offAll(
              () => const LoginScreen(),
              transition: Transition.fadeIn,
              duration: const Duration(milliseconds: 500),
            );
          }
        } else {
          Get.offAll(
            () => const LoginScreen(),
            transition: Transition.fadeIn,
            duration: const Duration(milliseconds: 500),
          );
        }
      } catch (e) {
        // Fallback: If Get.offAll fails, use standard Navigator
        debugPrint('Navigation error: $e');
        if (mounted) {
          // Check approval status in fallback navigation too
          Widget nextScreen;
          if (Preferences.getBoolean(Preferences.isLogin)) {
            UserModel? userModel = Constant.getUserData();
            if (userModel.userData != null) {
              final isVerified = (userModel.userData!.isVerified == "yes" ||
                  userModel.userData!.isVerified == 1);
              final statut = (userModel.userData!.statut == "yes");
              final isFullyApproved = isVerified && statut;

              nextScreen =
                  isFullyApproved ? DashBoard() : const WaitingApprovalScreen();
            } else {
              nextScreen = const LoginScreen();
            }
          } else {
            nextScreen = const LoginScreen();
          }

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => nextScreen),
            (route) => false,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _fadeController.dispose();
    _waveController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          // Driver App - Dark Navy Theme
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.4, 1.0],
            colors: [
              ConstantColors.navyLight, // Lighter navy
              ConstantColors.blue, // Dark navy
              ConstantColors.navy, // Darkest navy
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated wave circles - Driver App unique hexagonal pulse effect
            ...List.generate(3, (index) {
              return AnimatedBuilder(
                animation: _waveAnimation,
                builder: (context, child) {
                  return Positioned(
                    top: MediaQuery.of(context).size.height * 0.35 +
                        (index * 15),
                    left: MediaQuery.of(context).size.width * 0.5 -
                        (120 + (_waveAnimation.value * 80) + (index * 40)),
                    child: Container(
                      width: 240 + (_waveAnimation.value * 160) + (index * 80),
                      height: 240 + (_waveAnimation.value * 160) + (index * 80),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: ConstantColors.primary.withOpacity(
                              0.15 - (_waveAnimation.value * 0.12)),
                          width: 2.5,
                        ),
                      ),
                    ),
                  );
                },
              );
            }),

            // Floating particles - Driver App green sparkles
            ...List.generate(12, (index) {
              return AnimatedBuilder(
                animation: _waveAnimation,
                builder: (context, child) {
                  final offset = (index * 0.25) % 1.0;
                  final animValue = (_waveAnimation.value + offset) % 1.0;
                  final particleColor = ConstantColors.primary;
                  return Positioned(
                    top: MediaQuery.of(context).size.height *
                        (0.15 + (index * 0.06)),
                    left: MediaQuery.of(context).size.width *
                        ((index * 0.12) % 1.0),
                    child: Opacity(
                      opacity: 0.4 - (animValue * 0.35),
                      child: Container(
                        width: 5 + (index % 3) * 2.5,
                        height: 5 + (index % 3) * 2.5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: particleColor,
                          boxShadow: [
                            BoxShadow(
                              color: particleColor.withOpacity(0.6),
                              blurRadius: 6,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo - shows immediately (no animation delay)
                  ColorFiltered(
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                    child: Image.asset(
                      'assets/icons/appLogo.png',
                      width: 150,
                      height: 150,
                      fit: BoxFit.contain,
                      gaplessPlayback: true, // Prevents flicker
                      frameBuilder:
                          (context, child, frame, wasSynchronouslyLoaded) {
                        if (wasSynchronouslyLoaded) return child;
                        return child; // Show immediately without fade
                      },
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Tagline - Driver specific
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: CustomText(
                      text: 'Drive Smart, Earn More',
                      size: 17,
                      color: Colors.white.withOpacity(0.95),
                      letterSpacing: 1.5,
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Loading indicator with SpinKit - green accent
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SpinKitDoubleBounce(
                      color: ConstantColors.primary,
                      size: 40.0,
                    ),
                  ),
                ],
              ),
            ),

            // Version info at bottom - Driver App branding
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    // Driver badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_user_rounded,
                            size: 14,
                            color: ConstantColors.primary,
                          ),
                          const SizedBox(width: 6),
                          CustomText(
                            text: 'DRIVER APP',
                            size: 11,
                            color: Colors.white.withOpacity(0.9),
                            letterSpacing: 1.5,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    CustomText(
                      text: 'Version 2.1.0',
                      size: 11,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
