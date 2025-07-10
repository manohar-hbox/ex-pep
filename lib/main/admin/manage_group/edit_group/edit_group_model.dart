import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_data_table.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/index.dart';
import 'edit_group_widget.dart' show EditGroupWidget;
import 'package:flutter/material.dart';

class EditGroupModel extends FlutterFlowModel<EditGroupWidget> {
  ///  Local state fields for this page.

  List<dynamic> debugVar = [];
  void addToDebugVar(dynamic item) => debugVar.add(item);
  void removeFromDebugVar(dynamic item) => debugVar.remove(item);
  void removeAtIndexFromDebugVar(int index) => debugVar.removeAt(index);
  void insertAtIndexInDebugVar(int index, dynamic item) =>
      debugVar.insert(index, item);
  void updateDebugVarAtIndex(int index, Function(dynamic) updateFn) =>
      debugVar[index] = updateFn(debugVar[index]);

  dynamic patientDetails;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in EditGroup widget.
  ApiCallResponse? getPatientList;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in EditGroup widget.
  ApiCallResponse? getCreateGroupPatientList;
  // State field(s) for txtfldEnterGroupName widget.
  FocusNode? txtfldEnterGroupNameFocusNode;
  TextEditingController? txtfldEnterGroupNameTextController;
  String? Function(BuildContext, String?)?
      txtfldEnterGroupNameTextControllerValidator;
  // State field(s) for EnrollmentSpecialistSelect widget.
  List<int>? enrollmentSpecialistSelectValue;
  FormFieldController<List<int>>? enrollmentSpecialistSelectValueController;
  // State field(s) for SelectType widget.
  String? selectTypeValue;
  FormFieldController<String>? selectTypeValueController;
  // State field(s) for dataTableGroupList widget.
  final dataTableGroupListController =
      FlutterFlowDataTableController<dynamic>();
  // State field(s) for PaginatedDataTable widget.
  final paginatedDataTableController =
      FlutterFlowDataTableController<dynamic>();
  // Stores action output result for [Backend Call - API (Update Group)] action in btnUpdateGroup widget.
  ApiCallResponse? updateGroupResponse;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    txtfldEnterGroupNameFocusNode?.dispose();
    txtfldEnterGroupNameTextController?.dispose();

    dataTableGroupListController.dispose();
    paginatedDataTableController.dispose();
  }
}
