import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_data_table.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/index.dart';
import 'manage_clinic_time_slots_widget.dart' show ManageClinicTimeSlotsWidget;
import 'package:flutter/material.dart';

class ManageClinicTimeSlotsModel
    extends FlutterFlowModel<ManageClinicTimeSlotsWidget> {
  ///  Local state fields for this page.

  dynamic clinicData;

  dynamic facilityData;

  List<dynamic> appointmentData = [];
  void addToAppointmentData(dynamic item) => appointmentData.add(item);
  void removeFromAppointmentData(dynamic item) => appointmentData.remove(item);
  void removeAtIndexFromAppointmentData(int index) =>
      appointmentData.removeAt(index);
  void insertAtIndexInAppointmentData(int index, dynamic item) =>
      appointmentData.insert(index, item);
  void updateAppointmentDataAtIndex(int index, Function(dynamic) updateFn) =>
      appointmentData[index] = updateFn(appointmentData[index]);

  List<dynamic> appointmentFiltredData = [];
  void addToAppointmentFiltredData(dynamic item) =>
      appointmentFiltredData.add(item);
  void removeFromAppointmentFiltredData(dynamic item) =>
      appointmentFiltredData.remove(item);
  void removeAtIndexFromAppointmentFiltredData(int index) =>
      appointmentFiltredData.removeAt(index);
  void insertAtIndexInAppointmentFiltredData(int index, dynamic item) =>
      appointmentFiltredData.insert(index, item);
  void updateAppointmentFiltredDataAtIndex(
          int index, Function(dynamic) updateFn) =>
      appointmentFiltredData[index] = updateFn(appointmentFiltredData[index]);

  DateTime? dateSearch;

  bool pageLoadComplete = false;

  List<int> selectedRows = [];
  void addToSelectedRows(int item) => selectedRows.add(item);
  void removeFromSelectedRows(int item) => selectedRows.remove(item);
  void removeAtIndexFromSelectedRows(int index) => selectedRows.removeAt(index);
  void insertAtIndexInSelectedRows(int index, int item) =>
      selectedRows.insert(index, item);
  void updateSelectedRowsAtIndex(int index, Function(int) updateFn) =>
      selectedRows[index] = updateFn(selectedRows[index]);

  bool showTable = true;

  /// Variable to keep track of whether filter is applied or not.
  bool isFilterApplied = false;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in ManageClinicTimeSlots widget.
  ApiCallResponse? getAppointments;
  // Stores action output result for [Backend Call - API (GQLgetClinicNames)] action in ManageClinicTimeSlots widget.
  ApiCallResponse? getClinics;
  // State field(s) for ClinicSelect widget.
  int? clinicSelectValue;
  FormFieldController<int>? clinicSelectValueController;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in ClinicSelect widget.
  ApiCallResponse? getClinicAppointment;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in ClinicSelect widget.
  ApiCallResponse? getFacility;
  // State field(s) for FacilitySelect widget.
  List<String>? facilitySelectValue;
  FormFieldController<List<String>>? facilitySelectValueController;
  // Stores action output result for [Alert Dialog - Custom Dialog] action in ClinicTimeSlots widget.
  dynamic filterData;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in IconButton widget.
  ApiCallResponse? getClinicAppointmentReloadButton;
  // Stores action output result for [Backend Call - API (Delete Multiple Time Slots)] action in Button widget.
  ApiCallResponse? deleteMultipleClinicTimeSlots;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in Button widget.
  ApiCallResponse? getMultipleAppointmentsDeleteOperation;
  // State field(s) for PaginatedDataTable widget.
  final paginatedDataTableController =
      FlutterFlowDataTableController<dynamic>();
  // Stores action output result for [Backend Call - API (Delete Time Slot)] action in IconButton widget.
  ApiCallResponse? deleteTimeAllotment;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in IconButton widget.
  ApiCallResponse? getAppointmentsDeleteOperation;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    paginatedDataTableController.dispose();
  }
}
