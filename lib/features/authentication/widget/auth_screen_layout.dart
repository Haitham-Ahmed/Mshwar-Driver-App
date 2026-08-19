import 'package:cabme_driver/common/widget/custom_text.dart';
import 'package:cabme_driver/core/themes/constant_colors.dart';
import 'package:cabme_driver/core/utils/dark_theme_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

/// Reusable layout widget for all authentication screens
/// Provides consistent UI with gradient background, decorative circles,
/// header section, form card, and bottom section
class AuthScreenLayout extends StatefulWidget {
  /// Title displayed in the header (e.g., "Welcome Back!")
  final String title;

  /// Subtitle/description displayed below the title
  final String subtitle;

  /// Whether to show the back button in the header
  final bool showBackButton;

  /// The main content/form to display in the white card
  final Widget child;

  /// Optional widget to display in the bottom section
  final Widget? bottomWidget;

  /// Optional custom back button action
  final VoidCallback? onBackPressed;

  const AuthScreenLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.showBackButton = true,
    this.bottomWidget,
    this.onBackPressed,
  });

  @override
  State<AuthScreenLayout> createState() => _AuthScreenLayoutState();
}

class _AuthScreenLayoutState extends State<AuthScreenLayout>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDarkMode = themeChange.getThem();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          // Driver App - Dark Navy Theme
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.6, 1.0],
            colors: [
              ConstantColors.navyLight, // Lighter navy
              ConstantColors.blue, // Dark navy
              ConstantColors.navy, // Darkest navy
            ],
          ),
        ),
        child: Stack(
          children: [
            // Driver App - Decorative Elements with green accent
            Positioned(
              top: -80,
              right: -60,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ConstantColors.primary.withOpacity(0.1),
                    width: 2,
                  ),
                ),
              ),
            ),
            Positioned(
              top: -40,
              right: -20,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ConstantColors.primary.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -40,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ConstantColors.primary.withOpacity(0.08),
                    width: 1.5,
                  ),
                ),
              ),
            ),

            // Main Content
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      // Header Section
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              24,
                              widget.showBackButton ? 60 : 80,
                              24,
                              20,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Back Button
                                if (widget.showBackButton)
                                  IconButton(
                                    onPressed: widget.onBackPressed ??
                                        () => Get.back(),
                                    icon: const Icon(
                                      Icons.arrow_back_ios,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                if (widget.showBackButton)
                                  const SizedBox(height: 24),
                                CustomText(
                                  text: widget.title.tr,
                                  size: 32,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                  height: 1.2,
                                ),
                                const SizedBox(height: 12),
                                CustomText(
                                  text: widget.subtitle.tr,
                                  size: 15,
                                  color: Colors.white.withOpacity(0.9),
                                  height: 1.5,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Form Card
                      Expanded(
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? AppThemeData.surface50Dark
                                  : AppThemeData.surface50,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(32),
                                topRight: Radius.circular(32),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, -5),
                                ),
                              ],
                            ),
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // Drag Handle
                                    Center(
                                      child: Container(
                                        width: 40,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: isDarkMode
                                              ? AppThemeData.grey300Dark
                                              : AppThemeData.grey300,
                                          borderRadius:
                                              BorderRadius.circular(2),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    // Child content
                                    widget.child,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Bottom Section
                      if (widget.bottomWidget != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 20),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? AppThemeData.surface50Dark
                                : AppThemeData.surface50,
                            border: Border(
                              top: BorderSide(
                                color: isDarkMode
                                    ? AppThemeData.grey300Dark.withOpacity(0.3)
                                    : AppThemeData.grey300.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                          ),
                          child: widget.bottomWidget,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper widget for the bottom link section (e.g., "Already have an account? Log in")
class AuthBottomLink extends StatelessWidget {
  final String text;
  final String linkText;
  final VoidCallback onTap;

  const AuthBottomLink({
    super.key,
    required this.text,
    required this.linkText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDarkMode = themeChange.getThem();

    return Center(
      child: Text.rich(
        TextSpan(
          text: text.tr,
          style: TextStyle(
            fontSize: 15,
            fontFamily: 'pop',
            color: isDarkMode ? AppThemeData.grey500Dark : AppThemeData.grey800,
          ),
          children: <TextSpan>[
            const TextSpan(text: ' '),
            TextSpan(
              text: linkText.tr,
              style: TextStyle(
                fontSize: 15,
                fontFamily: 'pop',
                fontWeight: FontWeight.bold,
                color: ConstantColors.blue, // Dark navy for links
              ),
              recognizer: TapGestureRecognizer()..onTap = onTap,
            ),
          ],
        ),
      ),
    );
  }
}
