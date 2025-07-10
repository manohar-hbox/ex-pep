import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_data_table.dart';
import '/flutter_flow/flutter_flow_timer.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/flutter_flow/instant_timer.dart';
import '/index.dart';
import 'p_e_s_patient_detail_widget.dart' show PESPatientDetailWidget;
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:flutter/material.dart';

class PESPatientDetailModel extends FlutterFlowModel<PESPatientDetailWidget> {
  ///  Local state fields for this page.

  int ccmStatus = 0;

  int rpmStatus = 0;

  int? patientTimerState = 0;

  String? patientTimerLogId;

  List<String> outboundNumbers = [];
  void addToOutboundNumbers(String item) => outboundNumbers.add(item);
  void removeFromOutboundNumbers(String item) => outboundNumbers.remove(item);
  void removeAtIndexFromOutboundNumbers(int index) =>
      outboundNumbers.removeAt(index);
  void insertAtIndexInOutboundNumbers(int index, String item) =>
      outboundNumbers.insert(index, item);
  void updateOutboundNumbersAtIndex(int index, Function(String) updateFn) =>
      outboundNumbers[index] = updateFn(outboundNumbers[index]);

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (Create Patient Timer Log)] action in PESPatientDetail widget.
  ApiCallResponse? createPatientTimeButtonPESLog;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in PESPatientDetail widget.
  ApiCallResponse? getPatientDetails;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in PESPatientDetail widget.
  ApiCallResponse? getIfPatientCanMakeOutgoingCallResponse;
  InstantTimer? instantTimer;
  // Stores action output result for [Custom Action - isTabMinimized] action in PESPatientDetail widget.
  bool? isTabMinimized;
  // Stores action output result for [Backend Call - API (Update Timer Log)] action in PESPatientDetail widget.
  ApiCallResponse? updateTimerPageLoad;
  // Stores action output result for [Backend Call - API (Update Patient Timer Log)] action in PESPatientDetail widget.
  ApiCallResponse? patientTimerUpdatePageLoad;
  InstantTimer? instantTimerNested;
  // Stores action output result for [Custom Action - isTabMinimized] action in PlayIconButton widget.
  bool? isTabMinimizedNested;
  // Stores action output result for [Backend Call - API (Update Timer Log)] action in PlayIconButton widget.
  ApiCallResponse? updateTimerPlayButton;
  // Stores action output result for [Backend Call - API (Update Patient Timer Log)] action in PlayIconButton widget.
  ApiCallResponse? patientTimerUpdatePlayButton;
  // State field(s) for SessionTimer widget.
  final sessionTimerInitialTimeMs1 = 0;
  int sessionTimerMilliseconds1 = 0;
  String sessionTimerValue1 = StopWatchTimer.getDisplayTime(
    0,
    hours: false,
    milliSecond: false,
  );
  FlutterFlowTimerController sessionTimerController1 =
      FlutterFlowTimerController(StopWatchTimer(mode: StopWatchMode.countUp));

  InstantTimer? patientInstantTimerNested;
  // Stores action output result for [Custom Action - isTabMinimized] action in PatientPlayIconButton widget.
  bool? isTabMinimizedNestedPatient;
  // Stores action output result for [Backend Call - API (Update Timer Log)] action in PatientPlayIconButton widget.
  ApiCallResponse? updatePatientTimerPlayButton;
  // Stores action output result for [Backend Call - API (Update Patient Timer Log)] action in PatientPlayIconButton widget.
  ApiCallResponse? updatePatientTimerPlayBtn;
  // State field(s) for SessionTimer widget.
  final sessionTimerInitialTimeMs2 = 0;
  int sessionTimerMilliseconds2 = 0;
  String sessionTimerValue2 = StopWatchTimer.getDisplayTime(
    0,
    hours: false,
    milliSecond: false,
  );
  FlutterFlowTimerController sessionTimerController2 =
      FlutterFlowTimerController(StopWatchTimer(mode: StopWatchMode.countUp));

  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in btnCallPatient widget.
  ApiCallResponse? lisOfOutboundNumbers;
  // Stores action output result for [Custom Action - getOutboundNumbersFromResponse] action in btnCallPatient widget.
  List<String>? listOfProcessedOutboundNo;
  // State field(s) for PaginatedDataTable widget.
  final paginatedDataTableController =
      FlutterFlowDataTableController<dynamic>();
  // State field(s) for rpmStatus widget.
  int? rpmStatusValue;
  FormFieldController<int>? rpmStatusValueController;
  // State field(s) for facility widget.
  int? facilityValue;
  FormFieldController<int>? facilityValueController;
  // State field(s) for RPMAppDate widget.
  String? rPMAppDateValue;
  FormFieldController<String>? rPMAppDateValueController;
  // State field(s) for RPMAppTime widget.
  String? rPMAppTimeValue;
  FormFieldController<String>? rPMAppTimeValueController;
  // State field(s) for Comment widget.
  FocusNode? commentFocusNode;
  TextEditingController? commentTextController;
  String? Function(BuildContext, String?)? commentTextControllerValidator;
  // Stores action output result for [Backend Call - API (Update Patient)] action in Button widget.
  ApiCallResponse? updatePatient;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    instantTimer?.cancel();
    instantTimerNested?.cancel();
    sessionTimerController1.dispose();
    patientInstantTimerNested?.cancel();
    sessionTimerController2.dispose();
    paginatedDataTableController.dispose();
    commentFocusNode?.dispose();
    commentTextController?.dispose();
  }
}
