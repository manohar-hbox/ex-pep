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

import 'index.dart'; // Imports other custom actions

import '/backend/api_requests/api_calls.dart'; // Import API calls

import 'dart:async';
import 'dart:html' as html;
import 'dart:convert';
import 'dart:js' as js;
import 'dart:js_util' as js_util;
import 'dart:typed_data';

Future<void> openNewWindow(BuildContext context, BuildContext parentContext) async {
  final safeContext = context; // capture before await
  if (html.window.sessionStorage['popupOpen'] == 'true') return;

  final uri = html.window.location;
  final baseUrl = '${uri.protocol}//${uri.host}'; // host already includes port

  print('Base URL: $baseUrl');

  // Construct correct path (no hash)
  final targetPath = '/CallingPatient';
  final fullUrl = '$baseUrl$targetPath';

  print("Opening URL: $fullUrl");
  FFAppState().twilioCTCPhoneNo = "${FFAppState().twilioCallData.toPhoneNumber}";
  // Create a completer that will resolve when we get a CallSid
  final callSidCompleter = Completer<String>();
  // Set up an event listener for the CallSid
  html.window.addEventListener('twilioCallSidReceived', (event) {
    try {
      final customEvent = event as html.CustomEvent;
      final callSid = customEvent.detail['callSid']?.toString() ?? '';
      if (callSid.isNotEmpty) {
        print('Received CallSid from custom event: $callSid');
        if (!callSidCompleter.isCompleted) {
          callSidCompleter.complete(callSid);
        }
      }
    } catch (e) {
      print('Error processing twilioCallSidReceived event: $e');
    }
  });
  final popup = html.window.open(
    fullUrl,
    'FlutterFlowPopup',
    'popup=yes,width=600,height=800,left=100,top=100,toolbar=no,location=no,status=no,menubar=no,scrollbars=no,resizable=no',
  ); // Set up message listener for cross-window communication
  late StreamSubscription<html.MessageEvent> messageSubscription;
  messageSubscription = html.window.onMessage.listen((html.MessageEvent event) {
    try {
      print('=== MESSAGE RECEIVED FROM POPUP ===');
      print('Message data: ${event.data}');
      print('Message origin: ${event.origin}');
      print('Event source: ${event.source}');

      // Check if it's a map/object
      if (event.data is Map ||
          (event.data != null &&
              event.data.toString().contains('twilioCallDisconnected'))) {
        dynamic messageData = event.data;

        // Handle both Map and string representations
        String messageType = '';
        if (messageData is Map) {
          messageType = messageData['type']?.toString() ?? '';
          print('Message debug info: ${messageData['debug']}');
          print('Message source type: ${messageData['source']}');
        } else if (messageData is String &&
            messageData.contains('twilioCallDisconnected')) {
          messageType = 'twilioCallDisconnected';
        }

        print('Message type: $messageType');
        if (messageType == 'twilioCallDisconnected') {
          print('=== CALL DISCONNECTED MESSAGE RECEIVED FROM POPUP ===');
          print('Message received at: ${DateTime.now()}');
          print('Popup object: $popup');
          print('Popup closed status: ${popup?.closed}');

          if (popup != null && !popup.closed!) {
            print('Closing popup due to call disconnect message...');
            popup.close();
            print('✅ Popup closed successfully due to call disconnect message');
          } else {
            print('⚠️ Popup was already closed or null');
          }

          // Clean up the message listener after 2 seconds delay
          Timer(Duration(seconds: 2), () {
            messageSubscription.cancel();
            print('✅ Message listener cleaned up after 2 second delay');
          });
        }
      }
    } catch (e) {
      print('❌ Error processing message from popup: $e');
    }
  });

  // Also set up BroadcastChannel listener as backup
  try {
    final jsCode = '''
      (function() {
        const broadcastChannel = new BroadcastChannel('twilio-calls');
        broadcastChannel.addEventListener('message', function(event) {
          console.log('=== BROADCAST MESSAGE RECEIVED ===');
          console.log('Broadcast data:', event.data);
          
          if (event.data && event.data.type === 'twilioCallDisconnected') {
            console.log('Broadcasting disconnect event to main window...');
            // Dispatch event in main window context
            const disconnectEvent = new CustomEvent('twilioCallDisconnected', {
              detail: event.data
            });
            window.dispatchEvent(disconnectEvent);
            
            // Also trigger postMessage to simulate cross-window communication
            window.postMessage({
              type: 'twilioCallDisconnected',
              timestamp: event.data.timestamp,
              source: 'broadcast-relay'
            }, '*');
          }
        });
        
        // Store reference for cleanup
        window._twilioCallBroadcastChannel = broadcastChannel;
        console.log('✅ BroadcastChannel listener set up');
      })();
    ''';
    js.context.callMethod('eval', [jsCode]);
  } catch (e) {
    print('⚠️ BroadcastChannel setup failed: $e');
  }

  // Set up an event listener for call disconnected to auto-close popup (fallback)
  html.window.addEventListener('twilioCallDisconnected', (event) {
    try {
      print('=== CALL DISCONNECTED EVENT RECEIVED (FALLBACK) ===');
      print('Event received at: ${DateTime.now()}');
      print('Popup object: $popup');
      print('Popup closed status: ${popup?.closed}');

      if (popup != null) {
        if (!popup.closed!) {
          print('Closing popup due to call disconnect...');
          // popup.close();
          print('✅ Popup closed successfully due to call disconnect');
        } else {
          print('⚠️ Popup was already closed');
        }
      } else {
        print('❌ Popup object is null');
      }
    } catch (e) {
      print('❌ Error closing popup on call disconnect: $e');
    }
  });

  html.window.sessionStorage['popupOpen'] = 'true';

  html.window.onStorage.listen((event) {
    if (event.key == 'popupClosed' && event.newValue == 'true') {
      html.window.sessionStorage['popupOpen'] = 'false';
    }
  });
  Timer.periodic(Duration(milliseconds: 500), (timer) async {
    if (popup.closed!) {
      timer.cancel();
      // Clean up the message listener when popup closes
      messageSubscription.cancel();
      print('✅ Message listener cleaned up due to popup closure');

      html.window.sessionStorage['popupOpen'] = 'false';
      html.window.dispatchEvent(html.Event('popupClosed'));
      print('Call Finished!');
      FFAppState().update(() {
        FFAppState().isPatientCallInProgress = false;
      });
      await warnBeforeUnload(false);
      // Get the CallSid from Twilio using JavaScript with enhanced reliability
      String callSid = '';
      try {
        final jsCode = '''
        (function() {
          // Try accessing the stored CallSid directly
          if (window._storedCallSid && window._storedCallSid !== '') {
            console.log('Directly accessing stored CallSid:', window._storedCallSid);
            return window._storedCallSid;
          }
          
          // Try to get from localStorage
          try {
            const storedSid = localStorage.getItem('twilioCallSid');
            if (storedSid) {
              console.log('Retrieved CallSid from localStorage:', storedSid);
              return storedSid;
            }
          } catch (e) {
            console.error('Error accessing localStorage:', e);
          }
          
          // Try to use the helper method
          if (window.twilioHelper && typeof window.twilioHelper.getCallSid === 'function') {
            console.log('Trying to get CallSid from helper function');
            const sid = window.twilioHelper.getCallSid();
            if (sid) {
              console.log('Retrieved CallSid from helper:', sid);
              return sid;
            }
          }
          
          // If we still don't have a CallSid, try to get directly from the current call
          if (window._currentCall && window._currentCall.parameters && window._currentCall.parameters.CallSid) {
            console.log('Getting CallSid directly from _currentCall.parameters');
            return window._currentCall.parameters.CallSid;
          }
          
          console.log('⚠️ No CallSid available from any source');
          return '';
        })();
        ''';

        final result = js.context.callMethod('eval', [jsCode]);
        callSid = result?.toString() ?? '';
        print('Retrieved CallSid for API request: $callSid');

        if (callSid.isEmpty || callSid == 'undefined' || callSid == 'null') {
          print('⚠️ WARNING: Retrieved empty or invalid CallSid');

          // Try to complete the API call using the completer
          if (!callSidCompleter.isCompleted) {
            // Wait for a reasonable timeout before giving up
            Timer(Duration(seconds: 2), () {
              if (!callSidCompleter.isCompleted) {
                print('⚠️ Timeout waiting for CallSid event');
                callSidCompleter.complete(''); // Complete with empty string
              }
            });
          }

          // Try one more attempt with direct access
          final retryResult = js.context.callMethod('eval', [
            "window._storedCallSid || (localStorage.getItem('twilioCallSid') || '')"
          ]);
          callSid = retryResult?.toString() ?? '';
          print('Final attempt CallSid: $callSid');
        }
      } catch (e) {
        print('Error getting CallSid: $e');
      }

      // If we still don't have a CallSid, wait for the event-based one
      if (callSid.isEmpty || callSid == 'undefined' || callSid == 'null') {
        print('Waiting for CallSid from event...');
        // We'll wait for the callSidCompleter to complete
      }

      // Function to proceed with the API call once we have a CallSid
      void processCallWithSid(String sid) async {
        print('Processing call with CallSid: $sid');

        if (sid.isEmpty) {
          print('⚠️ WARNING: Unable to retrieve CallSid. API call may fail.');
        }

        // Get the Twilio call information and parse the JSON response
        // delay for 2 seconds
        await Future.delayed(Duration(seconds: 4));
        final callResponse = GQLgetByFunctionCall.call(
            hasuraToken: FFAppState().hasuraToken,
            requestBody: getTwilioCallInformation(sid));

        callResponse.then((apiCallResponse) {
          // Convert the response to a JSON string
          final callInfoJson = apiCallResponse.bodyText;

          try {
            // Parse the JSON response
            Map<String, dynamic> response = json.decode(callInfoJson);

            // Check if data exists and extract call log information
            Map<String, dynamic> callData = {};
            if (response.containsKey('data') &&
                response['data'].containsKey('api_outgoing_call_log') &&
                response['data']['api_outgoing_call_log'].isNotEmpty) {
              // Get the first call log entry
              callData = response['data']['api_outgoing_call_log'][0];
            } else {
              print('⚠️ API response does not contain expected data structure');
            }

            print("Twilio Call Data: $callData");

            // Extract call status from API response
            String callStatus = callData['call_status'] ?? 'unknown';

            // Format the call duration to mm:ss
            String formattedDuration =
                formatCallDuration(callData['call_duration'] ?? '00:00:00');

            // Use dtFormatterNew for timezone handling of start and end times
            String answeredAt = formatTimeWithTimezone(
                callData['answered_at'] ?? '',
                FFAppState().twilioCallData.patientClinicTimeZone);

            String completedAt = formatTimeWithTimezone(
                callData['completed_at'] ?? '',
                FFAppState().twilioCallData.patientClinicTimeZone);

            print("Twilio Call Status: $callStatus");
            print("Twilio Call Duration: $formattedDuration");
            print("Twilio Answered At: $answeredAt");
            print("Twilio Completed At: $completedAt");
            openCallSummaryDialog(
                parentContext,
                CallSummary(
                  callDuration: formattedDuration,
                  answeredAt: answeredAt,
                  completedAt: completedAt,
                  callStatus: callStatus,
                ));
          } catch (e) {
            print("Error parsing call data: $e");
            // Show dialog with default values in case of error
            openCallSummaryDialog(
                parentContext,
                CallSummary(
                  callDuration: 'N/A',
                  answeredAt: 'N/A',
                  completedAt: 'N/A',
                  callStatus: 'unknown',
                ));
          }
        }).catchError((error) {
          print("Error getting call data: $error");
          // Show dialog with default values in case of error
          openCallSummaryDialog(
              parentContext,
              CallSummary(
                callDuration: 'N/A',
                answeredAt: 'N/A',
                completedAt: 'N/A',
                callStatus: 'error',
              ));
        });
      }

      // If we already have a CallSid, use it immediately
      if (callSid.isNotEmpty && callSid != 'undefined' && callSid != 'null') {
        processCallWithSid(callSid);
      } else {
        // Otherwise wait for the completer or timeout
        Future.any([
          callSidCompleter.future,
          Future.delayed(Duration(seconds: 3), () => '')
        ]).then((sid) {
          processCallWithSid(sid);
        });
      }

      html.Url.revokeObjectUrl(fullUrl); // Clean up
    }
  });
}

// Format call duration from HH:MM:SS to MM:SS
String formatCallDuration(String durationString) {
  if (durationString.isEmpty) {
    return '00:00';
  }

  try {
    // Parse the HH:MM:SS format
    List<String> parts = durationString.split(':');
    if (parts.length == 3) {
      int hours = int.tryParse(parts[0]) ?? 0;
      int minutes = int.tryParse(parts[1]) ?? 0;
      int seconds = int.tryParse(parts[2]) ?? 0;

      // Convert hours to minutes
      minutes += hours * 60;

      // Format as MM:SS
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return durationString; // Return as-is if not in expected format
  } catch (e) {
    print('Error formatting duration: $e');
    return durationString; // Return original on error
  }
}

// Format time with timezone using dtFormatterNew
String formatTimeWithTimezone(String timeString, String timezone) {
  if (timeString.isEmpty) {
    return 'N/A';
  }

  try {
    // Parse the datetime string
    DateTime dateTime = DateTime.parse(timeString);

    // Use the dtDisplayFormatterNew function to apply timezone
    // This converts the time to the specified timezone
    String formattedTime = dtDisplayFormatterNew(dateTime.toString(), timezone);

    // Parse the formatted time which is now in the target timezone
    DateTime parsedDateTime = DateTime.parse(formattedTime);

    // Format as DD-MMM-YYYY HH:MM:SS
    String formattedDateTime =
        DateFormat('dd-MMM-yyyy HH:mm:ss').format(parsedDateTime);

    // Extract timezone abbreviation from the timezone string
    String timezoneAbbr = getTimezoneAbbreviation(timezone);

    return '$formattedDateTime ($timezoneAbbr)';
  } catch (e) {
    print('Error formatting time with timezone: $e');
    return timeString; // Return original on error
  }
}

// Helper function to get timezone abbreviation from timezone string
String getTimezoneAbbreviation(String timezone) {
  // Common timezone mappings
  Map<String, String> timezoneMap = {
    'America/New_York': 'EST',
    'US/Eastern': 'EST',
    'America/Chicago': 'CST',
    'US/Central': 'CST',
    'America/Denver': 'MST',
    'US/Mountain': 'MST',
    'America/Los_Angeles': 'PST',
    'US/Pacific': 'PST',
    'America/Phoenix': 'MST',
    'America/Anchorage': 'AKST',
    'America/Adak': 'HST',
    'Pacific/Honolulu': 'HST',
    'America/Puerto_Rico': 'AST',
    'Europe/London': 'GMT',
    'Europe/Paris': 'CET',
    'Europe/Athens': 'EET',
    'Asia/Kolkata': 'IST',
    'Asia/Tokyo': 'JST',
    'Asia/Shanghai': 'CST',
    'Australia/Sydney': 'AEST',
    // Add more mappings as needed
  };

  return timezoneMap[timezone] ?? timezone.split('/').last;
}

// Added CallSummary class to hold parsed call information
class CallSummary {
  final String callDuration;
  final String answeredAt;
  final String completedAt;
  final String callStatus; // Added call_status field

  CallSummary({
    required this.callDuration,
    required this.answeredAt,
    required this.completedAt,
    required this.callStatus, // Added parameter
  });
}

Future<void> openCallSummaryDialog(
    BuildContext context, CallSummary callInfo) async {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      // Determine color and icon based on call status
      Color statusColor;
      IconData statusIcon;
      String statusText;

      switch (callInfo.callStatus) {
        case 'completed':
          statusColor = Colors.green;
          statusIcon = Icons.check;
          statusText = 'Call Completed';
          break;
        case 'failed':
          statusColor = Colors.red;
          statusIcon = Icons.error_outline;
          statusText = 'Call Failed';
          break;
        case 'no-answer':
          statusColor = Colors.orange;
          statusIcon = Icons.phone_missed;
          statusText = 'No Answer';
          break;
        case 'busy':
          statusColor = Colors.orange;
          statusIcon = Icons.phone_missed;
          statusText = 'Busy';
          break;
        case 'transferred':
          statusColor = Colors.orange;
          statusIcon = Icons.swap_calls;
          statusText = 'Call Transferred';
          break;
        case 'unknown':
          statusColor = Colors.grey;
          statusIcon = Icons.help_outline;
          statusText = 'Call Status Unknown';
          break;
        default:
          statusColor = Colors.blue;
          statusIcon = Icons.phone_in_talk;
          statusText = 'Call Status: ${callInfo.callStatus}';
      }

      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 400, // Increased width for a more spacious dialog
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Close button in top-right corner
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon:
                      const Icon(Icons.close, size: 24), // Slightly larger icon
                  padding: EdgeInsets.all(
                      12), // More padding for better touch target
                  onPressed: () {
                    // Clear Twilio call data when close is pressed
                    FFAppState().update(() {
                      FFAppState().twilioCallData = TwilioCallDataStruct(
                        toPhoneNumber: '',
                        patientFirstName: '',
                        patientLastName: '',
                        patientClinicTimeZone: '',
                      );
                    });
                    Navigator.pop(context);
                  },
                ),
              ),

              // Header with title
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                    24, 0, 24, 24), // Increased padding
                child: Text(
                  'Call Summary',
                  style: TextStyle(
                    fontSize: 20, // Slightly larger font
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),

              // Status box with dynamic colors and status
              Container(
                width: double.infinity,
                color: statusColor.withOpacity(0.1),
                padding: const EdgeInsets.symmetric(
                    vertical: 28), // More vertical padding
                margin: const EdgeInsets.only(
                    bottom: 16), // Add margin below status box
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: statusColor,
                      ),
                      padding:
                          const EdgeInsets.all(10), // Larger icon container
                      child: Icon(
                        statusIcon,
                        color: Colors.white,
                        size: 28, // Larger icon
                      ),
                    ),
                    const SizedBox(height: 12), // More spacing
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 18, // Larger text
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Call details
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    24, 8, 24, 16), // Adjusted padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CallInfoRow(
                      label: 'Patient:',
                      value:
                          "${FFAppState().twilioCallData.patientFirstName} ${FFAppState().twilioCallData.patientLastName}",
                    ),
                    Divider(
                        height: 24,
                        color: Colors
                            .grey[300]), // Grey divider with height for spacing

                    CallInfoRow(
                      label: 'Phone Number:',
                      value: formatPhoneNumber(
                          FFAppState().twilioCallData.toPhoneNumber),
                    ),
                    Divider(height: 24, color: Colors.grey[300]),

                    // Only show duration if it's not 00:00
                    if (callInfo.callDuration != '00:00')
                      Column(
                        children: [
                          CallInfoRow(
                            label: 'Duration:',
                            value: callInfo.callDuration,
                          ),
                          Divider(height: 24, color: Colors.grey[300]),
                        ],
                      ),

                    // Only show start time if it's not N/A
                    if (callInfo.answeredAt != 'N/A')
                      Column(
                        children: [
                          CallInfoRow(
                            label: 'Started:',
                            value: callInfo.answeredAt,
                          ),
                          Divider(height: 24, color: Colors.grey[300]),
                        ],
                      ),

                    // Only show end time if it's not N/A
                    if (callInfo.completedAt != 'N/A')
                      Column(
                        children: [
                          CallInfoRow(
                            label: 'Ended:',
                            value: callInfo.completedAt,
                          ),
                          Divider(height: 24, color: Colors.grey[300]),
                        ],
                      ),
                  ],
                ),
              ),

              // Close button
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(24, 8, 24, 24), // More padding
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Clear Twilio call data when close is pressed
                      FFAppState().update(() {
                        FFAppState().twilioCallData = TwilioCallDataStruct(
                          toPhoneNumber: '',
                          patientFirstName: '',
                          patientLastName: '',
                          patientClinicTimeZone: '',
                        );
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Color(0xFF812AD4), // Updated color to #812AD4
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            8), // Slightly rounded corners
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 16), // Taller button
                      elevation: 2, // Slight elevation for better depth
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16, // Larger text
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class CallInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const CallInfoRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120, // Slightly wider to accommodate longer labels
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[600], // Slightly darker for better readability
              fontSize: 15, // Slightly larger font
              fontWeight: FontWeight.w500, // Medium weight for better contrast
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 15, // Slightly larger font
              fontWeight: FontWeight.w400,
              color: Colors.grey[800], // Darker text for better readability
            ),
          ),
        ),
      ],
    );
  }
}
