// filepath: c:\Users\DELL\StudioProjects\pep\lib\custom_code\widgets\twilio_incoming_call_dialog.dart
// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';

// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'dart:js' as js;

class TwilioIncomingCallDialog extends StatefulWidget {
  const TwilioIncomingCallDialog({
    Key? key,
    required this.callerName,
    required this.callerNumber,
    required this.onAccept,
    required this.onReject,
    this.callSid,
    this.backgroundService,
    this.vibratePattern = const [500, 1000, 500, 1000],
  }) : super(key: key);
  final String callerName;
  final String callerNumber;
  final Function() onAccept;
  final Function() onReject;
  final String? callSid;
  final dynamic backgroundService; // TwilioBackgroundService
  final List<int> vibratePattern;

  // Factory constructor for background service integration
  factory TwilioIncomingCallDialog.fromBackgroundService({
    required Map<String, dynamic> callInfo,
    required dynamic backgroundService,
    required Function() onAccept,
    required Function() onReject,
  }) {
    final callerName = callInfo['callerId']?.toString() ?? 
                      callInfo['from']?.toString() ?? 
                      'Unknown Caller';
    final callerNumber = callInfo['from']?.toString() ?? '';
    final callSid = callInfo['callSid']?.toString();

    return TwilioIncomingCallDialog(
      callerName: callerName,
      callerNumber: callerNumber,
      callSid: callSid,
      backgroundService: backgroundService,
      onAccept: onAccept,
      onReject: onReject,
    );
  }

  @override
  State<TwilioIncomingCallDialog> createState() => _TwilioIncomingCallDialogState();
}

class _TwilioIncomingCallDialogState extends State<TwilioIncomingCallDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _callAccepted = false;
  bool _callRejected = false;
  bool _callInProgress = false;
  bool _isMuted = false;
  
  // Call timer functionality
  Timer? _callTimer;
  String _callDuration = '00:00';
  DateTime? _callStartTime;

  @override
  void initState() {
    super.initState();

    // Set up pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Start animation loop
    _pulseController.repeat(reverse: true);

    // Play vibration pattern
    if (widget.vibratePattern.isNotEmpty) {
      // Initial vibration
      _playVibrationPattern();
    }

    // Listen to background service events if available
    _listenToBackgroundServiceEvents();
  }

  void _listenToBackgroundServiceEvents() {
    if (widget.backgroundService == null) return;

    try {
      // Listen for call disconnected events
      widget.backgroundService.onCallDisconnected.listen((_) {
        if (mounted) {
          setState(() {
            _callInProgress = false;
          });
          _callTimer?.cancel();
          Navigator.of(context).pop();
        }
      });

      // Listen for call accepted events
      widget.backgroundService.onCallAccepted.listen((_) {
        if (mounted && !_callAccepted) {
          setState(() {
            _callAccepted = true;
            _callInProgress = true;
            _callStartTime = DateTime.now();
          });
          _pulseController.stop();
          _startCallTimer();
        }
      });

      // Listen for call rejected events
      widget.backgroundService.onCallRejected.listen((_) {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });

      // Listen for mute state changes
      widget.backgroundService.onCallMute.listen((isMuted) {
        if (mounted) {
          setState(() {
            _isMuted = isMuted;
          });
        }
      });
    } catch (e) {
      print('Error setting up background service event listeners: $e');
    }
  }

  void _playVibrationPattern() {
    if (kIsWeb) {
      try {
        // Use navigator.vibrate if available in the browser
        final jsVibrate = '''
          (function() {
            if (navigator.vibrate) {
              navigator.vibrate(${widget.vibratePattern});
              return true;
            }
            return false;
          })();
        ''';
        js.context.callMethod('eval', [jsVibrate]);
      } catch (e) {
        print('Error playing vibration: $e');
      }
    }
  }  void _handleAccept() {
    setState(() {
      _callAccepted = true;
      _callInProgress = true;
      _callStartTime = DateTime.now();
    });

    // Stop pulse animation and start call timer
    _pulseController.stop();
    _startCallTimer();

    // Use background service to accept call if available
    if (widget.backgroundService != null) {
      try {
        widget.backgroundService.acceptCall();
      } catch (e) {
        print('Error calling background service acceptCall: $e');
      }
    }

    // Call the accept callback
    widget.onAccept();
  }
  
  void _handleReject() {
    setState(() {
      _callRejected = true;
    });

    // Stop pulse animation
    _pulseController.stop();

    // Use background service to reject call if available
    if (widget.backgroundService != null) {
      try {
        widget.backgroundService.rejectCall();
      } catch (e) {
        print('Error calling background service rejectCall: $e');
      }
    }

    // Call the reject callback
    widget.onReject();
    
    // Close dialog after brief delay
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  void _handleHangup() {
    setState(() {
      _callInProgress = false;
    });

    // Stop call timer
    _callTimer?.cancel();

    // Use background service to hangup call if available
    if (widget.backgroundService != null) {
      try {
        widget.backgroundService.hangupCall();
      } catch (e) {
        print('Error calling background service hangupCall: $e');
      }
    }

    // Call the reject callback (hangup is essentially rejecting)
    widget.onReject();
    
    // Close dialog after brief delay
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  void _handleToggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });

    // Use background service to toggle mute if available
    if (widget.backgroundService != null) {
      try {
        widget.backgroundService.toggleMute();
      } catch (e) {
        print('Error calling background service toggleMute: $e');
      }
    }
  }
  
  void _startCallTimer() {
    _callTimer?.cancel();
    _callTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_callStartTime != null && mounted) {
        final duration = DateTime.now().difference(_callStartTime!);
        final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
        final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
        setState(() {
          _callDuration = "$minutes:$seconds";
        });
      }
    });
  }
    @override
  void dispose() {
    _pulseController.dispose();
    _callTimer?.cancel();
    
    // Notify background service that dialog is being disposed
    if (widget.backgroundService != null) {
      try {
        widget.backgroundService._showingCallDialog = false;
      } catch (e) {
        print('Error updating background service state on dispose: $e');
      }
    }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _buildDialogContent(context),
    );
  }
  Widget _buildDialogContent(BuildContext context) {
    return Container(
      width: 350,
      decoration: BoxDecoration(
        color: _callAccepted ? Color(0xFF2D2D2D) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: _callAccepted && _callInProgress 
          ? _buildActiveCallInterface() 
          : _buildIncomingCallInterface(),
    );
  }

  Widget _buildIncomingCallInterface() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar section
        Container(
          padding: EdgeInsets.only(top: 50, bottom: 30),
          child: Column(
            children: [
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFE1BEE7), // Light purple background
                    border: Border.all(
                      color: Color(0xFF5C6BC0), // Blue border
                      width: 4,
                    ),
                  ),
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: Color(0xFF7B1FA2), // Purple icon
                  ),
                ),
              ),
              SizedBox(height: 30),
              Text(
                widget.callerName,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: Color(0xFF5C6BC0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Ringing...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),        // Action buttons
        Container(
          padding: EdgeInsets.symmetric(horizontal: 60, vertical: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Microphone/Accept button (tap to accept call)
              GestureDetector(
                onTap: _handleAccept,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                    Icons.mic,
                    color: Colors.black,
                    size: 28,
                  ),
                ),
              ),
              
              // Reject/Hangup button
              GestureDetector(
                onTap: _handleReject,
                child: Container(
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
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActiveCallInterface() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header section
        Container(
          padding: EdgeInsets.only(top: 40, bottom: 20),
          child: Column(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFE1BEE7), // Same avatar style
                  border: Border.all(
                    color: Color(0xFF4CAF50), // Green border for active call
                    width: 3,
                  ),
                ),
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Color(0xFF7B1FA2),
                ),
              ),
              SizedBox(height: 20),
              Text(
                widget.callerName,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              if (widget.callerNumber.isNotEmpty)
                Text(
                  widget.callerNumber,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              SizedBox(height: 15),
              // Call timer
              Text(
                _callDuration,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        
        // Active call controls
        Container(
          padding: EdgeInsets.symmetric(horizontal: 60, vertical: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Mute button
              GestureDetector(
                onTap: _handleToggleMute,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _isMuted ? Colors.red : Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    _isMuted ? Icons.mic_off : Icons.mic,
                    color: _isMuted ? Colors.white : Colors.white,
                    size: 28,
                  ),
                ),
              ),
              
              // Hangup button
              GestureDetector(
                onTap: _handleHangup,
                child: Container(
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
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildIncomingCallButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildRejectButton(context),
        _buildAcceptButton(context),
      ],
    );
  }

  Widget _buildActiveCallButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Mute button
        GestureDetector(
          onTap: _handleToggleMute,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _isMuted ? Colors.red.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isMuted ? Icons.mic_off : Icons.mic,
                  color: _isMuted ? Colors.red : Colors.black,
                  size: 30,
                ),
              ),
              SizedBox(height: 8),
              Text(
                _isMuted ? 'Unmute' : 'Mute',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),

        // Hangup button
        GestureDetector(
          onTap: _handleHangup,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
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
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAcceptButton(BuildContext context) {
    return GestureDetector(
      onTap: _handleAccept,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              Icons.call,
              color: Colors.white,
              size: 30,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Accept',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRejectButton(BuildContext context) {
    return GestureDetector(
      onTap: _handleReject,
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
            'Reject',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Static helper method for background service to show the dialog
  static void showFromBackgroundService({
    required BuildContext context,
    required Map<String, dynamic> callInfo,
    required dynamic backgroundService,
  }) {
    final callerName = callInfo['callerId']?.toString() ?? 
                      callInfo['from']?.toString() ?? 
                      'Unknown Caller';
    final callerNumber = callInfo['from']?.toString() ?? '';
    final callSid = callInfo['callSid']?.toString();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return TwilioIncomingCallDialog(
          callerName: callerName,
          callerNumber: callerNumber,
          callSid: callSid,
          backgroundService: backgroundService,
          onAccept: () {
            print('Call accepted for: $callerName');
          },
          onReject: () {
            print('Call rejected for: $callerName');
          },
        );
      },
    );
  }
}

// Helper class for background service integration
class TwilioIncomingCallDialogHelper {
  static void showIncomingCallDialog({
    required BuildContext context,
    required Map<String, dynamic> callInfo,
    required dynamic backgroundService,
  }) {
    final callerName = callInfo['callerId']?.toString() ?? 
                      callInfo['from']?.toString() ?? 
                      'Unknown Caller';
    final callerNumber = callInfo['from']?.toString() ?? '';
    final callSid = callInfo['callSid']?.toString();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return TwilioIncomingCallDialog(
          callerName: callerName,
          callerNumber: callerNumber,
          callSid: callSid,
          backgroundService: backgroundService,
          onAccept: () {
            print('Call accepted for: $callerName ($callerNumber)');
            // The dialog will handle the accept via background service
          },
          onReject: () {
            print('Call rejected for: $callerName ($callerNumber)');
            // The dialog will handle the reject via background service
          },
        );
      },
    );
  }

  // Alternative method using overlay (for when no context is available)
  static OverlayEntry showAsOverlay({
    required Map<String, dynamic> callInfo,
    required dynamic backgroundService,
    required OverlayState overlayState,
  }) {
    final callerName = callInfo['callerId']?.toString() ?? 
                      callInfo['from']?.toString() ?? 
                      'Unknown Caller';
    final callerNumber = callInfo['from']?.toString() ?? '';
    final callSid = callInfo['callSid']?.toString();

    // Create a variable that can be captured by closures
    late final OverlayEntry entry;

    // Define the entry using the variable
    entry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.black54,
        child: Center(
          child: TwilioIncomingCallDialog(
            callerName: callerName,
            callerNumber: callerNumber,
            callSid: callSid,
            backgroundService: backgroundService,
            onAccept: () {
              print('Call accepted for: $callerName ($callerNumber)');
              // Remove overlay after acceptance
              Future.delayed(Duration(milliseconds: 100), () {
                try {
                  entry.remove();
                } catch (e) {
                  print('Error removing overlay entry: $e');
                }
              });
            },
            onReject: () {
              print('Call rejected for: $callerName ($callerNumber)');
              // Remove overlay after rejection
              Future.delayed(Duration(milliseconds: 500), () {
                try {
                  entry.remove();
                } catch (e) {
                  print('Error removing overlay entry: $e');
                }
              });
            },
          ),
        ),
      ),
    );

    overlayState.insert(entry);
    return entry;
  }
}

