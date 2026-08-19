import 'package:cabme_driver/core/themes/constant_colors.dart';
import 'package:cabme_driver/core/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class TextFieldThem {
  const TextFieldThem(Key? key);

  static buildTextField(
      {required String title,
      required TextEditingController controller,
      IconData? icon,
      String? Function(String?)? validators,
      TextInputType textInputType = TextInputType.text,
      bool obscureText = true,
      EdgeInsets contentPadding = EdgeInsets.zero,
      maxLine = 1,
      bool enabled = true,
      maxLength = 300,
      String? labelText}) {
    return TextFormField(
      obscureText: !obscureText,
      validator: validators,
      keyboardType: textInputType,
      textCapitalization: TextCapitalization.sentences,
      controller: controller,
      maxLines: maxLine,
      maxLength: maxLength,
      enabled: enabled,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
          counterText: "",
          labelText: labelText,
          hintText: title,
          contentPadding: contentPadding,
          suffixIcon: Icon(icon),
          border: const UnderlineInputBorder()),
    );
  }

  static boxBuildTextField({
    required String hintText,
    required TextEditingController controller,
    String? Function(String?)? validators,
    TextInputType textInputType = TextInputType.text,
    bool obscureText = true,
    EdgeInsets contentPadding = EdgeInsets.zero,
    maxLine = 1,
    bool enabled = true,
    Widget? prefix,
    Widget? suffix,
    maxLength = 300,
  }) {
    return TextFormField(
        obscureText: !obscureText,
        validator: validators,
        keyboardType: textInputType,
        textCapitalization: TextCapitalization.sentences,
        controller: controller,
        maxLines: maxLine,
        maxLength: maxLength,
        enabled: enabled,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
            prefixIcon: prefix,
            suffixIcon: suffix,
            counterText: "",
            contentPadding: const EdgeInsets.all(8),
            fillColor: Colors.white,
            filled: true,
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppThemeData.grey500, width: 0.7),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: ConstantColors.textFieldBoarderColor, width: 0.7),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: ConstantColors.textFieldBoarderColor, width: 0.7),
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(
                  color: ConstantColors.textFieldBoarderColor, width: 0.7),
            ),
            hintText: hintText,
            hintStyle: TextStyle(color: ConstantColors.hintTextColor)));
  }
}

class TextFieldWidget extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final String? Function(String?)? validators;
  final String? Function(String?)? onChanged;
  final String? Function(String?)? onSubmitBtn;
  final VoidCallback? onTap;
  final TextInputType textInputType;
  final bool obscureText;
  final EdgeInsets contentPadding;
  final int maxLine;
  final bool enabled;
  final bool isReadOnly;
  final Widget? prefix;
  final Widget? suffix;
  final int maxLength;
  final BorderRadius radius;
  final Color? borderColor;
  final bool? isBorderEnable;
  final List<TextInputFormatter>? inputFormatters;

  const TextFieldWidget(
      {super.key,
      required this.hintText,
      required this.controller,
      this.onChanged,
      this.onSubmitBtn,
      this.onTap,
      this.validators,
      this.textInputType = TextInputType.text,
      this.obscureText = true,
      this.contentPadding =
          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      this.maxLine = 1,
      this.enabled = true,
      this.prefix,
      this.suffix,
      this.maxLength = 300,
      this.radius = BorderRadius.zero,
      this.isReadOnly = false,
      this.borderColor,
      this.inputFormatters,
      this.isBorderEnable = true});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return TextFormField(
      readOnly: isReadOnly,
      onTap: onTap,
      onChanged: onChanged,
      cursorColor: AppThemeData.primary200,
      obscureText: !obscureText,
      validator: validators,
      keyboardType: textInputType,
      textCapitalization: TextCapitalization.sentences,
      controller: controller,
      maxLines: maxLine,
      maxLength: maxLength,
      onFieldSubmitted: onSubmitBtn,
      enabled: enabled,
      inputFormatters: inputFormatters, //
      textInputAction: TextInputAction.done,
      style: TextStyle(
        fontSize: 16,
        color: themeChange.getThem()
            ? AppThemeData.grey900Dark
            : AppThemeData.grey900,
        fontFamily: AppThemeData.regular,
      ),
      decoration: InputDecoration(
        prefixIcon: prefix,
        suffixIcon: suffix,
        counterText: "",
        contentPadding: contentPadding,
        fillColor: themeChange.getThem()
            ? AppThemeData.surface50Dark
            : AppThemeData.surface50,
        filled: true,
        focusedBorder: isBorderEnable == true
            ? OutlineInputBorder(
                borderRadius: radius,
                borderSide: BorderSide(
                  color: borderColor ??
                      (themeChange.getThem()
                          ? AppThemeData.grey200Dark
                          : AppThemeData.grey200),
                  width: 0.7,
                ),
              )
            : UnderlineInputBorder(
                borderRadius: const BorderRadius.only(),
                borderSide: BorderSide(
                  color: AppThemeData.primary200,
                  width: 0.8,
                ),
              ),
        disabledBorder: isBorderEnable == true
            ? OutlineInputBorder(
                borderRadius: radius,
                borderSide: BorderSide(
                  color: borderColor ??
                      (themeChange.getThem()
                          ? AppThemeData.grey200Dark
                          : AppThemeData.grey200),
                  width: 0.7,
                ),
              )
            : null,
        enabledBorder: isBorderEnable == true
            ? OutlineInputBorder(
                borderRadius: radius,
                borderSide: BorderSide(
                  color: borderColor ??
                      (themeChange.getThem()
                          ? AppThemeData.grey200Dark
                          : AppThemeData.grey200),
                  width: 0.7,
                ),
              )
            : null,
        errorBorder: isBorderEnable == true
            ? OutlineInputBorder(
                borderRadius: radius,
                borderSide: BorderSide(
                  color: borderColor ??
                      (themeChange.getThem()
                          ? AppThemeData.grey200Dark
                          : AppThemeData.grey200),
                  width: 0.7,
                ),
              )
            : null,
        border: isBorderEnable == true
            ? OutlineInputBorder(
                borderRadius: radius,
                borderSide: BorderSide(
                  color: borderColor ??
                      (themeChange.getThem()
                          ? AppThemeData.grey200Dark
                          : AppThemeData.grey200),
                  width: 0.7,
                ),
              )
            : InputBorder.none,
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: 16,
          color: themeChange.getThem()
              ? AppThemeData.grey500Dark
              : AppThemeData.grey500,
          fontFamily: AppThemeData.regular,
        ),
      ),
    );
  }
}

class TextFieldWithoutBorderWidget extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final String? Function(String?)? validators;
  final String? Function(String?)? onChanged;
  final String? Function(String?)? onSubmitBtn;
  final VoidCallback? onTap;
  final TextInputType textInputType;
  final bool obscureText;
  final EdgeInsets contentPadding;
  final int maxLine;
  final bool enabled;
  final bool isReadOnly;
  final Widget? prefix;
  final Widget? suffix;
  final int maxLength;
  final BorderRadius radius;
  final Color? borderColor;
  final bool? isBorderEnable;

  const TextFieldWithoutBorderWidget(
      {super.key,
      required this.hintText,
      required this.controller,
      this.onChanged,
      this.onSubmitBtn,
      this.onTap,
      this.validators,
      this.textInputType = TextInputType.text,
      this.obscureText = true,
      this.contentPadding =
          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      this.maxLine = 1,
      this.enabled = true,
      this.prefix,
      this.suffix,
      this.maxLength = 300,
      this.radius = BorderRadius.zero,
      this.isReadOnly = false,
      this.borderColor,
      this.isBorderEnable = true});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return TextFormField(
      readOnly: isReadOnly,
      onTap: onTap,
      onChanged: onChanged,
      cursorColor: AppThemeData.primary200,
      obscureText: !obscureText,
      validator: validators,
      keyboardType: textInputType,
      textCapitalization: TextCapitalization.sentences,
      controller: controller,
      maxLines: maxLine,
      maxLength: maxLength,
      onFieldSubmitted: onSubmitBtn,
      enabled: enabled,
      textInputAction: TextInputAction.done,
      style: TextStyle(
        fontSize: 16,
        color: themeChange.getThem()
            ? AppThemeData.grey900Dark
            : AppThemeData.grey900,
        fontFamily: AppThemeData.regular,
      ),
      decoration: InputDecoration(
        prefixIcon: prefix,
        suffixIcon: suffix,
        counterText: "",
        contentPadding: contentPadding,
        fillColor: themeChange.getThem()
            ? AppThemeData.surface50Dark
            : AppThemeData.surface50,
        filled: true,
        focusedBorder: null,
        disabledBorder: null,
        enabledBorder: null,
        errorBorder: null,
        border: InputBorder.none,
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: 16,
          color: themeChange.getThem()
              ? AppThemeData.grey500Dark
              : AppThemeData.grey500,
          fontFamily: AppThemeData.regular,
        ),
      ),
    );
  }
}
