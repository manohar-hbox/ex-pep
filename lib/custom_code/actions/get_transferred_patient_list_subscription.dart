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
import 'dart:convert';
import 'package:web_socket_client/web_socket_client.dart';

import 'dart:html' as html;

// Global variable to track previous count
int previousTransferCount = 0;
bool ignoredFirstTime = false;

final isSandboxEnv = FFDevEnvironmentValues().baseUrl.contains('sandbox');

void printLog(String message) {
  if (isSandboxEnv) {
    print(message);
  }
}

Future<dynamic> getTransferredPatientListSubscription(
    BuildContext context, String token, int assignedCSId) async {
  final url =
      Uri.parse(FFDevEnvironmentValues().websocketGraphQLSubscriptionURL);
  final authToken = 'Bearer ' + token;

  final socket = WebSocket(
    url,
    protocols: ['graphql-transport-ws'],
    headers: {
      'Authorization': authToken,
      'Sec-WebSocket-Protocol': 'graphql-transport-ws',
    },
  );

  printLog('Connecting to WebSocket...');

  Completer<dynamic> completer = Completer<dynamic>();

  socket.connection.listen((state) {
    if (state is Connecting) {
      printLog('WebSocket is connecting...');
    } else if (state is Connected) {
      printLog('WebSocket connected');

      var requestBody = {
        "type": "connection_init",
        "payload": {
          "Authorization": authToken,
          "headers": {
            "Authorization": authToken,
          }
        }
      };

      socket.send(jsonEncode(requestBody));
      printLog('Connection initialization sent with Authorization');
    } else if (state is Disconnected) {
      printLog('WebSocket disconnected');
      if (!completer.isCompleted) {
        completer.complete(null);
      }
    }
  });

  socket.messages.listen((message) {
    if (message is String) {
      try {
        final data = jsonDecode(message);
        dynamic request = {
          "operationName": "MyQuery",
          "variables": {"assignedCSId": assignedCSId}
        };

        if (data['type'] == 'connection_ack') {
          printLog(
              'Connection acknowledged by server. Sending subscription...');
          socket.send(jsonEncode({
            "id": "1",
            "type": "start",
            "payload": {
              "query": """
                subscription MyQuery(\$assignedCSId: Int!) {
                  pep_vw_transfer_patient_list(
                    where: {
                      _or: [
                        {assigned_cs_id: {_is_null: true}},
                        {assigned_cs_id: {_eq: \$assignedCSId}}
                      ]
                    }
                  ) {
                    id
                    pep_patient_clinic_data_id
                    patient_name
                    group_name
                    clinic_id
                    clinic_name
                    vpe_id
                    vpe_name
                    assigned_cs_id
                    added_dt
                  }
                }
              """,
              "variables": request['variables']
            }
          }));
          printLog('Subscription request sent');
        } else if (data['type'] == 'ping') {
          socket.send(jsonEncode({"type": "pong"}));
        } else if (data['type'] == 'next' && data.containsKey('payload')) {
          final updatedPatientList =
              (data['payload']['data']['pep_vw_transfer_patient_list'] ?? [])
                  as List;

          final newCount = updatedPatientList.length;

          // Show notification if count increased
          if ((FFAppState().isCSView == true ||
                  FFAppState().isCSAdminView == true) &&
              newCount > previousTransferCount &&
              ignoredFirstTime) {
            _showNotificationWithSound(newCount);
          } else {
            ignoredFirstTime = true;
          }

          // Update previous count
          previousTransferCount = newCount;

          // Update state
          FFAppState().update(() {
            FFAppState().transferCSRequestCount = newCount;
            FFAppState().transferredPatientList = updatedPatientList;
          });

          if (!completer.isCompleted) {
            if (updatedPatientList.isEmpty) {
              completer.complete([]);
            } else {
              completer.complete(updatedPatientList);
            }
          }
        } else if (data['type'] == 'connection_error') {
          printLog('Connection error: ${data['payload']}');
          if (!completer.isCompleted) {
            completer.complete(null);
          }
        }
      } catch (e) {
        printLog('Error parsing message: $e');
        if (!completer.isCompleted) {
          completer.complete(null);
        }
      }
    } else {
      printLog('Received non-string message');
    }
  });

  return completer.future;
}

void _showNotificationWithSound(int notificationCount) {
  final notification = html.Notification("New Patient Transferred",
      body: "A new patient has been transferred to your list.");

  // Click handler
  notification.onClick.listen((event) {
    String? redirectTo = FFAppState().redirectURL;
    if (redirectTo.isNotEmpty) {
      html.window.localStorage['redirect_url'] = redirectTo;
    }
    // sort the path paramater based on the user type

    if (FFAppState().usertype == FFAppConstants.UserTypeCS) {
      html.window.location.href = "${redirectTo}/CSTransferPatientList";
    } else {
      html.window.location.href = "${redirectTo}/CSAdminTransferPatientList";
    }
    notification.close();
  });
}
