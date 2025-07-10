import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'add_v_p_e_widget.dart' show AddVPEWidget;
import 'package:flutter/material.dart';

class AddVPEModel extends FlutterFlowModel<AddVPEWidget> {
  ///  Local state fields for this component.

  bool? taskAssigned;

  ///  State fields for stateful widgets in this component.

  final formKey = GlobalKey<FormState>();
  // State field(s) for firstNameVPE widget.
  FocusNode? firstNameVPEFocusNode;
  TextEditingController? firstNameVPETextController;
  String? Function(BuildContext, String?)? firstNameVPETextControllerValidator;
  String? _firstNameVPETextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Field is required';
    }

    if (!RegExp('^[a-zA-Z ]*\$').hasMatch(val)) {
      return 'Text Only';
    }
    return null;
  }

  // State field(s) for lastNameVPE widget.
  FocusNode? lastNameVPEFocusNode;
  TextEditingController? lastNameVPETextController;
  String? Function(BuildContext, String?)? lastNameVPETextControllerValidator;
  String? _lastNameVPETextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Field is required';
    }

    if (!RegExp('^[a-zA-Z ]*\$').hasMatch(val)) {
      return 'Text Only';
    }
    return null;
  }

  // State field(s) for emailVPE widget.
  FocusNode? emailVPEFocusNode;
  TextEditingController? emailVPETextController;
  String? Function(BuildContext, String?)? emailVPETextControllerValidator;
  String? _emailVPETextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Field is required';
    }

    if (!RegExp(kTextValidatorEmailRegex).hasMatch(val)) {
      return 'Email Only';
    }
    return null;
  }

  // State field(s) for Checkbox widget.
  bool? checkboxValue;
  // State field(s) for passwordVPE widget.
  FocusNode? passwordVPEFocusNode;
  TextEditingController? passwordVPETextController;
  late bool passwordVPEVisibility;
  String? Function(BuildContext, String?)? passwordVPETextControllerValidator;
  String? _passwordVPETextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Field is required';
    }

    if (val.length < 6) {
      return 'Atleast 6 characters required';
    }
    if (val.length > 32) {
      return 'Password should not exceed 32 characters';
    }

    return null;
  }

  // State field(s) for reEnterPasswordVPE widget.
  FocusNode? reEnterPasswordVPEFocusNode;
  TextEditingController? reEnterPasswordVPETextController;
  late bool reEnterPasswordVPEVisibility;
  String? Function(BuildContext, String?)?
      reEnterPasswordVPETextControllerValidator;
  String? _reEnterPasswordVPETextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Field is required';
    }

    if (val.length < 6) {
      return 'Atleast 6 characters required';
    }
    if (val.length > 32) {
      return 'Password should not exceed 32 characters';
    }

    return null;
  }

  // Stores action output result for [Backend Call - API (Create VPE)] action in Button widget.
  ApiCallResponse? createVPE;

  @override
  void initState(BuildContext context) {
    firstNameVPETextControllerValidator = _firstNameVPETextControllerValidator;
    lastNameVPETextControllerValidator = _lastNameVPETextControllerValidator;
    emailVPETextControllerValidator = _emailVPETextControllerValidator;
    passwordVPEVisibility = false;
    passwordVPETextControllerValidator = _passwordVPETextControllerValidator;
    reEnterPasswordVPEVisibility = false;
    reEnterPasswordVPETextControllerValidator =
        _reEnterPasswordVPETextControllerValidator;
  }

  @override
  void dispose() {
    firstNameVPEFocusNode?.dispose();
    firstNameVPETextController?.dispose();

    lastNameVPEFocusNode?.dispose();
    lastNameVPETextController?.dispose();

    emailVPEFocusNode?.dispose();
    emailVPETextController?.dispose();

    passwordVPEFocusNode?.dispose();
    passwordVPETextController?.dispose();

    reEnterPasswordVPEFocusNode?.dispose();
    reEnterPasswordVPETextController?.dispose();
  }
}
