import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'send_s_m_s_widget.dart' show SendSMSWidget;
import 'package:flutter/material.dart';

class SendSMSModel extends FlutterFlowModel<SendSMSWidget> {
  ///  Local state fields for this component.

  String? template;

  ///  State fields for stateful widgets in this component.

  final formKey = GlobalKey<FormState>();
  // State field(s) for templateSelect widget.
  String? templateSelectValue;
  FormFieldController<String>? templateSelectValueController;
  // State field(s) for txtPhoneNumber widget.
  FocusNode? txtPhoneNumberFocusNode;
  TextEditingController? txtPhoneNumberTextController;
  String? Function(BuildContext, String?)?
      txtPhoneNumberTextControllerValidator;
  String? _txtPhoneNumberTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Phone Number is required';
    }

    if (!RegExp('^\\(?\\d{3}\\)?[-.\\s]?\\d{3}[-.\\s]?\\d{4}\$')
        .hasMatch(val)) {
      return 'Invalid Phone Number';
    }
    return null;
  }

  // State field(s) for textFieldSMS widget.
  FocusNode? textFieldSMSFocusNode;
  TextEditingController? textFieldSMSTextController;
  String? Function(BuildContext, String?)? textFieldSMSTextControllerValidator;
  // Stores action output result for [Backend Call - API (Send SMS)] action in Button widget.
  ApiCallResponse? sendSMS;

  @override
  void initState(BuildContext context) {
    txtPhoneNumberTextControllerValidator =
        _txtPhoneNumberTextControllerValidator;
  }

  @override
  void dispose() {
    txtPhoneNumberFocusNode?.dispose();
    txtPhoneNumberTextController?.dispose();

    textFieldSMSFocusNode?.dispose();
    textFieldSMSTextController?.dispose();
  }
}
