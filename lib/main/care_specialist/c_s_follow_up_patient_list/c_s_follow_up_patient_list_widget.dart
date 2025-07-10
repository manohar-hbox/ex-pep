import '/backend/api_requests/api_calls.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_data_table.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_timer.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/flutter_flow/instant_timer.dart';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'c_s_follow_up_patient_list_model.dart';
export 'c_s_follow_up_patient_list_model.dart';

class CSFollowUpPatientListWidget extends StatefulWidget {
  const CSFollowUpPatientListWidget({super.key});

  static String routeName = 'CSFollowUpPatientList';
  static String routePath = 'CSFollowUpPatientList';

  @override
  State<CSFollowUpPatientListWidget> createState() =>
      _CSFollowUpPatientListWidgetState();
}

class _CSFollowUpPatientListWidgetState
    extends State<CSFollowUpPatientListWidget> {
  late CSFollowUpPatientListModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CSFollowUpPatientListModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (FFAppState().loginToken != '') {
        _model.sessionTimerController.timer.setPresetTime(
          mSec: FFAppState().timerState,
          add: false,
        );
        _model.sessionTimerController.onResetTimer();

        _model.sessionTimerController.onStartTimer();

        FFAppState().update(() {});
        _model.csFollowUpPatientList = [];
        _model.csFollowUpPatientListFiltered = [];
        _model.pageLoad = false;
        safeSetState(() {});
        if (!(_model.csFollowUpPatientList.isNotEmpty)) {
          _model.csPatientDeferredListAPICallPageLoad =
              await GQLgetByFunctionCall.call(
            hasuraToken: FFAppState().hasuraToken,
            requestBody:
                functions.getCareSpecialistFollowUpPatientList().toString(),
          );

          FFAppState().isCSView = true;
          safeSetState(() {});
          _model.csFollowUpPatientList = functions
              .enrichClinicTime(getJsonField(
                (_model.csPatientDeferredListAPICallPageLoad?.jsonBody ?? ''),
                r'''$.data.pep_vw_cs_task_patient_list''',
                true,
              )!)
              .toList()
              .cast<dynamic>();
          safeSetState(() {});
          _model.pageLoad = true;
          safeSetState(() {});
          await Future.delayed(const Duration(milliseconds: 100));
          _model.dataTableGroupListController.paginatorController
              .setRowsPerPage(FFAppState().csTableRowCount);
          _model.dataTableGroupListController.paginatorController
              .goToPageWithRow(FFAppState().csTableRowIndex);
        } else {
          _model.csFollowUpPatientList = [];
          safeSetState(() {});
          _model.pageLoad = true;
          safeSetState(() {});
        }

        _model.instantTimer = InstantTimer.periodic(
          duration: Duration(milliseconds: 1000),
          callback: (timer) async {
            if (((_model.sessionTimerMilliseconds ~/ 1000) % 60) == 0) {
              _model.updateTimerPageLoad =
                  await PEPAPIsGroup.updateTimerLogCall.call(
                duration: _model.sessionTimerMilliseconds ~/ 1000,
                userId: FFAppState().loginProfileID,
                timelogId: FFAppState().timerlogId,
                authToken: FFAppState().loginToken,
              );
            }
            _model.isTabMinimized = await actions.isTabMinimized();
            if (_model.isTabMinimized!) {
              FFAppState().timerState = FFAppState().timerState;
              safeSetState(() {});
              FFAppState().isAppMinimized = true;
              safeSetState(() {});
              _model.sessionTimerController.onStopTimer();
              FFAppState().isPaused = true;
              safeSetState(() {});
            } else {
              FFAppState().timerState = FFAppState().timerState;
              safeSetState(() {});
              FFAppState().isAppMinimized = false;
              safeSetState(() {});
              _model.sessionTimerController.onStartTimer();
              FFAppState().isPaused = false;
              safeSetState(() {});
            }
          },
          startImmediately: false,
        );
      } else {
        await actions.checkAndStoreRedirectURL();

        context.goNamed(LoginWidget.routeName);

        await actions.clearCacheAndReloadHbox();
      }
    });

    _model.searchStringTextController ??= TextEditingController();
    _model.searchStringFocusNode ??= FocusNode();

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
        backgroundColor: FlutterFlowTheme.of(context).secondary,
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
                          'Care Specialist (CS) - Follow Up Patients',
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
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 16.0, 0.0),
                      child: Container(
                        width: 115.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                          color: Color(0xFF007BFF),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Align(
                          alignment: AlignmentDirectional(0.0, 0.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (!FFAppState().isPaused)
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 4.0, 0.0),
                                  child: FlutterFlowIconButton(
                                    borderColor: Colors.transparent,
                                    borderRadius: 20.0,
                                    buttonSize: 40.0,
                                    icon: Icon(
                                      Icons.pause_sharp,
                                      color: FlutterFlowTheme.of(context)
                                          .secondary,
                                      size: 24.0,
                                    ),
                                    onPressed: () async {
                                      if (FFAppState().loginToken != '') {
                                        FFAppState().timerState =
                                            _model.sessionTimerMilliseconds;
                                        safeSetState(() {});
                                        _model.sessionTimerController
                                            .onStopTimer();
                                        FFAppState().isPaused =
                                            !(FFAppState().isPaused ?? true);
                                        safeSetState(() {});
                                        if (_model.instantTimer.isActive) {
                                          _model.instantTimer?.cancel();
                                        } else {
                                          _model.instantTimerNested?.cancel();
                                        }
                                      }
                                    },
                                  ),
                                ),
                              if (FFAppState().isPaused)
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 4.0, 0.0),
                                  child: FlutterFlowIconButton(
                                    borderColor: Colors.transparent,
                                    borderRadius: 20.0,
                                    buttonSize: 40.0,
                                    icon: Icon(
                                      Icons.play_arrow,
                                      color: FlutterFlowTheme.of(context)
                                          .secondary,
                                      size: 24.0,
                                    ),
                                    onPressed: () async {
                                      if (FFAppState().loginToken != '') {
                                        FFAppState().timerState =
                                            FFAppState().timerState;
                                        safeSetState(() {});
                                        _model.sessionTimerController
                                            .onStartTimer();
                                        FFAppState().isPaused =
                                            !(FFAppState().isPaused ?? true);
                                        safeSetState(() {});
                                        if (!_model.instantTimer.isActive) {
                                          _model.instantTimerNested =
                                              InstantTimer.periodic(
                                            duration:
                                                Duration(milliseconds: 1000),
                                            callback: (timer) async {
                                              if (((_model.sessionTimerMilliseconds ~/
                                                          1000) %
                                                      60) ==
                                                  0) {
                                                _model.updateTimerPlayTap =
                                                    await PEPAPIsGroup
                                                        .updateTimerLogCall
                                                        .call(
                                                  duration: _model
                                                          .sessionTimerMilliseconds ~/
                                                      1000,
                                                  userId: FFAppState()
                                                      .loginProfileID,
                                                  timelogId:
                                                      FFAppState().timerlogId,
                                                  authToken:
                                                      FFAppState().loginToken,
                                                );
                                              }
                                              _model.isTabMinimizedNested =
                                                  await actions
                                                      .isTabMinimized();
                                              if (_model
                                                  .isTabMinimizedNested!) {
                                                FFAppState().timerState =
                                                    FFAppState().timerState;
                                                safeSetState(() {});
                                                FFAppState().isAppMinimized =
                                                    true;
                                                safeSetState(() {});
                                                _model.sessionTimerController
                                                    .onStopTimer();
                                                FFAppState().isPaused = true;
                                                safeSetState(() {});
                                              } else {
                                                FFAppState().timerState =
                                                    FFAppState().timerState;
                                                safeSetState(() {});
                                                FFAppState().isAppMinimized =
                                                    false;
                                                safeSetState(() {});
                                                _model.sessionTimerController
                                                    .onStartTimer();
                                                FFAppState().isPaused = false;
                                                safeSetState(() {});
                                              }
                                            },
                                            startImmediately: false,
                                          );
                                        }
                                      }

                                      safeSetState(() {});
                                    },
                                  ),
                                ),
                              FlutterFlowTimer(
                                initialTime: _model.sessionTimerInitialTimeMs,
                                getDisplayTime: (value) =>
                                    StopWatchTimer.getDisplayTime(
                                  value,
                                  hours: false,
                                  milliSecond: false,
                                ),
                                controller: _model.sessionTimerController,
                                updateStateInterval:
                                    Duration(milliseconds: 1000),
                                onChanged: (value, displayTime, shouldUpdate) {
                                  _model.sessionTimerMilliseconds = value;
                                  _model.sessionTimerValue = displayTime;
                                  if (shouldUpdate) safeSetState(() {});
                                },
                                onEnded: () async {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Showing from End Timer',
                                        style: TextStyle(
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                        ),
                                      ),
                                      duration: Duration(milliseconds: 4000),
                                      backgroundColor:
                                          FlutterFlowTheme.of(context)
                                              .secondary,
                                    ),
                                  );
                                  _model.sessionTimerController.onStartTimer();
                                },
                                textAlign: TextAlign.start,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .secondary,
                                      fontSize: 18.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    FFButtonWidget(
                      onPressed: () async {
                        var confirmDialogResponse = await showDialog<bool>(
                              context: context,
                              builder: (alertDialogContext) {
                                return AlertDialog(
                                  content: Text(
                                      'Are you sure you want to sign out?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(
                                          alertDialogContext, false),
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(
                                          alertDialogContext, true),
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

                          FFAppState().isCSView = false;
                          safeSetState(() {});
                          FFAppState().timerState = FFAppState().timerState;
                          safeSetState(() {});
                          FFAppState().timerState =
                              _model.sessionTimerMilliseconds;
                          safeSetState(() {});
                          _model.sessionTimerController.onResetTimer();

                          if (_model.instantTimer.isActive) {
                            _model.instantTimer?.cancel();
                          } else {
                            _model.instantTimerNested?.cancel();
                          }

                          FFAppState().deleteTimerState();
                          FFAppState().timerState = 0;

                          safeSetState(() {});

                          context.goNamed(
                            LoginWidget.routeName,
                            extra: <String, dynamic>{
                              kTransitionInfoKey: TransitionInfo(
                                hasTransition: true,
                                transitionType: PageTransitionType.fade,
                                duration: Duration(milliseconds: 400),
                              ),
                            },
                          );

                          await actions.clearCacheAndReloadHbox();
                        }
                      },
                      text: 'SIGNOUT',
                      options: FFButtonOptions(
                        height: 40.0,
                        padding: EdgeInsetsDirectional.fromSTEB(
                            24.0, 0.0, 24.0, 0.0),
                        iconPadding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                        color: FlutterFlowTheme.of(context).accent3,
                        textStyle: FlutterFlowTheme.of(context)
                            .titleSmall
                            .override(
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
                  ],
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
          child: AnimatedContainer(
            duration: Duration(milliseconds: 390),
            curve: Curves.easeIn,
            decoration: BoxDecoration(),
            alignment: AlignmentDirectional(1.0, 1.0),
            child: Visibility(
              visible: _model.pageLoad,
              child: Align(
                alignment: AlignmentDirectional(1.0, 1.0),
                child: Stack(
                  alignment: AlignmentDirectional(1.0, 1.0),
                  children: [
                    if (!(_model.csFollowUpPatientList.isNotEmpty))
                      Align(
                        alignment: AlignmentDirectional(0.0, 0.0),
                        child: Text(
                          'There are no patients available in the Follow up List!',
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
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Align(
                          alignment: AlignmentDirectional(-1.0, 0.0),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                20.0, 20.0, 0.0, 0.0),
                            child: FlutterFlowIconButton(
                              borderRadius: 8.0,
                              buttonSize: 40.0,
                              fillColor: FlutterFlowTheme.of(context).primary,
                              icon: Icon(
                                Icons.arrow_back,
                                color: FlutterFlowTheme.of(context).info,
                                size: 24.0,
                              ),
                              onPressed: () async {
                                FFAppState().isDetailsSaved = false;
                                safeSetState(() {});
                                FFAppState().timerState =
                                    FFAppState().timerState;
                                safeSetState(() {});
                                FFAppState().timerState =
                                    _model.sessionTimerMilliseconds;
                                safeSetState(() {});
                                _model.sessionTimerController.onStopTimer();
                                FFAppState().isPaused =
                                    !(FFAppState().isPaused ?? true);
                                safeSetState(() {});
                                if (_model.instantTimer.isActive) {
                                  _model.instantTimer?.cancel();
                                } else {
                                  _model.instantTimerNested?.cancel();
                                }

                                FFAppState().filterApplied = false;
                                safeSetState(() {});

                                context.goNamed(
                                  CSPatientListWidget.routeName,
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
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              20.0, 12.0, 20.0, 0.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  FlutterFlowDropDown<String>(
                                    controller: _model
                                            .csFollowUpDropDownValueController ??=
                                        FormFieldController<String>(
                                      _model
                                          .csFollowUpDropDownValue ??= (FFAppState()
                                                          .csFilterDropDownContent ==
                                                      '') ||
                                              !(FFAppState()
                                                  .csFilterDropdownContentListCCM
                                                  .isNotEmpty) ||
                                              !(FFAppState()
                                                  .csFilterDropdownContentListRPM
                                                  .isNotEmpty)
                                          ? 'full_name'
                                          : FFAppState().csFilterDropDownIndex,
                                    ),
                                    options: List<String>.from([
                                      'full_name',
                                      'dob',
                                      'mobile_phone_number',
                                      'provider_name',
                                      'clinic_time_appointment',
                                      'clinic_name'
                                    ]),
                                    optionLabels: [
                                      'Name',
                                      'DOB',
                                      'Phone Number',
                                      'Provider Name',
                                      'Appointment Date',
                                      'Clinic Name'
                                    ],
                                    onChanged: (val) => safeSetState(() =>
                                        _model.csFollowUpDropDownValue = val),
                                    width: 189.0,
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
                                    hintText: (FFAppState()
                                                        .csFilterDropDownContent ==
                                                    '') ||
                                            !(FFAppState()
                                                .csFilterDropdownContentListCCM
                                                .isNotEmpty) ||
                                            !(FFAppState()
                                                .pesFilterDropDownContentListCCM
                                                .isNotEmpty)
                                        ? 'Name'
                                        : FFAppState().csFilterDropDownIndex,
                                    icon: Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      size: 24.0,
                                    ),
                                    fillColor: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    elevation: 2.0,
                                    borderColor: FlutterFlowTheme.of(context)
                                        .borderColor,
                                    borderWidth: 0.0,
                                    borderRadius: 8.0,
                                    margin: EdgeInsetsDirectional.fromSTEB(
                                        12.0, 0.0, 12.0, 0.0),
                                    hidesUnderline: true,
                                    isOverButton: false,
                                    isSearchable: false,
                                    isMultiSelect: false,
                                  ),
                                  if (!((_model.csFollowUpDropDownValue ==
                                          'dob') ||
                                      (_model.csFollowUpDropDownValue ==
                                          'clinic_time_appointment')))
                                    Container(
                                      width: 360.0,
                                      height: 56.0,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(0.0),
                                        shape: BoxShape.rectangle,
                                      ),
                                      child: Container(
                                        width: 360.0,
                                        child: TextFormField(
                                          controller:
                                              _model.searchStringTextController,
                                          focusNode:
                                              _model.searchStringFocusNode,
                                          onChanged: (_) =>
                                              EasyDebounce.debounce(
                                            '_model.searchStringTextController',
                                            Duration(milliseconds: 2000),
                                            () => safeSetState(() {}),
                                          ),
                                          onFieldSubmitted: (_) async {
                                            if (!((_model
                                                        .csFollowUpDropDownValue ==
                                                    'dob') ||
                                                (_model.csFollowUpDropDownValue ==
                                                    'clinic_time_appointment'))) {
                                              if ((String? searchString) {
                                                return searchString == null
                                                    ? false
                                                    : (searchString.length >= 3
                                                        ? true
                                                        : false);
                                              }(_model
                                                  .searchStringTextController
                                                  .text)) {
                                                _model.csFollowUpPatientListFiltered = functions
                                                    .filterCSFollowUpListLocally(
                                                        _model
                                                            .csFollowUpPatientList
                                                            .toList(),
                                                        _model
                                                            .csFollowUpDropDownValue,
                                                        _model
                                                            .searchStringTextController
                                                            .text)!
                                                    .toList()
                                                    .cast<dynamic>();
                                                safeSetState(() {});
                                                FFAppState()
                                                    .csFilterFollowUpDropDownContent = '';
                                                safeSetState(() {});
                                                FFAppState()
                                                        .csFilterFollowUpDropDownIndex =
                                                    _model
                                                        .csFollowUpDropDownValue!;
                                                safeSetState(() {});
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Enter a minimum of three characters for search operation',
                                                      style: TextStyle(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primaryText,
                                                      ),
                                                    ),
                                                    duration: Duration(
                                                        milliseconds: 4000),
                                                    backgroundColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .warning,
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                          autofocus: false,
                                          obscureText: false,
                                          decoration: InputDecoration(
                                            isDense: false,
                                            labelStyle:
                                                FlutterFlowTheme.of(context)
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
                                            hintText: 'Search',
                                            hintStyle:
                                                FlutterFlowTheme.of(context)
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
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .borderColor,
                                                width: 1.0,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .borderColor,
                                                width: 1.0,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .error,
                                                width: 1.0,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .error,
                                                width: 1.0,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                            filled: true,
                                            fillColor:
                                                FlutterFlowTheme.of(context)
                                                    .secondaryBackground,
                                            suffixIcon: _model
                                                    .searchStringTextController!
                                                    .text
                                                    .isNotEmpty
                                                ? InkWell(
                                                    onTap: () async {
                                                      _model
                                                          .searchStringTextController
                                                          ?.clear();
                                                      safeSetState(() {});
                                                    },
                                                    child: Icon(
                                                      Icons.clear,
                                                      size: 22,
                                                    ),
                                                  )
                                                : null,
                                          ),
                                          style: FlutterFlowTheme.of(context)
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
                                                  .primaryText,
                                          validator: _model
                                              .searchStringTextControllerValidator
                                              .asValidator(context),
                                        ),
                                      ),
                                    ),
                                  if ((_model.csFollowUpDropDownValue ==
                                          'dob') ||
                                      (_model.csFollowUpDropDownValue ==
                                          'clinic_time_appointment'))
                                    FFButtonWidget(
                                      onPressed: () async {
                                        final _datePickedDate =
                                            await showDatePicker(
                                          context: context,
                                          initialDate: getCurrentTimestamp,
                                          firstDate: DateTime(1900),
                                          lastDate: DateTime(2050),
                                          builder: (context, child) {
                                            return wrapInMaterialDatePickerTheme(
                                              context,
                                              child!,
                                              headerBackgroundColor:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              headerForegroundColor:
                                                  FlutterFlowTheme.of(context)
                                                      .info,
                                              headerTextStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .headlineLarge
                                                      .override(
                                                        font:
                                                            GoogleFonts.poppins(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .headlineLarge
                                                                  .fontStyle,
                                                        ),
                                                        fontSize: 32.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
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
                                                      .info,
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
                                            _model.datePicked =
                                                getCurrentTimestamp;
                                          });
                                        }
                                        _model.dateSearch = _model.datePicked;
                                        safeSetState(() {});
                                        FFAppState()
                                                .csFilterFollowUpDropDownContent =
                                            _model.datePicked!.toString();
                                        safeSetState(() {});
                                      },
                                      text: valueOrDefault<String>(
                                        dateTimeFormat(
                                          "d MMM, y",
                                          _model.dateSearch,
                                          locale: FFLocalizations.of(context)
                                              .languageCode,
                                        ),
                                        'Select Date',
                                      ),
                                      options: FFButtonOptions(
                                        width: 200.0,
                                        height: 56.0,
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            16.0, 0.0, 16.0, 0.0),
                                        iconPadding:
                                            EdgeInsetsDirectional.fromSTEB(
                                                0.0, 0.0, 0.0, 0.0),
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        textStyle: FlutterFlowTheme.of(context)
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
                                        elevation: 0.0,
                                        borderSide: BorderSide(
                                          color: FlutterFlowTheme.of(context)
                                              .borderColor,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                    ),
                                  FFButtonWidget(
                                    onPressed: (_model
                                                    .csFollowUpDropDownValue ==
                                                null ||
                                            _model.csFollowUpDropDownValue ==
                                                '')
                                        ? null
                                        : () async {
                                            if (!((_model
                                                        .csFollowUpDropDownValue ==
                                                    'dob') ||
                                                (_model.csFollowUpDropDownValue ==
                                                    'clinic_time_appointment'))) {
                                              if ((String? searchString) {
                                                return searchString == null
                                                    ? false
                                                    : (searchString.length >= 3
                                                        ? true
                                                        : false);
                                              }(_model
                                                  .searchStringTextController
                                                  .text)) {
                                                FFAppState().filterApplied =
                                                    true;
                                                safeSetState(() {});
                                                _model.csFollowUpPatientListFiltered = functions
                                                    .filterCSFollowUpListLocally(
                                                        _model
                                                            .csFollowUpPatientList
                                                            .toList(),
                                                        _model
                                                            .csFollowUpDropDownValue,
                                                        _model
                                                            .searchStringTextController
                                                            .text)!
                                                    .toList()
                                                    .cast<dynamic>();
                                                safeSetState(() {});
                                                FFAppState()
                                                        .csFilterFollowUpDropDownContent =
                                                    (_model.searchStringFocusNode
                                                                ?.hasFocus ??
                                                            false)
                                                        .toString();
                                                safeSetState(() {});
                                                FFAppState()
                                                        .csFilterFollowUpDropDownIndex =
                                                    _model
                                                        .csFollowUpDropDownValue!;
                                                safeSetState(() {});
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Enter a minimum of three characters for search operation',
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
                                            } else if ((_model
                                                        .csFollowUpDropDownValue ==
                                                    'dob') ||
                                                (_model.csFollowUpDropDownValue ==
                                                    'clinic_time_appointment')) {
                                              if (_model.dateSearch != null) {
                                                FFAppState().filterApplied =
                                                    true;
                                                safeSetState(() {});
                                                _model.csFollowUpPatientListFiltered = functions
                                                    .filterCSFollowUpListLocally(
                                                        _model
                                                            .csFollowUpPatientList
                                                            .toList(),
                                                        _model
                                                            .csFollowUpDropDownValue,
                                                        functions.returnDate(
                                                            _model
                                                                .dateSearch!))!
                                                    .toList()
                                                    .cast<dynamic>();
                                                safeSetState(() {});

                                                safeSetState(() {});
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Select the date to search for',
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
                                            }
                                          },
                                    text: 'Search',
                                    options: FFButtonOptions(
                                      height: 46.0,
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          16.0, 0.0, 16.0, 0.0),
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
                                            color: Colors.white,
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
                                      elevation: 0.0,
                                      borderRadius: BorderRadius.circular(8.0),
                                      disabledColor:
                                          FlutterFlowTheme.of(context)
                                              .alternate,
                                    ),
                                  ),
                                ].divide(SizedBox(width: 20.0)),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  FlutterFlowIconButton(
                                    borderColor: Colors.transparent,
                                    borderRadius: 20.0,
                                    borderWidth: 1.0,
                                    buttonSize: 40.0,
                                    fillColor:
                                        FlutterFlowTheme.of(context).tertiary,
                                    icon: Icon(
                                      Icons.refresh_sharp,
                                      color: FlutterFlowTheme.of(context)
                                          .buttonText,
                                      size: 24.0,
                                    ),
                                    onPressed: () async {
                                      _model.csFollowUpPatientList = [];
                                      _model.csFollowUpPatientListFiltered = [];
                                      _model.pageLoad = false;
                                      safeSetState(() {});
                                      FFAppState().csTableRowCount = 10;
                                      FFAppState().csTableRowIndex = 0;
                                      FFAppState().csFilterDropDownContent = '';
                                      FFAppState().csFilterDropDownIndex = '';
                                      FFAppState()
                                          .csFilterDropdownContentListCCM = [];
                                      FFAppState()
                                          .csFilterDropdownContentListRPM = [];
                                      FFAppState().csSelectedStatusesCCM = [];
                                      FFAppState().csSelectedStatusesRPM = [];
                                      FFAppState().filterApplied = false;
                                      safeSetState(() {});
                                      safeSetState(() {
                                        _model.csFollowUpDropDownValueController
                                            ?.reset();
                                      });
                                      safeSetState(() {
                                        _model.searchStringTextController
                                            ?.clear();
                                      });
                                      safeSetState(() {
                                        _model.csFollowUpDropDownValueController
                                            ?.value = 'full_name';
                                      });
                                      _model.csPatientFollowUpListAPICallReLoadButton =
                                          await GQLgetByFunctionCall.call(
                                        hasuraToken: FFAppState().hasuraToken,
                                        requestBody: functions
                                            .getCareSpecialistFollowUpPatientList()
                                            .toString(),
                                      );

                                      _model.csFollowUpPatientList = functions
                                          .enrichClinicTime(getJsonField(
                                            (_model.csPatientFollowUpListAPICallReLoadButton
                                                    ?.jsonBody ??
                                                ''),
                                            r'''$.data.pep_vw_cs_task_patient_list''',
                                            true,
                                          )!)
                                          .toList()
                                          .cast<dynamic>();
                                      safeSetState(() {});
                                      _model.pageLoad = true;
                                      safeSetState(() {});

                                      safeSetState(() {});
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Stack(
                            children: [
                              if (_model.csFollowUpPatientList.isNotEmpty)
                                Align(
                                  alignment: AlignmentDirectional(0.0, 0.0),
                                  child: Padding(
                                    padding: EdgeInsets.all(20.0),
                                    child: Builder(
                                      builder: (context) {
                                        final tableData = ((FFAppState()
                                                            .filterApplied ==
                                                        false) &&
                                                    !(_model
                                                        .csFollowUpPatientListFiltered
                                                        .isNotEmpty)
                                                ? _model.csFollowUpPatientList
                                                : _model
                                                    .csFollowUpPatientListFiltered)
                                            .toList();

                                        return FlutterFlowDataTable<dynamic>(
                                          controller: _model
                                              .dataTableGroupListController,
                                          data: tableData,
                                          columnsBuilder: (onSortChanged) => [
                                            DataColumn2(
                                              label: DefaultTextStyle.merge(
                                                softWrap: true,
                                                child: Text(
                                                  'Last Appointment in\nClinic Time',
                                                  textAlign: TextAlign.center,
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .labelLarge
                                                      .override(
                                                        font:
                                                            GoogleFonts.poppins(
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
                                                ),
                                              ),
                                              fixedWidth:
                                                  MediaQuery.sizeOf(context)
                                                          .width *
                                                      0.12,
                                            ),
                                            DataColumn2(
                                              label: DefaultTextStyle.merge(
                                                softWrap: true,
                                                child: Text(
                                                  'Last Appointment in\nLocal Time',
                                                  textAlign: TextAlign.center,
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .labelLarge
                                                      .override(
                                                        font:
                                                            GoogleFonts.poppins(
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
                                                ),
                                              ),
                                              fixedWidth:
                                                  MediaQuery.sizeOf(context)
                                                          .width *
                                                      0.12,
                                            ),
                                            DataColumn2(
                                              label: DefaultTextStyle.merge(
                                                softWrap: true,
                                                child: Text(
                                                  'Name',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .labelLarge
                                                      .override(
                                                        font:
                                                            GoogleFonts.poppins(
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
                                                ),
                                              ),
                                              fixedWidth:
                                                  MediaQuery.sizeOf(context)
                                                          .width *
                                                      0.18,
                                            ),
                                            DataColumn2(
                                              label: DefaultTextStyle.merge(
                                                softWrap: true,
                                                child: Text(
                                                  'Date of Birth',
                                                  textAlign: TextAlign.center,
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .labelLarge
                                                      .override(
                                                        font:
                                                            GoogleFonts.poppins(
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
                                                ),
                                              ),
                                              fixedWidth:
                                                  MediaQuery.sizeOf(context)
                                                          .width *
                                                      0.1,
                                            ),
                                            DataColumn2(
                                              label: DefaultTextStyle.merge(
                                                softWrap: true,
                                                child: Text(
                                                  'Clinic Name',
                                                  textAlign: TextAlign.center,
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .labelLarge
                                                      .override(
                                                        font:
                                                            GoogleFonts.poppins(
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
                                                ),
                                              ),
                                              fixedWidth:
                                                  MediaQuery.sizeOf(context)
                                                          .width *
                                                      0.15,
                                            ),
                                            DataColumn2(
                                              label: DefaultTextStyle.merge(
                                                softWrap: true,
                                                child: Text(
                                                  'CCM Status',
                                                  textAlign: TextAlign.center,
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .labelLarge
                                                      .override(
                                                        font:
                                                            GoogleFonts.poppins(
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
                                                ),
                                              ),
                                              fixedWidth:
                                                  MediaQuery.sizeOf(context)
                                                          .width *
                                                      0.1,
                                            ),
                                            DataColumn2(
                                              label: DefaultTextStyle.merge(
                                                softWrap: true,
                                                child: Text(
                                                  'RPM Status',
                                                  textAlign: TextAlign.center,
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .labelLarge
                                                      .override(
                                                        font:
                                                            GoogleFonts.poppins(
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
                                                ),
                                              ),
                                              fixedWidth:
                                                  MediaQuery.sizeOf(context)
                                                          .width *
                                                      0.1,
                                            ),
                                            DataColumn2(
                                              label: DefaultTextStyle.merge(
                                                softWrap: true,
                                                child: Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          0.0, 0.0),
                                                  child: Text(
                                                    'Actions',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .labelLarge
                                                        .override(
                                                          font: GoogleFonts
                                                              .poppins(
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
                                                  ),
                                                ),
                                              ),
                                              fixedWidth:
                                                  MediaQuery.sizeOf(context)
                                                          .width *
                                                      0.07,
                                            ),
                                          ],
                                          dataRowBuilder: (tableDataItem,
                                                  tableDataIndex,
                                                  selected,
                                                  onSelectChanged) =>
                                              DataRow(
                                            color: WidgetStateProperty.all(
                                              tableDataIndex % 2 == 0
                                                  ? FlutterFlowTheme.of(context)
                                                      .secondaryBackground
                                                  : FlutterFlowTheme.of(context)
                                                      .alternateRow,
                                            ),
                                            cells: [
                                              Text(
                                                getJsonField(
                                                          tableDataItem,
                                                          r'''$.consented_appointment_date_time''',
                                                        ) ==
                                                        null
                                                    ? 'Appointment Not Set'
                                                    : dateTimeFormat(
                                                        "MM/dd/yy h:mm a",
                                                        functions
                                                            .dtReturnFormatter(
                                                                getJsonField(
                                                                  tableDataItem,
                                                                  r'''$.consented_appointment_date_time''',
                                                                ).toString(),
                                                                getJsonField(
                                                                  tableDataItem,
                                                                  r'''$.patient_clinic_timezone''',
                                                                ).toString()),
                                                        locale:
                                                            FFLocalizations.of(
                                                                    context)
                                                                .languageCode,
                                                      ),
                                                style: FlutterFlowTheme.of(
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
                                                      letterSpacing: 0.0,
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
                                              ),
                                              Text(
                                                getJsonField(
                                                          tableDataItem,
                                                          r'''$.consented_appointment_date_time''',
                                                        ) ==
                                                        null
                                                    ? 'Appointment Not Set'
                                                    : dateTimeFormat(
                                                        "MM/dd/yy h:mm a",
                                                        functions
                                                            .dtReturnFormatter(
                                                                getJsonField(
                                                                  tableDataItem,
                                                                  r'''$.consented_appointment_date_time''',
                                                                ).toString(),
                                                                'LOCAL'),
                                                        locale:
                                                            FFLocalizations.of(
                                                                    context)
                                                                .languageCode,
                                                      ),
                                                style: FlutterFlowTheme.of(
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
                                                      letterSpacing: 0.0,
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
                                              ),
                                              Text(
                                                getJsonField(
                                                  tableDataItem,
                                                  r'''$.full_name''',
                                                ).toString(),
                                                style: FlutterFlowTheme.of(
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
                                                      letterSpacing: 0.0,
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
                                              ),
                                              Text(
                                                valueOrDefault<String>(
                                                  dateTimeFormat(
                                                    "MM/dd/yy",
                                                    functions
                                                        .returnDT(getJsonField(
                                                      tableDataItem,
                                                      r'''$.dob''',
                                                    ).toString()),
                                                    locale: FFLocalizations.of(
                                                            context)
                                                        .languageCode,
                                                  ),
                                                  '[MM/dd/yy]',
                                                ),
                                                textAlign: TextAlign.center,
                                                style: FlutterFlowTheme.of(
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
                                                      letterSpacing: 0.0,
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
                                              ),
                                              Text(
                                                getJsonField(
                                                  tableDataItem,
                                                  r'''$.clinic_name''',
                                                ).toString(),
                                                textAlign: TextAlign.start,
                                                style: FlutterFlowTheme.of(
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
                                                      letterSpacing: 0.0,
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
                                              ),
                                              Text(
                                                getJsonField(
                                                  tableDataItem,
                                                  r'''$.ccm_status_value''',
                                                ).toString(),
                                                textAlign: TextAlign.center,
                                                style: FlutterFlowTheme.of(
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
                                                      letterSpacing: 0.0,
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
                                              ),
                                              Text(
                                                getJsonField(
                                                  tableDataItem,
                                                  r'''$.rpm_status_value''',
                                                ).toString(),
                                                textAlign: TextAlign.center,
                                                style: FlutterFlowTheme.of(
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
                                                      letterSpacing: 0.0,
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
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            1.0, 0.0),
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  10.0,
                                                                  0.0,
                                                                  0.0,
                                                                  0.0),
                                                      child:
                                                          FlutterFlowIconButton(
                                                        borderColor:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .tertiary,
                                                        borderRadius: 20.0,
                                                        borderWidth: 1.0,
                                                        buttonSize: 38.0,
                                                        fillColor:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .secondary,
                                                        icon: Icon(
                                                          Icons.open_in_new,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .tertiary,
                                                          size: 22.0,
                                                        ),
                                                        onPressed: () async {
                                                          FFAppState()
                                                              .clearPatientDetailsCacheCache();
                                                          FFAppState()
                                                              .clearFacilityListCache();
                                                          FFAppState()
                                                              .clearApptDateCache();
                                                          FFAppState()
                                                                  .isDetailsSaved =
                                                              true;
                                                          safeSetState(() {});
                                                          FFAppState()
                                                                  .timerState =
                                                              FFAppState()
                                                                  .timerState;
                                                          safeSetState(() {});
                                                          FFAppState()
                                                                  .timerState =
                                                              _model
                                                                  .sessionTimerMilliseconds;
                                                          safeSetState(() {});
                                                          _model
                                                              .sessionTimerController
                                                              .onStopTimer();
                                                          FFAppState()
                                                                  .isPaused =
                                                              !(FFAppState()
                                                                      .isPaused ??
                                                                  true);
                                                          safeSetState(() {});
                                                          if (_model
                                                              .instantTimer
                                                              .isActive) {
                                                            _model.instantTimer
                                                                ?.cancel();
                                                          } else {
                                                            _model.instantTimer
                                                                ?.cancel();
                                                          }

                                                          context.goNamed(
                                                            CSPatientDetailWidget
                                                                .routeName,
                                                            queryParameters: {
                                                              'patientClinicDataID':
                                                                  serializeParam(
                                                                getJsonField(
                                                                  tableDataItem,
                                                                  r'''$.patient_clinic_data_id''',
                                                                ),
                                                                ParamType.int,
                                                              ),
                                                              'clinicID':
                                                                  serializeParam(
                                                                getJsonField(
                                                                  tableDataItem,
                                                                  r'''$.clinic_id''',
                                                                ),
                                                                ParamType.int,
                                                              ),
                                                              'cSScreenType':
                                                                  serializeParam(
                                                                CSScreenType
                                                                    .FollowUpList,
                                                                ParamType.Enum,
                                                              ),
                                                            }.withoutNulls,
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ].map((c) => DataCell(c)).toList(),
                                          ),
                                          onPageChanged:
                                              (currentRowIndex) async {
                                            FFAppState().csTableRowIndex =
                                                currentRowIndex;
                                            safeSetState(() {});
                                          },
                                          onRowsPerPageChanged:
                                              (rowsPerPage) async {
                                            FFAppState().csTableRowCount =
                                                rowsPerPage;
                                            safeSetState(() {});
                                          },
                                          paginated: true,
                                          selectable: false,
                                          hidePaginator: false,
                                          showFirstLastButtons: false,
                                          width:
                                              MediaQuery.sizeOf(context).width *
                                                  1.0,
                                          headingRowHeight: 56.0,
                                          dataRowHeight: 48.0,
                                          columnSpacing: 1.0,
                                          headingRowColor:
                                              FlutterFlowTheme.of(context)
                                                  .primary,
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          addHorizontalDivider: true,
                                          addTopAndBottomDivider: false,
                                          hideDefaultHorizontalDivider: true,
                                          horizontalDividerColor:
                                              FlutterFlowTheme.of(context)
                                                  .alternateRow,
                                          horizontalDividerThickness: 1.0,
                                          addVerticalDivider: false,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              if (!(_model.csFollowUpPatientListFiltered
                                      .isNotEmpty) &&
                                  (FFAppState().filterApplied == true))
                                Align(
                                  alignment: AlignmentDirectional(0.0, 0.0),
                                  child: Text(
                                    'No Patient Found!',
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
                                          fontSize: 32.0,
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
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
