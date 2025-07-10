import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'clinic_time_slots_adder_widget.dart' show ClinicTimeSlotsAdderWidget;
import 'package:flutter/material.dart';

class ClinicTimeSlotsAdderModel
    extends FlutterFlowModel<ClinicTimeSlotsAdderWidget> {
  ///  Local state fields for this component.

  dynamic facilityData;

  ///  State fields for stateful widgets in this component.

  final formKey = GlobalKey<FormState>();
  // State field(s) for ClinicSelect widget.
  int? clinicSelectValue;
  FormFieldController<int>? clinicSelectValueController;
  // Stores action output result for [Backend Call - API (GQLgetFacilityNames)] action in ClinicSelect widget.
  ApiCallResponse? getFacility;
  // State field(s) for FacilityNameSelect widget.
  int? facilityNameSelectValue;
  FormFieldController<int>? facilityNameSelectValueController;
  // State field(s) for DaysOfWeek widget.
  List<String>? daysOfWeekValue;
  FormFieldController<List<String>>? daysOfWeekValueController;
  DateTime? datePicked1;
  DateTime? datePicked2;
  DateTime? datePicked3;
  DateTime? datePicked4;
  // State field(s) for txtTimeSlotsDuration widget.
  FocusNode? txtTimeSlotsDurationFocusNode;
  TextEditingController? txtTimeSlotsDurationTextController;
  String? Function(BuildContext, String?)?
      txtTimeSlotsDurationTextControllerValidator;
  // Stores action output result for [Backend Call - API (Create Clinic Appointments)] action in Button widget.
  ApiCallResponse? createSlots;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    txtTimeSlotsDurationFocusNode?.dispose();
    txtTimeSlotsDurationTextController?.dispose();
  }
}
