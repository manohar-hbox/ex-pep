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

import 'package:email_validator/email_validator.dart';

Future<List<String>> processesEmailAddresses(String? emailAddresses) async {
  if (emailAddresses == null || emailAddresses.isEmpty) {
    return [];
  }

  List<String> emails = emailAddresses.split(',');
  List<String> validEmails = [];

  for (String email in emails) {
    email = email.trim(); // Trim whitespace
    if (EmailValidator.validate(email)) {
      validEmails.add(email);
    }
  }

  return validEmails;
}
