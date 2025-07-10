// filepath: c:\Users\DELL\StudioProjects\pep\lib\custom_code\services\twilio_background_service.dart
// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Custom imports
import 'dart:async';
import 'dart:convert';
import 'dart:js' as js;
import 'dart:js_util' as js_util;
import 'dart:html' as html;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Added for date formatting
import '../actions/inject_twilio_functions.dart';
import '../widgets/twilio_incoming_call_dialog.dart';
import '../widgets/incoming_call_summary_dialog.dart';
import '../widgets/draggable_call_dialog.dart'; // Import the new draggable dialog
import '/backend/api_requests/api_calls.dart'; // Import API calls
import '/flutter_flow/custom_functions.dart'; // Import custom functions for getTwilioCallInformation
import '/custom_code/models/user_info.dart'; // Import for UserInfo model
import '/flutter_flow/custom_functions.dart' as functions;

/// A background service for handling Twilio calls, particularly incoming calls
/// This service works independently of the current screen
///
/// EVENT INTEGRATION ARCHITECTURE:
/// 1. HTML Dialog buttons call window.twilioHelper functions (acceptIncomingCall, rejectIncomingCall, hangupCall, toggleMute)
/// 2. twilioHelper functions interact with Twilio SDK and dispatch events (twilioCallAccepted, twilioCallRejected, etc.)
/// 3. Dart event listeners in _setupTwilioEventListeners() handle these events
/// 4. BroadcastChannel and cross-window messaging handle events across different windows/tabs
/// 5. Direct Dart methods (callAcceptMethod, etc.) are kept for backward compatibility but bypassed in favor of events
class TwilioBackgroundService {
  // Singleton instance
  static final TwilioBackgroundService _instance = TwilioBackgroundService._internal();

  factory TwilioBackgroundService() => _instance;

  TwilioBackgroundService._internal() {
    // Set up global handlers immediately when the singleton is first created
    _initializeEarlyHandlers();
  }

  // Early initialization of global handlers - called as soon as the singleton is created
  void _initializeEarlyHandlers() {
    try {
      print(
          'Setting up early global Dart handlers...');      // Create a global Dart handler that can be called from JavaScript
      js.context['DartTwilioHandler'] = js.JsObject.jsify({
        'handleIncomingCall':
        js.allowInterop((String fromNumber, String toNumber, String callerId, String callSid) {          print('EARLY DART CALL: handleIncomingCall called from JavaScript');
        print('From: $fromNumber, To: $toNumber, CallerId: $callerId, CallSid: $callSid');

        final callInfo = {
          'from': fromNumber,
          'to': toNumber,
          'callerId': callerId,
          'callSid': callSid,
        };

        _currentCallInfo = callInfo;
        _incomingCallController.add(callInfo);
        _handleIncomingCall(callInfo);
        }),        'getCallInfo': js.allowInterop(() {
          print('DART: getCallInfo called from JavaScript');
          print('DART: Returning current call info: $_currentCallInfo');
          if (_currentCallInfo.isEmpty) {
            return '{}';
          }
          return json.encode(_currentCallInfo);
        }),
        'handleIncomingCallDisconnection': js.allowInterop((String callInfoJson) {
          print('DART: handleIncomingCallDisconnection called from JavaScript with: $callInfoJson');
          try {
            final callInfo = json.decode(callInfoJson);
            handleIncomingCallDisconnection(null, callInfo);
          } catch (e) {
            print('Error parsing call info in handleIncomingCallDisconnection: $e');
            handleIncomingCallDisconnection(null, _currentCallInfo);
          }
        }),        'handleCallAccepted': js.allowInterop(() {
          print('EARLY DART CALL: handleCallAccepted called from JavaScript');
          // Clear auto-reject timer
          js.context.callMethod('eval', [
            '''
            if (window._autoRejectTimer) {
              console.log('Clearing auto-reject timer due to early call acceptance');
              clearTimeout(window._autoRejectTimer);
              window._autoRejectTimer = null;
            }
          '''
          ]);
          _hasActiveCall = true;
          _callWasAnswered = true; // Mark that this call was answered
          _showingCallDialog = false;
          _callAcceptedController.add(null);
        }),
        'handleCallRejected': js.allowInterop(() {
          print('EARLY DART CALL: handleCallRejected called from JavaScript');
          // Clear auto-reject timer
          js.context.callMethod('eval', [
            '''
            if (window._autoRejectTimer) {
              console.log('Clearing auto-reject timer due to early call rejection');
              clearTimeout(window._autoRejectTimer);
              window._autoRejectTimer = null;
            }
          '''          ]);
          _hasActiveCall = false;
          _showingCallDialog = false;

          // Clear transfer role data when call is rejected
          transferredToRoles.clear();
          transferredFromRoles.clear();
          print('Cleared transfer role data after call rejection');

          _callRejectedController.add(null);
        }),
        'handleCallDisconnected': js.allowInterop(() {
          print('EARLY DART CALL: handleCallDisconnected called from JavaScript');
          // Clear auto-reject timer
          js.context.callMethod('eval', [
            '''
            if (window._autoRejectTimer) {
              console.log('Clearing auto-reject timer due to early call disconnection');
              clearTimeout(window._autoRejectTimer);
              window._autoRejectTimer = null;
            }
          '''
          ]);          _hasActiveCall = false;
          _showingCallDialog = false;

          // Clear transfer role data when call ends
          transferredToRoles.clear();
          transferredFromRoles.clear();
          print('Cleared transfer role data after call disconnection');

          // Close all UI dialogs when caller disconnects (early handler)
          // 1. Close the draggable dialog overlay
          if (_draggableCallOverlayEntry != null) {
            print('Closing draggable dialog due to early call disconnection');
            _draggableCallOverlayEntry!.remove();
            _draggableCallOverlayEntry = null;
          }

          // 2. Close popup windows (incoming call popup, active call popup)
          print('Closing popup windows due to early call disconnection');
          _closePopups();

          // 3. Close HTML overlay dialogs
          print('Closing HTML overlay dialogs due to early call disconnection');
          js.context.callMethod('eval', [
            '''
            try {
              // Remove the main call overlay
              var overlay = document.getElementById('twilio-call-overlay');
              if (overlay && overlay.parentNode) {
                overlay.parentNode.removeChild(overlay);
                console.log('Removed twilio-call-overlay due to early disconnection');
              }
              
              // Remove any other call-related overlays
              var callOverlay = document.getElementById('call-summary-overlay');
              if (callOverlay && callOverlay.parentNode) {
                callOverlay.parentNode.removeChild(callOverlay);
                console.log('Removed call-summary-overlay due to early disconnection');
              }
            } catch (e) {
              console.error('Error removing HTML overlays on early disconnection:', e);
            }
          '''
          ]);

          _callDisconnectedController.add(null);

          // Show call summary dialog for incoming calls
          print('🎯 Early disconnect handler - _currentCallInfo: $_currentCallInfo');
          if (_currentCallInfo.isNotEmpty) {
            final context = _getCurrentContext();
            print('📞 Calling handleIncomingCallDisconnection from early disconnect handler');
            handleIncomingCallDisconnection(context, _currentCallInfo);
          } else {
            print('⚠️ _currentCallInfo is empty in early handler, cannot show call summary');
          }        }),
        // New methods for actual Twilio operations
        'callAcceptMethod': js.allowInterop(() {
          print('DART CALL: Accepting call from HTML dialog');
          acceptCall().then((success) {
            if (success) {
              print('Call accepted successfully');
              _hasActiveCall = true;
              _callWasAnswered = true; // Mark that this call was answered
              _showingCallDialog = false;
            } else {
              print('Failed to accept call');
            }
          });
        }),
        'callRejectMethod': js.allowInterop(() {
          print('DART CALL: Rejecting call from HTML dialog');

          // Preserve call info before any state changes
          final callInfoForSummary = Map<String, dynamic>.from(_currentCallInfo);
          print('📞 Preserved call info for summary: $callInfoForSummary');

          rejectCall().then((success) {
            if (success) {
              print('Call rejected successfully');
            } else {
              print('Failed to reject call');
            }            _hasActiveCall = false;
            _showingCallDialog = false;

            // Don't show call summary for declined calls
            print('📞 Call declined - no call summary will be shown');
          });
        }),
        'callHangupMethod': js.allowInterop(() {
          print('DART CALL: Hanging up call from HTML dialog');

          // Preserve call info before any state changes
          final callInfoForSummary = Map<String, dynamic>.from(_currentCallInfo);
          print('📞 Preserved call info for summary: $callInfoForSummary');

          hangupCall().then((success) {
            if (success) {
              print('Call hung up successfully');
            } else {
              print('Failed to hang up call');
            }
            _hasActiveCall = false;
            _showingCallDialog = false;

            // Show call summary after 2 seconds delay using preserved call info
            print('📞 Scheduling call summary after hangup from HTML (2 second delay)');
            Future.delayed(Duration(seconds: 2), () {
              if (callInfoForSummary.isNotEmpty) {
                final context = _getCurrentContext();
                print('📞 Showing call summary after hangup delay from HTML using preserved info');
                handleIncomingCallDisconnection(context, callInfoForSummary);
              } else {
                print(
                    '⚠️ Preserved call info is empty after hangup from HTML, cannot show call summary');
              }
            });
          }).catchError((error) {
            print('Error during hangup call: $error');
            _hasActiveCall = false;
            _showingCallDialog = false;

            // Still show call summary even if hangup failed
            print('📞 Scheduling call summary after hangup error (2 second delay)');
            Future.delayed(Duration(seconds: 2), () {
              if (callInfoForSummary.isNotEmpty) {
                final context = _getCurrentContext();
                print('📞 Showing call summary after hangup error using preserved info');
                handleIncomingCallDisconnection(context, callInfoForSummary);
              } else {
                print(
                    '⚠️ Preserved call info is empty after hangup error, cannot show call summary');
              }
            });
          });
        }),
        'callMuteMethod': js.allowInterop(() {
          print('DART CALL: Toggling mute from HTML dialog');
          toggleMute().then((success) {
            if (success) {
              print('Mute toggled successfully');
            } else {
              print('Failed to toggle mute');
            }
          });
        }),
        'resetDialogState': js.allowInterop(() {
          print('DART CALL: Resetting dialog state from JavaScript');
          // Clear auto-reject timer
          js.context.callMethod('eval', [
            '''
            if (window._autoRejectTimer) {
              console.log('Clearing auto-reject timer due to dialog state reset');
              clearTimeout(window._autoRejectTimer);
              window._autoRejectTimer = null;
            }
          '''
          ]);
          _showingCallDialog = false;
          // Don't clear _currentCallInfo immediately - wait a bit to allow call summary to be shown
          // This prevents the call summary from failing due to empty call info
          print('Dialog state reset - _showingCallDialog: $_showingCallDialog (preserving _currentCallInfo for call summary)');
          // Future.delayed(Duration(seconds: 5), () {
          //   _currentCallInfo = {};
          //   print('Delayed clearing of _currentCallInfo after 5 seconds in JavaScript resetDialogState handler');
          // });
        }),'clearAutoRejectTimer': js.allowInterop(() {
          print('DART CALL: Clearing auto-reject timer from JavaScript');
          js.context.callMethod('eval', [
            '''
            if (window._autoRejectTimer) {
              console.log('Manual clearing of auto-reject timer');
              clearTimeout(window._autoRejectTimer);
              window._autoRejectTimer = null;
            }          '''
          ]);
        }),        'resetCallSummaryFlag': js.allowInterop(() {
          print('DART CALL: Resetting call summary flag from JavaScript');
          _showingCallSummary = false;
          // Don't reset _callWasAnswered immediately - this should only be reset after call summary is shown
          print('Call summary flag reset - _showingCallSummary: $_showingCallSummary (preserving _callWasAnswered)');
        }),        'resetCallAnsweredFlag': js.allowInterop(() {
          print('DART CALL: Resetting call answered flag from JavaScript');
          _callWasAnswered = false;
          print('Call answered flag reset - _callWasAnswered: $_callWasAnswered');
        }),        'transferCall': js.allowInterop((String callSid) async {
          print('DART CALL: Transferring call from HTML dialog with CallSid: $callSid');
          print('Attempting call transfer to email: linda.e@hbox.ai with callSid: $callSid');
          print('Auth token length: ${FFAppState().loginToken?.length ?? 0}');

          try {
            final transferResult = await TwilioGroup.transferCall.call(
              email: "john.p@hbox.ai",
              callSid: callSid,
              authToken: FFAppState().loginToken,
            );

            print('Transfer API call completed');
            print('API response status: ${transferResult.statusCode}');
            print('API response: ${transferResult.jsonBody}');

            final success = transferResult.succeeded &&
                (TwilioGroup.transferCall.success(transferResult.jsonBody) ?? false);

            print('Transfer success: $success');

            if (success) {
              print('Call transfer initiated successfully');
              return true;
            } else {
              print('Call transfer failed - API response indicates failure');
              print('Transfer result body: ${transferResult.bodyText}');
              return false;
            }
          } catch (e) {
            print('ERROR during transfer API call: $e');
            return false;
          }
        }),
        'isReady': true,
        'earlyInit': true,
      });

      print('Early global Dart handlers setup complete');

      // Notify JavaScript that handlers are ready
      js.context.callMethod('eval', [
        '''
        console.log('Early DartTwilioHandler setup complete');
        console.log('window.DartTwilioHandler:', window.DartTwilioHandler);
        console.log('window.DartTwilioHandler.isReady:', window.DartTwilioHandler ? window.DartTwilioHandler.isReady : 'undefined');
        console.log('window.DartTwilioHandler.earlyInit:', window.DartTwilioHandler ? window.DartTwilioHandler.earlyInit : 'undefined');
        
        // Dispatch ready event
        const readyEvent = new CustomEvent('dartTwilioHandlerReady');
        document.dispatchEvent(readyEvent);
      '''
      ]);
    } catch (e) {
      print('Error setting up early global Dart handlers: $e');
    }
  }

  // Static method to ensure global handlers are available
  static void ensureGlobalHandlers() {
    // This will create the singleton and call _initializeEarlyHandlers
    TwilioBackgroundService();
  }

  // Stream controllers for call events
  final StreamController<Map<String, dynamic>> _incomingCallController =
  StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<void> _callAcceptedController = StreamController<void>.broadcast();
  final StreamController<void> _callRejectedController = StreamController<void>.broadcast();
  final StreamController<void> _callDisconnectedController = StreamController<void>.broadcast();
  final StreamController<String> _callErrorController = StreamController<String>.broadcast();
  final StreamController<bool> _callMuteController = StreamController<bool>.broadcast();
  final StreamController<String> _clientRegistrationController =
  StreamController<String>.broadcast();

  // Streams that can be listened to from Flutter
  Stream<Map<String, dynamic>> get onIncomingCall => _incomingCallController.stream;

  Stream<void> get onCallAccepted => _callAcceptedController.stream;

  Stream<void> get onCallRejected => _callRejectedController.stream;

  Stream<void> get onCallDisconnected => _callDisconnectedController.stream;

  Stream<String> get onCallError => _callErrorController.stream;

  Stream<bool> get onCallMute => _callMuteController.stream;

  Stream<String> get onClientRegistration => _clientRegistrationController.stream;  // Call state
  bool _isInitialized = false;
  bool _hasActiveCall = false;
  bool _showingCallDialog = false;
  bool _showingCallSummary = false; // Prevent duplicate call summaries
  bool _isMuted = false;
  bool _callWasAnswered = false; // Track if current call was ever accepted/answered
  Map<String, dynamic> _currentCallInfo = {};
  String _clientIdentity = '';
  String _storedCleanedCallerName = ''; // Store cleaned caller name for call summary
  String _storedCleanedClinicName = ''; // Store cleaned clinic name for call summary
  String _storedClinicId = ''; // Store clinic ID for call summary
  String _storedClinicTimeZone = ''; // Store clinic timezone for call summary

  var transferredFromRoles = <String>[];
  var transferredToRoles = <String>[];
  List<UserInfo> userRolesInfo = [];

  // Popup window management
  html.WindowBase? _incomingCallPopup;
  html.WindowBase? _activeCallPopup;
  Timer? _popupMonitorTimer;
  OverlayEntry? _draggableCallOverlayEntry;

  // Getters
  bool get hasActiveCall => _hasActiveCall;

  bool get isInitialized => _isInitialized;

  bool get isMuted => _isMuted;

  Map<String, dynamic> get currentCallInfo => _currentCallInfo;

  String get clientIdentity => _clientIdentity;

  // Method to reset dialog state if it gets stuck
  void resetDialogState() {
    print('Resetting dialog state. Previous state: $_showingCallDialog');
    _showingCallDialog = false;

    // Clear transfer role data when resetting dialog state
    transferredToRoles.clear();
    transferredFromRoles.clear();
    print('Cleared transfer role data during dialog state reset');

    // Don't clear _currentCallInfo immediately - wait a bit to allow call summary to be shown
    // This prevents the call summary from failing due to empty call info
    Future.delayed(Duration(seconds: 5), () {
      _currentCallInfo = {};
      print('Delayed clearing of _currentCallInfo after 5 seconds in resetDialogState');
    });

    _closePopups();
    _stopPopupMonitoring();

    // Also remove any HTML overlays
    if (kIsWeb) {
      js.context.callMethod('eval', [
        '''        var overlay = document.getElementById('twilio-call-overlay');
        if (overlay && overlay.parentNode) {
          console.log('Removing HTML overlay during state reset');
          overlay.parentNode.removeChild(overlay);
        }
      '''
      ]);
    }
  }

  // Set up the background service with a token and optional identity
  Future<bool> initialize(String token, {String? identity}) async {
    try {
      print('TwilioBackgroundService: Starting initialization with token');

      // Store client identity if provided
      if (identity != null && identity.isNotEmpty) {
        _clientIdentity = identity;
      }

      // Set up global Dart handlers FIRST before anything else
      _setupGlobalDartHandlers();

      // Ensure Twilio functions are injected
      final injectionResult = await injectTwilioFunctions();
      print('Twilio functions injection result: $injectionResult');

      // Now initialize Twilio with the token
      final setupResult = await _setupTwilio(token);
      print('Twilio setup result: $setupResult');

      if (setupResult) {
        _isInitialized = true;
        _setupEventListeners();

        // Notify listeners that client is registered and ready
        if (_clientIdentity.isNotEmpty) {
          _clientRegistrationController.add(_clientIdentity);
        }

        return true;
      } else {
        print('Failed to initialize Twilio background service');
        return false;
      }
    } catch (e) {
      print('Error initializing Twilio background service: $e');
      return false;
    }
  }

// Setup global Dart handlers that can be called directly from JavaScript
  void _setupGlobalDartHandlers() {
    try {
      print('Setting up global Dart handlers...');      // Create a global Dart handler that can be called from JavaScript
      js.context['DartTwilioHandler'] = js.JsObject.jsify({
        'handleIncomingCall':
        js.allowInterop((String fromNumber, String toNumber, String callerId, String callSid, String parameters) {
          print('DIRECT DART CALL: handleIncomingCall called from JavaScript');
          print('From: $fromNumber, To: $toNumber, CallerId: $callerId, CallSid: $callSid');

          final callInfo = {
            'from': fromNumber,
            'to': toNumber,
            'callerId': callerId,
            'callSid': callSid,
            'parameters': parameters,
          };

          _currentCallInfo = callInfo;
          _incomingCallController.add(callInfo);
          _handleIncomingCall(callInfo);
        }),        'getCallInfo': js.allowInterop(() {
          print('DART: getCallInfo called from JavaScript');
          print('DART: Returning current call info: $_currentCallInfo');
          if (_currentCallInfo.isEmpty) {
            return '{}';
          }
          return json.encode(_currentCallInfo);
        }),
        'handleIncomingCallDisconnection': js.allowInterop((String callInfoJson) {
          print('DART: handleIncomingCallDisconnection called from JavaScript with: $callInfoJson');
          try {
            final callInfo = json.decode(callInfoJson);
            handleIncomingCallDisconnection(null, callInfo);
          } catch (e) {
            print('Error parsing call info in handleIncomingCallDisconnection: $e');
            handleIncomingCallDisconnection(null, _currentCallInfo);
          }
        }),        'handleCallAccepted': js.allowInterop(() {
          print('DIRECT DART CALL: handleCallAccepted called from JavaScript');
          _hasActiveCall = true;
          _callWasAnswered = true; // Mark that this call was answered
          _showingCallDialog = false;
          _callAcceptedController.add(null);
        }),        'handleCallRejected': js.allowInterop(() {
          print('DIRECT DART CALL: handleCallRejected called from JavaScript');
          _hasActiveCall = false;
          _showingCallDialog = false;

          // Clear transfer role data when call is rejected
          transferredToRoles.clear();
          transferredFromRoles.clear();
          print('Cleared transfer role data after call rejection');

          _callRejectedController.add(null);
        }),
        'handleCallDisconnected': js.allowInterop(() {
          print('DIRECT DART CALL: handleCallDisconnected called from JavaScript');
          // Clear auto-reject timer
          js.context.callMethod('eval', [
            '''
            if (window._autoRejectTimer) {
              console.log('Clearing auto-reject timer due to direct call disconnection');
              clearTimeout(window._autoRejectTimer);
              window._autoRejectTimer = null;
            }
          '''
          ]);          _hasActiveCall = false;
          _showingCallDialog = false;

          // Clear transfer role data when call ends
          transferredToRoles.clear();
          transferredFromRoles.clear();
          print('Cleared transfer role data after call disconnection');

          // Close the draggable dialog overlay when caller disconnects
          if (_draggableCallOverlayEntry != null) {
            print('Closing draggable dialog due to direct call disconnection');
            _draggableCallOverlayEntry!.remove();
            _draggableCallOverlayEntry = null;
          }

          _callDisconnectedController.add(null);

          // Show call summary dialog for incoming calls
          print('🎯 Direct disconnect handler - _currentCallInfo: $_currentCallInfo');
          if (_currentCallInfo.isNotEmpty) {
            final context = _getCurrentContext();
            print('📞 Calling handleIncomingCallDisconnection from direct disconnect handler');
            handleIncomingCallDisconnection(context, _currentCallInfo);
          } else {
            print('⚠️ _currentCallInfo is empty in direct handler, cannot show call summary');
          }        }),
        // Add the missing methods for actual Twilio operations
        'callAcceptMethod': js.allowInterop(() {
          print('DART CALL: Accepting call from HTML dialog');
          acceptCall().then((success) {
            if (success) {
              print('Call accepted successfully');
              _hasActiveCall = true;
              _callWasAnswered = true; // Mark that this call was answered
              _showingCallDialog = false;
            } else {
              print('Failed to accept call');
            }
          });
        }),
        'callRejectMethod': js.allowInterop(() {
          print('DART CALL: Rejecting call from HTML dialog');
          rejectCall().then((success) {
            if (success) {
              print('Call rejected successfully');
            } else {
              print('Failed to reject call');
            }            _hasActiveCall = false;
            _showingCallDialog = false;

            // Don't show call summary for declined calls
            print('📞 Call declined - no call summary will be shown');
          });
        }),
        'callHangupMethod': js.allowInterop(() {
          print('DART CALL: Hanging up call from HTML dialog');

          // Preserve call info before any state changes
          final callInfoForSummary = Map<String, dynamic>.from(_currentCallInfo);
          print('📞 Preserved call info for summary: $callInfoForSummary');

          hangupCall().then((success) {
            if (success) {
              print('Call hung up successfully');
            } else {
              print('Failed to hang up call');
            }
            _hasActiveCall = false;
            _showingCallDialog = false;

            // Show call summary after 2 seconds delay using preserved call info
            print('📞 Scheduling call summary after hangup from HTML (2 second delay)');
            Future.delayed(Duration(seconds: 2), () {
              if (callInfoForSummary.isNotEmpty) {
                final context = _getCurrentContext();
                print('📞 Showing call summary after hangup delay from HTML using preserved info');
                handleIncomingCallDisconnection(context, callInfoForSummary);
              } else {
                print(
                    '⚠️ Preserved call info is empty after hangup from HTML, cannot show call summary');
              }
            });
          }).catchError((error) {
            print('Error during hangup call: $error');
            _hasActiveCall = false;
            _showingCallDialog = false;

            // Still show call summary even if hangup failed
            print('📞 Scheduling call summary after hangup error (2 second delay)');
            Future.delayed(Duration(seconds: 2), () {
              if (callInfoForSummary.isNotEmpty) {
                final context = _getCurrentContext();
                print('📞 Showing call summary after hangup error using preserved info');
                handleIncomingCallDisconnection(context, callInfoForSummary);
              } else {
                print(
                    '⚠️ Preserved call info is empty after hangup error, cannot show call summary');
              }
            });
          });
        }),
        'callMuteMethod': js.allowInterop(() {
          print('DART CALL: Toggling mute from HTML dialog');
          toggleMute().then((success) {
            if (success) {
              print('Mute toggled successfully');
            } else {
              print('Failed to toggle mute');
            }
          });
        }),
        'resetDialogState': js.allowInterop(() {
          print('DART CALL: Resetting dialog state from JavaScript');
          // Clear auto-reject timer
          js.context.callMethod('eval', [
            '''
            if (window._autoRejectTimer) {
              console.log('Clearing auto-reject timer due to dialog state reset');
              clearTimeout(window._autoRejectTimer);
              window._autoRejectTimer = null;
            }
          '''
          ]);
          _showingCallDialog = false;
          _hasActiveCall = false;

          // Don't clear _currentCallInfo immediately - wait a bit to allow call summary to be shown
          // This prevents the call summary from failing due to empty call info
          // Future.delayed(Duration(seconds: 5), () {
          //   _currentCallInfo = {};
          //   print('Delayed clearing of _currentCallInfo after 5 seconds');
          // });

          print(
              'Dialog state reset - _showingCallDialog: $_showingCallDialog (preserving _currentCallInfo for call summary)');
        }),        'clearAutoRejectTimer': js.allowInterop(() {
          print('DART CALL: Clearing auto-reject timer from JavaScript');
          js.context.callMethod('eval', [
            '''
            if (window._autoRejectTimer) {
              console.log('Manual clearing of auto-reject timer');
              clearTimeout(window._autoRejectTimer);
              window._autoRejectTimer = null;
            }          '''
          ]);
        }),        'resetCallSummaryFlag': js.allowInterop(() {
          print('DART CALL: Resetting call summary flag from JavaScript');
          _showingCallSummary = false;
          // Don't reset _callWasAnswered immediately - this should only be reset after call summary is shown
          print('Call summary flag reset - _showingCallSummary: $_showingCallSummary (preserving _callWasAnswered)');
        }),
        'resetCallAnsweredFlag': js.allowInterop(() {
          print('DART CALL: Resetting call answered flag from JavaScript');
          _callWasAnswered = false;
          print('Call answered flag reset - _callWasAnswered: $_callWasAnswered');
        }),
        'isReady': true,
      });

      print('Global Dart handlers setup complete');

      // Verify that the handler is accessible from JavaScript
      js.context.callMethod('eval', [
        '''
        console.log('Checking DartTwilioHandler availability...');
        console.log('window.DartTwilioHandler:', window.DartTwilioHandler);
        console.log('window.DartTwilioHandler.isReady:', window.DartTwilioHandler ? window.DartTwilioHandler.isReady : 'undefined');
        
        // Notify any waiting JavaScript code that Dart is ready
        if (window.DartTwilioHandler && window.DartTwilioHandler.isReady) {
          console.log('DartTwilioHandler is ready - dispatching ready event');
          const readyEvent = new CustomEvent('dartTwilioHandlerReady');
          document.dispatchEvent(readyEvent);
        } else {
          console.error('DartTwilioHandler setup failed');
        }
      '''
      ]);
      // Also add a test call that can be triggered from browser console
      js.context.callMethod('eval', [
        '''
        console.log('Setting up test function for DartTwilioHandler...');        window.testDartIncomingCall = function() {
          console.log('Testing direct Dart call...');
          if (window.DartTwilioHandler && window.DartTwilioHandler.handleIncomingCall) {
            window.DartTwilioHandler.handleIncomingCall('+13026006476', 'client:agent-123', '+13026006476', 'test-call-sid-direct');
            console.log('Direct Dart call made successfully');
          } else {
            console.error('DartTwilioHandler not available');
          }
        };
          window.testCallDisconnection = function() {
          console.log('Testing call disconnection and summary...');
          // Set up test call info
          window._lastCallInfo = {
            from: 'Test Caller',
            callerId: '+15551234567',
            callSid: 'CA123test456789',
            timestamp: new Date().toISOString()
          };
          
          if (window.DartTwilioHandler && window.DartTwilioHandler.handleIncomingCallDisconnection) {
            window.DartTwilioHandler.handleIncomingCallDisconnection(JSON.stringify(window._lastCallInfo));
            console.log('Call disconnection test triggered successfully');
          } else {
            console.error('DartTwilioHandler.handleIncomingCallDisconnection not available');
            // Fallback to manual test
            if (typeof window.testCallSummary === 'function') {
              window.testCallSummary(false);
            }
          }
        };
        
        window.testEnhancedCallSummary = function() {
          console.log('Testing enhanced call summary...');
          // Create test enhanced call data
          const enhancedCallInfo = {
            from: 'Dr. Sarah Johnson',
            callerId: '+15551234567',
            phoneNumber: '+15551234567',
            callSid: 'CA123enhanced456789',
            callStatus: 'completed',
            duration: '04:32',
            answeredAt: 'Dec 5, 2024 at 2:30 PM (EST)',
            completedAt: 'Dec 5, 2024 at 2:34 PM EST',
            patientName: 'Dr. Sarah Johnson'
          };
          
          // Set the enhanced data directly
          window._lastCallInfo = enhancedCallInfo;
          console.log('Enhanced call info set:', enhancedCallInfo);
          
          // Trigger the call summary
          if (typeof window.showCallSummary === 'function') {
            window.showCallSummary();
          } else if (window.DartTwilioHandler && window.DartTwilioHandler.showCallSummary) {
            window.DartTwilioHandler.showCallSummary(JSON.stringify(enhancedCallInfo));
          }
        };
        
        console.log('Test functions available:');
        console.log('- window.testDartIncomingCall() to test incoming call');
        console.log('- window.testCallDisconnection() to test call summary');
        console.log('- window.testEnhancedCallSummary() to test enhanced call summary with GraphQL data');
      '''
      ]);
    } catch (e) {
      print('Error setting up global Dart handlers: $e');
    }
  }

// Set up Twilio with the token
  Future<bool> _setupTwilio(String token) async {
    try {
      final setupScript = '''
      (function() {
        if (!window.twilioHelper || typeof window.twilioHelper.setupTwilio !== 'function') {
          console.error("setupTwilio function not available!");
          return false;
        }
        
        return window.twilioHelper.setupTwilio("$token");
      })();
      ''';

      final result = js.context.callMethod('eval', [setupScript]);

      // Handle Promise if returned
      if (result != null) {
        // Check if result is an object that could have a 'then' property
        if (result is! bool &&
            result is! String &&
            result is! num &&
            js_util
                .getProperty(js.context, 'Object')
                .callMethod('prototype.toString.call', [result]) ==
                '[object Object]') {
          try {
            if (js_util.hasProperty(result, 'then')) {
              final asyncResult = await js_util.promiseToFuture<dynamic>(result);
              return asyncResult == true;
            }
          } catch (e) {
            print('Error in promise resolution for setupTwilio: $e');
            return false;
          }
        }
      }

      return result == true;
    } catch (e) {
      print('Error setting up Twilio: $e');
      return false;
    }
  } // Set up event listeners for Twilio events

  void _setupEventListeners() {
    try {
      print('Setting up Twilio event listeners...');

      // Add JavaScript debug to confirm event is being dispatched
      js.context.callMethod('eval', [
        '''
        console.log('Setting up JavaScript event listener debug...');
        
        // Add a listener to verify events are being dispatched
        document.addEventListener('twilioIncomingCall', function(event) {
          console.log('JavaScript side received twilioIncomingCall event:', event);
          console.log('Event detail:', event.detail);
        });
        
        console.log('JavaScript event listener setup complete');
      '''
      ]); // Listen for incoming calls via events
      js.context['document'].addEventListener('twilioIncomingCall', js.allowInterop((event) {
        try {
          print('=== DART: Received twilioIncomingCall event ===');
          final detail = js_util.getProperty(event, 'detail');

          if (detail != null) {
            final callInfo = {
              'from': js_util.getProperty(detail, 'from'),
              'to': js_util.getProperty(detail, 'to'),
              'callerId': js_util.getProperty(detail, 'callerId'),
              'callSid': js_util.getProperty(detail, 'callSid'),
              'customParameters': js_util.hasProperty(detail, 'customParameters')
                  ? js_util.getProperty(detail, 'customParameters')
                  : {},
            };

            print('DART: Incoming call from ${callInfo['from']}');
            _currentCallInfo = callInfo;
            _incomingCallController.add(callInfo);
            _handleIncomingCall(callInfo);
          } else {
            print('DART: No detail found in twilioIncomingCall event');
          }
        } catch (e) {
          print('DART: Error processing twilioIncomingCall event: $e');
        }
      }));

      print('Dart event listener for twilioIncomingCall added successfully');

      // Test the event listener by dispatching a test event
      js.context.callMethod('eval', [
        '''
        console.log('Testing event listener setup...');
        setTimeout(() => {
          console.log('Dispatching test twilioIncomingCall event');
          const testEvent = new CustomEvent('twilioIncomingCall', {
            detail: {
              from: '+13026006476',
              to: 'client:agent-123', 
              callerId: '+13026006476',
              callSid: 'test-call-sid'
            }
          });
          document.dispatchEvent(testEvent);
          console.log('Test event dispatched');        }, 3000);
      '''
      ]);

      // Listen for call accepted events
      js.context['document'].addEventListener('twilioCallAccepted', js.allowInterop((event) {
        print('Call accepted event received');

        // Clear any auto-reject timer
        js.context.callMethod('eval', [
          '''
          if (window._autoRejectTimer) {
            console.log('Clearing auto-reject timer due to call acceptance');
            clearTimeout(window._autoRejectTimer);
            window._autoRejectTimer = null;
          }
        '''
        ]);

        _hasActiveCall = true;
        _callWasAnswered = true; // Mark that this call was answered
        _showingCallDialog = false;
        _callAcceptedController.add(null);
      }));

      // Listen for call rejected events
      js.context['document'].addEventListener('twilioCallRejected', js.allowInterop((event) {
        print('Call rejected event received');

        // Clear any auto-reject timer
        js.context.callMethod('eval', [
          '''
          if (window._autoRejectTimer) {
            console.log('Clearing auto-reject timer due to call rejection');
            clearTimeout(window._autoRejectTimer);
            window._autoRejectTimer = null;
          }
        '''        ]);
        _hasActiveCall = false;
        _callWasAnswered = false; // Reset since call was rejected, not answered
        _showingCallDialog = false;

        // Clear transfer role data when call is rejected
        transferredToRoles.clear();
        transferredFromRoles.clear();
        print('Cleared transfer role data after call rejection');

        _callRejectedController.add(null);
      }));// Listen for call disconnected events

      js.context['document'].addEventListener('twilioCallDisconnected', js.allowInterop((event) {
        print('🔍 DEBUG: twilioCallDisconnected event received');
        print('🔍 DEBUG: _currentCallInfo before preserving: $_currentCallInfo');
        print('Call disconnected event received');

        // Preserve call info immediately before any other operations that might clear it
        final callInfoForSummary = Map<String, dynamic>.from(_currentCallInfo);
        print('🎯 Preserved call info for summary: $callInfoForSummary');

        // Clear any auto-reject timer
        js.context.callMethod('eval', [
          '''
          if (window._autoRejectTimer) {
            console.log('Clearing auto-reject timer due to call disconnection');
            clearTimeout(window._autoRejectTimer);
            window._autoRejectTimer = null;
          }
        '''
        ]);        _hasActiveCall = false;
        _showingCallDialog = false;

        // Clear transfer role data when call ends
        transferredToRoles.clear();
        transferredFromRoles.clear();
        print('Cleared transfer role data after call disconnection');

        // Close all UI dialogs when call is disconnected
        // 1. Close the draggable dialog overlay
        if (_draggableCallOverlayEntry != null) {
          print('Closing draggable dialog due to call disconnection');
          _draggableCallOverlayEntry!.remove();
          _draggableCallOverlayEntry = null;
        }

        // 2. Close popup windows (incoming call popup, active call popup)
        print('Closing popup windows due to call disconnection');
        _closePopups();

        // 3. Close HTML overlay dialogs
        print('Closing HTML overlay dialogs due to call disconnection');
        js.context.callMethod('eval', [
          '''
          try {
            // Remove the main call overlay
            var overlay = document.getElementById('twilio-call-overlay');
            if (overlay && overlay.parentNode) {
              overlay.parentNode.removeChild(overlay);
              console.log('Removed twilio-call-overlay due to disconnection');
            }
            
            // Remove any other call-related overlays
            var callOverlay = document.getElementById('call-summary-overlay');
            if (callOverlay && callOverlay.parentNode) {
              callOverlay.parentNode.removeChild(callOverlay);
              console.log('Removed call-summary-overlay due to disconnection');
            }
          } catch (e) {
            console.error('Error removing HTML overlays on disconnection:', e);
          }
        '''
        ]);        _callDisconnectedController
            .add(null); // Show call summary dialog for incoming calls using preserved call info
        print('🎯 Main disconnect handler - using preserved callInfo: $callInfoForSummary');
        print('🔍 DEBUG: callInfoForSummary.isNotEmpty: ${callInfoForSummary.isNotEmpty}');
        if (callInfoForSummary.isNotEmpty) {
          final context = _getCurrentContext();
          print('� DEBUG: Found context: ${context != null}');
          print('�📞 Calling handleIncomingCallDisconnection from main disconnect handler');
          handleIncomingCallDisconnection(context, callInfoForSummary);
        } else {
          print('⚠️ Preserved call info is empty, cannot show call summary');
          print('🔍 DEBUG: _currentCallInfo was: $_currentCallInfo');
        }
      }));      // Listen for call cancelled events      js.context['document'].addEventListener('twilioCallCancelled', js.allowInterop((event) {
      print('Call cancelled event received');

      // Preserve call info immediately before any other operations that might clear it
      final callInfoForSummary = Map<String, dynamic>.from(_currentCallInfo);
      print('🎯 Preserved call info for summary: $callInfoForSummary');

      // Clear any auto-reject timer
      js.context.callMethod('eval', [
        '''
          if (window._autoRejectTimer) {
            console.log('Clearing auto-reject timer due to call cancellation');
            clearTimeout(window._autoRejectTimer);
            window._autoRejectTimer = null;
          }
        '''
      ]);

      // Check if there's still an active call in Twilio before resetting flags and closing UI
      bool shouldCloseUI = true;
      bool shouldResetAnsweredFlag = true;
      try {
        final jsResult = js.context.callMethod('eval', [
          '''
            (function() {
              // Check if there's an active Twilio call
              if (window.device && window.device.activeConnection && 
                  window.device.activeConnection.status && 
                  window.device.activeConnection.status() === 'open') {
                console.log('🔍 Active Twilio connection detected during cancel event');
                return 'active';
              }
              
              if (window.activeCall && 
                  (window.activeCall.status === 'open' || window.activeCall.status === 'connecting')) {
                console.log('🔍 Active call object detected during cancel event');
                return 'active';
              }
              
              if (window._currentCall && 
                  (window._currentCall.status === 'open' || window._currentCall.status === 'connecting')) {
                console.log('🔍 Current call object detected during cancel event');
                return 'active';
              }
              
              // Check via twilioHelper if available
              if (window.twilioHelper && window.twilioHelper.getCallStatus) {
                try {
                  var callStatus = window.twilioHelper.getCallStatus();
                  if (callStatus === 'connected' || callStatus === 'open' || callStatus === 'connecting') {
                    console.log('🔍 TwilioHelper reports active call (' + callStatus + ') during cancel event');
                    return 'active';
                  }
                } catch (e) {
                  console.log('Error checking call status via twilioHelper:', e);
                }
              }
              
              console.log('🔍 No active call detected during cancel event');
              return 'inactive';
            })();
            '''
        ]);

        String callStatus = jsResult?.toString() ?? 'inactive';
        print('🔍 Call status during cancel event: $callStatus');

        if (callStatus == 'active' && _callWasAnswered) {
          print('🎯 Call is still active and was answered - NOT closing UI or resetting flags');
          shouldCloseUI = false;
          shouldResetAnsweredFlag = false;
        } else if (callStatus == 'active') {
          print('🎯 Call is still active but not answered - keeping call active but may close incoming call UI');
          shouldResetAnsweredFlag = false; // Keep this false since call is still active
        }
      } catch (e) {
        print('Error checking call status: $e');
      }

      // Only reset states if we're sure the call is truly cancelled
      if (shouldCloseUI) {
        _hasActiveCall = false;
        _showingCallDialog = false;

        // Close all UI dialogs when call is truly cancelled
        // 1. Close the draggable dialog overlay
        if (_draggableCallOverlayEntry != null) {
          print('Closing draggable dialog due to call cancellation');
          _draggableCallOverlayEntry!.remove();
          _draggableCallOverlayEntry = null;
        }

        // 2. Close popup windows (incoming call popup, active call popup)
        print('Closing popup windows due to call cancellation');
        _closePopups();

        // 3. Close HTML overlay dialogs
        print('Closing HTML overlay dialogs due to call cancellation');
        js.context.callMethod('eval', [
          '''
            try {
              // Remove the main call overlay
              var overlay = document.getElementById('twilio-call-overlay');
              if (overlay && overlay.parentNode) {
                overlay.parentNode.removeChild(overlay);
                console.log('Removed twilio-call-overlay due to cancellation');
              }
              
              // Remove any other call-related overlays
              var callOverlay = document.getElementById('call-summary-overlay');
              if (callOverlay && callOverlay.parentNode) {
                callOverlay.parentNode.removeChild(callOverlay);
                console.log('Removed call-summary-overlay due to cancellation');
              }
            } catch (e) {
              console.error('Error removing HTML overlays on cancellation:', e);
            }
          '''
        ]);
      } else {
        print('🎯 NOT closing UI - call is still active despite cancel event');
      }

      if (shouldResetAnsweredFlag) {
        _callWasAnswered = false; // Reset only if call is truly cancelled/ended, not just UI closed
        print('🎯 Reset _callWasAnswered to false (call truly cancelled)');
      } else {
        print('🎯 Keeping _callWasAnswered = $_callWasAnswered (call still active or just UI event)');
      }

      _callDisconnectedController.add(null);

      // Show call summary dialog for incoming calls using preserved call info only if UI was closed
      if (shouldCloseUI) {
        print('🎯 Main cancel handler - using preserved callInfo: $callInfoForSummary');
        if (callInfoForSummary.isNotEmpty) {
          final context = _getCurrentContext();
          print('📞 Calling handleIncomingCallDisconnection from main cancel handler');
          handleIncomingCallDisconnection(context, callInfoForSummary);
        } else {
          print('⚠️ Preserved call info is empty, cannot show call summary');
        }
      } else {
        print('🎯 NOT showing call summary - call is still active, this was just a UI event');
      }
      // Listen for client registration events
      js.context['document'].addEventListener('twilioClientRegistered', js.allowInterop((event) {
        try {
          final detail = js_util.getProperty(event, 'detail');
          final identity = js_util.getProperty(detail, 'identity');
          print('Client registered event received for: $identity');
          _clientIdentity = identity.toString();
          _clientRegistrationController.add(_clientIdentity);
        } catch (e) {
          print('Error processing twilioClientRegistered event: $e');
        }
      }));

      // Set up BroadcastChannel listener for cross-window communication
      js.context.callMethod('eval', [
        '''
        try {
          console.log('Setting up BroadcastChannel listener for Twilio events...');
          window._twilioBroadcastChannel = new BroadcastChannel('twilio-calls');
          
          window._twilioBroadcastChannel.onmessage = function(event) {
            console.log('BroadcastChannel message received:', event.data);
            const data = event.data;
            
            if (data && data.type) {              switch (data.type) {
                case 'twilioCallDisconnected':
                  console.log('Broadcasting disconnect event to local document');
                  // Clear auto-reject timer
                  if (window._autoRejectTimer) {
                    console.log('Clearing auto-reject timer due to broadcast disconnect');
                    clearTimeout(window._autoRejectTimer);
                    window._autoRejectTimer = null;
                  }
                  const disconnectEvent = new CustomEvent('twilioCallDisconnected', { detail: data });
                  document.dispatchEvent(disconnectEvent);
                  break;
                case 'twilioCallAccepted':
                  console.log('Broadcasting accept event to local document');
                  // Clear auto-reject timer
                  if (window._autoRejectTimer) {
                    console.log('Clearing auto-reject timer due to broadcast accept');
                    clearTimeout(window._autoRejectTimer);
                    window._autoRejectTimer = null;
                  }
                  const acceptEvent = new CustomEvent('twilioCallAccepted', { detail: data });
                  document.dispatchEvent(acceptEvent);
                  break;                case 'twilioCallRejected':
                  console.log('Broadcasting reject event to local document');
                  // Clear auto-reject timer
                  if (window._autoRejectTimer) {
                    console.log('Clearing auto-reject timer due to broadcast reject');
                    clearTimeout(window._autoRejectTimer);
                    window._autoRejectTimer = null;
                  }
                  const rejectEvent = new CustomEvent('twilioCallRejected', { detail: data });
                  document.dispatchEvent(rejectEvent);
                  break;
                case 'twilioCallCancelled':
                  console.log('Broadcasting cancel event to local document');
                  // Clear auto-reject timer
                  if (window._autoRejectTimer) {
                    console.log('Clearing auto-reject timer due to broadcast cancel');
                    clearTimeout(window._autoRejectTimer);
                    window._autoRejectTimer = null;
                  }
                  const cancelEvent = new CustomEvent('twilioCallCancelled', { detail: data });
                  document.dispatchEvent(cancelEvent);
                  break;
                default:
                  console.log('Unknown BroadcastChannel message type:', data.type);
              }
            }
          };
          
          console.log('BroadcastChannel listener setup complete');
        } catch (e) {
          console.error('Error setting up BroadcastChannel listener:', e);
        }
      '''
      ]); // Set up cross-window postMessage listener
      js.context['addEventListener'] = js.allowInterop((String type, Function callback) {
        // This is just for compatibility - we use html.window.addEventListener directly
      });

      html.window.addEventListener('message', (event) {
        try {
          final data = (event as html.MessageEvent).data;
          if (data != null) {
            final type = data['type'];
            if (type != null) {
              print('Cross-window message received: $type');
              switch (type.toString()) {
                case 'twilioCallDisconnected':
                  print('Cross-window disconnect event received');
                  // Clear auto-reject timer
                  js.context.callMethod('eval', [
                    '''
                  if (window._autoRejectTimer) {
                      console.log('Clearing auto-reject timer due to cross-window disconnect');
                      clearTimeout(window._autoRejectTimer);
                      window._autoRejectTimer = null;
                    }
                  '''
                  ]);
                  _hasActiveCall = false;
                  _showingCallDialog = false;
                  // Close the draggable dialog overlay when caller disconnects (cross-window)
                  if (_draggableCallOverlayEntry != null) {
                    print('Closing draggable dialog due to cross-window call disconnection');
                    _draggableCallOverlayEntry!.remove();
                    _draggableCallOverlayEntry = null;
                  }

                  _callDisconnectedController.add(null);

                  // Show call summary dialog for incoming calls
                  print('🎯 Cross-window disconnect handler - _currentCallInfo: $_currentCallInfo');
                  if (_currentCallInfo.isNotEmpty) {
                    final context = _getCurrentContext();
                    print(
                        '📞 Calling handleIncomingCallDisconnection from cross-window disconnect handler');
                    handleIncomingCallDisconnection(context, _currentCallInfo);
                  } else {
                    print(
                        '⚠️ _currentCallInfo is empty in cross-window handler, cannot show call summary');
                  }
                  break;                case 'twilioCallAccepted':
                print('Cross-window accept event received');
                // Clear auto-reject timer
                js.context.callMethod('eval', [
                  '''
                    if (window._autoRejectTimer) {
                      console.log('Clearing auto-reject timer due to cross-window accept');
                      clearTimeout(window._autoRejectTimer);
                      window._autoRejectTimer = null;
                    }
                  '''
                ]);
                _hasActiveCall = true;
                _callWasAnswered = true; // Mark that this call was answered
                _showingCallDialog = false;
                _callAcceptedController.add(null);
                break;                case 'twilioCallRejected':
                print('Cross-window reject event received');
                // Clear auto-reject timer
                js.context.callMethod('eval', [
                  '''
                    if (window._autoRejectTimer) {
                      console.log('Clearing auto-reject timer due to cross-window reject');
                      clearTimeout(window._autoRejectTimer);
                      window._autoRejectTimer = null;
                    }
                  '''
                ]);
                _hasActiveCall = false;
                _callWasAnswered = false; // Reset since call was rejected, not answered
                _showingCallDialog = false;
                _callRejectedController.add(null);
                break;                case 'twilioCallCancelled':
                print('Cross-window cancel event received');
                // Clear auto-reject timer
                js.context.callMethod('eval', [
                  '''
                    if (window._autoRejectTimer) {
                      console.log('Clearing auto-reject timer due to cross-window cancel');
                      clearTimeout(window._autoRejectTimer);
                      window._autoRejectTimer = null;
                    }
                  '''
                ]);

                // Check if there's still an active call in Twilio before resetting _callWasAnswered
                bool shouldResetAnsweredFlag = true;
                try {
                  final jsResult = js.context.callMethod('eval', [
                    '''
                      (function() {
                        // Check if there's an active Twilio call
                        if (window.device && window.device.activeConnection && 
                            window.device.activeConnection.status && 
                            window.device.activeConnection.status() === 'open') {
                          console.log('🔍 Active Twilio call detected during cross-window cancel event');
                          return 'active';
                        }
                        
                        if (window.activeCall && 
                            (window.activeCall.status === 'open' || window.activeCall.status === 'connecting')) {
                          console.log('🔍 Active call object detected during cross-window cancel event');
                          return 'active';
                        }
                        
                        console.log('🔍 No active call detected during cross-window cancel event');
                        return 'inactive';
                      })();
                      '''
                  ]);

                  String callStatus = jsResult?.toString() ?? 'inactive';
                  print('🔍 Call status during cross-window cancel event: $callStatus');

                  if (callStatus == 'active' && _callWasAnswered) {
                    print('🎯 Call is still active and was answered - keeping _callWasAnswered = true (cross-window)');
                    shouldResetAnsweredFlag = false;
                  }
                } catch (e) {
                  print('Error checking call status in cross-window handler: $e');
                }

                _hasActiveCall = false;
                if (shouldResetAnsweredFlag) {
                  _callWasAnswered = false; // Reset only if call is truly cancelled/ended, not just UI closed
                  print('🎯 Reset _callWasAnswered to false (call truly cancelled - cross-window)');
                } else {
                  print('🎯 Keeping _callWasAnswered = true (UI closed but call still active - cross-window)');
                }
                _showingCallDialog = false;
                // Close the draggable dialog overlay when call is cancelled (cross-window)
                if (_draggableCallOverlayEntry != null) {
                  print('Closing draggable dialog due to cross-window call cancellation');
                  _draggableCallOverlayEntry!.remove();
                  _draggableCallOverlayEntry = null;
                }

                _callDisconnectedController.add(null);

                // Show call summary dialog for incoming calls
                print('🎯 Cross-window cancel handler - _currentCallInfo: $_currentCallInfo');
                if (_currentCallInfo.isNotEmpty) {
                  final context = _getCurrentContext();
                  print(
                      '📞 Calling handleIncomingCallDisconnection from cross-window cancel handler');
                  handleIncomingCallDisconnection(context, _currentCallInfo);
                } else {
                  print(
                      '⚠️ _currentCallInfo is empty in cross-window cancel handler, cannot show call summary');
                }
                break;
              }
            }
          }
        } catch (e) {
          print('Error processing cross-window message: $e');
        }
      });

      // Enhance cancel event handling with cross-window messaging
      print('Setting up cross-window messaging enhancement for cancel events...');
      js.context.callMethod('eval', [
        '''
        try {
          console.log('🔧 Enhancing twilioCallCancelled events with cross-window messaging...');
          
          // Listen for our own cancel events and add cross-window messaging
          document.addEventListener('twilioCallCancelled', function(event) {
            console.log('🔄 twilioCallCancelled event detected, adding cross-window messaging...');
            
            // Cross-window messaging for cancelled calls (similar to disconnect handling)
            let messageSent = false;
            
            // Approach 1: If this is a popup window, send message to parent
            if (window.opener && !window.opener.closed) {
              console.log('🔄 Sending cancel message to parent window (via window.opener)...');
              try {
                window.opener.postMessage({
                  type: 'twilioCallCancelled',
                  timestamp: new Date().toISOString(),
                  source: 'popup-cancel'
                }, '*');
                console.log('✅ Cancel message sent to parent window successfully');
                messageSent = true;
              } catch (e) {
                console.error('❌ Error sending cancel message to parent window:', e);
              }
            }
            
            // Approach 2: Also try to send to parent if we're in an iframe context
            if (window.parent && window.parent !== window) {
              console.log('🔄 Sending cancel message to parent window (via window.parent)...');
              try {
                window.parent.postMessage({
                  type: 'twilioCallCancelled',
                  timestamp: new Date().toISOString(),
                  source: 'iframe-cancel'
                }, '*');
                console.log('✅ Cancel message sent to parent via iframe successfully');
                messageSent = true;
              } catch (e) {
                console.error('❌ Error sending cancel message to parent via iframe:', e);
              }
            }
            
            // Approach 3: Broadcast to all windows
            try {
              console.log('🔄 Broadcasting cancel message...');
              const broadcastChannel = new BroadcastChannel('twilio-calls');
              const message = {
                type: 'twilioCallCancelled',
                timestamp: new Date().toISOString(),
                source: 'broadcast-cancel',
                debug: {
                  windowName: window.name,
                  location: window.location.href
                }
              };
              broadcastChannel.postMessage(message);
              console.log('✅ Cancel message broadcasted:', message);
              broadcastChannel.close();
              messageSent = true;
            } catch (e) {
              console.error('❌ Error broadcasting cancel message:', e);
            }
            
            if (!messageSent) {
              console.log('ℹ️ No cross-window messaging available for cancel event');
            }
          });
          
          console.log('✅ Cross-window messaging enhancement for cancel events completed');
          
        } catch (e) {
          console.error('❌ Error setting up cancel event cross-window enhancement:', e);
        }
      '''
      ]);
    } catch (e) {
      print('Error setting up Twilio event listeners: $e');
    }
  }

// Test method to verify event integration with twilio_helper.js
  void testEventIntegration() {
    try {
      print('Testing event integration with twilio_helper.js...');

      js.context.callMethod('eval', [
        '''
        console.log('=== TESTING TWILIO EVENT INTEGRATION ===');
        console.log('twilioHelper exists:', !!window.twilioHelper);
        console.log('DartTwilioHandler exists:', !!window.DartTwilioHandler);
        console.log('BroadcastChannel exists:', !!window._twilioBroadcastChannel);
        
        // Test event dispatch
        setTimeout(() => {
          console.log('Testing event dispatch...');
          const testEvent = new CustomEvent('twilioCallAccepted');
          document.dispatchEvent(testEvent);
        }, 1000);
      '''
      ]);

      print('Event integration test initiated.');
    } catch (e) {
      print('Error testing event integration: $e');
    }
  }

// Handle incoming call - show popup window
  void _handleIncomingCall(Map<String, dynamic> callInfo) async {
    print('Call info: $callInfo');
    print('Current _showingCallDialog state: $_showingCallDialog');

    // Reset call answered flag for new incoming call
    _callWasAnswered = false;

    if (_showingCallDialog) {
      print('Already showing a call dialog. Checking if overlay actually exists...');

      // Check if HTML overlay actually exists
      final overlayExists = js.context.callMethod('eval', [
        '''
        (function() {
          var overlay = document.getElementById('twilio-call-overlay');
          return overlay !== null;
        })();
      '''
      ]);

      print('HTML overlay exists: $overlayExists');

      if (overlayExists != true) {
        print(
            'No HTML overlay found but _showingCallDialog is true. Resetting state and showing new dialog.');
        _showingCallDialog = false;
      } else {
        print('HTML overlay exists. Ignoring additional incoming call.');
        return;
      }
    }

    _showingCallDialog = true;    try {
      print('Showing incoming call popup for: ${callInfo['from']}');

      // Store call info in session storage for popup to access
      _storeCallInfoInSession(callInfo);      // Process transfer information BEFORE showing the overlay
      // Clear previous values first
      transferredToRoles.clear();
      transferredFromRoles.clear();
      
      await _processTransferInformation();
      await _getUserRolesInformation();

      // Debug: Log the values after processing
      print('After processing - Transferred to roles: $transferredToRoles');
      print('After processing - Transferred from roles: $transferredFromRoles');
      print('After processing - Current user type: ${FFAppState().usertype}');

      // Show incoming call popup window
      _showIncomingCallOverlay(callInfo);

      // Start monitoring popup
      _startPopupMonitoring();
    } catch (e) {
      print('Error showing incoming call popup: $e');
      _showingCallDialog = false;
    }
  }

// Get the current BuildContext from the navigator
  BuildContext? _getCurrentContext() {
    try {
      // Try to get context from the current route
      final NavigatorState? navigatorState =
      WidgetsBinding.instance.rootElement?.findAncestorStateOfType<NavigatorState>();

      if (navigatorState != null && navigatorState.context.mounted) {
        return navigatorState.context;
      }

      // Alternative approach: get from a MaterialApp context
      BuildContext? foundContext;
      void visitor(Element element) {
        if (foundContext == null && element.widget is MaterialApp && element.mounted) {
          foundContext = element;
        }
        element.visitChildren(visitor);
      }

      WidgetsBinding.instance.rootElement?.visitChildren(visitor);
      return foundContext;
    } catch (e) {
      print('Error getting current context: $e');
      return null;
    }
  } // Show the TwilioIncomingCallDialog widget

  // Process transfer information from AppState
  Future<void> _processTransferInformation() async {
    final response = await GQLgetByFunctionCall.call(
      hasuraToken: FFAppState().hasuraToken,
      requestBody: functions
          .getTransferFeatureRoles()
          .toString(),
    );

    // Parse the response if it contains a 'jsonBody' or similar key
    final data = response?.jsonBody?['data']?['reference_origin_number_type'];

    if (data != null && data is List && data.isNotEmpty) {
      final item = data.first;

      // Extract strings
      final fromRole = item['transferred_from_role_type'] as String?;
      final toRolesRaw = item['transferred_to_role_type'] as String?;

      if (fromRole != null) {
        transferredFromRoles.addAll(fromRole.split(',').map((e) => e.trim()));
      }

      if (toRolesRaw != null) {
        transferredToRoles.addAll(toRolesRaw.split(',').map((e) => e.trim()));
      }
    } else {
      print('No transfer role data found.');
    }
  }

  Future<void> _getUserRolesInformation() async {
    final response = await GQLgetByFunctionCall.call(
      hasuraToken: FFAppState().hasuraToken,
      requestBody: functions
          .getUserInfoOfSpecificRoles("P")
          .toString(),
    );

    // Parse the response if it contains a 'jsonBody' or similar key
    final data = response?.jsonBody?['data']?['api_hboxuser'];

    if (data != null && data is List) {
      userRolesInfo.clear();
      for (var user in data) {
        // Create a UserInfo object for each user in the response
        userRolesInfo.add(UserInfo(
          firstName: user['first_name'] ?? '',
          lastName: user['last_name'] ?? '',
          type: user['type'] ?? '',
          email: user['email'] ?? '',
        ));
      }
      print('User roles information loaded: ${userRolesInfo.length} users');
    } else {
      print('No user roles data found or invalid format.');
    }
  }

  void _showTwilioIncomingCallDialog(BuildContext context, Map<String, dynamic> callInfo) {
    // Use the helper from the dialog to ensure proper integration
    TwilioIncomingCallDialogHelper.showIncomingCallDialog(
      context: context,
      callInfo: callInfo,
      backgroundService: this,
    );
  }

// Show active call dialog after accepting
  void _showActiveCallDialog(BuildContext context, Map<String, dynamic> callInfo) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.green.withOpacity(0.1),
                  child: Icon(
                    Icons.call,
                    size: 50,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  callInfo['from']?.toString() ?? 'Unknown Caller',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Call Active',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Mute button
                    GestureDetector(
                      onTap: () {
                        toggleMute();
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: _isMuted ? Colors.orange : Colors.grey,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (_isMuted ? Colors.orange : Colors.grey).withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              _isMuted ? Icons.mic_off : Icons.mic,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            _isMuted ? 'Unmute' : 'Mute',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[800],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Hangup button
                    GestureDetector(
                      onTap: () {
                        Navigator.of(dialogContext).pop();
                        hangupCall();
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.call_end,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Hang Up',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[800],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

// Shows a dialog without requiring a BuildContext
  void _showDialogWithoutContext(Map<String, dynamic> callInfo) {
    try {
      // Create our own overlay using the TwilioIncomingCallDialog widget
      OverlayEntry? entry;

      entry = OverlayEntry(
        builder: (context) {
          return Material(
            color: Colors.black54,
            child: Center(
              child: TwilioIncomingCallDialog(
                callerName: callInfo['from']?.toString() ?? 'Unknown Caller',
                callerNumber: callInfo['callerId']?.toString() ?? '',
                onAccept: () {
                  if (entry != null) {
                    entry!.remove();
                  }
                  acceptCall();
                  _showingCallDialog = false;
                  _showActiveCallOverlay(callInfo);
                },
                onReject: () {
                  if (entry != null) {
                    entry!.remove();
                  }
                  rejectCall();
                  _showingCallDialog = false;
                },
              ),
            ),
          );
        },
      );

      // Add to overlay
      _insertOverlayEntry(entry);
    } catch (e) {
      print('Error in _showDialogWithoutContext: $e');
      _showingCallDialog = false;
    }
  } // Shows incoming call UI as overlay

  void _showIncomingCallOverlay(Map<String, dynamic> callInfo) {
    try {
      print('Showing incoming call dialog');

      // Use HTML-based overlay that doesn't depend on Flutter's overlay system
      _showHTMLBasedCallDialog(callInfo);
    } catch (e) {
      print('Error in _showIncomingCallOverlay: $e');
      _showingCallDialog = false;
      rethrow; // Re-throw the error so the caller can handle it
    }
  }

// Create an HTML-based call dialog that works independently of Flutter overlay
  void _showHTMLBasedCallDialog(Map<String, dynamic> callInfo) {
    try {
      print('Showing HTML-based call dialog for incoming call');
      if (kIsWeb) {
        // final rawCallerName = callInfo['parameters']?.toString() ?? 'Unknown Caller';
        // final callerName = _cleanCallerName(rawCallerName);

        String callerName = 'Unknown Caller';
        String clinicName = '';
        String clinicId = '';
        String clinicTimeZone = '';
        final callerNumber = callInfo['callerId']?.toString() ?? '';

        final rawParams = callInfo['parameters']?.toString() ?? '';
        print('Raw parameters from call info: $rawParams');
        final cleanParams = rawParams.startsWith('"') && rawParams.endsWith('"')
            ? rawParams.substring(1, rawParams.length - 1)
            : rawParams;

        final paramPairs = cleanParams.split('&');
        for (final pair in paramPairs) {
            final keyValue = pair.split('=');
            if (keyValue.length == 2) {
              final key = keyValue[0];
              final value = keyValue[1];

              if (key == 'patientName') {
                callerName = _cleanCallerName(value);
              } else if (key == 'clinicName') {
                clinicName = _cleanClinicName(value);
              } else if (key == 'clinicId') {
                clinicId = _cleanClinicId(value);
              } else if (key == 'clinicTimeZone') {
                clinicTimeZone = _cleanClinicTimezone(value);
              }
            }
          }

          // If no patientName parameter was found, fall back to using the whole string as caller name (for backward compatibility)
          if (callerName == 'Unknown Caller' && !rawParams.contains('&')) {
            callerName = rawParams;
          }


        print('Parsed parameters - patientName: $callerName, clinicName: $clinicName, clinicId: $clinicId, clinicTimeZone: $clinicTimeZone');        // Check transfer conditions        print("Transferred to roles: $transferredToRoles");
        print("Transferred from roles: $transferredFromRoles");
        print("Current user type: ${FFAppState().usertype}");        final shouldShowTransferBtn = transferredToRoles.isNotEmpty && 
            transferredFromRoles.isNotEmpty && 
            transferredFromRoles.contains(FFAppState().usertype);
        js.context.callMethod('eval', [
          '''
          // Transfer button condition passed from Dart
          var shouldShowTransferBtn = ${shouldShowTransferBtn.toString()};
          
          // Transfer roles data passed from Dart
          var transferredToRoles = ${jsonEncode(transferredToRoles)};
          console.log('Transferred to roles from Dart:', transferredToRoles);
          
          // User roles information passed from Dart
          var userRolesInfo = ${jsonEncode(userRolesInfo.map((user) => {
            'firstName': user.firstName,
            'lastName': user.lastName,
            'type': user.type,
            'email': user.email,
            'fullName': user.fullName
          }).toList())};
          console.log('User roles info from Dart:', userRolesInfo);
          
          // Reset call handled flag for new call
          window._callHandled = false;
          console.log('Resetting call handled flag for new incoming call');
          
          (function() {
            // Remove any existing overlay first to prevent duplicates
            var existingOverlay = document.getElementById('twilio-call-overlay');
            if (existingOverlay) {
              console.log('Removing existing overlay and resetting Dart state');
              existingOverlay.parentNode.removeChild(existingOverlay);
              
              // Immediately reset Dart dialog state when removing existing overlay
              if (window.DartTwilioHandler && window.DartTwilioHandler.resetDialogState) {
                console.log('Resetting Dart dialog state after removing existing overlay');
                window.DartTwilioHandler.resetDialogState();
              }
            }
              // Create a draggable dialog that floats in the corner
            var overlay = document.createElement('div');
            overlay.id = 'twilio-call-overlay';
            overlay.style.cssText = 
              'position: fixed;' +
              'bottom: 20px;' +
              'right: 20px;' +
              'width: 320px;' +
              'z-index: 9999999;' +
              'font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;' +
              'box-shadow: 0 10px 25px rgba(0, 0, 0, 0.3);' +
              'border-radius: 16px;' +
              'overflow: hidden;' +
              'transition: all 0.3s ease;' +
              'touch-action: none;' +
              'user-select: none;' +
              'background: white;' +
              'border: 1px solid rgba(0, 0, 0, 0.1);';
              // Create header for dragging
            var header = document.createElement('div');
            header.id = 'twilio-call-header';
            header.style.cssText = 
              'background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);' +
              'color: white;' +
              'padding: 16px 20px;' +
              'font-weight: 600;' +
              'cursor: move;' +
              'display: flex;' +
              'justify-content: space-between;' +
              'align-items: center;' +
              'font-size: 16px;';header.innerHTML = '<span><svg width="16" height="16" viewBox="0 0 24 24" fill="none" style="display:inline; vertical-align:middle; margin-right:8px;"><path d="M6.62 10.79C8.06 13.62 10.38 15.94 13.21 17.38L15.41 15.18C15.69 14.9 16.08 14.82 16.43 14.93C17.55 15.3 18.75 15.5 20 15.5C20.55 15.5 21 15.95 21 16.5V20C21 20.55 20.55 21 20 21C10.61 21 3 13.39 3 4C3 3.45 3.45 3 4 3H7.5C8.05 3 8.5 3.45 8.5 4C8.5 5.25 8.7 6.45 9.07 7.57C9.18 7.92 9.1 8.31 8.82 8.59L6.62 10.79Z" fill="white"/></svg> Incoming Call</span><span id="twilio-call-close" style="cursor:pointer; font-size:18px; opacity:0.8; hover:opacity:1;"><svg width="18" height="18" viewBox="0 0 24 24" fill="none"><path d="M18 6L6 18M6 6l12 12" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg></span>';
            overlay.appendChild(header);
              // Create content area
            var content = document.createElement('div');
            content.id = 'twilio-call-content';
            content.style.cssText = 
              'padding: 24px 20px;' +
              'text-align: center;' +
              'background: white;';
              // Avatar
            var avatar = document.createElement('div');
            avatar.style.cssText = 
              'width: 80px;' +
              'height: 80px;' +
              'background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);' +
              'border-radius: 50%;' +
              'margin: 0 auto 16px;' +
              'display: flex;' +
              'align-items: center;' +
              'justify-content: center;' +
              'font-size: 36px;' +
              'box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);';avatar.innerHTML = '<svg width="36" height="36" viewBox="0 0 24 24" fill="none"><path d="M12 12C14.21 12 16 10.21 16 8C16 5.79 14.21 4 12 4C9.79 4 8 5.79 8 8C8 10.21 9.79 12 12 12ZM12 14C9.33 14 4 15.34 4 18V20H20V18C20 15.34 14.67 14 12 14Z" fill="white"/></svg>';
            content.appendChild(avatar);
              // Caller info
            var caller = document.createElement('h3');
            caller.style.cssText = 
              'margin: 0 0 8px 0;' +
              'font-size: 20px;' +
              'color: #2d3748;' +
              'font-weight: 600;';
            caller.textContent = "${callerName}";
            content.appendChild(caller);
            var clinicName = document.createElement('h4');
            clinicName.style.cssText = 
              'margin: 0 0 8px 0;' +
              'font-size: 16px;' +
              'color: #2d3748;' +
              'font-weight: 600;';
            clinicName.textContent = "${clinicName}";
            content.appendChild(clinicName);
              if ("${callerNumber}".trim()) {
              var number = document.createElement('p');
              number.style.cssText = 
                'margin: 0 0 24px 0;' +
                'font-size: 15px;' +
                'color: #718096;' +
                'font-weight: 400;';
              number.textContent = "${callerNumber}";
              content.appendChild(number);            } else {
              var spacer = document.createElement('div');
              spacer.style.cssText = 'height: 16px;';
              content.appendChild(spacer);
            }
              // Pulsing indicator
            var indicator = document.createElement('div');
            indicator.style.cssText = 
              'padding: 10px 16px;' +
              'background: rgba(72, 187, 120, 0.1);' +
              'color: #48bb78;' +
              'border-radius: 25px;' +
              'display: inline-block;' +
              'margin-bottom: 24px;' +
              'animation: twilioPulse 2s infinite;' +
              'font-size: 14px;' +
              'font-weight: 500;' +
              'border: 1px solid rgba(72, 187, 120, 0.2);';
            indicator.textContent = "Ringing...";
            
            // Add the animation
            var style = document.createElement('style');
            style.textContent = `
              @keyframes twilioPulse {
                0% { opacity: 0.7; transform: scale(1); }
                50% { opacity: 1; transform: scale(1.02); }
                100% { opacity: 0.7; transform: scale(1); }
              }
              
              .twilio-btn {
                transition: all 0.2s ease;
                transform: translateY(0);
              }
              
              .twilio-btn:hover {
                transform: translateY(-2px);
                box-shadow: 0 6px 20px rgba(0, 0, 0, 0.15);
              }
              
              .twilio-btn:active {
                transform: translateY(0);
              }
            `;
            document.head.appendChild(style);
            
            content.appendChild(indicator);
            
            // Buttons
            var buttons = document.createElement('div');
            buttons.style.cssText = `
              display: flex;
              gap: 12px;
              justify-content: center;
            `;
            
            // Accept button
            var acceptBtn = document.createElement('button');
            acceptBtn.id = 'twilio-accept-call';
            acceptBtn.className = 'twilio-btn';
            acceptBtn.style.cssText = `
              background: linear-gradient(135deg, #48bb78 0%, #38a169 100%);
              color: white;
              border: none;
              padding: 14px 24px;
              flex: 1;
              border-radius: 50px;
              cursor: pointer;
              font-weight: 600;
              display: flex;
              align-items: center;
              justify-content: center;
              gap: 8px;
              font-size: 15px;
              box-shadow: 0 4px 12px rgba(72, 187, 120, 0.3);
            `;
            acceptBtn.innerHTML = '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" style="margin-right:8px;"><path d="M6.62 10.79C8.06 13.62 10.38 15.94 13.21 17.38L15.41 15.18C15.69 14.9 16.08 14.82 16.43 14.93C17.55 15.3 18.75 15.5 20 15.5C20.55 15.5 21 15.95 21 16.5V20C21 20.55 20.55 21 20 21C10.61 21 3 13.39 3 4C3 3.45 3.45 3 4 3H7.5C8.05 3 8.5 3.45 8.5 4C8.5 5.25 8.7 6.45 9.07 7.57C9.18 7.92 9.1 8.31 8.82 8.59L6.62 10.79Z" fill="white"/></svg>Accept';
            
            // Reject button
            var rejectBtn = document.createElement('button');
            rejectBtn.id = 'twilio-reject-call';
            rejectBtn.className = 'twilio-btn';
            rejectBtn.style.cssText = `
              background: linear-gradient(135deg, #f56565 0%, #e53e3e 100%);
              color: white;
              border: none;
              padding: 14px 24px;
              flex: 1;
              border-radius: 50px;
              cursor: pointer;
              font-weight: 600;
              display: flex;
              align-items: center;
              justify-content: center;
              gap: 8px;
              font-size: 15px;
              box-shadow: 0 4px 12px rgba(245, 101, 101, 0.3);
            `;
            rejectBtn.innerHTML = '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" style="margin-right:8px;"><path d="M6.62 10.79C8.06 13.62 10.38 15.94 13.21 17.38L15.41 15.18C15.69 14.9 16.08 14.82 16.43 14.93C17.55 15.3 18.75 15.5 20 15.5C20.55 15.5 21 15.95 21 16.5V20C21 20.55 20.55 21 20 21C10.61 21 3 13.39 3 4C3 3.45 3.45 3 4 3H7.5C8.05 3 8.5 3.45 8.5 4C8.5 5.25 8.7 6.45 9.07 7.57C9.18 7.92 9.1 8.31 8.82 8.59L6.62 10.79Z" fill="white" transform="rotate(135 12 12)"/></svg>Decline';
            
            buttons.appendChild(acceptBtn);
            buttons.appendChild(rejectBtn);
            content.appendChild(buttons);
            
            overlay.appendChild(content);
            document.body.appendChild(overlay);            // Close function            
            function removeOverlay() {
              const overlayElement = document.getElementById('twilio-call-overlay');
              if (overlayElement && overlayElement.parentNode) {
                overlayElement.parentNode.removeChild(overlayElement);
              }
              
              // Reset the Dart dialog state
              if (window.DartTwilioHandler && window.DartTwilioHandler.resetDialogState) {
                console.log('Resetting Dart dialog state via removeOverlay');
                window.DartTwilioHandler.resetDialogState();
              }
              
              // IMPORTANT: Also trigger call disconnection processing for call summary
              if (window.DartTwilioHandler && window.DartTwilioHandler.handleIncomingCallDisconnection) {
                console.log('📞 Triggering handleIncomingCallDisconnection from removeOverlay');
                try {
                  // Get current call info from DartTwilioHandler
                  const currentCallInfo = window.DartTwilioHandler.getCallInfo ? window.DartTwilioHandler.getCallInfo() : '{}';
                  window.DartTwilioHandler.handleIncomingCallDisconnection(currentCallInfo);
                } catch (e) {
                  console.error('Error calling handleIncomingCallDisconnection from removeOverlay:', e);
                }
              }
            }
            
            // Make draggable
            var pos1 = 0, pos2 = 0, pos3 = 0, pos4 = 0;
            header.onmousedown = dragMouseDown;
            header.ontouchstart = dragTouchStart;
            
            function dragMouseDown(e) {
              e = e || window.event;
              e.preventDefault();
              pos3 = e.clientX;
              pos4 = e.clientY;
              document.onmouseup = closeDragElement;
              document.onmousemove = elementDrag;
            }
            
            function dragTouchStart(e) {
              e = e || window.event;
              e.preventDefault();
              var touch = e.touches[0];
              pos3 = touch.clientX;
              pos4 = touch.clientY;
              document.ontouchend = closeTouchDragElement;
              document.ontouchmove = elementTouchDrag;
            }
            
            function elementDrag(e) {
              e = e || window.event;
              e.preventDefault();
              pos1 = pos3 - e.clientX;
              pos2 = pos4 - e.clientY;
              pos3 = e.clientX;
              pos4 = e.clientY;
              overlay.style.top = (overlay.offsetTop - pos2) + "px";
              overlay.style.left = (overlay.offsetLeft - pos1) + "px";
              overlay.style.right = "auto";
              overlay.style.bottom = "auto";
            }
            
            function elementTouchDrag(e) {
              e = e || window.event;
              e.preventDefault();
              var touch = e.touches[0];
              pos1 = pos3 - touch.clientX;
              pos2 = pos4 - touch.clientY;
              pos3 = touch.clientX;
              pos4 = touch.clientY;
              overlay.style.top = (overlay.offsetTop - pos2) + "px";
              overlay.style.left = (overlay.offsetLeft - pos1) + "px";
              overlay.style.right = "auto";
              overlay.style.bottom = "auto";
            }
            
            function closeDragElement() {
              document.onmouseup = null;
              document.onmousemove = null;
            }
            
            function closeTouchDragElement() {
              document.ontouchend = null;
              document.ontouchmove = null;
            }            // Add button handlers
            document.getElementById('twilio-call-close').onclick = function() {
              // Mark call as handled
              window._callHandled = true;
              
              // Clear auto-reject timer immediately when close is clicked
              if (window._autoRejectTimer) {
                console.log('Clearing auto-reject timer due to close button');
                clearTimeout(window._autoRejectTimer);
                window._autoRejectTimer = null;
              }
              
              // Call the Twilio helper function which will dispatch the correct events
              if (window.twilioHelper && window.twilioHelper.rejectIncomingCall) {
                console.log('Rejecting call via twilioHelper from close button');
                window.twilioHelper.rejectIncomingCall();
              } else {
                console.warn('twilioHelper.rejectIncomingCall not available');
              }
              removeOverlay();
            };
            document.getElementById('twilio-accept-call').onclick = function() {
              // Mark call as handled
              window._callHandled = true;
              
              // Clear auto-reject timer immediately when accept is clicked
              if (window._autoRejectTimer) {
                console.log('Clearing auto-reject timer due to call acceptance via HTML');
                clearTimeout(window._autoRejectTimer);
                window._autoRejectTimer = null;
              }
              
              // Call the Twilio helper function which will dispatch the correct events
              if (window.twilioHelper && window.twilioHelper.acceptIncomingCall) {
                console.log('Accepting call via twilioHelper');
                window.twilioHelper.acceptIncomingCall();
                // Transform to active call mode
                transformToActiveCall();
              } else {
                console.warn('twilioHelper.acceptIncomingCall not available');
              }
            };            
            document.getElementById('twilio-reject-call').onclick = function() {
              // Mark call as handled
              window._callHandled = true;
              
              // Clear auto-reject timer immediately when reject is clicked
              if (window._autoRejectTimer) {
                console.log('Clearing auto-reject timer due to call rejection via HTML');
                clearTimeout(window._autoRejectTimer);
                window._autoRejectTimer = null;
              }
              
              // Call the Twilio helper function which will dispatch the correct events
              if (window.twilioHelper && window.twilioHelper.rejectIncomingCall) {
                console.log('Rejecting call via twilioHelper');
                window.twilioHelper.rejectIncomingCall();
              } else {
                console.warn('twilioHelper.rejectIncomingCall not available');
              }
              removeOverlay();
            };
              // Transform to active call interface
            function transformToActiveCall() {
              // Increase dialog width for active call with transfer button
              overlay.style.width = '380px';
              
              header.innerHTML = '<span style="color:white;"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" style="display:inline; vertical-align:middle; margin-right:8px;"><path d="M6.62 10.79C8.06 13.62 10.38 15.94 13.21 17.38L15.41 15.18C15.69 14.9 16.08 14.82 16.43 14.93C17.55 15.3 18.75 15.5 20 15.5C20.55 15.5 21 15.95 21 16.5V20C21 20.55 20.55 21 20 21C10.61 21 3 13.39 3 4C3 3.45 3.45 3 4 3H7.5C8.05 3 8.5 3.45 8.5 4C8.5 5.25 8.7 6.45 9.07 7.57C9.18 7.92 9.1 8.31 8.82 8.59L6.62 10.79Z" fill="white"/></svg>Active Call</span><span id="twilio-call-close" style="cursor:pointer; font-size:18px; opacity:0.8;"><svg width="18" height="18" viewBox="0 0 24 24" fill="none"><path d="M18 6L6 18M6 6l12 12" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg></span>';
              header.style.background = 'linear-gradient(135deg, #48bb78 0%, #38a169 100%)';
              
              // Update content for active call
              content.innerHTML = '';
              
              // Keep the avatar
              content.appendChild(avatar);
              content.appendChild(caller);
              content.appendChild(clinicName);
              
              if ("${callerNumber}".trim()) {
                content.appendChild(number);
              }
              
              // Add connected indicator
              var connectedIndicator = document.createElement('div');
              connectedIndicator.style.cssText = `
                padding: 10px 16px;
                background: rgba(72, 187, 120, 0.1);
                color: #38a169;
                border-radius: 25px;
                display: inline-block;
                margin-bottom: 16px;
                font-size: 14px;
                font-weight: 500;
                border: 1px solid rgba(72, 187, 120, 0.2);
              `;
              connectedIndicator.textContent = "Connected";
              content.appendChild(connectedIndicator);
              
              // Call timer
              var timer = document.createElement('div');
              timer.id = 'twilio-call-timer';
              timer.style.cssText = `
                font-size: 18px;
                color: #2d3748;
                margin-bottom: 24px;
                font-weight: 600;
                font-family: 'Courier New', monospace;
              `;
              timer.textContent = "00:00";
              content.appendChild(timer);
                // Active call buttons
              var activeButtons = document.createElement('div');
              activeButtons.style.cssText = `
                display: flex;
                gap: 8px;
                justify-content: center;
                flex-wrap: wrap;
              `;
              
              // Mute button
              var muteBtn = document.createElement('button');
              muteBtn.id = 'twilio-mute-call';
              muteBtn.className = 'twilio-btn';
              muteBtn.style.cssText = `
                background: linear-gradient(135deg, #a0aec0 0%, #718096 100%);
                color: white;
                border: none;
                padding: 12px 16px;
                flex: 1;
                min-width: 90px;
                border-radius: 50px;
                cursor: pointer;
                font-weight: 600;
                display: flex;
                align-items: center;
                justify-content: center;
                gap: 6px;
                font-size: 13px;
                box-shadow: 0 4px 12px rgba(160, 174, 192, 0.3);
              `;
              muteBtn.innerHTML = '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" style="margin-right:4px;"><path d="M12 14C13.66 14 15 12.66 15 11V5C15 3.34 13.66 2 12 2C10.34 2 9 3.34 9 5V11C9 12.66 10.34 14 12 14ZM19 11C19 14.53 16.39 17.44 13 17.93V21H11V17.93C7.61 17.44 5 14.53 5 11H7C7 13.76 9.24 16 12 16C14.76 16 17 13.76 17 11H19Z" fill="white"/></svg>Mute';
                
              // Transfer Call button with proper icon
              var transferBtn = document.createElement('button');
              transferBtn.id = 'twilio-transfer-call';
              transferBtn.className = 'twilio-btn';
              transferBtn.style.cssText = `
                background: linear-gradient(135deg, #4299e1 0%, #3182ce 100%);
                color: white;
                border: none;
                padding: 12px 16px;
                flex: 1;
                min-width: 90px;
                border-radius: 50px;
                cursor: pointer;
                font-weight: 600;
                display: flex;
                align-items: center;
                justify-content: center;
                gap: 6px;
                font-size: 13px;
                box-shadow: 0 4px 12px rgba(66, 153, 225, 0.3);
              `;
              transferBtn.innerHTML = '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" style="margin-right:4px;" xmlns="http://www.w3.org/2000/svg"> <!-- Phone icon --> <path d="M6.62 10.79a15.05 15.05 0 006.59 6.59l2.2-2.2a1 1 0 011.11-.21c1.2.49 2.53.76 3.88.76a1 1 0 011 1v3.5a1 1 0 01-1 1C12.01 21.5 2.5 12 2.5 3a1 1 0 011-1H7a1 1 0 011 1c0 1.35.27 2.68.76 3.88a1 1 0 01-.21 1.11l-2.2 2.2z" fill="white"/> <!-- Transfer arrow --> <path d="M13 7h6m0 0l-2.5-2.5M19 7l-2.5 2.5" stroke="white" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/> </svg>Transfer';

              // Hangup button
              var hangupBtn = document.createElement('button');
              hangupBtn.id = 'twilio-hangup-call';
              hangupBtn.className = 'twilio-btn';
              hangupBtn.style.cssText = `
                background: linear-gradient(135deg, #f56565 0%, #e53e3e 100%);
                color: white;
                border: none;
                padding: 12px 16px;
                flex: 1;
                min-width: 90px;
                border-radius: 50px;
                cursor: pointer;
                font-weight: 600;
                display: flex;
                align-items: center;
                justify-content: center;
                gap: 6px;
                font-size: 13px;
                box-shadow: 0 4px 12px rgba(245, 101, 101, 0.3);
              `;
              hangupBtn.innerHTML = '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" style="margin-right:4px;"><path d="M6.62 10.79C8.06 13.62 10.38 15.94 13.21 17.38L15.41 15.18C15.69 14.9 16.08 14.82 16.43 14.93C17.55 15.3 18.75 15.5 20 15.5C20.55 15.5 21 15.95 21 16.5V20C21 20.55 20.55 21 20 21C10.61 21 3 13.39 3 4C3 3.45 3.45 3 4 3H7.5C8.05 3 8.5 3.45 8.5 4C8.5 5.25 8.7 6.45 9.07 7.57C9.18 7.92 9.1 8.31 8.82 8.59L6.62 10.79Z" fill="white" transform="rotate(135 12 12)"/></svg>End Call';              
              activeButtons.appendChild(muteBtn);
              if (shouldShowTransferBtn) {
                activeButtons.appendChild(transferBtn);
              }
              activeButtons.appendChild(hangupBtn);
              content.appendChild(activeButtons);
              
              // Set up timer
              var startTime = new Date();
              var timerInterval = setInterval(function() {
                var now = new Date();
                var diff = Math.floor((now - startTime) / 1000);
                var minutes = Math.floor(diff / 60);
                var seconds = diff % 60;
                var timerElement = document.getElementById('twilio-call-timer');
                if (timerElement) {
                  timerElement.textContent = 
                    (minutes < 10 ? '0' : '') + minutes + ':' + 
                    (seconds < 10 ? '0' : '') + seconds;
                } else {
                  clearInterval(timerInterval);
                }
              }, 1000);              // Update button handlers
              document.getElementById('twilio-call-close').onclick = function() {
                clearInterval(timerInterval);
                
                // Clear auto-reject timer (just in case it's still running)
                if (window._autoRejectTimer) {
                  console.log('Clearing auto-reject timer due to active call close button');
                  clearTimeout(window._autoRejectTimer);
                  window._autoRejectTimer = null;
                }
                  // Call the Twilio helper function which will dispatch the correct events
                if (window.twilioHelper && window.twilioHelper.hangupCall) {
                  console.log('Hanging up call via twilioHelper from close button');
                  window.twilioHelper.hangupCall();
                } else {
                  console.warn('twilioHelper.hangupCall not available');
                  // Fallback: call Dart method directly for call summary
                  if (window.DartTwilioHandler && window.DartTwilioHandler.callHangupMethod) {
                    console.log('Calling Dart hangup method as fallback');
                    window.DartTwilioHandler.callHangupMethod();
                  }
                }
                
                removeOverlay();
              };
              
              document.getElementById('twilio-mute-call').onclick = function() {
                var isMuted = this.innerHTML.includes('Unmute');
                // Call the Twilio helper function which will dispatch the correct events
                if (window.twilioHelper && window.twilioHelper.toggleMute) {
                  console.log('Toggling mute via twilioHelper');
                  var muteResult = window.twilioHelper.toggleMute();
                  console.log('Mute toggle result:', muteResult);                  // Update button based on mute result if available
                  if (typeof muteResult === 'boolean') {
                    if (muteResult) {
                      this.innerHTML = '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" style="margin-right:4px;"><path d="M12 2C13.66 2 15 3.34 15 5V11C15 12.66 13.66 14 12 14C10.34 14 9 12.66 9 11V5C9 3.34 10.34 2 12 2Z" fill="white"/><path d="M19 11C19 14.53 16.39 17.44 13 17.93V21H11V17.93C7.61 17.44 5 14.53 5 11H7C7 13.76 9.24 16 12 16C14.76 16 17 13.76 17 11H19Z" fill="white"/><line x1="4" y1="4" x2="20" y2="20" stroke="white" stroke-width="2" stroke-linecap="round"/></svg>Unmute';
                      this.style.background = 'linear-gradient(135deg, #ed8936 0%, #dd6b20 100%)';
                      this.style.boxShadow = '0 4px 12px rgba(237, 137, 54, 0.3)';
                    } else {
                      this.innerHTML = '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" style="margin-right:4px;"><path d="M12 14C13.66 14 15 12.66 15 11V5C15 3.34 13.66 2 12 2C10.34 2 9 3.34 9 5V11C9 12.66 10.34 14 12 14ZM19 11C19 14.53 16.39 17.44 13 17.93V21H11V17.93C7.61 17.44 5 14.53 5 11H7C7 13.76 9.24 16 12 16C14.76 16 17 13.76 17 11H19Z" fill="white"/></svg>Mute';
                      this.style.background = 'linear-gradient(135deg, #a0aec0 0%, #718096 100%)';
                      this.style.boxShadow = '0 4px 12px rgba(160, 174, 192, 0.3)';
                    }
                  } else {
                    // Fallback: toggle based on current state
                    if (!isMuted) {
                      this.innerHTML = '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" style="margin-right:4px;"><path d="M12 2C13.66 2 15 3.34 15 5V11C15 12.66 13.66 14 12 14C10.34 14 9 12.66 9 11V5C9 3.34 10.34 2 12 2Z" fill="white"/><path d="M19 11C19 14.53 16.39 17.44 13 17.93V21H11V17.93C7.61 17.44 5 14.53 5 11H7C7 13.76 9.24 16 12 16C14.76 16 17 13.76 17 11H19Z" fill="white"/><line x1="4" y1="4" x2="20" y2="20" stroke="white" stroke-width="2" stroke-linecap="round"/></svg>Unmute';
                      this.style.background = 'linear-gradient(135deg, #ed8936 0%, #dd6b20 100%)';
                      this.style.boxShadow = '0 4px 12px rgba(237, 137, 54, 0.3)';
                    } else {
                      this.innerHTML = '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" style="margin-right:4px;"><path d="M12 14C13.66 14 15 12.66 15 11V5C15 3.34 13.66 2 12 2C10.34 2 9 3.34 9 5V11C9 12.66 10.34 14 12 14ZM19 11C19 14.53 16.39 17.44 13 17.93V21H11V17.93C7.61 17.44 5 14.53 5 11H7C7 13.76 9.24 16 12 16C14.76 16 17 13.76 17 11H19Z" fill="white"/></svg>Mute';
                      this.style.background = 'linear-gradient(135deg, #a0aec0 0%, #718096 100%)';
                      this.style.boxShadow = '0 4px 12px rgba(160, 174, 192, 0.3)';                    }
                  }
                } else {
                  console.warn('twilioHelper.toggleMute not available');
                }
              };
              
              // Transfer function definition - COMMENTED OUT              // Updated handleCallTransfer function to accept email parameter
              function handleCallTransfer(transferEmail) {
                console.log('Transfer call button clicked with email:', transferEmail);
                
                // Get current call info from window._currentCall
                var callSid = null;
                
                if (window._currentCall && window._currentCall.parameters && window._currentCall.parameters.CallSid) {
                  callSid = window._currentCall.parameters.CallSid;
                  console.log('Found CallSid from _currentCall.parameters:', callSid);
                } else if (window._currentCall && window._currentCall.customParameters && window._currentCall.customParameters.CallSid) {
                  callSid = window._currentCall.customParameters.CallSid;
                  console.log('Found CallSid from _currentCall.customParameters:', callSid);
                } else if (window._currentCall && typeof window._currentCall.sid === 'string') {
                  callSid = window._currentCall.sid;
                  console.log('Found CallSid from _currentCall.sid:', callSid);
                } else if (window._currentCall && window._currentCall.outgoingConnectionId) {
                  callSid = window._currentCall.outgoingConnectionId;
                  console.log('Found CallSid from _currentCall.outgoingConnectionId:', callSid);
                }
                
                if (callSid) {
                  console.log('Transferring call with CallSid:', callSid);
                  console.log('Transfer email:', transferEmail);
                  
                  // Make direct API call to transfer endpoint
                  var transferUrl = "https://sandbox.hbox.ai/twilio";
                  
                  // Get auth token from app state (should be available globally)
                  var authToken = '';
                  try {
                    // Try to get auth token from various sources
                    if (window.FFAppState && window.FFAppState.loginToken) {
                      authToken = window.FFAppState.loginToken;
                    } else if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
                      // Fallback: try to get from Flutter bridge
                      console.log('Attempting to get auth token from Flutter bridge');
                    }
                  } catch (e) {
                    console.log('Error getting auth token:', e);
                  }
                  console.log('Making transfer API call to:', transferUrl + '/transfer');
                  console.log('CallSid:', callSid);
                  console.log('Auth token available:', !!authToken);
                  
                  // Prepare the request body matching the API structure with dynamic email
                  var requestBody = {
                    transferTo: transferEmail,
                    transferCallSid: callSid,
                    callerId: "5",
                    isPepPatient: true,
                    key: "INCOMING"
                  };                  
                  console.log('Request body:', JSON.stringify(requestBody, null, 2));
                  
                  // Make the API call
                  fetch(transferUrl + '/transfer', {
                    method: 'POST',
                    headers: {
                      'Content-Type': 'application/json',
                      'Authorization': 'Bearer ' + authToken,
                      'ngrok-skip-browser-warning': 'true'
                    },
                    body: JSON.stringify(requestBody)
                  }).then(response => {
                    console.log('Transfer API response status:', response.status);
                    console.log('Transfer API response headers:', response.headers);
                    
                    // Check if response is JSON
                    const contentType = response.headers.get('content-type');
                    if (contentType && contentType.includes('application/json')) {
                      return response.json().then(data => ({ status: response.status, data: data }));
                    } else {
                      // Handle non-JSON response (HTML, plain text, etc.)
                      return response.text().then(text => {
                        console.log('Non-JSON response received:', text);
                        return { 
                          status: response.status, 
                          data: { 
                            success: response.status >= 200 && response.status < 300,
                            message: text,
                            error: response.status >= 400 ? text : null
                          } 
                        };
                      });
                    }
                  })
                  .then(result => {
                    console.log('Transfer API response:', result);
                    
                    // Check for success more comprehensively
                    var isSuccess = false;
                    var successMessage = '';
                    var errorMessage = '';
                    
                    if (result.status >= 200 && result.status < 300) {
                      // HTTP status is successful
                      if (result.data) {
                        if (result.data.success === true) {
                          // Explicit success flag
                          isSuccess = true;
                          successMessage = result.data.message || 'Call transfer initiated successfully';
                        } else if (result.data.success === false) {
                          // Explicit failure flag
                          errorMessage = result.data.message || result.data.error || 'API returned failure';
                        } else if (typeof result.data === 'string') {
                          // String response - check if it looks like success
                          if (result.data.toLowerCase().includes('success') || 
                              result.data.toLowerCase().includes('transfer') ||
                              result.data.toLowerCase().includes('initiated')) {
                            isSuccess = true;
                            successMessage = result.data;
                          } else {
                            errorMessage = result.data;
                          }
                        } else {
                          // Assume success for 2xx status codes with any data
                          isSuccess = true;
                          successMessage = 'Call transfer request completed successfully';
                        }
                      } else {
                        // No data but successful status code
                        isSuccess = true;
                        successMessage = 'Call transfer request completed successfully';
                      }
                    } else {
                      // HTTP status indicates error
                      errorMessage = result.data ? 
                        (result.data.message || result.data.error || result.data) : 
                        'HTTP ' + result.status + ' error';
                    }
                    
                    if (isSuccess) {
                      console.log('Call transfer initiated successfully');
                    } else {
                      console.error('Call transfer failed:', errorMessage);
                    }
                  }).catch(error => {
                    console.error('Error during call transfer API call:', error);
                    
                    // Provide more detailed error information
                    var errorMessage = 'Unknown error occurred';
                    if (error.message) {
                      errorMessage = error.message;
                    } else if (typeof error === 'string') {
                      errorMessage = error;
                    }
                    
                    console.log('Full error object:', error);
                  });                } else {
                  console.error('No CallSid found in current call object');
                  console.log('Current call object:', window._currentCall);
                }
              }
              
              // New function to show transfer options with radio buttons
              function showTransferOptions(buttonElement) {
                console.log('Transfer call button clicked - showing options');
                  // Initialize/clear selected user
                window._selectedTransferUser = null;
                window._selectedTransferEmail = null;
                
                // Check if transfer options are already visible
                var existingOptions = document.getElementById('twilio-transfer-options');
                if (existingOptions) {
                  // Hide existing options
                  existingOptions.style.display = 'none';
                  existingOptions.parentNode.removeChild(existingOptions);
                  
                  // Reset overlay height
                  var overlay = document.getElementById('twilio-call-overlay');
                  if (overlay) {
                    overlay.style.height = 'auto';
                  }
                    // Clear selected user
                  window._selectedTransferUser = null;
                  window._selectedTransferEmail = null;
                  
                  // Reset button text
                  buttonElement.innerHTML = '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" style="margin-right:4px;" xmlns="http://www.w3.org/2000/svg"> <!-- Phone icon --> <path d="M6.62 10.79a15.05 15.05 0 006.59 6.59l2.2-2.2a1 1 0 011.11-.21c1.2.49 2.53.76 3.88.76a1 1 0 011 1v3.5a1 1 0 01-1 1C12.01 21.5 2.5 12 2.5 3a1 1 0 011-1H7a1 1 0 011 1c0 1.35.27 2.68.76 3.88a1 1 0 01-.21 1.11l-2.2 2.2z" fill="white"/> <!-- Transfer arrow --> <path d="M13 7h6m0 0l-2.5-2.5M19 7l-2.5 2.5" stroke="white" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/> </svg>Transfer';
                  return;
                }
                
                // Get the content area to add options to
                var content = document.getElementById('twilio-call-content');
                if (!content) {
                  console.error('Could not find call content area');
                  return;
                }
                
                // Create transfer options container
                var transferOptions = document.createElement('div');
                transferOptions.id = 'twilio-transfer-options';
                transferOptions.style.cssText = `
                  margin-top: 20px;
                  padding: 20px;
                  background: #f8f9fa;
                  border-radius: 12px;
                  border: 1px solid #e2e8f0;
                  animation: fadeIn 0.3s ease;
                `;
                
                // Add animation styles
                var style = document.createElement('style');
                style.textContent = `
                  @keyframes fadeIn {
                    from { opacity: 0; transform: translateY(-10px); }
                    to { opacity: 1; transform: translateY(0); }
                  }
                `;
                document.head.appendChild(style);
                
                // Title
                var title = document.createElement('h4');
                title.style.cssText = `
                  margin: 0 0 16px 0;
                  font-size: 16px;
                  color: #2d3748;
                  font-weight: 600;
                  text-align: center;
                `;
                title.textContent = 'Transfer to:';
                transferOptions.appendChild(title);                  // Radio button options - use data from Dart
                var options = [];
                
                // Check if transferredToRoles has data, otherwise use default options
                if (transferredToRoles && transferredToRoles.length > 0) {
                  // Use the actual role data from Dart
                  options = transferredToRoles.map(function(role) {
                    return {
                      value: role,
                      label: role.charAt(0).toUpperCase() + role.slice(1).replace(/[_-]/g, ' ')
                    };
                  });
                } else {
                  // Fallback to default options if no role data available
                  options = [
                    { value: 'linda.e@hbox.ai', label: 'Linda E' },
                    { value: 'support@hbox.ai', label: 'Support Team' },
                    { value: 'manager@hbox.ai', label: 'Manager' }
                  ];
                }
                
                console.log('Transfer options generated:', options);
                  // Create horizontal container for radio buttons
                var radioContainer = document.createElement('div');
                radioContainer.style.cssText = `
                  display: flex;
                  gap: 8px;
                  justify-content: center;
                  flex-wrap: nowrap;
                  margin-bottom: 16px;
                  overflow-x: auto;
                  width: 100%;
                `;
                
                options.forEach(function(option, index) {
                  var optionContainer = document.createElement('div');
                  optionContainer.style.cssText = `
                    display: flex;
                    align-items: center;
                    padding: 6px 8px;
                    border-radius: 8px;
                    cursor: pointer;
                    transition: background-color 0.2s ease;
                    border: 2px solid transparent;
                    flex: 1;
                    justify-content: center;
                    white-space: nowrap;
                    min-width: fit-content;
                    max-width: 120px;
                  `;
                  
                  optionContainer.onmouseover = function() {
                    this.style.backgroundColor = '#e2e8f0';
                    this.style.borderColor = '#cbd5e0';
                  };
                  
                  optionContainer.onmouseout = function() {
                    var radio = this.querySelector('input[type="radio"]');
                    if (radio.checked) {
                      this.style.backgroundColor = '#ebf8ff';
                      this.style.borderColor = '#4299e1';
                    } else {
                      this.style.backgroundColor = 'transparent';
                      this.style.borderColor = 'transparent';
                    }
                  };
                    var radio = document.createElement('input');
                  radio.type = 'radio';
                  radio.name = 'transferOption';
                  radio.value = option.value;
                  radio.id = 'transfer-option-' + index;
                  radio.style.cssText = `
                    margin-right: 6px;
                    transform: scale(1.0);
                    accent-color: #4299e1;
                    flex-shrink: 0;
                  `;
                  
                  if (index === 0) {
                    radio.checked = true; // Default selection
                    optionContainer.style.backgroundColor = '#ebf8ff';
                    optionContainer.style.borderColor = '#4299e1';
                  }
                  
                  var label = document.createElement('label');
                  label.htmlFor = 'transfer-option-' + index;
                  label.style.cssText = `
                    font-size: 12px;
                    color: #4a5568;
                    cursor: pointer;
                    font-weight: 500;
                    white-space: nowrap;
                    overflow: hidden;
                    text-overflow: ellipsis;
                    flex: 1;
                  `;
                  label.textContent = option.label;
                    // Make the entire container clickable and update styles
                  optionContainer.onclick = function() {
                    // Uncheck all other radio buttons and reset their container styles
                    var allContainers = radioContainer.querySelectorAll('div');
                    allContainers.forEach(function(container) {
                      container.style.backgroundColor = 'transparent';
                      container.style.borderColor = 'transparent';
                    });
                    
                    // Check this radio button and update its container style
                    radio.checked = true;
                    this.style.backgroundColor = '#ebf8ff';
                    this.style.borderColor = '#4299e1';
                      // Clear any existing dropdown and selected user
                    var existingDropdown = document.getElementById('twilio-user-dropdown');
                    if (existingDropdown) {
                      existingDropdown.parentNode.removeChild(existingDropdown);                    }
                    window._selectedTransferUser = null;
                    window._selectedTransferEmail = null;
                    
                    // Reset confirm button
                    var confirmBtn = document.querySelector('#twilio-transfer-options button:first-of-type');
                    if (confirmBtn) {
                      confirmBtn.textContent = 'Confirm Transfer';
                      confirmBtn.style.background = 'linear-gradient(135deg, #4299e1 0%, #3182ce 100%)';
                    }
                    
                    // Show dropdown for selected role
                    showUserDropdown(option.value, transferOptions);
                  };
                  
                  optionContainer.appendChild(radio);
                  optionContainer.appendChild(label);
                  radioContainer.appendChild(optionContainer);
                });
                
                transferOptions.appendChild(radioContainer);
                
                // Action buttons
                var actionButtons = document.createElement('div');
                actionButtons.style.cssText = `
                  display: flex;
                  gap: 12px;
                  margin-top: 20px;
                `;
                
                // Confirm transfer button
                var confirmBtn = document.createElement('button');
                confirmBtn.className = 'twilio-btn';
                confirmBtn.style.cssText = `
                  background: linear-gradient(135deg, #48bb78 0%, #38a169 100%);
                  color: white;
                  border: none;
                  padding: 12px 20px;
                  flex: 1;
                  border-radius: 8px;
                  cursor: pointer;
                  font-weight: 600;
                  font-size: 14px;
                  transition: all 0.2s ease;
                `;
                confirmBtn.textContent = 'Confirm Transfer';
                  confirmBtn.onclick = function() {
                  var selectedOption = document.querySelector('input[name="transferOption"]:checked');
                  var selectedUser = window._selectedTransferUser;
                    if (selectedOption && selectedUser) {
                    console.log('Transferring to role:', selectedOption.value);
                    console.log('Transferring to user:', selectedUser);
                    console.log('Transfer email address:', selectedUser.email);
                    console.log('Transfer email from window:', window._selectedTransferEmail);
                    
                    // Extract email for transfer API
                    var transferEmail = selectedUser.email || window._selectedTransferEmail;
                    console.log('Final transfer email:', transferEmail);
                      if (!transferEmail) {
                      console.error('Error: No email address found for selected user');
                      return;
                    }
                      // Update button state
                    confirmBtn.innerHTML = 'Transferring...';
                    confirmBtn.disabled = true;
                    confirmBtn.style.background = 'linear-gradient(135deg, #a0aec0 0%, #718096 100%)';
                    
                    // Call the handleCallTransfer function with the selected email
                    handleCallTransfer(transferEmail);
                    
                    // Hide options after initiating transfer
                    setTimeout(function() {
                      var existingOptions = document.getElementById('twilio-transfer-options');
                      if (existingOptions) {
                        existingOptions.style.display = 'none';
                        existingOptions.parentNode.removeChild(existingOptions);
                      }
                      
                      // Reset overlay height
                      var overlay = document.getElementById('twilio-call-overlay');
                      if (overlay) {
                        overlay.style.height = 'auto';
                      }
                      
                      // Reset button text
                      buttonElement.innerHTML = '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" style="margin-right:4px;" xmlns="http://www.w3.org/2000/svg"> <!-- Phone icon --> <path d="M6.62 10.79a15.05 15.05 0 006.59 6.59l2.2-2.2a1 1 0 011.11-.21c1.2.49 2.53.76 3.88.76a1 1 0 011 1v3.5a1 1 0 01-1 1C12.01 21.5 2.5 12 2.5 3a1 1 0 011-1H7a1 1 0 011 1c0 1.35.27 2.68.76 3.88a1 1 0 01-.21 1.11l-2.2 2.2z" fill="white"/> <!-- Transfer arrow --> <path d="M13 7h6m0 0l-2.5-2.5M19 7l-2.5 2.5" stroke="white" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/> </svg>Transfer';
                        // Clear selected user
                      window._selectedTransferUser = null;
                      window._selectedTransferEmail = null;
                    }, 1500);} else if (selectedOption && !selectedUser) {
                    console.warn('Please select a user from the dropdown to transfer the call to.');
                  } else {
                    console.warn('Please select a transfer option first.');
                  }
                };
                
                // Cancel button
                var cancelBtn = document.createElement('button');
                cancelBtn.className = 'twilio-btn';
                cancelBtn.style.cssText = `
                  background: linear-gradient(135deg, #a0aec0 0%, #718096 100%);
                  color: white;
                  border: none;
                  padding: 12px 20px;
                  flex: 1;
                  border-radius: 8px;
                  cursor: pointer;
                  font-weight: 600;
                  font-size: 14px;
                  transition: all 0.2s ease;
                `;
                cancelBtn.textContent = 'Cancel';
                  cancelBtn.onclick = function() {
                  // Hide options
                  transferOptions.style.display = 'none';
                  transferOptions.parentNode.removeChild(transferOptions);
                  
                  // Reset overlay height
                  var overlay = document.getElementById('twilio-call-overlay');
                  if (overlay) {
                    overlay.style.height = 'auto';
                  }
                  
                  // Clear selected user
                  window._selectedTransferUser = null;
                  
                  // Reset button text
                  buttonElement.innerHTML = '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" style="margin-right:4px;" xmlns="http://www.w3.org/2000/svg"> <!-- Phone icon --> <path d="M6.62 10.79a15.05 15.05 0 006.59 6.59l2.2-2.2a1 1 0 011.11-.21c1.2.49 2.53.76 3.88.76a1 1 0 011 1v3.5a1 1 0 01-1 1C12.01 21.5 2.5 12 2.5 3a1 1 0 011-1H7a1 1 0 011 1c0 1.35.27 2.68.76 3.88a1 1 0 01-.21 1.11l-2.2 2.2z" fill="white"/> <!-- Transfer arrow --> <path d="M13 7h6m0 0l-2.5-2.5M19 7l-2.5 2.5" stroke="white" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/> </svg>Transfer';
                };
                
                actionButtons.appendChild(confirmBtn);
                actionButtons.appendChild(cancelBtn);
                transferOptions.appendChild(actionButtons);
                
                // Add to content
                content.appendChild(transferOptions);
                
                // Increase overlay height dynamically
                var overlay = document.getElementById('twilio-call-overlay');
                if (overlay) {
                  overlay.style.height = 'auto';
                  overlay.style.minHeight = '500px'; // Ensure enough space
                }
                  // Update button text to indicate options are shown
                buttonElement.innerHTML = '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" style="margin-right:4px;"><path d="M18 6L6 18M6 6l12 12" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>Close Options';
              }
              
              // Function to show user dropdown based on selected role
              function showUserDropdown(selectedRole, transferOptionsContainer) {
                console.log('Showing user dropdown for role:', selectedRole);
                
                // Remove existing dropdown if any
                var existingDropdown = document.getElementById('twilio-user-dropdown');
                if (existingDropdown) {
                  existingDropdown.parentNode.removeChild(existingDropdown);
                }
                  // Filter users by selected role
                var filteredUsers = [];
                if (userRolesInfo && userRolesInfo.length > 0) {
                  filteredUsers = userRolesInfo.filter(function(user) {
                    return user.type === selectedRole;
                  });
                } else {
                  console.warn('User roles info is not available or empty');
                }
                
                if (filteredUsers.length === 0) {
                  console.log('No users found for role:', selectedRole);
                  
                  // Show a message that no users are available
                  var noUsersContainer = document.createElement('div');
                  noUsersContainer.id = 'twilio-user-dropdown';
                  noUsersContainer.style.cssText = 
                    'margin-top: 16px;' +
                    'padding: 20px;' +
                    'border: 1px solid #e2e8f0;' +
                    'border-radius: 8px;' +
                    'background: white;' +
                    'text-align: center;' +
                    'color: #718096;' +
                    'font-size: 14px;';
                  
                  noUsersContainer.textContent = 'No users available for ' + selectedRole + ' role';
                  transferOptionsContainer.appendChild(noUsersContainer);
                  return;
                }
                
                // Create dropdown container
                var dropdownContainer = document.createElement('div');
                dropdownContainer.id = 'twilio-user-dropdown';
                dropdownContainer.style.cssText = 
                  'margin-top: 16px;' +
                  'border: 1px solid #e2e8f0;' +
                  'border-radius: 8px;' +
                  'background: white;' +
                  'box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);' +
                  'overflow: hidden;';
                
                // Create search input
                var searchContainer = document.createElement('div');
                searchContainer.style.cssText = 
                  'padding: 12px;' +
                  'border-bottom: 1px solid #e2e8f0;' +
                  'background: #f8f9fa;';
                
                var searchInput = document.createElement('input');
                searchInput.type = 'text';
                searchInput.placeholder = 'Search users...';
                searchInput.style.cssText = 
                  'width: 100%;' +
                  'padding: 8px 12px;' +
                  'border: 1px solid #e2e8f0;' +
                  'border-radius: 6px;' +
                  'font-size: 14px;' +
                  'outline: none;' +
                  'box-sizing: border-box;';
                
                searchInput.onfocus = function() {
                  this.style.borderColor = '#4299e1';
                  this.style.boxShadow = '0 0 0 2px rgba(66, 153, 225, 0.2)';
                };
                
                searchInput.onblur = function() {
                  this.style.borderColor = '#e2e8f0';
                  this.style.boxShadow = 'none';
                };
                
                searchContainer.appendChild(searchInput);
                dropdownContainer.appendChild(searchContainer);
                
                // Create users list container
                var usersList = document.createElement('div');
                usersList.id = 'twilio-users-list';
                usersList.style.cssText = 
                  'max-height: 200px;' +
                  'overflow-y: auto;';
                
                // Function to render users list
                function renderUsersList(users) {
                  usersList.innerHTML = '';
                  
                  if (users.length === 0) {
                    var noResults = document.createElement('div');
                    noResults.style.cssText = 
                      'padding: 16px;' +
                      'text-align: center;' +
                      'color: #718096;' +
                      'font-size: 14px;';
                    noResults.textContent = 'No users found';
                    usersList.appendChild(noResults);
                    return;
                  }
                  
                  users.forEach(function(user) {
                    var userItem = document.createElement('div');
                    userItem.style.cssText = 
                      'padding: 12px 16px;' +
                      'cursor: pointer;' +
                      'border-bottom: 1px solid #f1f5f9;' +
                      'transition: background-color 0.2s ease;';
                    
                    userItem.onmouseover = function() {
                      this.style.backgroundColor = '#f8f9fa';
                    };
                    
                    userItem.onmouseout = function() {
                      this.style.backgroundColor = 'white';                    };
                    
                    // Format: \${user.type}: \${user.fullName} (\${user.email})
                    var displayText = user.type + ': ' + user.fullName + ' (' + user.email + ')';
                    userItem.textContent = displayText;
                      userItem.onclick = function() {
                      console.log('Selected user for transfer:', user);
                      console.log('Selected user email:', user.email);
                      
                      // Store selected user data
                      window._selectedTransferUser = user;
                      
                      // Also store email separately for easy access
                      window._selectedTransferEmail = user.email;
                      
                      console.log('Stored transfer email:', window._selectedTransferEmail);
                      
                      // Update confirm button to show selected user
                      var confirmBtn = document.querySelector('#twilio-transfer-options button:first-of-type');
                      if (confirmBtn) {
                        confirmBtn.textContent = 'Transfer to ' + user.fullName;
                        confirmBtn.style.background = 'linear-gradient(135deg, #48bb78 0%, #38a169 100%)';
                      }
                      
                      // Highlight selected item
                      var allItems = usersList.querySelectorAll('div');
                      allItems.forEach(function(item) {
                        item.style.backgroundColor = 'white';
                        item.style.fontWeight = 'normal';
                      });
                      
                      this.style.backgroundColor = '#ebf8ff';
                      this.style.fontWeight = '600';
                    };
                    
                    usersList.appendChild(userItem);
                  });
                }
                
                // Initial render with all users
                renderUsersList(filteredUsers);
                
                // Search functionality
                searchInput.oninput = function() {
                  var searchQuery = this.value.toLowerCase();
                  var searchResults = filteredUsers.filter(function(user) {
                    var searchText = (user.type + ': ' + user.fullName + ' (' + user.email + ')').toLowerCase();
                    return searchText.includes(searchQuery);
                  });
                  renderUsersList(searchResults);
                };
                
                dropdownContainer.appendChild(usersList);
                
                // Add dropdown to transfer options container
                transferOptionsContainer.appendChild(dropdownContainer);                // Increase overlay height to accommodate dropdown
                var overlay = document.getElementById('twilio-call-overlay');
                if (overlay) {
                  overlay.style.height = 'auto';
                  overlay.style.maxHeight = '90vh';
                  overlay.style.overflowY = 'auto';
                }
              }
              
              // Helper function to get selected user's email
              function getSelectedUserEmail() {
                if (window._selectedTransferUser && window._selectedTransferUser.email) {
                  console.log('Getting email from selectedTransferUser:', window._selectedTransferUser.email);
                  return window._selectedTransferUser.email;
                } else if (window._selectedTransferEmail) {
                  console.log('Getting email from selectedTransferEmail:', window._selectedTransferEmail);
                  return window._selectedTransferEmail;
                } else {
                  console.warn('No selected user email found');
                  return null;
                }
              }
              
              // Helper function to get complete selected user data
              function getSelectedUserData() {
                if (window._selectedTransferUser) {
                  console.log('Selected user data:', window._selectedTransferUser);
                  return {
                    fullName: window._selectedTransferUser.fullName,
                    email: window._selectedTransferUser.email,
                    type: window._selectedTransferUser.type,
                    firstName: window._selectedTransferUser.firstName,
                    lastName: window._selectedTransferUser.lastName
                  };
                } else {
                  console.warn('No selected user data found');
                  return null;
                }
              }
              
              // Set up event handlers for active call buttons
              if (shouldShowTransferBtn) {
                document.getElementById('twilio-transfer-call').onclick = function() {
                  showTransferOptions(this);
                };
              }
                
              document.getElementById('twilio-hangup-call').onclick = function() {
                clearInterval(timerInterval);// Call the Twilio helper function which will dispatch the correct events
                if (window.twilioHelper && window.twilioHelper.hangupCall) {
                  console.log('Hanging up call via twilioHelper');
                  window.twilioHelper.hangupCall();
                } else {
                  console.warn('twilioHelper.hangupCall not available');
                  // Fallback: call Dart method directly for call summary
                  if (window.DartTwilioHandler && window.DartTwilioHandler.callHangupMethod) {
                    console.log('Calling Dart hangup method as fallback');
                    window.DartTwilioHandler.callHangupMethod();
                  }                }
                removeOverlay();
              };
            } // End of transformToActiveCall function
            
            // Store timeout reference for cleanup
            var autoRejectTimer = setTimeout(function() {
              console.log('=== AUTO-REJECT TIMER FIRED ===');
              var overlay = document.getElementById('twilio-call-overlay');
              
              // Debug current state              console.log('Auto-reject debug state:');
              console.log('  - window._incomingCall exists:', !!window._incomingCall);
              console.log('  - window._currentCall exists:', !!window._currentCall);
              console.log('  - window._callHandled:', !!window._callHandled);
              console.log('  - overlay exists:', !!overlay);
              console.log('  - overlay active-call class:', overlay ? overlay.classList.contains('active-call') : 'N/A');
              
              // Check if call was already handled
              if (window._callHandled) {
                console.log('  - Not auto-rejecting - call was already handled');
                return;
              }
              
              // Check if we should auto-reject
              var shouldAutoReject = false;
                // Only auto-reject if:
              // 1. There's still an incoming call waiting
              // 2. No active call is in progress
              // 3. The call status is not 'accept' or connected
              if (window._incomingCall && !window._currentCall) {
                // Additional check: make sure the incoming call object itself hasn't been answered
                var incomingCallStatus = null;
                try {
                  if (window._incomingCall && typeof window._incomingCall.status === 'function') {
                    incomingCallStatus = window._incomingCall.status();
                    console.log('  - Incoming call object status:', incomingCallStatus);
                  }
                } catch (e) {
                  console.log('  - Error getting incoming call object status:', e);
                }
                
                // If the incoming call is already open/connected, don't auto-reject
                if (incomingCallStatus === 'open' || incomingCallStatus === 'connecting') {
                  console.log('  - Not auto-rejecting - incoming call status indicates answered:', incomingCallStatus);
                  shouldAutoReject = false;
                } else {
                  // Check call status to make sure it's still ringing
                  var callStatus = 'unknown';
                  if (window.twilioHelper && window.twilioHelper.getCallStatus) {
                    try {
                      callStatus = window.twilioHelper.getCallStatus();
                      console.log('  - Call status from twilioHelper:', callStatus);
                    } catch (e) {
                      console.log('  - Error getting call status for auto-reject check:', e);
                    }
                  }
                  
                  // Only auto-reject if call is still ringing or connecting (not accepted/connected)
                  if (callStatus === 'ringing' || callStatus === 'connecting' || callStatus === 'unknown') {
                    shouldAutoReject = true;
                    console.log('  - Auto-reject conditions met - callStatus:', callStatus);
                  } else {
                    console.log('  - Not auto-rejecting - call status indicates call is active:', callStatus);
                  }
                }
              } else {
                if (window._currentCall) {
                  console.log('  - Not auto-rejecting - active call in progress');
                } else if (!window._incomingCall) {
                  console.log('  - Not auto-rejecting - no incoming call reference');
                }
              }
              
              if (shouldAutoReject) {
                console.log('🚨 Auto-rejecting call via twilioHelper after timeout');
                // Call the Twilio helper function which will dispatch the correct events
                if (window.twilioHelper && window.twilioHelper.rejectIncomingCall) {
                  window.twilioHelper.rejectIncomingCall();
                } else {
                  console.warn('twilioHelper.rejectIncomingCall not available for auto-reject');
                }
                if (overlay) {
                  removeOverlay();
                }
              } else {
                console.log('✅ Auto-reject timer expired but conditions not met - not rejecting call');
              }
              console.log('=== AUTO-REJECT TIMER END ===');
            }, 30000);            // Store timer reference globally so it can be cleared on disconnect
            window._autoRejectTimer = autoRejectTimer;
            
            // Also create a flag to track if call was already handled
            window._callHandled = false;
              // Add event listeners for call disconnect/cancel to automatically close overlay
            console.log('Setting up disconnect/cancel event listeners for HTML overlay...');
            
            function handleCallDisconnectOrCancel(eventType) {
              console.log('HTML overlay received ' + eventType + ' event - checking if should close overlay');
              
              // For cancelled events, check if there's still an active call before closing
              if (eventType === 'twilioCallCancelled') {
                // Check if there's still an active call
                var hasActiveCall = false;
                
                try {
                  // Check multiple sources for active call status
                  if (window.device && window.device.activeConnection && 
                      window.device.activeConnection.status && 
                      window.device.activeConnection.status() === 'open') {
                    hasActiveCall = true;
                    console.log('Active Twilio connection detected - not closing overlay for cancelled event');
                  }
                  
                  if (window.activeCall && 
                      (window.activeCall.status === 'open' || window.activeCall.status === 'connecting')) {
                    hasActiveCall = true;
                    console.log('Active call object detected - not closing overlay for cancelled event');
                  }
                  
                  if (window._currentCall && 
                      (window._currentCall.status === 'open' || window._currentCall.status === 'connecting')) {
                    hasActiveCall = true;
                    console.log('Current call object detected - not closing overlay for cancelled event');
                  }
                  
                  // Check via twilioHelper if available
                  if (window.twilioHelper && window.twilioHelper.getCallStatus) {
                    var callStatus = window.twilioHelper.getCallStatus();
                    if (callStatus === 'connected' || callStatus === 'open' || callStatus === 'connecting') {
                      hasActiveCall = true;
                      console.log('TwilioHelper reports active call (' + callStatus + ') - not closing overlay for cancelled event');
                    }
                  }
                } catch (e) {
                  console.log('Error checking active call status for cancelled event:', e);
                }
                
                if (hasActiveCall) {
                  console.log('NOT closing overlay - call is still active despite cancelled event');
                  return; // Don't close the overlay
                } else {
                  console.log('No active call detected - proceeding to close overlay for cancelled event');
                }
              }
              
              // For disconnected events or cancelled events with no active call, close the overlay
              console.log('Closing overlay due to ' + eventType + ' event');
              var overlay = document.getElementById('twilio-call-overlay');
              if (overlay) {
                console.log('Removing HTML overlay due to ' + eventType);
                removeOverlay();
              } else {
                // console.log('No HTML overlay found to remove for ' + eventType);
              }
            }
            
            // Listen for call disconnected events
            document.addEventListener('twilioCallDisconnected', function(event) {
              handleCallDisconnectOrCancel('twilioCallDisconnected');
            });
            
            // Listen for call cancelled events
            document.addEventListener('twilioCallCancelled', function(event) {
              handleCallDisconnectOrCancel('twilioCallCancelled');
            });
            
            console.log('HTML overlay disconnect/cancel event listeners set up successfully');
          })();
          '''
        ]);
      }
    } catch (e) {
      print('Error showing HTML-based call dialog: $e');
      _showingCallDialog = false;
      throw e;
    }
  }

// Open a browser popup window for incoming call
  void _openBrowserPopup(Map<String, dynamic> callInfo) {
    try {
      final popupUrl = '/popup.html';
      final popupName = 'incomingCall_${DateTime.now().millisecondsSinceEpoch}';
      final popupSpecs =
          'width=400,height=600,resizable=no,scrollbars=no,status=no,centerscreen=yes';

      // First store call info in session storage so the popup can access it
      _storeCallInfoInSession(callInfo);

      // Try to open the popup
      final popup = html.window.open(popupUrl, popupName, popupSpecs);
      if (popup == null || popup.closed == true) {
        print('Popup was blocked. Showing dialog instead');
        _showDialogWithoutContext(callInfo);
      } else {
        _incomingCallPopup = popup;
        print('Popup opened successfully');
      }
    } catch (e) {
      print('Error opening browser popup: $e');
      _showDialogWithoutContext(callInfo);
    }
  }

// Shows active call UI as overlay
  void _showActiveCallOverlay(Map<String, dynamic> callInfo) {
    try {
      // Create our active call overlay
      OverlayEntry? activeCallEntry;

      activeCallEntry = OverlayEntry(
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Material(
                color: Colors.black54,
                child: Center(
                  child: Container(
                    width: 320,
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.green.withOpacity(0.1),
                          child: Icon(
                            Icons.call,
                            size: 50,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(height: 15),
                        Text(
                          callInfo['from']?.toString() ?? 'Unknown Caller',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Call Active',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Mute button
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  toggleMute();
                                });
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: _isMuted ? Colors.orange : Colors.grey,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: (_isMuted ? Colors.orange : Colors.grey)
                                              .withOpacity(0.3),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      _isMuted ? Icons.mic_off : Icons.mic,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    _isMuted ? 'Unmute' : 'Mute',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[800],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Hangup button
                            GestureDetector(
                              onTap: () {
                                if (activeCallEntry != null) {
                                  activeCallEntry!.remove();
                                }
                                hangupCall();
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.red.withOpacity(0.3),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.call_end,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Hang Up',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[800],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      );

      // Add to overlay
      _insertOverlayEntry(activeCallEntry);
    } catch (e) {
      print('Error in _showActiveCallOverlay: $e');
    }
  } // Helper method to safely insert an overlay entry

  void _insertOverlayEntry(OverlayEntry entry) {
    try {
      print('Attempting to insert overlay entry...');

      // Try to find the overlay from the root element
      final BuildContext? overlayContext = _findOverlayContext();
      if (overlayContext != null) {
        print('Found overlay context, inserting entry');
        Overlay.of(overlayContext).insert(entry);
        return;
      }

      // Alternative approach: Try to get the navigator state and use its overlay
      final NavigatorState? navigatorState =
      WidgetsBinding.instance.rootElement?.findAncestorStateOfType<NavigatorState>();

      if (navigatorState != null && navigatorState.context.mounted) {
        print('Found navigator state, inserting entry via navigator context');
        Overlay.of(navigatorState.context).insert(entry);
        return;
      }

      // Try using the app's navigator by looking it up in the widget tree
      BuildContext? foundContext;
      WidgetsBinding.instance.rootElement?.visitChildElements((element) {
        if (foundContext == null) {
          element.visitChildElements((child) {
            if (foundContext == null && child.widget is Navigator) {
              foundContext = child;
            }
          });
        }
      });

      if (foundContext != null) {
        print('Found navigator context in widget tree, inserting entry');
        Overlay.of(foundContext!).insert(entry);
        return;
      }

      // If we couldn't find any valid context, log the error
      print('Could not find a valid context to show dialog');
      _showingCallDialog = false;
    } catch (e) {
      print('Error inserting overlay entry: $e');
      _showingCallDialog = false;
    }
  }

// Helper to find overlay context
  BuildContext? _findOverlayContext() {
    try {
      BuildContext? overlayContext;

      void visitor(Element element) {
        if (overlayContext != null) return;

        if (element.widget is Overlay) {
          overlayContext = element;
          return;
        }

        element.visitChildren(visitor);
      }

      WidgetsBinding.instance.rootElement?.visitChildren(visitor);
      return overlayContext;
    } catch (e) {
      print('Error finding overlay context: $e');
      return null;
    }
  }

// Accept incoming call
  Future<bool> acceptCall() async {
    try {
      final acceptScript = '''
      (function() {
        if (!window.twilioHelper || typeof window.twilioHelper.acceptIncomingCall !== 'function') {
          console.error("acceptIncomingCall function not available!");
          return false;
        }
        
        return window.twilioHelper.acceptIncomingCall();
      })();
      ''';
      final result = js.context.callMethod('eval', [acceptScript]);

      // Handle Promise if returned
      try {
        if (result != null && js_util.hasProperty(result, 'then')) {
          final asyncResult = await js_util.promiseToFuture<dynamic>(result);
          _hasActiveCall = asyncResult == true;
          return asyncResult == true;
        }
      } catch (e) {
        print('Error checking for promise or resolving acceptCall: $e');
        // Continue with synchronous handling
      }

      _hasActiveCall = result == true;
      return result == true;
    } catch (e) {
      print('Error accepting call: $e');
      return false;
    }
  }

// Reject incoming call
  Future<bool> rejectCall() async {
    try {
      final rejectScript = '''
      (function() {
        if (!window.twilioHelper || typeof window.twilioHelper.rejectIncomingCall !== 'function') {
          console.error("rejectIncomingCall function not available!");
          return false;
        }
        
        return window.twilioHelper.rejectIncomingCall();
      })();
      ''';
      final result = js.context.callMethod('eval', [rejectScript]);

      // Handle Promise if returned
      try {
        if (result != null && js_util.hasProperty(result, 'then')) {
          final asyncResult = await js_util.promiseToFuture<dynamic>(result);
          return asyncResult == true;
        }
      } catch (e) {
        print('Error checking for promise or resolving rejectCall: $e');
        // Continue with synchronous handling
      }

      return result == true;
    } catch (e) {
      print('Error rejecting call: $e');
      return false;
    }
  }

// Hang up active call
  Future<bool> hangupCall() async {
    try {
      final hangupScript = '''
      (function() {
        if (!window.twilioHelper || typeof window.twilioHelper.hangupCall !== 'function') {
          console.error("hangupCall function not available!");
          return false;
        }
        
        return window.twilioHelper.hangupCall();
      })();
      ''';
      final result = js.context.callMethod('eval', [hangupScript]);

      // Handle Promise if returned
      try {
        if (result != null && js_util.hasProperty(result, 'then')) {
          final asyncResult = await js_util.promiseToFuture<dynamic>(result);
          _hasActiveCall = !asyncResult;
          return asyncResult == true;
        }
      } catch (e) {
        print('Error checking for promise or resolving hangupCall: $e');
        // Continue with synchronous handling
      }

      _hasActiveCall = !(result == true);
      return result == true;
    } catch (e) {
      print('Error hanging up call: $e');
      return false;
    }
  }

// Toggle mute status
  Future<bool> toggleMute() async {
    try {
      final toggleMuteScript = '''
      (function() {
        if (!window.twilioHelper || typeof window.twilioHelper.toggleMute !== 'function') {
          console.error("toggleMute function not available!");
          return false;
        }
        
        return window.twilioHelper.toggleMute();
      })();
      ''';

      final result = js.context.callMethod('eval', [toggleMuteScript]);

      // Handle Promise if returned      // Handle Promise if returned
      try {
        if (result != null && js_util.hasProperty(result, 'then')) {
          final asyncResult = await js_util.promiseToFuture<dynamic>(result);
          _isMuted = asyncResult == true;
          _callMuteController.add(_isMuted);
          return asyncResult == true;
        }
      } catch (e) {
        print('Error checking for promise or resolving toggleMute: $e');
        // Continue with synchronous handling
      }

      _isMuted = result == true;
      _callMuteController.add(_isMuted);
      return _isMuted;
    } catch (e) {
      print('Error toggling mute: $e');
      return _isMuted;
    }
  }

// Store call information in session storage for popup to access
  void _storeCallInfoInSession(Map<String, dynamic> callInfo) {
    try {
      final callData = jsonEncode(callInfo);
      html.window.sessionStorage['twilio_call_info'] = callData;
      html.window.sessionStorage['twilio_call_timestamp'] =
          DateTime.now().millisecondsSinceEpoch.toString();
      print('Stored call info in session storage: $callData');
    } catch (e) {
      print('Error storing call info in session: $e');
    }

    // Show incoming call popup window  void _showIncomingCallPopup(Map<String, dynamic> callInfo) {
    try {
      print('_showIncomingCallPopup called with: $callInfo');

      // Close any existing popups
      _closePopups();

      final callerName = _filterParametersName(callInfo['parameters']?.toString() ?? '', "patientName") ?? 'Unknown Caller';
      final callerNumber = callInfo['callerId']?.toString() ?? '';
      print('Creating call dialog for caller: $callerName, number: $callerNumber');

      // Always use in-app overlay dialog instead of popups or notifications
      print('Using in-app overlay for incoming call dialog');
      _showIncomingCallOverlay(callInfo);
    } catch (e) {
      print('Error showing incoming call popup: $e');
      _showingCallDialog = false;
    }
  }

//   Filter Parameters
  String _filterParametersName(String parameters, String field) {
    String callerName = 'Unknown Caller';
    String clinicName = '';
    String clinicId = '';
    String clinicTimeZone = '';
    final rawParams = parameters;
    // Parse parameters from URL-encoded string
    if (rawParams.isNotEmpty) {
      final paramPairs = rawParams.split('&');
      for (final pair in paramPairs) {
        final keyValue = pair.split('=');
        if (keyValue.length == 2) {
          final key = keyValue[0];
          final value = keyValue[1];

          if (key == 'patientName') {
            callerName = _cleanCallerName(value);
          } else if (key == 'clinicName') {
            clinicName = _cleanClinicName(value);
          } else if (key == 'clinicId') {
            clinicId = _cleanClinicId(value);
          } else if (key == 'clinicTimeZone') {
            clinicTimeZone = _cleanClinicTimezone(value);
          }
        }
      }

      if (field == 'patientName') {
        return callerName;
      } else if (field == 'clinicName') {
        return clinicName;
      } else if (field == 'clinicId') {
        return clinicId;
      } else if (field == 'clinicTimeZone') {
        return clinicTimeZone;
      } else {
        return callerName;
      }
    } else {
      print('No parameters found in URL-encoded string');
      return callerName; // Default to 'Unknown Caller' if no parameters
    }
  }

// Start monitoring popup windows for user actions
  void _startPopupMonitoring() {
    _popupMonitorTimer?.cancel();
    _popupMonitorTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      _checkPopupActions();
    });

    // Note: We're now using in-app overlays instead of popups to prevent blocking issues
    // This timer is kept for compatibility with existing code that may still use
    // the sessionStorage communication channel
  }

// Check for user actions in popup windows
  void _checkPopupActions() {
    try {
      final action = html.window.sessionStorage['twilio_popup_action'] ?? '';

      if (action.isNotEmpty) {
        print('Popup action detected: $action');
        html.window.sessionStorage.remove('twilio_popup_action');
        // Store the action as "last action" to prevent close-triggered reject
        html.window.sessionStorage['twilio_last_action'] = action;

        switch (action) {
          case 'accept':
            _handleAcceptCall();
            break;
          case 'reject':
            _handleRejectCall();
            break;
          case 'hangup':
            _handleHangupCall();
            break;
          case 'mute':
          case 'unmute':
            _handleToggleMute();
            break;
        }
      } // Check if popups are still open
      if (_incomingCallPopup != null && _incomingCallPopup!.closed == true) {
        _incomingCallPopup = null;
        // Check if an action was recently processed
        final recentAction = html.window.sessionStorage['twilio_last_action'] ?? '';

        if (recentAction.isNotEmpty) {
          print('Popup closed after action: $recentAction - not treating as reject');
          html.window.sessionStorage.remove('twilio_last_action');
        } else if (_showingCallDialog) {
          // Only treat popup close as reject if no action was taken and dialog is still showing
          print('Popup closed without action, treating as reject');
          _handleRejectCall();
        }
      }

      if (_activeCallPopup != null && _activeCallPopup!.closed == true) {
        _activeCallPopup = null;
        _stopPopupMonitoring();
      }
    } catch (e) {
      print('Error checking popup actions: $e');
    }
  }

// Handle accept call action from popup  // Handle accept call action from popup
  void _handleAcceptCall() {
    print('Handling accept call from popup');
    _showingCallDialog = false;

    acceptCall().then((success) {
      if (success) {
        _hasActiveCall = true;
        if (_currentCallInfo.isNotEmpty) {
          // Only update to completed if the call was previously answered
          if (_currentCallInfo['callStatus'] == 'answered') {
            _currentCallInfo['callStatus'] = 'completed';
            _currentCallInfo['completedAt'] = DateTime.now().toIso8601String();

            // Calculate duration if possible
            if (_currentCallInfo.containsKey('answeredAt')) {
              try {
                final answeredAt = DateTime.parse(_currentCallInfo['answeredAt']);
                final completedAt = DateTime.now();
                final duration = completedAt.difference(answeredAt);
                final minutes = duration.inMinutes.toString().padLeft(2, '0');
                final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
                _currentCallInfo['duration'] = '$minutes:$seconds';
              } catch (e) {
                print('Error calculating call duration: $e');
              }
            }

            print('📞 Call marked as completed: ${_currentCallInfo['callStatus']}');
          }

          // Update the call info in session storage for JavaScript access
          try {
            html.window.sessionStorage['twilio_call_info'] = jsonEncode(_currentCallInfo);
          } catch (e) {
            print('Error updating call info in session storage: $e');
          }
        }
        _callAcceptedController.add(null);
        // Note: No need to show separate active call popup since it's now integrated
        // into the incoming call popup interface
        print('Call accepted successfully - popup will transform to active call interface');
      } else {
        print('Failed to accept call');
      }
    });
  }

// Handle reject call action from popup
  void _handleRejectCall() {
    print('Handling reject call from popup');
    _showingCallDialog = false;
    _closePopups();

    rejectCall().then((success) {
      _hasActiveCall = false;
      _callRejectedController.add(null);

      // Show call summary after 2 seconds delay
      print('📞 Scheduling call summary after reject (2 second delay)');
      Future.delayed(Duration(seconds: 2), () {
        if (_currentCallInfo.isNotEmpty) {
          final context = _getCurrentContext();
          print('📞 Showing call summary after reject delay');
          handleIncomingCallDisconnection(context, _currentCallInfo);
        } else {
          print('⚠️ _currentCallInfo is empty after reject, cannot show call summary');
        }
      });
    });

    _stopPopupMonitoring();
  } // Handle hangup call action from popup

  void _handleHangupCall() {
    print('Handling hangup call from popup');
    _closePopups();

    hangupCall().then((success) {
      _hasActiveCall = false;
      _callDisconnectedController.add(null);

      // Show call summary after 2 seconds delay
      print('📞 Scheduling call summary after hangup from popup (2 second delay)');
      Future.delayed(Duration(seconds: 2), () {
        if (_currentCallInfo.isNotEmpty) {
          final context = _getCurrentContext();
          print('📞 Showing call summary after hangup delay from popup');
          handleIncomingCallDisconnection(context, _currentCallInfo);
        } else {
          print('⚠️ _currentCallInfo is empty after hangup from popup, cannot show call summary');
        }
      });
    });

    _stopPopupMonitoring();
  }

// Handle toggle mute action from popup
  void _handleToggleMute() {
    print('Handling toggle mute from popup');
    toggleMute();
  }

// Close all popup windows
  void _closePopups() {
    try {
      if (_incomingCallPopup != null && !_incomingCallPopup!.closed!) {
        _incomingCallPopup!.close();
      }
      _incomingCallPopup = null;

      if (_activeCallPopup != null && !_activeCallPopup!.closed!) {
        _activeCallPopup!.close();
      }
      _activeCallPopup = null;
    } catch (e) {
      print('Error closing popups: $e');
    }
  }

// Stop popup monitoring
  void _stopPopupMonitoring() {
    _popupMonitorTimer?.cancel();
    _popupMonitorTimer = null;
  }

// Vibrate device (if supported)
  void _vibrateDevice() {
    try {
      if (html.window.navigator.userAgent.contains('Mobile')) {
        js.context.callMethod('eval',
            ['if ("vibrate" in navigator) { navigator.vibrate([500, 300, 500, 300, 500]); }']);
      }
    } catch (e) {
      print('Error vibrating device: $e');
    }
  }

// Test methods for testing overlay functionality
//   void testIncomingCallOverlay({
//     String? callerName,
//     String? callerNumber,
//   }) {
//     print('Test method: testIncomingCallOverlay called');
//     print('Caller Name: ${callerName ?? "Unknown"}');
//     print('Caller Number: ${callerNumber ?? "Unknown"}');
//
//     // For testing purposes, just log the call
//     // In a real scenario, this might simulate an incoming call overlay
//     final testCallInfo = {
//       'from': callerNumber ?? '+1234567890',
//       'to': '+1987654321',
//       'callerId': callerName ?? 'Test Caller',
//       'callSid': 'test-call-sid-${DateTime.now().millisecondsSinceEpoch}',
//     };
//
//     print('Test call info: $testCallInfo');
//   }

  // void requestNotificationPermissions() {
  //   print('Notification permissions not needed - using in-app dialogs only');
  //
  //   // Since we're using in-app dialogs instead of browser notifications,
  //   // we don't need to request notification permissions.
  //   // Just log that the method was called for compatibility.
  //
  //   print('Call notifications will be displayed as in-app dialogs');
  // }

// Cleanup resources
  void dispose() {
    _closePopups();
    _stopPopupMonitoring();

    _incomingCallController.close();
    _callAcceptedController.close();
    _callRejectedController.close();
    _callDisconnectedController.close();
    _callErrorController.close();
    _callMuteController.close();
    _clientRegistrationController.close();
  }

// Handle disconnection of incoming call with call summary
  void handleIncomingCallDisconnection(BuildContext? context, Map<String, dynamic> callInfo) {
    print('🔍 DEBUG: handleIncomingCallDisconnection called');
    print('🔍 DEBUG: callInfo received: $callInfo');
    print('🔍 DEBUG: context available: ${context != null}');
    print('🔍 DEBUG: kIsWeb: $kIsWeb');
    print('🔍 DEBUG: _callWasAnswered: $_callWasAnswered');
    print('Handling incoming call disconnection: $callInfo');

    // Close any active call dialogs first
    _closePopups();    // Reset state
    _hasActiveCall = false;
    _showingCallDialog = false;

    // Check if call was ever answered - if not, don't show summary
    // if (!_callWasAnswered && !kIsWeb) {
    //   print('🚫 Call was not answered, skipping call summary dialog');
    //   return;
    // }

    // On web, process call with SID and show enhanced summary
    if (kIsWeb) {
      print('Processing incoming call disconnection on web with GraphQL query');
      _processIncomingCallWithSid(callInfo);
      return;
    }

    // If no context is available, try to find one
    if (context == null) {
      context = _getCurrentContext();
      if (context == null) {
        print('Error: Could not find a valid context to show call summary');
        return;
      }
    }

    // Make sure the context is still valid
    if (!context!.mounted) {
      print('Error: Context is no longer mounted, cannot show call summary');
      return;
    }
  }

// Helper method for building a simple call detail row
  Widget _buildSimpleCallDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],      ),
    );
  }
  // Process incoming call with SID and show enhanced call summary
  void _processIncomingCallWithSid(Map<String, dynamic> callInfo) {
    print('🎯 Processing incoming call with SID: ${callInfo['callSid']}');
    print('🎯 Processing incoming call with GLOBAL CURRENT CALL SID: ${_currentCallInfo}');

    // Check if call was ever answered - if not, don't show summary
    // if (!_callWasAnswered) {
    //   print('🚫 Call was not answered, skipping call summary dialog');
    //   return;
    // }

    // Get the CallSid from the callInfo or try to retrieve it from JavaScript
    String callSid = callInfo['callSid']?.toString() ?? '';

    // If we don't have a CallSid, try to get it from JavaScript
    if (callSid.isEmpty || callSid == 'undefined' || callSid == 'null') {
      print('⚠️ No CallSid in callInfo, attempting to retrieve from JavaScript...');
      try {
        final jsCode = '''
        (function() {
          // Try accessing the stored CallSid directly
          if (window._storedCallSid && window._storedCallSid !== '') {
            console.log('Retrieved CallSid from window._storedCallSid:', window._storedCallSid);
            return window._storedCallSid;
          }
          
          // Try to get from localStorage
          try {
            var storedSid = localStorage.getItem('twilioCallSid');
            if (storedSid && storedSid !== '' && storedSid !== 'null') {
              console.log('Retrieved CallSid from localStorage:', storedSid);
              return storedSid;
            }
          } catch (e) {
            console.log('Error getting CallSid from localStorage:', e);
          }
          
          // Try to use the helper method
          if (window.twilioHelper && typeof window.twilioHelper.getCallSid === 'function') {
            try {
              var helperSid = window.twilioHelper.getCallSid();
              if (helperSid && helperSid !== '' && helperSid !== 'null') {
                console.log('Retrieved CallSid from twilioHelper.getCallSid():', helperSid);
                return helperSid;
              }
            } catch (e) {
              console.log('Error getting CallSid from twilioHelper:', e);
            }
          }
          
          // If we still don't have a CallSid, try to get directly from the current call
          if (window._currentCall && window._currentCall.parameters && window._currentCall.parameters.CallSid) {
            console.log('Retrieved CallSid from _currentCall.parameters:', window._currentCall.parameters.CallSid);
            return window._currentCall.parameters.CallSid;
          }
          
          console.log('⚠️ No CallSid available from any source');
          return '';
        })();
        ''';

        final result = js.context.callMethod('eval', [jsCode]);
        callSid = result?.toString() ?? '';
        print('Retrieved CallSid from JavaScript: $callSid');
        final jsClearCode = '''
        (function() {
          // Try accessing the stored CallSid directly
          if (window._storedCallSid && window._storedCallSid !== '') {
            console.log('Retrieved CallSid from window._storedCallSid:', window._storedCallSid);
            window._lastCallInfo = null;
            window._storedCallSid = null;
          }
          console.log('CLEARED STORED CALL SID');
          return '';
        })();
        ''';
        final clearResult = js.context.callMethod('eval', [jsClearCode]);
      } catch (e) {
        print('Error getting CallSid from JavaScript: $e');
      }
    }    // If we still don't have a CallSid, show fallback dialog
    if (callSid.isEmpty || callSid == 'undefined' || callSid == 'null') {
      print('⚠️ WARNING: Unable to retrieve CallSid. Showing fallback summary.');
      _showCallSummaryViaHandler(callInfo, null);
      return;
    }// Proceed with GraphQL API call to get detailed call information
    _performCallDataQuery(callSid, callInfo);
  }

  // Perform GraphQL query to get call data
  Future<void> _performCallDataQuery(String callSid, Map<String, dynamic> originalCallInfo) async {
    print('📞 Performing GraphQL query for CallSid: $callSid');

    try {
      // Add a delay similar to open_new_window.dart
      await Future.delayed(Duration(seconds: 2));

      final callResponse = GQLgetByFunctionCall.call(
          hasuraToken: FFAppState().hasuraToken,
          requestBody: getTwilioIncomingCallInformation(callSid)
      );

      callResponse.then((apiCallResponse) {
        final callInfoJson = apiCallResponse.bodyText;
        try {
          Map<String, dynamic> response = json.decode(callInfoJson);
          Map<String, dynamic> callData = {};

          if (response.containsKey('data') &&
              response['data'].containsKey('api_incoming_call_log') &&
              response['data']['api_incoming_call_log'].isNotEmpty) {
            callData = response['data']['api_incoming_call_log'][0];
            print('📞 Found incoming call log data');
          } else {
            print('⚠️ No incoming call log data found in response');
          }
          if (callData.isNotEmpty) {
            final enhancedCallInfo = _parseCallData(callData, originalCallInfo);
            print('SHOW CALL SUMMARY: $enhancedCallInfo');
            _showCallSummaryViaHandler(originalCallInfo, enhancedCallInfo);
          } else {
            // _showCallSummaryViaHandler(originalCallInfo, null);
          }
        } catch (e) {
          print('❌ Error parsing GraphQL response: $e');
          _showCallSummaryViaHandler(originalCallInfo, null);
        }
      }).catchError((error) {
        print("❌ Error getting call data: $error");
        _showCallSummaryViaHandler(originalCallInfo, null);
      });
    } catch (e) {
      print('❌ Error in _performCallDataQuery: $e');
      _showCallSummaryViaHandler(originalCallInfo, null);
    }
  }
  // Parse call data
  Map<String, dynamic> _parseCallData(Map<String, dynamic> callData, Map<String, dynamic> originalCallInfo) {
    try {      final callDuration = _formatCallDuration(callData['call_duration']?.toString() ?? '');
    final callStatus = callData['call_status']?.toString() ?? 'unknown';

    // Get timezone value and add debugging
    final originalTimezone = FFAppState().twilioCallData.patientClinicTimeZone;
    print('🌍 Retrieved original timezone from FFAppState: "$originalTimezone"');
    print('🌍 Original timezone type: ${originalTimezone.runtimeType}');
    print('🌍 Original timezone isEmpty: ${originalTimezone.isEmpty}');
    
    // Force timezone to PST for display since server sends IST but we want PST display
    final timezone = 'US/Pacific';
    print('🌍 Using timezone for display: "$timezone" (converted from IST to PST)');

    // Format start and end times similar to open_new_window.dart
    String answeredAt = _formatTimeWithTimezone(
        callData['answered_at']?.toString() ?? '',
        timezone);

    String completedAt = _formatTimeWithTimezone(
        callData['completed_at']?.toString() ?? '',
        timezone);
    return {
      'from': callData['origin_number'] ?? 'Unknown Caller',
      'callerId': callData['callerId'] ?? '',
      'phoneNumber': callData['origin_number'] ?? '',
      'callSid': callData['twilio_call_sid'] ?? '',
      'duration': callDuration,
      'callStatus': callStatus,
      'answeredAt': answeredAt,
      'completedAt': completedAt,
      'patientName': _storedCleanedCallerName.isNotEmpty ? _storedCleanedCallerName : "Unknown Caller",
      'clinicId': _storedClinicId,
      'clinicName': _storedCleanedClinicName.isNotEmpty ? _storedCleanedClinicName : "Unknown Clinic",
      'clinicTimezone': "US/Pacific" // Always use PST for display
    };
    } catch (e) {      return {
      'from': originalCallInfo['from'] ?? 'Unknown Caller',
      'callerId': originalCallInfo['callerId'] ?? '',
      'callSid': originalCallInfo['callSid'] ?? '',
      'callStatus': 'unknown',
      'duration': '00:00',
      'answeredAt': 'N/A',
      'completedAt': 'N/A',
      'patientName': "${FFAppState().twilioCallData.patientFirstName} ${FFAppState().twilioCallData.patientLastName}",
    };
    }
  }
  String _formatCallDuration(String durationString) {
    if (durationString.isEmpty) return '00:00';
    try {
      List<String> parts = durationString.split(':');
      if (parts.length == 3) {
        int hours = int.tryParse(parts[0]) ?? 0;
        int minutes = int.tryParse(parts[1]) ?? 0;
        int seconds = int.tryParse(parts[2]) ?? 0;
        minutes += hours * 60;
        return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      }
      return durationString;
    } catch (e) {
      return durationString;
    }
  }
  // Format time with timezone - use time as-is without conversion
  String _formatTimeWithTimezone(String timeString, String timezone) {
    if (timeString.isEmpty) {
      return 'N/A';
    }

    try {
      print('🕒 Formatting time without conversion: $timeString (timezone: $timezone)');

      // Parse the datetime string and use as-is
      DateTime dateTime = DateTime.parse(timeString);
      print('🌍 Parsed time (no conversion): $dateTime');

      // Format as DD-MMM-YYYY HH:MM:SS (PST) without any timezone conversion
      String formattedDateTime = DateFormat('dd-MMM-yyyy HH:mm:ss').format(dateTime);

      return '$formattedDateTime (PST)';
    } catch (e) {
      print('Error formatting time: $e');
      // Fallback: return original time with PST suffix
      return '$timeString (PST)';
    }
  }
  // Helper function to get timezone abbreviation - always return PST since we convert everything to PST
  String _getTimezoneAbbreviation(String timezone) {
    print('🌍 Getting timezone abbreviation for: "$timezone" (forcing PST for display)');

    // Always return PST since we're converting all times to PST for display
    return 'PST';
  }
  // Helper function to clean caller name by removing patientName= prefix and replacing + with spaces
  String _cleanCallerName(String rawCallerName) {
    if (rawCallerName.isEmpty) return 'Unknown Caller';

    String cleanedName = rawCallerName;

    // Remove "patientName=" prefix if present
    if (cleanedName.startsWith('patientName=')) {
      cleanedName = cleanedName.substring('patientName='.length);
    }

    // Replace + signs with spaces
    cleanedName = cleanedName.replaceAll('+', ' ');

    // Trim any extra whitespace
    cleanedName = cleanedName.trim();

    // Return cleaned name or fallback if empty
    final finalCleanedName = cleanedName.isNotEmpty ? cleanedName : 'Unknown Caller';

    // Store the cleaned name for use in call summary
    _storedCleanedCallerName = finalCleanedName;
    print('Stored cleaned caller name: $_storedCleanedCallerName');

    return finalCleanedName;
  }

  String _cleanClinicName(String rawClinicName) {
    if (rawClinicName.isEmpty) return 'Unknown Clinic';

    String cleanedClinicName = rawClinicName;

    // Remove "clinicName=" prefix if present
    if (cleanedClinicName.startsWith('clinicName=')) {
      cleanedClinicName = cleanedClinicName.substring('clinicName='.length);
    }

    // Replace + signs with spaces
    cleanedClinicName = cleanedClinicName.replaceAll('+', ' ');

    // Trim any extra whitespace
    cleanedClinicName = cleanedClinicName.trim();

    // Return cleaned name or fallback if empty
    final finalClinicName = cleanedClinicName.isNotEmpty ? cleanedClinicName : 'Unknown Clinic';

    // Store the cleaned name for use in call summary
    _storedCleanedClinicName = finalClinicName;
    print('Stored cleaned Clinic name: $_storedCleanedClinicName');

    return finalClinicName;
  }

  String _cleanClinicId(String rawClinicId) {
    if (rawClinicId.isEmpty) return '2';

    String cleanedClinicId = rawClinicId;

    // Remove "clinicId=" prefix if present
    if (cleanedClinicId.startsWith('clinicId=')) {
      cleanedClinicId = cleanedClinicId.substring('clinicId='.length);
    }

    // Trim any extra whitespace
    cleanedClinicId = cleanedClinicId.trim();

    // Return cleaned name or fallback if empty
    final finalCleanedClinicId = cleanedClinicId.isNotEmpty ? cleanedClinicId : 'US/Pacific';

    // Store the cleaned name for use in call summary
    _storedClinicId = finalCleanedClinicId;
    print('Stored cleaned Clinic ID: $_storedClinicId');

    return finalCleanedClinicId;
  }

  String _cleanClinicTimezone(String rawCallerName) {
    if (rawCallerName.isEmpty) return 'US/Pacific';

    String cleanedClinicTimezone = rawCallerName;

    // Remove "clinicTimeZone=" prefix if present
    if (cleanedClinicTimezone.startsWith('clinicTimeZone=')) {
      cleanedClinicTimezone = cleanedClinicTimezone.substring('clinicTimeZone='.length);
    }

    // Replace %2F signs with /
    cleanedClinicTimezone = cleanedClinicTimezone.replaceAll('%2F', '/');

    // Trim any extra whitespace
    cleanedClinicTimezone = cleanedClinicTimezone.trim();

    // Always return PST since we're converting all display to PST regardless of server timezone
    final finalCleanedClinicTimezone = 'US/Pacific'; // Force PST for display
    
    print('🌍 Original server timezone: $cleanedClinicTimezone');
    print('🌍 Converted display timezone: $finalCleanedClinicTimezone');

    // Store the PST timezone for use in call summary
    _storedClinicTimeZone = finalCleanedClinicTimezone;
    print('Stored cleaned Clinic Timezone (forced PST): $_storedClinicTimeZone');

    return finalCleanedClinicTimezone;
  }

  // Show call summary via call_summary_handler.js
  void _showCallSummaryViaHandler(Map<String, dynamic> originalCallInfo, Map<String, dynamic>? enhancedCallInfo) {
    try {
      // Prevent duplicate call summaries
      if (_showingCallSummary) {
        print('🚫 Call summary already showing, skipping duplicate');
        return;
      }

      // if (!_callWasAnswered) {
      //   print('📞 Call was not answered, skipping call summary');
      //   _showingCallSummary = false; // Reset flag to ensure future calls work properly
      //   return;
      // }

      _showingCallSummary = true;
      print('📞 Showing enhanced call summary dialog');
      print('📞 Original call info: $originalCallInfo');
      print('📞 Enhanced call info: $enhancedCallInfo');

      final callInfoForHandler = enhancedCallInfo ?? {
        'from': originalCallInfo['parameters'] ?? 'Unknown Caller',
        'callerId': originalCallInfo['callerId'] ?? '',
        'phoneNumber': originalCallInfo['callerId'] ?? '',
        'callSid': originalCallInfo['callSid'] ?? '',
        'callStatus': 'completed',
        'duration': '00:00',
        'answeredAt': 'N/A',
        'completedAt': 'N/A',
      };

      if(enhancedCallInfo != null) {
        callInfoForHandler.addAll({
          'clinicName': enhancedCallInfo['clinicName'] ?? 'Unknown Clinic',
          'clinicTimezone': enhancedCallInfo['clinicTimezone'] ?? 'US/Pacific',
          'clinicId': enhancedCallInfo['clinicId'] ?? '2',
          'patientName': enhancedCallInfo['patientName'] ?? 'Unknown Caller'
        });
      }

      print('📞 Final call info for handler: $callInfoForHandler');
      js.context['_lastCallInfo'] = js.JsObject.jsify(callInfoForHandler);

      final jsCode = '''
      (function() {
        console.log('📞 Creating enhanced call summary dialog...');
        
        // Get call information
        const callInfo = window._lastCallInfo;
        const callerName = callInfo.patientName || callInfo.from || 'Unknown Caller';
        const clinicId = callInfo.clinicId || '2';
        const clinicName = callInfo.clinicName || 'Unknown Clinic';
        // Force timezone to PST since server sends IST but we want to display in PST
        const originalTimezone = callInfo.clinicTimezone || 'Asia/Kolkata';
        const targetTimezone = 'US/Pacific'; // Always display in PST
        const callerNumber = callInfo.callerId || '';
        const rawCallStatus = callInfo.callStatus || 'completed';
        const duration = callInfo.duration || '';
        let answeredAt = callInfo.answeredAt || '';
        let completedAt = callInfo.completedAt || '';
        
        // Add debugging for timezone conversion from IST to PST
        console.log('🌍 DEBUG: Original timezone from server =', originalTimezone);
        console.log('🌍 DEBUG: Target timezone for display =', targetTimezone);
        console.log('🌍 DEBUG: Original answeredAt =', answeredAt);
        console.log('🌍 DEBUG: Original completedAt =', completedAt);
        console.log('🌍 DEBUG: Duration =', duration);
        
        // Convert completedAt from IST to PST if it's not already formatted
        if (completedAt && completedAt !== 'N/A') {
          console.log('🌍 Processing completedAt for IST to PST conversion:', completedAt);
          
          // Check if completedAt already has timezone info
          const hasTimezoneInfo = completedAt.match(/\\(([^)]+)\\)\$/);
          
          if (!hasTimezoneInfo) {
            console.log('🌍 completedAt lacks timezone info, converting from IST to PST');
            try {
              console.log('🌍 Raw input time from server:', completedAt);
              
              // Parse the time and treat it as IST
              let inputTime = new Date(completedAt);
              console.log('🌍 Parsed input time:', inputTime);
              console.log('🌍 Input time ISO:', inputTime.toISOString());
              
              // The server gives us time in IST, but JavaScript Date parses it as local time
              // We need to adjust for this difference
              
              // Method: Create the time in IST timezone, then convert to PST
              const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
              
              // Parse the components from the input string
              let year, month, day, hour, minute, second;
              
              if (completedAt.includes('T')) {
                // ISO format: 2025-06-26T22:43:59 or similar
                const isoMatch = completedAt.match(/(\\d{4})-(\\d{2})-(\\d{2})T(\\d{2}):(\\d{2}):(\\d{2})/);
                if (isoMatch) {
                  [, year, month, day, hour, minute, second] = isoMatch;
                }
              } else {
                // Other format: 2025-06-26 22:43:59 or similar
                const dateMatch = completedAt.match(/(\\d{4})-(\\d{2})-(\\d{2})\\s+(\\d{2}):(\\d{2}):(\\d{2})/);
                if (dateMatch) {
                  [, year, month, day, hour, minute, second] = dateMatch;
                }
              }
              
              if (year && month && day && hour && minute && second) {
                console.log(\`🌍 Parsed components: \${year}-\${month}-\${day} \${hour}:\${minute}:\${second}\`);
                
                // Create a date object from the parsed time (use as-is without timezone adjustment)
                const originalTime = new Date(\`\${year}-\${month}-\${day}T\${hour}:\${minute}:\${second}\`);
                console.log('🌍 Original time (no adjustment):', originalTime.toISOString());
                
                // Format the time without adjustment
                try {
                  const timeOptions = {
                    year: 'numeric',
                    month: '2-digit',
                    day: '2-digit',
                    hour: '2-digit',
                    minute: '2-digit',
                    second: '2-digit',
                    hour12: false
                  };
                  
                  const timeFormatter = new Intl.DateTimeFormat('en-CA', timeOptions);
                  const timeParts = timeFormatter.formatToParts(originalTime);
                  
                  const timeYear = timeParts.find(part => part.type === 'year').value;
                  const timeMonth = months[parseInt(timeParts.find(part => part.type === 'month').value) - 1];
                  const timeDay = timeParts.find(part => part.type === 'day').value;
                  const timeHour = timeParts.find(part => part.type === 'hour').value;
                  const timeMinute = timeParts.find(part => part.type === 'minute').value;
                  const timeSecond = timeParts.find(part => part.type === 'second').value;
                  
                  completedAt = \`\${timeDay}-\${timeMonth}-\${timeYear} \${timeHour}:\${timeMinute}:\${timeSecond} (PST)\`;
                  console.log('🌍 ✅ Formatted time without adjustment:', completedAt);
                } catch (intlError) {
                  console.log('🌍 Intl failed, using manual formatting:', intlError);
                  
                  // Manual formatting for original time
                  const timeDay = originalTime.getDate().toString().padStart(2, '0');
                  const timeMonth = months[originalTime.getMonth()];
                  const timeYear = originalTime.getFullYear();
                  const timeHours = (originalTime.getHours() - 7).toString().padStart(2, '0');
                  const timeMinutes = originalTime.getMinutes().toString().padStart(2, '0');
                  const timeSeconds = originalTime.getSeconds().toString().padStart(2, '0');
                  
                  completedAt = \`\${timeDay}-\${timeMonth}-\${timeYear} \${timeHours}:\${timeMinutes}:\${timeSeconds} (PST)\`;
                  console.log('🌍 ✅ Manual formatting without adjustment:', completedAt);
                }
              } else {
                console.log('🌍 ❌ Could not parse time components');
                completedAt = completedAt + ' (PST)';
              }              } catch (error) {
                console.log('Error formatting time without adjustment:', error);
                // Fallback: just append PST
                completedAt = completedAt + ' (PST)';
              }
          } else {
            console.log('🌍 completedAt already has timezone info, converting to PST if needed:', completedAt);
            // If it already has timezone info, check if it needs conversion to PST
            const currentTz = hasTimezoneInfo[1];
            if (currentTz !== 'PST' && currentTz !== 'Pacific') {
              try {
                const timeStr = completedAt.replace(/\\s*\\([^)]+\\)\$/, ''); // Remove timezone part
                console.log('🌍 Extracting time string (no adjustment):', timeStr);
                const originalTime = new Date(timeStr);
                
                // Use the time as-is without adjustment
                console.log('🌍 Time without adjustment:', originalTime);
                
                // Format the time without adjustment
                const options = {
                  year: 'numeric',
                  month: '2-digit',
                  day: '2-digit',
                  hour: '2-digit',
                  minute: '2-digit',
                  second: '2-digit',
                  hour12: false
                };
                
                const formatter = new Intl.DateTimeFormat('en-CA', options);
                const parts = formatter.formatToParts(originalTime);
                const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                
                const year = parts.find(part => part.type === 'year').value;
                const month = months[parseInt(parts.find(part => part.type === 'month').value) - 1];
                const day = parts.find(part => part.type === 'day').value;
                const hour = parts.find(part => part.type === 'hour').value;
                const minute = parts.find(part => part.type === 'minute').value;
                const second = parts.find(part => part.type === 'second').value;
                
                completedAt = \`\${day}-\${month}-\${year} \${hour}:\${minute}:\${second} (PST)\`;
                console.log('🌍 Time formatted without adjustment:', completedAt);
              } catch (error) {
                console.log('Error formatting existing timezone time:', error);
              }
            }
          }
        }
          // Calculate started time if missing but we have ended time and duration (both in PST)
        if ((!answeredAt || answeredAt === 'N/A') && completedAt && completedAt !== 'N/A' && duration && duration !== '00:00') {
          console.log('🌍 Calculating answeredAt from completedAt and duration (no timezone adjustment)');
          try {
            // Since completedAt is displayed as-is, answeredAt should match
            let timezoneAbbr = 'PST'; // Keep PST for consistency
            const timezoneMatch = completedAt.match(/\\(([^)]+)\\)\$/);
            if (timezoneMatch) {
              timezoneAbbr = timezoneMatch[1];
              console.log('🌍 Extracted timezone abbreviation from completedAt:', timezoneAbbr);
            }
            
            // Parse the completedAt time to get the base date for consistent parsing
            const endTimeStr = completedAt.replace(/\\s*\\([^)]+\\)\$/, ''); // Remove timezone part for parsing
            console.log('🌍 Parsing endTimeStr (no adjustment):', endTimeStr);
            
            // Create the end time object - use as-is
            const endTime = new Date(endTimeStr);
            console.log('🌍 Created endTime object (no adjustment):', endTime);
            
            const durationParts = duration.split(':');
            const durationInSeconds = parseInt(durationParts[0]) * 60 + parseInt(durationParts[1]);
            console.log('🌍 Duration in seconds:', durationInSeconds);
            
            // Calculate start time by subtracting duration from the end time
            const startTime = new Date(endTime.getTime() - (durationInSeconds * 1000));
            console.log('🌍 Calculated startTime (no adjustment):', startTime);
            
            // Format startTime to match the same format as completedAt: dd-MMM-yyyy HH:mm:ss (PST)
            const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
            
            // Format the start time (no additional adjustment needed)
            const day = startTime.getDate().toString().padStart(2, '0');
            const month = months[startTime.getMonth()];
            const year = startTime.getFullYear();
            const hours = (startTime.getHours() - 7).toString().padStart(2, '0');
            const minutes = (startTime.getMinutes()).toString().padStart(2, '0');
            const seconds = startTime.getSeconds().toString().padStart(2, '0');
            
            answeredAt = \`\${day}-\${month}-\${year} \${hours}:\${minutes}:\${seconds} (PST)\`;
            console.log('🌍 Final formatted answeredAt (no adjustment):', answeredAt);
            
          } catch (error) {
            console.log('Error calculating start time:', error);
          }
        }        // Dynamic call status styling based on status
        let statusColor, statusIcon, statusText, statusBgColor;
        switch (rawCallStatus.toLowerCase()) {
          case 'completed':
            statusColor = '#4caf50';
            statusBgColor = '#e8f5e8';
            statusIcon = '✓';
            statusText = 'Call Completed';
            break;
          case 'failed':
            statusColor = '#f44336';
            statusBgColor = '#ffebee';
            statusIcon = '⚠';
            statusText = 'Call Failed';
            break;
          case 'no-answer':
            statusColor = '#ff9800';
            statusBgColor = '#fff3e0';
            statusIcon = '📞';
            statusText = 'No Answer';
            break;
          case 'busy':
            statusColor = '#ff9800';
            statusBgColor = '#fff3e0';
            statusIcon = '📞';
            statusText = 'Busy';
            break;          
          case 'transferred':
            statusColor = '#ff9800';
            statusBgColor = '#fff3e0';
            statusIcon = '🔄';
            statusText = 'Call Transferred';
            break;
          case 'unknown':
            statusColor = '#9e9e9e';
            statusBgColor = '#f5f5f5';
            statusIcon = '❓';
            statusText = 'Call Status Unknown';
            break;
          default:
            statusColor = '#2196f3';
            statusBgColor = '#e3f2fd';
            statusIcon = '📞';
            statusText = `Call Status: \${rawCallStatus}`;
        }
        
        // Remove any existing overlay first to prevent duplicates
        var existingOverlay = document.getElementById('call-summary-overlay');
        if (existingOverlay) {
          existingOverlay.parentNode.removeChild(existingOverlay);
        }
        
        // Create a modern dialog overlay
        var overlay = document.createElement('div');
        overlay.id = 'call-summary-overlay';
        overlay.style.cssText = `
          position: fixed;
          top: 0;
          left: 0;
          width: 100%;
          height: 100%;
          background: rgba(0, 0, 0, 0.5);
          z-index: 9999;
          display: flex;
          align-items: center;
          justify-content: center;
          font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
        `;
        
        var dialog = document.createElement('div');
        dialog.id = 'call-summary-dialog';
        dialog.style.cssText = `
          background: white;
          padding: 24px;
          border-radius: 16px;
          text-align: left;
          box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
          min-width: 320px;
          max-width: 420px;
          animation: slideIn 0.3s ease-out;
          position: relative;
        `;
        
        // Add animation keyframes to document
        if (!document.querySelector('#call-summary-animation')) {
          var style = document.createElement('style');
          style.id = 'call-summary-animation';
          style.textContent = `
            @keyframes slideIn {
              from {
                opacity: 0;
                transform: scale(0.9) translateY(-20px);
              }
              to {
                opacity: 1;
                transform: scale(1) translateY(0);
              }
            }
          `;
          document.head.appendChild(style);
        }
        
        // Build caller number display conditionally
        const callerNumberDisplay = callerNumber 
          ? `<div style="display: flex; justify-content: space-between; align-items: center; padding: 12px 0; border-bottom: 1px solid #f1f5f9;">
               <span style="color: #64748b; font-weight: 500;">Phone Number:</span>
               <span style="color: #1e293b; font-weight: 500;">\${callerNumber}</span>
             </div>`
          : '';
          // Dialog content matching the exact design from the screenshot
        dialog.innerHTML = `
          <button onclick="this.closest('#call-summary-overlay').remove()" style="
            position: absolute;
            top: 16px;
            right: 16px;
            background: none;
            border: none;
            font-size: 24px;
            color: #9ca3af;
            cursor: pointer;
            padding: 8px;
            line-height: 1;
            border-radius: 4px;
            transition: background-color 0.2s;
          " onmouseover="this.style.backgroundColor='#f3f4f6'" onmouseout="this.style.backgroundColor='transparent'">×</button>
            <h2 style="
            margin: 0 0 24px 0; 
            color: #374151; 
            font-size: 22px; 
            font-weight: 600;
            text-align: left;
          ">Call Summary</h2>
            <div style="
            background: \${statusBgColor};
            padding: 24px 20px;
            border-radius: 12px;
            text-align: center;
            margin: 0 0 24px 0;
          ">            
          <div style="
              width: 48px;
              height: 48px;
              margin: 0 auto 12px auto;
              background: \${statusColor};
              border-radius: 50%;
              display: flex;
              align-items: center;
              justify-content: center;
              color: white;
              font-size: 24px;
              font-weight: bold;
            ">\${statusIcon}
            </div>            
            <div style="
              color: \${statusColor}; 
              font-weight: 600; 
              font-size: 18px;
              margin: 0;
            ">\${statusText}</div>
          </div>
            <div style="margin-bottom: 24px;">
            <div style="
              display: flex; 
              justify-content: space-between; 
              align-items: flex-start; 
              padding: 12px 0; 
              border-bottom: 1px solid #e5e7eb;
            ">
              <span style="
                color: #6b7280; 
                font-weight: 500;
                font-size: 15px;
                min-width: 120px;
              ">Patient:</span>
              <span style="
                color: #374151; 
                font-weight: 500;
                font-size: 15px;
                text-align: right;
                flex: 1;
              ">\${callerName}</span>
            </div>
            <div style="
              display: flex; 
              justify-content: space-between; 
              align-items: flex-start; 
              padding: 12px 0; 
              border-bottom: 1px solid #e5e7eb;
            ">
              <span style="
                color: #6b7280; 
                font-weight: 500;
                font-size: 15px;
                min-width: 120px;
              ">Clinic Name:</span>
              <span style="
                color: #374151; 
                font-weight: 500;
                font-size: 15px;
                text-align: right;
                flex: 1;
              ">\${clinicName}</span>
            </div>
              \${callerNumber ? `
            <div style="
              display: flex; 
              justify-content: space-between; 
              align-items: flex-start; 
              padding: 12px 0; 
              border-bottom: 1px solid #e5e7eb;
            ">
              <span style="
                color: #6b7280; 
                font-weight: 500;
                font-size: 15px;
                min-width: 120px;
              ">Phone Number:</span>
              <span style="
                color: #374151; 
                font-weight: 500;
                font-size: 15px;
                text-align: right;
                flex: 1;
              ">\${callerNumber}</span>
            </div>
            ` : ''}
            
            \${duration && duration !== '00:00' ? `
            <div style="
              display: flex; 
              justify-content: space-between; 
              align-items: flex-start; 
              padding: 16px 0; 
              border-bottom: 1px solid #e5e7eb;
            ">
              <span style="
                color: #6b7280; 
                font-weight: 500;
                font-size: 16px;
                min-width: 120px;
              ">Duration:</span>
              <span style="
                color: #374151; 
                font-weight: 500;
                font-size: 16px;
                text-align: right;
                flex: 1;
              ">\${duration}</span>
            </div>
            ` : ''}
            
            \${answeredAt && answeredAt !== 'N/A' ? `
            <div style="
              display: flex; 
              justify-content: space-between; 
              align-items: flex-start; 
              padding: 16px 0; 
              border-bottom: 1px solid #e5e7eb;
            ">
              <span style="
                color: #6b7280; 
                font-weight: 500;
                font-size: 16px;
                min-width: 120px;
              ">Started:</span>
              <span style="
                color: #374151; 
                font-weight: 500;
                font-size: 16px;
                text-align: right;
                flex: 1;
              ">\${answeredAt}</span>
            </div>
            ` : ''}
            
            \${completedAt && completedAt !== 'N/A' ? `
            <div style="
              display: flex; 
              justify-content: space-between; 
              align-items: flex-start; 
              padding: 16px 0;
            ">
              <span style="
                color: #6b7280; 
                font-weight: 500;
                font-size: 16px;
                min-width: 120px;
              ">Ended:</span>
              <span style="
                color: #374151; 
                font-weight: 500;
                font-size: 16px;
                text-align: right;
                flex: 1;
              ">\${completedAt}</span>
            </div>
            ` : ''}
          </div>
          
          <button id="close-summary-btn" style="
            background: #8b5cf6;
            color: white;
            border: none;
            padding: 16px 24px;
            border-radius: 8px;
            cursor: pointer;
            font-size: 16px;
            font-weight: 600;
            width: 100%;
            transition: all 0.2s ease;
            box-shadow: none;
          " onmouseover="this.style.backgroundColor='#7c3aed'" onmouseout="this.style.backgroundColor='#8b5cf6'">
            Close
          </button>
        `;
        
        overlay.appendChild(dialog);
        document.body.appendChild(overlay);
        
        // Function to safely remove the overlay
        function safelyRemoveOverlay() {
          var overlayElement = document.getElementById('call-summary-overlay');
          if (overlayElement && overlayElement.parentNode) {
            // Add fade out animation
            overlayElement.style.opacity = '0';
            overlayElement.style.transition = 'opacity 0.2s ease-out';
            
            setTimeout(() => {
              if (overlayElement.parentNode) {
                overlayElement.parentNode.removeChild(overlayElement);
              }
            }, 200);
              // Reset call summary and answered flags when overlay is closed
            if (window.DartTwilioHandler && window.DartTwilioHandler.resetCallSummaryFlag) {
              window.DartTwilioHandler.resetCallSummaryFlag();
            }
            if (window.DartTwilioHandler && window.DartTwilioHandler.resetCallAnsweredFlag) {
              console.log('Resetting _callWasAnswered flag after call summary closed');
              window.DartTwilioHandler.resetCallAnsweredFlag();
            }
            
            // Clear stored call information when call summary is closed
            if (window._lastCallInfo) {
              console.log('Clearing stored _lastCallInfo after call summary closed');
              delete window._lastCallInfo;
              delete window._currentCallInfo;
            }
            if (window._storedCallSid) {
              console.log('Clearing stored _storedCallSid after call summary closed');
              delete window._storedCallSid;
              delete window._currentCallInfo;
            }
          }
        }
        
        // Add click handlers
        document.getElementById('close-summary-btn').onclick = function() {
          safelyRemoveOverlay();
        };
        
        // Close when clicking outside the dialog
        overlay.addEventListener('click', function(event) {
          if (event.target === overlay) {
            safelyRemoveOverlay();
          }
        });
        
        // Auto-close after 30 seconds
        setTimeout(function() {
          safelyRemoveOverlay();
        }, 30000);
        
        return true;
      })();
      ''';
      js.context.callMethod('eval', [jsCode]);
      print('✅ Enhanced call summary shown successfully');
      // Failsafe: Reset the _showingCallSummary flag after 35 seconds as a backup
      Timer(Duration(seconds: 35), () {
        if (_showingCallSummary) {
          print('⚠️ Failsafe: Resetting _showingCallSummary flag after timeout');
          _showingCallSummary = false;
          _callWasAnswered = false; // Also reset call answered flag in failsafe

        }
      });

    } catch (e) {
      print('❌ Error in _showCallSummaryViaHandler: $e');
      _showingCallSummary = false; // Reset flag on error
    }
  }

  void _showDraggableCallDialog(Map<String, dynamic> callInfo) {
    try {
      print('Showing unified incoming call dialog for: ${callInfo['from']}');

      // First, try to find a suitable overlay to insert our entry
      final overlayState = _findOverlayState();

      if (overlayState == null) {
        throw Exception('No overlay state found for incoming call dialog');
      }

      // Use our unified dialog as an overlay
      _draggableCallOverlayEntry = OverlayEntry(
        builder: (context) {
          return DraggableCallOverlay(
            callerName: callInfo['from']?.toString() ?? 'Unknown Caller',
            callerNumber: callInfo['callerId']?.toString() ?? '',
            isActive: _hasActiveCall,
            isMuted: _isMuted,
            onAccept: () {
              print('Call accepted via draggable dialog');
              acceptCall().then((success) {
                if (success) {
                  _updateDraggableCallUI(callInfo);
                }
              });
            },
            onReject: () {
              print('Call rejected via draggable dialog');
              rejectCall().then((_) {
                if (_draggableCallOverlayEntry != null) {
                  _draggableCallOverlayEntry!.remove();
                  _draggableCallOverlayEntry = null;
                }

                // Show call summary after 2 seconds delay
                print(
                    '📞 Scheduling call summary after reject from draggable dialog (2 second delay)');
                Future.delayed(Duration(seconds: 2), () {
                  if (_currentCallInfo.isNotEmpty) {
                    final context = _getCurrentContext();
                    print('📞 Showing call summary after reject delay from draggable dialog');
                    handleIncomingCallDisconnection(context, _currentCallInfo);
                  } else {
                    print(
                        '⚠️ _currentCallInfo is empty after reject from draggable dialog, cannot show call summary');
                  }
                });
              });
            },
            onHangup: () {
              print('Call hung up via draggable dialog');
              hangupCall().then((_) {
                if (_draggableCallOverlayEntry != null) {
                  _draggableCallOverlayEntry!.remove();
                  _draggableCallOverlayEntry = null;
                }

                // Show call summary after 2 seconds delay
                print(
                    '📞 Scheduling call summary after hangup from draggable dialog (2 second delay)');
                Future.delayed(Duration(seconds: 2), () {
                  if (_currentCallInfo.isNotEmpty) {
                    final context = _getCurrentContext();
                    print('📞 Showing call summary after hangup delay from draggable dialog');
                    handleIncomingCallDisconnection(context, _currentCallInfo);
                  } else {
                    print(
                        '⚠️ _currentCallInfo is empty after hangup from draggable dialog, cannot show call summary');
                  }
                });
              });
            },
            onToggleMute: () {
              toggleMute().then((_) {
                // Update the UI to reflect mute state by replacing the entry
                _updateDraggableCallUI(callInfo);
              });
            },
          );
        },
      );

      // Insert the overlay entry
      overlayState.insert(_draggableCallOverlayEntry!);
    } catch (e) {
      print('Error showing draggable call dialog: $e');
      throw e; // Re-throw to allow fallback methods to be used
    }
  }

// Helper method to update the draggable call UI (replace the rebuild method)
  void _updateDraggableCallUI(Map<String, dynamic> callInfo) {
    if (_draggableCallOverlayEntry == null) return;

    final overlayState = _findOverlayState();
    if (overlayState == null) return;

    // Create a new entry with the current state
    final oldEntry = _draggableCallOverlayEntry;
    _draggableCallOverlayEntry = OverlayEntry(
      builder: (context) {
        return DraggableCallOverlay(
          callerName: callInfo['from']?.toString() ?? 'Unknown Caller',
          callerNumber: callInfo['callerId']?.toString() ?? '',
          isActive: _hasActiveCall,
          isMuted: _isMuted,
          // Use the current mute state
          onAccept: _hasActiveCall
              ? () {}
              : () {
            acceptCall().then((success) {
              if (success) {
                _updateDraggableCallUI(callInfo);
              }
            });
          },
          onReject: () {
            rejectCall().then((_) {
              if (_draggableCallOverlayEntry != null) {
                _draggableCallOverlayEntry!.remove();
                _draggableCallOverlayEntry = null;
              }

              // Show call summary after 2 seconds delay
              print(
                  '📞 Scheduling call summary after reject from updated draggable dialog (2 second delay)');
              Future.delayed(Duration(seconds: 2), () {
                if (_currentCallInfo.isNotEmpty) {
                  final context = _getCurrentContext();
                  print('📞 Showing call summary after reject delay from updated draggable dialog');
                  handleIncomingCallDisconnection(context, _currentCallInfo);
                } else {
                  print(
                      '⚠️ _currentCallInfo is empty after reject from updated draggable dialog, cannot show call summary');
                }
              });
            });
          },
          onHangup: () {
            hangupCall().then((_) {
              if (_draggableCallOverlayEntry != null) {
                _draggableCallOverlayEntry!.remove();
                _draggableCallOverlayEntry = null;
              }

              // Show call summary after 2 seconds delay
              print(
                  '📞 Scheduling call summary after hangup from updated draggable dialog (2 second delay)');
              Future.delayed(Duration(seconds: 2), () {
                if (_currentCallInfo.isNotEmpty) {
                  final context = _getCurrentContext();
                  print('📞 Showing call summary after hangup delay from updated draggable dialog');
                  handleIncomingCallDisconnection(context, _currentCallInfo);
                } else {
                  print(
                      '⚠️ _currentCallInfo is empty after hangup from updated draggable dialog, cannot show call summary');
                }
              });
            });
          },
          onToggleMute: () {
            toggleMute().then((_) {
              _updateDraggableCallUI(callInfo);
            });
          },
        );
      },
    );

    // Replace the old entry with the new one
    oldEntry?.remove();
    overlayState.insert(_draggableCallOverlayEntry!);
  }

// Helper to find overlay state for showing dialogs
  OverlayState? _findOverlayState() {
    try {
      final BuildContext? overlayContext = _findOverlayContext();
      if (overlayContext != null) {
        return Overlay.of(overlayContext);
      }

      // Try navigator state
      final NavigatorState? navigatorState =
      WidgetsBinding.instance.rootElement?.findAncestorStateOfType<NavigatorState>();

      if (navigatorState != null && navigatorState.context.mounted) {
        return Overlay.of(navigatorState.context);
      }

      return null;
    } catch (e) {
      print('Error finding overlay state: $e');
      return null;
    }
  }

// Helper method to clear auto-reject timer
  void _clearAutoRejectTimer([String reason = 'unspecified']) {
    try {
      js.context.callMethod('eval', [
        '''
        if (window._autoRejectTimer) {
          console.log('Clearing auto-reject timer - reason: $reason');
          clearTimeout(window._autoRejectTimer);
          window._autoRejectTimer = null;
        }
      '''
      ]);
    } catch (e) {
      print('Error clearing auto-reject timer: $e');
    }
  }
}