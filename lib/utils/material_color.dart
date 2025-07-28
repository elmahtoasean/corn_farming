import 'package:flutter/material.dart';

Map<int, Color> _colorSwatch = {
  50: Color.fromRGBO(255, 211, 158, .1),
  100: Color.fromRGBO(255, 211, 158, .2),
  200: Color.fromRGBO(255, 211, 158, .3),
  300: Color.fromRGBO(255, 211, 158, .4),
  400: Color.fromRGBO(255, 211, 158, .5),
  500: Color.fromRGBO(255, 211, 158, .6),
  600: Color.fromRGBO(255, 211, 158, .7),
  700: Color.fromRGBO(255, 211, 158, .8),
  800: Color.fromRGBO(255, 211, 158, .9),
  900: Color.fromRGBO(255, 211, 158, 1),
};

MaterialColor customSwatch = MaterialColor(0xFFFFD39E, _colorSwatch);
