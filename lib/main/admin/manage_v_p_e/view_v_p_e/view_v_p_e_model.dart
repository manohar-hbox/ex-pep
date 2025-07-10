import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_data_table.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'view_v_p_e_widget.dart' show ViewVPEWidget;
import 'package:flutter/material.dart';

class ViewVPEModel extends FlutterFlowModel<ViewVPEWidget> {
  ///  Local state fields for this page.

  bool allocatedTasks = false;

  ///  State fields for stateful widgets in this page.

  // State field(s) for PaginatedDataTable widget.
  final paginatedDataTableController =
      FlutterFlowDataTableController<dynamic>();
  // Stores action output result for [Backend Call - API (Delete VPE)] action in IconButton widget.
  ApiCallResponse? deleteCS;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    paginatedDataTableController.dispose();
  }
}
