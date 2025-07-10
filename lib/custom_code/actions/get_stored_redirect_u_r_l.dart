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

String? getStoredRedirectURL() {
  String? storedUrl = html.window.localStorage['redirect_url'];
  print('Stored redirect URL: $storedUrl'); // Print the stored URL

  if (storedUrl != null && storedUrl.isNotEmpty) {
    return storedUrl; // Return the stored URL
  }
  return null; // Return null if no URL is found
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
