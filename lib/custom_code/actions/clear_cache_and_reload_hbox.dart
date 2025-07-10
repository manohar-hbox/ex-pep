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
import 'package:shared_preferences/shared_preferences.dart';

/// Clears stored tokens (both in SharedPreferences and FFAppState),
/// clears browser cache & localStorage, then reloads the app at its origin.
Future<void> clearCacheAndReloadHbox() async {
// 1️⃣ Clear tokens from SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('loginToken');
  await prefs.remove('hasuraToken');

  // 2️⃣ Clear tokens and redirect info from FFAppState
  FFAppState().loginToken = '';
  FFAppState().hasuraToken = '';
  FFAppState().redirectURL = '';
  FFAppState().patientClinicDataID = '';
  FFAppState().clinicID = '';

  // 3️⃣ Clear the same from localStorage
  html.window.localStorage.remove('loginToken');
  html.window.localStorage.remove('hasuraToken');
  html.window.localStorage.remove('redirect_url');
  html.window.localStorage.remove('patientClinicDataID');
  html.window.localStorage.remove('clinicID');

  // 4️⃣ Clear all caches
  try {
    final cacheNames = await html.window.caches!.keys();
    for (var name in cacheNames) {
      final cache = await html.window.caches!.open(name);
      await cache.clear();
    }
    print('Cache cleared.');
  } catch (e) {
    print('Error clearing cache: $e');
  }

  // 5️⃣ Reload the app at its base URL
  await Future.delayed(const Duration(milliseconds: 50));
  html.window.location.href = html.window.location.origin;
}
