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

dynamic previousCount; // Store the last count
final isSandboxEnv = FFDevEnvironmentValues().baseUrl.contains('sandbox');

void printLog(String message) {
  if (isSandboxEnv) {
    print(message);
  }
}

Future<String> getCSFromTransferredPatientSubscription(
    BuildContext context, String token, int transferId) async {
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

  // Use a Completer to handle the async return of the count
  Completer<String> completer = Completer<String>();

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

      String jsonMessage = jsonEncode(requestBody);
      socket.send(jsonMessage);

      printLog('Connection initialization sent with Authorization');
    } else if (state is Disconnected) {
      printLog('WebSocket disconnected with state: $state');
      if (!completer.isCompleted) {
        completer.complete(""); // Return null if disconnected before data
      }
    } else {
      printLog('WebSocket state: $state');
    }
  });

  socket.messages.listen((message) {
    if (message is String) {
      try {
        final data = jsonDecode(message);
        printLog('Received WebSocket Data: $data');
        dynamic request = {
          "operationName": "MyQuery",
          "variables": {"transferId": transferId}
        };

        if (data['type'] == 'connection_ack') {
          printLog('TRANSFER ID: $transferId');
          printLog(
              'Connection acknowledged by server. Sending subscription...');
          socket.send(jsonEncode({
            "id": "1",
            "type": "start",
            "payload": {
              "query": """
                subscription MyQuery(\$transferId: Int!) {
                  pep_vw_transfer_patient_list(where: {id: {_eq: \$transferId}, assigned_cs_id: {_is_null: false}}) {
                    id
                    care_specialist
                  }
                }
              """,
              "variables": request['variables']
            }
          }));
          printLog('Subscription request sent');
        } else if (data['type'] == 'ping') {
          socket.send(jsonEncode({"type": "pong"}));
          printLog('Sent pong response to ping');
        } else if (data['type'] == 'next' && data.containsKey('payload')) {
          printLog('TRANSFER ID: ${transferId.toString()}');
          final updatedPatientList =
              (data['payload']['data']['pep_vw_transfer_patient_list'] ?? [])
                  as List;

          if (updatedPatientList.isNotEmpty) {
            printLog('Updated Transferred Patient List: $updatedPatientList');
            // Find the first element where name is "care_specialist"
            // Extract the first element
            final firstItem = updatedPatientList.first;

            // Ensure it's a Map and contains the "care_specialist" key
            if (firstItem is Map<String, dynamic> &&
                firstItem.containsKey('care_specialist')) {
              final careSpecialist = firstItem['care_specialist'];

              // Update app state with the extracted care specialist name
              if (careSpecialist.isNotEmpty) {
                FFAppState().update(() {
                  FFAppState().acceptedTransferCSName = careSpecialist;
                  FFAppState().isDetailsSaved = true;
                });
                socket.close(); // Close the socket after receiving the count
              }
              printLog('Care Specialist Name: $careSpecialist');
            } else {
              printLog('No Care Specialist key found in the first item.');
            }
          } else {
            printLog('Updated Patient List is empty.');
          }

          printLog('Updated Patient List: $updatedPatientList');

          previousCount = updatedPatientList; // Update stored count

          if (!completer.isCompleted) {
            completer.complete(FFAppState().acceptedTransferCSName.isNotEmpty
                ? FFAppState().acceptedTransferCSName
                : ""); // Return the count
          }
        } else if (data['type'] == 'connection_error') {
          printLog('Connection error details: ${data['payload']}');
          if (!completer.isCompleted) {
            completer.complete(""); // Return null on error
          }
        }
      } catch (e) {
        printLog('Error parsing WebSocket message: $e');
        if (!completer.isCompleted) {
          completer.complete(""); // Return null on parsing error
        }
      }
    } else {
      printLog('Received non-string message: $message');
    }
  });

  return completer.future; // Return the Future that resolves to the count
}
