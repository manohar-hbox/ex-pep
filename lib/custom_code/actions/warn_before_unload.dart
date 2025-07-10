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

html.EventListener? _beforeUnloadHandler;

/// Call this function to manage the beforeunload warning.
Future<void> warnBeforeUnload(bool isCallOngoing) async {
  if (isCallOngoing) {
    // Avoid adding multiple listeners
    if (_beforeUnloadHandler == null) {
      _beforeUnloadHandler = (html.Event event) {
        final e = event as html.BeforeUnloadEvent;
        e.preventDefault();
        e.returnValue = 'Call is still ongoing. Do you really want to leave?';
      };
      html.window.addEventListener('beforeunload', _beforeUnloadHandler);
    }
  } else {
    // Remove the listener if it exists
    if (_beforeUnloadHandler != null) {
      html.window.removeEventListener('beforeunload', _beforeUnloadHandler);
      _beforeUnloadHandler = null;
    }
  }
}

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
