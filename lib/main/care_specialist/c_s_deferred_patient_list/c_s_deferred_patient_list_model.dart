import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_data_table.dart';
import '/flutter_flow/flutter_flow_timer.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/flutter_flow/instant_timer.dart';
import '/index.dart';
import 'c_s_deferred_patient_list_widget.dart' show CSDeferredPatientListWidget;
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:flutter/material.dart';

class CSDeferredPatientListModel
    extends FlutterFlowModel<CSDeferredPatientListWidget> {
  ///  Local state fields for this page.

  List<dynamic> csDeferredPatientList = [];
  void addToCsDeferredPatientList(dynamic item) =>
      csDeferredPatientList.add(item);
  void removeFromCsDeferredPatientList(dynamic item) =>
      csDeferredPatientList.remove(item);
  void removeAtIndexFromCsDeferredPatientList(int index) =>
      csDeferredPatientList.removeAt(index);
  void insertAtIndexInCsDeferredPatientList(int index, dynamic item) =>
      csDeferredPatientList.insert(index, item);
  void updateCsDeferredPatientListAtIndex(
          int index, Function(dynamic) updateFn) =>
      csDeferredPatientList[index] = updateFn(csDeferredPatientList[index]);

  List<dynamic> csDeferredPatientListFiltered = [];
  void addToCsDeferredPatientListFiltered(dynamic item) =>
      csDeferredPatientListFiltered.add(item);
  void removeFromCsDeferredPatientListFiltered(dynamic item) =>
      csDeferredPatientListFiltered.remove(item);
  void removeAtIndexFromCsDeferredPatientListFiltered(int index) =>
      csDeferredPatientListFiltered.removeAt(index);
  void insertAtIndexInCsDeferredPatientListFiltered(int index, dynamic item) =>
      csDeferredPatientListFiltered.insert(index, item);
  void updateCsDeferredPatientListFilteredAtIndex(
          int index, Function(dynamic) updateFn) =>
      csDeferredPatientListFiltered[index] =
          updateFn(csDeferredPatientListFiltered[index]);

  bool pageLoad = false;

  dynamic ccmMapping;

  dynamic rpmMapping;

  DateTime? dateSearch;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in CSDeferredPatientList widget.
  ApiCallResponse? csPatientDeferredListAPICallPageLoad;
  InstantTimer? instantTimer;
  // Stores action output result for [Backend Call - API (Update Timer Log)] action in CSDeferredPatientList widget.
  ApiCallResponse? updateTimerPageLoad;
  // Stores action output result for [Custom Action - isTabMinimized] action in CSDeferredPatientList widget.
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

  // State field(s) for csDeferredFilterDropDown widget.
  String? csDeferredFilterDropDownValue;
  FormFieldController<String>? csDeferredFilterDropDownValueController;
  // State field(s) for searchString widget.
  FocusNode? searchStringFocusNode;
  TextEditingController? searchStringTextController;
  String? Function(BuildContext, String?)? searchStringTextControllerValidator;
  DateTime? datePicked;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in IconButton widget.
  ApiCallResponse? csPatientDeferredListAPICallReLoadButton;
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
