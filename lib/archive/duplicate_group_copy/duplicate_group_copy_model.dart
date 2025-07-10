import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/index.dart';
import 'duplicate_group_copy_widget.dart' show DuplicateGroupCopyWidget;
import 'package:flutter/material.dart';

class DuplicateGroupCopyModel
    extends FlutterFlowModel<DuplicateGroupCopyWidget> {
  ///  Local state fields for this page.

  List<String> primDxDropDown = [];
  void addToPrimDxDropDown(String item) => primDxDropDown.add(item);
  void removeFromPrimDxDropDown(String item) => primDxDropDown.remove(item);
  void removeAtIndexFromPrimDxDropDown(int index) =>
      primDxDropDown.removeAt(index);
  void insertAtIndexInPrimDxDropDown(int index, String item) =>
      primDxDropDown.insert(index, item);
  void updatePrimDxDropDownAtIndex(int index, Function(String) updateFn) =>
      primDxDropDown[index] = updateFn(primDxDropDown[index]);

  List<String> secDxDropDown = [];
  void addToSecDxDropDown(String item) => secDxDropDown.add(item);
  void removeFromSecDxDropDown(String item) => secDxDropDown.remove(item);
  void removeAtIndexFromSecDxDropDown(int index) =>
      secDxDropDown.removeAt(index);
  void insertAtIndexInSecDxDropDown(int index, String item) =>
      secDxDropDown.insert(index, item);
  void updateSecDxDropDownAtIndex(int index, Function(String) updateFn) =>
      secDxDropDown[index] = updateFn(secDxDropDown[index]);

  List<String> primInsDropDown = [];
  void addToPrimInsDropDown(String item) => primInsDropDown.add(item);
  void removeFromPrimInsDropDown(String item) => primInsDropDown.remove(item);
  void removeAtIndexFromPrimInsDropDown(int index) =>
      primInsDropDown.removeAt(index);
  void insertAtIndexInPrimInsDropDown(int index, String item) =>
      primInsDropDown.insert(index, item);
  void updatePrimInsDropDownAtIndex(int index, Function(String) updateFn) =>
      primInsDropDown[index] = updateFn(primInsDropDown[index]);

  List<String> secInsDropDown = [];
  void addToSecInsDropDown(String item) => secInsDropDown.add(item);
  void removeFromSecInsDropDown(String item) => secInsDropDown.remove(item);
  void removeAtIndexFromSecInsDropDown(int index) =>
      secInsDropDown.removeAt(index);
  void insertAtIndexInSecInsDropDown(int index, String item) =>
      secInsDropDown.insert(index, item);
  void updateSecInsDropDownAtIndex(int index, Function(String) updateFn) =>
      secInsDropDown[index] = updateFn(secInsDropDown[index]);

  bool secondaryFiltersEnabled = false;

  bool applyEnabled = false;

  List<String> insTypeDropDown = [];
  void addToInsTypeDropDown(String item) => insTypeDropDown.add(item);
  void removeFromInsTypeDropDown(String item) => insTypeDropDown.remove(item);
  void removeAtIndexFromInsTypeDropDown(int index) =>
      insTypeDropDown.removeAt(index);
  void insertAtIndexInInsTypeDropDown(int index, String item) =>
      insTypeDropDown.insert(index, item);
  void updateInsTypeDropDownAtIndex(int index, Function(String) updateFn) =>
      insTypeDropDown[index] = updateFn(insTypeDropDown[index]);

  dynamic facilityData;

  dynamic providerData;

  dynamic clinicData;

  bool filtersChanged = false;

  dynamic groupFiltersUsed;

  bool newFiltersApplied = false;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in DuplicateGroupCopy widget.
  ApiCallResponse? groupDetails;
  // Stores action output result for [Backend Call - API (GQLgetClinicNames)] action in DuplicateGroupCopy widget.
  ApiCallResponse? getClinics;
  // Stores action output result for [Backend Call - API (GQLgetFacilityNames)] action in DuplicateGroupCopy widget.
  ApiCallResponse? getFacilityDP;
  // Stores action output result for [Backend Call - API (GQLgetProviderList)] action in DuplicateGroupCopy widget.
  ApiCallResponse? getProvidersDP;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in DuplicateGroupCopy widget.
  ApiCallResponse? getPrimDxDP;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in DuplicateGroupCopy widget.
  ApiCallResponse? getSecDxDP;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in DuplicateGroupCopy widget.
  ApiCallResponse? getPrimInsDP;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in DuplicateGroupCopy widget.
  ApiCallResponse? getSecInsDP;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in DuplicateGroupCopy widget.
  ApiCallResponse? getInsTypeDP;
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
  // State field(s) for clinicSelect widget.
  int? clinicSelectValue;
  FormFieldController<int>? clinicSelectValueController;
  // Stores action output result for [Backend Call - API (GQLgetProviderList)] action in clinicSelect widget.
  ApiCallResponse? getProviders;
  // Stores action output result for [Backend Call - API (GQLgetFacilityNames)] action in clinicSelect widget.
  ApiCallResponse? getFacility;
  // State field(s) for FacilitySelect widget.
  List<int>? facilitySelectValue;
  FormFieldController<List<int>>? facilitySelectValueController;
  // Stores action output result for [Backend Call - API (GQLgetProviderList)] action in FacilitySelect widget.
  ApiCallResponse? getProvidersII;
  // State field(s) for ProviderSelect widget.
  List<int>? providerSelectValue;
  FormFieldController<List<int>>? providerSelectValueController;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in btnApply widget.
  ApiCallResponse? getPrimDx;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in btnApply widget.
  ApiCallResponse? getSecDx;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in btnApply widget.
  ApiCallResponse? getPrimIns;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in btnApply widget.
  ApiCallResponse? getSecIns;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in btnApply widget.
  ApiCallResponse? getInsType;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in btnApply widget.
  ApiCallResponse? autofillValues;
  // State field(s) for PrimaryDxSelect widget.
  List<String>? primaryDxSelectValue;
  FormFieldController<List<String>>? primaryDxSelectValueController;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in PrimaryDxSelect widget.
  ApiCallResponse? getSecDxII;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in PrimaryDxSelect widget.
  ApiCallResponse? getPrimInsII;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in PrimaryDxSelect widget.
  ApiCallResponse? getSecInsII;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in PrimaryDxSelect widget.
  ApiCallResponse? getInsTypeII;
  // State field(s) for SecondaryDxSelect widget.
  List<String>? secondaryDxSelectValue;
  FormFieldController<List<String>>? secondaryDxSelectValueController;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in SecondaryDxSelect widget.
  ApiCallResponse? getPrimInsIII;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in SecondaryDxSelect widget.
  ApiCallResponse? getSecInsIII;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in SecondaryDxSelect widget.
  ApiCallResponse? getInsTypeIII;
  // State field(s) for ProgramEligibilitySelect widget.
  List<String>? programEligibilitySelectValue;
  FormFieldController<List<String>>? programEligibilitySelectValueController;
  // State field(s) for PrimaryInsuranceSelect widget.
  List<String>? primaryInsuranceSelectValue;
  FormFieldController<List<String>>? primaryInsuranceSelectValueController;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in PrimaryInsuranceSelect widget.
  ApiCallResponse? getSecInsIV;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in PrimaryInsuranceSelect widget.
  ApiCallResponse? getInsTypeIV;
  // State field(s) for SecondaryInsuranceSelect widget.
  List<String>? secondaryInsuranceSelectValue;
  FormFieldController<List<String>>? secondaryInsuranceSelectValueController;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in SecondaryInsuranceSelect widget.
  ApiCallResponse? getInsTypeV;
  // State field(s) for InsuranceTypeSelect widget.
  List<String>? insuranceTypeSelectValue;
  FormFieldController<List<String>>? insuranceTypeSelectValueController;
  // State field(s) for zipcodes widget.
  FocusNode? zipcodesFocusNode;
  TextEditingController? zipcodesTextController;
  String? Function(BuildContext, String?)? zipcodesTextControllerValidator;
  DateTime? datePicked;
  // State field(s) for GroupType widget.
  List<String>? groupTypeValue;
  FormFieldController<List<String>>? groupTypeValueController;
  // State field(s) for Switch widget.
  bool? switchValue;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in btnApply widget.
  ApiCallResponse? applyResponse;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in btnApply widget.
  ApiCallResponse? getPatientsByGroupType;
  // State field(s) for patientSearch widget.
  final patientSearchKey = GlobalKey();
  FocusNode? patientSearchFocusNode;
  TextEditingController? patientSearchTextController;
  String? patientSearchSelectedOption;
  String? Function(BuildContext, String?)? patientSearchTextControllerValidator;
  // Stores action output result for [Backend Call - API (GQLgetByFunction)] action in Button widget.
  ApiCallResponse? pcdID;
  // State field(s) for numberOfPatients widget.
  FocusNode? numberOfPatientsFocusNode;
  TextEditingController? numberOfPatientsTextController;
  String? Function(BuildContext, String?)?
      numberOfPatientsTextControllerValidator;
  // Stores action output result for [Backend Call - API (Create Group)] action in btnCreateGroup widget.
  ApiCallResponse? createGroup;
  // Stores action output result for [Backend Call - API (Create Group)] action in btnCreateGroup widget.
  ApiCallResponse? duplicateGroup;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    txtfldEnterGroupNameFocusNode?.dispose();
    txtfldEnterGroupNameTextController?.dispose();

    zipcodesFocusNode?.dispose();
    zipcodesTextController?.dispose();

    patientSearchFocusNode?.dispose();

    numberOfPatientsFocusNode?.dispose();
    numberOfPatientsTextController?.dispose();
  }
}
