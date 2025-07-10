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

import 'dart:js' as js; // Import dart:js for JavaScript interop

Future<bool> isTabMinimized() async {
  // Check if the browser tab is minimized or hidden in FlutterFlow using JavaScript

  // Using dart:js to run JavaScript code
  bool isMinimized = js.context.callMethod('eval', [
    '''
    (function() {
      return document.hidden || document.visibilityState === 'hidden';
    })();
  '''
  ]);

  if (isMinimized) {
    print('Browser is minimized');
  } else {
    print('Browser is not minimized');
  }

  return isMinimized;
}
