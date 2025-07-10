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

List<String> getOutboundNumbersFromResponse(List<dynamic> responseList) {
  if (responseList.isEmpty) return [];

  final phoneNumbers = responseList
      .map((item) => item['phone_number']?.toString())
      .where((number) => number != null && number.trim().isNotEmpty)
      .cast<String>()
      .toList();

  return phoneNumbers;
}

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
