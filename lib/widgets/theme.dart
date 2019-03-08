import 'package:flutter/material.dart';

ThemeData buildTheme() {
  // We're going to define all of our font styles
  // in this method:
  TextTheme _buildTextTheme(TextTheme base) {
    return base.copyWith(
      headline: base.headline.copyWith(
        fontFamily: 'Merriweather',
        fontSize: 40.0,
        color: const Color(0xFF807A6B),
      ),
      // New code:
      // Used for the recipes' title:
      title: base.title.copyWith(
        fontFamily: 'Merriweather',
        fontSize: 15.0,
        color: const Color(0xFF807A6B),
      ),
      // Used for the recipes' duration:
      caption: base.caption.copyWith(
        color: const Color(0xFFCCC5AF),
        fontSize: 15.0,
      ),
    );
  }

  // We want to override a default light blue theme.
  final ThemeData base = ThemeData.light();

  AppBarTheme _buildAppBarTheme(AppBarTheme appBarBase) {
    return appBarBase.copyWith(
      textTheme: base.primaryTextTheme.copyWith(
        title: base.primaryTextTheme.title.copyWith(
          color: Color(0xff223344),
        )
      ),
//      color: const Color(0xFF223333),
    );
  }

  // And apply changes on it:
  return base.copyWith(
    appBarTheme: _buildAppBarTheme(base.appBarTheme),
    textTheme: _buildTextTheme(base.textTheme),
    // New code:
    primaryColor: const Color(0xFFFFF8E1),    // Appbar background
    indicatorColor: const Color(0xFF807A6B),
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    accentColor: const Color(0xFFFFF8E1),     // CircularProgressIndicator color
    iconTheme: IconThemeData(
      color: const Color(0xFFCCC5AF),
      size: 20.0,
    ),
    buttonColor: Colors.white,
  );
}

// https://developers.google.com/identity/branding-guidelines
// https://fonts.google.com/specimen/Roboto
// https://fonts.google.com/specimen/Merriweather
