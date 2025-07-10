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

import 'package:shared_preferences/shared_preferences.dart';

Future<void> loadHasuraAndLoginToken() async {
  // Get SharedPreferences instance
  final prefs = await SharedPreferences.getInstance();

  // Read the loginToken from shared preferences
  String? loginToken = prefs.getString('loginToken');

  // Read the hasuraToken from shared preferences
  String? hasuraToken = prefs.getString('hasuraToken');

  // Update the app state if the values are not null
  if (loginToken != null) {
    FFAppState().loginToken = loginToken;
  }

  if (hasuraToken != null) {
    FFAppState().hasuraToken = hasuraToken;
  }
}

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
