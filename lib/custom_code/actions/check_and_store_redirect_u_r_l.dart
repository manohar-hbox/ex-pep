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

import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'dart:html' as html;

Future<void> checkAndStoreRedirectURL() async {
  Uri uri = Uri.base;

  // Step 1: Extract all top-level query params
  String? encodedRedirect = uri.queryParameters['redirectTo'];
  String? topLevelClinicID = uri.queryParameters['clinicID'];
  String? topLevelPatientClinicDataID =
      uri.queryParameters['patientClinicDataID'];

  if (encodedRedirect != null && encodedRedirect.isNotEmpty) {
    String fullRedirectUrl = encodedRedirect;

    // Step 2: Append missing patientClinicDataID if not already in redirectTo
    if (topLevelPatientClinicDataID != null &&
        !encodedRedirect.contains('patientClinicDataID=')) {
      fullRedirectUrl += encodedRedirect.contains('?') ? '&' : '?';
      fullRedirectUrl += 'patientClinicDataID=$topLevelPatientClinicDataID';
    }

    // Step 3: Append missing clinicID if not already in redirectTo
    if (topLevelClinicID != null && !encodedRedirect.contains('clinicID=')) {
      fullRedirectUrl += fullRedirectUrl.contains('?') ? '&' : '?';
      fullRedirectUrl += 'clinicID=$topLevelClinicID';
    }

    // Step 4: Decode and parse redirect URL
    String decodedRedirect = Uri.decodeComponent(fullRedirectUrl);
    Uri redirectUri = Uri.parse(decodedRedirect);

    // Step 5: Extract final values
    String? patientClinicDataID =
        redirectUri.queryParameters['patientClinicDataID'];
    String? clinicID = redirectUri.queryParameters['clinicID'];

    // Step 6: Store in FFAppState
    FFAppState().redirectURL = decodedRedirect;
    FFAppState().patientClinicDataID = patientClinicDataID ?? '';
    FFAppState().clinicID = clinicID ?? '';

    // Step 7: Store in localStorage (optional)
    html.window.localStorage['redirect_url'] = decodedRedirect;
    html.window.localStorage['patientClinicDataID'] = patientClinicDataID ?? '';
    html.window.localStorage['clinicID'] = clinicID ?? '';
  }
}
