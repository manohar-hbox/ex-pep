import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_data_table.dart';
import '/flutter_flow/flutter_flow_timer.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/flutter_flow/instant_timer.dart';
import '/index.dart';
import 'c_s_follow_up_patient_list_widget.dart'
    show CSFollowUpPatientListWidget;
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:flutter/material.dart';

class CSFollowUpPatientListModel
    extends FlutterFlowModel<CSFollowUpPatientListWidget> {
  ///  Local state fields for this page.

  List<dynamic> csFollowUpPatientList = [];
  void addToCsFollowUpPatientList(dynamic item) =>
      csFollowUpPatientList.add(item);
  void removeFromCsFollowUpPatientList(dynamic item) =>
      csFollowUpPatientList.remove(item);
  void removeAtIndexFromCsFollowUpPatientList(int index) =>
      csFollowUpPatientList.removeAt(index);
  void insertAtIndexInCsFollowUpPatientList(int index, dynamic item) =>
      csFollowUpPatientList.insert(index, item);
  void updateCsFollowUpPatientListAtIndex(
          int index, Function(dynamic) updateFn) =>
      csFollowUpPatientList[index] = updateFn(csFollowUpPatientList[index]);

  List<dynamic> csFollowUpPatientListFiltered = [];
  void addToCsFollowUpPatientListFiltered(dynamic item) =>
      csFollowUpPatientListFiltered.add(item);
  void removeFromCsFollowUpPatientListFiltered(dynamic item) =>
      csFollowUpPatientListFiltered.remove(item);
  void removeAtIndexFromCsFollowUpPatientListFiltered(int index) =>
      csFollowUpPatientListFiltered.removeAt(index);
  void insertAtIndexInCsFollowUpPatientListFiltered(int index, dynamic item) =>
      csFollowUpPatientListFiltered.insert(index, item);
  void updateCsFollowUpPatientListFilteredAtIndex(
          int index, Function(dynamic) updateFn) =>
      csFollowUpPatientListFiltered[index] =
          updateFn(csFollowUpPatientListFiltered[index]);

  bool pageLoad = false;

  dynamic ccmMapping;

  dynamic rpmMapping;

  DateTime? dateSearch;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in CSFollowUpPatientList widget.
  ApiCallResponse? csPatientDeferredListAPICallPageLoad;
  InstantTimer? instantTimer;
  // Stores action output result for [Backend Call - API (Update Timer Log)] action in CSFollowUpPatientList widget.
  ApiCallResponse? updateTimerPageLoad;
  // Stores action output result for [Custom Action - isTabMinimized] action in CSFollowUpPatientList widget.
  bool? isTabMinimized;
  InstantTimer? instantTimerNested;
  // Stores action output result for [Backend Call - API (Update Timer Log)] action in PlayIconButton widget.
  ApiCallResponse? updateTimerPlayTap;
  // Stores action output result for [Custom Action - isTabMinimized] action in PlayIconButton widget.
  bool? isTabMinimizedNested;
  // State field(s) for SessionTimer widget.
  final sessionTimerInitialTimeMs = 0;
  int sessionTimerMilliseconds = 0;
  String sessionTimerValue = StopWatchTimer.getDisplayTime(
    0,
    hours: false,
    milliSecond: false,
  );
  FlutterFlowTimerController sessionTimerController =
      FlutterFlowTimerController(StopWatchTimer(mode: StopWatchMode.countUp));

  // State field(s) for csFollowUpDropDown widget.
  String? csFollowUpDropDownValue;
  FormFieldController<String>? csFollowUpDropDownValueController;
  // State field(s) for searchString widget.
  FocusNode? searchStringFocusNode;
  TextEditingController? searchStringTextController;
  String? Function(BuildContext, String?)? searchStringTextControllerValidator;
  DateTime? datePicked;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in IconButton widget.
  ApiCallResponse? csPatientFollowUpListAPICallReLoadButton;
  // State field(s) for dataTableGroupList widget.
  final dataTableGroupListController =
      FlutterFlowDataTableController<dynamic>();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    instantTimer?.cancel();
    instantTimerNested?.cancel();
    sessionTimerController.dispose();
    searchStringFocusNode?.dispose();
    searchStringTextController?.dispose();

    dataTableGroupListController.dispose();
  }
}
