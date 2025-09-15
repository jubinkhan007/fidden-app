import 'package:flutter/material.dart';
import '../../utils/constants/app_colors.dart';

class AppBottomAppBarTheme {
  AppBottomAppBarTheme._();

  static BottomAppBarThemeData _baseBottomAppBarTheme({
    required Color color,
    required double elevation,
    required Color shadowColor,
   // required ShapeBorder shape,
  }) {
    return BottomAppBarThemeData(
      color: color,
      elevation: elevation,
      shadowColor: shadowColor,
     // shape: shape,
    );
  }

  static final BottomAppBarThemeData lightBottomAppBarTheme = _baseBottomAppBarTheme(
    color: Colors.white,
    elevation: 8,
    shadowColor: Colors.black12,
    //shape: const CircularNotchedRectangle(),
  );

  static final BottomAppBarThemeData darkBottomAppBarTheme = _baseBottomAppBarTheme(
    color: Colors.black,
    elevation: 4,
    shadowColor: Colors.black,
   // shape: const CircularNotchedRectangle(),
  );
}