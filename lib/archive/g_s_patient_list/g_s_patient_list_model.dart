import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_data_table.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'g_s_patient_list_widget.dart' show GSPatientListWidget;
import 'package:flutter/material.dart';

class GSPatientListModel extends FlutterFlowModel<GSPatientListWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for patientSearch widget.
  FocusNode? patientSearchFocusNode;
  TextEditingController? patientSearchTextController;
  String? Function(BuildContext, String?)? patientSearchTextControllerValidator;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in patientSearch widget.
  ApiCallResponse? searchPatientsOnSubmit;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in SearchButton widget.
  ApiCallResponse? searchPatients;
  // State field(s) for vi widget.
  final viController = FlutterFlowDataTableController<dynamic>();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    patientSearchFocusNode?.dispose();
    patientSearchTextController?.dispose();

    viController.dispose();
  }
}
