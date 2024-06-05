import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class MainColors {
  //// #FDB082
  static HexColor mainColor = HexColor('#FFFFFF');
  static HexColor textColor = HexColor('#FDB082');

  static LinearGradient theme1Gradient = const LinearGradient(
    begin: Alignment(0.98, -0.18),
    end: Alignment(-0.98, 0.18),
    colors: [Color(0xFFFBDD94), Color(0xFFFDB082), Color(0xFFE05C41)],
  );

  static LinearGradient theme2Gradient = const LinearGradient(
    begin: Alignment(1.00, 0.00),
    end: Alignment(-1.00, 0.00),
    colors: [Color(0xFFDBD95E), Color(0xFF79A10A)],
  );
}
