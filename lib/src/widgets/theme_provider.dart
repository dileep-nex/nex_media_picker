import 'package:flutter/material.dart';
import '../models/theme_settings.dart';

class MediaPickerThemeProvider extends ChangeNotifier {
  MediaPickerTheme _theme = const MediaPickerTheme();

  MediaPickerTheme get theme => _theme;

  void updateTheme(MediaPickerTheme newTheme) {
    _theme = newTheme;
    notifyListeners();
  }

  void toggleThemeMode() {
    final newMode = _theme.themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;

    updateTheme(_theme.copyWith(themeMode: newMode));
  }

  bool get isDarkMode {
    final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    return _theme.themeMode == ThemeMode.dark ||
        (_theme.themeMode == ThemeMode.system && brightness == Brightness.dark);
  }

  ColorScheme get currentColorScheme {
    if (isDarkMode) {
      return _theme.darkColorScheme ?? MediaPickerTheme.defaultDarkColorScheme;
    }
    return _theme.lightColorScheme ?? MediaPickerTheme.defaultLightColorScheme;
  }

  ThemeData get lightTheme => ThemeData(
    colorScheme: _theme.lightColorScheme ?? MediaPickerTheme.defaultLightColorScheme,
    textTheme: _theme.textTheme,
    fontFamily: _theme.fontFamily,
    useMaterial3: true,
  );

  ThemeData get darkTheme => ThemeData(
    colorScheme: _theme.darkColorScheme ?? MediaPickerTheme.defaultDarkColorScheme,
    textTheme: _theme.textTheme,
    fontFamily: _theme.fontFamily,
    useMaterial3: true,
  );
}