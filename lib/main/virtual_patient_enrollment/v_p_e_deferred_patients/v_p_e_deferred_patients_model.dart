import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_data_table.dart';
import '/flutter_flow/flutter_flow_timer.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/flutter_flow/instant_timer.dart';
import '/index.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'v_p_e_deferred_patients_widget.dart' show VPEDeferredPatientsWidget;
import 'package:flutter/material.dart';

class VPEDeferredPatientsModel
    extends FlutterFlowModel<VPEDeferredPatientsWidget> {
  ///  Local state fields for this page.

  int? ccmStatus;

  int? patientTimerState = 0;

  String? patientTimerLogId;

  int? transferredPatientId;

  bool isTransferPatientExecuted = false;

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

  // Stores action output result for [Backend Call - API (Create Patient Timer Log)] action in VPEDeferredPatients widget.
  ApiCallResponse? createPatientTimeButtonVPEDeferredLog;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in VPEDeferredPatients widget.
  ApiCallResponse? getVPEDeferredPatients;
  InstantTimer? instantTimer;
  // Stores action output result for [Custom Action - isTabMinimized] action in VPEDeferredPatients widget.
  bool? isTabMinimized;
  // Stores action output result for [Backend Call - API (Update Timer Log)] action in VPEDeferredPatients widget.
  ApiCallResponse? updateTimerPlayButtonVPE;
  // Stores action output result for [Backend Call - API (Update Patient Timer Log)] action in VPEDeferredPatients widget.
  ApiCallResponse? updatePatientTimerPlayButtonVPE;
  InstantTimer? instantTimerNested;
  // Stores action output result for [Custom Action - isTabMinimized] action in PlayIconButton widget.
  bool? isTabMinimizedNested;
  // Stores action output result for [Backend Call - API (Update Timer Log)] action in PlayIconButton widget.
  ApiCallResponse? updatePlayBtnVpe;
  // Stores action output result for [Backend Call - API (Update Patient Timer Log)] action in PlayIconButton widget.
  ApiCallResponse? updatePatientTimerPlayBtnVpe;
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

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode2;
  TextEditingController? textController2;
  String? Function(BuildContext, String?)? textController2Validator;
  // State field(s) for tfMobileNumber widget.
  FocusNode? tfMobileNumberFocusNode;
  TextEditingController? tfMobileNumberTextController;
  String? Function(BuildContext, String?)?
      tfMobileNumberTextControllerValidator;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in btnCallPatient widget.
  ApiCallResponse? lisOfOutboundNumbers;
  // Stores action output result for [Custom Action - getOutboundNumbersFromResponse] action in btnCallPatient widget.
  List<String>? listOfProcessedOutboundNo;
  // State field(s) for tfHomeNumber widget.
  FocusNode? tfHomeNumberFocusNode;
  TextEditingController? tfHomeNumberTextController;
  String? Function(BuildContext, String?)? tfHomeNumberTextControllerValidator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode3;
  TextEditingController? textController5;
  String? Function(BuildContext, String?)? textController5Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode4;
  TextEditingController? textController6;
  String? Function(BuildContext, String?)? textController6Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode5;
  TextEditingController? textController7;
  String? Function(BuildContext, String?)? textController7Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode6;
  TextEditingController? textController8;
  String? Function(BuildContext, String?)? textController8Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode7;
  TextEditingController? textController9;
  String? Function(BuildContext, String?)? textController9Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode8;
  TextEditingController? textController10;
  String? Function(BuildContext, String?)? textController10Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode9;
  TextEditingController? textController11;
  String? Function(BuildContext, String?)? textController11Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode10;
  TextEditingController? textController12;
  String? Function(BuildContext, String?)? textController12Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode11;
  TextEditingController? textController13;
  String? Function(BuildContext, String?)? textController13Validator;
  // State field(s) for checkboxPatientReceivedLetter widget.
  bool? checkboxPatientReceivedLetterValue;
  // State field(s) for checkboxPatientDownloadedApp widget.
  bool? checkboxPatientDownloadedAppValue;
  // State field(s) for PaginatedDataTable widget.
  final paginatedDataTableController =
      FlutterFlowDataTableController<dynamic>();
  // State field(s) for ccmStatus widget.
  int? ccmStatusValue1;
  FormFieldController<int>? ccmStatusValueController1;
  // State field(s) for ccmStatus widget.
  int? ccmStatusValue2;
  FormFieldController<int>? ccmStatusValueController2;
  DateTime? datePicked;
  // State field(s) for Comment widget.
  FocusNode? commentFocusNode;
  TextEditingController? commentTextController;
  String? Function(BuildContext, String?)? commentTextControllerValidator;
  // State field(s) for RadioButton widget.
  FormFieldController<String>? radioButtonValueController;
  // State field(s) for CheckboxGroup widget.
  FormFieldController<List<String>>? checkboxGroupValueController;
  List<String>? get checkboxGroupValues => checkboxGroupValueController?.value;
  set checkboxGroupValues(List<String>? v) =>
      checkboxGroupValueController?.value = v;

  // State field(s) for checkboxCSAcceptedTransfer widget.
  bool? checkboxCSAcceptedTransferValue;
  // Stores action output result for [Backend Call - API (Invalidate Transferred Patient)] action in IconButton widget.
  ApiCallResponse? invalidateTransferPatientDetailsFromCancel;
  // Stores action output result for [Backend Call - API (Invalidate Transferred Patient)] action in btnTransfer widget.
  ApiCallResponse? invalidateTransferDeferredPatientDetails;
  // Stores action output result for [Backend Call - API (Update Transferred Patient)] action in btnTransfer widget.
  ApiCallResponse? saveTransferDeferredPatientDetails;
  // Stores action output result for [Custom Action - getCSFromTransferredPatientSubscription] action in btnTransfer widget.
  String? transferredCSName;
  // Stores action output result for [Backend Call - API (Update Patient)] action in Button widget.
  ApiCallResponse? updateDeferredPatient;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in Button widget.
  ApiCallResponse? deferredResponse;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in Button widget.
  ApiCallResponse? deferredPatient;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    instantTimer?.cancel();
    instantTimerNested?.cancel();
    sessionTimerController1.dispose();
    patientInstantTimerNested?.cancel();
    sessionTimerController2.dispose();
    textFieldFocusNode1?.dispose();
    textController1?.dispose();

    textFieldFocusNode2?.dispose();
    textController2?.dispose();

    tfMobileNumberFocusNode?.dispose();
    tfMobileNumberTextController?.dispose();

    tfHomeNumberFocusNode?.dispose();
    tfHomeNumberTextController?.dispose();

    textFieldFocusNode3?.dispose();
    textController5?.dispose();

    textFieldFocusNode4?.dispose();
    textController6?.dispose();

    textFieldFocusNode5?.dispose();
    textController7?.dispose();

    textFieldFocusNode6?.dispose();
    textController8?.dispose();

    textFieldFocusNode7?.dispose();
    textController9?.dispose();

    textFieldFocusNode8?.dispose();
    textController10?.dispose();

    textFieldFocusNode9?.dispose();
    textController11?.dispose();

    textFieldFocusNode10?.dispose();
    textController12?.dispose();

    textFieldFocusNode11?.dispose();
    textController13?.dispose();

    paginatedDataTableController.dispose();
    commentFocusNode?.dispose();
    commentTextController?.dispose();
  }

  /// Additional helper methods.
  String? get radioButtonValue => radioButtonValueController?.value;
}
