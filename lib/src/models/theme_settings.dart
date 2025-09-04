import 'package:flutter/material.dart';

class MediaPickerTheme {
  final ThemeMode themeMode;
  final ColorScheme? lightColorScheme;
  final ColorScheme? darkColorScheme;
  final TextTheme? textTheme;
  final String? fontFamily;
  final BorderRadius? borderRadius;

  const MediaPickerTheme({
    this.themeMode = ThemeMode.system,
    this.lightColorScheme,
    this.darkColorScheme,
    this.textTheme,
    this.fontFamily,
    this.borderRadius,
  });

  static const defaultLightColorScheme = ColorScheme.light(
    primary: Color(0xFF1976D2),
    secondary: Color(0xFF03DAC6),
    surface: Color(0xFFFFFBFE),
    background: Color(0xFFFFFBFE),
    error: Color(0xFFBA1A1A),
  );

  static const defaultDarkColorScheme = ColorScheme.dark(
    primary: Color(0xFF90CAF9),
    secondary: Color(0xFF03DAC6),
    surface: Color(0xFF121212),
    background: Color(0xFF121212),
    error: Color(0xFFCF6679),
  );

  MediaPickerTheme copyWith({
    ThemeMode? themeMode,
    ColorScheme? lightColorScheme,
    ColorScheme? darkColorScheme,
    TextTheme? textTheme,
    String? fontFamily,
    BorderRadius? borderRadius,
  }) {
    return MediaPickerTheme(
      themeMode: themeMode ?? this.themeMode,
      lightColorScheme: lightColorScheme ?? this.lightColorScheme,
      darkColorScheme: darkColorScheme ?? this.darkColorScheme,
      textTheme: textTheme ?? this.textTheme,
      fontFamily: fontFamily ?? this.fontFamily,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }
}