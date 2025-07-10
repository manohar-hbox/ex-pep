import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_data_table.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/index.dart';
import 'view_groups_widget.dart' show ViewGroupsWidget;
import 'package:flutter/material.dart';

class ViewGroupsModel extends FlutterFlowModel<ViewGroupsWidget> {
  ///  Local state fields for this page.

  List<dynamic> groupDetails = [];
  void addToGroupDetails(dynamic item) => groupDetails.add(item);
  void removeFromGroupDetails(dynamic item) => groupDetails.remove(item);
  void removeAtIndexFromGroupDetails(int index) => groupDetails.removeAt(index);
  void insertAtIndexInGroupDetails(int index, dynamic item) =>
      groupDetails.insert(index, item);
  void updateGroupDetailsAtIndex(int index, Function(dynamic) updateFn) =>
      groupDetails[index] = updateFn(groupDetails[index]);

  List<dynamic> groupDetailsFiltered = [];
  void addToGroupDetailsFiltered(dynamic item) =>
      groupDetailsFiltered.add(item);
  void removeFromGroupDetailsFiltered(dynamic item) =>
      groupDetailsFiltered.remove(item);
  void removeAtIndexFromGroupDetailsFiltered(int index) =>
      groupDetailsFiltered.removeAt(index);
  void insertAtIndexInGroupDetailsFiltered(int index, dynamic item) =>
      groupDetailsFiltered.insert(index, item);
  void updateGroupDetailsFilteredAtIndex(
          int index, Function(dynamic) updateFn) =>
      groupDetailsFiltered[index] = updateFn(groupDetailsFiltered[index]);

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in ViewGroups widget.
  ApiCallResponse? groupDetailsAPICallPageLoad;
  // State field(s) for groupFilterDropDown widget.
  String? groupFilterDropDownValue;
  FormFieldController<String>? groupFilterDropDownValueController;
  // State field(s) for searchString widget.
  FocusNode? searchStringFocusNode;
  TextEditingController? searchStringTextController;
  String? Function(BuildContext, String?)? searchStringTextControllerValidator;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in IconButton widget.
  ApiCallResponse? groupDetailsAPICallReloadButton;
  // State field(s) for dataTableGroupList widget.
  final dataTableGroupListController =
      FlutterFlowDataTableController<dynamic>();
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in IconButtonSendEmail widget.
  ApiCallResponse? getPatientList;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in IconButtonDuplicate widget.
  ApiCallResponse? getPatientListDuplicateIcon;
  // Stores action output result for [Backend Call - API (Archive Group)] action in IconButtonArchive widget.
  ApiCallResponse? archiveGroupResult;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in IconButtonArchive widget.
  ApiCallResponse? groupDetailsAPICallArchiveButton;
  // Stores action output result for [Backend Call - API (Delete Group)] action in IconButtonDelete widget.
  ApiCallResponse? deleteGroupResult;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in IconButtonDelete widget.
  ApiCallResponse? groupDetailsAPICallDeleteButton;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    searchStringFocusNode?.dispose();
    searchStringTextController?.dispose();

    dataTableGroupListController.dispose();
  }
}
