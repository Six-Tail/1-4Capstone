// Build.Themes.dart
import 'package:flutter/material.dart';
import '../utils/Themes.Colors.dart';

ThemeData buildTheme1() {
  return ThemeData(
    primaryColor: Theme1Colors.mainColor,
    hintColor: Theme1Colors.textColor,
    scaffoldBackgroundColor: Theme1Colors.mainColor,
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Theme1Colors.textColor),
    ),
    appBarTheme: AppBarTheme(
      color: Theme1Colors.mainColor,
      titleTextStyle: TextStyle(
        color: Theme1Colors.textColor,
        fontSize: 20,
      ),
    ),
  );
}

ThemeData buildTheme2() {
  return ThemeData(
    primaryColor: Theme2Colors.mainColor,
    hintColor: Theme2Colors.textColor,
    scaffoldBackgroundColor: Theme2Colors.mainColor,
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Theme2Colors.textColor),
    ),
    appBarTheme: AppBarTheme(
      color: Theme2Colors.mainColor,
      titleTextStyle: TextStyle(
        color: Theme2Colors.textColor,
        fontSize: 20,
      ),
    ),
  );
}

ThemeData buildTheme3() {
  return ThemeData(
    primaryColor: Theme3Colors.mainColor,
    hintColor: Theme3Colors.textColor,
    scaffoldBackgroundColor: Theme3Colors.mainColor,
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Theme3Colors.textColor),
    ),
    appBarTheme: AppBarTheme(
      color: Theme3Colors.mainColor,
      titleTextStyle: TextStyle(
        color: Theme3Colors.textColor,
        fontSize: 20,
      ),
    ),
  );
}

ThemeData buildTheme4() {
  return ThemeData(
    primaryColor: Theme4Colors.mainColor,
    hintColor: Theme4Colors.textColor,
    scaffoldBackgroundColor: Theme4Colors.mainColor,
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Theme4Colors.textColor),
    ),
    appBarTheme: AppBarTheme(
      color: Theme4Colors.mainColor,
      titleTextStyle: TextStyle(
        color: Theme4Colors.textColor,
        fontSize: 20,
      ),
    ),
  );
}
