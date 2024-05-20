import 'package:flutter/material.dart';
import 'package:project/themes/app_color.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  backgroundColor: AppColor.bodyColor,
  scaffoldBackgroundColor: AppColor.bodyColor,
  hintColor: AppColor.textColor,
  primaryColorLight: AppColor.buttonBackgroundColor,
  textTheme: const TextTheme(
    headline1: TextStyle(
      color: Colors.black,
      fontSize: 40,
      fontWeight: FontWeight.bold,
    ),
    bodyText1: TextStyle(
      color: Colors.black,
    ),
  ),
  buttonTheme: const ButtonThemeData(
    colorScheme: ColorScheme.light(
      primary: Colors.black,
      onPrimary: Colors.white,
    ),
  ),
);
