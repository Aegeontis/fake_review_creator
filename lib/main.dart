import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

import '/backend/settings_manager.dart';
import '/screens/start.dart';

void main() {
  setDefaultSettings();
  runApp(const ScraperApp());
}

class ScraperApp extends StatelessWidget {
  const ScraperApp({super.key});

  static final _defaultLightColorScheme =
      ColorScheme.fromSwatch(primarySwatch: Colors.green);
  static final _defaultDarkColorScheme = ColorScheme.fromSwatch(
      primarySwatch: Colors.green, brightness: Brightness.dark);

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
      return MaterialApp(
        title: "Ebay picture scraper",
        theme: ThemeData(
          colorScheme: lightColorScheme ?? _defaultLightColorScheme,
        ),
        darkTheme: ThemeData(
          colorScheme: darkColorScheme ?? _defaultDarkColorScheme,
        ),
        themeMode: ThemeMode.system,
        home: const StartScreen(),
      );
    });
  }
}
