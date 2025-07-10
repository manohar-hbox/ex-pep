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

Future<void> notificationPermission() async {
  if (html.Notification.supported) {
    final permission = await html.Notification.requestPermission();

    if (permission == 'granted') {
      print('Notification permission granted.');
    } else if (permission == 'denied') {
      print('Notification permission denied.');
    } else {
      print('Notification permission dismissed.');
    }
  } else {
    print('Notifications are not supported in this browser.');
  }
}

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
