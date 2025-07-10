import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_data_table.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/main/admin/manage_p_e_s/clinic_time_slots_adder/clinic_time_slots_adder_widget.dart';
import '/main/admin/manage_p_e_s/clinic_time_slots_filter/clinic_time_slots_filter_widget.dart';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'manage_clinic_time_slots_model.dart';
export 'manage_clinic_time_slots_model.dart';

class ManageClinicTimeSlotsWidget extends StatefulWidget {
  const ManageClinicTimeSlotsWidget({super.key});

  static String routeName = 'ManageClinicTimeSlots';
  static String routePath = 'ManageClinicTime';

  @override
  State<ManageClinicTimeSlotsWidget> createState() =>
      _ManageClinicTimeSlotsWidgetState();
}

class _ManageClinicTimeSlotsWidgetState
    extends State<ManageClinicTimeSlotsWidget> {
  late ManageClinicTimeSlotsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ManageClinicTimeSlotsModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.clinicData = null;
      _model.facilityData = null;
      _model.appointmentData = [];
      _model.appointmentFiltredData = [];
      _model.dateSearch = null;
      _model.pageLoadComplete = false;
      safeSetState(() {});
      _model.getAppointments = await GQLgetByFunctionCall.call(
        hasuraToken: FFAppState().hasuraToken,
        requestBody: functions.generateClinicAppointmentsList(null).toString(),
      );

      _model.appointmentData = getJsonField(
        (_model.getAppointments?.jsonBody ?? ''),
        r'''$.data.pep_vw2_clinic_appointments''',
        true,
      )!
          .toList()
          .cast<dynamic>();
      safeSetState(() {});
      _model.getClinics = await GQLgetClinicNamesCall.call(
        hasuraToken: FFAppState().hasuraToken,
      );

      _model.clinicData = (_model.getClinics?.jsonBody ?? '');
      safeSetState(() {});
      _model.pageLoadComplete = true;
      safeSetState(() {});
    });

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
        floatingActionButton: Builder(
          builder: (context) => Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 48.0, 48.0),
            child: FloatingActionButton(
              onPressed: () async {
                // addCOM
                await showDialog(
                  barrierColor: Color(0xBF14181B),
                  context: context,
                  builder: (dialogContext) {
                    return Dialog(
                      elevation: 0,
                      insetPadding: EdgeInsets.zero,
                      backgroundColor: Colors.transparent,
                      alignment: AlignmentDirectional(0.0, 0.0)
                          .resolve(Directionality.of(context)),
                      child: GestureDetector(
                        onTap: () {
                          FocusScope.of(dialogContext).unfocus();
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        child: Container(
                          height: 500.0,
                          width: 620.0,
                          child: ClinicTimeSlotsAdderWidget(),
                        ),
                      ),
                    );
                  },
                );
              },
              backgroundColor: FlutterFlowTheme.of(context).tertiary,
              elevation: 5.0,
              child: Icon(
                Icons.add,
                color: FlutterFlowTheme.of(context).buttonText,
                size: 24.0,
              ),
            ),
          ),
        ),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(80.0),
          child: AppBar(
            backgroundColor: FlutterFlowTheme.of(context).primary,
            automaticallyImplyLeading: false,
            title: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.asset(
                        'assets/images/primary_logo.png',
                        width: 180.0,
                        height: 70.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional(0.0, 0.0),
                      child: Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                        child: Text(
                          'Patient Enrollment Specialist (PES) - Manage Time Slots',
                          textAlign: TextAlign.center,
                          style: FlutterFlowTheme.of(context)
                              .headlineSmall
                              .override(
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
                  ],
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

                        context.goNamed(LoginWidget.routeName);

                        await actions.clearCacheAndReloadHbox();
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
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 0.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        FlutterFlowIconButton(
                          borderColor: Colors.transparent,
                          borderRadius: 8.0,
                          buttonSize: 40.0,
                          fillColor: FlutterFlowTheme.of(context).primary,
                          icon: Icon(
                            Icons.arrow_back,
                            color: FlutterFlowTheme.of(context).info,
                            size: 24.0,
                          ),
                          onPressed: () async {
                            context.goNamed(
                              ViewPESWidget.routeName,
                              extra: <String, dynamic>{
                                kTransitionInfoKey: TransitionInfo(
                                  hasTransition: true,
                                  transitionType: PageTransitionType.fade,
                                  duration: Duration(milliseconds: 400),
                                ),
                              },
                            );
                          },
                        ),
                        if (_model.clinicData != null)
                          FlutterFlowDropDown<int>(
                            controller: _model.clinicSelectValueController ??=
                                FormFieldController<int>(
                              _model.clinicSelectValue ??= null,
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
                              _model.appointmentData = [];
                              _model.appointmentFiltredData = [];
                              _model.facilityData = null;
                              _model.pageLoadComplete = false;
                              safeSetState(() {});
                              _model.getClinicAppointment =
                                  await GQLgetByFunctionCall.call(
                                hasuraToken: FFAppState().hasuraToken,
                                requestBody: functions
                                    .generateClinicAppointmentsList(
                                        _model.clinicSelectValue)
                                    .toString(),
                              );

                              if ((_model.getClinicAppointment?.jsonBody ??
                                      '') !=
                                  FFAppState()
                                      .ClinicAppointmentsEmptyResponse) {
                                _model.appointmentData = getJsonField(
                                  (_model.getClinicAppointment?.jsonBody ?? ''),
                                  r'''$.data.pep_vw2_clinic_appointments''',
                                  true,
                                )!
                                    .toList()
                                    .cast<dynamic>();
                                safeSetState(() {});
                              }
                              _model.getFacility =
                                  await GQLgetByFunctionCall.call(
                                hasuraToken: FFAppState().hasuraToken,
                                requestBody: functions
                                    .generateClinicAppointmentsFacility(
                                        _model.clinicSelectValue!)
                                    .toString(),
                              );

                              if ((_model.getFacility?.jsonBody ?? '') !=
                                  FFAppState()
                                      .ClinicAppointmentsEmptyResponse) {
                                _model.facilityData =
                                    (_model.getFacility?.jsonBody ?? '');
                                safeSetState(() {});
                              }
                              _model.pageLoadComplete = true;
                              safeSetState(() {});

                              safeSetState(() {});
                            },
                            width: 230.8,
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
                            hintText: 'Select Clinic',
                            searchHintText: 'Search...',
                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: FlutterFlowTheme.of(context).secondaryText,
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
                            isMultiSelect: false,
                          ),
                        if ((_model.facilityData != null) &&
                            (_model.appointmentData.isNotEmpty))
                          FlutterFlowDropDown<String>(
                            multiSelectController:
                                _model.facilitySelectValueController ??=
                                    FormListFieldController<String>(null),
                            options: (getJsonField(
                              _model.facilityData,
                              r'''$.data.pep_vw2_clinic_appointments[:].facility_name''',
                              true,
                            ) as List)
                                .map<String>((s) => s.toString())
                                .toList(),
                            width: 219.65,
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
                            hintText: 'Select Facility',
                            searchHintText: 'Search...',
                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: FlutterFlowTheme.of(context).secondaryText,
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
                            onMultiSelectChanged: (val) async {
                              safeSetState(
                                  () => _model.facilitySelectValue = val);
                              _model.appointmentFiltredData = functions
                                  .filterAppointmentListLocally(
                                      _model.appointmentData.toList(),
                                      _model.facilitySelectValue?.toList(),
                                      _model.dateSearch != null
                                          ? functions
                                              .returnDate(_model.dateSearch!)
                                          : null)!
                                  .toList()
                                  .cast<dynamic>();
                              safeSetState(() {});
                            },
                          ),
                        if (_model.facilityData != null)
                          Builder(
                            builder: (context) => FFButtonWidget(
                              onPressed: () async {
                                await showDialog(
                                  context: context,
                                  builder: (dialogContext) {
                                    return Dialog(
                                      elevation: 0,
                                      insetPadding: EdgeInsets.zero,
                                      backgroundColor: Colors.transparent,
                                      alignment: AlignmentDirectional(0.0, 0.0)
                                          .resolve(Directionality.of(context)),
                                      child: GestureDetector(
                                        onTap: () {
                                          FocusScope.of(dialogContext)
                                              .unfocus();
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();
                                        },
                                        child: Container(
                                          height: 500.0,
                                          width: 620.0,
                                          child: ClinicTimeSlotsFilterWidget(),
                                        ),
                                      ),
                                    );
                                  },
                                ).then((value) => safeSetState(
                                    () => _model.filterData = value));

                                if (_model.filterData != null) {
                                  _model.appointmentFiltredData = functions
                                      .filterAppointmentListUsingRangeLocally(
                                          _model.appointmentData.toList(),
                                          _model.facilitySelectValue?.toList(),
                                          _model.filterData!)!
                                      .toList()
                                      .cast<dynamic>();
                                  _model.isFilterApplied = true;
                                  safeSetState(() {});
                                } else {
                                  safeSetState(() {});
                                }

                                safeSetState(() {});
                              },
                              text: 'Filter Time Slots',
                              options: FFButtonOptions(
                                width: 200.0,
                                height: 56.0,
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    16.0, 0.0, 16.0, 0.0),
                                iconPadding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 0.0),
                                color: FlutterFlowTheme.of(context).secondary,
                                textStyle: FlutterFlowTheme.of(context)
                                    .titleMedium
                                    .override(
                                      font: GoogleFonts.poppins(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .titleMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .titleMedium
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .textColor,
                                      fontSize: 14.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .titleMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleMedium
                                          .fontStyle,
                                    ),
                                elevation: 0.0,
                                borderSide: BorderSide(
                                  color:
                                      FlutterFlowTheme.of(context).borderColor,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                        if (_model.pageLoadComplete)
                          FlutterFlowIconButton(
                            borderColor: Colors.transparent,
                            borderRadius: 20.0,
                            borderWidth: 1.0,
                            buttonSize: 40.0,
                            fillColor: FlutterFlowTheme.of(context).tertiary,
                            icon: Icon(
                              Icons.refresh_sharp,
                              color: FlutterFlowTheme.of(context).buttonText,
                              size: 24.0,
                            ),
                            onPressed: () async {
                              _model.appointmentData = [];
                              _model.appointmentFiltredData = [];
                              _model.dateSearch = null;
                              _model.pageLoadComplete = false;
                              safeSetState(() {});
                              if (_model.facilitySelectValue != null &&
                                  (_model.facilitySelectValue)!.isNotEmpty) {
                                safeSetState(() {
                                  _model.facilitySelectValueController?.reset();
                                });
                              }
                              _model.getClinicAppointmentReloadButton =
                                  await GQLgetByFunctionCall.call(
                                hasuraToken: FFAppState().hasuraToken,
                                requestBody: functions
                                    .generateClinicAppointmentsList(
                                        _model.clinicSelectValue != null
                                            ? _model.clinicSelectValue
                                            : null)
                                    .toString(),
                              );

                              if ((_model.getClinicAppointmentReloadButton
                                          ?.jsonBody ??
                                      '') !=
                                  FFAppState()
                                      .ClinicAppointmentsEmptyResponse) {
                                _model.appointmentData = getJsonField(
                                  (_model.getClinicAppointmentReloadButton
                                          ?.jsonBody ??
                                      ''),
                                  r'''$.data.pep_vw2_clinic_appointments''',
                                  true,
                                )!
                                    .toList()
                                    .cast<dynamic>();
                                safeSetState(() {});
                              }
                              _model.pageLoadComplete = true;
                              safeSetState(() {});

                              safeSetState(() {});
                            },
                          ),
                        if (((_model.dateSearch != null) ||
                                _model.isFilterApplied) &&
                            (_model.appointmentFiltredData.isNotEmpty))
                          Align(
                            alignment: AlignmentDirectional(1.0, 0.0),
                            child: FFButtonWidget(
                              onPressed: () async {
                                _model.selectedRows = functions
                                    .filterNotAssignedAppointments(
                                        _model.appointmentFiltredData.toList())!
                                    .toList()
                                    .cast<int>();
                                safeSetState(() {});
                                var confirmDialogResponse =
                                    await showDialog<bool>(
                                          context: context,
                                          builder: (alertDialogContext) {
                                            return AlertDialog(
                                              content: Text(
                                                  'Are you sure you want to delete all the time slots? (Only non reserved time slots will be deleted)'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          alertDialogContext,
                                                          false),
                                                  child: Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          alertDialogContext,
                                                          true),
                                                  child: Text('Confirm'),
                                                ),
                                              ],
                                            );
                                          },
                                        ) ??
                                        false;
                                if (confirmDialogResponse) {
                                  if (_model.selectedRows.isNotEmpty) {
                                    _model.deleteMultipleClinicTimeSlots =
                                        await PEPAPIsGroup
                                            .deleteMultipleTimeSlotsCall
                                            .call(
                                      adminId: int.parse(
                                          FFAppState().loginProfileID),
                                      authToken: FFAppState().loginToken,
                                      appointmentIdsList: _model.selectedRows,
                                    );

                                    if (PEPAPIsGroup.deleteMultipleTimeSlotsCall
                                            .pesDeleteMultipleTimeSlotStatus(
                                          (_model.deleteMultipleClinicTimeSlots
                                                  ?.jsonBody ??
                                              ''),
                                        ) ==
                                        true) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Deleted Clinic Appointments Sucessfully.',
                                            style: TextStyle(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .buttonText,
                                            ),
                                          ),
                                          duration:
                                              Duration(milliseconds: 4000),
                                          backgroundColor:
                                              FlutterFlowTheme.of(context)
                                                  .tertiary,
                                        ),
                                      );
                                      FFAppState()
                                          .clearPatientEnrollmentListCache();
                                      _model.selectedRows = [];
                                      _model.dateSearch = null;
                                      _model.appointmentFiltredData = [];
                                      safeSetState(() {});
                                      _model.getMultipleAppointmentsDeleteOperation =
                                          await GQLgetByFunctionCall.call(
                                        hasuraToken: FFAppState().hasuraToken,
                                        requestBody: functions
                                            .generateClinicAppointmentsList(
                                                _model.clinicSelectValue != null
                                                    ? _model.clinicSelectValue
                                                    : null)
                                            .toString(),
                                      );

                                      _model.showTable = false;
                                      _model.appointmentData = [];
                                      safeSetState(() {});
                                      await Future.delayed(
                                          const Duration(milliseconds: 50));
                                      _model.showTable = true;
                                      safeSetState(() {});
                                      _model.appointmentData = getJsonField(
                                        (_model.getMultipleAppointmentsDeleteOperation
                                                ?.jsonBody ??
                                            ''),
                                        r'''$.data.pep_vw2_clinic_appointments''',
                                        true,
                                      )!
                                          .toList()
                                          .cast<dynamic>();
                                      safeSetState(() {});
                                      _model.appointmentFiltredData = functions
                                          .filterAppointmentListLocally(
                                              _model.appointmentData.toList(),
                                              _model.facilitySelectValue
                                                  ?.toList(),
                                              _model.dateSearch != null
                                                  ? functions.returnDate(
                                                      _model.dateSearch!)
                                                  : null)!
                                          .toList()
                                          .cast<dynamic>();
                                      safeSetState(() {});
                                      _model.appointmentData = [];
                                      safeSetState(() {});
                                      _model.appointmentFiltredData = [];
                                      safeSetState(() {});
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Deleting Clinic Appointments Failed.Please Try Again!',
                                            style: TextStyle(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .buttonText,
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
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Deleting Clinic Appointments Failed.Please Try Again!',
                                          style: TextStyle(
                                            color: FlutterFlowTheme.of(context)
                                                .buttonText,
                                          ),
                                        ),
                                        duration: Duration(milliseconds: 4000),
                                        backgroundColor:
                                            FlutterFlowTheme.of(context).error,
                                      ),
                                    );
                                  }
                                }

                                safeSetState(() {});
                              },
                              text: 'Delete All',
                              options: FFButtonOptions(
                                height: 40.0,
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    24.0, 0.0, 24.0, 0.0),
                                iconPadding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 0.0),
                                color: FlutterFlowTheme.of(context).tertiary,
                                textStyle: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .override(
                                      font: GoogleFonts.poppins(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .fontStyle,
                                      ),
                                      color: Colors.white,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontWeight,
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
                      ].divide(SizedBox(width: 20.0)),
                    ),
                    if (false)
                      Align(
                        alignment: AlignmentDirectional(1.0, 0.0),
                        child: FFButtonWidget(
                          onPressed: () async {},
                          text: 'Delete Multiple',
                          options: FFButtonOptions(
                            height: 40.0,
                            padding: EdgeInsetsDirectional.fromSTEB(
                                24.0, 0.0, 24.0, 0.0),
                            iconPadding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            color: FlutterFlowTheme.of(context).tertiary,
                            textStyle: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
                                  font: GoogleFonts.poppins(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontStyle,
                                  ),
                                  color: Colors.white,
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .fontWeight,
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
                    Align(
                      alignment: AlignmentDirectional(1.0, 0.0),
                      child: FFButtonWidget(
                        onPressed: () async {
                          FFAppState().clearPatientEnrollmentListCache();

                          context.goNamed(ViewPESWidget.routeName);
                        },
                        text: 'Manage Patient Enrollers',
                        options: FFButtonOptions(
                          height: 40.0,
                          padding: EdgeInsetsDirectional.fromSTEB(
                              24.0, 0.0, 24.0, 0.0),
                          iconPadding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 0.0),
                          color: FlutterFlowTheme.of(context).tertiary,
                          textStyle:
                              FlutterFlowTheme.of(context).titleSmall.override(
                                    font: GoogleFonts.poppins(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontStyle,
                                    ),
                                    color: Colors.white,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontWeight,
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
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(),
                  child: Stack(
                    children: [
                      if (_model.appointmentData.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Builder(
                            builder: (context) {
                              final tableData =
                                  (_model.appointmentFiltredData.isNotEmpty
                                          ? _model.appointmentFiltredData
                                          : _model.appointmentData)
                                      .toList();

                              return FlutterFlowDataTable<dynamic>(
                                controller: _model.paginatedDataTableController,
                                data: tableData,
                                columnsBuilder: (onSortChanged) => [
                                  DataColumn2(
                                    label: DefaultTextStyle.merge(
                                      softWrap: true,
                                      child: Text(
                                        'Clinic Name',
                                        style: FlutterFlowTheme.of(context)
                                            .labelLarge
                                            .override(
                                              font: GoogleFonts.poppins(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .labelLarge
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelLarge
                                                        .fontStyle,
                                              ),
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .labelLarge
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelLarge
                                                      .fontStyle,
                                            ),
                                      ),
                                    ),
                                    fixedWidth:
                                        MediaQuery.sizeOf(context).width * 0.21,
                                  ),
                                  DataColumn2(
                                    label: DefaultTextStyle.merge(
                                      softWrap: true,
                                      child: Text(
                                        'Facility Name',
                                        style: FlutterFlowTheme.of(context)
                                            .labelLarge
                                            .override(
                                              font: GoogleFonts.poppins(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .labelLarge
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelLarge
                                                        .fontStyle,
                                              ),
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .labelLarge
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelLarge
                                                      .fontStyle,
                                            ),
                                      ),
                                    ),
                                    fixedWidth:
                                        MediaQuery.sizeOf(context).width * 0.18,
                                  ),
                                  DataColumn2(
                                    label: DefaultTextStyle.merge(
                                      softWrap: true,
                                      child: Align(
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0),
                                        child: Text(
                                          'Appointment\nDate',
                                          textAlign: TextAlign.center,
                                          style: FlutterFlowTheme.of(context)
                                              .labelLarge
                                              .override(
                                                font: GoogleFonts.poppins(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelLarge
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelLarge
                                                          .fontStyle,
                                                ),
                                                letterSpacing: 0.0,
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .labelLarge
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelLarge
                                                        .fontStyle,
                                              ),
                                        ),
                                      ),
                                    ),
                                    fixedWidth:
                                        MediaQuery.sizeOf(context).width * 0.15,
                                  ),
                                  DataColumn2(
                                    label: DefaultTextStyle.merge(
                                      softWrap: true,
                                      child: Align(
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0),
                                        child: Text(
                                          'Appointment\nStart Time',
                                          textAlign: TextAlign.center,
                                          style: FlutterFlowTheme.of(context)
                                              .labelLarge
                                              .override(
                                                font: GoogleFonts.poppins(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelLarge
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelLarge
                                                          .fontStyle,
                                                ),
                                                letterSpacing: 0.0,
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .labelLarge
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelLarge
                                                        .fontStyle,
                                              ),
                                        ),
                                      ),
                                    ),
                                    fixedWidth:
                                        MediaQuery.sizeOf(context).width * 0.15,
                                  ),
                                  DataColumn2(
                                    label: DefaultTextStyle.merge(
                                      softWrap: true,
                                      child: Align(
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0),
                                        child: Text(
                                          'Appointment\nEnd Time',
                                          textAlign: TextAlign.center,
                                          style: FlutterFlowTheme.of(context)
                                              .labelLarge
                                              .override(
                                                font: GoogleFonts.poppins(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelLarge
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelLarge
                                                          .fontStyle,
                                                ),
                                                letterSpacing: 0.0,
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .labelLarge
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelLarge
                                                        .fontStyle,
                                              ),
                                        ),
                                      ),
                                    ),
                                    fixedWidth:
                                        MediaQuery.sizeOf(context).width * 0.15,
                                  ),
                                  DataColumn2(
                                    label: DefaultTextStyle.merge(
                                      softWrap: true,
                                      child: Align(
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0),
                                        child: Text(
                                          'Actions',
                                          textAlign: TextAlign.center,
                                          style: FlutterFlowTheme.of(context)
                                              .labelLarge
                                              .override(
                                                font: GoogleFonts.poppins(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelLarge
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelLarge
                                                          .fontStyle,
                                                ),
                                                letterSpacing: 0.0,
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .labelLarge
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelLarge
                                                        .fontStyle,
                                              ),
                                        ),
                                      ),
                                    ),
                                    fixedWidth:
                                        MediaQuery.sizeOf(context).width * 0.1,
                                  ),
                                ],
                                dataRowBuilder: (tableDataItem, tableDataIndex,
                                        selected, onSelectChanged) =>
                                    DataRow(
                                  color: WidgetStateProperty.all(
                                    tableDataIndex % 2 == 0
                                        ? FlutterFlowTheme.of(context)
                                            .secondaryBackground
                                        : FlutterFlowTheme.of(context)
                                            .primaryBackground,
                                  ),
                                  cells: [
                                    Text(
                                      valueOrDefault<String>(
                                        getJsonField(
                                          tableDataItem,
                                          r'''$.clinic_name''',
                                        )?.toString(),
                                        'N/A',
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
                                    Text(
                                      valueOrDefault<String>(
                                        getJsonField(
                                          tableDataItem,
                                          r'''$.facility_name''',
                                        )?.toString(),
                                        'N/A',
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
                                    Align(
                                      alignment: AlignmentDirectional(0.0, 0.0),
                                      child: Text(
                                        valueOrDefault<String>(
                                          (String dateString) {
                                            return dateString.length == 10
                                                ? dateString.substring(5) +
                                                    '-' +
                                                    dateString.substring(0, 4)
                                                : 'N/A';
                                          }(valueOrDefault<String>(
                                            getJsonField(
                                              tableDataItem,
                                              r'''$.appointment_date''',
                                            )?.toString(),
                                            'N/A',
                                          )),
                                          'N/A',
                                        ),
                                        textAlign: TextAlign.start,
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
                                    Align(
                                      alignment: AlignmentDirectional(0.0, 0.0),
                                      child: Text(
                                        valueOrDefault<String>(
                                          getJsonField(
                                            tableDataItem,
                                            r'''$.appointment_start_time''',
                                          )?.toString(),
                                          'N/A',
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
                                    Align(
                                      alignment: AlignmentDirectional(0.0, 0.0),
                                      child: Text(
                                        valueOrDefault<String>(
                                          getJsonField(
                                            tableDataItem,
                                            r'''$.appointment_end_time''',
                                          )?.toString(),
                                          'N/A',
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
                                    Align(
                                      alignment: AlignmentDirectional(0.0, 0.0),
                                      child: FlutterFlowIconButton(
                                        borderColor:
                                            FlutterFlowTheme.of(context)
                                                .secondaryText,
                                        borderRadius: 22.0,
                                        borderWidth: 1.0,
                                        buttonSize: 38.0,
                                        fillColor: FlutterFlowTheme.of(context)
                                            .secondary,
                                        disabledColor:
                                            FlutterFlowTheme.of(context)
                                                .secondary,
                                        disabledIconColor:
                                            FlutterFlowTheme.of(context)
                                                .secondaryText,
                                        icon: Icon(
                                          Icons.delete,
                                          color: FlutterFlowTheme.of(context)
                                              .error,
                                          size: 22.0,
                                        ),
                                        onPressed: (getJsonField(
                                                  tableDataItem,
                                                  r'''$.patient_clinic_data_id''',
                                                ) !=
                                                null)
                                            ? null
                                            : () async {
                                                var confirmDialogResponse =
                                                    await showDialog<bool>(
                                                          context: context,
                                                          builder:
                                                              (alertDialogContext) {
                                                            return AlertDialog(
                                                              content: Text(
                                                                  'Are you sure you want to delete this Time Slot?'),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed: () =>
                                                                      Navigator.pop(
                                                                          alertDialogContext,
                                                                          false),
                                                                  child: Text(
                                                                      'Cancel'),
                                                                ),
                                                                TextButton(
                                                                  onPressed: () =>
                                                                      Navigator.pop(
                                                                          alertDialogContext,
                                                                          true),
                                                                  child: Text(
                                                                      'Confirm'),
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        ) ??
                                                        false;
                                                if (confirmDialogResponse) {
                                                  _model.deleteTimeAllotment =
                                                      await PEPAPIsGroup
                                                          .deleteTimeSlotCall
                                                          .call(
                                                    appointmentId: getJsonField(
                                                      tableDataItem,
                                                      r'''$.appointment_id''',
                                                    ),
                                                    adminId: int.parse(
                                                        FFAppState()
                                                            .loginProfileID),
                                                    authToken:
                                                        FFAppState().loginToken,
                                                  );

                                                  if (PEPAPIsGroup
                                                          .deleteTimeSlotCall
                                                          .pesDeleteTimeSlotStatus(
                                                        (_model.deleteTimeAllotment
                                                                ?.jsonBody ??
                                                            ''),
                                                      ) ==
                                                      true) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          'Deleted Clinic Appointments Sucessfully.',
                                                          style: TextStyle(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
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
                                                    FFAppState()
                                                        .clearPatientEnrollmentListCache();
                                                    _model.getAppointmentsDeleteOperation =
                                                        await GQLgetByFunctionCall
                                                            .call(
                                                      hasuraToken: FFAppState()
                                                          .hasuraToken,
                                                      requestBody: functions
                                                          .generateClinicAppointmentsList(
                                                              _model.clinicSelectValue !=
                                                                      null
                                                                  ? _model
                                                                      .clinicSelectValue
                                                                  : null)
                                                          .toString(),
                                                    );

                                                    _model.appointmentData =
                                                        getJsonField(
                                                      (_model.getAppointmentsDeleteOperation
                                                              ?.jsonBody ??
                                                          ''),
                                                      r'''$.data.pep_vw2_clinic_appointments''',
                                                      true,
                                                    )!
                                                            .toList()
                                                            .cast<dynamic>();
                                                    safeSetState(() {});
                                                    _model.appointmentFiltredData = functions
                                                        .filterAppointmentListLocally(
                                                            _model
                                                                .appointmentData
                                                                .toList(),
                                                            _model
                                                                .facilitySelectValue
                                                                ?.toList(),
                                                            _model.dateSearch !=
                                                                    null
                                                                ? functions
                                                                    .returnDate(
                                                                        _model
                                                                            .dateSearch!)
                                                                : null)!
                                                        .toList()
                                                        .cast<dynamic>();
                                                    safeSetState(() {});
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          'Deleting Clinic Appointments Failed.Please Try Again!',
                                                          style: TextStyle(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
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
                                                }

                                                safeSetState(() {});
                                              },
                                      ),
                                    ),
                                  ].map((c) => DataCell(c)).toList(),
                                ),
                                paginated: true,
                                selectable: false,
                                hidePaginator: false,
                                showFirstLastButtons: false,
                                headingRowHeight: 56.0,
                                dataRowHeight: 48.0,
                                columnSpacing: 20.0,
                                headingRowColor:
                                    FlutterFlowTheme.of(context).primary,
                                borderRadius: BorderRadius.circular(8.0),
                                addHorizontalDivider: true,
                                addTopAndBottomDivider: false,
                                hideDefaultHorizontalDivider: true,
                                horizontalDividerColor:
                                    FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                horizontalDividerThickness: 1.0,
                                addVerticalDivider: false,
                              );
                            },
                          ),
                        ),
                      if (!(_model.appointmentData.isNotEmpty) &&
                          _model.pageLoadComplete)
                        Align(
                          alignment: AlignmentDirectional(0.0, 0.0),
                          child: Text(
                            'There are no slots booked for this clinic',
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
                                  fontSize: 32.0,
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
