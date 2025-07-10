import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'ctc_widget.dart' show CtcWidget;
import 'package:flutter/material.dart';

class CtcModel extends FlutterFlowModel<CtcWidget> {
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

  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in CTC widget.
  ApiCallResponse? pESAssignedTasksResponse;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in CTC widget.
  ApiCallResponse? pesPatientListAPICallPageLoad;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
