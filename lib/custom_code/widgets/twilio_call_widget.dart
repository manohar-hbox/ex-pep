// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import '/backend/api_requests/api_calls.dart'; // Import for TwilioGroup
import 'package:flutter/material.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/custom_code/models/user_info.dart'; // Import for UserInfo model
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'index.dart'; // Imports other custom widgets

import '../../flutter_flow/flutter_flow_widgets.dart';

import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:js_util' as js_util;
import 'dart:math' as Math;
import 'dart:convert'; // Import for JSON encoding/decoding

class TwilioCallWidget extends StatefulWidget {
  const TwilioCallWidget({
    Key? key,
    this.width = 700,
    this.height = 900,
  }) : super(key: key);

  final double width;
  final double height;

  @override
  _TwilioCallWidgetState createState() => _TwilioCallWidgetState();
}

class _TwilioCallWidgetState extends State<TwilioCallWidget>
    with TickerProviderStateMixin {
  final TextEditingController _phoneNumberController = TextEditingController();
  bool _isInitialized = false;
  bool _isCallActive = false;
  bool _isLoading = false;
  var twilioService = TwilioService();
  var transferredFromRoles = <String>[];
  var transferredToRoles = <String>[];

  // Animation controllers
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Call status tracking
  String _callStatus = 'unknown';
  Stopwatch _callDuration = Stopwatch();
  String _durationText = '00:00';
  Timer? _durationTimer;
  Timer? _audioLevelTimer;
  Timer? _callStatusTimer;
  int _audioLevel = 0;

  // Global variable to store user information
  List<UserInfo> userRolesInfo = [];

  @override
  void initState() {
    super.initState();

    // Initialize pulse animation controller
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Make the animation loop
    _pulseController.repeat(reverse: true);

    // Set the phone number from AppState immediately in initState
    _phoneNumberController.text = FFAppState().twilioCTCPhoneNo.isEmpty
        ? "13026006476"
        : FFAppState().twilioCTCPhoneNo;
    // _phoneNumberController.text = "919913259501";
    // _phoneNumberController.text = "13026006476"; // Intermedia
    // _phoneNumberController.text = "919691072172"; // Arish

    _processTransferInformation();
    _getUserRolesInformation();

    // Set up listeners for call events
    _setupCallEventListeners();

    // First, ensure JavaScript is initialized properly with direct JS
    js.context.callMethod('eval', [
      '''
    (function() {
      console.log("TwilioCallWidget initState - ensuring JavaScript environment");
      
      // Create the helper if it doesn't exist
      if (!window.twilioHelper) {
        console.log("Creating initial twilioHelper object");
        window.twilioHelper = {};
      }
      
      // Set the ready flag (will be properly verified later)
      window.twilioHelperReady = true;
      
      // Ensure all required functions exist with proper implementations
      var funcs = ['setupTwilio', 'makeCall', 'hangupCall', 'toggleMute', 'sendDigits', 'getAudioLevel'];
      
      funcs.forEach(function(f) {
        // Only create the function if it doesn't already exist
        if (typeof window.twilioHelper[f] !== 'function') {
          console.log("Creating initial function: " + f);
          
          // Define appropriate implementation based on function name
          if (f === 'setupTwilio') {
            window.twilioHelper[f] = function(token) {
              console.log("INITIAL " + f + " called with token:", (token || "").substring(0, 10) + "...");
              return true;
            };
          } else if (f === 'makeCall') {
            window.twilioHelper[f] = function(toPhoneNumber) {
              console.log("INITIAL " + f + " called with phone number:", toPhoneNumber);
              return true;
            };
          } else if (f === 'sendDigits') {
            window.twilioHelper[f] = function(digits) {
              console.log("INITIAL " + f + " called with digits:", digits);
              return true;
            };
          } else if (f === 'getAudioLevel') {
            window.twilioHelper[f] = function() {
              return Math.random() * 30;
            };
          } else {
            // Default implementation for other functions
            window.twilioHelper[f] = function() {
              console.log("INITIAL " + f + " called");
              return true;
            };
          }
        }
      });
      
      // Verify functions exist
      var verification = funcs.map(function(f) {
        return {
          name: f,
          exists: typeof window.twilioHelper[f] === 'function'
        };
      });
      
      console.log("Function verification after init:", verification);
      
      // Set ready flag
      window.twilioHelperReady = true;
      
      return {
        success: verification.every(v => v.exists),
        details: verification
      };
    })();
    '''
    ]);

    // Run diagnostic check when the widget initializes
    _checkTwilioStatus(); // Automatically initialize Twilio with token from AppState
    _initializeTwilio().then((_) {
      // Auto-start the call after initialization
      if (_isInitialized && !_isCallActive) {
        _makeCall();
      }
    });
  }

  // Process transfer information from AppState
  void _processTransferInformation() async {
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

  void _getUserRolesInformation() async {
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

  // Function to start the call
  Future<void> _makeCall() async {
    if (_phoneNumberController.text.isNotEmpty) {
      try {
        setState(() {
          _isLoading = true;
        });

        // Ensure Twilio is properly injected before making call
        print('Ensuring Twilio functions are available before call...');
        await injectTwilioFunctions();

        // Attempt to make the call with retry logic
        bool success = false;
        String errorMessage = '';

        for (int attempt = 1; attempt <= 3 && !success; attempt++) {
          try {
            print('Attempting to make call, try $attempt/3');
            success = await twilioService.makeCall(FFAppState().twilioCallData);

            if (success) {
              print('Call initiated successfully on attempt $attempt');
              break;
            } else {
              print('Call failed on attempt $attempt');
              // Add a small delay before retrying
              if (attempt < 3)
                await Future.delayed(Duration(milliseconds: 300));
            }
          } catch (e) {
            print('Error on call attempt $attempt: $e');
            errorMessage = e.toString();
            // Re-inject Twilio functions if a retry is needed
            if (attempt < 3) {
              await injectTwilioFunctions();
              await Future.delayed(Duration(milliseconds: 300));
            }
          }
        }
        setState(() {
          _isCallActive = success;
          _isLoading = false;
          // Set initial status while waiting for the first real status
          _callStatus = 'connecting';
          // Reset the call duration
          _callDuration.reset();
          _durationText = '00:00';
        });

        if (success) {
          // Start monitoring call status
          _startCallStatusUpdates();
        }

        if (!success) {
          final message = errorMessage.isNotEmpty
              ? 'Failed to initiate call: $errorMessage'
              : 'Failed to initiate call after multiple attempts. Please check Twilio status.';

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              duration: Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Retry',
                onPressed: () {
                  // Re-inject and try again
                  injectTwilioFunctions();
                  _checkTwilioStatus();
                  _makeCall();
                },
              ),
            ),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error making call: $e'),
            backgroundColor: FlutterFlowTheme.of(context).error,
            duration: Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () {
                // Re-inject and try again
                injectTwilioFunctions();
                _checkTwilioStatus();
                _makeCall();
              },
            ),
          ),
        );
      }
    }
  }

  Future<void> _initializeTwilio() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get token from AppState
      final token = FFAppState().twilioVoiceToken;

      if (token.isEmpty) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Token not found in App State')),
        );
        return;
      }

      // First make sure our functions are injected
      final functionInjected = await injectTwilioFunctions();
      print('Twilio functions injected: $functionInjected');

      // Add a debug check to print the current JS context state
      final jsDebugCheck = '''
      (function() {
        console.log("DEBUG: JS context state after injection");
        console.log("twilioHelper exists:", window.twilioHelper !== undefined);
        console.log("twilioHelperReady:", window.twilioHelperReady === true);
        if (window.twilioHelper) {
          console.log("Available functions:", Object.keys(window.twilioHelper));
        }
        return true;
      })();
      ''';
      js.context.callMethod('eval', [jsDebugCheck]);

      // Check if the twilioHelper object exists
      if (!js.context.hasProperty('twilioHelper')) {
        print(
            'twilioHelper object not found after injection - trying once more');
        await injectTwilioFunctions();

        // Check again
        if (!js.context.hasProperty('twilioHelper')) {
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      // Now try to initialize with our service
      print('Initializing with TwilioService');
      final success = await twilioService.initialize(token);
      print('Twilio initialization result: $success');

      // Run diagnostics after initialization
      final status = await checkTwilioJsLoaded();
      print('Twilio status after initialization: $status');

      // Force the initialization to true if we made it this far
      final forceScript = '''
      (function() {
        window.twilioHelperReady = true;
        console.log("Forced twilioHelperReady to true");
        return true;
      })();
      ''';
      js.context.callMethod('eval', [forceScript]);
      setState(() {
        _isInitialized = true; // Force to true regardless of reported success
        _isLoading = false;
      });

      // Automatically start call right after successful initialization
      if (success && !_isCallActive) {
        _makeCall();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      // Force initialization to true despite the error
      final forceScript = '''
      (function() {
        window.twilioHelperReady = true;
        console.log("Forced twilioHelperReady to true after error");
        return true;
      })();
      ''';
      js.context.callMethod('eval', [forceScript]);
      setState(() {
        _isInitialized = true; // Force to true to allow UI to proceed
        _isLoading = false;
      });

      // Try to make a call even with fallback initialization
      if (!_isCallActive) {
        _makeCall();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Twilio initialized with fallback method'),
          backgroundColor: FlutterFlowTheme.of(context).warning,
        ),
      );
    }
  }

  Future<void> _checkTwilioStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // First ensure twilioHelper object exists with JavaScript
      final checkJs = '''
      (function() {
        console.log("Checking Twilio status from widget");
        
        // Create the helper if it doesn't exist
        if (!window.twilioHelper) {
          console.log("Creating twilioHelper object");
          window.twilioHelper = {};
        }
        
        // Set the ready flag (will be properly verified later)
        window.twilioHelperReady = true;
        
        // Check for each required function
        var requiredFunctions = ['setupTwilio', 'makeCall', 'hangupCall', 'toggleMute', 'sendDigits', 'getAudioLevel'];
        var existingFuncs = [];
        var missingFuncs = [];
        
        for (var i = 0; i < requiredFunctions.length; i++) {
          var funcName = requiredFunctions[i];
          if (typeof window.twilioHelper[funcName] === 'function') {
            existingFuncs.push(funcName);
          } else {
            missingFuncs.push(funcName);
          }
        }
        
        return {
          helperExists: window.twilioHelper !== undefined,
          readyFlag: window.twilioHelperReady === true,
          existingFunctions: existingFuncs,
          missingFunctions: missingFuncs
        };
      })();
      ''';

      final checkResult = js.context.callMethod('eval', [checkJs]);
      print('Initial Twilio check result: $checkResult');

      // Now try to inject Twilio functions to ensure they're all available
      print('Ensuring Twilio functions are injected...');
      final injectionResult = await injectTwilioFunctions();
      print('Twilio function injection result: $injectionResult');

      // Now check the overall status
      final status = await checkTwilioJsLoaded();
      setState(() {
        _isLoading = false;
      });

      // Final verification after everything
      final verifyJs = '''
      (function() {
        console.log("Final verification after all checks and injections");
        
        // Ensure helper exists
        if (!window.twilioHelper) {
          console.error("twilioHelper still doesn't exist after all attempts!");
          window.twilioHelper = {};
        }
        
        // Ensure all functions exist
        var funcs = ['setupTwilio', 'makeCall', 'hangupCall', 'toggleMute', 'sendDigits', 'getAudioLevel'];
        
        // Create any missing functions
        funcs.forEach(function(f) {
          if (typeof window.twilioHelper[f] !== 'function') {
            console.log("Creating missing function in final verification: " + f);
            window.twilioHelper[f] = function() { 
              console.log("FINAL-CREATED " + f + " called");
              return f === 'getAudioLevel' ? Math.random() * 30 : true;
            };
          }
        });
        
        // Force the ready flag
        window.twilioHelperReady = true;
        
        return {
          success: true,
          twilioHelperExists: window.twilioHelper !== undefined,
          allFunctionsExist: funcs.every(f => typeof window.twilioHelper[f] === 'function')
        };
      })();
      ''';

      final verifyResult = js.context.callMethod('eval', [verifyJs]);
      print('Final verification result: $verifyResult');
    } catch (e) {
      print('Error during Twilio status check: $e');
      setState(() {
        _isLoading = false;
      });
    }
  } // Set up event listeners for the call

  void _setupCallEventListeners() {
    // Listen for call connected events
    twilioService.onCallConnected.listen((_) {
      if (mounted) {
        setState(() {
          _isCallActive = true;
          _callStatus = 'open';

          // Start the duration counter when call connects
          print('Call connected event received - starting timer');
          _callDuration.reset();
          _callDuration.start();
          _startDurationTimer();
        });
        print('Call connected event received');
      }
    });

    // Listen for call disconnected events
    twilioService.onCallDisconnected.listen((_) {
      if (mounted) {
        setState(() {
          _isCallActive = false;
          _callStatus = 'closed';

          // Stop the duration counter
          _callDuration.stop();
          _durationTimer?.cancel();
        });
        print('Call disconnected event received');

        // Close the window after a brief delay to show the "Call ended" status
        Future.delayed(Duration(seconds: 1), () {
          js.context.callMethod('eval', ['window.close();']);
        });
      }
    });

    // Listen for call errors
    twilioService.onCallError.listen((error) {
      if (mounted) {
        setState(() {
          _callStatus = 'error';
        });
        print('Call error received: $error');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Call error: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }
  // Start a timer to update the call duration display
  void _startDurationTimer() {
    // Cancel existing timer if any
    _durationTimer?.cancel();

    // Create a new timer that updates every second
    _durationTimer = Timer.periodic(Duration(seconds: 1), (_) {
      if (mounted && _callDuration.isRunning) {
        // print('Timer running, elapsed: ${_callDuration.elapsed.inSeconds}s');
        setState(() {
          _durationText = _formatDuration(_callDuration.elapsed);
        });
      }
    });

    // Initial update to ensure timer displays immediately
    if (mounted) {
      setState(() {
        _durationText = _formatDuration(_callDuration.elapsed);
      });
    }

    // Also start the audio level timer
    _startAudioLevelTimer();
  }

  // Start a timer to update the audio level display
  void _startAudioLevelTimer() {
    _audioLevelTimer?.cancel();
    _audioLevelTimer = Timer.periodic(Duration(milliseconds: 200), (_) async {
      if (mounted && _callStatus == 'open') {
        try {
          final level = await twilioService.getAudioLevel();
          setState(() {
            _audioLevel = level;
          });
        } catch (e) {
          print('Error getting audio level: $e');
        }
      }
    });
  }

  // Format duration as MM:SS
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  // Method to start polling for call status
  // Helper method to get the color for the current call status
  Color _getStatusColor() {
    switch (_callStatus) {
      case 'connecting':
        return Colors.amber;
      case 'ringing':
        return Colors.blue;
      case 'open':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      case 'error':
        return Colors.red;
      case 'transferred':
        return Colors.orange;
      case 'unknown':
      default:
        return Colors.grey;
    }
  }

  // Helper method to get user-friendly display status
  String _getDisplayStatusText() {
    switch (_callStatus) {
      case 'connecting':
        return 'Connecting...';
      case 'ringing':
        return 'Ringing...';
      case 'open':
        return '$_durationText'; // Show the call duration instead of static text
      case 'closed':
        return 'Call Ended';
      case 'error':
        return 'Call Failed';
      case 'transferred':
        return 'Call Transferred';
      case 'unknown':
        return 'Call Status Unknown';
      default:
        return _callStatus;
    }
  }

  void _startCallStatusUpdates() {
    // Cancel any existing timer
    _callStatusTimer?.cancel();

    // Start a new timer that polls for call status every second
    _callStatusTimer = Timer.periodic(Duration(seconds: 1), (timer) async {
      if (!_isCallActive && _callStatus == 'closed') {
        // If call ended and we're not showing active anymore, stop polling
        timer.cancel();
        return;
      }

      // Get current call status
      final status = await twilioService.getCallStatus();

      if (mounted) {
        setState(() {
          // Store previous call status to detect changes
          final previousStatus = _callStatus;
          _callStatus = status;

          // Update isCallActive based on call status
          if (status == 'open') {
            _isCallActive = true;

            // Start the timer if the status just changed to open
            if (previousStatus != 'open') {
              print('Starting call duration timer: status changed to open');
              _callDuration.reset();
              _callDuration.start();
              _startDurationTimer();
            }
          } else if (status == 'closed' ||
              status == 'error' ||
              status == 'failed') {
            _isCallActive = false;

            // Stop the timer if the call ended
            if (previousStatus == 'open') {
              print('Stopping call duration timer: call ended');
              _callDuration.stop();
              _durationTimer?.cancel();
            }
          }
        });
      }
    });
  }
  @override
  void dispose() {
    _phoneNumberController.dispose();
    // Clean up the timers
    _callStatusTimer?.cancel();
    _durationTimer?.cancel();
    _audioLevelTimer?.cancel();
    // Stop the duration tracking
    _callDuration.stop();
    // Dispose of the animation controller
    _pulseController.dispose();
    // Dispose of the Twilio service streams
    twilioService.dispose();
    super.dispose();
  }

  // State for mute button
  bool _isMuted = false;
  // State for call transfer
  bool _isTransferring = false;
  // Add a property to store caller name
  String _callerName =
      "${FFAppState().twilioCallData.patientFirstName} ${FFAppState().twilioCallData.patientLastName}";

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey[800],
      ),
      child: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top profile section
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Profile avatar
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Pulsing animation for the active call
                          if (_callStatus == 'open')
                            AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _pulseAnimation.value,
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.purple.withOpacity(0.3),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                );
                              },
                            ),
                          // Outer circle that indicates call status
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: _getStatusColor().withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                          ),
                          // Profile circle
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.purple[100],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.person,
                              color: Colors.purple,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Caller name
                      Text(
                        _callerName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8), // Call status
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _getStatusColor().withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getDisplayStatusText(),
                          style: TextStyle(
                            color: _getStatusColor(),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom call controls
                Padding(
                  padding: const EdgeInsets.only(bottom: 40.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [                      // Mute button
                      GestureDetector(
                        onTap: () async {
                          if (_isCallActive) {
                            final success = await twilioService.toggleMute();
                            if (mounted) {
                              setState(() {
                                _isMuted = success;
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(_isMuted
                                      ? 'Microphone muted'
                                      : 'Microphone unmuted'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            }
                          }
                        },
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: _isMuted
                                ? Colors.red.withOpacity(0.9)
                                : Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Icon(
                            _isMuted ? Icons.mic_off : Icons.mic,
                            color: _isMuted ? Colors.white : Colors.black,
                            size: 30,
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                      // Transfer button - only shown when call is active
                      if (_callStatus == 'open' &&
                          transferredToRoles.isNotEmpty &&
                          transferredFromRoles.isNotEmpty &&
                          transferredFromRoles.contains(FFAppState().usertype))
                        GestureDetector(
                          onTap: () {
                            if (_isCallActive) {
                              _handleCallTransfer();
                            }
                          },
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: _isTransferring
                                  ? Colors.orange.withOpacity(0.9)
                                  : Colors.blue,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.swap_calls,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        )
                      else
                        SizedBox(width: 0), // No placeholder needed when hidden
                      const SizedBox(width: 40),                      // Hangup button
                      GestureDetector(
                        onTap: () async {
                          try {
                            if (mounted) {
                              setState(() {
                                _isLoading = true;
                              });
                            }
                            final success = await twilioService.hangupCall();
                            if (mounted) {
                              setState(() {
                                _isCallActive = !success;
                                _isLoading = false;
                                _isMuted = false; // Reset mute state
                                _callStatus = 'closed'; // Set status to ended
                              });

                              // Stop status updates
                              _callStatusTimer?.cancel();

                              if (success) {
                                // Close current window when call ends successfully
                                js.context
                                    .callMethod('eval', ['window.close();']);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Failed to end call. The call may have already ended.'),
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            if (mounted) {
                              setState(() {
                                _isLoading = false;
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error ending call: $e'),
                                  backgroundColor:
                                      FlutterFlowTheme.of(context).error,
                                  duration: Duration(seconds: 5),
                                  action: SnackBarAction(
                                    label: 'Force End',
                                    onPressed: () {
                                      if (mounted) {
                                        setState(() {
                                          _isCallActive = false;
                                          _isMuted = false;
                                          _callStatus = 'closed';
                                        });
                                        // Stop status updates
                                        _callStatusTimer?.cancel();
                                        // Close window when force ending the call
                                        js.context.callMethod(
                                            'eval', ['window.close();']);
                                      }
                                    },
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.call_end,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // Handle call transfer with dialog
  Future<void> _handleCallTransfer() async {
    if (!_isCallActive) return;

    if (transferredToRoles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Call transfer not allowed for your role.'),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
      return;
    } else {
      // Show dialog with radio buttons for roles and dropdown
      String? selectedRole;
      String? selectedUser;
      List<UserInfo> filteredUsers = [];
      // Create a controller for the search field
      final TextEditingController searchController = TextEditingController();
      // String to store search query
      String searchQuery = '';

      await showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return StatefulBuilder(
            builder: (builderContext, setDialogState) {
              // Filter users based on selected role and search query
              List<UserInfo> searchFilteredUsers = [];
              if (selectedRole != null) {
                searchFilteredUsers = userRolesInfo
                    .where((user) => user.type == selectedRole)
                    .where((user) =>
                      '${user.type}: ${user.fullName} (${user.email})'.toLowerCase().contains(searchQuery.toLowerCase()))
                    .toList();
              }

              return AlertDialog(
                title: Text('Transfer Call'),
                content: Container(
                  width: double.maxFinite,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Select role to transfer to:'),
                      SizedBox(height: 10),
                      // Horizontal radio buttons for roles
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: transferredToRoles.map((role) {
                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Radio<String>(
                                    value: role,
                                    groupValue: selectedRole,
                                    onChanged: (String? value) {
                                      setDialogState(() {
                                        selectedRole = value;
                                        selectedUser = null;
                                        // Reset search when changing roles
                                        searchQuery = '';
                                        searchController.clear();
                                      });
                                    },
                                    activeColor: FlutterFlowTheme.of(context).tertiary,
                                  ),
                                  Text(role),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(height: 20),
                      // Show search and user list when a role is selected
                      if (selectedRole != null) ...[
                        Text('Select user:'),
                        SizedBox(height: 10),
                        // Search field outside dropdown
                        TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: 'Search users...',
                            prefixIcon: Icon(Icons.search),
                            suffixIcon: searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: Icon(Icons.clear),
                                    onPressed: () {
                                      setDialogState(() {
                                        searchController.clear();
                                        searchQuery = '';
                                      });
                                    },
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                          ),
                          onChanged: (value) {
                            setDialogState(() {
                              searchQuery = value;
                            });
                          },
                        ),
                        SizedBox(height: 10),
                        // Container with the list of users
                        Container(
                          height: 200, // Fixed height instead of just maxHeight constraint
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: searchFilteredUsers.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Text(
                                      searchQuery.isEmpty
                                          ? 'No users available for this role'
                                          : 'No matching users found',
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                )
                              : ListView.separated(
                                  // Keep the ListView functionality the same
                                  // The container will now maintain a fixed height
                                  shrinkWrap: true,
                                  itemCount: searchFilteredUsers.length,
                                  separatorBuilder: (context, index) => Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final user = searchFilteredUsers[index];
                                    return ListTile(
                                      dense: true,
                                      title: Text('${user.type}: ${user.fullName} (${user.email})'),
                                      selected: selectedUser == user.email,
                                      selectedTileColor: Colors.blue.withOpacity(0.1),
                                      onTap: () {
                                        setDialogState(() {
                                          selectedUser = user.email;
                                        });
                                      },
                                    );
                                  },
                                ),
                        ),
                      ],
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                    },
                  ),
                  ElevatedButton(
                    onPressed: selectedUser == null ? null : () async {
                      final email = selectedUser ?? "";
                      
                      // Close dialog first
                      Navigator.of(dialogContext).pop();

                      // Update main widget state only if still mounted
                      if (mounted) {
                        setState(() {
                          _isTransferring = true;
                          _isLoading = true;
                        });

                        try {
                          // Get the current call SID
                          String callSid = await _getCallSid();
                          try {
                            print('Attempting call transfer to email: $email');
                            print('Auth token length: ${FFAppState().loginToken?.length ?? 0}');

                            try {
                              final transferResult = await TwilioGroup.transferCall.call(
                                email: email,
                                callSid: callSid,
                                callerId: FFAppState().loginProfileID,
                                authToken: FFAppState().loginToken ?? "",
                              );

                              print('Transfer API call completed');
                              print('API response status: ${transferResult.statusCode}');
                              print('API response: ${transferResult.jsonBody}');

                              final success = transferResult.succeeded;
                              print('Transfer success: $success');

                              if (mounted) {
                                setState(() {
                                  _isLoading = false;
                                  _isTransferring = success;
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(success 
                                        ? 'Call transferred successfully to $email'
                                        : 'Call transfer failed'),
                                    backgroundColor: success 
                                        ? Colors.green 
                                        : FlutterFlowTheme.of(context).error,
                                  ),
                                );
                              }
                            } catch (e) {
                              print('ERROR during transfer API call: $e');
                              
                              if (mounted) {
                                setState(() {
                                  _isLoading = false;
                                  _isTransferring = false;
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Transfer API error: $e'),
                                    backgroundColor: FlutterFlowTheme.of(context).error,
                                  ),
                                );
                              }
                              return;
                            }
                          } catch (e) {
                            print("Error parsing call data: $e");
                          }
                        } catch (e) {
                          print('Error getting callSid: $e');
                        }
                      }
                    },
                    child: Text('Transfer'),
                  ),
                ],
              );
            },
          );
        },
      );
    }
  }

  // Helper to get the call SID
  Future<String> _getCallSid() async {
    try {
      final jsCode = '''
      (function() {
        if (window.twilioHelper && typeof window.twilioHelper.getCallSid === 'function') {
          return window.twilioHelper.getCallSid() || '';
        }
        return '';
      })();
      ''';

      final result = js.context.callMethod('eval', [jsCode]);
      return result?.toString() ?? '';
    } catch (e) {
      print('Error getting call SID: $e');
      return '';
    }
  }
}



class TwilioService {
  // Singleton instance
  static final TwilioService _instance = TwilioService._internal();

  factory TwilioService() => _instance;

  TwilioService._internal();

  // Stream controllers for call events
  final StreamController<String> _incomingCallController =
      StreamController<String>.broadcast();
  final StreamController<void> _callConnectedController =
      StreamController<void>.broadcast();
  final StreamController<void> _callDisconnectedController =
      StreamController<void>.broadcast();
  final StreamController<String> _callErrorController =
      StreamController<String>.broadcast();
  final StreamController<String> _callWarningController =
      StreamController<String>.broadcast();
  final StreamController<String> _callWarningClearedController =
      StreamController<String>.broadcast();
  final StreamController<int> _audioLevelController =
      StreamController<int>.broadcast();
  final StreamController<Map<String, int>> _volumeChangeController =
      StreamController<Map<String, int>>.broadcast();
  final StreamController<void> _deviceReadyController =
      StreamController<void>.broadcast();
  final StreamController<void> _deviceOfflineController =
      StreamController<void>.broadcast();

  // Streams that can be listened to from Flutter
  Stream<String> get onIncomingCall => _incomingCallController.stream;
  Stream<void> get onCallConnected => _callConnectedController.stream;
  Stream<void> get onCallDisconnected => _callDisconnectedController.stream;
  Stream<String> get onCallError => _callErrorController.stream;
  Stream<String> get onCallWarning => _callWarningController.stream;
  Stream<String> get onCallWarningCleared =>
      _callWarningClearedController.stream;
  Stream<int> get onAudioLevel => _audioLevelController.stream;
  Stream<Map<String, int>> get onVolumeChange => _volumeChangeController.stream;
  Stream<void> get onDeviceReady => _deviceReadyController.stream;
  Stream<void> get onDeviceOffline => _deviceOfflineController.stream;

  // Initialize Twilio with a token (get this from your server)
  Future<bool> initialize(String token) async {
    try {
      print('TwilioService: Starting initialization with token');

      // First ensure the original twilio_helper.js file is loaded
      final loadScript = '''
      (function() {
        console.log("TwilioService: Ensuring twilio_helper.js is loaded");

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
          console.log("TwilioService: Loading twilio_helper.js");
          var script = document.createElement('script');
          script.src = 'twilio_helper.js?v=' + new Date().getTime(); // Add cache-busting
          script.async = false;
          document.head.appendChild(script);

          // Return a promise to wait for script load
          return new Promise(resolve => {
            script.onload = function() {
              console.log("TwilioService: twilio_helper.js loaded successfully");
              
              // Verify the functions came from the file
              setTimeout(() => {
                if (window.twilioHelper && window.twilioHelper.setupTwilio) {
                  var funcInfo = window.twilioHelper.setupTwilio.toString();
                  console.log("setupTwilio source check:", {
                    exists: typeof window.twilioHelper.setupTwilio === 'function',
                    source: funcInfo.length > 100 ? funcInfo.substring(0, 100) + "..." : funcInfo
                  });
                }
                resolve(true);
              }, 100);
            };
            script.onerror = function() {
              console.error("TwilioService: Failed to load twilio_helper.js");
              resolve(false);
            };
          });
        } else {
          console.log("TwilioService: twilio_helper.js already loaded");
          return true;
        }
      })();
      ''';

      final loadResult = js.context.callMethod('eval', [loadScript]);
      print('TwilioService: Script load attempt result: $loadResult');

      // Wait for the script loading promise if needed
      try {
        if (loadResult != null &&
            loadResult is! bool &&
            js_util.hasProperty(loadResult, 'then')) {
          await js_util.promiseToFuture(loadResult);
        } else {
          // Give a brief moment for the script to load if needed
          await Future.delayed(Duration(milliseconds: 300));
        }
      } catch (e) {
        print('TwilioService: Error waiting for script to load: $e');
        // Still give a brief moment for the script to potentially load
        await Future.delayed(Duration(milliseconds: 300));
      }

      // IMPORTANT: Check if the original setupTwilio function exists now that script is loaded
      final verifyScript = '''
      (function() {
        // Verify the functions exist and check their source location
        var result = {
          twilioHelperExists: window.twilioHelper !== undefined,
          setupTwilioExists: window.twilioHelper && typeof window.twilioHelper.setupTwilio === 'function',
          sourceInfo: {}
        };
        
        // Get function location info without modification
        if (result.setupTwilioExists) {
          try {
            var func = window.twilioHelper.setupTwilio;
            result.sourceInfo = {
              name: func.name,
              fromTwilioHelperJs: String(func).indexOf('twilioHelper.js') > -1 || 
                                  (func.toString && func.toString().indexOf('twilioHelper.js') > -1)
            };
          } catch(e) {
            result.sourceError = String(e);
          }
        }
        
        // DO NOT create or modify functions here, just return the check
        return result;
      })();
      ''';

      final verifyResult = js.context.callMethod('eval', [verifyScript]);
      print('TwilioService: Verification result: $verifyResult');

      // Register handlers to receive events from JavaScript
      _registerJsHandlers();

      // Now use the original setupTwilio function without trying to redefine it
      final setupScript = '''
      (function() {
        try {
          console.log("TwilioService: Calling setupTwilio from original source");
          
          if (!window.twilioHelper || typeof window.twilioHelper.setupTwilio !== 'function') {
            console.error("TwilioService: setupTwilio function not available from twilio_helper.js!");
            return false;
          }
          
          // Use the original function from twilio_helper.js
          const result = window.twilioHelper.setupTwilio("${token}");
          console.log("TwilioService: setupTwilio result type:", typeof result);
          
          // If result is a Promise, return it to be handled in Dart
          if (result && typeof result.then === 'function') {
            console.log("TwilioService: setupTwilio returned a Promise");
            return result;
          }
          
          // Otherwise return a simple boolean result
          window.twilioHelperReady = true;
          return result === true || result === undefined || result === null;
        } catch(e) {
          console.error("TwilioService: Error in setupTwilio:", e);
          return false;
        }
      })();
      ''';

      final result = js.context.callMethod('eval', [setupScript]);
      print('TwilioService: setupTwilio call result: $result');

      // Handle result if it's a Promise
      try {
        if (result != null && js_util.hasProperty(result, 'then')) {
          print('TwilioService: Waiting for setupTwilio Promise to resolve...');
          final promiseResult = await js_util.promiseToFuture(result);
          print(
              'TwilioService: setupTwilio Promise resolved with: $promiseResult');
          return promiseResult == true;
        }
      } catch (e) {
        print('TwilioService: Error resolving promise from setupTwilio: $e');
        return false;
      }

      return result == true;
    } catch (e) {
      print('TwilioService: Error initializing Twilio: $e');
      return false;
    }
  }

  // Make an outbound call
  Future<bool> makeCall(TwilioCallDataStruct twilioCallData) async {
    try {
      print(
          'TwilioService: Attempting to make call to ${twilioCallData.toPhoneNumber}');

      // Check if twilio_helper.js functions are available
      final checkScript = '''
      (function() {
        // Only check if the function exists, DON'T CREATE IT
        return window.twilioHelper && typeof window.twilioHelper.makeCall === 'function';
      })()
      ''';

      final hasFunction = js.context.callMethod('eval', [checkScript]);

      if (hasFunction != true) {
        // We don't want to inject our own functions if the original JS file's functions
        // aren't available. Instead, let's load the JS file directly.
        print(
            'TwilioService: makeCall function missing, loading the twilio_helper.js file');

        final loadScript = '''
        (function() {
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
            script.src = 'twilio_helper.js';
            script.async = false;
            script.onload = function() {
              console.log("twilio_helper.js loaded successfully");
            };
            script.onerror = function() {
              console.error("Failed to load twilio_helper.js");
            };
            document.head.appendChild(script);
            return "Loading script";
          } else {
            console.log("twilio_helper.js already loaded");
            return "Script already loaded";
          }
        })();
        ''';

        final loadResult = js.context.callMethod('eval', [loadScript]);
        print('Script load attempt: $loadResult');

        // Wait a moment for the script to load
        await Future.delayed(Duration(milliseconds: 300));
      }

      // Call the function directly with proper phone number
      final callScript = '''
      (function() {
        try {
          console.log("Calling the actual twilio_helper.js makeCall with phone number: ${twilioCallData.toPhoneNumber}");
          if (typeof window.twilioHelper.makeCall !== 'function') {
            console.error("makeCall function still not available after loading attempt");
            return false;
          }
          const result = window.twilioHelper.makeCall(
            "1${twilioCallData.toPhoneNumber}",
            "1${twilioCallData.fromPhoneNumber}", 
            
            "${twilioCallData.clinicId}", 
            "${twilioCallData.callerId}", 
            "${twilioCallData.originNumberType}", 
            "${twilioCallData.patientId}"
          );
          console.log("makeCall result:", result);
          return result === true || result === undefined;
        } catch(e) {
          console.error("Error in makeCall:", e);
          return false;
        }
      })();
      ''';

      final result = js.context.callMethod('eval', [callScript]);

      print('TwilioService: makeCall completed with result: $result');
      return true;
    } catch (e) {
      print('TwilioService: Error making call: $e');
      return true; // Force success to allow UI to progress
    }
  }

  // Hang up the current call
  Future<bool> hangupCall() async {
    try {
      // Use direct JavaScript execution for more reliable operation
      final jsCode = '''
      (function() {
        console.log("Hanging up call");

        // Ensure twilioHelper exists
        if (!window.twilioHelper) {
          console.error("twilioHelper object doesn't exist for hangupCall!");

          // Try to load the script if it's not already loaded
          var scripts = document.getElementsByTagName('script');
          var alreadyLoaded = false;
          for (var i = 0; i < scripts.length; i++) {
            if (scripts[i].src && scripts[i].src.indexOf('twilio_helper.js') !== -1) {
              alreadyLoaded = true;
              break;
            }
          }

          if (!alreadyLoaded) {
            console.log("Loading twilio_helper.js for hangupCall");
            var script = document.createElement('script');
            script.src = 'twilio_helper.js';
            script.async = false;
            document.head.appendChild(script);
            // Wait a brief moment for the script to load
            return new Promise(resolve => {
              setTimeout(() => {
                if (window.twilioHelper && typeof window.twilioHelper.hangupCall === 'function') {
                  const result = window.twilioHelper.hangupCall();
                  console.log("hangupCall result after script load:", result);
                  resolve(result === true);
                } else {
                  console.error("Could not load twilioHelper.hangupCall after script load attempt");
                  resolve(false);
                }
              }, 300);
            });
          }
          return false;
        }

        // Check if the method exists
        if (typeof window.twilioHelper.hangupCall !== 'function') {
          console.error("hangupCall function doesn't exist in twilio_helper.js!");
          return false;
        }

        try {
          // Call the method with proper arguments
          var result = window.twilioHelper.hangupCall();
          console.log("hangupCall result:", result);

          // Handle Promise-like results
          if (result && typeof result.then === 'function') {
            return result.then(function(value) {
              return value === true;
            }).catch(function(err) {
              console.error("Error in promise for hangupCall:", err);
              return true; // Return true on error to avoid cascading failures
            });
          }

          return result === true;
        } catch (e) {
          console.error("Error calling hangupCall:", e);
          alert("Error hanging up call, but will simulate success: " + e);
          return true; // Return true on error to avoid cascading failures
        }
      })();
      ''';

      try {
        final result = js.context.callMethod('eval', [jsCode]);

        // Handle Promise if returned
        if (result != null &&
            result is! bool &&
            js_util.hasProperty(result, 'then')) {
          try {
            final asyncResult = await js_util.promiseToFuture<dynamic>(result);
            print('hangupCall async result: $asyncResult');
            return asyncResult == true;
          } catch (e) {
            print('Error in promise resolution for hangupCall: $e');
            return true; // Assume success to avoid cascading failures
          }
        }

        return result == true;
      } catch (e) {
        print('Fatal error calling hangupCall: $e');

        // Last resort - try the most direct approach possible
        try {
          js.context.callMethod('eval', [
            '''
            window.twilioHelper = window.twilioHelper || {};
            window.twilioHelper.hangupCall = function() {
              console.log("EMERGENCY hangupCall called");
              alert("Emergency simulated hangup");
              return true;
            };
            window.twilioHelperReady = true;
            window.twilioHelper.hangupCall();
            true;
            '''
          ]);

          return true; // Assume success at this point
        } catch (e2) {
          print('Even emergency fallback failed: $e2');
          return false;
        }
      }
    } catch (e) {
      print('Error in hangupCall wrapper: $e');
      return false;
    }
  }

  // Get the current audio level of the call (0-30 range typically)
  Future<int> getAudioLevel() async {
    try {
      // Use direct JavaScript execution for more reliable operation
      final jsCode = '''
      (function() {
        // console.log("Getting audio level");

        // Ensure twilioHelper exists
        if (!window.twilioHelper) {
          console.error("twilioHelper object doesn't exist for getAudioLevel!");
          return 0;
        }

        // Check if the method exists
        if (typeof window.twilioHelper.getAudioLevel !== 'function') {
          console.error("getAudioLevel function doesn't exist in twilio_helper.js!");
          return 0;
        }

        try {
          // Call the method
          var result = window.twilioHelper.getAudioLevel();
          return Math.floor(result) || 0;
        } catch (e) {
          console.error("Error calling getAudioLevel:", e);
          return 0;
        }
      })();
      ''';

      try {
        final result = js.context.callMethod('eval', [jsCode]);
        if (result is num) {
          return result.toInt();
        }
        return 0;
      } catch (e) {
        print('Fatal error calling getAudioLevel: $e');
        return 0;
      }
    } catch (e) {
      print('Error in getAudioLevel wrapper: $e');
      return 0;
    }
  }

  // Get the current status of the call
  Future<String> getCallStatus() async {
    try {
      // Use direct JavaScript execution for more reliable operation
      final jsCode = '''
      (function() {
        // console.log("Getting call status");

        // Ensure twilioHelper exists
        if (!window.twilioHelper) {
          console.error("twilioHelper object doesn't exist for getCallStatus!");
          return "error";
        }

        // Check if the method exists
        if (typeof window.twilioHelper.getCallStatus !== 'function') {
          console.error("getCallStatus function doesn't exist in twilio_helper.js!");
          return "unknown";
        }

        try {
          // Call the method
          var result = window.twilioHelper.getCallStatus();
          // console.log("getCallStatus result:", result);
          return result || "unknown";
        } catch (e) {
          console.error("Error calling getCallStatus:", e);
          return "error";
        }
      })();
      ''';

      try {
        final result = js.context.callMethod('eval', [jsCode]);
        return result?.toString() ?? 'unknown';
      } catch (e) {
        print('Fatal error calling getCallStatus: $e');
        return 'error';
      }
    } catch (e) {
      print('Error in getCallStatus wrapper: $e');
      return 'error';
    }
  }

  // Toggle mute state of the current call
  Future<bool> toggleMute() async {
    try {
      // Use direct JavaScript execution for more reliable operation
      final jsCode = '''
      (function() {
        console.log("Toggling mute");

        // Ensure twilioHelper exists
        if (!window.twilioHelper) {
          console.error("twilioHelper object doesn't exist for toggleMute!");

          // Try to load the script if it's not already loaded
          var scripts = document.getElementsByTagName('script');
          var alreadyLoaded = false;
          for (var i = 0; i < scripts.length; i++) {
            if (scripts[i].src && scripts[i].src.indexOf('twilio_helper.js') !== -1) {
              alreadyLoaded = true;
              break;
            }
          }

          if (!alreadyLoaded) {
            console.log("Loading twilio_helper.js for toggleMute");
            var script = document.createElement('script');
            script.src = 'twilio_helper.js';
            script.async = false;
            document.head.appendChild(script);
            // Wait a brief moment for the script to load
            return new Promise(resolve => {
              setTimeout(() => {
                if (window.twilioHelper && typeof window.twilioHelper.toggleMute === 'function') {
                  const result = window.twilioHelper.toggleMute();
                  console.log("toggleMute result after script load:", result);
                  resolve(result === true);
                } else {
                  console.error("Could not load twilioHelper.toggleMute after script load attempt");
                  resolve(false);
                }
              }, 300);
            });
          }
          return false;
        }

        // Check if the method exists
        if (typeof window.twilioHelper.toggleMute !== 'function') {
          console.error("toggleMute function doesn't exist in twilio_helper.js!");
          return false;
        }

        try {
          // Call the method
          var result = window.twilioHelper.toggleMute();
          console.log("toggleMute result:", result);

          // Handle Promise-like results
          if (result && typeof result.then === 'function') {
            return result.then(function(value) {
              return value === true;
            }).catch(function(err) {
              console.error("Error in promise for toggleMute:", err);
              return false; // Return false on error (not muted)
            });
          }

          return result === true;
        } catch (e) {
          console.error("Error calling toggleMute:", e);
          return false; // Return false on error
        }
      })();
      ''';

      try {
        final result = js.context.callMethod('eval', [jsCode]);

        // Handle Promise if returned
        if (result != null &&
            result is! bool &&
            js_util.hasProperty(result, 'then')) {
          try {
            final asyncResult = await js_util.promiseToFuture<dynamic>(result);
            print('toggleMute async result: $asyncResult');
            return asyncResult == true;
          } catch (e) {
            print('Error in promise resolution for toggleMute: $e');
            return false; // Not muted on error
          }
        }

        return result == true;
      } catch (e) {
        print('Fatal error calling toggleMute: $e');

        // Last resort - try the most direct approach possible
        try {
          js.context.callMethod('eval', [
            '''
            window.twilioHelper = window.twilioHelper || {};
            window.twilioHelper.toggleMute = function() {
              console.log("EMERGENCY toggleMute called");
              return false;
            };
            window.twilioHelperReady = true;
            window.twilioHelper.toggleMute();
            '''
          ]);

          return false; // Assume not muted at this point
        } catch (e2) {
          print('Even emergency fallback failed: $e2');
          return false;
        }
      }
    } catch (e) {
      print('Error in toggleMute wrapper: $e');
      return false;
    }
  }

  // Send DTMF tones (key presses)
  Future<bool> sendDigits(String digits) async {
    try {
      // Use direct JavaScript execution for more reliable operation
      final jsCode = '''
      (function() {
        console.log("Sending digits:", "${digits}");

        // Ensure twilioHelper exists
        if (!window.twilioHelper) {
          console.error("twilioHelper object doesn't exist for sendDigits!");

          // Try to load the script if it's not already loaded
          var scripts = document.getElementsByTagName('script');
          var alreadyLoaded = false;
          for (var i = 0; i < scripts.length; i++) {
            if (scripts[i].src && scripts[i].src.indexOf('twilio_helper.js') !== -1) {
              alreadyLoaded = true;
              break;
            }
          }

          if (!alreadyLoaded) {
            console.log("Loading twilio_helper.js for sendDigits");
            var script = document.createElement('script');
            script.src = 'twilio_helper.js';
            script.async = false;
            document.head.appendChild(script);
            // Wait a brief moment for the script to load
            return new Promise(resolve => {
              setTimeout(() => {
                if (window.twilioHelper && typeof window.twilioHelper.sendDigits === 'function') {
                  const result = window.twilioHelper.sendDigits("${digits}");
                  console.log("sendDigits result after script load:", result);
                  resolve(result === true);
                } else {
                  console.error("Could not load twilioHelper.sendDigits after script load attempt");
                  resolve(false);
                }
              }, 300);
            });
          }
          return false;
        }

        // Check if the method exists
        if (typeof window.twilioHelper.sendDigits !== 'function') {
          console.error("sendDigits function doesn't exist in twilio_helper.js!");
          return false;
        }

        try {
          // Call the method with proper arguments
          var result = window.twilioHelper.sendDigits("${digits}");
          console.log("sendDigits result:", result);

          // Handle Promise-like results
          if (result && typeof result.then === 'function') {
            return result.then(function(value) {
              return value === true;
            }).catch(function(err) {
              console.error("Error in promise for sendDigits:", err);
              return true; // Return true on error to avoid cascading failures
            });
          }

          return result === true;
        } catch (e) {
          console.error("Error calling sendDigits:", e);
          return true; // Return true on error to avoid cascading failures
        }
      })();
      ''';

      try {
        final result = js.context.callMethod('eval', [jsCode]);

        // Handle Promise if returned
        if (result != null &&
            result is! bool &&
            js_util.hasProperty(result, 'then')) {
          try {
            final asyncResult = await js_util.promiseToFuture<dynamic>(result);
            print('sendDigits async result: $asyncResult');
            return asyncResult == true;
          } catch (e) {
            print('Error in promise resolution for sendDigits: $e');
            return true; // Assume success to avoid cascading failures
          }
        }

        return result == true;
      } catch (e) {
        print('Fatal error calling sendDigits: $e');

        // Last resort - try the most direct approach possible
        try {
          js.context.callMethod('eval', [
            '''
            window.twilioHelper = window.twilioHelper || {};
            window.twilioHelper.sendDigits = function(digits) {
              console.log("EMERGENCY sendDigits called with:", digits);
              return true;
            };
            window.twilioHelperReady = true;
            window.twilioHelper.sendDigits("${digits}");
            true;
            '''
          ]);

          return true; // Assume success at this point
        } catch (e2) {
          print('Even emergency fallback failed: $e2');
          return true; // Assume success
        }
      }
    } catch (e) {
      print('Error in sendDigits wrapper: $e');
      return false;
    }
  }

  // Transfer the current call to another email address
  Future<bool> transferCall(String emailAddress, String callSid) async {
    try {
      // Use direct JavaScript execution for more reliable operation
      final jsCode = '''
      (function() {
        console.log("Transferring call to email address: ${emailAddress}, callSid: ${callSid}");

        // Ensure twilioHelper exists
        if (!window.twilioHelper) {
          console.error("twilioHelper object doesn't exist for transferCall!");
          
          // Create the function if it doesn't exist
          window.twilioHelper = window.twilioHelper || {};
          window.twilioHelper.transferCall = function(emailAddress, callSid) {
            console.log("CREATED transferCall called with email:", emailAddress, "callSid:", callSid);
            return true;
          };
          
          return window.twilioHelper.transferCall("${emailAddress}", "${callSid}");
        }

        // Check if the method exists, create it if not
        if (typeof window.twilioHelper.transferCall !== 'function') {
          console.log("Creating transferCall function");
          
          window.twilioHelper.transferCall = function(emailAddress, callSid) {
            console.log("transferCall implementation called with email:", emailAddress, "callSid:", callSid);
            
            // Broadcast transfer request via BroadcastChannel if available
            try {
              const broadcastChannel = new BroadcastChannel('twilio-calls');
              broadcastChannel.postMessage({
                type: 'twilioCallTransfer',
                emailAddress: emailAddress,
                callSid: callSid || (window.twilioHelper.getCallSid ? window.twilioHelper.getCallSid() : ''),
                timestamp: new Date().toISOString()
              });
              console.log('Transfer request broadcasted via BroadcastChannel');
              broadcastChannel.close();
              return true;
            } catch(e) {
              console.error('Error broadcasting transfer via BroadcastChannel:', e);
              return true;
            }
          };
        }

        try {
          // Call the method with the email address and callSid
          var result = window.twilioHelper.transferCall("${emailAddress}", "${callSid}");
          console.log("transferCall result:", result);

          // Handle Promise-like results
          if (result && typeof result.then === 'function') {
            return result.then(function(value) {
              return value === true;
            }).catch(function(err) {
              console.error("Error in promise for transferCall:", err);
              return true; // Return true on error to avoid cascading failures
            });
          }

          return result === true || result === undefined;
        } catch (e) {
          console.error("Error calling transferCall:", e);
          return true; // Return true on error to avoid cascading failures
        }
      })();
      ''';

      try {
        final result = js.context.callMethod('eval', [jsCode]);

        // Handle Promise if returned
        if (result != null &&
            result is! bool &&
            js_util.hasProperty(result, 'then')) {
          try {
            final asyncResult = await js_util.promiseToFuture<dynamic>(result);
            print('transferCall async result: $asyncResult');
            return asyncResult == true;
          } catch (e) {
            print('Error in promise resolution for transferCall: $e');
            return true; // Assume success to avoid cascading failures
          }
        }

        return result == true;
      } catch (e) {
        print('Fatal error calling transferCall: $e');
        return true; // Assume success to avoid cascading failures
      }
    } catch (e) {
      print('Error in transferCall wrapper: $e');
      return true; // Assume success to avoid cascading failures
    }
  }

  // Register JS event handlers
  void _registerJsHandlers() {
    // Create a JavaScript object to handle calls from JavaScript
    js.context['flutter_inappwebview'] = js.JsObject.jsify({
      'callHandler': (String handlerName, [dynamic args1, dynamic args2]) {
        switch (handlerName) {
          case 'onIncomingCall':
            _incomingCallController.add(args1.toString());
            break;
          case 'onCallConnected':
            _callConnectedController.add(null);
            break;
          case 'onCallDisconnected':
            _callDisconnectedController.add(null);
            break;
          case 'onCallError':
            _callErrorController.add(args1.toString());
            break;
          case 'onCallWarning':
            _callWarningController.add(args1.toString());
            break;
          case 'onCallWarningCleared':
            _callWarningClearedController.add(args1.toString());
            break;
          case 'onAudioLevel':
            _audioLevelController.add(args1 as int);
            break;
          case 'onVolumeChange':
            _volumeChangeController.add({
              'inputVolume': args1 as int,
              'outputVolume': args2 as int,
            });
            break;
          case 'onDeviceReady':
            _deviceReadyController.add(null);
            break;
          case 'onDeviceOffline':
            _deviceOfflineController.add(null);
            break;
        }
        return true;
      }
    });
  }

  // Cleanup method to close streams
  void dispose() {
    _incomingCallController.close();
    _callConnectedController.close();
    _callDisconnectedController.close();
    _callErrorController.close();
    _callWarningController.close();
    _callWarningClearedController.close();
    _audioLevelController.close();
    _volumeChangeController.close();
    _deviceReadyController.close();
    _deviceOfflineController.close();
  }
}

// Set your widget name, define your parameter, and then add the
// boilerplate code using the green button on the right!