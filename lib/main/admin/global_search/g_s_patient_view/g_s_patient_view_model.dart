import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_data_table.dart';
import '/flutter_flow/flutter_flow_timer.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/flutter_flow/instant_timer.dart';
import '/index.dart';
import 'g_s_patient_view_widget.dart' show GSPatientViewWidget;
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:flutter/material.dart';

class GSPatientViewModel extends FlutterFlowModel<GSPatientViewWidget> {
  ///  Local state fields for this page.

  int? ccmStatus;

  int? rpmStatus;

  bool saveConfirm = false;

  int? transferredPatientId;

  bool isTransferPatientExecuted = false;

  String? txtDefaultComment;

  String? patientTimerLogId;

  int? patientTimerState = 0;

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

  // Stores action output result for [Backend Call - API (Create Patient Timer Log)] action in GSPatientView widget.
  ApiCallResponse? createPatientTimeButtongGSLog;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in GSPatientView widget.
  ApiCallResponse? getPatientDetails;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in GSPatientView widget.
  ApiCallResponse? getIfPatientCanMakeOutgoingCallResponse;
  InstantTimer? instantTimer;
  // Stores action output result for [Custom Action - isTabMinimized] action in GSPatientView widget.
  bool? isTabMinimized;
  // Stores action output result for [Backend Call - API (Update Timer Log)] action in GSPatientView widget.
  ApiCallResponse? updateTimerPageLoad;
  // Stores action output result for [Backend Call - API (Update Patient Timer Log)] action in GSPatientView widget.
  ApiCallResponse? patientTimerUpdatePageLoad;
  InstantTimer? InstantTimerNested;
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

  // State field(s) for firstName widget.
  FocusNode? firstNameFocusNode;
  TextEditingController? firstNameTextController;
  String? Function(BuildContext, String?)? firstNameTextControllerValidator;
  // State field(s) for lastName widget.
  FocusNode? lastNameFocusNode;
  TextEditingController? lastNameTextController;
  String? Function(BuildContext, String?)? lastNameTextControllerValidator;
  DateTime? datePicked1;
  // State field(s) for gender widget.
  String? genderValue;
  FormFieldController<String>? genderValueController;
  // State field(s) for tfMobilePhoneNumber widget.
  FocusNode? tfMobilePhoneNumberFocusNode;
  TextEditingController? tfMobilePhoneNumberTextController;
  String? Function(BuildContext, String?)?
      tfMobilePhoneNumberTextControllerValidator;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in btnCallPatient widget.
  ApiCallResponse? lisOfOutboundNumbers;
  // Stores action output result for [Custom Action - getOutboundNumbersFromResponse] action in btnCallPatient widget.
  List<String>? listOfProcessedOutboundNo;
  // State field(s) for tfHomePhoneNumber widget.
  FocusNode? tfHomePhoneNumberFocusNode;
  TextEditingController? tfHomePhoneNumberTextController;
  String? Function(BuildContext, String?)?
      tfHomePhoneNumberTextControllerValidator;
  // State field(s) for email widget.
  FocusNode? emailFocusNode;
  TextEditingController? emailTextController;
  String? Function(BuildContext, String?)? emailTextControllerValidator;
  // State field(s) for address widget.
  FocusNode? addressFocusNode;
  TextEditingController? addressTextController;
  String? Function(BuildContext, String?)? addressTextControllerValidator;
  // State field(s) for city widget.
  FocusNode? cityFocusNode;
  TextEditingController? cityTextController;
  String? Function(BuildContext, String?)? cityTextControllerValidator;
  // State field(s) for state widget.
  FocusNode? stateFocusNode;
  TextEditingController? stateTextController;
  String? Function(BuildContext, String?)? stateTextControllerValidator;
  // State field(s) for zipcode widget.
  FocusNode? zipcodeFocusNode;
  TextEditingController? zipcodeTextController;
  String? Function(BuildContext, String?)? zipcodeTextControllerValidator;
  // State field(s) for emr widget.
  FocusNode? emrFocusNode;
  TextEditingController? emrTextController;
  String? Function(BuildContext, String?)? emrTextControllerValidator;
  // State field(s) for PrimaryDxSelect widget.
  int? primaryDxSelectValue;
  FormFieldController<int>? primaryDxSelectValueController;
  // State field(s) for SecondaryDxSelect widget.
  int? secondaryDxSelectValue;
  FormFieldController<int>? secondaryDxSelectValueController;
  // State field(s) for programEligibilty widget.
  List<String>? programEligibiltyValue;
  FormFieldController<List<String>>? programEligibiltyValueController;
  // State field(s) for provider widget.
  int? providerValue;
  FormFieldController<int>? providerValueController;
  // State field(s) for primaryIns widget.
  FocusNode? primaryInsFocusNode;
  TextEditingController? primaryInsTextController;
  String? Function(BuildContext, String?)? primaryInsTextControllerValidator;
  // State field(s) for primaryInsNumber widget.
  FocusNode? primaryInsNumberFocusNode;
  TextEditingController? primaryInsNumberTextController;
  String? Function(BuildContext, String?)?
      primaryInsNumberTextControllerValidator;
  // State field(s) for secondaryIns widget.
  FocusNode? secondaryInsFocusNode;
  TextEditingController? secondaryInsTextController;
  String? Function(BuildContext, String?)? secondaryInsTextControllerValidator;
  // State field(s) for secondaryInsNumber widget.
  FocusNode? secondaryInsNumberFocusNode;
  TextEditingController? secondaryInsNumberTextController;
  String? Function(BuildContext, String?)?
      secondaryInsNumberTextControllerValidator;
  // State field(s) for TabBar widget.
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;
  int get tabBarPreviousIndex =>
      tabBarController != null ? tabBarController!.previousIndex : 0;

  // State field(s) for PaginatedDataTable widget.
  final paginatedDataTableController1 =
      FlutterFlowDataTableController<dynamic>();
  // State field(s) for PaginatedDataTable widget.
  final paginatedDataTableController2 =
      FlutterFlowDataTableController<dynamic>();
  // State field(s) for ccmStatus widget.
  int? ccmStatusValue;
  FormFieldController<int>? ccmStatusValueController;
  DateTime? datePicked2;
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
  // State field(s) for txtFieldComment widget.
  FocusNode? txtFieldCommentFocusNode;
  TextEditingController? txtFieldCommentTextController;
  String? Function(BuildContext, String?)?
      txtFieldCommentTextControllerValidator;
  // State field(s) for RadioButton widget.
  FormFieldController<String>? radioButtonValueController;
  // State field(s) for checkboxCSAcceptedTransfer widget.
  bool? checkboxCSAcceptedTransferValue;
  // Stores action output result for [Backend Call - API (Invalidate Transferred Patient)] action in IconButton widget.
  ApiCallResponse? invalidateTransferPatientDetailsFromCancel;
  // Stores action output result for [Backend Call - API (Invalidate Transferred Patient)] action in btnTransfer widget.
  ApiCallResponse? invalidateTransferPatientDetails;
  // Stores action output result for [Backend Call - API (Update Transferred Patient)] action in btnTransfer widget.
  ApiCallResponse? saveTransferPatientDetails;
  // Stores action output result for [Custom Action - getCSFromTransferredPatientSubscription] action in btnTransfer widget.
  String? transferredCSName;
  // Stores action output result for [Backend Call - API (Update Patient)] action in GSButtonSave widget.
  ApiCallResponse? updatePatient;
  // Stores action output result for [Backend Call - API (Update Patient)] action in GSButtonSave widget.
  ApiCallResponse? updatePatientWithoutStatus;
  // Stores action output result for [Backend Call - API (Invalidate Transferred Patient)] action in Button widget.
  ApiCallResponse? invalidateCancelBtnTransferPatientDetails;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    instantTimer?.cancel();
    InstantTimerNested?.cancel();
    sessionTimerController1.dispose();
    patientInstantTimerNested?.cancel();
    sessionTimerController2.dispose();
    firstNameFocusNode?.dispose();
    firstNameTextController?.dispose();

    lastNameFocusNode?.dispose();
    lastNameTextController?.dispose();

    tfMobilePhoneNumberFocusNode?.dispose();
    tfMobilePhoneNumberTextController?.dispose();

    tfHomePhoneNumberFocusNode?.dispose();
    tfHomePhoneNumberTextController?.dispose();

    emailFocusNode?.dispose();
    emailTextController?.dispose();

    addressFocusNode?.dispose();
    addressTextController?.dispose();

    cityFocusNode?.dispose();
    cityTextController?.dispose();

    stateFocusNode?.dispose();
    stateTextController?.dispose();

    zipcodeFocusNode?.dispose();
    zipcodeTextController?.dispose();

    emrFocusNode?.dispose();
    emrTextController?.dispose();

    primaryInsFocusNode?.dispose();
    primaryInsTextController?.dispose();

    primaryInsNumberFocusNode?.dispose();
    primaryInsNumberTextController?.dispose();

    secondaryInsFocusNode?.dispose();
    secondaryInsTextController?.dispose();

    secondaryInsNumberFocusNode?.dispose();
    secondaryInsNumberTextController?.dispose();

    tabBarController?.dispose();
    paginatedDataTableController1.dispose();
    paginatedDataTableController2.dispose();
    txtFieldCommentFocusNode?.dispose();
    txtFieldCommentTextController?.dispose();
  }

  /// Additional helper methods.
  String? get radioButtonValue => radioButtonValueController?.value;
}
