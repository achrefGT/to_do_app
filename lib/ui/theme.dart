import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/theme_services.dart';

class Themes {
  static final light = ThemeData(
    //primaryColor: white,
    //colorSchemeSeed: primaryClr, // Removed as it's not defined
    //backgroundColor: white, // Removed as it's not defined
    brightness: Brightness.light,
  );
  static final dark = ThemeData(
    //colorSchemeSeed: darkGreyClr, // Removed as it's not defined
    //backgroundColor: darkGreyClr, // Removed as it's not defined
    brightness: Brightness.dark,
  );
}

const Color bluishClr = Color(0xff4e5ae8);
const Color yellowClr = Color(0xffffb746);
const Color pinkClr = Color(0xffff4667);
const Color white = Colors.white;
const primaryClr = bluishClr;
const Color darkGreyClr = Color(0xff1221212);
Color darkHeaderClr = Colors.grey.shade800;

TextStyle get subHeadingStyle {
  return const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    // fontFamily: 'Lato', // Removed as Google Fonts is removed
  );
}

TextStyle get headingStyle {
  return const TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    // fontFamily: 'Lato', // Removed as Google Fonts is removed
  );
}

TextStyle get titleStyle {
  return const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    // fontFamily: 'Lato', // Removed as Google Fonts is removed
  );
}

TextStyle get subTitleStyle {
  return const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    // fontFamily: 'Lato', // Removed as Google Fonts is removed
  );
}
