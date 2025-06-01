import 'package:flutter/material.dart';
import '../core/constants.dart';

final ThemeData appTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    seedColor: kPrimaryColor,
    brightness: Brightness.light,
  ),
  scaffoldBackgroundColor: kBackgroundColor,
  useMaterial3: true,
  fontFamily: 'SansSerif',
);