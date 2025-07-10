import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_data_table.dart';
import '/flutter_flow/flutter_flow_timer.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/flutter_flow/instant_timer.dart';
import '/index.dart';
import 'g_s_list_view_widget.dart' show GSListViewWidget;
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:flutter/material.dart';

class GSListViewModel extends FlutterFlowModel<GSListViewWidget> {
  ///  Local state fields for this page.

  int? dropDown = 0;

  dynamic patientList;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in GSListView widget.
  ApiCallResponse? getGsOnLoad;
  InstantTimer? instantTimer;
  // Stores action output result for [Backend Call - API (Update Timer Log)] action in GSListView widget.
  ApiCallResponse? updateTimerPageLoad;
  // Stores action output result for [Custom Action - isTabMinimized] action in GSListView widget.
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

  // State field(s) for DropDown widget.
  int? dropDownValue;
  FormFieldController<int>? dropDownValueController;
  // State field(s) for patientSearch widget.
  FocusNode? patientSearchFocusNode;
  TextEditingController? patientSearchTextController;
  String? Function(BuildContext, String?)? patientSearchTextControllerValidator;
  DateTime? datePicked;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in Button widget.
  ApiCallResponse? dropDownGlobalSearch;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in IconButton widget.
  ApiCallResponse? getGsOnReload;
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
    patientSearchFocusNode?.dispose();
    patientSearchTextController?.dispose();

    dataTableGroupListController.dispose();
  }
}
