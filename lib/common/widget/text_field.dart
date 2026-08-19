import 'package:cabme_driver/core/themes/constant_colors.dart';
import 'package:cabme_driver/core/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

/// Validation types for real-time tracking
enum ValidationType {
  none,
  email,
  password,
  confirmPassword,
  phone,
  name,
  required,
}

class CustomTextField extends StatefulWidget {
  final String text;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final int? maxLines;
  final VoidCallback? suffixPressed;
  final String? Function(String?)? validator;
  final int? maxWords;
  final bool readOnly;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final VoidCallback? ontap;
  final TextInputAction? textInputAction;
  final bool? obscureText;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final EdgeInsetsGeometry? contentPadding;
  final Color? fillColor;
  final bool? filled;
  final InputBorder? border;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final InputBorder? errorBorder;
  final InputBorder? disabledBorder;
  final Widget? counter;
  final double? cursorWidth;
  final Radius? cursorRadius;
  final Color? cursorColor;
  final bool? autofocus;
  final bool? enableSuggestions;
  final bool? autocorrect;
  final Brightness? keyboardAppearance;
  final int? minLines;
  final BoxConstraints? prefixIconConstraints;
  final BoxConstraints? suffixIconConstraints;
  final FocusNode? focusNode;
  final void Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;

  /// Real-time validation type
  final ValidationType validationType;

  /// For confirm password validation - pass the password controller
  final TextEditingController? passwordController;

  /// Minimum password length (default: 6)
  final int minPasswordLength;

  /// Show validation status below the field
  final bool showValidationStatus;

  const CustomTextField({
    super.key,
    required this.text,
    this.suffixIcon,
    this.prefixIcon,
    this.maxLines,
    this.suffixPressed,
    this.validator,
    this.maxWords,
    this.controller,
    this.readOnly = false,
    this.ontap,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.textStyle,
    this.hintStyle,
    this.contentPadding,
    this.fillColor,
    this.filled = true,
    this.border,
    this.enabledBorder,
    this.focusedBorder,
    this.errorBorder,
    this.disabledBorder,
    this.counter,
    this.cursorWidth,
    this.cursorRadius,
    this.cursorColor,
    this.autofocus = false,
    this.enableSuggestions = true,
    this.autocorrect = true,
    this.keyboardAppearance,
    this.minLines,
    this.prefixIconConstraints,
    this.suffixIconConstraints,
    this.focusNode,
    this.onChanged,
    this.inputFormatters,
    this.validationType = ValidationType.none,
    this.passwordController,
    this.minPasswordLength = 6,
    this.showValidationStatus = true,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField>
    with SingleTickerProviderStateMixin {
  late TextEditingController controller;
  FocusNode? _focusNode;
  AnimationController? _animationController;
  Animation<double>? _borderAnimation;
  bool _isFocused = false;
  bool _hasInput = false;
  bool _isValid = false;
  String? _errorMessage;
  String? _successMessage;

  // ============================================
  // DEFAULT STYLING CONSTANTS (Consistent UI)
  // ============================================
  static const double _borderRadius = 16.0;
  static const double _borderWidth = 1.5;
  static const double _focusedBorderWidth = 1.5;
  static const double _fontSize = 15.0;
  static const EdgeInsets _defaultPadding =
      EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0);

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _borderAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Curves.easeInOut,
      ),
    );

    _focusNode!.addListener(_onFocusChange);
    controller.addListener(_onTextChanged);

    // Listen to password controller for confirm password
    if (widget.validationType == ValidationType.confirmPassword) {
      widget.passwordController?.addListener(_onTextChanged);
    }
  }

  void _onTextChanged() {
    final value = controller.text;
    setState(() {
      _hasInput = value.isNotEmpty;

      if (value.isEmpty) {
        _isValid = false;
        _errorMessage = null;
        _successMessage = null;
        return;
      }

      // Validate based on type
      switch (widget.validationType) {
        case ValidationType.email:
          _validateEmail(value);
          break;
        case ValidationType.password:
          _validatePassword(value);
          break;
        case ValidationType.confirmPassword:
          _validateConfirmPassword(value);
          break;
        case ValidationType.phone:
          _validatePhone(value);
          break;
        case ValidationType.name:
          _validateName(value);
          break;
        case ValidationType.required:
          _validateRequired(value);
          break;
        case ValidationType.none:
          _isValid = true;
          _errorMessage = null;
          _successMessage = null;
          break;
      }
    });
  }

  void _validateEmail(String value) {
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    if (!value.contains('@')) {
      _isValid = false;
      _errorMessage = 'Email must contain @'.tr;
    } else if (!value.contains('.')) {
      _isValid = false;
      _errorMessage = 'Email must contain a domain'.tr;
    } else if (!emailRegex.hasMatch(value)) {
      _isValid = false;
      _errorMessage = 'Invalid email format'.tr;
    } else {
      _isValid = true;
      _errorMessage = null;
      _successMessage = 'Valid email address'.tr;
    }
  }

  void _validatePassword(String value) {
    if (value.length < widget.minPasswordLength) {
      _isValid = false;
      _errorMessage =
          'Password must be at least ${widget.minPasswordLength} characters'.tr;
    } else {
      _isValid = true;
      _errorMessage = null;
      _successMessage = 'Valid password'.tr;
    }
  }

  void _validateConfirmPassword(String value) {
    if (widget.passwordController == null) {
      _isValid = false;
      _errorMessage = 'Password controller not provided'.tr;
      return;
    }

    if (value != widget.passwordController!.text) {
      _isValid = false;
      _errorMessage = 'Passwords do not match'.tr;
    } else {
      _isValid = true;
      _errorMessage = null;
      _successMessage = 'Passwords match'.tr;
    }
  }

  void _validatePhone(String value) {
    // Kuwait phone numbers: Mobile (5,6,9,41), Landline (2), Test (999)
    final kuwaitPhoneRegex = RegExp(r'^(41\d{6}|[5692]\d{7}|999\d{5})$');

    if (value.length < 8) {
      _isValid = false;
      _errorMessage = 'Kuwait number must be 8 digits'.tr;
    } else if (value.length > 8) {
      _isValid = false;
      _errorMessage = 'Kuwait number must be 8 digits'.tr;
    } else if (!kuwaitPhoneRegex.hasMatch(value)) {
      _isValid = false;
      _errorMessage = 'Kuwait numbers start with 5, 6, 9, 2, or 41'.tr;
    } else {
      _isValid = true;
      _errorMessage = null;
      _successMessage = 'Valid Kuwait phone number'.tr;
    }
  }

  void _validateName(String value) {
    final nameRegex = RegExp(r'^[a-zA-Z\s\u0600-\u06FF]+$');

    if (value.trim().length < 2) {
      _isValid = false;
      _errorMessage = 'Name must be at least 2 characters'.tr;
    } else if (!nameRegex.hasMatch(value)) {
      _isValid = false;
      _errorMessage = 'Name can only contain letters'.tr;
    } else {
      _isValid = true;
      _errorMessage = null;
      _successMessage = 'Valid name'.tr;
    }
  }

  void _validateRequired(String value) {
    if (value.trim().isEmpty) {
      _isValid = false;
      _errorMessage = 'This field is required'.tr;
    } else {
      _isValid = true;
      _errorMessage = null;
      _successMessage = null;
    }
  }

  void _onFocusChange() {
    if (_focusNode == null || _animationController == null) return;
    setState(() {
      _isFocused = _focusNode!.hasFocus;
    });
    if (_isFocused) {
      _animationController!.forward();
    } else {
      _animationController!.reverse();
    }
  }

  @override
  void dispose() {
    _focusNode?.removeListener(_onFocusChange);
    controller.removeListener(_onTextChanged);
    widget.passwordController?.removeListener(_onTextChanged);
    if (widget.focusNode == null) {
      _focusNode?.dispose();
    }
    _animationController?.dispose();
    if (widget.controller == null) {
      controller.dispose();
    }
    super.dispose();
  }

  // ============================================
  // DEFAULT COLORS BASED ON THEME
  // ============================================
  Color _getDefaultFillColor(bool isDarkMode) {
    return isDarkMode
        ? AppThemeData.grey300Dark.withOpacity(0.5)
        : Colors.white;
  }

  Color _getDefaultBorderColor(bool isDarkMode) {
    return isDarkMode ? AppThemeData.grey300Dark : AppThemeData.grey200;
  }

  Color _getDefaultTextColor(bool isDarkMode) {
    return isDarkMode ? AppThemeData.grey900Dark : AppThemeData.grey900;
  }

  Color _getDefaultHintColor(bool isDarkMode) {
    return isDarkMode ? AppThemeData.grey400Dark : AppThemeData.grey400;
  }

  // ============================================
  // DEFAULT TEXT STYLES
  // ============================================
  TextStyle _getDefaultTextStyle(bool isDarkMode) {
    return TextStyle(
      fontFamily: AppThemeData.medium,
      fontSize: _fontSize,
      color: _getDefaultTextColor(isDarkMode),
      letterSpacing: 0.3,
      height: 1.4,
    );
  }

  TextStyle _getDefaultHintStyle(bool isDarkMode) {
    return TextStyle(
      color: _getDefaultHintColor(isDarkMode),
      fontSize: _fontSize,
      fontFamily: AppThemeData.regular,
      letterSpacing: 0.2,
    );
  }

  // ============================================
  // DYNAMIC BORDERS BASED ON VALIDATION
  // ============================================
  Color _getBorderColor(bool isDarkMode) {
    if (widget.validationType == ValidationType.none || !_hasInput) {
      return _getDefaultBorderColor(isDarkMode);
    }
    return _isValid ? Colors.green.shade400 : Colors.red.shade400;
  }

  OutlineInputBorder _getDefaultBorder(bool isDarkMode) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(_borderRadius),
      borderSide: BorderSide(
        color: _getBorderColor(isDarkMode),
        width: _hasInput && widget.validationType != ValidationType.none
            ? _focusedBorderWidth
            : _borderWidth,
      ),
    );
  }

  OutlineInputBorder _getDefaultFocusedBorder(bool isDarkMode) {
    if (widget.validationType != ValidationType.none && _hasInput) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
        borderSide: BorderSide(
          color: _isValid ? Colors.green.shade400 : Colors.red.shade400,
          width: _focusedBorderWidth,
        ),
      );
    }
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(_borderRadius),
      borderSide: BorderSide(
        color: AppThemeData.primary200,
        width: _focusedBorderWidth,
      ),
    );
  }

  OutlineInputBorder _getDefaultErrorBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(_borderRadius),
      borderSide: BorderSide(
        color: AppThemeData.error50,
        width: _borderWidth,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDarkMode = themeChange.getThem();

    if (_borderAnimation == null || _focusNode == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _borderAnimation!,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_borderRadius),
              ),
              child: TextFormField(
                onTapOutside: (event) => FocusScope.of(context).unfocus(),
                onTap: widget.ontap,
                onChanged: (value) {
                  widget.onChanged?.call(value);
                },
                readOnly: widget.readOnly,
                keyboardType: widget.keyboardType,
                validator: widget.validator,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: controller,
                inputFormatters: widget.inputFormatters,
                maxLines: widget.maxLines ?? 1,
                minLines: widget.minLines,
                maxLength: widget.maxWords,
                textAlignVertical: TextAlignVertical.center,
                textInputAction: widget.textInputAction,
                onFieldSubmitted: (value) {
                  if (widget.textInputAction == TextInputAction.next) {
                    FocusScope.of(context).nextFocus();
                  }
                },
                obscureText: widget.obscureText ?? false,
                cursorWidth: widget.cursorWidth ?? 2.5,
                cursorRadius: widget.cursorRadius ?? const Radius.circular(2.0),
                cursorColor: widget.cursorColor ?? AppThemeData.primary200,
                autofocus: widget.autofocus ?? false,
                enableSuggestions: widget.enableSuggestions ?? true,
                autocorrect: widget.autocorrect ?? true,
                keyboardAppearance: widget.keyboardAppearance,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  suffixIcon: _buildSuffixIcon(isDarkMode),
                  suffixIconConstraints: widget.suffixIconConstraints ??
                      const BoxConstraints(
                        minWidth: 48,
                        minHeight: 48,
                      ),
                  prefixIcon: widget.prefixIcon,
                  prefixIconConstraints: widget.prefixIconConstraints ??
                      const BoxConstraints(
                        minWidth: 48,
                        minHeight: 48,
                      ),
                  hintText: widget.text,
                  hintStyle:
                      widget.hintStyle ?? _getDefaultHintStyle(isDarkMode),
                  filled: widget.filled,
                  fillColor:
                      widget.fillColor ?? _getDefaultFillColor(isDarkMode),
                  contentPadding: widget.contentPadding ?? _defaultPadding,
                  border: widget.border ?? _getDefaultBorder(isDarkMode),
                  enabledBorder:
                      widget.enabledBorder ?? _getDefaultBorder(isDarkMode),
                  focusedBorder:
                      widget.focusedBorder ?? _getDefaultFocusedBorder(isDarkMode),
                  errorBorder: widget.errorBorder ?? _getDefaultErrorBorder(),
                  disabledBorder:
                      widget.disabledBorder ?? _getDefaultBorder(isDarkMode),
                  counter: widget.counter,
                  errorStyle: TextStyle(
                    fontSize: 12,
                    fontFamily: AppThemeData.regular,
                    color: AppThemeData.error50,
                    letterSpacing: 0.2,
                  ),
                ),
                style: widget.textStyle ?? _getDefaultTextStyle(isDarkMode),
              ),
            );
          },
        ),
        // Validation Status Message
        if (widget.showValidationStatus &&
            widget.validationType != ValidationType.none)
          _buildValidationStatus(isDarkMode),
      ],
    );
  }

  Widget? _buildSuffixIcon(bool isDarkMode) {
    // If custom suffix icon is provided, use it
    if (widget.suffixIcon != null) {
      return widget.suffixIcon;
    }

    // Show validation status icon only when validation type is set
    if (widget.validationType != ValidationType.none && _hasInput) {
      return Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Icon(
          _isValid ? Iconsax.tick_circle5 : Iconsax.close_circle5,
          color: _isValid ? Colors.green.shade400 : Colors.red.shade400,
          size: 24,
        ),
      );
    }

    return null;
  }

  Widget _buildValidationStatus(bool isDarkMode) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Padding(
        key: ValueKey(_hasInput ? (_isValid ? 'valid' : 'invalid') : 'empty'),
        padding: const EdgeInsets.only(top: 6, left: 12, right: 12),
        child: _hasInput
            ? Row(
                children: [
                  Icon(
                    _isValid ? Iconsax.tick_circle : Iconsax.info_circle,
                    size: 14,
                    color:
                        _isValid ? Colors.green.shade600 : Colors.red.shade600,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _isValid
                          ? (_successMessage ?? '')
                          : (_errorMessage ?? 'Invalid input'.tr),
                      style: TextStyle(
                        fontSize: 12,
                        color: _isValid
                            ? Colors.green.shade600
                            : Colors.red.shade600,
                        fontFamily: AppThemeData.regular,
                      ),
                    ),
                  ),
                ],
              )
            : Text(
                _getHelperText(),
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode
                      ? AppThemeData.grey400Dark
                      : AppThemeData.grey400,
                  fontFamily: AppThemeData.regular,
                ),
              ),
      ),
    );
  }

  String _getHelperText() {
    switch (widget.validationType) {
      case ValidationType.email:
        return 'Enter a valid email address'.tr;
      case ValidationType.password:
        return 'Min ${widget.minPasswordLength} characters'.tr;
      case ValidationType.confirmPassword:
        return 'Re-enter your password'.tr;
      case ValidationType.phone:
        return 'Enter 8-digit Kuwait mobile number'.tr;
      case ValidationType.name:
        return 'Enter your name (letters only)'.tr;
      case ValidationType.required:
        return 'This field is required'.tr;
      case ValidationType.none:
        return '';
    }
  }
}
