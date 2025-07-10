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

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!

import 'package:flutter/services.dart';

Future<String> pasteCopiedEMRsWithCommas() async {
  ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
  if (data == null || data.text == null) return '';

  // Split by new lines, trim items, filter empty ones, and join with commas
  return data.text!
      .split('\n')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .join(', ');
}
