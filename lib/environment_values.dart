import 'dart:convert';
import 'package:flutter/services.dart';

class FFDevEnvironmentValues {
  static const String currentEnvironment = 'Production';
  static const String environmentValuesPath =
      'assets/environment_values/environment.json';

  static final FFDevEnvironmentValues _instance =
      FFDevEnvironmentValues._internal();

  factory FFDevEnvironmentValues() {
    return _instance;
  }

  FFDevEnvironmentValues._internal();

  Future<void> initialize() async {
    try {
      final String response =
          await rootBundle.loadString(environmentValuesPath);
      final data = await json.decode(response);
      _baseUrl = data['baseUrl'];
      _graphQLBaseURL = data['graphQLBaseURL'];
      _websocketGraphQLSubscriptionURL =
          data['websocketGraphQLSubscriptionURL'];
    } catch (e) {
      print('Error loading environment values: $e');
    }
  }

  String _baseUrl = '';
  String get baseUrl => _baseUrl;

  String _graphQLBaseURL = '';
  String get graphQLBaseURL => _graphQLBaseURL;

  String _websocketGraphQLSubscriptionURL = '';
  String get websocketGraphQLSubscriptionURL =>
      _websocketGraphQLSubscriptionURL;
}
