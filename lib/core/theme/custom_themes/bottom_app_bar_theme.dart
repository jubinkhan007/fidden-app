import 'package:flutter/material.dart';
import '../../utils/constants/app_colors.dart';

class BottomAppBarThemeData {
  BottomAppBarThemeData._();

  static BottomAppBarTheme _baseBottomAppBarTheme({
    required Color color,
    required double elevation,
    required Color shadowColor,
   // required ShapeBorder shape,
  }) {
    return BottomAppBarTheme(
      color: color,
      elevation: elevation,
      shadowColor: shadowColor,
     // shape: shape,
    );
  }

  static final BottomAppBarTheme lightBottomAppBarTheme = _baseBottomAppBarTheme(
    color: Colors.white,
    elevation: 8,
    shadowColor: Colors.black12,
    //shape: const CircularNotchedRectangle(),
  );

  static final BottomAppBarTheme darkBottomAppBarTheme = _baseBottomAppBarTheme(
    color: Colors.black,
    elevation: 4,
    shadowColor: Colors.black,
   // shape: const CircularNotchedRectangle(),
  );
}