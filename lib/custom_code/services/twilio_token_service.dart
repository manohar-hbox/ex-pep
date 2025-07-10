// filepath: C:\Users\DELL\StudioProjects\pep\lib\custom_code\services\twilio_token_service.dart
// Twilio token service to interact with Java backend

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'twilio_background_service.dart';
import '../../app_state.dart'; // Import the FFAppState class

class TwilioTokenService {
  // Singleton instance
  static final TwilioTokenService _instance = TwilioTokenService._internal();
  factory TwilioTokenService() => _instance;
  TwilioTokenService._internal();

  // Base URL for your Java backend (update with your actual backend URL)
  final String _baseUrl = 'https://sandbox.hbox.ai'; // TODO: Replace with your backend URL

  /// Fetches a token from your backend to enable incoming calls
  ///
  /// The [identity] parameter is the client identity that will receive calls
  /// Returns the token as a string, or throws an exception if something goes wrong
  Future<String> getToken(String identity) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/twilio/token?identity=$identity'),
        // Uri.parse('https://d569-2401-4900-65c3-eb30-f4f8-4e85-d935-b392.ngrok-free.app/twilio/token?identity=$identity'),
        // headers: {
        //   'ngrok-skip-browser-warning': 'true',
        // },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];

        if (token != null) {
          print('Token successfully retrieved for identity: $identity');
          FFAppState().update(() {
            FFAppState().twilioVoiceToken = token;
          });
          return token;
        } else {
          throw Exception('Token field not found in response');
        }
      } else {
        throw Exception('Failed to fetch token: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching Twilio token: $e');
      throw Exception('Error fetching Twilio token: $e');
    }
  }

  /// Initiates a check to see if the client is registered to receive calls
  Future<bool> registerForIncomingCalls(String identity) async {
    try {
      // Get a fresh token from the backend
      final token = await getToken(identity);

      // Store token in memory for debugging
      _lastToken = token;

      // Initialize the Twilio background service with the token
      final twilioService = TwilioBackgroundService();
      final result = await twilioService.initialize(token);

      print('Client registration for incoming calls: $result');
      return result;
    } catch (e) {
      print('Error registering for incoming calls: $e');
      return false;
    }
  }

  // For debugging purposes - store the last token
  String? _lastToken;
  String? get lastToken => _lastToken;
}
