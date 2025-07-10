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

int? previousCount; // Store the last count
final isSandboxEnv = FFDevEnvironmentValues().baseUrl.contains('sandbox');

void printLog(String message) {
  if (isSandboxEnv) {
    print(message);
  }
}

Future<int?> websocket(BuildContext context, String token) async {
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
  Completer<int?> completer = Completer<int?>();

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
        completer.complete(null); // Return null if disconnected before data
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
        if (data['type'] == 'connection_ack') {
          printLog(
              'Connection acknowledged by server. Sending subscription...');
          socket.send(jsonEncode({
            "id": "1",
            "type": "start",
            "payload": {
              "query": """
                subscription HboxHpodCount {
                  totalCount: api_message_aggregate(
                    where: {recipient_id: {_eq: 146074}, unread: {_eq: true}, type: {_eq: "standard"}}
                  ) {
                    aggregate {
                      count
                    }
                  }
                }
              """
            }
          }));
          printLog('Subscription request sent');
        } else if (data['type'] == 'ping') {
          socket.send(jsonEncode({"type": "pong"}));
          printLog('Sent pong response to ping');
        } else if (data['type'] == 'next' && data.containsKey('payload')) {
          final count = data['payload']['data']['totalCount']['aggregate']
              ['count'] as int;
          printLog('Formatted Count: $count');

          FFAppState().totalTransferAlertCount = count; // Store in AppState

          previousCount = count; // Update stored count

          if (!completer.isCompleted) {
            completer.complete(count); // Return the count
          }
          // socket.close(); // Close the socket after receiving the count
        } else if (data['type'] == 'connection_error') {
          printLog('Connection error details: ${data['payload']}');
          if (!completer.isCompleted) {
            completer.complete(null); // Return null on error
          }
        }
      } catch (e) {
        printLog('Error parsing WebSocket message: $e');
        if (!completer.isCompleted) {
          completer.complete(null); // Return null on parsing error
        }
      }
    } else {
      printLog('Received non-string message: $message');
    }
  });

  return completer.future; // Return the Future that resolves to the count
}
