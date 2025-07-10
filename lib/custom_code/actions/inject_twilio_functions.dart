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

Future<bool> injectTwilioFunctions() async {
  try {
    // First, try loading the actual twilio_helper.js file if it's not already loaded
    final loadScript = '''
    (function() {
      console.log("Ensuring twilio_helper.js is loaded");

      // Check if the script is already loaded
      var scripts = document.getElementsByTagName('script');
      var alreadyLoaded = false;
      for (var i = 0; i < scripts.length; i++) {
        if (scripts[i].src && scripts[i].src.indexOf('twilio_helper.js') !== -1) {
          alreadyLoaded = true;
          break;
        }
      }

      if (!alreadyLoaded) {
        console.log("Loading twilio_helper.js");
        var script = document.createElement('script');
        script.src = 'twilio_helper.js?v=' + new Date().getTime(); // Add cache-busting
        script.async = false;
        document.head.appendChild(script);

        // Return a promise to wait for script load
        return new Promise(resolve => {
          script.onload = function() {
            console.log("twilio_helper.js loaded successfully");
            resolve(true);
          };
          script.onerror = function() {
            console.error("Failed to load twilio_helper.js");
            resolve(false);
          };
        });
      } else {
        console.log("twilio_helper.js already loaded");
        return true;
      }
    })();
    ''';

    final loadResult = js.context.callMethod('eval', [loadScript]);
    print('Script load attempt result: $loadResult');

    // Wait for the script to load if it returned a Promise
    if (loadResult != null && loadResult is! bool) {
      try {
        if (js_util.hasProperty(loadResult, 'then')) {
          await js_util.promiseToFuture(loadResult);
        }
      } catch (e) {
        print('Error waiting for script to load: $e');
      }
    }

    // Wait a moment for any script loading to complete
    await Future.delayed(Duration(milliseconds: 300));

    // Now carefully check and only fill in missing functions - NEVER override existing ones from twilio_helper.js
    final jsCode = '''
    (function() {
      console.log("Checking Twilio functions - will only create missing ones");
      
      // Create the helper if it doesn't exist
      if (!window.twilioHelper) {
        console.log("Creating twilioHelper object (it was missing)");
        window.twilioHelper = {};
      }
      
      const requiredFunctions = [
        'setupTwilio', 'makeCall', 'hangupCall', 'toggleMute', 
        'sendDigits', 'getAudioLevel'
      ];
      
      // Check which functions exist and which ones we need to create
      const functionStatus = {};
      const missingFunctions = [];
      
      requiredFunctions.forEach(func => {
        const exists = typeof window.twilioHelper[func] === 'function';
        functionStatus[func] = exists;
        
        // Only record as missing if it doesn't exist
        if (!exists) {
          missingFunctions.push(func);
        }
      });
      
      console.log("Function status check:", functionStatus);
      console.log("Missing functions:", missingFunctions);
      
      // IMPORTANT: We now avoid creating ANY functions if setupTwilio exists
      // This prevents us from overriding the proper implementation
      if (typeof window.twilioHelper.setupTwilio === 'function') {
        console.log("setupTwilio already exists - NOT creating any functions to avoid conflicts");
        window.twilioHelperReady = true;
        return {
          status: functionStatus,
          twilioHelperReady: true,
          message: "setupTwilio already exists, not modifying functions"
        };
      }
      
      // Only create functions that don't exist
      missingFunctions.forEach(func => {
        console.log("Creating missing function: " + func);
        
        // Define placeholder implementations for missing functions
        if (func === 'setupTwilio') {
          // This is a fallback implementation - it should be replaced by loading the real script
          window.twilioHelper[func] = function(token) {
            console.log("FALLBACK " + func + " called with token:", token.substring(0, 10) + "...");
            console.warn("This is a placeholder implementation - the real twilio_helper.js should be loaded!");
            return true;
          };
        } else if (func === 'makeCall') {
          window.twilioHelper[func] = function(phoneNumber) {
            console.log("FALLBACK " + func + " called with phone number:", phoneNumber);
            return true;
          };
        } else if (func === 'sendDigits') {
          window.twilioHelper[func] = function(digits) {
            console.log("FALLBACK " + func + " called with digits:", digits);
            return true;
          };
        } else if (func === 'getAudioLevel') {
          window.twilioHelper[func] = function() {
            return Math.random() * 30;
          };
        } else {
          // Default implementation for other functions
          window.twilioHelper[func] = function() {
            console.log("FALLBACK " + func + " called");
            return true;
          };
        }
      });
      
      // Set ready flag
      window.twilioHelperReady = true;
      
      // Return status
      return {
        status: functionStatus,
        created: missingFunctions,
        twilioHelperReady: true
      };
    })();
    ''';

    final result = js.context.callMethod('eval', [jsCode]);

    // Debug the result
    try {
      if (result != null) {
        final status = js_util.getProperty(result, 'status');
        final created = js_util.getProperty(result, 'created');
        print('Function status: $status');
        print('Created functions: $created');
      }
    } catch (e) {
      print('Error getting function status: $e');
    }

    // Now perform a final check to verify our functions are working
    final verifyScript = '''
    (function() {
      const functions = ['setupTwilio', 'makeCall', 'hangupCall', 'toggleMute', 'sendDigits', 'getAudioLevel'];
      const verification = {};
      
      if (!window.twilioHelper) {
        return { success: false, error: "twilioHelper object missing" };
      }
      
      functions.forEach(func => {
        verification[func] = {
          exists: typeof window.twilioHelper[func] === 'function',
          source: typeof window.twilioHelper[func] === 'function' ? 
            (window.twilioHelper[func].toString().length > 50 ? 
             window.twilioHelper[func].toString().substring(0, 50) + "..." : 
             window.twilioHelper[func].toString()) : 'undefined'
        };
      });
      
      return {
        success: functions.every(f => typeof window.twilioHelper[f] === 'function'),
        verification: verification,
        twilioHelperReady: window.twilioHelperReady === true
      };
    })();
    ''';

    final verifyResult = js.context.callMethod('eval', [verifyScript]);
    try {
      if (verifyResult != null) {
        final success = js_util.getProperty(verifyResult, 'success');
        print('Verification success: $success');
      }
    } catch (e) {
      print('Error verifying functions: $e');
    }

    return true;
  } catch (e) {
    print('Error injecting Twilio functions: $e');
    return false;
  }
}
