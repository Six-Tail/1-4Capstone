import 'package:flutter/material.dart';
import 'package:project/themes/app_color.dart';

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  backgroundColor: AppColor.bodyColorDark,
  scaffoldBackgroundColor: AppColor.bodyColorDark,
  hintColor: AppColor.textColor,
  primaryColorLight: AppColor.buttonBackgroundColorDark,
  textTheme: const TextTheme(
    headline1: TextStyle(
      color: Colors.white,
      fontSize: 40,
      fontWeight: FontWeight.bold,
    ),
    bodyText1: TextStyle(
      color: Colors.white,
    ),
  ),
  buttonTheme: const ButtonThemeData(
    colorScheme: ColorScheme.dark(
      primary: Colors.white,
      onPrimary: Colors.black,
    ),
  ),
);
