import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_data_table.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/index.dart';
import 'create_new_group_by_e_m_r_widget.dart' show CreateNewGroupByEMRWidget;
import 'package:flutter/material.dart';

class CreateNewGroupByEMRModel
    extends FlutterFlowModel<CreateNewGroupByEMRWidget> {
  ///  Local state fields for this page.

  dynamic facilityData;

  dynamic providerData;

  dynamic clinicData;

  dynamic groupFiltersUsed;

  bool createGroup = false;

  List<int> patientClinicDataIDs = [];
  void addToPatientClinicDataIDs(int item) => patientClinicDataIDs.add(item);
  void removeFromPatientClinicDataIDs(int item) =>
      patientClinicDataIDs.remove(item);
  void removeAtIndexFromPatientClinicDataIDs(int index) =>
      patientClinicDataIDs.removeAt(index);
  void insertAtIndexInPatientClinicDataIDs(int index, int item) =>
      patientClinicDataIDs.insert(index, item);
  void updatePatientClinicDataIDsAtIndex(int index, Function(int) updateFn) =>
      patientClinicDataIDs[index] = updateFn(patientClinicDataIDs[index]);

  dynamic patientDetails;

  List<int> selectedPatientClinicDataIDs = [];
  void addToSelectedPatientClinicDataIDs(int item) =>
      selectedPatientClinicDataIDs.add(item);
  void removeFromSelectedPatientClinicDataIDs(int item) =>
      selectedPatientClinicDataIDs.remove(item);
  void removeAtIndexFromSelectedPatientClinicDataIDs(int index) =>
      selectedPatientClinicDataIDs.removeAt(index);
  void insertAtIndexInSelectedPatientClinicDataIDs(int index, int item) =>
      selectedPatientClinicDataIDs.insert(index, item);
  void updateSelectedPatientClinicDataIDsAtIndex(
          int index, Function(int) updateFn) =>
      selectedPatientClinicDataIDs[index] =
          updateFn(selectedPatientClinicDataIDs[index]);

  List<String> emrIds = [];
  void addToEmrIds(String item) => emrIds.add(item);
  void removeFromEmrIds(String item) => emrIds.remove(item);
  void removeAtIndexFromEmrIds(int index) => emrIds.removeAt(index);
  void insertAtIndexInEmrIds(int index, String item) =>
      emrIds.insert(index, item);
  void updateEmrIdsAtIndex(int index, Function(String) updateFn) =>
      emrIds[index] = updateFn(emrIds[index]);

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (GQLgetClinicNames)] action in CreateNewGroupByEMR widget.
  ApiCallResponse? getClinics;
  // State field(s) for txtfldEnterGroupName widget.
  FocusNode? txtfldEnterGroupNameFocusNode;
  TextEditingController? txtfldEnterGroupNameTextController;
  String? Function(BuildContext, String?)?
      txtfldEnterGroupNameTextControllerValidator;
  // State field(s) for SelectType widget.
  String? selectTypeValue;
  FormFieldController<String>? selectTypeValueController;
  // State field(s) for EnrollmentSpecialistSelect widget.
  List<int>? enrollmentSpecialistSelectValue;
  FormFieldController<List<int>>? enrollmentSpecialistSelectValueController;
  // State field(s) for clinicSelect widget.
  int? clinicSelectValue;
  FormFieldController<int>? clinicSelectValueController;
  // Stores action output result for [Backend Call - API (GQLgetProviderList)] action in clinicSelect widget.
  ApiCallResponse? getProviders;
  // Stores action output result for [Backend Call - API (GQLgetFacilityNames)] action in clinicSelect widget.
  ApiCallResponse? getFacility;
  // State field(s) for patientEMRs widget.
  FocusNode? patientEMRsFocusNode;
  TextEditingController? patientEMRsTextController;
  String? Function(BuildContext, String?)? patientEMRsTextControllerValidator;
  // Stores action output result for [Custom Action - pasteCopiedEMRsWithCommas] action in btnShowPatientList widget.
  String? processEMRsWithCommaOutput;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in btnShowPatientList widget.
  ApiCallResponse? getCreateGroupPatientListbyEMR;
  // State field(s) for PaginatedDataTable widget.
  final paginatedDataTableController =
      FlutterFlowDataTableController<dynamic>();
  // Stores action output result for [Backend Call - API (Create Group by EMR)] action in btnCreateGroup widget.
  ApiCallResponse? createGroupwithEMR;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    txtfldEnterGroupNameFocusNode?.dispose();
    txtfldEnterGroupNameTextController?.dispose();

    patientEMRsFocusNode?.dispose();
    patientEMRsTextController?.dispose();

    paginatedDataTableController.dispose();
  }
}
