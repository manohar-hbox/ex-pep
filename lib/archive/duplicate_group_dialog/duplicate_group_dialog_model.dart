import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'duplicate_group_dialog_widget.dart' show DuplicateGroupDialogWidget;
import 'package:flutter/material.dart';

class DuplicateGroupDialogModel
    extends FlutterFlowModel<DuplicateGroupDialogWidget> {
  ///  State fields for stateful widgets in this component.

  final formKey = GlobalKey<FormState>();
  // State field(s) for groupName widget.
  FocusNode? groupNameFocusNode;
  TextEditingController? groupNameTextController;
  String? Function(BuildContext, String?)? groupNameTextControllerValidator;
  // State field(s) for EnrollmentSpecialistSelect widget.
  List<int>? enrollmentSpecialistSelectValue;
  FormFieldController<List<int>>? enrollmentSpecialistSelectValueController;
  // State field(s) for SelectType widget.
  String? selectTypeValue;
  FormFieldController<String>? selectTypeValueController;
  // State field(s) for SelectStatus widget.
  String? selectStatusValue;
  FormFieldController<String>? selectStatusValueController;
  DateTime? datePicked;
  // Stores action output result for [Backend Call - API (Create Group)] action in Button widget.
  ApiCallResponse? duplicateGroup;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    groupNameFocusNode?.dispose();
    groupNameTextController?.dispose();
  }
}
