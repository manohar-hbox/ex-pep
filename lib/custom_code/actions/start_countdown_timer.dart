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

import 'dart:async';

Timer? countdownTimer; // Global variable for the timer

Future<void> startCountdownTimer(bool startTimer) async {
  FFAppState appState = FFAppState();
  int initialSeconds = 120; // Store initial total seconds
  int totalSeconds = initialSeconds; // 2 minutes in seconds

  if (!startTimer) {
    stopCountdownTimer();
    appState.update(() {
      appState.countdownValue = formatTime(0);
      appState.countdownProgressBarValue = 0.0;
    });
  } else {
    if (countdownTimer != null) {
      countdownTimer!.cancel(); // Cancel the timer
      countdownTimer = null; // Reset the timer variabl
      print("Cancelled the existing timer");
    }
    appState.update(() {
      appState.countdownValue = formatTime(totalSeconds); // Set initial time
      appState.countdownProgressBarValue = 1.0; // Start progress at full
    });

    countdownTimer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (totalSeconds <= 0) {
        timer.cancel(); // Stop timer at 00:00
        stopCountdownTimer();
      } else {
        totalSeconds--; // Decrease seconds
        appState.update(() {
          appState.countdownValue =
              formatTime(totalSeconds); // Update formatted time
          appState.countdownProgressBarValue =
              totalSeconds / initialSeconds; // Update progress bar value
        });
      }
    });
  }
}

// Function to stop the timer from a button click
Future<void> stopCountdownTimer() async {
  if (countdownTimer != null) {
    countdownTimer!.cancel(); // Cancel the timer
    countdownTimer = null; // Reset the timer variable
    FFAppState().transferPatient = false;
    print("Cancelled the timer");
  } else {
    print("NOT Cancelled the timer");
  }
}

// Function to format seconds into mm:ss format
String formatTime(int seconds) {
  int minutes = seconds ~/ 60;
  int secs = seconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
}

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
