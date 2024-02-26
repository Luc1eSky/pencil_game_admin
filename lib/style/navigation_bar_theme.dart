import 'package:flutter/material.dart';

final navigationBarTheme = NavigationBarThemeData(
  labelTextStyle: MaterialStateProperty.resolveWith<TextStyle>(
    (Set<MaterialState> states) => states.contains(MaterialState.selected)
        ? const TextStyle(color: Colors.white)
        : const TextStyle(color: Colors.black),
  ),
);
