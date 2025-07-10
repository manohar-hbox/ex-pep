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

Future<void> redirectToURL(BuildContext context) async {
  String? redirectTo = html.window.localStorage['redirect_url'];

  if (redirectTo != null && redirectTo.isNotEmpty) {
    html.window.localStorage.remove('redirect_url'); // Clear after reading

    Future.delayed(Duration(milliseconds: 100), () {
      context.go(redirectTo); // Navigate to the stored URL
    });
  } else if (FFAppState().redirectURL.isNotEmpty) {
    String? localRedirect = FFAppState().redirectURL;
    FFAppState().redirectURL = "";

    Future.delayed(Duration(milliseconds: 100), () {
      context.go(localRedirect); // Navigate to the stored URL
    });
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
