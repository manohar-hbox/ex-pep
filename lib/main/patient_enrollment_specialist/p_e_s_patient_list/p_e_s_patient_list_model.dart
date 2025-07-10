import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_data_table.dart';
import '/flutter_flow/flutter_flow_timer.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/flutter_flow/instant_timer.dart';
import '/index.dart';
import 'p_e_s_patient_list_widget.dart' show PESPatientListWidget;
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:flutter/material.dart';

class PESPatientListModel extends FlutterFlowModel<PESPatientListWidget> {
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

  DateTime? dateSearch;

  bool pageLoad = false;

  List<String> ccmStatus = [];
  void addToCcmStatus(String item) => ccmStatus.add(item);
  void removeFromCcmStatus(String item) => ccmStatus.remove(item);
  void removeAtIndexFromCcmStatus(int index) => ccmStatus.removeAt(index);
  void insertAtIndexInCcmStatus(int index, String item) =>
      ccmStatus.insert(index, item);
  void updateCcmStatusAtIndex(int index, Function(String) updateFn) =>
      ccmStatus[index] = updateFn(ccmStatus[index]);

  List<String> rpmStatus = [];
  void addToRpmStatus(String item) => rpmStatus.add(item);
  void removeFromRpmStatus(String item) => rpmStatus.remove(item);
  void removeAtIndexFromRpmStatus(int index) => rpmStatus.removeAt(index);
  void insertAtIndexInRpmStatus(int index, String item) =>
      rpmStatus.insert(index, item);
  void updateRpmStatusAtIndex(int index, Function(String) updateFn) =>
      rpmStatus[index] = updateFn(rpmStatus[index]);

  dynamic ccmMapping;

  dynamic rpmMapping;

  bool checkDeferredTaskAssigned = false;

  bool checkFollowUpTaskAssigned = false;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in PESPatientList widget.
  ApiCallResponse? pESAssignedTasksResponse;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in PESPatientList widget.
  ApiCallResponse? pesPatientListAPICallPageLoad;
  InstantTimer? instantTimer;
  // Stores action output result for [Backend Call - API (Update Timer Log)] action in PESPatientList widget.
  ApiCallResponse? updateTimerPageLoad;
  // Stores action output result for [Custom Action - isTabMinimized] action in PESPatientList widget.
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

  // State field(s) for pesFilterDropDown widget.
  String? pesFilterDropDownValue;
  FormFieldController<String>? pesFilterDropDownValueController;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in pesFilterDropDown widget.
  ApiCallResponse? ccmMappingQuery;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in pesFilterDropDown widget.
  ApiCallResponse? rpmMappingQuery;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in pesFilterDropDown widget.
  ApiCallResponse? ccmElseMappingQuery;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in pesFilterDropDown widget.
  ApiCallResponse? rpmElseMappingQuery;
  // State field(s) for searchString widget.
  FocusNode? searchStringFocusNode;
  TextEditingController? searchStringTextController;
  String? Function(BuildContext, String?)? searchStringTextControllerValidator;
  // State field(s) for pesFilterDropDownCCM widget.
  List<String>? pesFilterDropDownCCMValue;
  FormFieldController<List<String>>? pesFilterDropDownCCMValueController;
  // State field(s) for pesFilterDropDownRPM widget.
  List<String>? pesFilterDropDownRPMValue;
  FormFieldController<List<String>>? pesFilterDropDownRPMValueController;
  DateTime? datePicked;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in IconButton widget.
  ApiCallResponse? pesPatientListAPICallReloadButton;
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
