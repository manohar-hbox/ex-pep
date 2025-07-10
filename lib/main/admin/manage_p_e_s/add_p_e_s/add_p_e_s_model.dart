import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'add_p_e_s_widget.dart' show AddPESWidget;
import 'package:flutter/material.dart';

class AddPESModel extends FlutterFlowModel<AddPESWidget> {
  ///  Local state fields for this component.

  bool? taskAssigned;

  bool? followUpTasks;

  ///  State fields for stateful widgets in this component.

  final formKey = GlobalKey<FormState>();
  // State field(s) for firstNamePES widget.
  FocusNode? firstNamePESFocusNode;
  TextEditingController? firstNamePESTextController;
  String? Function(BuildContext, String?)? firstNamePESTextControllerValidator;
  String? _firstNamePESTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Field is required';
    }

    if (!RegExp('^[a-zA-Z ]*\$').hasMatch(val)) {
      return 'Text Only';
    }
    return null;
  }

  // State field(s) for lastNamePES widget.
  FocusNode? lastNamePESFocusNode;
  TextEditingController? lastNamePESTextController;
  String? Function(BuildContext, String?)? lastNamePESTextControllerValidator;
  String? _lastNamePESTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Field is required';
    }

    if (!RegExp('^[a-zA-Z ]*\$').hasMatch(val)) {
      return 'Text Only';
    }
    return null;
  }

  // State field(s) for emailPES widget.
  FocusNode? emailPESFocusNode;
  TextEditingController? emailPESTextController;
  String? Function(BuildContext, String?)? emailPESTextControllerValidator;
  String? _emailPESTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Field is required';
    }

    if (!RegExp(kTextValidatorEmailRegex).hasMatch(val)) {
      return 'Email Only';
    }
    return null;
  }

  // State field(s) for Deferred widget.
  bool? deferredValue;
  // State field(s) for FollowUp widget.
  bool? followUpValue;
  // State field(s) for passwordPES widget.
  FocusNode? passwordPESFocusNode;
  TextEditingController? passwordPESTextController;
  late bool passwordPESVisibility;
  String? Function(BuildContext, String?)? passwordPESTextControllerValidator;
  String? _passwordPESTextControllerValidator(
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

  // State field(s) for reEnterPasswordPES widget.
  FocusNode? reEnterPasswordPESFocusNode;
  TextEditingController? reEnterPasswordPESTextController;
  late bool reEnterPasswordPESVisibility;
  String? Function(BuildContext, String?)?
      reEnterPasswordPESTextControllerValidator;
  String? _reEnterPasswordPESTextControllerValidator(
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

  // State field(s) for ClinicSelectPES widget.
  List<int>? clinicSelectPESValue;
  FormFieldController<List<int>>? clinicSelectPESValueController;
  // Stores action output result for [Backend Call - API (Create PES )] action in Button widget.
  ApiCallResponse? createPES;

  @override
  void initState(BuildContext context) {
    firstNamePESTextControllerValidator = _firstNamePESTextControllerValidator;
    lastNamePESTextControllerValidator = _lastNamePESTextControllerValidator;
    emailPESTextControllerValidator = _emailPESTextControllerValidator;
    passwordPESVisibility = false;
    passwordPESTextControllerValidator = _passwordPESTextControllerValidator;
    reEnterPasswordPESVisibility = false;
    reEnterPasswordPESTextControllerValidator =
        _reEnterPasswordPESTextControllerValidator;
  }

  @override
  void dispose() {
    firstNamePESFocusNode?.dispose();
    firstNamePESTextController?.dispose();

    lastNamePESFocusNode?.dispose();
    lastNamePESTextController?.dispose();

    emailPESFocusNode?.dispose();
    emailPESTextController?.dispose();

    passwordPESFocusNode?.dispose();
    passwordPESTextController?.dispose();

    reEnterPasswordPESFocusNode?.dispose();
    reEnterPasswordPESTextController?.dispose();
  }
}
