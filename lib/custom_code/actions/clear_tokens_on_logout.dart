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

import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

Future<void> clearTokensOnLogout() async {
  final prefs = await SharedPreferences.getInstance();

  // Removing the tokens
  await prefs.remove('loginToken');
  await prefs.remove('hasuraToken');

  // You can also log or return a confirmation message
  print('Tokens cleared on logout.');
}

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
