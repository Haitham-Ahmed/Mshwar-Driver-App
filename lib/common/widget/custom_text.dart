import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String text;
  // Text widget properties
  final TextAlign? align;
  final TextDirection? direction;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final int? maxLines;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final Color? selectionColor;
  final bool? strutStyle;

  // TextStyle properties
  final bool? inherit;
  final Color? color;
  final Color? backgroundColor;
  final double? size;
  final FontWeight? weight;
  final FontStyle? fontStyle;
  final double? letterSpacing;
  final double? wordSpacing;
  final TextBaseline? textBaseline;
  final double? height;
  final Paint? foreground;
  final Paint? background;
  final List<Shadow>? shadows;
  final List<FontFeature>? fontFeatures;
  final List<FontVariation>? fontVariations;
  final TextDecoration? decoration;
  final Color? decorationColor;
  final TextDecorationStyle? decorationStyle;
  final double? decorationThickness;

  final String? package;
  final bool? debugLabel;
  final ui.TextLeadingDistribution? leadingDistribution;
  final TextOverflow? textOverflow;

  const CustomText({
    super.key,
    required this.text,
    this.align,
    this.direction,
    this.locale,
    this.softWrap,
    this.overflow,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
    this.strutStyle,

    // TextStyle properties
    this.inherit,
    this.color,
    this.backgroundColor,
    this.size,
    this.weight,
    this.fontStyle,
    this.letterSpacing,
    this.wordSpacing,
    this.textBaseline,
    this.height,
    this.foreground,
    this.background,
    this.shadows,
    this.fontFeatures,
    this.fontVariations,
    this.decoration,
    this.decorationColor,
    this.decorationStyle,
    this.decorationThickness,
    this.package,
    this.debugLabel,
    this.leadingDistribution,
    this.textOverflow,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      textDirection: direction,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      selectionColor: selectionColor,
      style: TextStyle(
        inherit: inherit ?? true,
        color: color,
        backgroundColor: backgroundColor,
        fontSize: size ?? 18,
        fontWeight: weight ?? FontWeight.normal,
        fontStyle: fontStyle ?? FontStyle.normal,
        letterSpacing: letterSpacing,
        wordSpacing: wordSpacing,
        textBaseline: textBaseline,
        height: height,
        leadingDistribution: leadingDistribution,
        foreground: foreground,
        background: background,
        shadows: shadows,
        fontFeatures: fontFeatures,
        fontVariations: fontVariations,
        decoration: decoration,
        decorationColor: decorationColor,
        decorationStyle: decorationStyle,
        decorationThickness: decorationThickness,
        fontFamily: 'pop',
        package: package,
        overflow: textOverflow,
      ),
    );
  }
}
