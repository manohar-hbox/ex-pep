import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'login_widget.dart' show LoginWidget;
import 'package:flutter/material.dart';

class LoginModel extends FlutterFlowModel<LoginWidget> {
  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  // State field(s) for emailAddress widget.
  FocusNode? emailAddressFocusNode;
  TextEditingController? emailAddressTextController;
  String? Function(BuildContext, String?)? emailAddressTextControllerValidator;
  String? _emailAddressTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Field is required';
    }

    if (!RegExp(kTextValidatorEmailRegex).hasMatch(val)) {
      return 'Email Only';
    }
    return null;
  }

  // State field(s) for password widget.
  FocusNode? passwordFocusNode;
  TextEditingController? passwordTextController;
  late bool passwordVisibility;
  String? Function(BuildContext, String?)? passwordTextControllerValidator;
  String? _passwordTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Field is required';
    }

    if (val.length < 6) {
      return 'Atleast 6  characters required';
    }
    if (val.length > 32) {
      return 'Password  should not exceed  32 characters';
    }

    return null;
  }

  // Stores action output result for [Backend Call - API (LoginAPI)] action in password widget.
  ApiCallResponse? loginResponseEnterKey;
  // Stores action output result for [Backend Call - API (GetProfile)] action in password widget.
  ApiCallResponse? getProfileResponseEnterKey;
  // Stores action output result for [Backend Call - API (GetHasuraToken)] action in password widget.
  ApiCallResponse? getHasuraEnterKey;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in password widget.
  ApiCallResponse? usernamesEnterKey;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in password widget.
  ApiCallResponse? currentPatientEnterKey;
  // Stores action output result for [Backend Call - API (Create Timer Log)] action in password widget.
  ApiCallResponse? createTimeEnterESLog;
  // Stores action output result for [Backend Call - API (Create Timer Log)] action in password widget.
  ApiCallResponse? createTimeEnterESEmptyLog;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in password widget.
  ApiCallResponse? getCSClinicsEnterKey;
  // Stores action output result for [Backend Call - API (Create Timer Log)] action in password widget.
  ApiCallResponse? createTimeEnterCSLog;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in password widget.
  ApiCallResponse? getPESClinicsEnterKey;
  // Stores action output result for [Backend Call - API (Create Timer Log)] action in password widget.
  ApiCallResponse? createTimeEnterPELog;
  // Stores action output result for [Custom Action - getStoredRedirectURL] action in password widget.
  String? storedRedirectEnterURL;
  // Stores action output result for [Backend Call - API (LoginAPI)] action in Button widget.
  ApiCallResponse? loginResponse;
  // Stores action output result for [Backend Call - API (GetProfile)] action in Button widget.
  ApiCallResponse? getProfileResponse;
  // Stores action output result for [Backend Call - API (GetHasuraToken)] action in Button widget.
  ApiCallResponse? getHasura;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in Button widget.
  ApiCallResponse? usernames;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in Button widget.
  ApiCallResponse? currentPatient;
  // Stores action output result for [Backend Call - API (Create Timer Log)] action in Button widget.
  ApiCallResponse? createTimeBtnESLog;
  // Stores action output result for [Backend Call - API (Create Timer Log)] action in Button widget.
  ApiCallResponse? createTimeBtnESEmptyLog;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in Button widget.
  ApiCallResponse? getCSClinics;
  // Stores action output result for [Backend Call - API (Create Timer Log)] action in Button widget.
  ApiCallResponse? createTimeBtnCSLog;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in Button widget.
  ApiCallResponse? getPESClinics;
  // Stores action output result for [Backend Call - API (Create Timer Log)] action in Button widget.
  ApiCallResponse? createTimeBtnPESLog;
  // Stores action output result for [Custom Action - getStoredRedirectURL] action in Button widget.
  String? storedRedirectURL;

  @override
  void initState(BuildContext context) {
    emailAddressTextControllerValidator = _emailAddressTextControllerValidator;
    passwordVisibility = false;
    passwordTextControllerValidator = _passwordTextControllerValidator;
  }

  @override
  void dispose() {
    emailAddressFocusNode?.dispose();
    emailAddressTextController?.dispose();

    passwordFocusNode?.dispose();
    passwordTextController?.dispose();
  }
}
