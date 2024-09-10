// Themes.Colors.dart
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class Theme1Colors {
  //// #FDB082 text
  //// #FFFFFF main
  static HexColor mainColor = HexColor('#FFFFFF');
  static HexColor textColor = HexColor('#FDB082');

  static LinearGradient theme1Gradient = const LinearGradient(
    begin: Alignment(0.98, -0.18),
    end: Alignment(-0.98, 0.18),
    colors: [Color(0xFFFBDD94), Color(0xFFFDB082), Color(0xFFE05C41)]
  );
}

class Theme2Colors {
  //// #7BA20C text
  //// #FFFFFF main
  static HexColor mainColor = HexColor('#FFFFFF');
  static HexColor textColor = HexColor('#7BA20C');


  static LinearGradient theme2Gradient = const LinearGradient(
    begin: Alignment(1.00, 0.00),
    end: Alignment(-1.00, 0.00),
    colors: [Color(0xFFDBD95E), Color(0xFF79A10A)]
  );
}

class Theme3Colors {
  //// #604927 text
  //// #FCF8EE main
  static HexColor mainColor = HexColor('#FCF8EE');
  static HexColor textColor = HexColor('#604927');

}

class Theme4Colors {
  //// #0189BB text
  //// #FFFFFF main
  static HexColor mainColor = HexColor('#FFFFFF');
  static HexColor textColor = HexColor('#0189BB');

  static LinearGradient theme4Gradient = const LinearGradient(
    begin: Alignment(1.00, 0.00),
    end: Alignment(-1, 0),
    colors: [Color(0xFFD3E6EC), Color(0xFF014576)]
  );
}