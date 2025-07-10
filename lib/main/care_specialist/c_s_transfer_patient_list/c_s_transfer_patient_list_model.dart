import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_data_table.dart';
import '/flutter_flow/flutter_flow_timer.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/instant_timer.dart';
import '/index.dart';
import 'c_s_transfer_patient_list_widget.dart' show CSTransferPatientListWidget;
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:flutter/material.dart';

class CSTransferPatientListModel
    extends FlutterFlowModel<CSTransferPatientListWidget> {
  ///  Local state fields for this page.

  List<dynamic> csPatientList = [];
  void addToCsPatientList(dynamic item) => csPatientList.add(item);
  void removeFromCsPatientList(dynamic item) => csPatientList.remove(item);
  void removeAtIndexFromCsPatientList(int index) =>
      csPatientList.removeAt(index);
  void insertAtIndexInCsPatientList(int index, dynamic item) =>
      csPatientList.insert(index, item);
  void updateCsPatientListAtIndex(int index, Function(dynamic) updateFn) =>
      csPatientList[index] = updateFn(csPatientList[index]);

  List<dynamic> csPatientListFiltered = [];
  void addToCsPatientListFiltered(dynamic item) =>
      csPatientListFiltered.add(item);
  void removeFromCsPatientListFiltered(dynamic item) =>
      csPatientListFiltered.remove(item);
  void removeAtIndexFromCsPatientListFiltered(int index) =>
      csPatientListFiltered.removeAt(index);
  void insertAtIndexInCsPatientListFiltered(int index, dynamic item) =>
      csPatientListFiltered.insert(index, item);
  void updateCsPatientListFilteredAtIndex(
          int index, Function(dynamic) updateFn) =>
      csPatientListFiltered[index] = updateFn(csPatientListFiltered[index]);

  bool pageLoad = false;

  dynamic ccmMapping;

  dynamic rpmMapping;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - getTransferredPatientListSubscription] action in CSTransferPatientList widget.
  dynamic getTransferUpdatedListSubscription;
  InstantTimer? instantTimer;
  // Stores action output result for [Backend Call - API (Update Timer Log)] action in CSTransferPatientList widget.
  ApiCallResponse? updateTimerPageLoad;
  // Stores action output result for [Custom Action - isTabMinimized] action in CSTransferPatientList widget.
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
  // Stores action output result for [Backend Call - API (Approve Patient Transfer Request)] action in IconButtonApprove widget.
  ApiCallResponse? approveTransferPatientRequest;

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
