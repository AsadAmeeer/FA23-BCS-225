import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  // Updated theme: a brighter material blue palette
  const primary = Color(0xFF1E88E5); // Material Blue 600
  const accent = Color(0xFF42A5F5); // Light blue accent
  const background = Color(0xFFF3F7FB);
  final base = ThemeData.light();

  return base.copyWith(
    primaryColor: primary,
    scaffoldBackgroundColor: background,
    colorScheme: base.colorScheme.copyWith(primary: primary, secondary: accent),
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
          color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    floatingActionButtonTheme:
        const FloatingActionButtonThemeData(backgroundColor: primary),
    textTheme: base.textTheme.apply(bodyColor: Colors.black87),
  );
}
