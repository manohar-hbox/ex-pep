import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_data_table.dart';
import '/flutter_flow/flutter_flow_timer.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/instant_timer.dart';
import '/index.dart';
import 'p_e_s_follow_up_patient_list_widget.dart'
    show PESFollowUpPatientListWidget;
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:flutter/material.dart';

class PESFollowUpPatientListModel
    extends FlutterFlowModel<PESFollowUpPatientListWidget> {
  ///  Local state fields for this page.

  List<dynamic> pesPatientList = [];
  void addToPesPatientList(dynamic item) => pesPatientList.add(item);
  void removeFromPesPatientList(dynamic item) => pesPatientList.remove(item);
  void removeAtIndexFromPesPatientList(int index) =>
      pesPatientList.removeAt(index);
  void insertAtIndexInPesPatientList(int index, dynamic item) =>
      pesPatientList.insert(index, item);
  void updatePesPatientListAtIndex(int index, Function(dynamic) updateFn) =>
      pesPatientList[index] = updateFn(pesPatientList[index]);

  List<dynamic> pesPatientListFiltered = [];
  void addToPesPatientListFiltered(dynamic item) =>
      pesPatientListFiltered.add(item);
  void removeFromPesPatientListFiltered(dynamic item) =>
      pesPatientListFiltered.remove(item);
  void removeAtIndexFromPesPatientListFiltered(int index) =>
      pesPatientListFiltered.removeAt(index);
  void insertAtIndexInPesPatientListFiltered(int index, dynamic item) =>
      pesPatientListFiltered.insert(index, item);
  void updatePesPatientListFilteredAtIndex(
          int index, Function(dynamic) updateFn) =>
      pesPatientListFiltered[index] = updateFn(pesPatientListFiltered[index]);

  bool pageLoad = false;

  dynamic ccmMapping;

  dynamic rpmMapping;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in PESFollowUpPatientList widget.
  ApiCallResponse? pesPatientFollowUpListAPICallPageLoad;
  InstantTimer? instantTimer;
  // Stores action output result for [Backend Call - API (Update Timer Log)] action in PESFollowUpPatientList widget.
  ApiCallResponse? updateTimerPageLoad;
  // Stores action output result for [Custom Action - isTabMinimized] action in PESFollowUpPatientList widget.
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
    dataTableGroupListController.dispose();
  }
}
