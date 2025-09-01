import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/constants/app_sizes.dart';

TextStyle getTextStyleMsrt({
  double fontSize = 16,
  FontWeight fontWeight = FontWeight.w400,
  TextAlign textAlign = TextAlign.center,
  //Color color = Colors.black,
  TextDecoration decoration = TextDecoration.none,
  Color? decorationColor,
  double? decorationThickness,
}) {
  return GoogleFonts.inter(
    fontSize: getWidth(fontSize),
    fontWeight: fontWeight,
    //color: color,
    decoration: decoration,
    decorationColor: decorationColor,
    decorationThickness: decorationThickness,
  );
}
