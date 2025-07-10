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

import 'dart:js' as js;
import 'dart:js_util' as js_util;
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'dart:html' as html;
import 'dart:async';

Future<String?> checkTwilioJsLoaded() async {
  try {
    // Add a small delay to ensure JavaScript context is updated
    await Future.delayed(Duration(milliseconds: 100));

    // Force clear any cached values in JavaScript
    js.context.callMethod('eval', [
      '''
      delete window._twilioCheckCache;
    '''
    ]);

    // Run a comprehensive JavaScript check to diagnose Twilio status
    final jsCheckCode = '''
    (function() {
      console.log("Running comprehensive Twilio status check");
      
      // Force fresh evaluation by avoiding any cached values
      window._twilioCheckCache = null;
      
      var result = {
        twilioHelperExists: window.twilioHelper !== undefined,
        twilioHelperReady: window.twilioHelperReady === true,
        twilioSDKExists: window.Twilio !== undefined,
        availableFunctions: [],
        missingFunctions: []
      };

      // Check if scripts are loaded (added timestamp to avoid caching)
      var scripts = Array.from(document.getElementsByTagName('script'));
      result.twilioScriptLoaded = scripts.some(s => s.src && s.src.includes('twilio.js'));
      result.helperScriptLoaded = scripts.some(s => s.src && s.src.includes('twilio_helper.js'));

      console.log("Current twilioHelper value:", window.twilioHelper);
      console.log("Current twilioHelperReady value:", window.twilioHelperReady);
      
      // Check for all required functions
      var requiredFunctions = ['setupTwilio', 'makeCall', 'hangupCall', 'toggleMute', 'sendDigits', 'getAudioLevel'];

      if (window.twilioHelper) {
        for (var i = 0; i < requiredFunctions.length; i++) {
          var funcName = requiredFunctions[i];
          if (typeof window.twilioHelper[funcName] === 'function') {
            result.availableFunctions.push(funcName);
          } else {
            result.missingFunctions.push(funcName);
          }
        }
      }

      console.log("Twilio status check result:", result);
      return result;
    })();
    ''';

    final checkResult = js.context.callMethod('eval', [jsCheckCode]);

    // Build a user-friendly status message with timestamp to show it's fresh
    String result =
        'JavaScript Status Check (${DateTime.now().toString().substring(11, 19)}):\n';

    // Helper object status - add null check with default value
    final helperExists =
        js_util.getProperty(checkResult, 'twilioHelperExists') ?? false;
    result +=
        'twilioHelper object: ${helperExists ? "EXISTS ✅" : "MISSING ❌"}\n';

    // Ready flag status - add null check with default value
    final helperReady =
        js_util.getProperty(checkResult, 'twilioHelperReady') ?? false;
    result += 'twilioHelperReady flag: ${helperReady ? "TRUE ✅" : "FALSE ❌"}\n';

    // SDK status - add null check with default value
    final sdkExists =
        js_util.getProperty(checkResult, 'twilioSDKExists') ?? false;
    result += 'Twilio SDK: ${sdkExists ? "LOADED ✅" : "NOT LOADED ❌"}\n';

    // Script loading status - add null checks with default values
    final twilioScriptLoaded =
        js_util.getProperty(checkResult, 'twilioScriptLoaded') ?? false;
    final helperScriptLoaded =
        js_util.getProperty(checkResult, 'helperScriptLoaded') ?? false;

    result += 'Script tags:\n';
    result +=
        '- Twilio SDK script: ${twilioScriptLoaded ? "FOUND ✅" : "NOT FOUND ❌"}\n';
    result +=
        '- Twilio Helper script: ${helperScriptLoaded ? "FOUND ✅" : "NOT FOUND ❌"}\n';

    // Function availability
    final availableFunctions =
        js_util.getProperty(checkResult, 'availableFunctions');
    final missingFunctions =
        js_util.getProperty(checkResult, 'missingFunctions');

    result += '\nFunction availability:\n';

    if (availableFunctions is List && availableFunctions.isNotEmpty) {
      result += '- Available functions: ${availableFunctions.join(', ')} ✅\n';
    } else {
      result += '- No functions available ❌\n';
    }

    if (missingFunctions is List && missingFunctions.isNotEmpty) {
      result += '- Missing functions: ${missingFunctions.join(', ')} ❌\n';

      // Try to fix missing functions
      result += '\nAttempting to fix missing functions...\n';

      // Inject all missing functions if needed
      await injectTwilioFunctions();

      // Check if the fix worked
      final fixCheckJs = '''
      (function() {
        if (!window.twilioHelper) return { fixed: [] };

        var missing = ${missingFunctions.map((f) => '"$f"').toList()};
        var fixed = [];

        for (var i = 0; i < missing.length; i++) {
          var funcName = missing[i];
          if (typeof window.twilioHelper[funcName] === 'function') {
            fixed.push(funcName);
          }
        }

        return { fixed: fixed };
      })();
      ''';

      final fixResult = js.context.callMethod('eval', [fixCheckJs]);
      final fixedFunctions = js_util.getProperty(fixResult, 'fixed');

      if (fixedFunctions is List && fixedFunctions.isNotEmpty) {
        result += '- Successfully fixed: ${fixedFunctions.join(', ')} ✅\n';
      } else {
        result += '- No functions were fixed ❌\n';
      }
    } else if (helperExists) {
      result += '- All required functions are available ✅\n';
    }

    // Set the ready flag in any case to try to recover
    js.context['twilioHelperReady'] = true;

    if (!helperExists ||
        (missingFunctions is List && missingFunctions.isNotEmpty)) {
      result += '\nFinal recovery attempt in progress...\n';

      // Try a final recovery through the injection function
      final recoveryResult = await injectTwilioFunctions();
      result += recoveryResult
          ? 'Recovery succeeded ✅\n'
          : 'Recovery failed, please refresh the page ❌\n';
    }

    return result;
  } catch (e) {
    return 'Error checking Twilio JavaScript: $e (${DateTime.now().toString().substring(11, 19)})';
  }
}
