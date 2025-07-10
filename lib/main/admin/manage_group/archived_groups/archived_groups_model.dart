import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_data_table.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'archived_groups_widget.dart' show ArchivedGroupsWidget;
import 'package:flutter/material.dart';

class ArchivedGroupsModel extends FlutterFlowModel<ArchivedGroupsWidget> {
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

  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in ArchivedGroups widget.
  ApiCallResponse? groupArchivedDetailsAPICallPageLoad;
  // State field(s) for dataTableGroupList widget.
  final dataTableGroupListController =
      FlutterFlowDataTableController<dynamic>();
  // Stores action output result for [Backend Call - API (Archive Group)] action in IconButtonArchive widget.
  ApiCallResponse? unarchiveGroupResult;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in IconButtonArchive widget.
  ApiCallResponse? groupDetailsAPICallUnarchiveButton;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    dataTableGroupListController.dispose();
  }
}
