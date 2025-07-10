import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_data_table.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/index.dart';
import 'c_s_admin_patient_detail_widget.dart' show CSAdminPatientDetailWidget;
import 'package:flutter/material.dart';

class CSAdminPatientDetailModel
    extends FlutterFlowModel<CSAdminPatientDetailWidget> {
  ///  Local state fields for this page.

  int? ccmStatus;

  int? rpmStatus;

  List<String> outboundNumbers = [];
  void addToOutboundNumbers(String item) => outboundNumbers.add(item);
  void removeFromOutboundNumbers(String item) => outboundNumbers.remove(item);
  void removeAtIndexFromOutboundNumbers(int index) =>
      outboundNumbers.removeAt(index);
  void insertAtIndexInOutboundNumbers(int index, String item) =>
      outboundNumbers.insert(index, item);
  void updateOutboundNumbersAtIndex(int index, Function(String) updateFn) =>
      outboundNumbers[index] = updateFn(outboundNumbers[index]);

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in CSAdminPatientDetail widget.
  ApiCallResponse? getIfPatientCanMakeOutgoingCallResponse;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in btnCallPatient widget.
  ApiCallResponse? lisOfOutboundNumbers;
  // Stores action output result for [Custom Action - getOutboundNumbersFromResponse] action in btnCallPatient widget.
  List<String>? listOfProcessedOutboundNo;
  // State field(s) for PrimaryDxSelect widget.
  int? primaryDxSelectValue;
  FormFieldController<int>? primaryDxSelectValueController;
  // State field(s) for SecondaryDxSelect widget.
  int? secondaryDxSelectValue;
  FormFieldController<int>? secondaryDxSelectValueController;
  // State field(s) for TabBar widget.
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;
  int get tabBarPreviousIndex =>
      tabBarController != null ? tabBarController!.previousIndex : 0;

  // State field(s) for PaginatedDataTable widget.
  final paginatedDataTableController1 =
      FlutterFlowDataTableController<dynamic>();
  // State field(s) for PaginatedDataTable widget.
  final paginatedDataTableController2 =
      FlutterFlowDataTableController<dynamic>();
  // State field(s) for ccmStatus widget.
  int? ccmStatusValue;
  FormFieldController<int>? ccmStatusValueController;
  DateTime? datePicked;
  // State field(s) for rpmStatus widget.
  int? rpmStatusValue;
  FormFieldController<int>? rpmStatusValueController;
  // State field(s) for facility widget.
  int? facilityValue;
  FormFieldController<int>? facilityValueController;
  // State field(s) for RPMAppDate widget.
  String? rPMAppDateValue;
  FormFieldController<String>? rPMAppDateValueController;
  // State field(s) for RPMAppTime widget.
  String? rPMAppTimeValue;
  FormFieldController<String>? rPMAppTimeValueController;
  // State field(s) for Comment widget.
  FocusNode? commentFocusNode;
  TextEditingController? commentTextController;
  String? Function(BuildContext, String?)? commentTextControllerValidator;
  // Stores action output result for [Backend Call - API (Update Patient)] action in Button widget.
  ApiCallResponse? updatePatient;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    tabBarController?.dispose();
    paginatedDataTableController1.dispose();
    paginatedDataTableController2.dispose();
    commentFocusNode?.dispose();
    commentTextController?.dispose();
  }
}
