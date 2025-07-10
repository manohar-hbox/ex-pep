import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'send_email_widget.dart' show SendEmailWidget;
import 'package:flutter/material.dart';

class SendEmailModel extends FlutterFlowModel<SendEmailWidget> {
  ///  State fields for stateful widgets in this component.

  final formKey = GlobalKey<FormState>();
  // State field(s) for txtEmailAddress widget.
  FocusNode? txtEmailAddressFocusNode;
  TextEditingController? txtEmailAddressTextController;
  String? Function(BuildContext, String?)?
      txtEmailAddressTextControllerValidator;
  String? _txtEmailAddressTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Email is required';
    }

    return null;
  }

  // State field(s) for txtSheetPassword widget.
  FocusNode? txtSheetPasswordFocusNode;
  TextEditingController? txtSheetPasswordTextController;
  late bool txtSheetPasswordVisibility;
  String? Function(BuildContext, String?)?
      txtSheetPasswordTextControllerValidator;
  String? _txtSheetPasswordTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Enter Password to Protect Excel Sheet is required';
    }

    return null;
  }

  // Stores action output result for [Custom Action - processesEmailAddresses] action in Button widget.
  List<String>? processedEmailAddresses;
  // Stores action output result for [Backend Call - API (Send Email)] action in Button widget.
  ApiCallResponse? sendEmail;

  @override
  void initState(BuildContext context) {
    txtEmailAddressTextControllerValidator =
        _txtEmailAddressTextControllerValidator;
    txtSheetPasswordVisibility = false;
    txtSheetPasswordTextControllerValidator =
        _txtSheetPasswordTextControllerValidator;
  }

  @override
  void dispose() {
    txtEmailAddressFocusNode?.dispose();
    txtEmailAddressTextController?.dispose();

    txtSheetPasswordFocusNode?.dispose();
    txtSheetPasswordTextController?.dispose();
  }
}
