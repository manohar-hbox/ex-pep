import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_data_table.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'view_p_e_s_widget.dart' show ViewPESWidget;
import 'package:flutter/material.dart';

class ViewPESModel extends FlutterFlowModel<ViewPESWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for vi widget.
  final viController = FlutterFlowDataTableController<dynamic>();
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in IconButton widget.
  ApiCallResponse? allClinics;
  // Stores action output result for [Backend Call - API (Delete PES)] action in IconButton widget.
  ApiCallResponse? deletePes;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    viController.dispose();
  }
}
