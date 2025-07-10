// filepath: C:\Users\DELL\StudioProjects\pep\lib\custom_code\services\twilio_client_manager.dart
// Manager to initialize and maintain Twilio client state for incoming calls

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'twilio_background_service.dart';
import 'twilio_token_service.dart';

/// Manages the Twilio client for incoming and outgoing calls
class TwilioClientManager {
  // Singleton instance
  static final TwilioClientManager _instance = TwilioClientManager._internal();
  factory TwilioClientManager() => _instance;
  TwilioClientManager._internal();

  // Services
  final TwilioBackgroundService _backgroundService = TwilioBackgroundService();
  final TwilioTokenService _tokenService = TwilioTokenService();

  // State
  bool _isRegistered = false;
  String? _currentIdentity;
  Timer? _tokenRefreshTimer;

  // Getters
  bool get isRegistered => _isRegistered;
  String? get currentIdentity => _currentIdentity;

  /// Register this device to receive incoming calls with the given identity
  Future<bool> registerForIncomingCalls(String identity, bool isSetForIncomingCall) async {
    try {
      print('Registering for incoming calls with identity: $identity');

      // Get a new token from the backend
      final token = await _tokenService.getToken(identity);

      if(isSetForIncomingCall) {
        // Initialize the background service with this token
        final initialized = await _backgroundService.initialize(token);

        if (initialized) {
          _isRegistered = true;
          _currentIdentity = identity;

          // Set up token refresh timer (tokens typically expire after 1 hour)
          _setupTokenRefreshTimer(identity);

          print('Successfully registered for incoming calls');
          return true;
        } else {
          print('Failed to initialize background service for incoming calls');
          _isRegistered = false;
          return false;
        }
      } else {
        return true; // If not set for incoming calls, just return true
      }
    } catch (e) {
      print('Error registering for incoming calls: $e');
      _isRegistered = false;
      return false;
    }
  }

  /// Set up a timer to refresh the token periodically (every 45 minutes)
  void _setupTokenRefreshTimer(String identity) {
    _tokenRefreshTimer?.cancel();
    _tokenRefreshTimer = Timer.periodic(Duration(minutes: 45), (timer) async {
      try {
        print('Refreshing Twilio token for identity: $identity');
        final token = await _tokenService.getToken(identity);

        // Reinitialize with new token
        final refreshed = await _backgroundService.initialize(token);

        if (refreshed) {
          print('Successfully refreshed Twilio token');
          _isRegistered = true;
        } else {
          print('Failed to refresh Twilio token');
          _isRegistered = false;
        }
      } catch (e) {
        print('Error refreshing Twilio token: $e');
        _isRegistered = false;
      }
    });
  }

  /// Unregister from receiving incoming calls
  void unregisterFromIncomingCalls() {
    _tokenRefreshTimer?.cancel();
    _tokenRefreshTimer = null;
    _isRegistered = false;
    _currentIdentity = null;

    // We don't need to do anything to the background service,
    // as the token will simply expire
  }

  /// Handle application lifecycle events to maintain client registration
  void handleAppLifecycleState(AppLifecycleState state) {
    if (_currentIdentity == null) return;

    if (state == AppLifecycleState.resumed) {
      // App came to foreground, refresh registration
      registerForIncomingCalls(_currentIdentity!, true);
    } else if (state == AppLifecycleState.paused) {
      // App went to background, but we keep the registration active
      // so incoming calls can still be received
      print('App paused but keeping Twilio client active for incoming calls');
    }
  }

  void dispose() {
    _tokenRefreshTimer?.cancel();
  }
}
