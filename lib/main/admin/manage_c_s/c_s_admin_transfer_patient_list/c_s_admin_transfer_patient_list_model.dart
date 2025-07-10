import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_data_table.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'c_s_admin_transfer_patient_list_widget.dart'
    show CSAdminTransferPatientListWidget;
import 'package:flutter/material.dart';

class CSAdminTransferPatientListModel
    extends FlutterFlowModel<CSAdminTransferPatientListWidget> {
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

  // Stores action output result for [Custom Action - getTransferredPatientListSubscription] action in CSAdminTransferPatientList widget.
  dynamic getTransferUpdatedListSubscription;
  // State field(s) for DataTableTransferPatientList widget.
  final dataTableTransferPatientListController =
      FlutterFlowDataTableController<dynamic>();
  // Stores action output result for [Backend Call - API (Approve Patient Transfer Request)] action in IconButtonApprove widget.
  ApiCallResponse? approveTransferPatientRequest;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    dataTableTransferPatientListController.dispose();
  }
}
