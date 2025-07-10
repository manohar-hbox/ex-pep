import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'update_v_p_e_widget.dart' show UpdateVPEWidget;
import 'package:flutter/material.dart';

class UpdateVPEModel extends FlutterFlowModel<UpdateVPEWidget> {
  ///  State fields for stateful widgets in this component.

  final formKey = GlobalKey<FormState>();
  // State field(s) for updatedFirstNameVPE widget.
  FocusNode? updatedFirstNameVPEFocusNode;
  TextEditingController? updatedFirstNameVPETextController;
  String? Function(BuildContext, String?)?
      updatedFirstNameVPETextControllerValidator;
  String? _updatedFirstNameVPETextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Field is required';
    }

    if (!RegExp('^[a-zA-Z ]*\$').hasMatch(val)) {
      return 'Text Only';
    }
    return null;
  }

  // State field(s) for updatedLastNameVPE widget.
  FocusNode? updatedLastNameVPEFocusNode;
  TextEditingController? updatedLastNameVPETextController;
  String? Function(BuildContext, String?)?
      updatedLastNameVPETextControllerValidator;
  String? _updatedLastNameVPETextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Field is required';
    }

    if (!RegExp('^[a-zA-Z ]*\$').hasMatch(val)) {
      return 'Text Only';
    }
    return null;
  }

  // State field(s) for updatedEmailVPE widget.
  FocusNode? updatedEmailVPEFocusNode;
  TextEditingController? updatedEmailVPETextController;
  String? Function(BuildContext, String?)?
      updatedEmailVPETextControllerValidator;
  String? _updatedEmailVPETextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Field is required';
    }

    if (!RegExp(kTextValidatorEmailRegex).hasMatch(val)) {
      return 'Text Only';
    }
    return null;
  }

  // State field(s) for Checkbox widget.
  bool? checkboxValue;
  // State field(s) for updatedPasswordVPE widget.
  FocusNode? updatedPasswordVPEFocusNode;
  TextEditingController? updatedPasswordVPETextController;
  late bool updatedPasswordVPEVisibility;
  String? Function(BuildContext, String?)?
      updatedPasswordVPETextControllerValidator;
  // State field(s) for updatedReEnterPasswordVPE widget.
  FocusNode? updatedReEnterPasswordVPEFocusNode;
  TextEditingController? updatedReEnterPasswordVPETextController;
  late bool updatedReEnterPasswordVPEVisibility;
  String? Function(BuildContext, String?)?
      updatedReEnterPasswordVPETextControllerValidator;
  // Stores action output result for [Backend Call - API (Update VPE)] action in Button widget.
  ApiCallResponse? updateVPE;

  @override
  void initState(BuildContext context) {
    updatedFirstNameVPETextControllerValidator =
        _updatedFirstNameVPETextControllerValidator;
    updatedLastNameVPETextControllerValidator =
        _updatedLastNameVPETextControllerValidator;
    updatedEmailVPETextControllerValidator =
        _updatedEmailVPETextControllerValidator;
    updatedPasswordVPEVisibility = false;
    updatedReEnterPasswordVPEVisibility = false;
  }

  @override
  void dispose() {
    updatedFirstNameVPEFocusNode?.dispose();
    updatedFirstNameVPETextController?.dispose();

    updatedLastNameVPEFocusNode?.dispose();
    updatedLastNameVPETextController?.dispose();

    updatedEmailVPEFocusNode?.dispose();
    updatedEmailVPETextController?.dispose();

    updatedPasswordVPEFocusNode?.dispose();
    updatedPasswordVPETextController?.dispose();

    updatedReEnterPasswordVPEFocusNode?.dispose();
    updatedReEnterPasswordVPETextController?.dispose();
  }
}
