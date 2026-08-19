import 'package:cabme_driver/core/themes/constant_colors.dart';
import 'package:cabme_driver/core/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

/// Reusable phone input widget with Kuwait country code and real-time validation
class PhoneInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final bool readOnly;

  const PhoneInputWidget({
    super.key,
    required this.controller,
    this.onChanged,
    this.validator,
    this.readOnly = false,
  });

  @override
  State<PhoneInputWidget> createState() => _PhoneInputWidgetState();
}

class _PhoneInputWidgetState extends State<PhoneInputWidget> {
  bool _isValid = false;
  bool _hasInput = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_validatePhoneNumber);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_validatePhoneNumber);
    super.dispose();
  }

  void _validatePhoneNumber() {
    final phoneNumber = widget.controller.text;
    setState(() {
      _hasInput = phoneNumber.isNotEmpty;

      if (phoneNumber.isEmpty) {
        _isValid = false;
        _errorMessage = null;
        return;
      }

      // Kuwait phone numbers validation
      // Valid formats: 8 digits starting with 5, 6, 9, 2, or 41
      // Mobile: 5 (STC), 6 (Ooredoo), 9 (Zain), 41 (Virgin Mobile)
      // Landline: 2
      // Test: 999 (for testing purposes - use OTP: 123456)
      // Examples: 51234567, 66666666, 99887766, 22334455, 41020626, 99912345
      final kuwaitPhoneRegex = RegExp(r'^(41\d{6}|[5692]\d{7}|999\d{5})$');

      if (phoneNumber.length < 8) {
        _isValid = false;
        _errorMessage = 'Kuwait number must be 8 digits'.tr;
      } else if (phoneNumber.length > 8) {
        _isValid = false;
        _errorMessage = 'Kuwait number must be 8 digits'.tr;
      } else if (!kuwaitPhoneRegex.hasMatch(phoneNumber)) {
        _isValid = false;
        _errorMessage = 'Kuwait numbers start with 5, 6, 9, 2, or 41'.tr;
      } else {
        _isValid = true;
        _errorMessage = null;
      }
    });
  }

  Color _getBorderColor(bool isDarkMode) {
    if (!_hasInput) {
      return isDarkMode ? AppThemeData.grey200Dark : AppThemeData.grey200;
    }
    return _isValid ? Colors.green.shade400 : Colors.red.shade400;
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDarkMode = themeChange.getThem();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: _getBorderColor(isDarkMode),
              width: _hasInput ? 1.5 : 1,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(0)),
            color: isDarkMode
                ? AppThemeData.grey300Dark.withOpacity(0.3)
                : Colors.white,
          ),
          padding: const EdgeInsets.only(left: 10),
          child: TextFormField(
            controller: widget.controller,
            keyboardType: TextInputType.phone,
            readOnly: widget.readOnly,
            maxLength: 8,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(8),
            ],
            validator: widget.validator ??
                (value) {
                  if (value == null || value.isEmpty) {
                    return 'Phone number is required'.tr;
                  }

                  // Kuwait phone numbers: Mobile (5,6,9,41), Landline (2), Test (999)
                  final kuwaitPhoneRegex = RegExp(r'^(41\d{6}|[5692]\d{7}|999\d{5})$');

                  if (value.length != 8) {
                    return 'Kuwait number must be 8 digits'.tr;
                  }

                  if (!kuwaitPhoneRegex.hasMatch(value)) {
                    return 'Invalid Kuwait phone number'.tr;
                  }

                  return null;
                },
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              counterText: '',
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "🇰🇼 +965",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 1,
                      height: 24,
                      color: isDarkMode
                          ? AppThemeData.grey300Dark
                          : AppThemeData.grey300,
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
              suffixIcon: _hasInput
                  ? Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Icon(
                        _isValid ? Iconsax.tick_circle5 : Iconsax.close_circle5,
                        color: _isValid
                            ? Colors.green.shade400
                            : Colors.red.shade400,
                        size: 24,
                      ),
                    )
                  : null,
              hintText: '51234567'.tr,
              hintStyle: TextStyle(
                fontSize: 16,
                color: isDarkMode
                    ? AppThemeData.grey400Dark
                    : AppThemeData.grey400,
                fontFamily: 'pop',
              ),
              border: InputBorder.none,
              errorStyle: const TextStyle(height: 0, fontSize: 0),
            ),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color:
                  isDarkMode ? AppThemeData.grey900Dark : AppThemeData.grey900,
              fontFamily: 'pop',
            ),
            cursorColor: AppThemeData.primary200,
            onChanged: (value) {
              if (widget.onChanged != null) {
                widget.onChanged!(value);
              }
            },
          ),
        ),
        // Real-time error message or helper text
        const SizedBox(height: 6),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _hasInput
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Icon(
                        _isValid ? Iconsax.tick_circle : Iconsax.info_circle,
                        size: 14,
                        color: _isValid
                            ? Colors.green.shade600
                            : Colors.red.shade600,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _isValid
                              ? 'Valid Kuwait phone number'.tr
                              : _errorMessage ?? 'Invalid phone number'.tr,
                          style: TextStyle(
                            fontSize: 12,
                            color: _isValid
                                ? Colors.green.shade600
                                : Colors.red.shade600,
                            fontFamily: 'pop',
                          ),
                        ),
                      ),
                      // Character counter
                      Text(
                        '${widget.controller.text.length}/8',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode
                              ? AppThemeData.grey400Dark
                              : AppThemeData.grey400,
                          fontFamily: 'pop',
                        ),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'Enter 8-digit Kuwait mobile number'.tr,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode
                          ? AppThemeData.grey400Dark
                          : AppThemeData.grey400,
                      fontFamily: 'pop',
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
