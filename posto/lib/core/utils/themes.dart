import 'package:flutter/material.dart';

CustomTheme currentTheme = CustomTheme();

class CustomTheme with ChangeNotifier {
  static ThemeData get lightTheme {
    _CustomColorPalette colorPalette = const _CustomColorPalette(
      dominantColor: Color(0xFF64748B),
      accentColorBasic: Color(0xFF94A3B8),
      accentColorDetail: Color(0xFF6B7280),
      accentColorFront: Color(0xFFF8FAFC),
      accentColorBack: Color(0xFFE7E7E7),
      textColor: Color(0xFF1A1A1A),
      invertedTextColor: Color(0xFFFFFFFF),
      fadedTextColor: Color(0xFF6B7280),
      fadedCardColor: Color(0xFFCECECE),
      shadowColor: Color(0x3B000000),
      errorColor: Color(0xFFDC2626),
      correctColor: Color(0xFF059669),
      shimmerBaseColor: Color(0xFF818181),
      shimmerHighlightColor: Color(0xFFE3E3E3),
    );

    return _generateThemeFromColors(colorPalette);
  }

  static ThemeData get darkTheme {
    _CustomColorPalette colorPalette = const _CustomColorPalette(
      dominantColor: Color(0xFF30e67c),
      accentColorBasic: Color(0xFF30e6af),
      accentColorDetail: Color(0xFF00ff3f),
      accentColorFront: Color(0x80252528),
      accentColorBack: Color(0xFF09090B),
      textColor: Color(0xFFe8ffef),
      invertedTextColor: Color(0xFF111111),
      fadedTextColor: Color(0xFF969696),
      fadedCardColor: Color(0xA020202A),
      shadowColor: Color(0xC2000000),
      errorColor: Color(0xFFFF6161),
      correctColor: Color(0xB349FF49),
      shimmerBaseColor: Color(0xFF585867),
      shimmerHighlightColor: Color(0xFF70707E),
    );

    return _generateThemeFromColors(colorPalette);
  }

  static ThemeData _generateThemeFromColors(_CustomColorPalette colorPalette) {
    return ThemeData(
      shadowColor: colorPalette.shadowColor,
      cardColor: colorPalette.accentColorFront,
      hintColor: colorPalette.fadedTextColor,
      dividerColor: colorPalette.correctColor,
      primaryColor: colorPalette.dominantColor,
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.all(colorPalette.dominantColor),
      ),
      iconTheme: IconThemeData(
        color: colorPalette.textColor,
      ),
      cardTheme: CardThemeData(
        color: colorPalette.accentColorFront,
      ),
      colorScheme: ColorScheme.dark(
        primary: colorPalette.dominantColor,
        secondary: colorPalette.accentColorBasic,
        tertiary: colorPalette.accentColorDetail,
        surface: colorPalette.accentColorBack,
        outline: colorPalette.dominantColor,
        error: colorPalette.errorColor,
        shadow: colorPalette.fadedCardColor,
        onSurface: colorPalette.textColor,
        surfaceDim: colorPalette.shimmerBaseColor,
        surfaceBright: colorPalette.shimmerHighlightColor,
        inverseSurface: colorPalette.invertedTextColor,
      ),
      textTheme: TextTheme(
        titleMedium: TextStyle(
          color: colorPalette.dominantColor,
          fontSize: 36,
          fontWeight: FontWeight.w900,
        ),
        headlineLarge: TextStyle(
          color: colorPalette.textColor,
          fontSize: 34,
          fontWeight: FontWeight.w400,
        ),
        headlineMedium: TextStyle(
          color: colorPalette.textColor,
          fontSize: 26,
          fontWeight: FontWeight.w400,
        ),
        headlineSmall: TextStyle(
          color: colorPalette.textColor,
          fontSize: 22,
          fontWeight: FontWeight.w400,
        ),
        bodyLarge: TextStyle(
          color: colorPalette.textColor,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        bodyMedium: TextStyle(
          color: colorPalette.textColor,
          fontSize: 18,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: TextStyle(
          color: colorPalette.fadedTextColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        displayLarge: TextStyle(
          color: colorPalette.fadedTextColor,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: colorPalette.fadedTextColor,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        displaySmall: TextStyle(
          color: colorPalette.fadedTextColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _CustomColorPalette {
  final Color dominantColor;
  final Color accentColorBasic;
  final Color accentColorDetail;
  final Color accentColorFront;
  final Color accentColorBack;
  final Color textColor;
  final Color invertedTextColor;
  final Color fadedTextColor;
  final Color fadedCardColor;
  final Color shadowColor;
  final Color errorColor;
  final Color correctColor;
  final Color shimmerBaseColor;
  final Color shimmerHighlightColor;

  const _CustomColorPalette({
    required this.dominantColor,
    required this.accentColorBasic,
    required this.accentColorDetail,
    required this.accentColorFront,
    required this.accentColorBack,
    required this.textColor,
    required this.invertedTextColor,
    required this.fadedCardColor,
    required this.shadowColor,
    required this.fadedTextColor,
    required this.errorColor,
    required this.correctColor,
    required this.shimmerBaseColor,
    required this.shimmerHighlightColor,
  });
}
