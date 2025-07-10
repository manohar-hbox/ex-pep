import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/index.dart';
import 'update_group_widget.dart' show UpdateGroupWidget;
import 'package:flutter/material.dart';

class UpdateGroupModel extends FlutterFlowModel<UpdateGroupWidget> {
  ///  State fields for stateful widgets in this page.

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
  // Stores action output result for [Backend Call - API (Update Group)] action in btnUpdateGroup widget.
  ApiCallResponse? updateGroupResponse;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    txtfldEnterGroupNameFocusNode?.dispose();
    txtfldEnterGroupNameTextController?.dispose();
  }
}
