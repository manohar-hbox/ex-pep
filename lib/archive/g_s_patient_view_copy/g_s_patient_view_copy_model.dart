import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_data_table.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/index.dart';
import 'g_s_patient_view_copy_widget.dart' show GSPatientViewCopyWidget;
import 'package:flutter/material.dart';

class GSPatientViewCopyModel extends FlutterFlowModel<GSPatientViewCopyWidget> {
  ///  Local state fields for this page.

  int? ccmStatus;

  int? rpmStatus;

  bool saveConfirm = false;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in GSPatientViewCopy widget.
  ApiCallResponse? getPatientDetails;
  // State field(s) for firstName widget.
  FocusNode? firstNameFocusNode;
  TextEditingController? firstNameTextController;
  String? Function(BuildContext, String?)? firstNameTextControllerValidator;
  // State field(s) for lastName widget.
  FocusNode? lastNameFocusNode;
  TextEditingController? lastNameTextController;
  String? Function(BuildContext, String?)? lastNameTextControllerValidator;
  DateTime? datePicked1;
  // State field(s) for gender widget.
  String? genderValue;
  FormFieldController<String>? genderValueController;
  // State field(s) for mobilePhone widget.
  FocusNode? mobilePhoneFocusNode;
  TextEditingController? mobilePhoneTextController;
  String? Function(BuildContext, String?)? mobilePhoneTextControllerValidator;
  // State field(s) for homePhone widget.
  FocusNode? homePhoneFocusNode;
  TextEditingController? homePhoneTextController;
  String? Function(BuildContext, String?)? homePhoneTextControllerValidator;
  // State field(s) for email widget.
  FocusNode? emailFocusNode;
  TextEditingController? emailTextController;
  String? Function(BuildContext, String?)? emailTextControllerValidator;
  // State field(s) for address widget.
  FocusNode? addressFocusNode;
  TextEditingController? addressTextController;
  String? Function(BuildContext, String?)? addressTextControllerValidator;
  // State field(s) for city widget.
  FocusNode? cityFocusNode;
  TextEditingController? cityTextController;
  String? Function(BuildContext, String?)? cityTextControllerValidator;
  // State field(s) for state widget.
  FocusNode? stateFocusNode;
  TextEditingController? stateTextController;
  String? Function(BuildContext, String?)? stateTextControllerValidator;
  // State field(s) for zipcode widget.
  FocusNode? zipcodeFocusNode;
  TextEditingController? zipcodeTextController;
  String? Function(BuildContext, String?)? zipcodeTextControllerValidator;
  // State field(s) for emr widget.
  FocusNode? emrFocusNode;
  TextEditingController? emrTextController;
  String? Function(BuildContext, String?)? emrTextControllerValidator;
  // State field(s) for programEligibilty widget.
  List<String>? programEligibiltyValue;
  FormFieldController<List<String>>? programEligibiltyValueController;
  // State field(s) for provider widget.
  int? providerValue;
  FormFieldController<int>? providerValueController;
  // State field(s) for primaryIns widget.
  FocusNode? primaryInsFocusNode;
  TextEditingController? primaryInsTextController;
  String? Function(BuildContext, String?)? primaryInsTextControllerValidator;
  // State field(s) for primaryInsNumber widget.
  FocusNode? primaryInsNumberFocusNode;
  TextEditingController? primaryInsNumberTextController;
  String? Function(BuildContext, String?)?
      primaryInsNumberTextControllerValidator;
  // State field(s) for secondaryIns widget.
  FocusNode? secondaryInsFocusNode;
  TextEditingController? secondaryInsTextController;
  String? Function(BuildContext, String?)? secondaryInsTextControllerValidator;
  // State field(s) for secondaryInsNumber widget.
  FocusNode? secondaryInsNumberFocusNode;
  TextEditingController? secondaryInsNumberTextController;
  String? Function(BuildContext, String?)?
      secondaryInsNumberTextControllerValidator;
  // State field(s) for PaginatedDataTable widget.
  final paginatedDataTableController1 =
      FlutterFlowDataTableController<dynamic>();
  // State field(s) for PaginatedDataTable widget.
  final paginatedDataTableController2 =
      FlutterFlowDataTableController<dynamic>();
  // State field(s) for ccmStatus widget.
  int? ccmStatusValue;
  FormFieldController<int>? ccmStatusValueController;
  DateTime? datePicked2;
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
    firstNameFocusNode?.dispose();
    firstNameTextController?.dispose();

    lastNameFocusNode?.dispose();
    lastNameTextController?.dispose();

    mobilePhoneFocusNode?.dispose();
    mobilePhoneTextController?.dispose();

    homePhoneFocusNode?.dispose();
    homePhoneTextController?.dispose();

    emailFocusNode?.dispose();
    emailTextController?.dispose();

    addressFocusNode?.dispose();
    addressTextController?.dispose();

    cityFocusNode?.dispose();
    cityTextController?.dispose();

    stateFocusNode?.dispose();
    stateTextController?.dispose();

    zipcodeFocusNode?.dispose();
    zipcodeTextController?.dispose();

    emrFocusNode?.dispose();
    emrTextController?.dispose();

    primaryInsFocusNode?.dispose();
    primaryInsTextController?.dispose();

    primaryInsNumberFocusNode?.dispose();
    primaryInsNumberTextController?.dispose();

    secondaryInsFocusNode?.dispose();
    secondaryInsTextController?.dispose();

    secondaryInsNumberFocusNode?.dispose();
    secondaryInsNumberTextController?.dispose();

    paginatedDataTableController1.dispose();
    paginatedDataTableController2.dispose();
    commentFocusNode?.dispose();
    commentTextController?.dispose();
  }
}
