import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_autocomplete_options_list.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'duplicate_group_copy_model.dart';
export 'duplicate_group_copy_model.dart';

class DuplicateGroupCopyWidget extends StatefulWidget {
  const DuplicateGroupCopyWidget({
    super.key,
    required this.groupID,
    required this.clinicID,
  });

  final int? groupID;
  final int? clinicID;

  static String routeName = 'DuplicateGroupCopy';
  static String routePath = 'duplicateGroupCopy';

  @override
  State<DuplicateGroupCopyWidget> createState() =>
      _DuplicateGroupCopyWidgetState();
}

class _DuplicateGroupCopyWidgetState extends State<DuplicateGroupCopyWidget> {
  late DuplicateGroupCopyModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DuplicateGroupCopyModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      safeSetState(() {
        _model.primaryInsuranceSelectValueController?.reset();
        _model.secondaryInsuranceSelectValueController?.reset();
        _model.insuranceTypeSelectValueController?.reset();
        _model.primaryDxSelectValueController?.reset();
        _model.secondaryDxSelectValueController?.reset();
        _model.programEligibilitySelectValueController?.reset();
        _model.groupTypeValueController?.reset();
        _model.facilitySelectValueController?.reset();
        _model.clinicSelectValueController?.reset();
        _model.providerSelectValueController?.reset();
      });
      safeSetState(() {
        _model.patientSearchTextController?.clear();
        _model.numberOfPatientsTextController?.clear();
        _model.zipcodesTextController?.clear();
      });
      _model.primDxDropDown = [];
      _model.secDxDropDown = [];
      _model.primInsDropDown = [];
      _model.secInsDropDown = [];
      _model.insTypeDropDown = [];
      _model.secondaryFiltersEnabled = false;
      _model.applyEnabled = false;
      _model.facilityData = null;
      _model.providerData = null;
      _model.clinicData = null;
      _model.filtersChanged = false;
      _model.groupFiltersUsed = null;
      _model.newFiltersApplied = false;
      safeSetState(() {});
      // groupDetails
      _model.groupDetails = await GQLgetByFunctionCall.call(
        hasuraToken: FFAppState().hasuraToken,
        requestBody:
            functions.getSingleGroupDetails(widget.groupID!).toString(),
      );

      // getClinics
      _model.getClinics = await GQLgetClinicNamesCall.call(
        hasuraToken: FFAppState().hasuraToken,
      );

      FFAppState().addedPPCIDs = [];
      safeSetState(() {});
      // getFacilityDP
      _model.getFacilityDP = await GQLgetFacilityNamesCall.call(
        hasuraToken: FFAppState().hasuraToken,
        clinicID: widget.clinicID?.toString(),
      );

      // getProvidersDP
      _model.getProvidersDP = await GQLgetProviderListCall.call(
        hasuraToken: FFAppState().hasuraToken,
        clinicID: widget.clinicID?.toString(),
      );

      // getPrimDxDP
      _model.getPrimDxDP = await GQLgetByFunctionCall.call(
        hasuraToken: FFAppState().hasuraToken,
        requestBody: functions
            .generatePrimaryListRequest(
                widget.clinicID!,
                functions
                    .returnIntList(getJsonField(
                      (_model.groupDetails?.jsonBody ?? ''),
                      r'''$.data.pep_vw_group_details[:].group_filters.providerID''',
                      true,
                    ))
                    .toList(),
                functions
                    .returnIntList(getJsonField(
                      (_model.groupDetails?.jsonBody ?? ''),
                      r'''$.data.pep_vw_group_details[:].group_filters.facilityID''',
                      true,
                    ))
                    .toList())
            .toString(),
      );

      // getSecDxDP
      _model.getSecDxDP = await GQLgetByFunctionCall.call(
        hasuraToken: FFAppState().hasuraToken,
        requestBody: functions
            .generateSecondaryListRequest(
                widget.clinicID!,
                functions
                    .returnIntList(getJsonField(
                      (_model.groupDetails?.jsonBody ?? ''),
                      r'''$.data.pep_vw_group_details[:].group_filters.providerID''',
                      true,
                    ))
                    .toList(),
                functions
                    .returnStringList(getJsonField(
                      (_model.groupDetails?.jsonBody ?? ''),
                      r'''$.data.pep_vw_group_details[:].group_filters.primaryDx''',
                      true,
                    ))
                    .toList(),
                functions
                    .returnIntList(getJsonField(
                      (_model.groupDetails?.jsonBody ?? ''),
                      r'''$.data.pep_vw_group_details[:].group_filters.facilityID''',
                      true,
                    ))
                    .toList())
            .toString(),
      );

      // getPrimInsDP
      _model.getPrimInsDP = await GQLgetByFunctionCall.call(
        hasuraToken: FFAppState().hasuraToken,
        requestBody: functions
            .generatePrimaryInsListRequest(
                widget.clinicID!,
                functions
                    .returnIntList(getJsonField(
                      (_model.groupDetails?.jsonBody ?? ''),
                      r'''$.data.pep_vw_group_details[:].group_filters.providerID''',
                      true,
                    ))
                    .toList(),
                functions
                    .returnStringList(getJsonField(
                      (_model.groupDetails?.jsonBody ?? ''),
                      r'''$.data.pep_vw_group_details[:].group_filters.primaryDx''',
                      true,
                    ))
                    .toList(),
                functions
                    .returnStringList(getJsonField(
                      (_model.groupDetails?.jsonBody ?? ''),
                      r'''$.data.pep_vw_group_details[:].group_filters.secondaryDx''',
                      true,
                    ))
                    .toList(),
                functions
                    .returnIntList(getJsonField(
                      (_model.groupDetails?.jsonBody ?? ''),
                      r'''$.data.pep_vw_group_details[:].group_filters.facilityID''',
                      true,
                    ))
                    .toList())
            .toString(),
      );

      // getSecInsDP
      _model.getSecInsDP = await GQLgetByFunctionCall.call(
        hasuraToken: FFAppState().hasuraToken,
        requestBody: functions
            .generateSecondaryInsListRequest(
                widget.clinicID!,
                functions
                    .returnIntList(getJsonField(
                      (_model.groupDetails?.jsonBody ?? ''),
                      r'''$.data.pep_vw_group_details[:].group_filters.providerID''',
                      true,
                    ))
                    .toList(),
                functions
                    .returnStringList(getJsonField(
                      (_model.groupDetails?.jsonBody ?? ''),
                      r'''$.data.pep_vw_group_details[:].group_filters.primaryDx''',
                      true,
                    ))
                    .toList(),
                functions
                    .returnStringList(getJsonField(
                      (_model.groupDetails?.jsonBody ?? ''),
                      r'''$.data.pep_vw_group_details[:].group_filters.secondaryDx''',
                      true,
                    ))
                    .toList(),
                functions
                    .returnStringList(getJsonField(
                      (_model.groupDetails?.jsonBody ?? ''),
                      r'''$.data.pep_vw_group_details[:].group_filters.primaryInsurance''',
                      true,
                    ))
                    .toList(),
                functions
                    .returnIntList(getJsonField(
                      (_model.groupDetails?.jsonBody ?? ''),
                      r'''$.data.pep_vw_group_details[:].group_filters.facilityID''',
                      true,
                    ))
                    .toList())
            .toString(),
      );

      // getInsTypeDP
      _model.getInsTypeDP = await GQLgetByFunctionCall.call(
        hasuraToken: FFAppState().hasuraToken,
        requestBody: functions
            .generateInsTypeListRequest(
                widget.clinicID!,
                functions
                    .returnIntList(getJsonField(
                      (_model.groupDetails?.jsonBody ?? ''),
                      r'''$.data.pep_vw_group_details[:].group_filters.providerID''',
                      true,
                    ))
                    .toList(),
                functions
                    .returnStringList(getJsonField(
                      (_model.groupDetails?.jsonBody ?? ''),
                      r'''$.data.pep_vw_group_details[:].group_filters.primaryDx''',
                      true,
                    ))
                    .toList(),
                functions
                    .returnStringList(getJsonField(
                      (_model.groupDetails?.jsonBody ?? ''),
                      r'''$.data.pep_vw_group_details[:].group_filters.secondaryDx''',
                      true,
                    ))
                    .toList(),
                functions
                    .returnStringList(getJsonField(
                      (_model.groupDetails?.jsonBody ?? ''),
                      r'''$.data.pep_vw_group_details[:].group_filters.primaryInsurance''',
                      true,
                    ))
                    .toList(),
                functions
                    .returnStringList(getJsonField(
                      (_model.groupDetails?.jsonBody ?? ''),
                      r'''$.data.pep_vw_group_details[:].group_filters.secondaryInsurance''',
                      true,
                    ))
                    .toList(),
                functions
                    .returnIntList(getJsonField(
                      (_model.groupDetails?.jsonBody ?? ''),
                      r'''$.data.pep_vw_group_details[:].group_filters.facilityID''',
                      true,
                    ))
                    .toList())
            .toString(),
      );

      _model.primDxDropDown = GQLgetByFunctionCall.primaryDxList(
        (_model.getPrimDxDP?.jsonBody ?? ''),
      )!
          .toList()
          .cast<String>();
      _model.secDxDropDown = GQLgetByFunctionCall.secondaryDxList(
        (_model.getSecDxDP?.jsonBody ?? ''),
      )!
          .toList()
          .cast<String>();
      _model.primInsDropDown = GQLgetByFunctionCall.primaryInsList(
        (_model.getPrimInsDP?.jsonBody ?? ''),
      )!
          .toList()
          .cast<String>();
      _model.secInsDropDown = GQLgetByFunctionCall.secondaryInsList(
        (_model.getSecInsDP?.jsonBody ?? ''),
      )!
          .toList()
          .cast<String>();
      _model.insTypeDropDown = GQLgetByFunctionCall.insuranceType(
        (_model.getInsTypeDP?.jsonBody ?? ''),
      )!
          .map((e) => e.toString())
          .toList()
          .toList()
          .cast<String>();
      _model.clinicData = (_model.getClinics?.jsonBody ?? '');
      _model.facilityData = (_model.getFacilityDP?.jsonBody ?? '');
      _model.providerData = (_model.getProvidersDP?.jsonBody ?? '');
      _model.applyEnabled = true;
      _model.secondaryFiltersEnabled = true;
      safeSetState(() {});
      _model.groupFiltersUsed = functions.groupFiltersUsed(
          functions.getClinicName(
              GQLgetClinicNamesCall.clinicDetailsMap(
                (_model.getClinics?.jsonBody ?? ''),
              )!
                  .toList(),
              widget.clinicID!),
          functions
              .getFacilityNames(
                  GQLgetFacilityNamesCall.facilityDetailsMap(
                    (_model.getFacilityDP?.jsonBody ?? ''),
                  )!
                      .toList(),
                  functions
                      .returnIntList(getJsonField(
                        (_model.groupDetails?.jsonBody ?? ''),
                        r'''$.data.pep_vw_group_details[:].group_filters.facilityID''',
                        true,
                      ))
                      .toList())
              .toList(),
          functions
              .getProviderNames(
                  GQLgetProviderListCall.providerDetailsMap(
                    (_model.getProvidersDP?.jsonBody ?? ''),
                  )!
                      .toList(),
                  functions
                      .returnIntList(getJsonField(
                        (_model.groupDetails?.jsonBody ?? ''),
                        r'''$.data.pep_vw_group_details[:].group_filters.providerID''',
                        true,
                      ))
                      .toList())
              .toList(),
          functions
              .returnStringList(getJsonField(
                (_model.groupDetails?.jsonBody ?? ''),
                r'''$.data.pep_vw_group_details[:].group_filters.primaryDx''',
                true,
              ))
              .toList(),
          functions
              .returnStringList(getJsonField(
                (_model.groupDetails?.jsonBody ?? ''),
                r'''$.data.pep_vw_group_details[:].group_filters.secondaryDx''',
                true,
              ))
              .toList(),
          functions
              .returnStringList(getJsonField(
                (_model.groupDetails?.jsonBody ?? ''),
                r'''$.data.pep_vw_group_details[:].group_filters.programEligibility''',
                true,
              ))
              .toList(),
          functions
              .returnStringList(getJsonField(
                (_model.groupDetails?.jsonBody ?? ''),
                r'''$.data.pep_vw_group_details[:].group_filters.primaryInsurance''',
                true,
              ))
              .toList(),
          functions
              .returnStringList(getJsonField(
                (_model.groupDetails?.jsonBody ?? ''),
                r'''$.data.pep_vw_group_details[:].group_filters.secondaryInsurance''',
                true,
              ))
              .toList(),
          functions
              .returnStringList(getJsonField(
                (_model.groupDetails?.jsonBody ?? ''),
                r'''$.data.pep_vw_group_details[:].group_filters.insuranceTypes''',
                true,
              ))
              .toList(),
          functions
              .returnStringList(getJsonField(
                (_model.groupDetails?.jsonBody ?? ''),
                r'''$.data.pep_vw_group_details[:].group_filters.groupTypes''',
                true,
              ))
              .toList(),
          functions.returnString(getJsonField(
            (_model.groupDetails?.jsonBody ?? ''),
            r'''$.data.pep_vw_group_details[:].group_filters.zipcodes''',
          )),
          functions.returnDT(functions.returnString(getJsonField(
            (_model.groupDetails?.jsonBody ?? ''),
            r'''$.data.pep_vw_group_details[:].group_filters.lastVisitDate''',
          ))),
          (String excludeFlag) {
            return excludeFlag == "true" ? true : false;
          }(getJsonField(
            (_model.groupDetails?.jsonBody ?? ''),
            r'''$.data.pep_vw_group_details[:].group_filters.excludeFlag''',
          ).toString().toString()),
          widget.clinicID!,
          functions
              .returnIntList(getJsonField(
                (_model.groupDetails?.jsonBody ?? ''),
                r'''$.data.pep_vw_group_details[:].group_filters.facilityID''',
                true,
              ))
              .toList(),
          functions
              .returnIntList(getJsonField(
                (_model.groupDetails?.jsonBody ?? ''),
                r'''$.data.pep_vw_group_details[:].group_filters.providerID''',
                true,
              ))
              .toList());
      safeSetState(() {});
    });

    _model.txtfldEnterGroupNameFocusNode ??= FocusNode();

    _model.zipcodesFocusNode ??= FocusNode();

    _model.patientSearchTextController ??= TextEditingController();

    _model.numberOfPatientsTextController ??= TextEditingController();
    _model.numberOfPatientsFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(80.0),
          child: AppBar(
            backgroundColor: FlutterFlowTheme.of(context).primary,
            automaticallyImplyLeading: false,
            title: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset(
                      'assets/images/primary_logo.png',
                      width: 180.0,
                      height: 70.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                    child: Text(
                      'Patient Enrollment Platform',
                      style:
                          FlutterFlowTheme.of(context).headlineSmall.override(
                                font: GoogleFonts.poppins(
                                  fontWeight: FontWeight.normal,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .headlineSmall
                                      .fontStyle,
                                ),
                                color: FlutterFlowTheme.of(context).primaryText,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.normal,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .headlineSmall
                                    .fontStyle,
                              ),
                    ),
                  ),
                ),
                Flexible(
                  child: FFButtonWidget(
                    onPressed: () async {
                      var confirmDialogResponse = await showDialog<bool>(
                            context: context,
                            builder: (alertDialogContext) {
                              return AlertDialog(
                                content:
                                    Text('Are you sure you want to sign out?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(
                                        alertDialogContext, false),
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(alertDialogContext, true),
                                    child: Text('Confirm'),
                                  ),
                                ],
                              );
                            },
                          ) ??
                          false;
                      if (confirmDialogResponse) {
                        FFAppState().deleteLoginToken();
                        FFAppState().loginToken = '';

                        FFAppState().deleteLoginEmail();
                        FFAppState().loginEmail = '';

                        FFAppState().deleteHasuraToken();
                        FFAppState().hasuraToken = '';

                        FFAppState().deleteLoginProfileID();
                        FFAppState().loginProfileID = '';

                        safeSetState(() {});

                        context.pushNamed(LoginWidget.routeName);
                      }
                    },
                    text: 'SIGNOUT',
                    options: FFButtonOptions(
                      height: 40.0,
                      padding:
                          EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                      iconPadding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                      color: FlutterFlowTheme.of(context).accent3,
                      textStyle:
                          FlutterFlowTheme.of(context).titleSmall.override(
                                font: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .fontStyle,
                                ),
                                color: FlutterFlowTheme.of(context).buttonText,
                                fontSize: 12.0,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w500,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .fontStyle,
                              ),
                      elevation: 3.0,
                      borderSide: BorderSide(
                        color: Colors.transparent,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ],
            ),
            actions: [],
            centerTitle: false,
            toolbarHeight: 80.0,
            elevation: 2.0,
          ),
        ),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 20.0),
            child: FutureBuilder<ApiCallResponse>(
              future: FFAppState().duplicateGroupDetails(
                requestFn: () => GQLgetByFunctionCall.call(
                  hasuraToken: FFAppState().hasuraToken,
                  requestBody: functions
                      .getSingleGroupDetails(widget.groupID!)
                      .toString(),
                ),
              ),
              builder: (context, snapshot) {
                // Customize what your widget looks like when it's loading.
                if (!snapshot.hasData) {
                  return Center(
                    child: SizedBox(
                      width: 50.0,
                      height: 50.0,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          FlutterFlowTheme.of(context).primary,
                        ),
                      ),
                    ),
                  );
                }
                final columnGQLgetByFunctionResponse = snapshot.data!;

                return SingleChildScrollView(
                  primary: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                        child: Container(
                          width: 750.0,
                          child: TextFormField(
                            controller:
                                _model.txtfldEnterGroupNameTextController ??=
                                    TextEditingController(
                              text: getJsonField(
                                columnGQLgetByFunctionResponse.jsonBody,
                                r'''$.data.pep_vw_group_details[:].group_name''',
                              ).toString(),
                            ),
                            focusNode: _model.txtfldEnterGroupNameFocusNode,
                            onChanged: (_) => EasyDebounce.debounce(
                              '_model.txtfldEnterGroupNameTextController',
                              Duration(milliseconds: 100),
                              () => safeSetState(() {}),
                            ),
                            autofocus: true,
                            textCapitalization: TextCapitalization.none,
                            textInputAction: TextInputAction.next,
                            obscureText: false,
                            decoration: InputDecoration(
                              labelText: 'Group Name*',
                              labelStyle: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .override(
                                    font: GoogleFonts.poppins(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .fontStyle,
                                    ),
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .fontStyle,
                                  ),
                              alignLabelWithHint: false,
                              hintText: 'Enter Group Name',
                              hintStyle: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .override(
                                    font: GoogleFonts.poppins(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .fontStyle,
                                    ),
                                    fontSize: 24.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .fontStyle,
                                  ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color:
                                      FlutterFlowTheme.of(context).borderColor,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).tertiary,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              errorBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).error,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              focusedErrorBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).error,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              filled: true,
                              fillColor: FlutterFlowTheme.of(context).accent1,
                              contentPadding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 20.0),
                              prefixIcon: Icon(
                                Icons.group_add,
                                color: FlutterFlowTheme.of(context).info,
                              ),
                            ),
                            style: FlutterFlowTheme.of(context)
                                .titleLarge
                                .override(
                                  font: GoogleFonts.poppins(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .titleLarge
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleLarge
                                        .fontStyle,
                                  ),
                                  fontSize: 32.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .titleLarge
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .titleLarge
                                      .fontStyle,
                                ),
                            textAlign: TextAlign.start,
                            maxLength: 64,
                            buildCounter: (context,
                                    {required currentLength,
                                    required isFocused,
                                    maxLength}) =>
                                null,
                            cursorColor: FlutterFlowTheme.of(context).tertiary,
                            validator: _model
                                .txtfldEnterGroupNameTextControllerValidator
                                .asValidator(context),
                            inputFormatters: [
                              if (!isAndroid && !isiOS)
                                TextInputFormatter.withFunction(
                                    (oldValue, newValue) {
                                  return TextEditingValue(
                                    selection: newValue.selection,
                                    text: newValue.text.toCapitalization(
                                        TextCapitalization.none),
                                  );
                                }),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                        child: Text(
                          'Virtual Enrollment Specialist (VPE)',
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.poppins(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
                        child: FutureBuilder<ApiCallResponse>(
                          future: FFAppState().virtualEnrollmentSpecialist(
                            requestFn: () => GQLgetByFunctionCall.call(
                              hasuraToken: FFAppState().hasuraToken,
                              requestBody:
                                  '{ \"query\": \"query MyQuery { pep_vw_enrollment_specialists { hbox_user_id es_name } }\" }',
                            ),
                          ),
                          builder: (context, snapshot) {
                            // Customize what your widget looks like when it's loading.
                            if (!snapshot.hasData) {
                              return Center(
                                child: SizedBox(
                                  width: 50.0,
                                  height: 50.0,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      FlutterFlowTheme.of(context).primary,
                                    ),
                                  ),
                                ),
                              );
                            }
                            final enrollmentSpecialistSelectGQLgetByFunctionResponse =
                                snapshot.data!;

                            return FlutterFlowDropDown<int>(
                              multiSelectController: _model
                                      .enrollmentSpecialistSelectValueController ??=
                                  FormListFieldController<int>(
                                      _model.enrollmentSpecialistSelectValue ??=
                                          List<int>.from(
                                getJsonField(
                                      columnGQLgetByFunctionResponse.jsonBody,
                                      r'''$.data.pep_vw_group_details[:].es_id''',
                                      true,
                                    ) ??
                                    [],
                              )),
                              options: List<int>.from(getJsonField(
                                enrollmentSpecialistSelectGQLgetByFunctionResponse
                                    .jsonBody,
                                r'''$.data.pep_vw_enrollment_specialists[:].hbox_user_id''',
                                true,
                              )!),
                              optionLabels: (getJsonField(
                                enrollmentSpecialistSelectGQLgetByFunctionResponse
                                    .jsonBody,
                                r'''$.data.pep_vw_enrollment_specialists[:].es_name''',
                                true,
                              ) as List)
                                  .map<String>((s) => s.toString())
                                  .toList(),
                              width: 360.0,
                              height: 56.0,
                              searchHintTextStyle: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .override(
                                    font: GoogleFonts.poppins(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .fontStyle,
                                    ),
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .fontStyle,
                                  ),
                              searchTextStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.poppins(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                              textStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.poppins(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                              hintText: 'Select Virtual Enrollment Specialist',
                              searchHintText: 'Search...',
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                                size: 24.0,
                              ),
                              fillColor: FlutterFlowTheme.of(context).accent1,
                              elevation: 2.0,
                              borderColor:
                                  FlutterFlowTheme.of(context).borderColor,
                              borderWidth: 2.0,
                              borderRadius: 8.0,
                              margin: EdgeInsetsDirectional.fromSTEB(
                                  16.0, 4.0, 16.0, 4.0),
                              hidesUnderline: true,
                              isOverButton: true,
                              isSearchable: true,
                              isMultiSelect: true,
                              onMultiSelectChanged: (val) => safeSetState(() =>
                                  _model.enrollmentSpecialistSelectValue = val),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Group Type*',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.poppins(
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          fontSize: 16.0,
                                          letterSpacing: 0.0,
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 12.0, 0.0, 0.0),
                                    child: FutureBuilder<ApiCallResponse>(
                                      future: FFAppState().groupType(
                                        requestFn: () =>
                                            GQLgetByFunctionCall.call(
                                          hasuraToken: FFAppState().hasuraToken,
                                          requestBody:
                                              '{\"query\":\"query MyQuery {pep_group_type_mapping(order_by: {id: asc}) { id group_type }}\"}',
                                        ),
                                      ),
                                      builder: (context, snapshot) {
                                        // Customize what your widget looks like when it's loading.
                                        if (!snapshot.hasData) {
                                          return Center(
                                            child: SizedBox(
                                              width: 50.0,
                                              height: 50.0,
                                              child: CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                        final selectTypeGQLgetByFunctionResponse =
                                            snapshot.data!;

                                        return FlutterFlowDropDown<String>(
                                          controller: _model
                                                  .selectTypeValueController ??=
                                              FormFieldController<String>(
                                            _model.selectTypeValue ??=
                                                getJsonField(
                                              columnGQLgetByFunctionResponse
                                                  .jsonBody,
                                              r'''$.data.pep_vw_group_details[:].group_type_id''',
                                            ).toString(),
                                          ),
                                          options: List<String>.from(
                                              (getJsonField(
                                            selectTypeGQLgetByFunctionResponse
                                                .jsonBody,
                                            r'''$.data.pep_group_type_mapping[:].id''',
                                            true,
                                          ) as List)
                                                  .map<String>(
                                                      (s) => s.toString())
                                                  .toList()),
                                          optionLabels: (getJsonField(
                                            selectTypeGQLgetByFunctionResponse
                                                .jsonBody,
                                            r'''$.data.pep_group_type_mapping[:].group_type''',
                                            true,
                                          ) as List)
                                              .map<String>((s) => s.toString())
                                              .toList(),
                                          onChanged: (val) => safeSetState(() =>
                                              _model.selectTypeValue = val),
                                          width: 240.0,
                                          height: 56.0,
                                          textStyle: FlutterFlowTheme.of(
                                                  context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.poppins(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                fontSize: 16.0,
                                                letterSpacing: 0.0,
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                          hintText: 'Select Type',
                                          icon: Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryText,
                                            size: 24.0,
                                          ),
                                          fillColor:
                                              FlutterFlowTheme.of(context)
                                                  .accent1,
                                          elevation: 2.0,
                                          borderColor:
                                              FlutterFlowTheme.of(context)
                                                  .borderColor,
                                          borderWidth: 2.0,
                                          borderRadius: 8.0,
                                          margin:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  16.0, 4.0, 16.0, 4.0),
                                          hidesUnderline: true,
                                          isOverButton: true,
                                          isSearchable: false,
                                          isMultiSelect: false,
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ].divide(SizedBox(width: 20.0)),
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                        child: Text(
                          'Select Clinics and Providers',
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.poppins(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              if (_model.clinicData != null)
                                Align(
                                  alignment: AlignmentDirectional(0.0, 0.0),
                                  child: FlutterFlowDropDown<int>(
                                    controller:
                                        _model.clinicSelectValueController ??=
                                            FormFieldController<int>(
                                      _model.clinicSelectValue ??=
                                          _model.filtersChanged
                                              ? null
                                              : getJsonField(
                                                  columnGQLgetByFunctionResponse
                                                      .jsonBody,
                                                  r'''$.data.pep_vw_group_details[:].group_filters.clinicID''',
                                                ),
                                    ),
                                    options: List<int>.from(getJsonField(
                                      _model.clinicData,
                                      r'''$.data.pep_vw_available_clinics[:].clinic_id''',
                                      true,
                                    )!),
                                    optionLabels: (getJsonField(
                                      _model.clinicData,
                                      r'''$.data.pep_vw_available_clinics[:].clinic_name''',
                                      true,
                                    ) as List)
                                        .map<String>((s) => s.toString())
                                        .toList(),
                                    onChanged: (val) async {
                                      safeSetState(
                                          () => _model.clinicSelectValue = val);
                                      _model.filtersChanged = true;
                                      safeSetState(() {});
                                      _model.applyEnabled = false;
                                      safeSetState(() {});
                                      FFAppState().addedPPCIDs = [];
                                      safeSetState(() {});
                                      safeSetState(() {
                                        _model.providerSelectValueController
                                            ?.reset();
                                        _model.facilitySelectValueController
                                            ?.reset();
                                        _model.primaryDxSelectValueController
                                            ?.reset();
                                        _model.secondaryDxSelectValueController
                                            ?.reset();
                                        _model
                                            .programEligibilitySelectValueController
                                            ?.reset();
                                        _model
                                            .secondaryInsuranceSelectValueController
                                            ?.reset();
                                        _model
                                            .insuranceTypeSelectValueController
                                            ?.reset();
                                        _model
                                            .primaryInsuranceSelectValueController
                                            ?.reset();
                                        _model.groupTypeValueController
                                            ?.reset();
                                      });
                                      _model.providerData = null;
                                      _model.facilityData = null;
                                      safeSetState(() {});
                                      _model.getProviders =
                                          await GQLgetProviderListCall.call(
                                        hasuraToken: FFAppState().hasuraToken,
                                        clinicID: _model.clinicSelectValue
                                            ?.toString(),
                                      );

                                      _model.getFacility =
                                          await GQLgetFacilityNamesCall.call(
                                        hasuraToken: FFAppState().hasuraToken,
                                        clinicID: _model.clinicSelectValue
                                            ?.toString(),
                                      );

                                      _model.providerData =
                                          (_model.getProviders?.jsonBody ?? '');
                                      _model.facilityData =
                                          (_model.getFacility?.jsonBody ?? '');
                                      safeSetState(() {});
                                      _model.secondaryFiltersEnabled = false;
                                      _model.applyEnabled = true;
                                      safeSetState(() {});

                                      safeSetState(() {});
                                    },
                                    width: 300.0,
                                    height: 56.0,
                                    searchHintTextStyle:
                                        FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .override(
                                              font: GoogleFonts.poppins(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium
                                                        .fontStyle,
                                              ),
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .fontStyle,
                                            ),
                                    searchTextStyle:
                                        FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.poppins(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                    textStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.poppins(
                                            fontWeight: FontWeight.normal,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          fontSize: 16.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.normal,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                    hintText: 'Select Clinic*',
                                    searchHintText: 'Search...',
                                    icon: Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      size: 24.0,
                                    ),
                                    fillColor:
                                        FlutterFlowTheme.of(context).accent1,
                                    elevation: 2.0,
                                    borderColor: FlutterFlowTheme.of(context)
                                        .borderColor,
                                    borderWidth: 2.0,
                                    borderRadius: 8.0,
                                    margin: EdgeInsetsDirectional.fromSTEB(
                                        16.0, 4.0, 16.0, 4.0),
                                    hidesUnderline: true,
                                    isOverButton: true,
                                    isSearchable: true,
                                    isMultiSelect: false,
                                  ),
                                ),
                              if (_model.facilityData != null)
                                Align(
                                  alignment: AlignmentDirectional(0.0, 0.0),
                                  child: FlutterFlowDropDown<int>(
                                    multiSelectController:
                                        _model.facilitySelectValueController ??=
                                            FormListFieldController<int>(
                                                _model.facilitySelectValue ??=
                                                    List<int>.from(
                                      _model.filtersChanged
                                          ? (<int>[])
                                          : functions
                                                  .returnIntList(getJsonField(
                                                columnGQLgetByFunctionResponse
                                                    .jsonBody,
                                                r'''$.data.pep_vw_group_details[:].group_filters.facilityID''',
                                                true,
                                              )) ??
                                              [],
                                    )),
                                    options: List<int>.from(getJsonField(
                                      _model.facilityData,
                                      r'''$.data.pep_vw_consolidated_data[:].facility_id''',
                                      true,
                                    )!),
                                    optionLabels: (getJsonField(
                                      _model.facilityData,
                                      r'''$.data.pep_vw_consolidated_data[:].facility_name''',
                                      true,
                                    ) as List)
                                        .map<String>((s) => s.toString())
                                        .toList(),
                                    width: 300.0,
                                    height: 56.0,
                                    searchHintTextStyle:
                                        FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .override(
                                              font: GoogleFonts.poppins(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium
                                                        .fontStyle,
                                              ),
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .fontStyle,
                                            ),
                                    searchTextStyle:
                                        FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.poppins(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                    textStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.poppins(
                                            fontWeight: FontWeight.normal,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          fontSize: 16.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.normal,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                    hintText: 'Select Facility Name',
                                    searchHintText: 'Search...',
                                    icon: Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      size: 24.0,
                                    ),
                                    fillColor:
                                        FlutterFlowTheme.of(context).accent1,
                                    elevation: 2.0,
                                    borderColor: FlutterFlowTheme.of(context)
                                        .borderColor,
                                    borderWidth: 2.0,
                                    borderRadius: 8.0,
                                    margin: EdgeInsetsDirectional.fromSTEB(
                                        16.0, 4.0, 16.0, 4.0),
                                    hidesUnderline: true,
                                    isOverButton: true,
                                    isSearchable: true,
                                    isMultiSelect: true,
                                    onMultiSelectChanged: (val) async {
                                      safeSetState(() =>
                                          _model.facilitySelectValue = val);
                                      _model.filtersChanged = true;
                                      safeSetState(() {});
                                      _model.applyEnabled = false;
                                      safeSetState(() {});
                                      safeSetState(() {
                                        _model.providerSelectValueController
                                            ?.reset();
                                      });
                                      _model.providerData = null;
                                      safeSetState(() {});
                                      _model.getProvidersII =
                                          await GQLgetProviderListCall.call(
                                        hasuraToken: FFAppState().hasuraToken,
                                        clinicID: _model.clinicSelectValue
                                            ?.toString(),
                                      );

                                      _model.providerData =
                                          (_model.getProvidersII?.jsonBody ??
                                              '');
                                      safeSetState(() {});
                                      _model.secondaryFiltersEnabled = false;
                                      safeSetState(() {});
                                      _model.applyEnabled = true;
                                      safeSetState(() {});

                                      safeSetState(() {});
                                    },
                                  ),
                                ),
                              if (_model.providerData != null)
                                Align(
                                  alignment: AlignmentDirectional(0.0, 0.0),
                                  child: FlutterFlowDropDown<int>(
                                    multiSelectController:
                                        _model.providerSelectValueController ??=
                                            FormListFieldController<int>(
                                                _model.providerSelectValue ??=
                                                    List<int>.from(
                                      _model.filtersChanged
                                          ? (<int>[])
                                          : functions
                                                  .returnIntList(getJsonField(
                                                columnGQLgetByFunctionResponse
                                                    .jsonBody,
                                                r'''$.data.pep_vw_group_details[:].group_filters.providerID''',
                                                true,
                                              )) ??
                                              [],
                                    )),
                                    options: List<int>.from(getJsonField(
                                      _model.providerData,
                                      r'''$.data.pep_vw_consolidated_data[:].provider_id''',
                                      true,
                                    )!),
                                    optionLabels: (getJsonField(
                                      _model.providerData,
                                      r'''$.data.pep_vw_consolidated_data[:].provider_name''',
                                      true,
                                    ) as List)
                                        .map<String>((s) => s.toString())
                                        .toList(),
                                    width: 300.0,
                                    height: 56.0,
                                    searchHintTextStyle:
                                        FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .override(
                                              font: GoogleFonts.poppins(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium
                                                        .fontStyle,
                                              ),
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .fontStyle,
                                            ),
                                    searchTextStyle:
                                        FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.poppins(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                    textStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.poppins(
                                            fontWeight: FontWeight.normal,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          fontSize: 16.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.normal,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                    hintText: 'Select Provider',
                                    searchHintText: 'Search...',
                                    icon: Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      size: 24.0,
                                    ),
                                    fillColor:
                                        FlutterFlowTheme.of(context).accent1,
                                    elevation: 2.0,
                                    borderColor: FlutterFlowTheme.of(context)
                                        .borderColor,
                                    borderWidth: 2.0,
                                    borderRadius: 8.0,
                                    margin: EdgeInsetsDirectional.fromSTEB(
                                        16.0, 4.0, 16.0, 4.0),
                                    hidesUnderline: true,
                                    isOverButton: true,
                                    isSearchable: true,
                                    isMultiSelect: true,
                                    onMultiSelectChanged: (val) async {
                                      safeSetState(() =>
                                          _model.providerSelectValue = val);
                                      _model.filtersChanged = true;
                                      safeSetState(() {});
                                      _model.applyEnabled = false;
                                      safeSetState(() {});
                                      _model.secondaryFiltersEnabled = false;
                                      safeSetState(() {});
                                      _model.applyEnabled = true;
                                      safeSetState(() {});
                                    },
                                  ),
                                ),
                              FFButtonWidget(
                                onPressed: !_model.applyEnabled
                                    ? null
                                    : () async {
                                        if (_model.clinicSelectValue != null) {
                                          _model.filtersChanged = true;
                                          safeSetState(() {});
                                          safeSetState(() {
                                            _model
                                                .primaryInsuranceSelectValueController
                                                ?.reset();
                                            _model
                                                .secondaryInsuranceSelectValueController
                                                ?.reset();
                                            _model
                                                .insuranceTypeSelectValueController
                                                ?.reset();
                                            _model
                                                .primaryDxSelectValueController
                                                ?.reset();
                                            _model
                                                .secondaryDxSelectValueController
                                                ?.reset();
                                            _model
                                                .programEligibilitySelectValueController
                                                ?.reset();
                                            _model.groupTypeValueController
                                                ?.reset();
                                          });
                                          safeSetState(() {
                                            _model.patientSearchTextController
                                                ?.clear();
                                            _model
                                                .numberOfPatientsTextController
                                                ?.clear();
                                            _model.zipcodesTextController
                                                ?.clear();
                                          });
                                          _model.primDxDropDown = [];
                                          _model.secDxDropDown = [];
                                          _model.primInsDropDown = [];
                                          _model.secInsDropDown = [];
                                          _model.insTypeDropDown = [];
                                          _model.filtersChanged = true;
                                          safeSetState(() {});
                                          _model.getPrimDx =
                                              await GQLgetByFunctionCall.call(
                                            hasuraToken:
                                                FFAppState().hasuraToken,
                                            requestBody: functions
                                                .generatePrimaryListRequest(
                                                    _model.clinicSelectValue!,
                                                    _model.providerSelectValue
                                                        ?.toList(),
                                                    _model.facilitySelectValue
                                                        ?.toList())
                                                .toString(),
                                          );

                                          _model.getSecDx =
                                              await GQLgetByFunctionCall.call(
                                            hasuraToken:
                                                FFAppState().hasuraToken,
                                            requestBody: functions
                                                .generateSecondaryListRequest(
                                                    _model.clinicSelectValue!,
                                                    _model.providerSelectValue
                                                        ?.toList(),
                                                    (<String>[]).toList(),
                                                    _model.facilitySelectValue
                                                        ?.toList())
                                                .toString(),
                                          );

                                          _model.getPrimIns =
                                              await GQLgetByFunctionCall.call(
                                            hasuraToken:
                                                FFAppState().hasuraToken,
                                            requestBody: functions
                                                .generatePrimaryInsListRequest(
                                                    _model.clinicSelectValue!,
                                                    _model.providerSelectValue
                                                        ?.toList(),
                                                    (<String>[]).toList(),
                                                    (<String>[]).toList(),
                                                    _model.facilitySelectValue
                                                        ?.toList())
                                                .toString(),
                                          );

                                          _model.getSecIns =
                                              await GQLgetByFunctionCall.call(
                                            hasuraToken:
                                                FFAppState().hasuraToken,
                                            requestBody: functions
                                                .generateSecondaryInsListRequest(
                                                    _model.clinicSelectValue!,
                                                    _model.providerSelectValue
                                                        ?.toList(),
                                                    (<String>[]).toList(),
                                                    (<String>[]).toList(),
                                                    (<String>[]).toList(),
                                                    _model.facilitySelectValue
                                                        ?.toList())
                                                .toString(),
                                          );

                                          _model.getInsType =
                                              await GQLgetByFunctionCall.call(
                                            hasuraToken:
                                                FFAppState().hasuraToken,
                                            requestBody: functions
                                                .generateInsTypeListRequest(
                                                    _model.clinicSelectValue!,
                                                    _model.providerSelectValue
                                                        ?.toList(),
                                                    (<String>[]).toList(),
                                                    (<String>[]).toList(),
                                                    (<String>[]).toList(),
                                                    (<String>[]).toList(),
                                                    _model.facilitySelectValue
                                                        ?.toList())
                                                .toString(),
                                          );

                                          _model.autofillValues =
                                              await GQLgetByFunctionCall.call(
                                            hasuraToken:
                                                FFAppState().hasuraToken,
                                            requestBody: functions
                                                .autofillSearch(
                                                    _model.clinicSelectValue!,
                                                    '|')
                                                .toString(),
                                          );

                                          _model.primDxDropDown =
                                              GQLgetByFunctionCall
                                                      .primaryDxList(
                                            (_model.getPrimDx?.jsonBody ?? ''),
                                          )!
                                                  .toList()
                                                  .cast<String>();
                                          _model.secDxDropDown =
                                              GQLgetByFunctionCall
                                                      .secondaryDxList(
                                            (_model.getSecDx?.jsonBody ?? ''),
                                          )!
                                                  .toList()
                                                  .cast<String>();
                                          _model.primInsDropDown =
                                              GQLgetByFunctionCall
                                                      .primaryInsList(
                                            (_model.getPrimIns?.jsonBody ?? ''),
                                          )!
                                                  .toList()
                                                  .cast<String>();
                                          _model.secInsDropDown =
                                              GQLgetByFunctionCall
                                                      .secondaryInsList(
                                            (_model.getSecIns?.jsonBody ?? ''),
                                          )!
                                                  .toList()
                                                  .cast<String>();
                                          _model.insTypeDropDown =
                                              GQLgetByFunctionCall
                                                      .insuranceType(
                                            (_model.getInsType?.jsonBody ?? ''),
                                          )!
                                                  .map((e) => e.toString())
                                                  .toList()
                                                  .cast<String>();
                                          safeSetState(() {});
                                          _model.secondaryFiltersEnabled = true;
                                          safeSetState(() {});
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Select a Clinic',
                                                style: TextStyle(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryText,
                                                ),
                                              ),
                                              duration:
                                                  Duration(milliseconds: 4000),
                                              backgroundColor:
                                                  FlutterFlowTheme.of(context)
                                                      .error,
                                            ),
                                          );
                                        }

                                        safeSetState(() {});
                                      },
                                text: 'Apply',
                                options: FFButtonOptions(
                                  width: 120.0,
                                  height: 50.0,
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      24.0, 0.0, 24.0, 0.0),
                                  iconPadding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 0.0),
                                  color: FlutterFlowTheme.of(context).tertiary,
                                  textStyle: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .override(
                                        font: GoogleFonts.poppins(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .titleMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .titleMedium
                                                  .fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .buttonText,
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .titleMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .titleMedium
                                            .fontStyle,
                                      ),
                                  elevation: 3.0,
                                  borderSide: BorderSide(
                                    color: Colors.transparent,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                  disabledColor:
                                      FlutterFlowTheme.of(context).borderColor,
                                ),
                              ),
                            ].divide(SizedBox(width: 20.0)),
                          ),
                        ),
                      ),
                      if (_model.secondaryFiltersEnabled)
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 20.0, 0.0, 0.0),
                          child: Text(
                            'Filters',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.poppins(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  fontSize: 16.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                          ),
                        ),
                      if (_model.secondaryFiltersEnabled)
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 12.0, 0.0, 0.0),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Align(
                                  alignment: AlignmentDirectional(0.0, -1.0),
                                  child: FlutterFlowDropDown<String>(
                                    multiSelectController: _model
                                            .primaryDxSelectValueController ??=
                                        FormListFieldController<String>(
                                            _model.primaryDxSelectValue ??=
                                                List<String>.from(
                                      _model.filtersChanged
                                          ? (<String>[])
                                          : functions.returnStringList(
                                                  getJsonField(
                                                columnGQLgetByFunctionResponse
                                                    .jsonBody,
                                                r'''$.data.pep_vw_group_details[:].group_filters.primaryDx''',
                                                true,
                                              )) ??
                                              [],
                                    )),
                                    options: _model.primDxDropDown,
                                    width: 300.0,
                                    height: 56.0,
                                    searchHintTextStyle:
                                        FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .override(
                                              font: GoogleFonts.poppins(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium
                                                        .fontStyle,
                                              ),
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .fontStyle,
                                            ),
                                    searchTextStyle:
                                        FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.poppins(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                    textStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.poppins(
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          fontSize: 16.0,
                                          letterSpacing: 0.0,
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                    hintText: 'Select Primary Dx',
                                    searchHintText: 'Search...',
                                    icon: Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      size: 24.0,
                                    ),
                                    fillColor:
                                        FlutterFlowTheme.of(context).accent1,
                                    elevation: 2.0,
                                    borderColor: FlutterFlowTheme.of(context)
                                        .borderColor,
                                    borderWidth: 2.0,
                                    borderRadius: 8.0,
                                    margin: EdgeInsetsDirectional.fromSTEB(
                                        16.0, 4.0, 16.0, 4.0),
                                    hidesUnderline: true,
                                    disabled:
                                        !(_model.primDxDropDown.isNotEmpty),
                                    isOverButton: true,
                                    isSearchable: true,
                                    isMultiSelect: true,
                                    onMultiSelectChanged: (val) async {
                                      safeSetState(() =>
                                          _model.primaryDxSelectValue = val);
                                      _model.filtersChanged = true;
                                      safeSetState(() {});
                                      safeSetState(() {
                                        _model
                                            .primaryInsuranceSelectValueController
                                            ?.reset();
                                        _model
                                            .secondaryInsuranceSelectValueController
                                            ?.reset();
                                        _model.secondaryDxSelectValueController
                                            ?.reset();
                                        _model
                                            .insuranceTypeSelectValueController
                                            ?.reset();
                                      });
                                      if (_model.primaryDxSelectValue != null &&
                                          (_model.primaryDxSelectValue)!
                                              .isNotEmpty) {
                                        _model.secDxDropDown = [];
                                        _model.primInsDropDown = [];
                                        _model.secInsDropDown = [];
                                        _model.insTypeDropDown = [];
                                        safeSetState(() {});
                                        _model.getSecDxII =
                                            await GQLgetByFunctionCall.call(
                                          hasuraToken: FFAppState().hasuraToken,
                                          requestBody: functions
                                              .generateSecondaryListRequest(
                                                  _model.clinicSelectValue!,
                                                  _model.providerSelectValue
                                                      ?.toList(),
                                                  _model.primaryDxSelectValue
                                                      ?.toList(),
                                                  _model.facilitySelectValue
                                                      ?.toList())
                                              .toString(),
                                        );

                                        _model.getPrimInsII =
                                            await GQLgetByFunctionCall.call(
                                          hasuraToken: FFAppState().hasuraToken,
                                          requestBody: functions
                                              .generatePrimaryInsListRequest(
                                                  _model.clinicSelectValue!,
                                                  _model.providerSelectValue
                                                      ?.toList(),
                                                  _model.primaryDxSelectValue
                                                      ?.toList(),
                                                  _model.secondaryDxSelectValue
                                                      ?.toList(),
                                                  _model.facilitySelectValue
                                                      ?.toList())
                                              .toString(),
                                        );

                                        _model.getSecInsII =
                                            await GQLgetByFunctionCall.call(
                                          hasuraToken: FFAppState().hasuraToken,
                                          requestBody: functions
                                              .generateSecondaryInsListRequest(
                                                  _model.clinicSelectValue!,
                                                  _model.providerSelectValue
                                                      ?.toList(),
                                                  _model.primaryDxSelectValue
                                                      ?.toList(),
                                                  _model.secondaryDxSelectValue
                                                      ?.toList(),
                                                  _model
                                                      .primaryInsuranceSelectValue
                                                      ?.toList(),
                                                  _model.facilitySelectValue
                                                      ?.toList())
                                              .toString(),
                                        );

                                        _model.getInsTypeII =
                                            await GQLgetByFunctionCall.call(
                                          hasuraToken: FFAppState().hasuraToken,
                                          requestBody: functions
                                              .generateInsTypeListRequest(
                                                  _model.clinicSelectValue!,
                                                  _model.providerSelectValue
                                                      ?.toList(),
                                                  _model.primaryDxSelectValue
                                                      ?.toList(),
                                                  _model.secondaryDxSelectValue
                                                      ?.toList(),
                                                  _model
                                                      .primaryInsuranceSelectValue
                                                      ?.toList(),
                                                  _model
                                                      .secondaryInsuranceSelectValue
                                                      ?.toList(),
                                                  _model.facilitySelectValue
                                                      ?.toList())
                                              .toString(),
                                        );

                                        _model.secDxDropDown =
                                            GQLgetByFunctionCall
                                                    .secondaryDxList(
                                          (_model.getSecDxII?.jsonBody ?? ''),
                                        )!
                                                .toList()
                                                .cast<String>();
                                        _model.primInsDropDown =
                                            GQLgetByFunctionCall.primaryInsList(
                                          (_model.getPrimInsII?.jsonBody ?? ''),
                                        )!
                                                .toList()
                                                .cast<String>();
                                        _model.secInsDropDown =
                                            GQLgetByFunctionCall
                                                    .secondaryInsList(
                                          (_model.getSecInsII?.jsonBody ?? ''),
                                        )!
                                                .toList()
                                                .cast<String>();
                                        _model.insTypeDropDown =
                                            GQLgetByFunctionCall.insuranceType(
                                          (_model.getInsTypeII?.jsonBody ?? ''),
                                        )!
                                                .map((e) => e.toString())
                                                .toList()
                                                .cast<String>();
                                        safeSetState(() {});
                                      }

                                      safeSetState(() {});
                                    },
                                  ),
                                ),
                                Align(
                                  alignment: AlignmentDirectional(0.0, -1.0),
                                  child: FlutterFlowDropDown<String>(
                                    multiSelectController: _model
                                            .secondaryDxSelectValueController ??=
                                        FormListFieldController<String>(
                                            _model.secondaryDxSelectValue ??=
                                                List<String>.from(
                                      _model.filtersChanged
                                          ? (<String>[])
                                          : functions.returnStringList(
                                                  getJsonField(
                                                columnGQLgetByFunctionResponse
                                                    .jsonBody,
                                                r'''$.data.pep_vw_group_details[:].group_filters.secondaryDx''',
                                                true,
                                              )) ??
                                              [],
                                    )),
                                    options: _model.secDxDropDown,
                                    width: 300.0,
                                    height: 56.0,
                                    searchHintTextStyle:
                                        FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .override(
                                              font: GoogleFonts.poppins(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium
                                                        .fontStyle,
                                              ),
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .fontStyle,
                                            ),
                                    searchTextStyle:
                                        FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.poppins(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                    textStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.poppins(
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          fontSize: 16.0,
                                          letterSpacing: 0.0,
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                    hintText: 'Select Secondary Dx',
                                    searchHintText: 'Search...',
                                    icon: Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      size: 24.0,
                                    ),
                                    fillColor:
                                        FlutterFlowTheme.of(context).accent1,
                                    elevation: 2.0,
                                    borderColor: FlutterFlowTheme.of(context)
                                        .borderColor,
                                    borderWidth: 2.0,
                                    borderRadius: 8.0,
                                    margin: EdgeInsetsDirectional.fromSTEB(
                                        16.0, 4.0, 16.0, 4.0),
                                    hidesUnderline: true,
                                    disabled:
                                        !(_model.secDxDropDown.isNotEmpty),
                                    isOverButton: true,
                                    isSearchable: true,
                                    isMultiSelect: true,
                                    onMultiSelectChanged: (val) async {
                                      safeSetState(() =>
                                          _model.secondaryDxSelectValue = val);
                                      _model.filtersChanged = true;
                                      safeSetState(() {});
                                      safeSetState(() {
                                        _model
                                            .primaryInsuranceSelectValueController
                                            ?.reset();
                                        _model
                                            .secondaryInsuranceSelectValueController
                                            ?.reset();
                                        _model
                                            .insuranceTypeSelectValueController
                                            ?.reset();
                                      });
                                      if (_model.secondaryDxSelectValue !=
                                              null &&
                                          (_model.secondaryDxSelectValue)!
                                              .isNotEmpty) {
                                        _model.primInsDropDown = [];
                                        _model.secInsDropDown = [];
                                        _model.insTypeDropDown = [];
                                        safeSetState(() {});
                                        _model.getPrimInsIII =
                                            await GQLgetByFunctionCall.call(
                                          hasuraToken: FFAppState().hasuraToken,
                                          requestBody: functions
                                              .generatePrimaryInsListRequest(
                                                  _model.clinicSelectValue!,
                                                  _model.providerSelectValue
                                                      ?.toList(),
                                                  _model.primaryDxSelectValue
                                                      ?.toList(),
                                                  _model.secondaryDxSelectValue
                                                      ?.toList(),
                                                  _model.facilitySelectValue
                                                      ?.toList())
                                              .toString(),
                                        );

                                        _model.getSecInsIII =
                                            await GQLgetByFunctionCall.call(
                                          hasuraToken: FFAppState().hasuraToken,
                                          requestBody: functions
                                              .generateSecondaryInsListRequest(
                                                  _model.clinicSelectValue!,
                                                  _model.providerSelectValue
                                                      ?.toList(),
                                                  _model.primaryDxSelectValue
                                                      ?.toList(),
                                                  _model.secondaryDxSelectValue
                                                      ?.toList(),
                                                  _model
                                                      .primaryInsuranceSelectValue
                                                      ?.toList(),
                                                  _model.facilitySelectValue
                                                      ?.toList())
                                              .toString(),
                                        );

                                        _model.getInsTypeIII =
                                            await GQLgetByFunctionCall.call(
                                          hasuraToken: FFAppState().hasuraToken,
                                          requestBody: functions
                                              .generateInsTypeListRequest(
                                                  _model.clinicSelectValue!,
                                                  _model.providerSelectValue
                                                      ?.toList(),
                                                  _model.primaryDxSelectValue
                                                      ?.toList(),
                                                  _model.secondaryDxSelectValue
                                                      ?.toList(),
                                                  _model
                                                      .primaryInsuranceSelectValue
                                                      ?.toList(),
                                                  _model
                                                      .secondaryInsuranceSelectValue
                                                      ?.toList(),
                                                  _model.facilitySelectValue
                                                      ?.toList())
                                              .toString(),
                                        );

                                        _model.primInsDropDown =
                                            GQLgetByFunctionCall.primaryInsList(
                                          (_model.getPrimInsIII?.jsonBody ??
                                              ''),
                                        )!
                                                .toList()
                                                .cast<String>();
                                        _model.secInsDropDown =
                                            GQLgetByFunctionCall
                                                    .secondaryInsList(
                                          (_model.getSecInsIII?.jsonBody ?? ''),
                                        )!
                                                .toList()
                                                .cast<String>();
                                        _model.insTypeDropDown =
                                            GQLgetByFunctionCall.insuranceType(
                                          (_model.getInsTypeIII?.jsonBody ??
                                              ''),
                                        )!
                                                .map((e) => e.toString())
                                                .toList()
                                                .cast<String>();
                                        safeSetState(() {});
                                      }

                                      safeSetState(() {});
                                    },
                                  ),
                                ),
                                Align(
                                  alignment: AlignmentDirectional(0.0, -1.0),
                                  child: FlutterFlowDropDown<String>(
                                    multiSelectController: _model
                                            .programEligibilitySelectValueController ??=
                                        FormListFieldController<String>(_model
                                                .programEligibilitySelectValue ??=
                                            List<String>.from(
                                      _model.filtersChanged
                                          ? (<String>[])
                                          : functions.returnStringList(
                                                  getJsonField(
                                                columnGQLgetByFunctionResponse
                                                    .jsonBody,
                                                r'''$.data.pep_vw_group_details[:].group_filters.programEligibility''',
                                                true,
                                              )) ??
                                              [],
                                    )),
                                    options: ['PCM', 'CCM', 'RPM'],
                                    width: 300.0,
                                    height: 56.0,
                                    textStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.poppins(
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          fontSize: 16.0,
                                          letterSpacing: 0.0,
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                    hintText: 'Select Program Eligibility',
                                    icon: Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      size: 24.0,
                                    ),
                                    fillColor:
                                        FlutterFlowTheme.of(context).accent1,
                                    elevation: 2.0,
                                    borderColor: FlutterFlowTheme.of(context)
                                        .borderColor,
                                    borderWidth: 2.0,
                                    borderRadius: 8.0,
                                    margin: EdgeInsetsDirectional.fromSTEB(
                                        16.0, 4.0, 16.0, 4.0),
                                    hidesUnderline: true,
                                    isOverButton: true,
                                    isSearchable: false,
                                    isMultiSelect: true,
                                    onMultiSelectChanged: (val) async {
                                      safeSetState(() => _model
                                          .programEligibilitySelectValue = val);
                                      _model.filtersChanged = true;
                                      safeSetState(() {});
                                    },
                                  ),
                                ),
                              ].divide(SizedBox(width: 20.0)),
                            ),
                          ),
                        ),
                      if (_model.secondaryFiltersEnabled)
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 12.0, 0.0, 0.0),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Align(
                                  alignment: AlignmentDirectional(0.0, -1.0),
                                  child: FlutterFlowDropDown<String>(
                                    multiSelectController: _model
                                            .primaryInsuranceSelectValueController ??=
                                        FormListFieldController<String>(_model
                                                .primaryInsuranceSelectValue ??=
                                            List<String>.from(
                                      _model.filtersChanged
                                          ? (<String>[])
                                          : functions.returnStringList(
                                                  getJsonField(
                                                columnGQLgetByFunctionResponse
                                                    .jsonBody,
                                                r'''$.data.pep_vw_group_details[:].group_filters.primaryInsurance''',
                                                true,
                                              )) ??
                                              [],
                                    )),
                                    options: _model.primInsDropDown,
                                    width: 300.0,
                                    height: 56.0,
                                    searchHintTextStyle:
                                        FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .override(
                                              font: GoogleFonts.poppins(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium
                                                        .fontStyle,
                                              ),
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .fontStyle,
                                            ),
                                    searchTextStyle:
                                        FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.poppins(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                    textStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.poppins(
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          fontSize: 16.0,
                                          letterSpacing: 0.0,
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                    hintText: 'Select Primary Insurance',
                                    searchHintText: 'Search...',
                                    icon: Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      size: 24.0,
                                    ),
                                    fillColor:
                                        FlutterFlowTheme.of(context).accent1,
                                    elevation: 2.0,
                                    borderColor: FlutterFlowTheme.of(context)
                                        .borderColor,
                                    borderWidth: 2.0,
                                    borderRadius: 8.0,
                                    margin: EdgeInsetsDirectional.fromSTEB(
                                        16.0, 4.0, 16.0, 4.0),
                                    hidesUnderline: true,
                                    disabled:
                                        !(_model.primInsDropDown.isNotEmpty),
                                    isOverButton: true,
                                    isSearchable: true,
                                    isMultiSelect: true,
                                    onMultiSelectChanged: (val) async {
                                      safeSetState(() => _model
                                          .primaryInsuranceSelectValue = val);
                                      _model.filtersChanged = true;
                                      safeSetState(() {});
                                      safeSetState(() {
                                        _model
                                            .secondaryInsuranceSelectValueController
                                            ?.reset();
                                        _model
                                            .insuranceTypeSelectValueController
                                            ?.reset();
                                      });
                                      if (_model.primaryInsuranceSelectValue !=
                                              null &&
                                          (_model.primaryInsuranceSelectValue)!
                                              .isNotEmpty) {
                                        _model.secInsDropDown = [];
                                        _model.insTypeDropDown = [];
                                        safeSetState(() {});
                                        _model.getSecInsIV =
                                            await GQLgetByFunctionCall.call(
                                          hasuraToken: FFAppState().hasuraToken,
                                          requestBody: functions
                                              .generateSecondaryInsListRequest(
                                                  _model.clinicSelectValue!,
                                                  _model.providerSelectValue
                                                      ?.toList(),
                                                  _model.primaryDxSelectValue
                                                      ?.toList(),
                                                  _model.secondaryDxSelectValue
                                                      ?.toList(),
                                                  _model
                                                      .primaryInsuranceSelectValue
                                                      ?.toList(),
                                                  _model.facilitySelectValue
                                                      ?.toList())
                                              .toString(),
                                        );

                                        _model.getInsTypeIV =
                                            await GQLgetByFunctionCall.call(
                                          hasuraToken: FFAppState().hasuraToken,
                                          requestBody: functions
                                              .generateInsTypeListRequest(
                                                  _model.clinicSelectValue!,
                                                  _model.providerSelectValue
                                                      ?.toList(),
                                                  _model.primaryDxSelectValue
                                                      ?.toList(),
                                                  _model.secondaryDxSelectValue
                                                      ?.toList(),
                                                  _model
                                                      .primaryInsuranceSelectValue
                                                      ?.toList(),
                                                  _model
                                                      .secondaryInsuranceSelectValue
                                                      ?.toList(),
                                                  _model.facilitySelectValue
                                                      ?.toList())
                                              .toString(),
                                        );

                                        _model.secInsDropDown =
                                            GQLgetByFunctionCall
                                                    .secondaryInsList(
                                          (_model.getSecInsIV?.jsonBody ?? ''),
                                        )!
                                                .toList()
                                                .cast<String>();
                                        _model.insTypeDropDown =
                                            GQLgetByFunctionCall.insuranceType(
                                          (_model.getInsTypeIV?.jsonBody ?? ''),
                                        )!
                                                .map((e) => e.toString())
                                                .toList()
                                                .cast<String>();
                                        safeSetState(() {});
                                      }

                                      safeSetState(() {});
                                    },
                                  ),
                                ),
                                Align(
                                  alignment: AlignmentDirectional(0.0, -1.0),
                                  child: FlutterFlowDropDown<String>(
                                    multiSelectController: _model
                                            .secondaryInsuranceSelectValueController ??=
                                        FormListFieldController<String>(_model
                                                .secondaryInsuranceSelectValue ??=
                                            List<String>.from(
                                      _model.filtersChanged
                                          ? (<String>[])
                                          : functions.returnStringList(
                                                  getJsonField(
                                                columnGQLgetByFunctionResponse
                                                    .jsonBody,
                                                r'''$.data.pep_vw_group_details[:].group_filters.secondaryInsurance''',
                                                true,
                                              )) ??
                                              [],
                                    )),
                                    options: _model.secInsDropDown,
                                    width: 300.0,
                                    height: 56.0,
                                    searchHintTextStyle:
                                        FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .override(
                                              font: GoogleFonts.poppins(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium
                                                        .fontStyle,
                                              ),
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .fontStyle,
                                            ),
                                    searchTextStyle:
                                        FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.poppins(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                    textStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.poppins(
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          fontSize: 16.0,
                                          letterSpacing: 0.0,
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                    hintText: 'Select Secondary Insurance',
                                    searchHintText: 'Search...',
                                    icon: Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      size: 24.0,
                                    ),
                                    fillColor:
                                        FlutterFlowTheme.of(context).accent1,
                                    elevation: 2.0,
                                    borderColor: FlutterFlowTheme.of(context)
                                        .borderColor,
                                    borderWidth: 2.0,
                                    borderRadius: 8.0,
                                    margin: EdgeInsetsDirectional.fromSTEB(
                                        16.0, 4.0, 16.0, 4.0),
                                    hidesUnderline: true,
                                    disabled:
                                        !(_model.secInsDropDown.isNotEmpty),
                                    isOverButton: true,
                                    isSearchable: true,
                                    isMultiSelect: true,
                                    onMultiSelectChanged: (val) async {
                                      safeSetState(() => _model
                                          .secondaryInsuranceSelectValue = val);
                                      _model.filtersChanged = true;
                                      safeSetState(() {});
                                      safeSetState(() {
                                        _model
                                            .insuranceTypeSelectValueController
                                            ?.reset();
                                      });
                                      if (_model.secondaryInsuranceSelectValue !=
                                              null &&
                                          (_model.secondaryInsuranceSelectValue)!
                                              .isNotEmpty) {
                                        _model.insTypeDropDown = [];
                                        safeSetState(() {});
                                        _model.getInsTypeV =
                                            await GQLgetByFunctionCall.call(
                                          hasuraToken: FFAppState().hasuraToken,
                                          requestBody: functions
                                              .generateInsTypeListRequest(
                                                  _model.clinicSelectValue!,
                                                  _model.providerSelectValue
                                                      ?.toList(),
                                                  _model.primaryDxSelectValue
                                                      ?.toList(),
                                                  _model.secondaryDxSelectValue
                                                      ?.toList(),
                                                  _model
                                                      .primaryInsuranceSelectValue
                                                      ?.toList(),
                                                  _model
                                                      .secondaryInsuranceSelectValue
                                                      ?.toList(),
                                                  _model.facilitySelectValue
                                                      ?.toList())
                                              .toString(),
                                        );

                                        _model.insTypeDropDown =
                                            GQLgetByFunctionCall.insuranceType(
                                          (_model.getInsTypeV?.jsonBody ?? ''),
                                        )!
                                                .map((e) => e.toString())
                                                .toList()
                                                .cast<String>();
                                        safeSetState(() {});
                                      }

                                      safeSetState(() {});
                                    },
                                  ),
                                ),
                                Align(
                                  alignment: AlignmentDirectional(0.0, -1.0),
                                  child: FlutterFlowDropDown<String>(
                                    multiSelectController: _model
                                            .insuranceTypeSelectValueController ??=
                                        FormListFieldController<String>(
                                            _model.insuranceTypeSelectValue ??=
                                                List<String>.from(
                                      _model.filtersChanged
                                          ? (<String>[])
                                          : functions.returnStringList(
                                                  getJsonField(
                                                columnGQLgetByFunctionResponse
                                                    .jsonBody,
                                                r'''$.data.pep_vw_group_details[:].group_filters.insuranceTypes''',
                                                true,
                                              )) ??
                                              [],
                                    )),
                                    options: _model.insTypeDropDown,
                                    width: 300.0,
                                    height: 56.0,
                                    searchHintTextStyle:
                                        FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .override(
                                              font: GoogleFonts.poppins(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium
                                                        .fontStyle,
                                              ),
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .fontStyle,
                                            ),
                                    searchTextStyle:
                                        FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.poppins(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                    textStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.poppins(
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          fontSize: 16.0,
                                          letterSpacing: 0.0,
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                    hintText: 'Select Insurance Type',
                                    searchHintText: 'Search...',
                                    icon: Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      size: 24.0,
                                    ),
                                    fillColor:
                                        FlutterFlowTheme.of(context).accent1,
                                    elevation: 2.0,
                                    borderColor: FlutterFlowTheme.of(context)
                                        .borderColor,
                                    borderWidth: 2.0,
                                    borderRadius: 8.0,
                                    margin: EdgeInsetsDirectional.fromSTEB(
                                        16.0, 4.0, 16.0, 4.0),
                                    hidesUnderline: true,
                                    disabled:
                                        !(_model.insTypeDropDown.isNotEmpty),
                                    isOverButton: true,
                                    isSearchable: true,
                                    isMultiSelect: true,
                                    onMultiSelectChanged: (val) async {
                                      safeSetState(() => _model
                                          .insuranceTypeSelectValue = val);
                                      _model.filtersChanged = true;
                                      safeSetState(() {});
                                    },
                                  ),
                                ),
                              ].divide(SizedBox(width: 20.0)),
                            ),
                          ),
                        ),
                      if (_model.secondaryFiltersEnabled)
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 12.0, 0.0, 0.0),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  width: 620.0,
                                  height: 56.0,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                  ),
                                  child: Container(
                                    width: 620.0,
                                    child: TextFormField(
                                      controller:
                                          _model.zipcodesTextController ??=
                                              TextEditingController(
                                        text: _model.filtersChanged
                                            ? ("")
                                            : functions
                                                .returnString(getJsonField(
                                                columnGQLgetByFunctionResponse
                                                    .jsonBody,
                                                r'''$.data.pep_vw_group_details[:].group_filters.zipcodes''',
                                              )),
                                      ),
                                      focusNode: _model.zipcodesFocusNode,
                                      onFieldSubmitted: (_) async {
                                        _model.filtersChanged = true;
                                        safeSetState(() {});
                                      },
                                      autofocus: true,
                                      obscureText: false,
                                      decoration: InputDecoration(
                                        labelText:
                                            'Enter Zip Codes Separated by Commas',
                                        labelStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .override(
                                              font: GoogleFonts.poppins(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium
                                                        .fontStyle,
                                              ),
                                              fontSize: 16.0,
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .fontStyle,
                                            ),
                                        hintStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .override(
                                              font: GoogleFonts.poppins(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium
                                                        .fontStyle,
                                              ),
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .fontStyle,
                                            ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: FlutterFlowTheme.of(context)
                                                .borderColor,
                                            width: 2.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: FlutterFlowTheme.of(context)
                                                .borderColor,
                                            width: 2.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        errorBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: FlutterFlowTheme.of(context)
                                                .error,
                                            width: 2.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        focusedErrorBorder:
                                            UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: FlutterFlowTheme.of(context)
                                                .error,
                                            width: 2.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        filled: true,
                                        fillColor: FlutterFlowTheme.of(context)
                                            .accent1,
                                      ),
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.poppins(
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                            color: FlutterFlowTheme.of(context)
                                                .textColor,
                                            fontSize: 20.0,
                                            letterSpacing: 0.0,
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                      cursorColor:
                                          FlutterFlowTheme.of(context).tertiary,
                                      validator: _model
                                          .zipcodesTextControllerValidator
                                          .asValidator(context),
                                    ),
                                  ),
                                ),
                                FFButtonWidget(
                                  onPressed: () async {
                                    _model.filtersChanged = true;
                                    safeSetState(() {});
                                    // Last Seen Date
                                    final _datePickedDate =
                                        await showDatePicker(
                                      context: context,
                                      initialDate: (null ?? DateTime.now()),
                                      firstDate: DateTime(1900),
                                      lastDate: (null ?? DateTime.now()),
                                      builder: (context, child) {
                                        return wrapInMaterialDatePickerTheme(
                                          context,
                                          child!,
                                          headerBackgroundColor:
                                              FlutterFlowTheme.of(context)
                                                  .primary,
                                          headerForegroundColor:
                                              FlutterFlowTheme.of(context)
                                                  .buttonText,
                                          headerTextStyle: FlutterFlowTheme.of(
                                                  context)
                                              .headlineLarge
                                              .override(
                                                font: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .headlineLarge
                                                          .fontStyle,
                                                ),
                                                fontSize: 32.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w600,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .headlineLarge
                                                        .fontStyle,
                                              ),
                                          pickerBackgroundColor:
                                              FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          pickerForegroundColor:
                                              FlutterFlowTheme.of(context)
                                                  .primaryText,
                                          selectedDateTimeBackgroundColor:
                                              FlutterFlowTheme.of(context)
                                                  .primary,
                                          selectedDateTimeForegroundColor:
                                              FlutterFlowTheme.of(context)
                                                  .primaryText,
                                          actionButtonForegroundColor:
                                              FlutterFlowTheme.of(context)
                                                  .primaryText,
                                          iconSize: 24.0,
                                        );
                                      },
                                    );

                                    if (_datePickedDate != null) {
                                      safeSetState(() {
                                        _model.datePicked = DateTime(
                                          _datePickedDate.year,
                                          _datePickedDate.month,
                                          _datePickedDate.day,
                                        );
                                      });
                                    } else if (_model.datePicked != null) {
                                      safeSetState(() {
                                        _model.datePicked = null;
                                      });
                                    }
                                  },
                                  text: valueOrDefault<String>(
                                    functions.returnString(getJsonField(
                                              columnGQLgetByFunctionResponse
                                                  .jsonBody,
                                              r'''$.data.pep_vw_group_details[:].group_filters.lastVisitDate''',
                                            )) ==
                                            ("")
                                        ? valueOrDefault<String>(
                                            dateTimeFormat(
                                              "d MMM, y",
                                              _model.datePicked,
                                              locale:
                                                  FFLocalizations.of(context)
                                                      .languageCode,
                                            ),
                                            'Select Last Visit Date',
                                          )
                                        : (_model.filtersChanged
                                            ? valueOrDefault<String>(
                                                dateTimeFormat(
                                                  "d MMM, y",
                                                  _model.datePicked,
                                                  locale: FFLocalizations.of(
                                                          context)
                                                      .languageCode,
                                                ),
                                                'Select Last Visit Date',
                                              )
                                            : functions
                                                .returnString(getJsonField(
                                                columnGQLgetByFunctionResponse
                                                    .jsonBody,
                                                r'''$.data.pep_vw_group_details[:].group_filters.lastVisitDate''',
                                              ))),
                                    'Select Last Visit Date',
                                  ),
                                  icon: Icon(
                                    Icons.date_range,
                                    size: 24.0,
                                  ),
                                  options: FFButtonOptions(
                                    width: 300.0,
                                    height: 56.0,
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        24.0, 0.0, 24.0, 0.0),
                                    iconPadding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                    iconColor: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    color: FlutterFlowTheme.of(context).accent4,
                                    textStyle: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .override(
                                          font: GoogleFonts.poppins(
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .titleMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .titleMedium
                                                    .fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          fontSize: 16.0,
                                          letterSpacing: 0.0,
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .titleMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .titleMedium
                                                  .fontStyle,
                                        ),
                                    elevation: 1.0,
                                    borderSide: BorderSide(
                                      color: Colors.transparent,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                              ].divide(SizedBox(width: 20.0)),
                            ),
                          ),
                        ),
                      if (_model.secondaryFiltersEnabled)
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 12.0, 0.0, 0.0),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Align(
                                  alignment: AlignmentDirectional(0.0, -1.0),
                                  child: FutureBuilder<ApiCallResponse>(
                                    future: FFAppState().groupType(
                                      requestFn: () =>
                                          GQLgetByFunctionCall.call(
                                        hasuraToken: FFAppState().hasuraToken,
                                        requestBody:
                                            '{\"query\":\"query MyQuery {pep_group_type_mapping(order_by: {id: asc}) { id group_type }}\"}',
                                      ),
                                    ),
                                    builder: (context, snapshot) {
                                      // Customize what your widget looks like when it's loading.
                                      if (!snapshot.hasData) {
                                        return Center(
                                          child: SizedBox(
                                            width: 50.0,
                                            height: 50.0,
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                FlutterFlowTheme.of(context)
                                                    .primary,
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                      final groupTypeGQLgetByFunctionResponse =
                                          snapshot.data!;

                                      return FlutterFlowDropDown<String>(
                                        multiSelectController:
                                            _model.groupTypeValueController ??=
                                                FormListFieldController<String>(
                                                    _model.groupTypeValue ??=
                                                        List<String>.from(
                                          _model.filtersChanged
                                              ? (<String>[])
                                              : functions.returnStringList(
                                                      getJsonField(
                                                    columnGQLgetByFunctionResponse
                                                        .jsonBody,
                                                    r'''$.data.pep_vw_group_details[:].group_filters.groupTypes''',
                                                    true,
                                                  )) ??
                                                  [],
                                        )),
                                        options: List<String>.from(
                                            (getJsonField(
                                          groupTypeGQLgetByFunctionResponse
                                              .jsonBody,
                                          r'''$.data.pep_group_type_mapping[:].id''',
                                          true,
                                        ) as List)
                                                .map<String>(
                                                    (s) => s.toString())
                                                .toList()),
                                        optionLabels: (getJsonField(
                                          groupTypeGQLgetByFunctionResponse
                                              .jsonBody,
                                          r'''$.data.pep_group_type_mapping[:].group_type''',
                                          true,
                                        ) as List)
                                            .map<String>((s) => s.toString())
                                            .toList(),
                                        width: 300.0,
                                        height: 56.0,
                                        textStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.poppins(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              fontSize: 16.0,
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                        hintText: 'Select Group Type',
                                        icon: Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                          size: 24.0,
                                        ),
                                        fillColor: FlutterFlowTheme.of(context)
                                            .accent1,
                                        elevation: 2.0,
                                        borderColor:
                                            FlutterFlowTheme.of(context)
                                                .borderColor,
                                        borderWidth: 2.0,
                                        borderRadius: 8.0,
                                        margin: EdgeInsetsDirectional.fromSTEB(
                                            16.0, 4.0, 16.0, 4.0),
                                        hidesUnderline: true,
                                        isOverButton: true,
                                        isSearchable: false,
                                        isMultiSelect: true,
                                        onMultiSelectChanged: (val) async {
                                          safeSetState(() =>
                                              _model.groupTypeValue = val);
                                          _model.filtersChanged = true;
                                          safeSetState(() {});
                                          FFAppState().groupTypeFilter = _model
                                              .groupTypeValue!
                                              .toList()
                                              .cast<String>();
                                          safeSetState(() {});
                                        },
                                      );
                                    },
                                  ),
                                ),
                                Align(
                                  alignment: AlignmentDirectional(-1.0, 0.0),
                                  child: Text(
                                    ' ',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.poppins(
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          fontSize: 16.0,
                                          letterSpacing: 0.0,
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                  ),
                                ),
                              ].divide(SizedBox(width: 15.0)),
                            ),
                          ),
                        ),
                      if (_model.secondaryFiltersEnabled)
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 12.0, 0.0, 0.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Align(
                                alignment: AlignmentDirectional(-1.0, 0.0),
                                child: Text(
                                  'Exclude Patients with Assigned Groups',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.poppins(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        fontSize: 16.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                ),
                              ),
                              Align(
                                alignment: AlignmentDirectional(-1.0, 0.0),
                                child: Switch.adaptive(
                                  value: _model.switchValue ??=
                                      _model.filtersChanged
                                          ? true
                                          : getJsonField(
                                              columnGQLgetByFunctionResponse
                                                  .jsonBody,
                                              r'''$.data.pep_vw_group_details[:].group_filters.excludeFlag''',
                                            ),
                                  onChanged: (newValue) async {
                                    safeSetState(
                                        () => _model.switchValue = newValue);
                                    if (newValue) {
                                      _model.filtersChanged = true;
                                      safeSetState(() {});
                                      FFAppState().filteredPatientsList =
                                          functions
                                              .generateFilteredPatientsList(
                                                  FFAppState()
                                                      .filteredPatients
                                                      .toList(),
                                                  _model.switchValue!)
                                              .toList()
                                              .cast<int>();
                                      safeSetState(() {});
                                      if ((_model.groupTypeValue != null &&
                                              (_model.groupTypeValue)!
                                                  .isNotEmpty) !=
                                          false) {
                                        FFAppState().filteredPatientsList =
                                            functions
                                                .findCommonPatients(
                                                    FFAppState()
                                                        .filteredPatientsList
                                                        .toList(),
                                                    GQLgetByFunctionCall
                                                            .patientsByGroupType(
                                                      (_model.getPatientsByGroupType
                                                              ?.jsonBody ??
                                                          ''),
                                                    )!
                                                        .toList())
                                                .toList()
                                                .cast<int>();
                                        safeSetState(() {});
                                      }
                                      FFAppState().filteredPatientsList =
                                          functions
                                              .addSearchPPCIDs(
                                                  FFAppState()
                                                      .addedPPCIDs
                                                      .toList(),
                                                  FFAppState()
                                                      .filteredPatientsList
                                                      .toList())
                                              .toList()
                                              .cast<int>();
                                      safeSetState(() {});
                                      FFAppState().filteredPatientsCount =
                                          functions
                                              .generateFilteredPatientsListCount(
                                                  FFAppState()
                                                      .filteredPatientsList
                                                      .toList());
                                      safeSetState(() {});
                                    } else {
                                      FFAppState().filteredPatientsList =
                                          functions
                                              .generateFilteredPatientsList(
                                                  FFAppState()
                                                      .filteredPatients
                                                      .toList(),
                                                  _model.switchValue!)
                                              .toList()
                                              .cast<int>();
                                      safeSetState(() {});
                                      if ((_model.groupTypeValue != null &&
                                              (_model.groupTypeValue)!
                                                  .isNotEmpty) !=
                                          false) {
                                        FFAppState().filteredPatientsList =
                                            functions
                                                .findCommonPatients(
                                                    FFAppState()
                                                        .filteredPatientsList
                                                        .toList(),
                                                    GQLgetByFunctionCall
                                                            .patientsByGroupType(
                                                      (_model.getPatientsByGroupType
                                                              ?.jsonBody ??
                                                          ''),
                                                    )!
                                                        .toList())
                                                .toList()
                                                .cast<int>();
                                        safeSetState(() {});
                                      }
                                      FFAppState().filteredPatientsList =
                                          functions
                                              .addSearchPPCIDs(
                                                  FFAppState()
                                                      .addedPPCIDs
                                                      .toList(),
                                                  FFAppState()
                                                      .filteredPatientsList
                                                      .toList())
                                              .toList()
                                              .cast<int>();
                                      safeSetState(() {});
                                      FFAppState().filteredPatientsCount =
                                          functions
                                              .generateFilteredPatientsListCount(
                                                  FFAppState()
                                                      .filteredPatientsList
                                                      .toList());
                                      safeSetState(() {});
                                    }
                                  },
                                  activeColor:
                                      FlutterFlowTheme.of(context).tertiary,
                                  inactiveTrackColor:
                                      FlutterFlowTheme.of(context).accent4,
                                  inactiveThumbColor:
                                      FlutterFlowTheme.of(context).buttonText,
                                ),
                              ),
                            ].divide(SizedBox(width: 15.0)),
                          ),
                        ),
                      if (_model.secondaryFiltersEnabled)
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 12.0, 0.0, 0.0),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                FFButtonWidget(
                                  onPressed: () async {
                                    _model.filtersChanged = true;
                                    _model.newFiltersApplied = true;
                                    safeSetState(() {});
                                    if (_model.clinicSelectValue != null) {
                                      _model.applyResponse =
                                          await GQLgetByFunctionCall.call(
                                        hasuraToken: FFAppState().hasuraToken,
                                        requestBody: functions
                                            .generateFilteredPatients(
                                                _model.clinicSelectValue!,
                                                _model.providerSelectValue
                                                    ?.toList(),
                                                _model.primaryDxSelectValue
                                                    ?.toList(),
                                                _model.secondaryDxSelectValue
                                                    ?.toList(),
                                                _model
                                                    .programEligibilitySelectValue
                                                    ?.toList(),
                                                _model
                                                    .primaryInsuranceSelectValue
                                                    ?.toList(),
                                                _model
                                                    .secondaryInsuranceSelectValue
                                                    ?.toList(),
                                                _model.facilitySelectValue
                                                    ?.toList(),
                                                _model.insuranceTypeSelectValue
                                                    ?.toList(),
                                                _model.zipcodesTextController
                                                    .text,
                                                _model.datePicked)
                                            .toString(),
                                      );

                                      if ((_model.applyResponse?.succeeded ??
                                          true)) {
                                        _model.filtersChanged = true;
                                        safeSetState(() {});
                                        FFAppState().filteredPatients =
                                            GQLgetByFunctionCall
                                                    .consolidatedData(
                                          (_model.applyResponse?.jsonBody ??
                                              ''),
                                        )!
                                                .toList()
                                                .cast<dynamic>();
                                        safeSetState(() {});
                                        FFAppState().filteredPatientsList =
                                            functions
                                                .generateFilteredPatientsList(
                                                    FFAppState()
                                                        .filteredPatients
                                                        .toList(),
                                                    false)
                                                .toList()
                                                .cast<int>();
                                        safeSetState(() {});
                                        if ((_model.groupTypeValue != null &&
                                                (_model.groupTypeValue)!
                                                    .isNotEmpty) !=
                                            false) {
                                          _model.getPatientsByGroupType =
                                              await GQLgetByFunctionCall.call(
                                            hasuraToken:
                                                FFAppState().hasuraToken,
                                            requestBody: functions
                                                .getPatientsByGroupType(
                                                    _model.clinicSelectValue!,
                                                    FFAppState()
                                                        .groupTypeFilter
                                                        .toList())
                                                .toString(),
                                          );

                                          FFAppState().filteredPatientsList =
                                              functions
                                                  .findCommonPatients(
                                                      FFAppState()
                                                          .filteredPatientsList
                                                          .toList(),
                                                      GQLgetByFunctionCall
                                                              .patientsByGroupType(
                                                        (_model.getPatientsByGroupType
                                                                ?.jsonBody ??
                                                            ''),
                                                      )!
                                                          .toList())
                                                  .toList()
                                                  .cast<int>();
                                          safeSetState(() {});
                                        }
                                        FFAppState().filteredPatientsCount =
                                            functions
                                                .generateFilteredPatientsListCount(
                                                    FFAppState()
                                                        .filteredPatientsList
                                                        .toList());
                                        safeSetState(() {});
                                        _model.groupFiltersUsed = functions
                                            .groupFiltersUsed(
                                                functions.getClinicName(
                                                    GQLgetClinicNamesCall
                                                            .clinicDetailsMap(
                                                      (_model.getClinics
                                                              ?.jsonBody ??
                                                          ''),
                                                    )!
                                                        .toList(),
                                                    _model.clinicSelectValue!),
                                                functions
                                                    .getFacilityNames(
                                                        getJsonField(
                                                          _model.facilityData,
                                                          r'''$.data.pep_vw_consolidated_data''',
                                                          true,
                                                        )!,
                                                        _model
                                                            .facilitySelectValue
                                                            ?.toList())
                                                    .toList(),
                                                functions
                                                    .getProviderNames(
                                                        getJsonField(
                                                          _model.providerData,
                                                          r'''$.data.pep_vw_consolidated_data''',
                                                          true,
                                                        )!,
                                                        _model
                                                            .providerSelectValue
                                                            ?.toList())
                                                    .toList(),
                                                _model.primaryDxSelectValue
                                                    ?.toList(),
                                                _model
                                                    .secondaryDxSelectValue
                                                    ?.toList(),
                                                _model
                                                    .programEligibilitySelectValue
                                                    ?.toList(),
                                                _model
                                                    .primaryInsuranceSelectValue
                                                    ?.toList(),
                                                _model
                                                    .secondaryInsuranceSelectValue
                                                    ?.toList(),
                                                _model
                                                    .insuranceTypeSelectValue
                                                    ?.toList(),
                                                _model.groupTypeValue?.toList(),
                                                _model.zipcodesTextController
                                                    .text,
                                                _model.datePicked,
                                                _model.switchValue!,
                                                _model.clinicSelectValue!,
                                                _model.facilitySelectValue
                                                    ?.toList(),
                                                _model.providerSelectValue
                                                    ?.toList());
                                        safeSetState(() {});
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Select a Clinic',
                                            style: TextStyle(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                            ),
                                          ),
                                          duration:
                                              Duration(milliseconds: 4000),
                                          backgroundColor:
                                              FlutterFlowTheme.of(context)
                                                  .error,
                                        ),
                                      );
                                    }

                                    safeSetState(() {});
                                  },
                                  text: 'Apply',
                                  options: FFButtonOptions(
                                    width: 120.0,
                                    height: 50.0,
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        24.0, 0.0, 24.0, 0.0),
                                    iconPadding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                    color:
                                        FlutterFlowTheme.of(context).tertiary,
                                    textStyle: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .override(
                                          font: GoogleFonts.poppins(
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .titleMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .titleMedium
                                                    .fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context)
                                              .buttonText,
                                          letterSpacing: 0.0,
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .titleMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .titleMedium
                                                  .fontStyle,
                                        ),
                                    elevation: 3.0,
                                    borderSide: BorderSide(
                                      color: Colors.transparent,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Align(
                                      alignment: AlignmentDirectional(0.0, 0.0),
                                      child: Text(
                                        'Number of Patients Found: ',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.poppins(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              fontSize: 20.0,
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          8.0, 0.0, 0.0, 0.0),
                                      child: Text(
                                        FFAppState()
                                            .filteredPatientsCount
                                            .toString(),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.poppins(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              fontSize: 20.0,
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ].divide(SizedBox(width: 20.0)),
                            ),
                          ),
                        ),
                      if (_model.secondaryFiltersEnabled)
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 12.0, 0.0, 0.0),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  width: 940.0,
                                  child: Autocomplete<String>(
                                    initialValue: TextEditingValue(),
                                    optionsBuilder: (textEditingValue) {
                                      if (textEditingValue.text == '') {
                                        return const Iterable<String>.empty();
                                      }
                                      return (getJsonField(
                                        (_model.autofillValues?.jsonBody ?? ''),
                                        r'''$.data.pep_vw_consolidated_data[:].search_string''',
                                        true,
                                      ) as List)
                                          .map<String>((s) => s.toString())
                                          .toList()
                                          .where((option) {
                                        final lowercaseOption =
                                            option.toLowerCase();
                                        return lowercaseOption.contains(
                                            textEditingValue.text
                                                .toLowerCase());
                                      });
                                    },
                                    optionsViewBuilder:
                                        (context, onSelected, options) {
                                      return AutocompleteOptionsList(
                                        textFieldKey: _model.patientSearchKey,
                                        textController:
                                            _model.patientSearchTextController!,
                                        options: options.toList(),
                                        onSelected: onSelected,
                                        textStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.poppins(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                        textHighlightStyle: TextStyle(),
                                        elevation: 4.0,
                                        optionBackgroundColor:
                                            FlutterFlowTheme.of(context)
                                                .primaryBackground,
                                        optionHighlightColor:
                                            FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                        maxHeight: 200.0,
                                      );
                                    },
                                    onSelected: (String selection) {
                                      safeSetState(() =>
                                          _model.patientSearchSelectedOption =
                                              selection);
                                      FocusScope.of(context).unfocus();
                                    },
                                    fieldViewBuilder: (
                                      context,
                                      textEditingController,
                                      focusNode,
                                      onEditingComplete,
                                    ) {
                                      _model.patientSearchFocusNode = focusNode;

                                      _model.patientSearchTextController =
                                          textEditingController;
                                      return TextFormField(
                                        key: _model.patientSearchKey,
                                        controller: textEditingController,
                                        focusNode: focusNode,
                                        onEditingComplete: onEditingComplete,
                                        autofocus: true,
                                        obscureText: false,
                                        decoration: InputDecoration(
                                          labelText:
                                              'Search Patient by Name, EMR, DOB, Mobile/Home Number',
                                          labelStyle: FlutterFlowTheme.of(
                                                  context)
                                              .labelMedium
                                              .override(
                                                font: GoogleFonts.poppins(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelMedium
                                                          .fontStyle,
                                                ),
                                                fontSize: 16.0,
                                                letterSpacing: 0.0,
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium
                                                        .fontStyle,
                                              ),
                                          hintStyle: FlutterFlowTheme.of(
                                                  context)
                                              .labelMedium
                                              .override(
                                                font: GoogleFonts.poppins(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelMedium
                                                          .fontStyle,
                                                ),
                                                letterSpacing: 0.0,
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium
                                                        .fontStyle,
                                              ),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .borderColor,
                                              width: 2.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .borderColor,
                                              width: 2.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          errorBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .error,
                                              width: 2.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          focusedErrorBorder:
                                              UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .error,
                                              width: 2.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          filled: true,
                                          fillColor:
                                              FlutterFlowTheme.of(context)
                                                  .accent1,
                                        ),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.poppins(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .textColor,
                                              fontSize: 20.0,
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                        cursorColor:
                                            FlutterFlowTheme.of(context)
                                                .tertiary,
                                        validator: _model
                                            .patientSearchTextControllerValidator
                                            .asValidator(context),
                                      );
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      20.0, 0.0, 0.0, 0.0),
                                  child: FFButtonWidget(
                                    onPressed: () async {
                                      _model.pcdID =
                                          await GQLgetByFunctionCall.call(
                                        hasuraToken: FFAppState().hasuraToken,
                                        requestBody: functions
                                            .autofillSearchPPCID(
                                                _model.clinicSelectValue!,
                                                _model
                                                    .patientSearchTextController
                                                    .text)
                                            .toString(),
                                      );

                                      if (getJsonField(
                                            (_model.pcdID?.jsonBody ?? ''),
                                            r'''$.data.pep_vw_consolidated_data[:].patient_clinic_data_id''',
                                          ) !=
                                          getJsonField(
                                            FFAppState().searchNotFound,
                                            r'''$.data.pep_vw_consolidated_data[:].patient_clinic_data_id''',
                                          )) {
                                        FFAppState()
                                            .addToAddedPPCIDs(getJsonField(
                                          (_model.pcdID?.jsonBody ?? ''),
                                          r'''$.data.pep_vw_consolidated_data[:].patient_clinic_data_id''',
                                        ));
                                        safeSetState(() {});
                                        FFAppState().filteredPatientsList =
                                            functions
                                                .addSearchPPCIDs(
                                                    FFAppState()
                                                        .addedPPCIDs
                                                        .toList(),
                                                    FFAppState()
                                                        .filteredPatientsList
                                                        .toList())
                                                .toList()
                                                .cast<int>();
                                        safeSetState(() {});
                                        FFAppState().filteredPatientsCount =
                                            functions
                                                .generateFilteredPatientsListCount(
                                                    FFAppState()
                                                        .filteredPatientsList
                                                        .toList());
                                        safeSetState(() {});
                                        await showDialog(
                                          context: context,
                                          builder: (alertDialogContext) {
                                            return AlertDialog(
                                              title: Text('Add Patient'),
                                              content: Text('Successful'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          alertDialogContext),
                                                  child: Text('Ok'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                        safeSetState(() {
                                          _model.patientSearchTextController
                                              ?.clear();
                                        });
                                      } else {
                                        await showDialog(
                                          context: context,
                                          builder: (alertDialogContext) {
                                            return AlertDialog(
                                              title: Text('Add Patient'),
                                              content:
                                                  Text('Patient not Found'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          alertDialogContext),
                                                  child: Text('Ok'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                        safeSetState(() {
                                          _model.patientSearchTextController
                                              ?.clear();
                                        });
                                      }

                                      safeSetState(() {});
                                    },
                                    text: 'ADD',
                                    options: FFButtonOptions(
                                      height: 56.0,
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          24.0, 0.0, 24.0, 0.0),
                                      iconPadding:
                                          EdgeInsetsDirectional.fromSTEB(
                                              0.0, 0.0, 0.0, 0.0),
                                      color:
                                          FlutterFlowTheme.of(context).tertiary,
                                      textStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .override(
                                            font: GoogleFonts.poppins(
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmall
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmall
                                                      .fontStyle,
                                            ),
                                            color: FlutterFlowTheme.of(context)
                                                .buttonText,
                                            letterSpacing: 0.0,
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .titleSmall
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .titleSmall
                                                    .fontStyle,
                                          ),
                                      elevation: 3.0,
                                      borderSide: BorderSide(
                                        color: Colors.transparent,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                width: 460.0,
                                child: TextFormField(
                                  controller:
                                      _model.numberOfPatientsTextController,
                                  focusNode: _model.numberOfPatientsFocusNode,
                                  onChanged: (_) => EasyDebounce.debounce(
                                    '_model.numberOfPatientsTextController',
                                    Duration(milliseconds: 100),
                                    () => safeSetState(() {}),
                                  ),
                                  autofocus: true,
                                  textInputAction: TextInputAction.done,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    labelText:
                                        'Enter Number of Patients To Be Assigned*',
                                    labelStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .override(
                                          font: GoogleFonts.poppins(
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .labelMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .labelMedium
                                                    .fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                          fontSize: 16.0,
                                          letterSpacing: 0.0,
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontStyle,
                                        ),
                                    hintText: '500',
                                    hintStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .override(
                                          font: GoogleFonts.poppins(
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .labelMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .labelMedium
                                                    .fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                          fontSize: 16.0,
                                          letterSpacing: 0.0,
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontStyle,
                                        ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: FlutterFlowTheme.of(context)
                                            .borderColor,
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: FlutterFlowTheme.of(context)
                                            .borderColor,
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    errorBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            FlutterFlowTheme.of(context).error,
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    focusedErrorBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            FlutterFlowTheme.of(context).error,
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    filled: true,
                                    fillColor:
                                        FlutterFlowTheme.of(context).accent1,
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .override(
                                        font: GoogleFonts.poppins(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .textColor,
                                        fontSize: 18.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontStyle,
                                        lineHeight: 1.8,
                                      ),
                                  keyboardType: TextInputType.number,
                                  cursorColor:
                                      FlutterFlowTheme.of(context).tertiary,
                                  validator: _model
                                      .numberOfPatientsTextControllerValidator
                                      .asValidator(context),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp('[0-9]'))
                                  ],
                                ),
                              ),
                            ].divide(SizedBox(width: 20.0)),
                          ),
                        ),
                      ),
                      if (_model.filtersChanged && !_model.newFiltersApplied)
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 12.0, 0.0, 0.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Align(
                                alignment: AlignmentDirectional(-1.0, 0.0),
                                child: Text(
                                  'Apply the latest filters before creating the group',
                                  style: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .override(
                                        font: GoogleFonts.poppins(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontStyle,
                                        ),
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontStyle,
                                      ),
                                ),
                              ),
                            ].divide(SizedBox(width: 15.0)),
                          ),
                        ),
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              if (_model.filtersChanged)
                                FFButtonWidget(
                                  onPressed: !((_model.txtfldEnterGroupNameTextController
                                                      .text !=
                                                  '') &&
                                          (_model.selectTypeValue != null &&
                                              _model.selectTypeValue != '') &&
                                          (_model.clinicSelectValue != null) &&
                                          (_model.numberOfPatientsTextController
                                                      .text !=
                                                  '') &&
                                          _model.newFiltersApplied)
                                      ? null
                                      : () async {
                                          _model.createGroup =
                                              await PEPAPIsGroup.createGroupCall
                                                  .call(
                                            name: _model
                                                .txtfldEnterGroupNameTextController
                                                .text,
                                            enrollmentSpecialistIdList: _model
                                                .enrollmentSpecialistSelectValue,
                                            type: int.parse(
                                                (_model.selectTypeValue!)),
                                            status: 2,
                                            clinicId: _model.clinicSelectValue,
                                            patientIdsList:
                                                functions.subsetPatients(
                                                    FFAppState()
                                                        .filteredPatientsCount,
                                                    int.parse(_model
                                                        .numberOfPatientsTextController
                                                        .text),
                                                    FFAppState()
                                                        .filteredPatientsList
                                                        .toList()),
                                            authToken: FFAppState().loginToken,
                                            enrollmentAdminId:
                                                FFAppState().loginProfileID,
                                            groupFiltersJson:
                                                _model.groupFiltersUsed,
                                          );

                                          if ((_model.createGroup?.succeeded ??
                                              true)) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  ' Created Group Successfully.',
                                                  style: TextStyle(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .buttonText,
                                                  ),
                                                ),
                                                duration: Duration(
                                                    milliseconds: 4000),
                                                backgroundColor:
                                                    FlutterFlowTheme.of(context)
                                                        .tertiary,
                                              ),
                                            );
                                            await Future.delayed(const Duration(
                                                milliseconds: 1000));

                                            context.goNamed(
                                              ReloadPageWidget.routeName,
                                              queryParameters: {
                                                'groupListReload':
                                                    serializeParam(
                                                  true,
                                                  ParamType.bool,
                                                ),
                                              }.withoutNulls,
                                              extra: <String, dynamic>{
                                                kTransitionInfoKey:
                                                    TransitionInfo(
                                                  hasTransition: true,
                                                  transitionType:
                                                      PageTransitionType.fade,
                                                  duration: Duration(
                                                      milliseconds: 400),
                                                ),
                                              },
                                            );

                                            FFAppState().filteredPatients = [];
                                            FFAppState().filteredPatientsList =
                                                [];
                                            FFAppState().filteredPatientsCount =
                                                0;
                                            safeSetState(() {});
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Problem with creating the Group. Please try again!',
                                                  style: TextStyle(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .buttonText,
                                                  ),
                                                ),
                                                duration: Duration(
                                                    milliseconds: 4000),
                                                backgroundColor:
                                                    FlutterFlowTheme.of(context)
                                                        .error,
                                              ),
                                            );
                                          }

                                          safeSetState(() {});
                                        },
                                  text: 'Create Group',
                                  options: FFButtonOptions(
                                    width: 300.0,
                                    height: 50.0,
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        24.0, 0.0, 24.0, 0.0),
                                    iconPadding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                    color:
                                        FlutterFlowTheme.of(context).tertiary,
                                    textStyle: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .override(
                                          font: GoogleFonts.poppins(
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .titleMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .titleMedium
                                                    .fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context)
                                              .buttonText,
                                          letterSpacing: 0.0,
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .titleMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .titleMedium
                                                  .fontStyle,
                                        ),
                                    elevation: 3.0,
                                    borderSide: BorderSide(
                                      color: Colors.transparent,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                    disabledColor:
                                        FlutterFlowTheme.of(context).accent4,
                                    disabledTextColor:
                                        FlutterFlowTheme.of(context).buttonText,
                                  ),
                                ),
                              if (!_model.filtersChanged)
                                FFButtonWidget(
                                  onPressed:
                                      !((_model.txtfldEnterGroupNameTextController
                                                          .text !=
                                                      '') &&
                                              (_model.selectTypeValue != null &&
                                                  _model.selectTypeValue !=
                                                      '') &&
                                              (_model.clinicSelectValue !=
                                                  null))
                                          ? null
                                          : () async {
                                              _model.duplicateGroup =
                                                  await PEPAPIsGroup
                                                      .createGroupCall
                                                      .call(
                                                name: _model
                                                    .txtfldEnterGroupNameTextController
                                                    .text,
                                                enrollmentSpecialistIdList: _model
                                                    .enrollmentSpecialistSelectValue,
                                                type: int.parse(
                                                    (_model.selectTypeValue!)),
                                                status: 2,
                                                clinicId:
                                                    _model.clinicSelectValue,
                                                patientIdsList: FFAppState()
                                                    .filteredPatientsList,
                                                authToken:
                                                    FFAppState().loginToken,
                                                enrollmentAdminId:
                                                    FFAppState().loginProfileID,
                                                groupFiltersJson:
                                                    _model.groupFiltersUsed,
                                              );

                                              if ((_model.duplicateGroup
                                                      ?.succeeded ??
                                                  true)) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      ' Duplicate Group Created Successfully.',
                                                      style: TextStyle(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .buttonText,
                                                      ),
                                                    ),
                                                    duration: Duration(
                                                        milliseconds: 4000),
                                                    backgroundColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .tertiary,
                                                  ),
                                                );
                                                await Future.delayed(
                                                    const Duration(
                                                        milliseconds: 1000));

                                                context.goNamed(
                                                  ReloadPageWidget.routeName,
                                                  queryParameters: {
                                                    'groupListReload':
                                                        serializeParam(
                                                      true,
                                                      ParamType.bool,
                                                    ),
                                                  }.withoutNulls,
                                                  extra: <String, dynamic>{
                                                    kTransitionInfoKey:
                                                        TransitionInfo(
                                                      hasTransition: true,
                                                      transitionType:
                                                          PageTransitionType
                                                              .fade,
                                                      duration: Duration(
                                                          milliseconds: 400),
                                                    ),
                                                  },
                                                );

                                                FFAppState().filteredPatients =
                                                    [];
                                                FFAppState()
                                                    .filteredPatientsList = [];
                                                FFAppState()
                                                    .filteredPatientsCount = 0;
                                                safeSetState(() {});
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Problem with duplicating the Group. Please try again!',
                                                      style: TextStyle(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .buttonText,
                                                      ),
                                                    ),
                                                    duration: Duration(
                                                        milliseconds: 4000),
                                                    backgroundColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .error,
                                                  ),
                                                );
                                              }

                                              safeSetState(() {});
                                            },
                                  text: 'Duplicate Group',
                                  options: FFButtonOptions(
                                    width: 300.0,
                                    height: 50.0,
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        24.0, 0.0, 24.0, 0.0),
                                    iconPadding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                    color:
                                        FlutterFlowTheme.of(context).tertiary,
                                    textStyle: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .override(
                                          font: GoogleFonts.poppins(
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .titleMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .titleMedium
                                                    .fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context)
                                              .buttonText,
                                          letterSpacing: 0.0,
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .titleMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .titleMedium
                                                  .fontStyle,
                                        ),
                                    elevation: 3.0,
                                    borderSide: BorderSide(
                                      color: Colors.transparent,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                    disabledColor:
                                        FlutterFlowTheme.of(context).accent4,
                                    disabledTextColor:
                                        FlutterFlowTheme.of(context).buttonText,
                                  ),
                                ),
                              FFButtonWidget(
                                onPressed: () async {
                                  safeSetState(() {
                                    _model.txtfldEnterGroupNameTextController
                                        ?.clear();
                                    _model.patientSearchTextController?.clear();
                                    _model.numberOfPatientsTextController
                                        ?.clear();
                                    _model.zipcodesTextController?.clear();
                                  });
                                  safeSetState(() {
                                    _model
                                        .enrollmentSpecialistSelectValueController
                                        ?.reset();
                                    _model.selectTypeValueController?.reset();
                                    _model.clinicSelectValueController?.reset();
                                    _model.providerSelectValueController
                                        ?.reset();
                                    _model.primaryDxSelectValueController
                                        ?.reset();
                                    _model.secondaryDxSelectValueController
                                        ?.reset();
                                    _model
                                        .programEligibilitySelectValueController
                                        ?.reset();
                                    _model.primaryInsuranceSelectValueController
                                        ?.reset();
                                    _model
                                        .secondaryInsuranceSelectValueController
                                        ?.reset();
                                    _model.insuranceTypeSelectValueController
                                        ?.reset();
                                    _model.groupTypeValueController?.reset();
                                    _model.facilitySelectValueController
                                        ?.reset();
                                  });

                                  context.goNamed(
                                    ViewGroupsWidget.routeName,
                                    extra: <String, dynamic>{
                                      kTransitionInfoKey: TransitionInfo(
                                        hasTransition: true,
                                        transitionType: PageTransitionType.fade,
                                        duration: Duration(milliseconds: 400),
                                      ),
                                    },
                                  );

                                  FFAppState().filteredPatients = [];
                                  FFAppState().filteredPatientsList = [];
                                  FFAppState().filteredPatientsCount = 0;
                                  safeSetState(() {});
                                },
                                text: 'Cancel',
                                options: FFButtonOptions(
                                  width: 200.0,
                                  height: 50.0,
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      24.0, 0.0, 24.0, 0.0),
                                  iconPadding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 0.0),
                                  color: FlutterFlowTheme.of(context).accent3,
                                  textStyle: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .override(
                                        font: GoogleFonts.poppins(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .titleMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .titleMedium
                                                  .fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .buttonText,
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .titleMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .titleMedium
                                            .fontStyle,
                                      ),
                                  elevation: 3.0,
                                  borderSide: BorderSide(
                                    color: Colors.transparent,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            ].divide(SizedBox(width: 20.0)),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
