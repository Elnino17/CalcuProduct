import 'package:BadreCalcuter/OptionPage.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: const OptionsPage(
      savedOrders: [],
    ),
    theme: ThemeData(
      primaryColor: Colors.blue,
      buttonTheme: ButtonThemeData(
        buttonColor: Colors.blue,
        textTheme: ButtonTextTheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    ),
  ));
}
