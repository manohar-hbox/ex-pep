// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:html' as html;

Future<bool> checkCtrlRPressed() async {
  bool isCtrlRPressed = false;

  // Listen for keydown events
  html.window.onKeyDown.listen((html.KeyboardEvent event) {
    // Check if 'Ctrl + R' is pressed
    if (event.ctrlKey && (event.key == 'r' || event.key == 'R')) {
      event.preventDefault(); // Prevent default browser reload
      isCtrlRPressed = true;
      print('Ctrl + R was pressed');
    }
  });

  return isCtrlRPressed;
}
