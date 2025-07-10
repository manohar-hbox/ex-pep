import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_data_table.dart';
import '/flutter_flow/flutter_flow_timer.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/flutter_flow/instant_timer.dart';
import '/index.dart';
import 'c_s_patient_list_widget.dart' show CSPatientListWidget;
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:flutter/material.dart';

class CSPatientListModel extends FlutterFlowModel<CSPatientListWidget> {
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

  DateTime? dateSearch;

  bool pageLoad = false;

  List<String> ccmStaus = [];
  void addToCcmStaus(String item) => ccmStaus.add(item);
  void removeFromCcmStaus(String item) => ccmStaus.remove(item);
  void removeAtIndexFromCcmStaus(int index) => ccmStaus.removeAt(index);
  void insertAtIndexInCcmStaus(int index, String item) =>
      ccmStaus.insert(index, item);
  void updateCcmStausAtIndex(int index, Function(String) updateFn) =>
      ccmStaus[index] = updateFn(ccmStaus[index]);

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

  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in CSPatientList widget.
  ApiCallResponse? cSAssignedTasksResponse;
  // Stores action output result for [Custom Action - getTransferredPatientListSubscription] action in CSPatientList widget.
  dynamic getTransferUpdatedListSubscriptionCount;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in CSPatientList widget.
  ApiCallResponse? csPatientListAPICallPageLoad;
  InstantTimer? instantTimer;
  // Stores action output result for [Backend Call - API (Update Timer Log)] action in CSPatientList widget.
  ApiCallResponse? updateTimerPageLoad;
  // Stores action output result for [Custom Action - isTabMinimized] action in CSPatientList widget.
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

  // State field(s) for csFilterDropDown widget.
  String? csFilterDropDownValue;
  FormFieldController<String>? csFilterDropDownValueController;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in csFilterDropDown widget.
  ApiCallResponse? ccmMappingQuery;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in csFilterDropDown widget.
  ApiCallResponse? rpmMappingQuery;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in csFilterDropDown widget.
  ApiCallResponse? ccmElseMappingQuery;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in csFilterDropDown widget.
  ApiCallResponse? rpmElseMappingQuery;
  // State field(s) for searchString widget.
  FocusNode? searchStringFocusNode;
  TextEditingController? searchStringTextController;
  String? Function(BuildContext, String?)? searchStringTextControllerValidator;
  // State field(s) for csFilterDropDownCCM widget.
  List<String>? csFilterDropDownCCMValue;
  FormFieldController<List<String>>? csFilterDropDownCCMValueController;
  // State field(s) for csFilterDropDownRPM widget.
  List<String>? csFilterDropDownRPMValue;
  FormFieldController<List<String>>? csFilterDropDownRPMValueController;
  DateTime? datePicked;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in IconButton widget.
  ApiCallResponse? csPatientListAPICallReloadButton;
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
