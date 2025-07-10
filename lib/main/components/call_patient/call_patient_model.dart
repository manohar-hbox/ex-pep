import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'call_patient_widget.dart' show CallPatientWidget;
import 'package:flutter/material.dart';

class CallPatientModel extends FlutterFlowModel<CallPatientWidget> {
  ///  Local state fields for this component.

  String? selectedPatientNo;

  String? selectedOutboundNo;

  ///  State fields for stateful widgets in this component.

  final formKey = GlobalKey<FormState>();
  // State field(s) for MobNoCheckbox widget.
  bool? mobNoCheckboxValue;
  // State field(s) for HomNoCheckbox widget.
  bool? homNoCheckboxValue;
  // State field(s) for OutbountNoDropDown widget.
  String? outbountNoDropDownValue;
  FormFieldController<String>? outbountNoDropDownValueController;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
