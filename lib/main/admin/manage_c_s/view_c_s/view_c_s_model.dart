import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_data_table.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'view_c_s_widget.dart' show ViewCSWidget;
import 'package:flutter/material.dart';

class ViewCSModel extends FlutterFlowModel<ViewCSWidget> {
  ///  Local state fields for this page.

  int? transferRequestCount = 0;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - getTransferredPatientListSubscription] action in ViewCS widget.
  dynamic getTransferUpdatedListSubscriptionCount;
  // State field(s) for vi widget.
  final viController = FlutterFlowDataTableController<dynamic>();
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in IconButton widget.
  ApiCallResponse? allClinics;
  // Stores action output result for [Backend Call - API (Delete CS)] action in IconButton widget.
  ApiCallResponse? deleteCSResult;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    viController.dispose();
  }
}
