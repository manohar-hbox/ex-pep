import 'package:patient_enrollment_program/custom_code/services/twilio_client_manager.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_checkbox_group.dart';
import '/flutter_flow/flutter_flow_data_table.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_radio_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_timer.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/flutter_flow/instant_timer.dart';
import '/main/components/call_patient/call_patient_widget.dart';
import '/main/components/comment_card/comment_card_widget.dart';
import '/main/components/send_s_m_s/send_s_m_s_widget.dart';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/flutter_flow/random_data_util.dart' as random_data;
import '/index.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'v_p_e_dashboard_model.dart';
export 'v_p_e_dashboard_model.dart';

class VPEDashboardWidget extends StatefulWidget {
  const VPEDashboardWidget({super.key});

  static String routeName = 'VPEDashboard';
  static String routePath = 'VPEDashboard';

  @override
  State<VPEDashboardWidget> createState() => _VPEDashboardWidgetState();
}

class _VPEDashboardWidgetState extends State<VPEDashboardWidget> {
  late VPEDashboardModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => VPEDashboardModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 500));
      await actions.checkAndStoreRedirectURL();
      await actions.loadHasuraAndLoginToken();
      if (FFAppState().loginToken != '') {
        _model.createPatientTimeButtonVPELog =
            await PEPAPIsGroup.createPatientTimerLogCall.call(
          userId: FFAppState().loginProfileID,
          authToken: FFAppState().loginToken,
          pepPatientId: FFAppState().currentPatient,
        );

        if ((_model.createPatientTimeButtonVPELog?.succeeded ?? true)) {
          _model.patientTimerLogId = PEPAPIsGroup.createPatientTimerLogCall
              .timeLogId(
                (_model.createPatientTimeButtonVPELog?.jsonBody ?? ''),
              )
              ?.toString();
          safeSetState(() {});
        }
        _model.sessionTimerController2.onStartTimer();
        _model.sessionTimerController1.timer.setPresetTime(
          mSec: FFAppState().timerState,
          add: false,
        );
        _model.sessionTimerController1.onResetTimer();

        _model.sessionTimerController1.onStartTimer();
        _model.enrollementSpecialist = await GQLgetByFunctionCall.call(
          hasuraToken: FFAppState().hasuraToken,
          requestBody: functions
              .checkVpeForDeferredPatients(
                  (int.parse(FFAppState().loginProfileID)).toString())
              .toString(),
        );

        // Initialization Twilio for Inbound and Outbound Calls
        final twilioClientManager = TwilioClientManager();
        String identity = FFAppState().loginEmail;  // This should come from your user's session

        // Register to receive incoming calls
        final success = await twilioClientManager.registerForIncomingCalls(identity, true);

        if (success) {
          print("Ready to receive incoming calls");
        } else {
          print("Failed to register for incoming calls");
        }

        _model.checkTaskAssigned = getJsonField(
          (_model.enrollementSpecialist?.jsonBody ?? ''),
          r'''$.data.pep_vw_enrollment_specialists[:].deferred_task''',
        );
        _model.isTransferPatientExecuted = false;
        safeSetState(() {});
        _model.getAssignedGroups = await GQLgetByFunctionCall.call(
          hasuraToken: FFAppState().hasuraToken,
          requestBody: functions
              .getAssignedGroups(int.parse(FFAppState().loginProfileID))
              .toString(),
        );

        await Future.delayed(const Duration(milliseconds: 500));
        if (GQLgetByFunctionCall.assignedGroupList(
              (_model.getAssignedGroups?.jsonBody ?? ''),
            )?.length !=
            0) {
          _model.selectGroupSeen = true;
          _model.transferredPatientId = null;
          _model.isTransferPatientExecuted = false;
          safeSetState(() {});
          FFAppState().transferPatient = false;
          safeSetState(() {});
          FFAppState().clearCanCallCache();
        } else {
          FFAppState().noPatientsAvailable = true;
          safeSetState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'No Patients Available',
                style: TextStyle(
                  color: FlutterFlowTheme.of(context).primaryText,
                ),
              ),
              duration: Duration(milliseconds: 4000),
              backgroundColor: FlutterFlowTheme.of(context).secondary,
            ),
          );

          context.goNamed(VPEDashboardWidget.routeName);
        }

        FFAppState().isPaused = true;
        safeSetState(() {});
        if (FFAppState().redirectURL != '') {
          await actions.redirectToURL(
            context,
          );
          FFAppState().deleteRedirectURL();
          FFAppState().redirectURL = '';

          safeSetState(() {});
        }
        _model.instantTimer = InstantTimer.periodic(
          duration: Duration(milliseconds: 1000),
          callback: (timer) async {
            _model.isTabMinimized = await actions.isTabMinimized();
            if (_model.isTabMinimized!) {
              FFAppState().timerState = FFAppState().timerState;
              safeSetState(() {});
              _model.patientTimerState = _model.patientTimerState;
              safeSetState(() {});
              FFAppState().isAppMinimized = true;
              safeSetState(() {});
              _model.sessionTimerController1.onStopTimer();
              _model.sessionTimerController2.onStopTimer();
              FFAppState().isPaused = true;
              safeSetState(() {});
            } else {
              _model.sessionTimerController1.onStartTimer();
              _model.sessionTimerController2.onStartTimer();
              if (((_model.sessionTimerMilliseconds1 ~/ 1000) % 60) == 0) {
                _model.updateTimerPlayButtonVPE =
                    await PEPAPIsGroup.updateTimerLogCall.call(
                  duration: _model.sessionTimerMilliseconds1 ~/ 1000,
                  userId: FFAppState().loginProfileID,
                  timelogId: FFAppState().timerlogId,
                  authToken: FFAppState().loginToken,
                );

                FFAppState().timerState = FFAppState().timerState;
                safeSetState(() {});
              } else if ((((_model.sessionTimerMilliseconds2 ~/ 1000) % 60) ==
                      0) &&
                  (FFAppState().isDetailsSaved == false)) {
                _model.updatePatientTimerPlayButtonVPE =
                    await PEPAPIsGroup.updatePatientTimerLogCall.call(
                  duration: _model.sessionTimerMilliseconds2 ~/ 1000,
                  userId: FFAppState().loginProfileID,
                  timelogId: _model.patientTimerLogId,
                  authToken: FFAppState().loginToken,
                  pepPatientId: FFAppState().currentPatient,
                );

                _model.patientTimerState = _model.patientTimerState;
                safeSetState(() {});
              }

              FFAppState().isAppMinimized = false;
              safeSetState(() {});
              FFAppState().isPaused = false;
              safeSetState(() {});
            }
          },
          startImmediately: false,
        );
      } else {
        context.goNamed(LoginWidget.routeName);
      }
    });

    _model.textFieldFocusNode1 ??= FocusNode();

    _model.textFieldFocusNode2 ??= FocusNode();

    _model.tfMobileNumberFocusNode ??= FocusNode();

    _model.tfHomeNumberFocusNode ??= FocusNode();

    _model.textFieldFocusNode3 ??= FocusNode();

    _model.textFieldFocusNode4 ??= FocusNode();

    _model.textFieldFocusNode5 ??= FocusNode();

    _model.textFieldFocusNode6 ??= FocusNode();

    _model.textFieldFocusNode7 ??= FocusNode();

    _model.textFieldFocusNode8 ??= FocusNode();

    _model.textFieldFocusNode9 ??= FocusNode();

    _model.textFieldFocusNode10 ??= FocusNode();

    _model.textFieldFocusNode11 ??= FocusNode();

    _model.commentTextController ??= TextEditingController();
    _model.commentFocusNode ??= FocusNode();

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

    return Title(
        title: 'VPE: Dashboard',
        color: FlutterFlowTheme.of(context).primary.withAlpha(0XFF),
        child: GestureDetector(
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
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 8.0, 0.0, 0.0),
                            child: Text(
                              'Virtual Patient Enroller (VPE)',
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
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
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
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 16.0, 0.0),
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
                                                FFAppState().timerState;
                                            safeSetState(() {});
                                            FFAppState().timerState = _model
                                                .sessionTimerMilliseconds1;
                                            safeSetState(() {});
                                            _model.patientTimerState =
                                                _model.patientTimerState;
                                            safeSetState(() {});
                                            _model.patientTimerState = _model
                                                .sessionTimerMilliseconds2;
                                            safeSetState(() {});
                                            _model.sessionTimerController1
                                                .onStopTimer();
                                            _model.sessionTimerController2
                                                .onStopTimer();
                                            FFAppState().isPaused =
                                                !(FFAppState().isPaused ??
                                                    true);
                                            safeSetState(() {});
                                            if (_model.instantTimer.isActive) {
                                              _model.instantTimer?.cancel();
                                            } else {
                                              _model.instantTimerNested
                                                  ?.cancel();
                                              _model.patientInstantTimerNested
                                                  ?.cancel();
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
                                            _model.patientTimerState =
                                                _model.patientTimerState;
                                            safeSetState(() {});
                                            _model.sessionTimerController1
                                                .onStartTimer();
                                            _model.sessionTimerController2
                                                .onStartTimer();
                                            FFAppState().isPaused =
                                                !(FFAppState().isPaused ??
                                                    true);
                                            safeSetState(() {});
                                            if (!_model.instantTimer.isActive) {
                                              _model.instantTimerNested =
                                                  InstantTimer.periodic(
                                                duration: Duration(
                                                    milliseconds: 1000),
                                                callback: (timer) async {
                                                  _model.isTabMinimizedNested =
                                                      await actions
                                                          .isTabMinimized();
                                                  if (_model
                                                      .isTabMinimizedNested!) {
                                                    FFAppState().timerState =
                                                        FFAppState().timerState;
                                                    safeSetState(() {});
                                                    _model.patientTimerState =
                                                        _model
                                                            .patientTimerState;
                                                    safeSetState(() {});
                                                    FFAppState()
                                                        .isAppMinimized = true;
                                                    safeSetState(() {});
                                                    _model
                                                        .sessionTimerController1
                                                        .onStopTimer();
                                                    _model
                                                        .sessionTimerController2
                                                        .onStopTimer();
                                                    FFAppState().isPaused =
                                                        true;
                                                    safeSetState(() {});
                                                  } else {
                                                    _model
                                                        .sessionTimerController1
                                                        .onStartTimer();
                                                    _model
                                                        .sessionTimerController2
                                                        .onStartTimer();
                                                    if (((_model.sessionTimerMilliseconds1 ~/
                                                                1000) %
                                                            60) ==
                                                        0) {
                                                      _model.updateMainTimerVPE =
                                                          await PEPAPIsGroup
                                                              .updateTimerLogCall
                                                              .call(
                                                        duration: _model
                                                                .sessionTimerMilliseconds1 ~/
                                                            1000,
                                                        userId: FFAppState()
                                                            .loginProfileID,
                                                        timelogId: FFAppState()
                                                            .timerlogId,
                                                        authToken: FFAppState()
                                                            .loginToken,
                                                      );

                                                      FFAppState().timerState =
                                                          FFAppState()
                                                              .timerState;
                                                      safeSetState(() {});
                                                    } else if (((_model
                                                                    .sessionTimerMilliseconds2 ~/
                                                                1000) %
                                                            60) ==
                                                        0) {
                                                      _model.updatePatientTimerVPE =
                                                          await PEPAPIsGroup
                                                              .updatePatientTimerLogCall
                                                              .call(
                                                        duration: _model
                                                                .sessionTimerMilliseconds2 ~/
                                                            1000,
                                                        userId: FFAppState()
                                                            .loginProfileID,
                                                        authToken: FFAppState()
                                                            .loginToken,
                                                        timelogId: _model
                                                            .patientTimerLogId,
                                                        pepPatientId:
                                                            FFAppState()
                                                                .currentPatient,
                                                      );

                                                      _model.patientTimerState =
                                                          _model
                                                              .patientTimerState;
                                                      safeSetState(() {});
                                                    }

                                                    FFAppState()
                                                        .isAppMinimized = false;
                                                    safeSetState(() {});
                                                    FFAppState().isPaused =
                                                        false;
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
                                    initialTime:
                                        _model.sessionTimerInitialTimeMs1,
                                    getDisplayTime: (value) =>
                                        StopWatchTimer.getDisplayTime(
                                      value,
                                      hours: false,
                                      milliSecond: false,
                                    ),
                                    controller: _model.sessionTimerController1,
                                    updateStateInterval:
                                        Duration(milliseconds: 1000),
                                    onChanged:
                                        (value, displayTime, shouldUpdate) {
                                      _model.sessionTimerMilliseconds1 = value;
                                      _model.sessionTimerValue1 = displayTime;
                                      if (shouldUpdate) safeSetState(() {});
                                    },
                                    onEnded: () async {
                                      _model.sessionTimerController1
                                          .onStartTimer();
                                    },
                                    textAlign: TextAlign.start,
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context)
                                              .secondary,
                                          fontSize: 18.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
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
                                      content: Text(FFAppState()
                                              .isPatientCallInProgress
                                          ? 'The call is still in progress. Do you still want to sign out?'
                                          : 'Are you sure you want to sign out?'),
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
                              await PEPAPIsGroup.unlockPatientCall.call(
                                authToken: FFAppState().loginToken,
                                loginID:
                                    int.parse(FFAppState().loginProfileID),
                                patientClinicDataID:
                                    FFAppState().currentPatient,
                              );
                                                          FFAppState().deleteLoginToken();
                              FFAppState().loginToken = '';

                              FFAppState().deleteLoginEmail();
                              FFAppState().loginEmail = '';

                              FFAppState().deleteHasuraToken();
                              FFAppState().hasuraToken = '';

                              FFAppState().deleteLoginProfileID();
                              FFAppState().loginProfileID = '';

                              FFAppState().deleteTwilioCallData();
                              FFAppState().twilioCallData =
                                  TwilioCallDataStruct.fromSerializableMap(
                                      jsonDecode(
                                          '{\"originNumberType\":\"goulb\"}'));

                              FFAppState().deleteIsPatientCallInProgress();
                              FFAppState().isPatientCallInProgress = false;

                              safeSetState(() {});
                              FFAppState().timerState = FFAppState().timerState;
                              safeSetState(() {});
                              FFAppState().timerState =
                                  _model.sessionTimerMilliseconds1;
                              safeSetState(() {});
                              _model.patientTimerState =
                                  _model.patientTimerState;
                              safeSetState(() {});
                              _model.patientTimerState =
                                  _model.sessionTimerMilliseconds2;
                              safeSetState(() {});
                              _model.sessionTimerController1.onResetTimer();

                              if (_model.instantTimerNested.isActive) {
                                _model.instantTimer?.cancel();
                              } else {
                                _model.instantTimerNested?.cancel();
                                _model.patientInstantTimerNested?.cancel();
                              }

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
                            iconPadding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
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
                                  color:
                                      FlutterFlowTheme.of(context).buttonText,
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
              child: Stack(
                children: [
                  if (!FFAppState().noPatientsAvailable)
                    Align(
                      alignment: AlignmentDirectional(0.0, 0.0),
                      child: FutureBuilder<ApiCallResponse>(
                        future: FFAppState().vpePatientDetailsCache(
                          requestFn: () => GQLgetByFunctionCall.call(
                            hasuraToken: FFAppState().hasuraToken,
                            requestBody: functions
                                .getPatientDetails(FFAppState().currentPatient)
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
                          final mainContainerGQLgetByFunctionResponse =
                              snapshot.data!;

                          return Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              borderRadius: BorderRadius.circular(0.0),
                              shape: BoxShape.rectangle,
                              border: Border.all(
                                color: FlutterFlowTheme.of(context).secondary,
                                width: 1.0,
                              ),
                            ),
                            child: Stack(
                              children: [
                                Align(
                                  alignment: AlignmentDirectional(0.0, 0.0),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        20.0, 0.0, 20.0, 0.0),
                                    child: ListView(
                                      padding: EdgeInsets.zero,
                                      scrollDirection: Axis.vertical,
                                      children: [
                                        Container(
                                          width:
                                              MediaQuery.sizeOf(context).width *
                                                  0.5,
                                          decoration: BoxDecoration(),
                                          child: Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0.0, 10.0, 0.0, 0.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                if (FFAppState()
                                                        .isDetailsSaved ==
                                                    false)
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      if (_model
                                                              .selectGroupSeen ??
                                                          true)
                                                        Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      20.0,
                                                                      0.0,
                                                                      0.0,
                                                                      0.0),
                                                          child: Text(
                                                            'Select Group:',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .poppins(
                                                                    fontWeight: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontWeight,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                                  ),
                                                                  fontSize:
                                                                      16.0,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                                ),
                                                          ),
                                                        ),
                                                      if (_model
                                                              .selectGroupSeen ??
                                                          true)
                                                        Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      20.0,
                                                                      0.0,
                                                                      0.0,
                                                                      0.0),
                                                          child:
                                                              FlutterFlowDropDown<
                                                                  int>(
                                                            controller: _model
                                                                    .groupValueController ??=
                                                                FormFieldController<
                                                                    int>(
                                                              _model.groupValue ??=
                                                                  FFAppState()
                                                                      .currentPatientGroupID,
                                                            ),
                                                            options: List<
                                                                    int>.from(
                                                                getJsonField(
                                                                          (_model.getAssignedGroups?.jsonBody ??
                                                                              ''),
                                                                          r'''$.data.pep_vw_patient_list[:].group_id''',
                                                                        ) !=
                                                                        null
                                                                    ? getJsonField(
                                                                        (_model.getAssignedGroups?.jsonBody ??
                                                                            ''),
                                                                        r'''$.data.pep_vw_patient_list[:].group_id''',
                                                                        true,
                                                                      )!
                                                                    : List.generate(
                                                                        random_data.randomInteger(
                                                                            5,
                                                                            5),
                                                                        (index) => random_data.randomInteger(
                                                                            0,
                                                                            10))),
                                                            optionLabels: getJsonField(
                                                                      (_model.getAssignedGroups
                                                                              ?.jsonBody ??
                                                                          ''),
                                                                      r'''$.data.pep_vw_patient_list[:].group_name''',
                                                                    ) !=
                                                                    null
                                                                ? (getJsonField(
                                                                    (_model.getAssignedGroups
                                                                            ?.jsonBody ??
                                                                        ''),
                                                                    r'''$.data.pep_vw_patient_list[:].group_name''',
                                                                    true,
                                                                  ) as List)
                                                                    .map<String>((s) => s.toString())
                                                                    .toList()
                                                                : List.generate(
                                                                    random_data.randomInteger(5, 5),
                                                                    (index) => random_data.randomString(
                                                                          0,
                                                                          0,
                                                                          true,
                                                                          false,
                                                                          false,
                                                                        )),
                                                            onChanged:
                                                                (val) async {
                                                              safeSetState(() =>
                                                                  _model.groupValue =
                                                                      val);
                                                              FFAppState()
                                                                      .searchByAssignedGroupID =
                                                                  _model
                                                                      .groupValue!;
                                                              safeSetState(
                                                                  () {});
                                                              _model.nextPatientByGroup =
                                                                  await GQLgetByFunctionCall
                                                                      .call(
                                                                hasuraToken:
                                                                    FFAppState()
                                                                        .hasuraToken,
                                                                requestBody: functions
                                                                    .getNextPatientInGroup(
                                                                        int.parse(FFAppState()
                                                                            .loginProfileID),
                                                                        FFAppState()
                                                                            .searchByAssignedGroupID)
                                                                    .toString(),
                                                              );

                                                              if (GQLgetByFunctionCall
                                                                      .currentPatient(
                                                                    (_model.nextPatientByGroup
                                                                            ?.jsonBody ??
                                                                        ''),
                                                                  ) !=
                                                                  null) {
                                                                await PEPAPIsGroup
                                                                    .unlockPatientCall
                                                                    .call(
                                                                  authToken:
                                                                      FFAppState()
                                                                          .loginToken,
                                                                  loginID: int.parse(
                                                                      FFAppState()
                                                                          .loginProfileID),
                                                                  patientClinicDataID:
                                                                      FFAppState()
                                                                          .currentPatient,
                                                                );
                                                                                                                              FFAppState()
                                                                        .currentPatient =
                                                                    GQLgetByFunctionCall
                                                                        .currentPatient(
                                                                  (_model.nextPatientByGroup
                                                                          ?.jsonBody ??
                                                                      ''),
                                                                )!;
                                                                FFAppState()
                                                                        .currentPatientGroupID =
                                                                    GQLgetByFunctionCall
                                                                        .currentPatientGroupID(
                                                                  (_model.nextPatientByGroup
                                                                          ?.jsonBody ??
                                                                      ''),
                                                                )!;
                                                                safeSetState(
                                                                    () {});
                                                                await PEPAPIsGroup
                                                                    .lockPatientByGroupCall
                                                                    .call(
                                                                  loginID: int.parse(
                                                                      FFAppState()
                                                                          .loginProfileID),
                                                                  authToken:
                                                                      FFAppState()
                                                                          .loginToken,
                                                                  groupId:
                                                                      FFAppState()
                                                                          .currentPatientGroupID,
                                                                );

                                                                FFAppState()
                                                                    .clearPatientDetailsCacheCache();
                                                                FFAppState()
                                                                    .clearCcmStatusUpdatesVPECache();
                                                                _model.selectGroupSeen =
                                                                    false;
                                                                safeSetState(
                                                                    () {});

                                                                context.goNamed(
                                                                  ReloadPageWidget
                                                                      .routeName,
                                                                  queryParameters:
                                                                      {
                                                                    'vpeReload':
                                                                        serializeParam(
                                                                      true,
                                                                      ParamType
                                                                          .bool,
                                                                    ),
                                                                  }.withoutNulls,
                                                                  extra: <String,
                                                                      dynamic>{
                                                                    kTransitionInfoKey:
                                                                        TransitionInfo(
                                                                      hasTransition:
                                                                          true,
                                                                      transitionType:
                                                                          PageTransitionType
                                                                              .fade,
                                                                      duration: Duration(
                                                                          milliseconds:
                                                                              100),
                                                                    ),
                                                                  },
                                                                );
                                                              } else {
                                                                FFAppState()
                                                                        .noPatientsAvailable =
                                                                    true;
                                                                safeSetState(
                                                                    () {});

                                                                context.goNamed(
                                                                    VPEDashboardWidget
                                                                        .routeName);
                                                              }

                                                              safeSetState(
                                                                  () {});
                                                            },
                                                            width: 400.0,
                                                            height: 56.0,
                                                            textStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      font: GoogleFonts
                                                                          .poppins(
                                                                        fontWeight: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontWeight,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontStyle,
                                                                      ),
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontStyle,
                                                                    ),
                                                            hintText:
                                                                'Select Group',
                                                            icon: Icon(
                                                              Icons
                                                                  .keyboard_arrow_down_rounded,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .secondaryText,
                                                              size: 24.0,
                                                            ),
                                                            fillColor:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .accent1,
                                                            elevation: 2.0,
                                                            borderColor:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .borderColor,
                                                            borderWidth: 2.0,
                                                            borderRadius: 8.0,
                                                            margin:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        16.0,
                                                                        4.0,
                                                                        16.0,
                                                                        4.0),
                                                            hidesUnderline:
                                                                true,
                                                            isOverButton: true,
                                                            isSearchable: false,
                                                            isMultiSelect:
                                                                false,
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          1.0, 0.0),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      if (_model
                                                              .checkTaskAssigned ==
                                                          true)
                                                        Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      0.0,
                                                                      0.0,
                                                                      20.0,
                                                                      0.0),
                                                          child: FFButtonWidget(
                                                            onPressed:
                                                                () async {
                                                              FFAppState()
                                                                      .timerState =
                                                                  FFAppState()
                                                                      .timerState;
                                                              safeSetState(
                                                                  () {});
                                                              _model.patientTimerState =
                                                                  _model
                                                                      .patientTimerState;
                                                              safeSetState(
                                                                  () {});
                                                              FFAppState()
                                                                      .timerState =
                                                                  _model
                                                                      .sessionTimerMilliseconds1;
                                                              safeSetState(
                                                                  () {});
                                                              _model.patientTimerState =
                                                                  _model
                                                                      .sessionTimerMilliseconds2;
                                                              safeSetState(
                                                                  () {});
                                                              _model
                                                                  .sessionTimerController1
                                                                  .onStopTimer();
                                                              _model
                                                                  .sessionTimerController2
                                                                  .onStopTimer();
                                                              FFAppState()
                                                                      .isPaused =
                                                                  !(FFAppState()
                                                                          .isPaused ??
                                                                      true);
                                                              safeSetState(
                                                                  () {});
                                                              if (_model
                                                                  .instantTimer
                                                                  .isActive) {
                                                                _model
                                                                    .instantTimer
                                                                    ?.cancel();
                                                              } else {
                                                                _model
                                                                    .instantTimerNested
                                                                    ?.cancel();
                                                                _model
                                                                    .patientInstantTimerNested
                                                                    ?.cancel();
                                                              }

                                                              _model.deferredResponse =
                                                                  await GQLgetByFunctionCall
                                                                      .call(
                                                                hasuraToken:
                                                                    FFAppState()
                                                                        .hasuraToken,
                                                                requestBody:
                                                                    functions
                                                                        .getDeferredPatientId(),
                                                              );

                                                              FFAppState()
                                                                      .patientID =
                                                                  getJsonField(
                                                                (_model.deferredResponse
                                                                        ?.jsonBody ??
                                                                    ''),
                                                                r'''$.data.pep_vw_vpe_deferred_list[:].pep_patient_clinic_data_id''',
                                                              );
                                                              safeSetState(
                                                                  () {});

                                                              context.goNamed(
                                                                VPEDeferredPatientsWidget
                                                                    .routeName,
                                                                queryParameters:
                                                                    {
                                                                  'patientClinicDataId':
                                                                      serializeParam(
                                                                    FFAppState()
                                                                        .patientID,
                                                                    ParamType
                                                                        .int,
                                                                  ),
                                                                }.withoutNulls,
                                                              );

                                                              safeSetState(
                                                                  () {});
                                                            },
                                                            text:
                                                                'Deferred Patients',
                                                            options:
                                                                FFButtonOptions(
                                                              height: 42.0,
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          16.0,
                                                                          0.0,
                                                                          16.0,
                                                                          0.0),
                                                              iconPadding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          0.0,
                                                                          0.0,
                                                                          0.0),
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .tertiary,
                                                              textStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmall
                                                                      .override(
                                                                        font: GoogleFonts
                                                                            .poppins(
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontStyle,
                                                                        ),
                                                                        color: Colors
                                                                            .white,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        fontWeight: FlutterFlowTheme.of(context)
                                                                            .titleSmall
                                                                            .fontWeight,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .titleSmall
                                                                            .fontStyle,
                                                                      ),
                                                              elevation: 0.0,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12.0),
                                                            ),
                                                          ),
                                                        ),
                                                      InkWell(
                                                        splashColor:
                                                            Colors.transparent,
                                                        focusColor:
                                                            Colors.transparent,
                                                        hoverColor:
                                                            Colors.transparent,
                                                        highlightColor:
                                                            Colors.transparent,
                                                        onTap: () async {
                                                          FFAppState()
                                                                  .timerState =
                                                              FFAppState()
                                                                  .timerState;
                                                          safeSetState(() {});
                                                          FFAppState()
                                                                  .timerState =
                                                              _model
                                                                  .sessionTimerMilliseconds1;
                                                          safeSetState(() {});
                                                          _model.patientTimerState =
                                                              _model
                                                                  .patientTimerState;
                                                          safeSetState(() {});
                                                          _model.patientTimerState =
                                                              _model
                                                                  .sessionTimerMilliseconds2;
                                                          safeSetState(() {});
                                                          _model
                                                              .sessionTimerController1
                                                              .onStopTimer();
                                                          _model
                                                              .sessionTimerController2
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
                                                            _model
                                                                .instantTimerNested
                                                                ?.cancel();
                                                            _model
                                                                .patientInstantTimerNested
                                                                ?.cancel();
                                                          }

                                                          context.goNamed(
                                                              GSListViewWidget
                                                                  .routeName);
                                                        },
                                                        child: Container(
                                                          width: 190.0,
                                                          height: 42.0,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .tertiary,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12.0),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        10.0,
                                                                        0.0,
                                                                        15.0,
                                                                        0.0),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Align(
                                                                  alignment:
                                                                      AlignmentDirectional(
                                                                          -1.0,
                                                                          0.0),
                                                                  child: Icon(
                                                                    Icons
                                                                        .search,
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .buttonText,
                                                                    size: 24.0,
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          10.0,
                                                                          0.0,
                                                                          0.0,
                                                                          0.0),
                                                                  child: Text(
                                                                    'Search Patients',
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.poppins(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).buttonText,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontStyle,
                                                                        ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      if (FFAppState()
                                                              .isDetailsSaved ==
                                                          false)
                                                        Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      10.0,
                                                                      0.0,
                                                                      16.0,
                                                                      0.0),
                                                          child: Container(
                                                            width: 110.0,
                                                            height: 40.0,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .tertiary,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                            ),
                                                            child: Align(
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                      0.0, 0.0),
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  if (!FFAppState()
                                                                      .isPaused)
                                                                    Padding(
                                                                      padding: EdgeInsetsDirectional.fromSTEB(
                                                                          0.0,
                                                                          0.0,
                                                                          4.0,
                                                                          0.0),
                                                                      child:
                                                                          FlutterFlowIconButton(
                                                                        borderColor:
                                                                            Colors.transparent,
                                                                        borderRadius:
                                                                            20.0,
                                                                        buttonSize:
                                                                            40.0,
                                                                        icon:
                                                                            Icon(
                                                                          Icons
                                                                              .pause_sharp,
                                                                          color:
                                                                              FlutterFlowTheme.of(context).secondary,
                                                                          size:
                                                                              24.0,
                                                                        ),
                                                                        onPressed:
                                                                            () async {
                                                                          if (FFAppState().loginToken != '') {
                                                                            FFAppState().timerState =
                                                                                _model.sessionTimerMilliseconds1;
                                                                            safeSetState(() {});
                                                                            _model.patientTimerState =
                                                                                _model.sessionTimerMilliseconds2;
                                                                            safeSetState(() {});
                                                                            FFAppState().timerState =
                                                                                FFAppState().timerState;
                                                                            safeSetState(() {});
                                                                            _model.patientTimerState =
                                                                                _model.patientTimerState;
                                                                            safeSetState(() {});
                                                                            _model.sessionTimerController1.onStopTimer();
                                                                            _model.sessionTimerController2.onStopTimer();
                                                                            FFAppState().isPaused =
                                                                                !(FFAppState().isPaused ?? true);
                                                                            safeSetState(() {});
                                                                            if (_model.instantTimer.isActive) {
                                                                              _model.instantTimer?.cancel();
                                                                            } else {
                                                                              _model.instantTimerNested?.cancel();
                                                                              _model.patientInstantTimerNested?.cancel();
                                                                            }
                                                                          }
                                                                        },
                                                                      ),
                                                                    ),
                                                                  if (FFAppState()
                                                                      .isPaused)
                                                                    Padding(
                                                                      padding: EdgeInsetsDirectional.fromSTEB(
                                                                          0.0,
                                                                          0.0,
                                                                          4.0,
                                                                          0.0),
                                                                      child:
                                                                          FlutterFlowIconButton(
                                                                        borderColor:
                                                                            Colors.transparent,
                                                                        borderRadius:
                                                                            20.0,
                                                                        buttonSize:
                                                                            40.0,
                                                                        icon:
                                                                            Icon(
                                                                          Icons
                                                                              .play_arrow,
                                                                          color:
                                                                              FlutterFlowTheme.of(context).secondary,
                                                                          size:
                                                                              24.0,
                                                                        ),
                                                                        onPressed:
                                                                            () async {
                                                                          if (FFAppState().loginToken != '') {
                                                                            FFAppState().timerState =
                                                                                FFAppState().timerState;
                                                                            safeSetState(() {});
                                                                            _model.patientTimerState =
                                                                                _model.patientTimerState;
                                                                            safeSetState(() {});
                                                                            _model.sessionTimerController2.onStartTimer();
                                                                            _model.sessionTimerController1.onStartTimer();
                                                                            FFAppState().isPaused =
                                                                                !(FFAppState().isPaused ?? true);
                                                                            safeSetState(() {});
                                                                            if (!_model.instantTimer.isActive) {
                                                                              _model.patientInstantTimerNested = InstantTimer.periodic(
                                                                                duration: Duration(milliseconds: 1000),
                                                                                callback: (timer) async {
                                                                                  _model.isTabMinimizedNestedPatient = await actions.isTabMinimized();
                                                                                  if (_model.isTabMinimizedNestedPatient!) {
                                                                                    FFAppState().timerState = FFAppState().timerState;
                                                                                    safeSetState(() {});
                                                                                    _model.patientTimerState = _model.patientTimerState;
                                                                                    safeSetState(() {});
                                                                                    FFAppState().isAppMinimized = true;
                                                                                    safeSetState(() {});
                                                                                    _model.sessionTimerController1.onStopTimer();
                                                                                    _model.sessionTimerController2.onStopTimer();
                                                                                    FFAppState().isPaused = true;
                                                                                    safeSetState(() {});
                                                                                  } else {
                                                                                    _model.sessionTimerController1.onStartTimer();
                                                                                    _model.sessionTimerController2.onStartTimer();
                                                                                    if (((_model.sessionTimerMilliseconds1 ~/ 1000) % 60) == 0) {
                                                                                      _model.updatePlayBtnVpe = await PEPAPIsGroup.updateTimerLogCall.call(
                                                                                        duration: _model.sessionTimerMilliseconds1 ~/ 1000,
                                                                                        userId: FFAppState().loginProfileID,
                                                                                        timelogId: FFAppState().timerlogId,
                                                                                        authToken: FFAppState().loginToken,
                                                                                      );

                                                                                      FFAppState().timerState = FFAppState().timerState;
                                                                                      safeSetState(() {});
                                                                                    } else if ((((_model.sessionTimerMilliseconds2 ~/ 1000) % 60) == 0) && (FFAppState().isDetailsSaved == false)) {
                                                                                      _model.updatePatientTimerPlayBtnVpe = await PEPAPIsGroup.updatePatientTimerLogCall.call(
                                                                                        duration: _model.sessionTimerMilliseconds2 ~/ 1000,
                                                                                        userId: FFAppState().loginProfileID,
                                                                                        timelogId: _model.patientTimerLogId,
                                                                                        pepPatientId: FFAppState().currentPatient,
                                                                                        authToken: FFAppState().loginToken,
                                                                                      );

                                                                                      _model.patientTimerState = _model.patientTimerState;
                                                                                      safeSetState(() {});
                                                                                    }

                                                                                    FFAppState().isAppMinimized = false;
                                                                                    safeSetState(() {});
                                                                                    FFAppState().isPaused = false;
                                                                                    safeSetState(() {});
                                                                                  }
                                                                                },
                                                                                startImmediately: false,
                                                                              );
                                                                            }
                                                                          }

                                                                          safeSetState(
                                                                              () {});
                                                                        },
                                                                      ),
                                                                    ),
                                                                  FlutterFlowTimer(
                                                                    initialTime:
                                                                        _model
                                                                            .sessionTimerInitialTimeMs2,
                                                                    getDisplayTime:
                                                                        (value) =>
                                                                            StopWatchTimer.getDisplayTime(
                                                                      value,
                                                                      hours:
                                                                          false,
                                                                      milliSecond:
                                                                          false,
                                                                    ),
                                                                    controller:
                                                                        _model
                                                                            .sessionTimerController2,
                                                                    updateStateInterval:
                                                                        Duration(
                                                                            milliseconds:
                                                                                1000),
                                                                    onChanged: (value,
                                                                        displayTime,
                                                                        shouldUpdate) {
                                                                      _model.sessionTimerMilliseconds2 =
                                                                          value;
                                                                      _model.sessionTimerValue2 =
                                                                          displayTime;
                                                                      if (shouldUpdate)
                                                                        safeSetState(
                                                                            () {});
                                                                    },
                                                                    onEnded:
                                                                        () async {
                                                                      _model
                                                                          .sessionTimerController2
                                                                          .onStartTimer();
                                                                    },
                                                                    textAlign:
                                                                        TextAlign
                                                                            .start,
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.poppins(
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).secondary,
                                                                          fontSize:
                                                                              18.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight:
                                                                              FontWeight.w600,
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
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Align(
                                          alignment:
                                              AlignmentDirectional(0.0, 0.0),
                                          child: Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0.0, 12.0, 0.0, 0.0),
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            -1.0, 0.0),
                                                    child: Container(
                                                      width: MediaQuery.sizeOf(
                                                                  context)
                                                              .width *
                                                          0.47,
                                                      height: 395.0,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(0.0),
                                                        shape:
                                                            BoxShape.rectangle,
                                                      ),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Expanded(
                                                                child: Align(
                                                                  alignment:
                                                                      AlignmentDirectional(
                                                                          0.0,
                                                                          0.0),
                                                                  child:
                                                                      TextFormField(
                                                                    controller:
                                                                        _model.textController1 ??=
                                                                            TextEditingController(
                                                                      text:
                                                                          getJsonField(
                                                                        mainContainerGQLgetByFunctionResponse
                                                                            .jsonBody,
                                                                        r'''$.data.pep_vw_consolidated_data[:].first_name''',
                                                                      ).toString(),
                                                                    ),
                                                                    focusNode:
                                                                        _model
                                                                            .textFieldFocusNode1,
                                                                    autofocus:
                                                                        true,
                                                                    obscureText:
                                                                        false,
                                                                    decoration:
                                                                        InputDecoration(
                                                                      labelText:
                                                                          'First Name',
                                                                      labelStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelMedium
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                            ),
                                                                            color:
                                                                                FlutterFlowTheme.of(context).textColor,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                          ),
                                                                      hintText:
                                                                          'Enter First Name',
                                                                      hintStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelMedium
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                            ),
                                                                            color:
                                                                                FlutterFlowTheme.of(context).textColor,
                                                                            letterSpacing:
                                                                                1.0,
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                          ),
                                                                      enabledBorder:
                                                                          OutlineInputBorder(
                                                                        borderSide:
                                                                            BorderSide(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).borderColor,
                                                                          width:
                                                                              1.0,
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.circular(8.0),
                                                                      ),
                                                                      focusedBorder:
                                                                          OutlineInputBorder(
                                                                        borderSide:
                                                                            BorderSide(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).tertiary,
                                                                          width:
                                                                              1.0,
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.circular(8.0),
                                                                      ),
                                                                      errorBorder:
                                                                          OutlineInputBorder(
                                                                        borderSide:
                                                                            BorderSide(
                                                                          color:
                                                                              Color(0x00000000),
                                                                          width:
                                                                              1.0,
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.circular(8.0),
                                                                      ),
                                                                      focusedErrorBorder:
                                                                          OutlineInputBorder(
                                                                        borderSide:
                                                                            BorderSide(
                                                                          color:
                                                                              Color(0x00000000),
                                                                          width:
                                                                              1.0,
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.circular(8.0),
                                                                      ),
                                                                      filled:
                                                                          true,
                                                                      fillColor:
                                                                          FlutterFlowTheme.of(context)
                                                                              .accent1,
                                                                      contentPadding: EdgeInsetsDirectional.fromSTEB(
                                                                          10.0,
                                                                          0.0,
                                                                          0.0,
                                                                          0.0),
                                                                    ),
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelMedium
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.readexPro(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).textColor,
                                                                          letterSpacing:
                                                                              1.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontStyle,
                                                                        ),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .justify,
                                                                    cursorColor:
                                                                        FlutterFlowTheme.of(context)
                                                                            .tertiary,
                                                                    validator: _model
                                                                        .textController1Validator
                                                                        .asValidator(
                                                                            context),
                                                                  ),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: Align(
                                                                  alignment:
                                                                      AlignmentDirectional(
                                                                          1.0,
                                                                          0.0),
                                                                  child:
                                                                      TextFormField(
                                                                    controller:
                                                                        _model.textController2 ??=
                                                                            TextEditingController(
                                                                      text:
                                                                          getJsonField(
                                                                        mainContainerGQLgetByFunctionResponse
                                                                            .jsonBody,
                                                                        r'''$.data.pep_vw_consolidated_data[:].last_name''',
                                                                      ).toString(),
                                                                    ),
                                                                    focusNode:
                                                                        _model
                                                                            .textFieldFocusNode2,
                                                                    autofocus:
                                                                        true,
                                                                    obscureText:
                                                                        false,
                                                                    decoration:
                                                                        InputDecoration(
                                                                      labelText:
                                                                          'Last Name',
                                                                      labelStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelMedium
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                            ),
                                                                            color:
                                                                                FlutterFlowTheme.of(context).textColor,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                          ),
                                                                      hintText:
                                                                          'Enter Last Name',
                                                                      hintStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelMedium
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                            ),
                                                                            color:
                                                                                FlutterFlowTheme.of(context).textColor,
                                                                            letterSpacing:
                                                                                1.0,
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                          ),
                                                                      enabledBorder:
                                                                          OutlineInputBorder(
                                                                        borderSide:
                                                                            BorderSide(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).borderColor,
                                                                          width:
                                                                              1.0,
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.circular(8.0),
                                                                      ),
                                                                      focusedBorder:
                                                                          OutlineInputBorder(
                                                                        borderSide:
                                                                            BorderSide(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).tertiary,
                                                                          width:
                                                                              1.0,
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.circular(8.0),
                                                                      ),
                                                                      errorBorder:
                                                                          OutlineInputBorder(
                                                                        borderSide:
                                                                            BorderSide(
                                                                          color:
                                                                              Color(0x00000000),
                                                                          width:
                                                                              1.0,
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.circular(8.0),
                                                                      ),
                                                                      focusedErrorBorder:
                                                                          OutlineInputBorder(
                                                                        borderSide:
                                                                            BorderSide(
                                                                          color:
                                                                              Color(0x00000000),
                                                                          width:
                                                                              1.0,
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.circular(8.0),
                                                                      ),
                                                                      filled:
                                                                          true,
                                                                      fillColor:
                                                                          FlutterFlowTheme.of(context)
                                                                              .accent1,
                                                                      contentPadding: EdgeInsetsDirectional.fromSTEB(
                                                                          10.0,
                                                                          0.0,
                                                                          0.0,
                                                                          0.0),
                                                                    ),
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelMedium
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.readexPro(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).textColor,
                                                                          letterSpacing:
                                                                              1.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontStyle,
                                                                        ),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .justify,
                                                                    cursorColor:
                                                                        FlutterFlowTheme.of(context)
                                                                            .tertiary,
                                                                    validator: _model
                                                                        .textController2Validator
                                                                        .asValidator(
                                                                            context),
                                                                  ),
                                                                ),
                                                              ),
                                                            ].divide(SizedBox(
                                                                width: 20.0)),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        0.0,
                                                                        20.0,
                                                                        0.0,
                                                                        0.0),
                                                            child:
                                                                SingleChildScrollView(
                                                              scrollDirection:
                                                                  Axis.horizontal,
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Text(
                                                                        'Date of Birth:',
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                              fontSize: 16.0,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                      ),
                                                                      Text(
                                                                        dateTimeFormat(
                                                                          "MM/dd/yy",
                                                                          functions
                                                                              .returnDT(valueOrDefault<String>(
                                                                            getJsonField(
                                                                              mainContainerGQLgetByFunctionResponse.jsonBody,
                                                                              r'''$.data.pep_vw_consolidated_data[:].dob''',
                                                                            )?.toString(),
                                                                            'N/A',
                                                                          )),
                                                                          locale:
                                                                              FFLocalizations.of(context).languageCode,
                                                                        ),
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                              ),
                                                                              fontSize: 16.0,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                            ),
                                                                      ),
                                                                    ].divide(SizedBox(
                                                                        width:
                                                                            10.0)),
                                                                  ),
                                                                  Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        'Gender: ',
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                              fontSize: 16.0,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                      ),
                                                                      Text(
                                                                        (String
                                                                            gender) {
                                                                          return gender == 'M'
                                                                              ? 'Male'
                                                                              : gender == 'F'
                                                                                  ? 'Female'
                                                                                  : 'Unknown';
                                                                        }(valueOrDefault<
                                                                            String>(
                                                                          getJsonField(
                                                                            mainContainerGQLgetByFunctionResponse.jsonBody,
                                                                            r'''$.data.pep_vw_consolidated_data[:].gender''',
                                                                          )?.toString(),
                                                                          'N/A',
                                                                        )),
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                              ),
                                                                              fontSize: 16.0,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                            ),
                                                                      ),
                                                                    ].divide(SizedBox(
                                                                        width:
                                                                            10.0)),
                                                                  ),
                                                                ].divide(SizedBox(
                                                                    width:
                                                                        20.0)),
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          20.0,
                                                                          0.0,
                                                                          0.0),
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Expanded(
                                                                    child:
                                                                        Align(
                                                                      alignment:
                                                                          AlignmentDirectional(
                                                                              0.0,
                                                                              0.0),
                                                                      child:
                                                                          TextFormField(
                                                                        controller:
                                                                            _model.tfMobileNumberTextController ??=
                                                                                TextEditingController(
                                                                          text: (String?
                                                                              jv) {
                                                                            return jv == "null"
                                                                                ? ""
                                                                                : jv;
                                                                          }(getJsonField(
                                                                            mainContainerGQLgetByFunctionResponse.jsonBody,
                                                                            r'''$.data.pep_vw_consolidated_data[:].mobile_phone_number''',
                                                                          ).toString()),
                                                                        ),
                                                                        focusNode:
                                                                            _model.tfMobileNumberFocusNode,
                                                                        autofocus:
                                                                            true,
                                                                        obscureText:
                                                                            false,
                                                                        decoration:
                                                                            InputDecoration(
                                                                          labelText:
                                                                              'Mobile Number',
                                                                          labelStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .override(
                                                                                font: GoogleFonts.poppins(
                                                                                  fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                ),
                                                                                color: FlutterFlowTheme.of(context).textColor,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                              ),
                                                                          hintText:
                                                                              'Enter Mobile Number',
                                                                          hintStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .override(
                                                                                font: GoogleFonts.poppins(
                                                                                  fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                ),
                                                                                color: FlutterFlowTheme.of(context).textColor,
                                                                                letterSpacing: 1.0,
                                                                                fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                              ),
                                                                          enabledBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide(
                                                                              color: FlutterFlowTheme.of(context).borderColor,
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          focusedBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide(
                                                                              color: FlutterFlowTheme.of(context).tertiary,
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          errorBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide(
                                                                              color: Color(0x00000000),
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          focusedErrorBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide(
                                                                              color: Color(0x00000000),
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          filled:
                                                                              true,
                                                                          fillColor:
                                                                              FlutterFlowTheme.of(context).accent1,
                                                                          contentPadding: EdgeInsetsDirectional.fromSTEB(
                                                                              10.0,
                                                                              0.0,
                                                                              0.0,
                                                                              0.0),
                                                                        ),
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                              ),
                                                                              color: FlutterFlowTheme.of(context).textColor,
                                                                              letterSpacing: 1.0,
                                                                              fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                            ),
                                                                        textAlign:
                                                                            TextAlign.justify,
                                                                        maxLength:
                                                                            12,
                                                                        buildCounter: (context,
                                                                                {required currentLength,
                                                                                required isFocused,
                                                                                maxLength}) =>
                                                                            null,
                                                                        keyboardType:
                                                                            TextInputType.number,
                                                                        cursorColor:
                                                                            FlutterFlowTheme.of(context).tertiary,
                                                                        validator: _model
                                                                            .tfMobileNumberTextControllerValidator
                                                                            .asValidator(context),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  FlutterFlowIconButton(
                                                                    borderColor:
                                                                        FlutterFlowTheme.of(context)
                                                                            .borderColor,
                                                                    borderRadius:
                                                                        20.0,
                                                                    buttonSize:
                                                                        40.0,
                                                                    fillColor: FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondary,
                                                                    icon: Icon(
                                                                      Icons
                                                                          .content_copy,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .textColor,
                                                                      size:
                                                                          20.0,
                                                                    ),
                                                                    onPressed:
                                                                        () async {
                                                                      await Clipboard.setData(ClipboardData(
                                                                          text: _model
                                                                              .tfMobileNumberTextController
                                                                              .text));
                                                                      ScaffoldMessenger.of(
                                                                              context)
                                                                          .showSnackBar(
                                                                        SnackBar(
                                                                          content:
                                                                              Text(
                                                                            'Mobile Number copied to Clipboard ',
                                                                            style:
                                                                                TextStyle(
                                                                              color: FlutterFlowTheme.of(context).primaryText,
                                                                            ),
                                                                          ),
                                                                          duration:
                                                                              Duration(milliseconds: 4000),
                                                                          backgroundColor:
                                                                              FlutterFlowTheme.of(context).secondary,
                                                                        ),
                                                                      );
                                                                    },
                                                                  ),
                                                                  Builder(
                                                                    builder:
                                                                        (context) =>
                                                                            FlutterFlowIconButton(
                                                                      borderColor:
                                                                          FlutterFlowTheme.of(context)
                                                                              .primary,
                                                                      borderRadius:
                                                                          20.0,
                                                                      buttonSize:
                                                                          40.0,
                                                                      fillColor:
                                                                          FlutterFlowTheme.of(context)
                                                                              .secondary,
                                                                      hoverColor:
                                                                          FlutterFlowTheme.of(context)
                                                                              .secondaryBackground,
                                                                      icon:
                                                                          Icon(
                                                                        Icons
                                                                            .sms_outlined,
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .textColor,
                                                                        size:
                                                                            20.0,
                                                                      ),
                                                                      onPressed:
                                                                          () async {
                                                                        await showDialog(
                                                                          context:
                                                                              context,
                                                                          builder:
                                                                              (dialogContext) {
                                                                            return Dialog(
                                                                              elevation: 0,
                                                                              insetPadding: EdgeInsets.zero,
                                                                              backgroundColor: Colors.transparent,
                                                                              alignment: AlignmentDirectional(0.0, 0.0).resolve(Directionality.of(context)),
                                                                              child: GestureDetector(
                                                                                onTap: () {
                                                                                  FocusScope.of(dialogContext).unfocus();
                                                                                  FocusManager.instance.primaryFocus?.unfocus();
                                                                                },
                                                                                child: Container(
                                                                                  height: 620.0,
                                                                                  width: 700.0,
                                                                                  child: SendSMSWidget(
                                                                                    phoneNumber: (String mobilePhoneNumber) {
                                                                                      return mobilePhoneNumber == 'n/a';
                                                                                    }(_model.tfMobileNumberTextController.text)
                                                                                        ? ''
                                                                                        : _model.tfMobileNumberTextController.text,
                                                                                    patientId: FFAppState().currentPatient.toString(),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            );
                                                                          },
                                                                        );
                                                                      },
                                                                    ),
                                                                  ),
                                                                  FutureBuilder<
                                                                      ApiCallResponse>(
                                                                    future: FFAppState()
                                                                        .canCall(
                                                                      requestFn:
                                                                          () =>
                                                                              GQLgetByFunctionCall.call(
                                                                        hasuraToken:
                                                                            FFAppState().hasuraToken,
                                                                        requestBody: functions
                                                                            .getIfClinicCanMakeOutgoingCall(
                                                                                getJsonField(
                                                                                  mainContainerGQLgetByFunctionResponse.jsonBody,
                                                                                  r'''$.data.pep_vw_consolidated_data[:].clinic_id''',
                                                                                ),
                                                                                getJsonField(
                                                                                  mainContainerGQLgetByFunctionResponse.jsonBody,
                                                                                  r'''$.data.pep_vw_consolidated_data[:].state_id''',
                                                                                ))
                                                                            .toString(),
                                                                      ),
                                                                    ),
                                                                    builder:
                                                                        (context,
                                                                            snapshot) {
                                                                      // Customize what your widget looks like when it's loading.
                                                                      if (!snapshot
                                                                          .hasData) {
                                                                        return Center(
                                                                          child:
                                                                              SizedBox(
                                                                            width:
                                                                                50.0,
                                                                            height:
                                                                                50.0,
                                                                            child:
                                                                                CircularProgressIndicator(
                                                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                                                FlutterFlowTheme.of(context).primary,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        );
                                                                      }
                                                                      final callContainerGQLgetByFunctionResponse =
                                                                          snapshot
                                                                              .data!;

                                                                      return Container(
                                                                        decoration:
                                                                            BoxDecoration(),
                                                                        child:
                                                                            Visibility(
                                                                          visible: getJsonField(
                                                                                callContainerGQLgetByFunctionResponse.jsonBody,
                                                                                r'''$.data.api_origin_number_master[:]''',
                                                                              ) !=
                                                                              null,
                                                                          child:
                                                                              Builder(
                                                                            builder: (context) =>
                                                                                FlutterFlowIconButton(
                                                                              borderColor: FlutterFlowTheme.of(context).primary,
                                                                              borderRadius: 20.0,
                                                                              buttonSize: 40.0,
                                                                              fillColor: FlutterFlowTheme.of(context).secondary,
                                                                              hoverColor: FlutterFlowTheme.of(context).secondaryBackground,
                                                                              icon: Icon(
                                                                                Icons.call,
                                                                                color: FlutterFlowTheme.of(context).textColor,
                                                                                size: 20.0,
                                                                              ),
                                                                              onPressed: () async {
                                                                                _model.lisOfOutboundNumbers = await GQLgetByFunctionCall.call(
                                                                                  hasuraToken: FFAppState().hasuraToken,
                                                                                  requestBody: functions
                                                                                      .getIfClinicCanMakeOutgoingCall(
                                                                                          getJsonField(
                                                                                            mainContainerGQLgetByFunctionResponse.jsonBody,
                                                                                            r'''$.data.pep_vw_consolidated_data[:].clinic_id''',
                                                                                          ),
                                                                                          getJsonField(
                                                                                            mainContainerGQLgetByFunctionResponse.jsonBody,
                                                                                            r'''$.data.pep_vw_consolidated_data[:].state_id''',
                                                                                          ))
                                                                                      .toString(),
                                                                                );

                                                                                if (_model.lisOfOutboundNumbers != null) {
                                                                                  _model.listOfProcessedOutboundNo = await actions.getOutboundNumbersFromResponse(
                                                                                    getJsonField(
                                                                                      (_model.lisOfOutboundNumbers?.jsonBody ?? ''),
                                                                                      r'''$.data.api_origin_number_master[:]''',
                                                                                      true,
                                                                                    )!,
                                                                                  );
                                                                                  _model.outboundNumbers = _model.listOfProcessedOutboundNo!.toList().cast<String>();
                                                                                  safeSetState(() {});
                                                                                } else {
                                                                                  _model.outboundNumbers = [
                                                                                    '13026006476',
                                                                                    '17344071713'
                                                                                  ];
                                                                                  safeSetState(() {});
                                                                                }

                                                                                await showDialog(
                                                                                  context: context,
                                                                                  builder: (dialogContext) {
                                                                                    return Dialog(
                                                                                      elevation: 0,
                                                                                      insetPadding: EdgeInsets.zero,
                                                                                      backgroundColor: Colors.transparent,
                                                                                      alignment: AlignmentDirectional(0.0, 0.0).resolve(Directionality.of(context)),
                                                                                      child: GestureDetector(
                                                                                        onTap: () {
                                                                                          FocusScope.of(dialogContext).unfocus();
                                                                                          FocusManager.instance.primaryFocus?.unfocus();
                                                                                        },
                                                                                        child: Container(
                                                                                          height: 400.0,
                                                                                          width: 600.0,
                                                                                          child: CallPatientWidget(
                                                                                            parentContext: context,
                                                                                            primaryPhoneNumber: _model.tfMobileNumberTextController.text,
                                                                                            emergencyPhoneNumber: _model.tfHomeNumberTextController.text,
                                                                                            clinicId: getJsonField(
                                                                                              mainContainerGQLgetByFunctionResponse.jsonBody,
                                                                                              r'''$.data.pep_vw_consolidated_data[:].clinic_id''',
                                                                                            ).toString(),
                                                                                            patientId: FFAppState().currentPatient.toString(),
                                                                                            callerId: FFAppState().loginProfileID,
                                                                                            originNumberType: OriginNumberType.Enrollment.name,
                                                                                            patientFirstName: getJsonField(
                                                                                              mainContainerGQLgetByFunctionResponse.jsonBody,
                                                                                              r'''$.data.pep_vw_consolidated_data[:].first_name''',
                                                                                            ).toString(),
                                                                                            patientLastName: getJsonField(
                                                                                              mainContainerGQLgetByFunctionResponse.jsonBody,
                                                                                              r'''$.data.pep_vw_consolidated_data[:].last_name''',
                                                                                            ).toString(),
                                                                                            patientClinicTimeZone: getJsonField(
                                                                                              mainContainerGQLgetByFunctionResponse.jsonBody,
                                                                                              r'''$.data.pep_vw_consolidated_data[:].patient_clinic_timezone''',
                                                                                            ).toString(),
                                                                                            outboundNumbers: _model.outboundNumbers,
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    );
                                                                                  },
                                                                                );

                                                                                await actions.warnBeforeUnload(
                                                                                  FFAppState().isPatientCallInProgress,
                                                                                );

                                                                                safeSetState(() {});
                                                                              },
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      );
                                                                    },
                                                                  ),
                                                                  Expanded(
                                                                    child:
                                                                        Align(
                                                                      alignment:
                                                                          AlignmentDirectional(
                                                                              1.0,
                                                                              0.0),
                                                                      child:
                                                                          TextFormField(
                                                                        controller:
                                                                            _model.tfHomeNumberTextController ??=
                                                                                TextEditingController(
                                                                          text: (String?
                                                                              jv) {
                                                                            return jv == "null"
                                                                                ? ""
                                                                                : jv;
                                                                          }(getJsonField(
                                                                            mainContainerGQLgetByFunctionResponse.jsonBody,
                                                                            r'''$.data.pep_vw_consolidated_data[:].home_phone_number''',
                                                                          ).toString()),
                                                                        ),
                                                                        focusNode:
                                                                            _model.tfHomeNumberFocusNode,
                                                                        autofocus:
                                                                            true,
                                                                        obscureText:
                                                                            false,
                                                                        decoration:
                                                                            InputDecoration(
                                                                          labelText:
                                                                              'Home Phone Number',
                                                                          labelStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .override(
                                                                                font: GoogleFonts.poppins(
                                                                                  fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                ),
                                                                                color: FlutterFlowTheme.of(context).textColor,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                              ),
                                                                          hintText:
                                                                              'Enter Home Phone Number',
                                                                          hintStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .override(
                                                                                font: GoogleFonts.poppins(
                                                                                  fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                ),
                                                                                color: FlutterFlowTheme.of(context).textColor,
                                                                                letterSpacing: 1.0,
                                                                                fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                              ),
                                                                          enabledBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide(
                                                                              color: FlutterFlowTheme.of(context).borderColor,
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          focusedBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide(
                                                                              color: FlutterFlowTheme.of(context).tertiary,
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          errorBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide(
                                                                              color: Color(0x00000000),
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          focusedErrorBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide(
                                                                              color: Color(0x00000000),
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          filled:
                                                                              true,
                                                                          fillColor:
                                                                              FlutterFlowTheme.of(context).accent1,
                                                                          contentPadding: EdgeInsetsDirectional.fromSTEB(
                                                                              10.0,
                                                                              0.0,
                                                                              0.0,
                                                                              0.0),
                                                                        ),
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                              ),
                                                                              color: FlutterFlowTheme.of(context).textColor,
                                                                              letterSpacing: 1.0,
                                                                              fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                            ),
                                                                        textAlign:
                                                                            TextAlign.justify,
                                                                        maxLength:
                                                                            12,
                                                                        buildCounter: (context,
                                                                                {required currentLength,
                                                                                required isFocused,
                                                                                maxLength}) =>
                                                                            null,
                                                                        keyboardType:
                                                                            TextInputType.number,
                                                                        cursorColor:
                                                                            FlutterFlowTheme.of(context).tertiary,
                                                                        validator: _model
                                                                            .tfHomeNumberTextControllerValidator
                                                                            .asValidator(context),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  FlutterFlowIconButton(
                                                                    borderColor:
                                                                        FlutterFlowTheme.of(context)
                                                                            .borderColor,
                                                                    borderRadius:
                                                                        20.0,
                                                                    buttonSize:
                                                                        40.0,
                                                                    fillColor: FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondary,
                                                                    icon: Icon(
                                                                      Icons
                                                                          .content_copy,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .textColor,
                                                                      size:
                                                                          20.0,
                                                                    ),
                                                                    onPressed:
                                                                        () async {
                                                                      await Clipboard.setData(ClipboardData(
                                                                          text: _model
                                                                              .tfHomeNumberTextController
                                                                              .text));
                                                                      ScaffoldMessenger.of(
                                                                              context)
                                                                          .showSnackBar(
                                                                        SnackBar(
                                                                          content:
                                                                              Text(
                                                                            'Home Number copied to Clipboard ',
                                                                            style:
                                                                                TextStyle(
                                                                              color: FlutterFlowTheme.of(context).primaryText,
                                                                            ),
                                                                          ),
                                                                          duration:
                                                                              Duration(milliseconds: 4000),
                                                                          backgroundColor:
                                                                              FlutterFlowTheme.of(context).secondary,
                                                                        ),
                                                                      );
                                                                    },
                                                                  ),
                                                                ].divide(SizedBox(
                                                                    width:
                                                                        20.0)),
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        0.0,
                                                                        20.0,
                                                                        0.0,
                                                                        0.0),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Expanded(
                                                                  child: Align(
                                                                    alignment:
                                                                        AlignmentDirectional(
                                                                            0.0,
                                                                            0.0),
                                                                    child:
                                                                        TextFormField(
                                                                      controller:
                                                                          _model.textController5 ??=
                                                                              TextEditingController(
                                                                        text: (String?
                                                                            jv) {
                                                                          return jv == "null"
                                                                              ? ""
                                                                              : jv;
                                                                        }(getJsonField(
                                                                          mainContainerGQLgetByFunctionResponse
                                                                              .jsonBody,
                                                                          r'''$.data.pep_vw_consolidated_data[:].email''',
                                                                        ).toString()),
                                                                      ),
                                                                      focusNode:
                                                                          _model
                                                                              .textFieldFocusNode3,
                                                                      autofocus:
                                                                          true,
                                                                      obscureText:
                                                                          false,
                                                                      decoration:
                                                                          InputDecoration(
                                                                        labelText:
                                                                            'Email  Address',
                                                                        labelStyle: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                              ),
                                                                              color: FlutterFlowTheme.of(context).textColor,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                            ),
                                                                        hintText:
                                                                            'Enter Email Address',
                                                                        hintStyle: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                              ),
                                                                              color: FlutterFlowTheme.of(context).textColor,
                                                                              letterSpacing: 1.0,
                                                                              fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                            ),
                                                                        enabledBorder:
                                                                            OutlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).borderColor,
                                                                            width:
                                                                                1.0,
                                                                          ),
                                                                          borderRadius:
                                                                              BorderRadius.circular(8.0),
                                                                        ),
                                                                        focusedBorder:
                                                                            OutlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).tertiary,
                                                                            width:
                                                                                1.0,
                                                                          ),
                                                                          borderRadius:
                                                                              BorderRadius.circular(8.0),
                                                                        ),
                                                                        errorBorder:
                                                                            OutlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(
                                                                            color:
                                                                                Color(0x00000000),
                                                                            width:
                                                                                1.0,
                                                                          ),
                                                                          borderRadius:
                                                                              BorderRadius.circular(8.0),
                                                                        ),
                                                                        focusedErrorBorder:
                                                                            OutlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(
                                                                            color:
                                                                                Color(0x00000000),
                                                                            width:
                                                                                1.0,
                                                                          ),
                                                                          borderRadius:
                                                                              BorderRadius.circular(8.0),
                                                                        ),
                                                                        filled:
                                                                            true,
                                                                        fillColor:
                                                                            FlutterFlowTheme.of(context).accent1,
                                                                        contentPadding: EdgeInsetsDirectional.fromSTEB(
                                                                            10.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                      ),
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelSmall
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FlutterFlowTheme.of(context).labelSmall.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelSmall.fontStyle,
                                                                            ),
                                                                            color:
                                                                                FlutterFlowTheme.of(context).textColor,
                                                                            fontSize:
                                                                                14.0,
                                                                            letterSpacing:
                                                                                1.0,
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelSmall.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelSmall.fontStyle,
                                                                          ),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .justify,
                                                                      keyboardType:
                                                                          TextInputType
                                                                              .emailAddress,
                                                                      cursorColor:
                                                                          FlutterFlowTheme.of(context)
                                                                              .tertiary,
                                                                      validator: _model
                                                                          .textController5Validator
                                                                          .asValidator(
                                                                              context),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        0.0,
                                                                        20.0,
                                                                        0.0,
                                                                        0.0),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Expanded(
                                                                  child: Align(
                                                                    alignment:
                                                                        AlignmentDirectional(
                                                                            0.0,
                                                                            0.0),
                                                                    child:
                                                                        TextFormField(
                                                                      controller:
                                                                          _model.textController6 ??=
                                                                              TextEditingController(
                                                                        text: (String?
                                                                            jv) {
                                                                          return jv == "null"
                                                                              ? ""
                                                                              : jv;
                                                                        }(getJsonField(
                                                                          mainContainerGQLgetByFunctionResponse
                                                                              .jsonBody,
                                                                          r'''$.data.pep_vw_consolidated_data[:].address_line_1''',
                                                                        ).toString()),
                                                                      ),
                                                                      focusNode:
                                                                          _model
                                                                              .textFieldFocusNode4,
                                                                      autofocus:
                                                                          true,
                                                                      obscureText:
                                                                          false,
                                                                      decoration:
                                                                          InputDecoration(
                                                                        labelText:
                                                                            'Address',
                                                                        labelStyle: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                              ),
                                                                              color: FlutterFlowTheme.of(context).textColor,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                            ),
                                                                        hintText:
                                                                            'Enter Address',
                                                                        hintStyle: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                              ),
                                                                              color: FlutterFlowTheme.of(context).textColor,
                                                                              letterSpacing: 1.0,
                                                                              fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                            ),
                                                                        enabledBorder:
                                                                            OutlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).borderColor,
                                                                            width:
                                                                                1.0,
                                                                          ),
                                                                          borderRadius:
                                                                              BorderRadius.circular(8.0),
                                                                        ),
                                                                        focusedBorder:
                                                                            OutlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).tertiary,
                                                                            width:
                                                                                1.0,
                                                                          ),
                                                                          borderRadius:
                                                                              BorderRadius.circular(8.0),
                                                                        ),
                                                                        errorBorder:
                                                                            OutlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(
                                                                            color:
                                                                                Color(0x00000000),
                                                                            width:
                                                                                1.0,
                                                                          ),
                                                                          borderRadius:
                                                                              BorderRadius.circular(8.0),
                                                                        ),
                                                                        focusedErrorBorder:
                                                                            OutlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(
                                                                            color:
                                                                                Color(0x00000000),
                                                                            width:
                                                                                1.0,
                                                                          ),
                                                                          borderRadius:
                                                                              BorderRadius.circular(8.0),
                                                                        ),
                                                                        filled:
                                                                            true,
                                                                        fillColor:
                                                                            FlutterFlowTheme.of(context).accent1,
                                                                        contentPadding: EdgeInsetsDirectional.fromSTEB(
                                                                            10.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                      ),
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelSmall
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FlutterFlowTheme.of(context).labelSmall.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelSmall.fontStyle,
                                                                            ),
                                                                            color:
                                                                                FlutterFlowTheme.of(context).textColor,
                                                                            fontSize:
                                                                                14.0,
                                                                            letterSpacing:
                                                                                1.0,
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelSmall.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelSmall.fontStyle,
                                                                          ),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .justify,
                                                                      maxLength:
                                                                          256,
                                                                      buildCounter: (context,
                                                                              {required currentLength,
                                                                              required isFocused,
                                                                              maxLength}) =>
                                                                          null,
                                                                      cursorColor:
                                                                          FlutterFlowTheme.of(context)
                                                                              .tertiary,
                                                                      validator: _model
                                                                          .textController6Validator
                                                                          .asValidator(
                                                                              context),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        0.0,
                                                                        20.0,
                                                                        0.0,
                                                                        0.0),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Expanded(
                                                                  child: Align(
                                                                    alignment:
                                                                        AlignmentDirectional(
                                                                            0.0,
                                                                            0.0),
                                                                    child:
                                                                        TextFormField(
                                                                      controller:
                                                                          _model.textController7 ??=
                                                                              TextEditingController(
                                                                        text: (String?
                                                                            jv) {
                                                                          return jv == "null"
                                                                              ? ""
                                                                              : jv;
                                                                        }(getJsonField(
                                                                          mainContainerGQLgetByFunctionResponse
                                                                              .jsonBody,
                                                                          r'''$.data.pep_vw_consolidated_data[:].city''',
                                                                        ).toString()),
                                                                      ),
                                                                      focusNode:
                                                                          _model
                                                                              .textFieldFocusNode5,
                                                                      autofocus:
                                                                          true,
                                                                      obscureText:
                                                                          false,
                                                                      decoration:
                                                                          InputDecoration(
                                                                        labelText:
                                                                            'City',
                                                                        labelStyle: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                              ),
                                                                              color: FlutterFlowTheme.of(context).textColor,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                            ),
                                                                        hintText:
                                                                            'Enter City',
                                                                        hintStyle: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                              ),
                                                                              color: FlutterFlowTheme.of(context).textColor,
                                                                              letterSpacing: 1.0,
                                                                              fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                            ),
                                                                        enabledBorder:
                                                                            OutlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).borderColor,
                                                                            width:
                                                                                1.0,
                                                                          ),
                                                                          borderRadius:
                                                                              BorderRadius.circular(8.0),
                                                                        ),
                                                                        focusedBorder:
                                                                            OutlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).tertiary,
                                                                            width:
                                                                                1.0,
                                                                          ),
                                                                          borderRadius:
                                                                              BorderRadius.circular(8.0),
                                                                        ),
                                                                        errorBorder:
                                                                            OutlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(
                                                                            color:
                                                                                Color(0x00000000),
                                                                            width:
                                                                                1.0,
                                                                          ),
                                                                          borderRadius:
                                                                              BorderRadius.circular(8.0),
                                                                        ),
                                                                        focusedErrorBorder:
                                                                            OutlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(
                                                                            color:
                                                                                Color(0x00000000),
                                                                            width:
                                                                                1.0,
                                                                          ),
                                                                          borderRadius:
                                                                              BorderRadius.circular(8.0),
                                                                        ),
                                                                        filled:
                                                                            true,
                                                                        fillColor:
                                                                            FlutterFlowTheme.of(context).accent1,
                                                                        contentPadding: EdgeInsetsDirectional.fromSTEB(
                                                                            10.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                      ),
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelSmall
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FlutterFlowTheme.of(context).labelSmall.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelSmall.fontStyle,
                                                                            ),
                                                                            color:
                                                                                FlutterFlowTheme.of(context).textColor,
                                                                            fontSize:
                                                                                14.0,
                                                                            letterSpacing:
                                                                                1.0,
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelSmall.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelSmall.fontStyle,
                                                                          ),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .justify,
                                                                      maxLength:
                                                                          64,
                                                                      buildCounter: (context,
                                                                              {required currentLength,
                                                                              required isFocused,
                                                                              maxLength}) =>
                                                                          null,
                                                                      cursorColor:
                                                                          FlutterFlowTheme.of(context)
                                                                              .tertiary,
                                                                      validator: _model
                                                                          .textController7Validator
                                                                          .asValidator(
                                                                              context),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child: Align(
                                                                    alignment:
                                                                        AlignmentDirectional(
                                                                            0.0,
                                                                            0.0),
                                                                    child:
                                                                        TextFormField(
                                                                      controller:
                                                                          _model.textController8 ??=
                                                                              TextEditingController(
                                                                        text: (String?
                                                                            jv) {
                                                                          return jv == "null"
                                                                              ? ""
                                                                              : jv;
                                                                        }(getJsonField(
                                                                          mainContainerGQLgetByFunctionResponse
                                                                              .jsonBody,
                                                                          r'''$.data.pep_vw_consolidated_data[:].state''',
                                                                        ).toString()),
                                                                      ),
                                                                      focusNode:
                                                                          _model
                                                                              .textFieldFocusNode6,
                                                                      autofocus:
                                                                          true,
                                                                      obscureText:
                                                                          false,
                                                                      decoration:
                                                                          InputDecoration(
                                                                        labelText:
                                                                            'State',
                                                                        labelStyle: FlutterFlowTheme.of(context)
                                                                            .labelSmall
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FlutterFlowTheme.of(context).labelSmall.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelSmall.fontStyle,
                                                                              ),
                                                                              color: FlutterFlowTheme.of(context).textColor,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FlutterFlowTheme.of(context).labelSmall.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelSmall.fontStyle,
                                                                            ),
                                                                        hintText:
                                                                            'Enter State',
                                                                        hintStyle: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                              ),
                                                                              color: FlutterFlowTheme.of(context).textColor,
                                                                              letterSpacing: 1.0,
                                                                              fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                            ),
                                                                        enabledBorder:
                                                                            OutlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).borderColor,
                                                                            width:
                                                                                1.0,
                                                                          ),
                                                                          borderRadius:
                                                                              BorderRadius.circular(8.0),
                                                                        ),
                                                                        focusedBorder:
                                                                            OutlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).tertiary,
                                                                            width:
                                                                                1.0,
                                                                          ),
                                                                          borderRadius:
                                                                              BorderRadius.circular(8.0),
                                                                        ),
                                                                        errorBorder:
                                                                            OutlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(
                                                                            color:
                                                                                Color(0x00000000),
                                                                            width:
                                                                                1.0,
                                                                          ),
                                                                          borderRadius:
                                                                              BorderRadius.circular(8.0),
                                                                        ),
                                                                        focusedErrorBorder:
                                                                            OutlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(
                                                                            color:
                                                                                Color(0x00000000),
                                                                            width:
                                                                                1.0,
                                                                          ),
                                                                          borderRadius:
                                                                              BorderRadius.circular(8.0),
                                                                        ),
                                                                        filled:
                                                                            true,
                                                                        fillColor:
                                                                            FlutterFlowTheme.of(context).accent1,
                                                                        contentPadding: EdgeInsetsDirectional.fromSTEB(
                                                                            10.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                      ),
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelSmall
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FlutterFlowTheme.of(context).labelSmall.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelSmall.fontStyle,
                                                                            ),
                                                                            color:
                                                                                FlutterFlowTheme.of(context).textColor,
                                                                            fontSize:
                                                                                14.0,
                                                                            letterSpacing:
                                                                                1.0,
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelSmall.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelSmall.fontStyle,
                                                                          ),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .justify,
                                                                      maxLength:
                                                                          2,
                                                                      buildCounter: (context,
                                                                              {required currentLength,
                                                                              required isFocused,
                                                                              maxLength}) =>
                                                                          null,
                                                                      cursorColor:
                                                                          FlutterFlowTheme.of(context)
                                                                              .tertiary,
                                                                      validator: _model
                                                                          .textController8Validator
                                                                          .asValidator(
                                                                              context),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child: Align(
                                                                    alignment:
                                                                        AlignmentDirectional(
                                                                            1.0,
                                                                            0.0),
                                                                    child:
                                                                        TextFormField(
                                                                      controller:
                                                                          _model.textController9 ??=
                                                                              TextEditingController(
                                                                        text: (String?
                                                                            jv) {
                                                                          return jv == "null"
                                                                              ? ""
                                                                              : jv;
                                                                        }(getJsonField(
                                                                          mainContainerGQLgetByFunctionResponse
                                                                              .jsonBody,
                                                                          r'''$.data.pep_vw_consolidated_data[:].zip_code''',
                                                                        ).toString()),
                                                                      ),
                                                                      focusNode:
                                                                          _model
                                                                              .textFieldFocusNode7,
                                                                      autofocus:
                                                                          true,
                                                                      obscureText:
                                                                          false,
                                                                      decoration:
                                                                          InputDecoration(
                                                                        labelText:
                                                                            'Zip Code',
                                                                        labelStyle: FlutterFlowTheme.of(context)
                                                                            .labelSmall
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FlutterFlowTheme.of(context).labelSmall.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelSmall.fontStyle,
                                                                              ),
                                                                              color: FlutterFlowTheme.of(context).textColor,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FlutterFlowTheme.of(context).labelSmall.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelSmall.fontStyle,
                                                                            ),
                                                                        hintText:
                                                                            'Enter Zip Code',
                                                                        hintStyle: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                              ),
                                                                              color: FlutterFlowTheme.of(context).textColor,
                                                                              letterSpacing: 1.0,
                                                                              fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                            ),
                                                                        enabledBorder:
                                                                            OutlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).borderColor,
                                                                            width:
                                                                                1.0,
                                                                          ),
                                                                          borderRadius:
                                                                              BorderRadius.circular(8.0),
                                                                        ),
                                                                        focusedBorder:
                                                                            OutlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).tertiary,
                                                                            width:
                                                                                1.0,
                                                                          ),
                                                                          borderRadius:
                                                                              BorderRadius.circular(8.0),
                                                                        ),
                                                                        errorBorder:
                                                                            OutlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(
                                                                            color:
                                                                                Color(0x00000000),
                                                                            width:
                                                                                1.0,
                                                                          ),
                                                                          borderRadius:
                                                                              BorderRadius.circular(8.0),
                                                                        ),
                                                                        focusedErrorBorder:
                                                                            OutlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(
                                                                            color:
                                                                                Color(0x00000000),
                                                                            width:
                                                                                1.0,
                                                                          ),
                                                                          borderRadius:
                                                                              BorderRadius.circular(8.0),
                                                                        ),
                                                                        filled:
                                                                            true,
                                                                        fillColor:
                                                                            FlutterFlowTheme.of(context).accent1,
                                                                        contentPadding: EdgeInsetsDirectional.fromSTEB(
                                                                            10.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                      ),
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelSmall
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FlutterFlowTheme.of(context).labelSmall.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelSmall.fontStyle,
                                                                            ),
                                                                            color:
                                                                                FlutterFlowTheme.of(context).textColor,
                                                                            fontSize:
                                                                                14.0,
                                                                            letterSpacing:
                                                                                1.0,
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelSmall.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelSmall.fontStyle,
                                                                          ),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .justify,
                                                                      maxLength:
                                                                          10,
                                                                      buildCounter: (context,
                                                                              {required currentLength,
                                                                              required isFocused,
                                                                              maxLength}) =>
                                                                          null,
                                                                      cursorColor:
                                                                          FlutterFlowTheme.of(context)
                                                                              .tertiary,
                                                                      validator: _model
                                                                          .textController9Validator
                                                                          .asValidator(
                                                                              context),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ].divide(SizedBox(
                                                                  width: 20.0)),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            1.0, 0.0),
                                                    child: Container(
                                                      width: MediaQuery.sizeOf(
                                                                  context)
                                                              .width *
                                                          0.47,
                                                      height: 395.0,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          SingleChildScrollView(
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Text(
                                                                      'Clinic Name:',
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                            fontSize:
                                                                                16.0,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                          ),
                                                                    ),
                                                                    Text(
                                                                      getJsonField(
                                                                        mainContainerGQLgetByFunctionResponse
                                                                            .jsonBody,
                                                                        r'''$.data.pep_vw_consolidated_data[:].clinic_name''',
                                                                      ).toString(),
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelMedium
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                            ),
                                                                            fontSize:
                                                                                16.0,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                          ),
                                                                    ),
                                                                  ].divide(SizedBox(
                                                                      width:
                                                                          10.0)),
                                                                ),
                                                                Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    Text(
                                                                      'Provider Name: ',
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                            fontSize:
                                                                                16.0,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                          ),
                                                                    ),
                                                                    Text(
                                                                      valueOrDefault<
                                                                          String>(
                                                                        getJsonField(
                                                                          mainContainerGQLgetByFunctionResponse
                                                                              .jsonBody,
                                                                          r'''$.data.pep_vw_consolidated_data[:].provider_name''',
                                                                        )?.toString(),
                                                                        'N/A',
                                                                      ),
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelMedium
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                            ),
                                                                            fontSize:
                                                                                16.0,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                          ),
                                                                    ),
                                                                  ].divide(SizedBox(
                                                                      width:
                                                                          10.0)),
                                                                ),
                                                              ].divide(SizedBox(
                                                                  width: 20.0)),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        0.0,
                                                                        20.0,
                                                                        0.0,
                                                                        0.0),
                                                            child:
                                                                SingleChildScrollView(
                                                              scrollDirection:
                                                                  Axis.horizontal,
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Text(
                                                                        'Primary Dx:',
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                              fontSize: 16.0,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                      ),
                                                                      Text(
                                                                        valueOrDefault<
                                                                            String>(
                                                                          getJsonField(
                                                                            mainContainerGQLgetByFunctionResponse.jsonBody,
                                                                            r'''$.data.pep_vw_consolidated_data[:].primary_dx''',
                                                                          )?.toString(),
                                                                          'N/A',
                                                                        ),
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                              ),
                                                                              fontSize: 16.0,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                            ),
                                                                      ),
                                                                    ].divide(SizedBox(
                                                                        width:
                                                                            10.0)),
                                                                  ),
                                                                  Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        'Secondary Dx:',
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                              fontSize: 16.0,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                      ),
                                                                      Text(
                                                                        valueOrDefault<
                                                                            String>(
                                                                          getJsonField(
                                                                            mainContainerGQLgetByFunctionResponse.jsonBody,
                                                                            r'''$.data.pep_vw_consolidated_data[:].secondary_dx''',
                                                                          )?.toString(),
                                                                          'N/A',
                                                                        ),
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                              ),
                                                                              fontSize: 16.0,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                            ),
                                                                      ),
                                                                    ].divide(SizedBox(
                                                                        width:
                                                                            10.0)),
                                                                  ),
                                                                ].divide(SizedBox(
                                                                    width:
                                                                        20.0)),
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        0.0,
                                                                        20.0,
                                                                        0.0,
                                                                        0.0),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Expanded(
                                                                  child: Align(
                                                                    alignment:
                                                                        AlignmentDirectional(
                                                                            0.0,
                                                                            0.0),
                                                                    child:
                                                                        TextFormField(
                                                                      controller:
                                                                          _model.textController10 ??=
                                                                              TextEditingController(
                                                                        text: (String?
                                                                            jv) {
                                                                          return jv == "null"
                                                                              ? ""
                                                                              : jv;
                                                                        }(getJsonField(
                                                                          mainContainerGQLgetByFunctionResponse
                                                                              .jsonBody,
                                                                          r'''$.data.pep_vw_consolidated_data[:].primary_insurance_provider''',
                                                                        ).toString()),
                                                                      ),
                                                                      focusNode:
                                                                          _model
                                                                              .textFieldFocusNode8,
                                                                      autofocus:
                                                                          true,
                                                                      obscureText:
                                                                          false,
                                                                      decoration:
                                                                          InputDecoration(
                                                                        labelText:
                                                                            'Primary Insurance Provider',
                                                                        labelStyle: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                              ),
                                                                              color: FlutterFlowTheme.of(context).textColor,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                            ),
                                                                        hintText:
                                                                            'Enter Primary Insurance Provider',
                                                                        hintStyle: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                              ),
                                                                              color: FlutterFlowTheme.of(context).textColor,
                                                                              letterSpacing: 1.0,
                                                                              fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                            ),
                                                                        enabledBorder:
                                                                            OutlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).borderColor,
                                                                            width:
                                                                                1.0,
                                                                          ),
                                                                          borderRadius:
                                                                              BorderRadius.circular(8.0),
                                                                        ),
                                                                        focusedBorder:
                                                                            OutlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).tertiary,
                                                                            width:
                                                                                1.0,
                                                                          ),
                                                                          borderRadius:
                                                                              BorderRadius.circular(8.0),
                                                                        ),
                                                                        errorBorder:
                                                                            OutlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(
                                                                            color:
                                                                                Color(0x00000000),
                                                                            width:
                                                                                1.0,
                                                                          ),
                                                                          borderRadius:
                                                                              BorderRadius.circular(8.0),
                                                                        ),
                                                                        focusedErrorBorder:
                                                                            OutlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(
                                                                            color:
                                                                                Color(0x00000000),
                                                                            width:
                                                                                1.0,
                                                                          ),
                                                                          borderRadius:
                                                                              BorderRadius.circular(8.0),
                                                                        ),
                                                                        filled:
                                                                            true,
                                                                        fillColor:
                                                                            FlutterFlowTheme.of(context).accent1,
                                                                        contentPadding: EdgeInsetsDirectional.fromSTEB(
                                                                            10.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                      ),
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelMedium
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.readexPro(
                                                                              fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                            ),
                                                                            color:
                                                                                FlutterFlowTheme.of(context).textColor,
                                                                            letterSpacing:
                                                                                1.0,
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                          ),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .justify,
                                                                      maxLength:
                                                                          128,
                                                                      buildCounter: (context,
                                                                              {required currentLength,
                                                                              required isFocused,
                                                                              maxLength}) =>
                                                                          null,
                                                                      cursorColor:
                                                                          FlutterFlowTheme.of(context)
                                                                              .tertiary,
                                                                      validator: _model
                                                                          .textController10Validator
                                                                          .asValidator(
                                                                              context),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child: Align(
                                                                    alignment:
                                                                        AlignmentDirectional(
                                                                            1.0,
                                                                            0.0),
                                                                    child:
                                                                        Padding(
                                                                      padding: EdgeInsetsDirectional.fromSTEB(
                                                                          10.0,
                                                                          0.0,
                                                                          0.0,
                                                                          0.0),
                                                                      child:
                                                                          TextFormField(
                                                                        controller:
                                                                            _model.textController11 ??=
                                                                                TextEditingController(
                                                                          text: (String?
                                                                              jv) {
                                                                            return jv == "null"
                                                                                ? ""
                                                                                : jv;
                                                                          }(getJsonField(
                                                                            mainContainerGQLgetByFunctionResponse.jsonBody,
                                                                            r'''$.data.pep_vw_consolidated_data[:].primary_insurance_id''',
                                                                          ).toString()),
                                                                        ),
                                                                        focusNode:
                                                                            _model.textFieldFocusNode9,
                                                                        autofocus:
                                                                            true,
                                                                        obscureText:
                                                                            false,
                                                                        decoration:
                                                                            InputDecoration(
                                                                          labelText:
                                                                              'Primary Insurance Number',
                                                                          labelStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .override(
                                                                                font: GoogleFonts.poppins(
                                                                                  fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                ),
                                                                                color: FlutterFlowTheme.of(context).textColor,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                              ),
                                                                          hintText:
                                                                              'Enter Primary Insurance Number',
                                                                          hintStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .override(
                                                                                font: GoogleFonts.poppins(
                                                                                  fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                ),
                                                                                color: FlutterFlowTheme.of(context).textColor,
                                                                                letterSpacing: 1.0,
                                                                                fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                              ),
                                                                          enabledBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide(
                                                                              color: FlutterFlowTheme.of(context).borderColor,
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          focusedBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide(
                                                                              color: FlutterFlowTheme.of(context).tertiary,
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          errorBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide(
                                                                              color: Color(0x00000000),
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          focusedErrorBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide(
                                                                              color: Color(0x00000000),
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          filled:
                                                                              true,
                                                                          fillColor:
                                                                              FlutterFlowTheme.of(context).accent1,
                                                                          contentPadding: EdgeInsetsDirectional.fromSTEB(
                                                                              10.0,
                                                                              0.0,
                                                                              0.0,
                                                                              0.0),
                                                                        ),
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .override(
                                                                              font: GoogleFonts.readexPro(
                                                                                fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                              ),
                                                                              color: FlutterFlowTheme.of(context).textColor,
                                                                              letterSpacing: 1.0,
                                                                              fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                            ),
                                                                        textAlign:
                                                                            TextAlign.justify,
                                                                        maxLength:
                                                                            128,
                                                                        buildCounter: (context,
                                                                                {required currentLength,
                                                                                required isFocused,
                                                                                maxLength}) =>
                                                                            null,
                                                                        cursorColor:
                                                                            FlutterFlowTheme.of(context).tertiary,
                                                                        validator: _model
                                                                            .textController11Validator
                                                                            .asValidator(context),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ].divide(SizedBox(
                                                                  width: 20.0)),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        0.0,
                                                                        20.0,
                                                                        0.0,
                                                                        0.0),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Expanded(
                                                                  child: Align(
                                                                    alignment:
                                                                        AlignmentDirectional(
                                                                            0.0,
                                                                            0.0),
                                                                    child:
                                                                        TextFormField(
                                                                      controller:
                                                                          _model.textController12 ??=
                                                                              TextEditingController(
                                                                        text: (String?
                                                                            jv) {
                                                                          return jv == "null"
                                                                              ? ""
                                                                              : jv;
                                                                        }(getJsonField(
                                                                          mainContainerGQLgetByFunctionResponse
                                                                              .jsonBody,
                                                                          r'''$.data.pep_vw_consolidated_data[:].secondary_insurance_provider''',
                                                                        ).toString()),
                                                                      ),
                                                                      focusNode:
                                                                          _model
                                                                              .textFieldFocusNode10,
                                                                      autofocus:
                                                                          true,
                                                                      obscureText:
                                                                          false,
                                                                      decoration:
                                                                          InputDecoration(
                                                                        labelText:
                                                                            'Secondary Insurance Provider',
                                                                        labelStyle: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                              ),
                                                                              color: FlutterFlowTheme.of(context).textColor,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                            ),
                                                                        hintText:
                                                                            'Enter Secondary Insurance Provider',
                                                                        hintStyle: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                              ),
                                                                              color: FlutterFlowTheme.of(context).textColor,
                                                                              letterSpacing: 1.0,
                                                                              fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                            ),
                                                                        enabledBorder:
                                                                            OutlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).borderColor,
                                                                            width:
                                                                                1.0,
                                                                          ),
                                                                          borderRadius:
                                                                              BorderRadius.circular(8.0),
                                                                        ),
                                                                        focusedBorder:
                                                                            OutlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).tertiary,
                                                                            width:
                                                                                1.0,
                                                                          ),
                                                                          borderRadius:
                                                                              BorderRadius.circular(8.0),
                                                                        ),
                                                                        errorBorder:
                                                                            OutlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(
                                                                            color:
                                                                                Color(0x00000000),
                                                                            width:
                                                                                1.0,
                                                                          ),
                                                                          borderRadius:
                                                                              BorderRadius.circular(8.0),
                                                                        ),
                                                                        focusedErrorBorder:
                                                                            OutlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(
                                                                            color:
                                                                                Color(0x00000000),
                                                                            width:
                                                                                1.0,
                                                                          ),
                                                                          borderRadius:
                                                                              BorderRadius.circular(8.0),
                                                                        ),
                                                                        filled:
                                                                            true,
                                                                        fillColor:
                                                                            FlutterFlowTheme.of(context).accent1,
                                                                        contentPadding: EdgeInsetsDirectional.fromSTEB(
                                                                            10.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                      ),
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelMedium
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.readexPro(
                                                                              fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                            ),
                                                                            color:
                                                                                FlutterFlowTheme.of(context).textColor,
                                                                            letterSpacing:
                                                                                1.0,
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                          ),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .justify,
                                                                      maxLength:
                                                                          128,
                                                                      buildCounter: (context,
                                                                              {required currentLength,
                                                                              required isFocused,
                                                                              maxLength}) =>
                                                                          null,
                                                                      cursorColor:
                                                                          FlutterFlowTheme.of(context)
                                                                              .tertiary,
                                                                      validator: _model
                                                                          .textController12Validator
                                                                          .asValidator(
                                                                              context),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child: Align(
                                                                    alignment:
                                                                        AlignmentDirectional(
                                                                            1.0,
                                                                            0.0),
                                                                    child:
                                                                        Padding(
                                                                      padding: EdgeInsetsDirectional.fromSTEB(
                                                                          10.0,
                                                                          0.0,
                                                                          0.0,
                                                                          0.0),
                                                                      child:
                                                                          TextFormField(
                                                                        controller:
                                                                            _model.textController13 ??=
                                                                                TextEditingController(
                                                                          text: (String?
                                                                              jv) {
                                                                            return jv == "null"
                                                                                ? ""
                                                                                : jv;
                                                                          }(getJsonField(
                                                                            mainContainerGQLgetByFunctionResponse.jsonBody,
                                                                            r'''$.data.pep_vw_consolidated_data[:].secondary_insurance_id''',
                                                                          ).toString()),
                                                                        ),
                                                                        focusNode:
                                                                            _model.textFieldFocusNode11,
                                                                        autofocus:
                                                                            true,
                                                                        obscureText:
                                                                            false,
                                                                        decoration:
                                                                            InputDecoration(
                                                                          labelText:
                                                                              'Secondary Insurance Number',
                                                                          labelStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .override(
                                                                                font: GoogleFonts.poppins(
                                                                                  fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                ),
                                                                                color: FlutterFlowTheme.of(context).textColor,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                              ),
                                                                          hintText:
                                                                              'Enter Secondary Insurance Number',
                                                                          hintStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .override(
                                                                                font: GoogleFonts.poppins(
                                                                                  fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                ),
                                                                                color: FlutterFlowTheme.of(context).textColor,
                                                                                letterSpacing: 1.0,
                                                                                fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                              ),
                                                                          enabledBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide(
                                                                              color: FlutterFlowTheme.of(context).borderColor,
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          focusedBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide(
                                                                              color: FlutterFlowTheme.of(context).tertiary,
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          errorBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide(
                                                                              color: Color(0x00000000),
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          focusedErrorBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide(
                                                                              color: Color(0x00000000),
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          filled:
                                                                              true,
                                                                          fillColor:
                                                                              FlutterFlowTheme.of(context).accent1,
                                                                          contentPadding: EdgeInsetsDirectional.fromSTEB(
                                                                              10.0,
                                                                              0.0,
                                                                              0.0,
                                                                              0.0),
                                                                        ),
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .override(
                                                                              font: GoogleFonts.readexPro(
                                                                                fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                              ),
                                                                              color: FlutterFlowTheme.of(context).textColor,
                                                                              letterSpacing: 1.0,
                                                                              fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                            ),
                                                                        textAlign:
                                                                            TextAlign.justify,
                                                                        maxLength:
                                                                            128,
                                                                        buildCounter: (context,
                                                                                {required currentLength,
                                                                                required isFocused,
                                                                                maxLength}) =>
                                                                            null,
                                                                        cursorColor:
                                                                            FlutterFlowTheme.of(context).tertiary,
                                                                        validator: _model
                                                                            .textController13Validator
                                                                            .asValidator(context),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ].divide(SizedBox(
                                                                  width: 20.0)),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        0.0,
                                                                        20.0,
                                                                        0.0,
                                                                        0.0),
                                                            child:
                                                                SingleChildScrollView(
                                                              scrollDirection:
                                                                  Axis.horizontal,
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  SingleChildScrollView(
                                                                    scrollDirection:
                                                                        Axis.horizontal,
                                                                    child: Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      children:
                                                                          [
                                                                        Text(
                                                                          'EMR:',
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
                                                                                font: GoogleFonts.readexPro(
                                                                                  fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                ),
                                                                                fontSize: 16.0,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                        ),
                                                                        Text(
                                                                          getJsonField(
                                                                            mainContainerGQLgetByFunctionResponse.jsonBody,
                                                                            r'''$.data.pep_vw_consolidated_data[:].emr_id''',
                                                                          ).toString(),
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
                                                                                font: GoogleFonts.readexPro(
                                                                                  fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                ),
                                                                                color: FlutterFlowTheme.of(context).secondaryText,
                                                                                fontSize: 16.0,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                        ),
                                                                      ].divide(SizedBox(
                                                                              width: 10.0)),
                                                                    ),
                                                                  ),
                                                                  Align(
                                                                    alignment:
                                                                        AlignmentDirectional(
                                                                            1.0,
                                                                            0.0),
                                                                    child:
                                                                        SingleChildScrollView(
                                                                      scrollDirection:
                                                                          Axis.horizontal,
                                                                      child:
                                                                          Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.max,
                                                                        children:
                                                                            [
                                                                          Text(
                                                                            'Program Eligibilty:',
                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                  font: GoogleFonts.readexPro(
                                                                                    fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                  ),
                                                                                  fontSize: 16.0,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                ),
                                                                          ),
                                                                          Text(
                                                                            functions.getEligibility(
                                                                                valueOrDefault<bool>(
                                                                                  getJsonField(
                                                                                    mainContainerGQLgetByFunctionResponse.jsonBody,
                                                                                    r'''$.data.pep_vw_consolidated_data[:].rpm_flag''',
                                                                                  ),
                                                                                  false,
                                                                                ),
                                                                                valueOrDefault<bool>(
                                                                                  getJsonField(
                                                                                    mainContainerGQLgetByFunctionResponse.jsonBody,
                                                                                    r'''$.data.pep_vw_consolidated_data[:].ccm_flag''',
                                                                                  ),
                                                                                  false,
                                                                                ),
                                                                                valueOrDefault<bool>(
                                                                                  getJsonField(
                                                                                    mainContainerGQLgetByFunctionResponse.jsonBody,
                                                                                    r'''$.data.pep_vw_consolidated_data[:].pcm_flag''',
                                                                                  ),
                                                                                  false,
                                                                                )),
                                                                            style: FlutterFlowTheme.of(context).labelMedium.override(
                                                                                  font: GoogleFonts.poppins(
                                                                                    fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                    fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                  ),
                                                                                  fontSize: 16.0,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                ),
                                                                          ),
                                                                        ].divide(SizedBox(width: 10.0)),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ].divide(SizedBox(
                                                                    width:
                                                                        20.0)),
                                                              ),
                                                            ),
                                                          ),
                                                          if (false == true)
                                                            Padding(
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          20.0,
                                                                          0.0,
                                                                          0.0),
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  SingleChildScrollView(
                                                                    scrollDirection:
                                                                        Axis.horizontal,
                                                                    child: Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      children:
                                                                          [
                                                                        Theme(
                                                                          data:
                                                                              ThemeData(
                                                                            checkboxTheme:
                                                                                CheckboxThemeData(
                                                                              visualDensity: VisualDensity.compact,
                                                                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(4.0),
                                                                              ),
                                                                            ),
                                                                            unselectedWidgetColor:
                                                                                FlutterFlowTheme.of(context).alternate,
                                                                          ),
                                                                          child:
                                                                              Checkbox(
                                                                            value: _model.checkboxPatientReceivedLetterValue ??=
                                                                                false,
                                                                            onChanged:
                                                                                (newValue) async {
                                                                              safeSetState(() => _model.checkboxPatientReceivedLetterValue = newValue!);
                                                                            },
                                                                            side: (FlutterFlowTheme.of(context).alternate != null)
                                                                                ? BorderSide(
                                                                                    width: 2,
                                                                                    color: FlutterFlowTheme.of(context).alternate,
                                                                                  )
                                                                                : null,
                                                                            activeColor:
                                                                                FlutterFlowTheme.of(context).primary,
                                                                            checkColor:
                                                                                FlutterFlowTheme.of(context).info,
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          'Patient received the letter?',
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
                                                                                font: GoogleFonts.readexPro(
                                                                                  fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                ),
                                                                                color: FlutterFlowTheme.of(context).primaryText,
                                                                                fontSize: 16.0,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                        ),
                                                                      ].divide(SizedBox(
                                                                              width: 10.0)),
                                                                    ),
                                                                  ),
                                                                  Align(
                                                                    alignment:
                                                                        AlignmentDirectional(
                                                                            1.0,
                                                                            0.0),
                                                                    child:
                                                                        SingleChildScrollView(
                                                                      scrollDirection:
                                                                          Axis.horizontal,
                                                                      child:
                                                                          Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children:
                                                                            [
                                                                          Theme(
                                                                            data:
                                                                                ThemeData(
                                                                              checkboxTheme: CheckboxThemeData(
                                                                                visualDensity: VisualDensity.compact,
                                                                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                                                shape: RoundedRectangleBorder(
                                                                                  borderRadius: BorderRadius.circular(4.0),
                                                                                ),
                                                                              ),
                                                                              unselectedWidgetColor: FlutterFlowTheme.of(context).alternate,
                                                                            ),
                                                                            child:
                                                                                Checkbox(
                                                                              value: _model.checkboxPatientDownloadedAppValue ??= false,
                                                                              onChanged: (newValue) async {
                                                                                safeSetState(() => _model.checkboxPatientDownloadedAppValue = newValue!);
                                                                              },
                                                                              side: (FlutterFlowTheme.of(context).alternate != null)
                                                                                  ? BorderSide(
                                                                                      width: 2,
                                                                                      color: FlutterFlowTheme.of(context).alternate,
                                                                                    )
                                                                                  : null,
                                                                              activeColor: FlutterFlowTheme.of(context).primary,
                                                                              checkColor: FlutterFlowTheme.of(context).info,
                                                                            ),
                                                                          ),
                                                                          Text(
                                                                            'Patient downloaded the app and registered it.',
                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                  font: GoogleFonts.readexPro(
                                                                                    fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                  ),
                                                                                  color: FlutterFlowTheme.of(context).primaryText,
                                                                                  fontSize: 16.0,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                ),
                                                                          ),
                                                                        ].divide(SizedBox(width: 10.0)),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ].divide(SizedBox(
                                                                    width:
                                                                        20.0)),
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ].divide(SizedBox(width: 20.0)),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Column(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            if (true /* Warning: Trying to access variable not yet defined. */)
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    -1.0, 0.0),
                                                child: FutureBuilder<
                                                    ApiCallResponse>(
                                                  future: FFAppState()
                                                      .ccmStatusUpdatesVPE(
                                                    requestFn: () =>
                                                        GQLgetByFunctionCall
                                                            .call(
                                                      hasuraToken: FFAppState()
                                                          .hasuraToken,
                                                      requestBody: functions
                                                          .getCCMStatusUpdates(
                                                              FFAppState()
                                                                  .currentPatient)
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
                                                          child:
                                                              CircularProgressIndicator(
                                                            valueColor:
                                                                AlwaysStoppedAnimation<
                                                                    Color>(
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .primary,
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                    final containerGQLgetByFunctionResponse =
                                                        snapshot.data!;

                                                    return Container(
                                                      height: 280.71,
                                                      decoration: BoxDecoration(
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryBackground,
                                                            offset: Offset(
                                                              0.0,
                                                              2.0,
                                                            ),
                                                          )
                                                        ],
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      child: Stack(
                                                        children: [
                                                          if (GQLgetByFunctionCall
                                                                      .ccmStatusUpdates(
                                                                    containerGQLgetByFunctionResponse
                                                                        .jsonBody,
                                                                  ) !=
                                                                  null &&
                                                              (GQLgetByFunctionCall
                                                                      .ccmStatusUpdates(
                                                                containerGQLgetByFunctionResponse
                                                                    .jsonBody,
                                                              ))!
                                                                  .isNotEmpty)
                                                            Padding(
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          20.0,
                                                                          50.0,
                                                                          20.0,
                                                                          0.0),
                                                              child: Builder(
                                                                builder:
                                                                    (context) {
                                                                  final ccmStatusUpdates =
                                                                      functions
                                                                          .sortAttemptsToDesc(
                                                                              getJsonField(
                                                                            containerGQLgetByFunctionResponse.jsonBody,
                                                                            r'''$.data.pep_vw_consolidated_data[:].ccm_status_updates''',
                                                                            true,
                                                                          )!)
                                                                          .toList();

                                                                  return FlutterFlowDataTable<
                                                                      dynamic>(
                                                                    controller:
                                                                        _model
                                                                            .paginatedDataTableController,
                                                                    data:
                                                                        ccmStatusUpdates,
                                                                    columnsBuilder:
                                                                        (onSortChanged) =>
                                                                            [
                                                                      DataColumn2(
                                                                        label: DefaultTextStyle
                                                                            .merge(
                                                                          softWrap:
                                                                              true,
                                                                          child:
                                                                              Text(
                                                                            'Attempt to Enroll',
                                                                            style: FlutterFlowTheme.of(context).titleLarge.override(
                                                                                  font: GoogleFonts.readexPro(
                                                                                    fontWeight: FlutterFlowTheme.of(context).titleLarge.fontWeight,
                                                                                    fontStyle: FlutterFlowTheme.of(context).titleLarge.fontStyle,
                                                                                  ),
                                                                                  fontSize: 16.0,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FlutterFlowTheme.of(context).titleLarge.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).titleLarge.fontStyle,
                                                                                ),
                                                                          ),
                                                                        ),
                                                                        fixedWidth:
                                                                            180.0,
                                                                      ),
                                                                      DataColumn2(
                                                                        label: DefaultTextStyle
                                                                            .merge(
                                                                          softWrap:
                                                                              true,
                                                                          child:
                                                                              Text(
                                                                            'Date & Time',
                                                                            style: FlutterFlowTheme.of(context).titleLarge.override(
                                                                                  font: GoogleFonts.readexPro(
                                                                                    fontWeight: FlutterFlowTheme.of(context).titleLarge.fontWeight,
                                                                                    fontStyle: FlutterFlowTheme.of(context).titleLarge.fontStyle,
                                                                                  ),
                                                                                  fontSize: 16.0,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FlutterFlowTheme.of(context).titleLarge.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).titleLarge.fontStyle,
                                                                                ),
                                                                          ),
                                                                        ),
                                                                        fixedWidth:
                                                                            200.0,
                                                                      ),
                                                                      DataColumn2(
                                                                        label: DefaultTextStyle
                                                                            .merge(
                                                                          softWrap:
                                                                              true,
                                                                          child:
                                                                              Text(
                                                                            'CCM Status',
                                                                            style: FlutterFlowTheme.of(context).titleLarge.override(
                                                                                  font: GoogleFonts.readexPro(
                                                                                    fontWeight: FlutterFlowTheme.of(context).titleLarge.fontWeight,
                                                                                    fontStyle: FlutterFlowTheme.of(context).titleLarge.fontStyle,
                                                                                  ),
                                                                                  fontSize: 16.0,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FlutterFlowTheme.of(context).titleLarge.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).titleLarge.fontStyle,
                                                                                ),
                                                                          ),
                                                                        ),
                                                                        fixedWidth:
                                                                            250.0,
                                                                      ),
                                                                      DataColumn2(
                                                                        label: DefaultTextStyle
                                                                            .merge(
                                                                          softWrap:
                                                                              true,
                                                                          child:
                                                                              Text(
                                                                            'Comments',
                                                                            style: FlutterFlowTheme.of(context).titleLarge.override(
                                                                                  font: GoogleFonts.readexPro(
                                                                                    fontWeight: FlutterFlowTheme.of(context).titleLarge.fontWeight,
                                                                                    fontStyle: FlutterFlowTheme.of(context).titleLarge.fontStyle,
                                                                                  ),
                                                                                  fontSize: 16.0,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FlutterFlowTheme.of(context).titleLarge.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).titleLarge.fontStyle,
                                                                                ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      DataColumn2(
                                                                        label: DefaultTextStyle
                                                                            .merge(
                                                                          softWrap:
                                                                              true,
                                                                          child:
                                                                              Text(
                                                                            'Updated By',
                                                                            style: FlutterFlowTheme.of(context).titleLarge.override(
                                                                                  font: GoogleFonts.readexPro(
                                                                                    fontWeight: FlutterFlowTheme.of(context).titleLarge.fontWeight,
                                                                                    fontStyle: FlutterFlowTheme.of(context).titleLarge.fontStyle,
                                                                                  ),
                                                                                  fontSize: 16.0,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FlutterFlowTheme.of(context).titleLarge.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).titleLarge.fontStyle,
                                                                                ),
                                                                          ),
                                                                        ),
                                                                        fixedWidth:
                                                                            250.0,
                                                                      ),
                                                                    ],
                                                                    dataRowBuilder: (ccmStatusUpdatesItem,
                                                                            ccmStatusUpdatesIndex,
                                                                            selected,
                                                                            onSelectChanged) =>
                                                                        DataRow(
                                                                      cells: [
                                                                        Align(
                                                                          alignment: AlignmentDirectional(
                                                                              -1.0,
                                                                              0.0),
                                                                          child:
                                                                              Text(
                                                                            getJsonField(
                                                                              ccmStatusUpdatesItem,
                                                                              r'''$.id''',
                                                                            ).toString(),
                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                  font: GoogleFonts.readexPro(
                                                                                    fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                  ),
                                                                                  color: FlutterFlowTheme.of(context).secondaryText,
                                                                                  fontSize: 12.0,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                ),
                                                                          ),
                                                                        ),
                                                                        Align(
                                                                          alignment: AlignmentDirectional(
                                                                              -1.0,
                                                                              0.0),
                                                                          child:
                                                                              Text(
                                                                            dateTimeFormat(
                                                                              "MM/dd/yy h:mm a",
                                                                              functions.returnDT(functions.dtDisplayFormatterNew(
                                                                                  (String timestamp) {
                                                                                    return timestamp.substring(0, 19).replaceAll('T', ' ');
                                                                                  }(getJsonField(
                                                                                    ccmStatusUpdatesItem,
                                                                                    r'''$.timestamp''',
                                                                                  ).toString()),
                                                                                  getJsonField(
                                                                                    containerGQLgetByFunctionResponse.jsonBody,
                                                                                    r'''$.data.pep_vw_consolidated_data[:].patient_clinic_timezone''',
                                                                                  ).toString())),
                                                                              locale: FFLocalizations.of(context).languageCode,
                                                                            ),
                                                                            style: FlutterFlowTheme.of(context).bodySmall.override(
                                                                                  font: GoogleFonts.poppins(
                                                                                    fontWeight: FlutterFlowTheme.of(context).bodySmall.fontWeight,
                                                                                    fontStyle: FlutterFlowTheme.of(context).bodySmall.fontStyle,
                                                                                  ),
                                                                                  color: FlutterFlowTheme.of(context).secondaryText,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FlutterFlowTheme.of(context).bodySmall.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).bodySmall.fontStyle,
                                                                                ),
                                                                          ),
                                                                        ),
                                                                        Align(
                                                                          alignment: AlignmentDirectional(
                                                                              -1.0,
                                                                              0.0),
                                                                          child:
                                                                              Text(
                                                                            getJsonField(
                                                                              ccmStatusUpdatesItem,
                                                                              r'''$.status''',
                                                                            ).toString(),
                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                  font: GoogleFonts.readexPro(
                                                                                    fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                  ),
                                                                                  color: FlutterFlowTheme.of(context).secondaryText,
                                                                                  fontSize: 12.0,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                ),
                                                                          ),
                                                                        ),
                                                                        Builder(
                                                                          builder: (context) =>
                                                                              InkWell(
                                                                            splashColor:
                                                                                Colors.transparent,
                                                                            focusColor:
                                                                                Colors.transparent,
                                                                            hoverColor:
                                                                                Colors.transparent,
                                                                            highlightColor:
                                                                                Colors.transparent,
                                                                            onTap:
                                                                                () async {
                                                                              await showDialog(
                                                                                context: context,
                                                                                builder: (dialogContext) {
                                                                                  return Dialog(
                                                                                    elevation: 0,
                                                                                    insetPadding: EdgeInsets.zero,
                                                                                    backgroundColor: Colors.transparent,
                                                                                    alignment: AlignmentDirectional(0.0, 0.0).resolve(Directionality.of(context)),
                                                                                    child: GestureDetector(
                                                                                      onTap: () {
                                                                                        FocusScope.of(dialogContext).unfocus();
                                                                                        FocusManager.instance.primaryFocus?.unfocus();
                                                                                      },
                                                                                      child: CommentCardWidget(
                                                                                        comment: getJsonField(
                                                                                          ccmStatusUpdatesItem,
                                                                                          r'''$.comment''',
                                                                                        ).toString(),
                                                                                      ),
                                                                                    ),
                                                                                  );
                                                                                },
                                                                              );
                                                                            },
                                                                            child:
                                                                                Container(
                                                                              decoration: BoxDecoration(),
                                                                              child: Text(
                                                                                getJsonField(
                                                                                  ccmStatusUpdatesItem,
                                                                                  r'''$.comment''',
                                                                                ).toString().maybeHandleOverflow(
                                                                                      maxChars: 105,
                                                                                      replacement: '…',
                                                                                    ),
                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                      font: GoogleFonts.readexPro(
                                                                                        fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                      ),
                                                                                      color: FlutterFlowTheme.of(context).secondaryText,
                                                                                      fontSize: 12.0,
                                                                                      letterSpacing: 0.0,
                                                                                      fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                    ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Align(
                                                                          alignment: AlignmentDirectional(
                                                                              -1.0,
                                                                              0.0),
                                                                          child:
                                                                              Text(
                                                                            functions.returnUsername(
                                                                                FFAppState().usernames.toList(),
                                                                                getJsonField(
                                                                                  ccmStatusUpdatesItem,
                                                                                  r'''$.user_id''',
                                                                                )),
                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                  font: GoogleFonts.readexPro(
                                                                                    fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                  ),
                                                                                  color: FlutterFlowTheme.of(context).secondaryText,
                                                                                  fontSize: 12.0,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                ),
                                                                          ),
                                                                        ),
                                                                      ]
                                                                          .map((c) =>
                                                                              DataCell(c))
                                                                          .toList(),
                                                                    ),
                                                                    paginated:
                                                                        true,
                                                                    selectable:
                                                                        false,
                                                                    hidePaginator:
                                                                        true,
                                                                    showFirstLastButtons:
                                                                        false,
                                                                    headingRowHeight:
                                                                        40.0,
                                                                    dataRowHeight:
                                                                        32.0,
                                                                    headingRowColor:
                                                                        FlutterFlowTheme.of(context)
                                                                            .primary,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            8.0),
                                                                    addHorizontalDivider:
                                                                        false,
                                                                    addTopAndBottomDivider:
                                                                        false,
                                                                    hideDefaultHorizontalDivider:
                                                                        true,
                                                                    addVerticalDivider:
                                                                        true,
                                                                    verticalDividerColor:
                                                                        Color(
                                                                            0x6957636C),
                                                                    verticalDividerThickness:
                                                                        1.0,
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                          Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        20.0,
                                                                        0.0,
                                                                        0.0,
                                                                        0.0),
                                                            child: Text(
                                                              'CCM Enrollment Attempts:\n',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .poppins(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontStyle,
                                                                    ),
                                                                    fontSize:
                                                                        16.0,
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                                  ),
                                                            ),
                                                          ),
                                                          if ((getJsonField(
                                                                    mainContainerGQLgetByFunctionResponse
                                                                        .jsonBody,
                                                                    r'''$.data.pep_vw_consolidated_data[:].ccm_status_updates''',
                                                                  ) !=
                                                                  null) &&
                                                              functions.isPatientAlreadyEnrolled(
                                                                  GQLgetByFunctionCall
                                                                          .ccmStatusUpdates(
                                                                mainContainerGQLgetByFunctionResponse
                                                                    .jsonBody,
                                                              )!
                                                                      .toList()))
                                                            Padding(
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          20.0,
                                                                          22.0,
                                                                          0.0,
                                                                          0.0),
                                                              child: Text(
                                                                'Note: This Patient is already enrolled once for CCM.',
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      font: GoogleFonts
                                                                          .poppins(
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontStyle,
                                                                      ),
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .error,
                                                                      fontSize:
                                                                          16.0,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontStyle,
                                                                    ),
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                          ],
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 20.0, 0.0, 0.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            0.0, 0.0),
                                                    child: Text(
                                                      'CCM Status:',
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyLarge
                                                              .override(
                                                                font: GoogleFonts
                                                                    .poppins(
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyLarge
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyLarge
                                                                      .fontStyle,
                                                                ),
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyLarge
                                                                    .fontWeight,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyLarge
                                                                    .fontStyle,
                                                              ),
                                                    ),
                                                  ),
                                                  if (FFAppState()
                                                          .isDetailsSaved !=
                                                      true)
                                                    Align(
                                                      alignment:
                                                          AlignmentDirectional(
                                                              0.0, 0.0),
                                                      child: FutureBuilder<
                                                          ApiCallResponse>(
                                                        future: FFAppState()
                                                            .ccmStatusListVPE(
                                                          requestFn: () =>
                                                              GQLgetByFunctionCall
                                                                  .call(
                                                            hasuraToken:
                                                                FFAppState()
                                                                    .hasuraToken,
                                                            requestBody:
                                                                '{\"query\":\"query MyQuery {pep_v2_status_mapping_ccm(where: {vpe: {_eq: true}}, order_by: {id: asc}) { id status }}\"}',
                                                          ),
                                                        ),
                                                        builder: (context,
                                                            snapshot) {
                                                          // Customize what your widget looks like when it's loading.
                                                          if (!snapshot
                                                              .hasData) {
                                                            return Center(
                                                              child: SizedBox(
                                                                width: 50.0,
                                                                height: 50.0,
                                                                child:
                                                                    CircularProgressIndicator(
                                                                  valueColor:
                                                                      AlwaysStoppedAnimation<
                                                                          Color>(
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary,
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          }
                                                          final ccmStatusGQLgetByFunctionResponse =
                                                              snapshot.data!;

                                                          return FlutterFlowDropDown<
                                                              int>(
                                                            controller: _model
                                                                    .ccmStatusValueController1 ??=
                                                                FormFieldController<
                                                                    int>(null),
                                                            options: List<
                                                                    int>.from(
                                                                getJsonField(
                                                              ccmStatusGQLgetByFunctionResponse
                                                                  .jsonBody,
                                                              r'''$.data.pep_v2_status_mapping_ccm[:].id''',
                                                              true,
                                                            )!),
                                                            optionLabels:
                                                                (getJsonField(
                                                              ccmStatusGQLgetByFunctionResponse
                                                                  .jsonBody,
                                                              r'''$.data.pep_v2_status_mapping_ccm[:].status''',
                                                              true,
                                                            ) as List)
                                                                    .map<String>(
                                                                        (s) => s
                                                                            .toString())
                                                                    .toList(),
                                                            onChanged:
                                                                (val) async {
                                                              safeSetState(() =>
                                                                  _model.ccmStatusValue1 =
                                                                      val);
                                                              _model.ccmStatus =
                                                                  _model
                                                                      .ccmStatusValue1;
                                                              safeSetState(
                                                                  () {});
                                                            },
                                                            width: 300.0,
                                                            height: 50.0,
                                                            textStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      font: GoogleFonts
                                                                          .poppins(
                                                                        fontWeight: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontWeight,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontStyle,
                                                                      ),
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .textColor,
                                                                      fontSize:
                                                                          16.0,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontStyle,
                                                                    ),
                                                            hintText:
                                                                'Select CCM Status',
                                                            icon: Icon(
                                                              Icons
                                                                  .keyboard_arrow_down_rounded,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .secondaryText,
                                                              size: 24.0,
                                                            ),
                                                            fillColor:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .accent1,
                                                            elevation: 2.0,
                                                            borderColor:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .borderColor,
                                                            borderWidth: 1.0,
                                                            borderRadius: 8.0,
                                                            margin:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        16.0,
                                                                        0.0,
                                                                        16.0,
                                                                        0.0),
                                                            hidesUnderline:
                                                                true,
                                                            isOverButton: true,
                                                            isSearchable: false,
                                                            isMultiSelect:
                                                                false,
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  if (FFAppState()
                                                          .isDetailsSaved ==
                                                      true)
                                                    Align(
                                                      alignment:
                                                          AlignmentDirectional(
                                                              0.0, 0.0),
                                                      child: FutureBuilder<
                                                          ApiCallResponse>(
                                                        future: FFAppState()
                                                            .ccmStatusListVPE(
                                                          requestFn: () =>
                                                              GQLgetByFunctionCall
                                                                  .call(
                                                            hasuraToken:
                                                                FFAppState()
                                                                    .hasuraToken,
                                                            requestBody:
                                                                '{\"query\":\"query MyQuery {pep_v2_status_mapping_ccm(where: {vpe: {_eq: true}}, order_by: {id: asc}) { id status }}\"}',
                                                          ),
                                                        ),
                                                        builder: (context,
                                                            snapshot) {
                                                          // Customize what your widget looks like when it's loading.
                                                          if (!snapshot
                                                              .hasData) {
                                                            return Center(
                                                              child: SizedBox(
                                                                width: 50.0,
                                                                height: 50.0,
                                                                child:
                                                                    CircularProgressIndicator(
                                                                  valueColor:
                                                                      AlwaysStoppedAnimation<
                                                                          Color>(
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary,
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          }
                                                          final ccmStatusGQLgetByFunctionResponse =
                                                              snapshot.data!;

                                                          return FlutterFlowDropDown<
                                                              int>(
                                                            controller: _model
                                                                    .ccmStatusValueController2 ??=
                                                                FormFieldController<
                                                                    int>(
                                                              _model.ccmStatusValue2 ??=
                                                                  getJsonField(
                                                                mainContainerGQLgetByFunctionResponse
                                                                    .jsonBody,
                                                                r'''$.data.pep_vw_consolidated_data[:].ccm_status''',
                                                              ),
                                                            ),
                                                            options: List<
                                                                    int>.from(
                                                                getJsonField(
                                                              ccmStatusGQLgetByFunctionResponse
                                                                  .jsonBody,
                                                              r'''$.data.pep_v2_status_mapping_ccm[:].id''',
                                                              true,
                                                            )!),
                                                            optionLabels:
                                                                (getJsonField(
                                                              ccmStatusGQLgetByFunctionResponse
                                                                  .jsonBody,
                                                              r'''$.data.pep_v2_status_mapping_ccm[:].status''',
                                                              true,
                                                            ) as List)
                                                                    .map<String>(
                                                                        (s) => s
                                                                            .toString())
                                                                    .toList(),
                                                            onChanged:
                                                                (val) async {
                                                              safeSetState(() =>
                                                                  _model.ccmStatusValue2 =
                                                                      val);
                                                              _model.ccmStatus =
                                                                  _model
                                                                      .ccmStatusValue2;
                                                              safeSetState(
                                                                  () {});
                                                            },
                                                            width: 300.0,
                                                            height: 50.0,
                                                            textStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      font: GoogleFonts
                                                                          .poppins(
                                                                        fontWeight: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontWeight,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontStyle,
                                                                      ),
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .textColor,
                                                                      fontSize:
                                                                          16.0,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontStyle,
                                                                    ),
                                                            hintText:
                                                                'Select CCM Status',
                                                            icon: Icon(
                                                              Icons
                                                                  .keyboard_arrow_down_rounded,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .secondaryText,
                                                              size: 24.0,
                                                            ),
                                                            fillColor:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .accent1,
                                                            elevation: 2.0,
                                                            borderColor:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .borderColor,
                                                            borderWidth: 1.0,
                                                            borderRadius: 8.0,
                                                            margin:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        16.0,
                                                                        0.0,
                                                                        16.0,
                                                                        0.0),
                                                            hidesUnderline:
                                                                true,
                                                            isOverButton: true,
                                                            isSearchable: false,
                                                            isMultiSelect:
                                                                false,
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  if (((_model.ccmStatusValue1 ==
                                                              (1)) &&
                                                          !FFAppState()
                                                              .transferPatient) ||
                                                      (_model.ccmStatusValue1 ==
                                                          (3)))
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Column(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              children: [
                                                                Text(
                                                                  'Book Appointment Date & Time:',
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        font: GoogleFonts
                                                                            .poppins(
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                        ),
                                                                        fontSize:
                                                                            16.0,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        fontWeight: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontWeight,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontStyle,
                                                                      ),
                                                                ),
                                                              ],
                                                            ),
                                                            Text(
                                                              valueOrDefault<
                                                                  String>(
                                                                getJsonField(
                                                                  mainContainerGQLgetByFunctionResponse
                                                                      .jsonBody,
                                                                  r'''$.data.pep_vw_consolidated_data[:].patient_clinic_timezone''',
                                                                )?.toString(),
                                                                'Standard UTC',
                                                              ),
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .poppins(
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontStyle,
                                                                    ),
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontWeight,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                        FFButtonWidget(
                                                          onPressed: () async {
                                                            // Date Time Picker
                                                            final _datePickedDate =
                                                                await showDatePicker(
                                                              context: context,
                                                              initialDate:
                                                                  (null ??
                                                                      DateTime
                                                                          .now()),
                                                              firstDate:
                                                                  DateTime(
                                                                      1900),
                                                              lastDate:
                                                                  DateTime(
                                                                      2050),
                                                              builder: (context,
                                                                  child) {
                                                                return wrapInMaterialDatePickerTheme(
                                                                  context,
                                                                  child!,
                                                                  headerBackgroundColor:
                                                                      FlutterFlowTheme.of(
                                                                              context)
                                                                          .tertiary,
                                                                  headerForegroundColor:
                                                                      FlutterFlowTheme.of(
                                                                              context)
                                                                          .primary,
                                                                  headerTextStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .headlineLarge
                                                                      .override(
                                                                        font: GoogleFonts
                                                                            .poppins(
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .headlineLarge
                                                                              .fontStyle,
                                                                        ),
                                                                        fontSize:
                                                                            32.0,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .headlineLarge
                                                                            .fontStyle,
                                                                      ),
                                                                  pickerBackgroundColor:
                                                                      FlutterFlowTheme.of(
                                                                              context)
                                                                          .secondaryBackground,
                                                                  pickerForegroundColor:
                                                                      FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryText,
                                                                  selectedDateTimeBackgroundColor:
                                                                      FlutterFlowTheme.of(
                                                                              context)
                                                                          .primary,
                                                                  selectedDateTimeForegroundColor:
                                                                      FlutterFlowTheme.of(
                                                                              context)
                                                                          .tertiary,
                                                                  actionButtonForegroundColor:
                                                                      FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryText,
                                                                  iconSize:
                                                                      24.0,
                                                                );
                                                              },
                                                            );

                                                            TimeOfDay?
                                                                _datePickedTime;
                                                            if (_datePickedDate !=
                                                                null) {
                                                              _datePickedTime =
                                                                  await showTimePicker(
                                                                context:
                                                                    context,
                                                                initialTime: TimeOfDay
                                                                    .fromDateTime(
                                                                        (null ??
                                                                            DateTime.now())),
                                                                builder:
                                                                    (context,
                                                                        child) {
                                                                  return wrapInMaterialTimePickerTheme(
                                                                    context,
                                                                    child!,
                                                                    headerBackgroundColor:
                                                                        FlutterFlowTheme.of(context)
                                                                            .tertiary,
                                                                    headerForegroundColor:
                                                                        FlutterFlowTheme.of(context)
                                                                            .primary,
                                                                    headerTextStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .headlineLarge
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.poppins(
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).headlineLarge.fontStyle,
                                                                          ),
                                                                          fontSize:
                                                                              32.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          fontStyle: FlutterFlowTheme.of(context)
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
                                                                            .tertiary,
                                                                    actionButtonForegroundColor:
                                                                        FlutterFlowTheme.of(context)
                                                                            .primaryText,
                                                                    iconSize:
                                                                        24.0,
                                                                  );
                                                                },
                                                              );
                                                            }

                                                            if (_datePickedDate !=
                                                                    null &&
                                                                _datePickedTime !=
                                                                    null) {
                                                              safeSetState(() {
                                                                _model.datePicked =
                                                                    DateTime(
                                                                  _datePickedDate
                                                                      .year,
                                                                  _datePickedDate
                                                                      .month,
                                                                  _datePickedDate
                                                                      .day,
                                                                  _datePickedTime!
                                                                      .hour,
                                                                  _datePickedTime
                                                                      .minute,
                                                                );
                                                              });
                                                            } else if (_model
                                                                    .datePicked !=
                                                                null) {
                                                              safeSetState(() {
                                                                _model.datePicked =
                                                                    null;
                                                              });
                                                            }
                                                            FFAppState()
                                                                .appointmentDateSelectFlag = 1;
                                                            safeSetState(() {});
                                                          },
                                                          text: valueOrDefault<
                                                              String>(
                                                            dateTimeFormat(
                                                              "d MMM, y - h:mm a",
                                                              _model.datePicked,
                                                              locale: FFLocalizations
                                                                      .of(context)
                                                                  .languageCode,
                                                            ),
                                                            'Set CCM Appointment',
                                                          ),
                                                          options:
                                                              FFButtonOptions(
                                                            width: 250.0,
                                                            height: 50.0,
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        24.0,
                                                                        0.0,
                                                                        24.0,
                                                                        0.0),
                                                            iconPadding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        0.0,
                                                                        0.0,
                                                                        0.0,
                                                                        0.0),
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .accent1,
                                                            textStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelLarge
                                                                    .override(
                                                                      font: GoogleFonts
                                                                          .poppins(
                                                                        fontWeight: FlutterFlowTheme.of(context)
                                                                            .labelLarge
                                                                            .fontWeight,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .labelLarge
                                                                            .fontStyle,
                                                                      ),
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .textColor,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelLarge
                                                                          .fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelLarge
                                                                          .fontStyle,
                                                                    ),
                                                            elevation: 0.0,
                                                            borderSide:
                                                                BorderSide(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .borderColor,
                                                              width: 1.0,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                          ),
                                                        ),
                                                      ].divide(SizedBox(
                                                          width: 20.0)),
                                                    ),
                                                ].divide(SizedBox(width: 20.0)),
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                -1.0, 0.0),
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      0.0,
                                                                      12.0,
                                                                      0.0,
                                                                      8.0),
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Align(
                                                                alignment:
                                                                    AlignmentDirectional(
                                                                        -1.0,
                                                                        0.0),
                                                                child: Text(
                                                                  'Comment:',
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyLarge
                                                                      .override(
                                                                        font: GoogleFonts
                                                                            .poppins(
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .bodyLarge
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyLarge
                                                                              .fontStyle,
                                                                        ),
                                                                        letterSpacing:
                                                                            0.0,
                                                                        fontWeight: FlutterFlowTheme.of(context)
                                                                            .bodyLarge
                                                                            .fontWeight,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .bodyLarge
                                                                            .fontStyle,
                                                                      ),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            0.0,
                                                                            10.0,
                                                                            0.0,
                                                                            0.0),
                                                                child:
                                                                    Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .accent1,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            8.0),
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .borderColor,
                                                                    ),
                                                                  ),
                                                                  child:
                                                                      Container(
                                                                    width:
                                                                        550.0,
                                                                    child:
                                                                        TextFormField(
                                                                      controller:
                                                                          _model
                                                                              .commentTextController,
                                                                      focusNode:
                                                                          _model
                                                                              .commentFocusNode,
                                                                      autofocus:
                                                                          true,
                                                                      obscureText:
                                                                          false,
                                                                      decoration:
                                                                          InputDecoration(
                                                                        hintStyle: FlutterFlowTheme.of(context)
                                                                            .labelSmall
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FlutterFlowTheme.of(context).labelSmall.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelSmall.fontStyle,
                                                                              ),
                                                                              color: FlutterFlowTheme.of(context).secondaryText,
                                                                              fontSize: 14.0,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FlutterFlowTheme.of(context).labelSmall.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelSmall.fontStyle,
                                                                            ),
                                                                        enabledBorder:
                                                                            UnderlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(
                                                                            color:
                                                                                Color(0x00000000),
                                                                            width:
                                                                                1.0,
                                                                          ),
                                                                          borderRadius:
                                                                              BorderRadius.circular(8.0),
                                                                        ),
                                                                        focusedBorder:
                                                                            UnderlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(
                                                                            color:
                                                                                Color(0x00000000),
                                                                            width:
                                                                                1.0,
                                                                          ),
                                                                          borderRadius:
                                                                              BorderRadius.circular(8.0),
                                                                        ),
                                                                        errorBorder:
                                                                            UnderlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(
                                                                            color:
                                                                                Color(0x00000000),
                                                                            width:
                                                                                1.0,
                                                                          ),
                                                                          borderRadius:
                                                                              BorderRadius.circular(8.0),
                                                                        ),
                                                                        focusedErrorBorder:
                                                                            UnderlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(
                                                                            color:
                                                                                Color(0x00000000),
                                                                            width:
                                                                                1.0,
                                                                          ),
                                                                          borderRadius:
                                                                              BorderRadius.circular(8.0),
                                                                        ),
                                                                        contentPadding: EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            10.0,
                                                                            0.0,
                                                                            20.0),
                                                                      ),
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelMedium
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.readexPro(
                                                                              fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                            ),
                                                                            color:
                                                                                FlutterFlowTheme.of(context).textColor,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                          ),
                                                                      maxLines:
                                                                          2,
                                                                      maxLength:
                                                                          500,
                                                                      maxLengthEnforcement:
                                                                          MaxLengthEnforcement
                                                                              .enforced,
                                                                      cursorColor:
                                                                          FlutterFlowTheme.of(context)
                                                                              .secondaryText,
                                                                      validator: _model
                                                                          .commentTextControllerValidator
                                                                          .asValidator(
                                                                              context),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      if (false == true)
                                                        Align(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  -1.0, -1.0),
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        20.0,
                                                                        10.0,
                                                                        0.0,
                                                                        0.0),
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Align(
                                                                  alignment:
                                                                      AlignmentDirectional(
                                                                          -1.0,
                                                                          0.0),
                                                                  child: Text(
                                                                    'Call Type:',
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyLarge
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.poppins(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).bodyLarge.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                                                                          ),
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .bodyLarge
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyLarge
                                                                              .fontStyle,
                                                                        ),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          12.0,
                                                                          0.0,
                                                                          0.0),
                                                                  child:
                                                                      FlutterFlowRadioButton(
                                                                    options: [
                                                                      'Inbound',
                                                                      'Outbound'
                                                                    ].toList(),
                                                                    onChanged: (val) =>
                                                                        safeSetState(
                                                                            () {}),
                                                                    controller: _model
                                                                        .radioButtonValueController ??= FormFieldController<
                                                                            String>(
                                                                        'Outbound'),
                                                                    optionHeight:
                                                                        32.0,
                                                                    textStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelLarge
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.poppins(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primaryText,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .labelLarge
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .labelLarge
                                                                              .fontStyle,
                                                                        ),
                                                                    selectedTextStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyLarge
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.poppins(
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).tertiary,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyLarge
                                                                              .fontStyle,
                                                                        ),
                                                                    buttonPosition:
                                                                        RadioButtonPosition
                                                                            .left,
                                                                    direction: Axis
                                                                        .vertical,
                                                                    radioButtonColor:
                                                                        FlutterFlowTheme.of(context)
                                                                            .tertiary,
                                                                    inactiveRadioButtonColor:
                                                                        FlutterFlowTheme.of(context)
                                                                            .secondaryText,
                                                                    toggleable:
                                                                        false,
                                                                    horizontalAlignment:
                                                                        WrapAlignment
                                                                            .start,
                                                                    verticalAlignment:
                                                                        WrapCrossAlignment
                                                                            .start,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      if (false == true)
                                                        Align(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  -1.0, -1.0),
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        20.0,
                                                                        10.0,
                                                                        0.0,
                                                                        0.0),
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Align(
                                                                  alignment:
                                                                      AlignmentDirectional(
                                                                          -1.0,
                                                                          0.0),
                                                                  child: Text(
                                                                    'Activity Type:',
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyLarge
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.poppins(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).bodyLarge.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                                                                          ),
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .bodyLarge
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyLarge
                                                                              .fontStyle,
                                                                        ),
                                                                  ),
                                                                ),
                                                                Container(
                                                                  width: 200.0,
                                                                  child:
                                                                      Padding(
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            0.0,
                                                                            12.0,
                                                                            0.0,
                                                                            0.0),
                                                                    child:
                                                                        FlutterFlowCheckboxGroup(
                                                                      options: [
                                                                        'SMS',
                                                                        'Email'
                                                                      ],
                                                                      onChanged:
                                                                          (val) =>
                                                                              safeSetState(() => _model.checkboxGroupValues = val),
                                                                      controller: _model
                                                                              .checkboxGroupValueController ??=
                                                                          FormFieldController<
                                                                              List<String>>(
                                                                        [],
                                                                      ),
                                                                      activeColor:
                                                                          FlutterFlowTheme.of(context)
                                                                              .primary,
                                                                      checkColor:
                                                                          FlutterFlowTheme.of(context)
                                                                              .info,
                                                                      checkboxBorderColor:
                                                                          FlutterFlowTheme.of(context)
                                                                              .secondaryText,
                                                                      textStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .titleSmall
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FontWeight.w600,
                                                                              fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                            ),
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                          ),
                                                                      unselectedTextStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyLarge
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FontWeight.normal,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                                                                            ),
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FontWeight.normal,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                                                                          ),
                                                                      checkboxBorderRadius:
                                                                          BorderRadius.circular(
                                                                              4.0),
                                                                      initialized:
                                                                          _model.checkboxGroupValues !=
                                                                              null,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                  if (FFAppState()
                                                          .transferPatient ==
                                                      true)
                                                    Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  20.0,
                                                                  0.0,
                                                                  2.0,
                                                                  0.0),
                                                      child: Container(
                                                        width: 550.0,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondary,
                                                          boxShadow: [
                                                            BoxShadow(
                                                              blurRadius: 1.0,
                                                              color: Color(
                                                                  0x33000000),
                                                              offset: Offset(
                                                                0.0,
                                                                1.0,
                                                              ),
                                                            )
                                                          ],
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                          border: Border.all(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primary,
                                                          ),
                                                        ),
                                                        child: Align(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  -1.0, -1.0),
                                                          child: Container(
                                                            width:
                                                                double.infinity,
                                                            height: 170.0,
                                                            child: Stack(
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                      1.0,
                                                                      -1.0),
                                                              children: [
                                                                Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          12.0,
                                                                          8.0,
                                                                          12.0,
                                                                          8.0),
                                                                  child: Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Expanded(
                                                                        child:
                                                                            Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Row(
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              children: [
                                                                                Align(
                                                                                  alignment: AlignmentDirectional(-1.0, 0.0),
                                                                                  child: Text(
                                                                                    'Waiting for Care Specialist Approval',
                                                                                    style: FlutterFlowTheme.of(context).bodyLarge.override(
                                                                                          font: GoogleFonts.poppins(
                                                                                            fontWeight: FontWeight.w600,
                                                                                            fontStyle: FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                                                                                          ),
                                                                                          letterSpacing: 0.0,
                                                                                          fontWeight: FontWeight.w600,
                                                                                          fontStyle: FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                                                                                        ),
                                                                                  ),
                                                                                ),
                                                                                if (FFAppState().acceptedTransferCSName == '')
                                                                                  Align(
                                                                                    alignment: AlignmentDirectional(-1.0, 0.0),
                                                                                    child: Padding(
                                                                                      padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 0.0, 0.0),
                                                                                      child: Text(
                                                                                        FFAppState().countdownValue,
                                                                                        style: FlutterFlowTheme.of(context).bodyLarge.override(
                                                                                              font: GoogleFonts.poppins(
                                                                                                fontWeight: FontWeight.w500,
                                                                                                fontStyle: FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                                                                                              ),
                                                                                              letterSpacing: 0.0,
                                                                                              fontWeight: FontWeight.w500,
                                                                                              fontStyle: FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                                                                                            ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                              ],
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      if (FFAppState().acceptedTransferCSName ==
                                                                              '')
                                                                        Expanded(
                                                                          child:
                                                                              Padding(
                                                                            padding: EdgeInsetsDirectional.fromSTEB(
                                                                                0.0,
                                                                                0.0,
                                                                                60.0,
                                                                                0.0),
                                                                            child:
                                                                                LinearPercentIndicator(
                                                                              percent: valueOrDefault<double>(
                                                                                FFAppState().countdownProgressBarValue,
                                                                                1.0,
                                                                              ),
                                                                              width: 455.0,
                                                                              lineHeight: 6.0,
                                                                              animation: true,
                                                                              animateFromLastPercent: true,
                                                                              progressColor: FlutterFlowTheme.of(context).tertiary,
                                                                              backgroundColor: FlutterFlowTheme.of(context).primary,
                                                                              barRadius: Radius.circular(20.0),
                                                                              padding: EdgeInsets.zero,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      Align(
                                                                        alignment: AlignmentDirectional(
                                                                            -1.0,
                                                                            -1.0),
                                                                        child:
                                                                            Padding(
                                                                          padding: EdgeInsetsDirectional.fromSTEB(
                                                                              0.0,
                                                                              4.0,
                                                                              0.0,
                                                                              0.0),
                                                                          child:
                                                                              Text(
                                                                            'This patient will be transfered to the Care Specialist once they accepts \nthe transfer request.',
                                                                            maxLines:
                                                                                2,
                                                                            style: FlutterFlowTheme.of(context).bodyLarge.override(
                                                                                  font: GoogleFonts.poppins(
                                                                                    fontWeight: FlutterFlowTheme.of(context).bodyLarge.fontWeight,
                                                                                    fontStyle: FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                                                                                  ),
                                                                                  fontSize: 14.0,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FlutterFlowTheme.of(context).bodyLarge.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                                                                                ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      if (FFAppState().acceptedTransferCSName !=
                                                                              '')
                                                                        Padding(
                                                                          padding: EdgeInsetsDirectional.fromSTEB(
                                                                              0.0,
                                                                              8.0,
                                                                              0.0,
                                                                              0.0),
                                                                          child:
                                                                              Row(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.center,
                                                                            children: [
                                                                              Theme(
                                                                                data: ThemeData(
                                                                                  checkboxTheme: CheckboxThemeData(
                                                                                    visualDensity: VisualDensity.compact,
                                                                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                                                    shape: RoundedRectangleBorder(
                                                                                      borderRadius: BorderRadius.circular(4.0),
                                                                                    ),
                                                                                  ),
                                                                                  unselectedWidgetColor: FlutterFlowTheme.of(context).alternate,
                                                                                ),
                                                                                child: Checkbox(
                                                                                  value: _model.checkboxCSAcceptedTransferValue ??= true,
                                                                                  onChanged: (newValue) async {
                                                                                    safeSetState(() => _model.checkboxCSAcceptedTransferValue = newValue!);
                                                                                  },
                                                                                  side: (FlutterFlowTheme.of(context).alternate != null)
                                                                                      ? BorderSide(
                                                                                          width: 2,
                                                                                          color: FlutterFlowTheme.of(context).alternate,
                                                                                        )
                                                                                      : null,
                                                                                  activeColor: Color(0xFFB9F0DF),
                                                                                  checkColor: FlutterFlowTheme.of(context).success,
                                                                                ),
                                                                              ),
                                                                              Align(
                                                                                alignment: AlignmentDirectional(-1.0, 0.0),
                                                                                child: Text(
                                                                                  FFAppState().acceptedTransferCSName,
                                                                                  maxLines: 2,
                                                                                  style: FlutterFlowTheme.of(context).bodyLarge.override(
                                                                                        font: GoogleFonts.poppins(
                                                                                          fontWeight: FontWeight.w500,
                                                                                          fontStyle: FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                                                                                        ),
                                                                                        fontSize: 14.5,
                                                                                        letterSpacing: 0.0,
                                                                                        fontWeight: FontWeight.w500,
                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                                                                                      ),
                                                                                ),
                                                                              ),
                                                                              Align(
                                                                                alignment: AlignmentDirectional(-1.0, 0.0),
                                                                                child: Text(
                                                                                  ' has accepted the Transfer Request',
                                                                                  maxLines: 2,
                                                                                  style: FlutterFlowTheme.of(context).bodyLarge.override(
                                                                                        font: GoogleFonts.poppins(
                                                                                          fontWeight: FontWeight.w500,
                                                                                          fontStyle: FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                                                                                        ),
                                                                                        fontSize: 14.5,
                                                                                        letterSpacing: 0.0,
                                                                                        fontWeight: FontWeight.w500,
                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                                                                                      ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      if (FFAppState().acceptedTransferCSName !=
                                                                              '')
                                                                        Align(
                                                                          alignment: AlignmentDirectional(
                                                                              -1.0,
                                                                              0.0),
                                                                          child:
                                                                              Padding(
                                                                            padding: EdgeInsetsDirectional.fromSTEB(
                                                                                32.0,
                                                                                0.0,
                                                                                0.0,
                                                                                0.0),
                                                                            child:
                                                                                Text(
                                                                              'Click on \"Next Patient\" Button to Proceed',
                                                                              maxLines: 2,
                                                                              style: FlutterFlowTheme.of(context).bodyLarge.override(
                                                                                    font: GoogleFonts.poppins(
                                                                                      fontWeight: FontWeight.w600,
                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                                                                                    ),
                                                                                    fontSize: 14.0,
                                                                                    letterSpacing: 0.0,
                                                                                    fontWeight: FontWeight.w600,
                                                                                    fontStyle: FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                                                                                  ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                if (FFAppState()
                                                                            .acceptedTransferCSName ==
                                                                        '')
                                                                  Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            1.0),
                                                                    child:
                                                                        FlutterFlowIconButton(
                                                                      borderRadius:
                                                                          2.0,
                                                                      buttonSize:
                                                                          40.0,
                                                                      fillColor:
                                                                          FlutterFlowTheme.of(context)
                                                                              .secondary,
                                                                      icon:
                                                                          Icon(
                                                                        Icons
                                                                            .clear,
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .error,
                                                                        size:
                                                                            24.0,
                                                                      ),
                                                                      onPressed:
                                                                          () async {
                                                                        _model.invalidateTransferPatientDetailsFromCancel = await PEPAPIsGroup
                                                                            .invalidateTransferredPatientCall
                                                                            .call(
                                                                          loginID:
                                                                              int.parse(FFAppState().loginProfileID),
                                                                          authToken:
                                                                              FFAppState().loginToken,
                                                                          transferID:
                                                                              _model.transferredPatientId,
                                                                        );

                                                                        if ((_model.invalidateTransferPatientDetailsFromCancel?.succeeded ??
                                                                            true)) {
                                                                          _model.transferredPatientId =
                                                                              null;
                                                                          safeSetState(
                                                                              () {});
                                                                          FFAppState().transferPatient =
                                                                              false;
                                                                          safeSetState(
                                                                              () {});
                                                                          await actions
                                                                              .startCountdownTimer(
                                                                            false,
                                                                          );
                                                                          _model.isTransferPatientExecuted =
                                                                              false;
                                                                          safeSetState(
                                                                              () {});
                                                                        } else {
                                                                          ScaffoldMessenger.of(context)
                                                                              .showSnackBar(
                                                                            SnackBar(
                                                                              content: Text(
                                                                                'Invalidate Transfer Patient Failed. Please try again later!',
                                                                                style: TextStyle(
                                                                                  color: FlutterFlowTheme.of(context).secondary,
                                                                                ),
                                                                              ),
                                                                              duration: Duration(milliseconds: 4000),
                                                                              backgroundColor: FlutterFlowTheme.of(context).error,
                                                                            ),
                                                                          );
                                                                          FFAppState().isDetailsSaved =
                                                                              false;
                                                                          safeSetState(
                                                                              () {});
                                                                        }

                                                                        safeSetState(
                                                                            () {});
                                                                      },
                                                                    ),
                                                                  ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ].divide(SizedBox(height: 20.0)),
                                          ),
                                        ),
                                        Align(
                                          alignment:
                                              AlignmentDirectional(0.0, 0.0),
                                          child: Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0.0, 20.0, 0.0, 20.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                if (_model.ccmStatusValue1 ==
                                                    (1))
                                                  Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            1.0, 0.0),
                                                    child: FFButtonWidget(
                                                      onPressed: ((FFAppState()
                                                                      .isDetailsSaved ==
                                                                  true) ||
                                                              (FFAppState()
                                                                          .acceptedTransferCSName !=
                                                                      ''))
                                                          ? null
                                                          : () async {
                                                              if (FFAppState()
                                                                  .transferPatient) {
                                                                _model.invalidateTransferPatientDetails =
                                                                    await PEPAPIsGroup
                                                                        .invalidateTransferredPatientCall
                                                                        .call(
                                                                  loginID: int.parse(
                                                                      FFAppState()
                                                                          .loginProfileID),
                                                                  authToken:
                                                                      FFAppState()
                                                                          .loginToken,
                                                                  transferID: _model
                                                                      .transferredPatientId,
                                                                );

                                                                if ((_model
                                                                        .invalidateTransferPatientDetails
                                                                        ?.succeeded ??
                                                                    true)) {
                                                                  _model.transferredPatientId =
                                                                      null;
                                                                  safeSetState(
                                                                      () {});
                                                                  FFAppState()
                                                                          .transferPatient =
                                                                      false;
                                                                  safeSetState(
                                                                      () {});
                                                                  await actions
                                                                      .startCountdownTimer(
                                                                    false,
                                                                  );
                                                                  _model.isTransferPatientExecuted =
                                                                      false;
                                                                  safeSetState(
                                                                      () {});
                                                                } else {
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(
                                                                    SnackBar(
                                                                      content:
                                                                          Text(
                                                                        'Invalidate Transfer Patient Failed. Please try again later!',
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).secondary,
                                                                        ),
                                                                      ),
                                                                      duration: Duration(
                                                                          milliseconds:
                                                                              4000),
                                                                      backgroundColor:
                                                                          FlutterFlowTheme.of(context)
                                                                              .error,
                                                                    ),
                                                                  );
                                                                  FFAppState()
                                                                          .isDetailsSaved =
                                                                      false;
                                                                  safeSetState(
                                                                      () {});
                                                                }
                                                              } else {
                                                                if (_model.commentTextController
                                                                            .text !=
                                                                        '') {
                                                                  _model.saveTransferPatientDetails =
                                                                      await PEPAPIsGroup
                                                                          .updateTransferredPatientCall
                                                                          .call(
                                                                    requestBody: functions.patientUpdateGlobal(
                                                                        _model.ccmStatus,
                                                                        functions.dtFormatterNew(
                                                                            _model.datePicked,
                                                                            getJsonField(
                                                                              mainContainerGQLgetByFunctionResponse.jsonBody,
                                                                              r'''$.data.pep_vw_consolidated_data[:].patient_clinic_timezone''',
                                                                            ).toString()),
                                                                        (null)?.toList(),
                                                                        null,
                                                                        null,
                                                                        null,
                                                                        null,
                                                                        (null)?.toList(),
                                                                        getJsonField(
                                                                          mainContainerGQLgetByFunctionResponse
                                                                              .jsonBody,
                                                                          r'''$.data.pep_vw_consolidated_data[:].emr_id''',
                                                                        ).toString(),
                                                                        functions.returnProgramEligibility(false, true, false).toList(),
                                                                        getJsonField(
                                                                          mainContainerGQLgetByFunctionResponse
                                                                              .jsonBody,
                                                                          r'''$.data.pep_vw_consolidated_data[:].provider_id''',
                                                                        ),
                                                                        int.parse(getJsonField(
                                                                          mainContainerGQLgetByFunctionResponse
                                                                              .jsonBody,
                                                                          r'''$.data.pep_vw_consolidated_data[:].pep_patient_id''',
                                                                        ).toString()),
                                                                        _model.textController1.text,
                                                                        _model.textController2.text,
                                                                        null,
                                                                        null,
                                                                        _model.textController6.text,
                                                                        _model.textController7.text,
                                                                        _model.textController8.text,
                                                                        _model.textController9.text,
                                                                        _model.tfHomeNumberTextController.text,
                                                                        _model.tfMobileNumberTextController.text,
                                                                        _model.textController5.text,
                                                                        null,
                                                                        _model.textController10.text,
                                                                        _model.textController12.text,
                                                                        _model.textController11.text,
                                                                        _model.textController13.text,
                                                                        false,
                                                                        valueOrDefault<String>(
                                                                          _model
                                                                              .commentTextController
                                                                              .text,
                                                                          'Transferred Patient in Real Time',
                                                                        ),
                                                                        null,
                                                                        null,
                                                                        FFAppState().currentPatientGroupID,
                                                                        false,
                                                                        true),
                                                                    loginID: int.parse(
                                                                        FFAppState()
                                                                            .loginProfileID),
                                                                    patientClinicDataID:
                                                                        FFAppState()
                                                                            .currentPatient,
                                                                    authToken:
                                                                        FFAppState()
                                                                            .loginToken,
                                                                  );

                                                                  if ((_model
                                                                          .saveTransferPatientDetails
                                                                          ?.succeeded ??
                                                                      true)) {
                                                                    _model.transferredPatientId =
                                                                        PEPAPIsGroup
                                                                            .updateTransferredPatientCall
                                                                            .transferId(
                                                                      (_model.saveTransferPatientDetails
                                                                              ?.jsonBody ??
                                                                          ''),
                                                                    );
                                                                    safeSetState(
                                                                        () {});
                                                                    FFAppState()
                                                                            .transferPatient =
                                                                        true;
                                                                    safeSetState(
                                                                        () {});
                                                                    await actions
                                                                        .startCountdownTimer(
                                                                      true,
                                                                    );
                                                                    _model.isTransferPatientExecuted =
                                                                        true;
                                                                    safeSetState(
                                                                        () {});
                                                                    _model.transferredCSName =
                                                                        await actions
                                                                            .getCSFromTransferredPatientSubscription(
                                                                      context,
                                                                      FFAppState()
                                                                          .hasuraToken,
                                                                      _model
                                                                          .transferredPatientId!,
                                                                    );
                                                                  } else {
                                                                    ScaffoldMessenger.of(
                                                                            context)
                                                                        .showSnackBar(
                                                                      SnackBar(
                                                                        content:
                                                                            Text(
                                                                          'Transfer Patient Failed. Please try again later!',
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).secondary,
                                                                          ),
                                                                        ),
                                                                        duration:
                                                                            Duration(milliseconds: 4000),
                                                                        backgroundColor:
                                                                            FlutterFlowTheme.of(context).error,
                                                                      ),
                                                                    );
                                                                    FFAppState()
                                                                            .isDetailsSaved =
                                                                        false;
                                                                    safeSetState(
                                                                        () {});
                                                                  }
                                                                } else {
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(
                                                                    SnackBar(
                                                                      content:
                                                                          Text(
                                                                        'Please Add a Comment',
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).secondary,
                                                                        ),
                                                                      ),
                                                                      duration: Duration(
                                                                          milliseconds:
                                                                              2000),
                                                                      backgroundColor:
                                                                          FlutterFlowTheme.of(context)
                                                                              .error,
                                                                    ),
                                                                  );
                                                                }
                                                              }

                                                              safeSetState(
                                                                  () {});
                                                            },
                                                      text: 'Transfer Patient',
                                                      options: FFButtonOptions(
                                                        width: 170.0,
                                                        height: 38.0,
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    24.0,
                                                                    0.0,
                                                                    24.0,
                                                                    0.0),
                                                        iconPadding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    0.0,
                                                                    0.0,
                                                                    0.0,
                                                                    0.0),
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .warning,
                                                        textStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleSmall
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .poppins(
                                                                    fontWeight: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .fontWeight,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .fontStyle,
                                                                  ),
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryText,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmall
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmall
                                                                      .fontStyle,
                                                                ),
                                                        elevation: 3.0,
                                                        borderSide: BorderSide(
                                                          color: Colors
                                                              .transparent,
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                        disabledColor:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .alternate,
                                                      ),
                                                    ),
                                                  ),
                                                Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          1.0, 0.0),
                                                  child: FFButtonWidget(
                                                    onPressed: (FFAppState()
                                                                .transferPatient
                                                            ? ((FFAppState()
                                                                        .isDetailsSaved ==
                                                                    true) &&
                                                                (FFAppState()
                                                                            .acceptedTransferCSName !=
                                                                        ''))
                                                            : (FFAppState()
                                                                    .isDetailsSaved ==
                                                                true))
                                                        ? null
                                                        : () async {
                                                            if ((_model.ccmStatus !=
                                                                    null) &&
                                                                (_model.ccmStatus !=
                                                                    (0))) {
                                                              if (((_model.ccmStatus ==
                                                                          (1)) &&
                                                                      (FFAppState()
                                                                              .appointmentDateSelectFlag ==
                                                                          (0))) ||
                                                                  ((_model.ccmStatus ==
                                                                          (3)) &&
                                                                      (FFAppState()
                                                                              .appointmentDateSelectFlag ==
                                                                          (0)))) {
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                  SnackBar(
                                                                    content:
                                                                        Text(
                                                                      'Select Appointment Date & Time',
                                                                      style:
                                                                          TextStyle(
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .secondary,
                                                                      ),
                                                                    ),
                                                                    duration: Duration(
                                                                        milliseconds:
                                                                            2000),
                                                                    backgroundColor:
                                                                        FlutterFlowTheme.of(context)
                                                                            .error,
                                                                  ),
                                                                );
                                                              } else {
                                                                if (_model.commentTextController
                                                                            .text !=
                                                                        '') {
                                                                  if ((_model.textController1.text !=
                                                                              '') &&
                                                                      (_model.textController2.text !=
                                                                              '')) {
                                                                    FFAppState()
                                                                            .isDetailsSaved =
                                                                        true;
                                                                    safeSetState(
                                                                        () {});
                                                                    _model.updatePatient =
                                                                        await PEPAPIsGroup
                                                                            .updatePatientCall
                                                                            .call(
                                                                      loginID: int.parse(
                                                                          FFAppState()
                                                                              .loginProfileID),
                                                                      authToken:
                                                                          FFAppState()
                                                                              .loginToken,
                                                                      patientClinicDataID:
                                                                          FFAppState()
                                                                              .currentPatient,
                                                                      requestBody: functions.patientUpdateGlobal(
                                                                          _model.ccmStatus,
                                                                          functions.dtFormatterNew(
                                                                              _model.datePicked,
                                                                              getJsonField(
                                                                                mainContainerGQLgetByFunctionResponse.jsonBody,
                                                                                r'''$.data.pep_vw_consolidated_data[:].patient_clinic_timezone''',
                                                                              ).toString()),
                                                                          (null)?.toList(),
                                                                          null,
                                                                          null,
                                                                          null,
                                                                          null,
                                                                          (null)?.toList(),
                                                                          getJsonField(
                                                                            mainContainerGQLgetByFunctionResponse.jsonBody,
                                                                            r'''$.data.pep_vw_consolidated_data[:].emr_id''',
                                                                          ).toString(),
                                                                          functions.returnProgramEligibility(false, true, false).toList(),
                                                                          getJsonField(
                                                                            mainContainerGQLgetByFunctionResponse.jsonBody,
                                                                            r'''$.data.pep_vw_consolidated_data[:].provider_id''',
                                                                          ),
                                                                          int.parse(getJsonField(
                                                                            mainContainerGQLgetByFunctionResponse.jsonBody,
                                                                            r'''$.data.pep_vw_consolidated_data[:].pep_patient_id''',
                                                                          ).toString()),
                                                                          _model.textController1.text,
                                                                          _model.textController2.text,
                                                                          null,
                                                                          null,
                                                                          _model.textController6.text,
                                                                          _model.textController7.text,
                                                                          _model.textController8.text,
                                                                          _model.textController9.text,
                                                                          _model.tfHomeNumberTextController.text,
                                                                          _model.tfMobileNumberTextController.text,
                                                                          _model.textController5.text,
                                                                          null,
                                                                          _model.textController10.text,
                                                                          _model.textController12.text,
                                                                          _model.textController11.text,
                                                                          _model.textController13.text,
                                                                          false,
                                                                          _model.commentTextController.text,
                                                                          null,
                                                                          null,
                                                                          FFAppState().currentPatientGroupID,
                                                                          false,
                                                                          false),
                                                                    );

                                                                    if (PEPAPIsGroup
                                                                            .updatePatientCall
                                                                            .updatePatientVPEStatus(
                                                                          (_model.updatePatient?.jsonBody ??
                                                                              ''),
                                                                        ) ==
                                                                        true) {
                                                                      FFAppState()
                                                                              .timerState =
                                                                          FFAppState()
                                                                              .timerState;
                                                                      safeSetState(
                                                                          () {});
                                                                      FFAppState()
                                                                              .timerState =
                                                                          _model
                                                                              .sessionTimerMilliseconds1;
                                                                      safeSetState(
                                                                          () {});
                                                                      _model.patientTimerState =
                                                                          _model
                                                                              .patientTimerState;
                                                                      safeSetState(
                                                                          () {});
                                                                      _model.patientTimerState =
                                                                          _model
                                                                              .sessionTimerMilliseconds2;
                                                                      safeSetState(
                                                                          () {});
                                                                      _model
                                                                          .sessionTimerController1
                                                                          .onStopTimer();
                                                                      _model
                                                                          .sessionTimerController2
                                                                          .onStopTimer();
                                                                      FFAppState()
                                                                          .isPaused = !(FFAppState()
                                                                              .isPaused ??
                                                                          true);
                                                                      safeSetState(
                                                                          () {});
                                                                      if (_model
                                                                          .instantTimer
                                                                          .isActive) {
                                                                        _model
                                                                            .instantTimer
                                                                            ?.cancel();
                                                                      } else {
                                                                        _model
                                                                            .instantTimerNested
                                                                            ?.cancel();
                                                                        _model
                                                                            .patientInstantTimerNested
                                                                            ?.cancel();
                                                                      }

                                                                      context
                                                                          .goNamed(
                                                                        ReloadPageWidget
                                                                            .routeName,
                                                                        queryParameters:
                                                                            {
                                                                          'vpeReload':
                                                                              serializeParam(
                                                                            true,
                                                                            ParamType.bool,
                                                                          ),
                                                                        }.withoutNulls,
                                                                      );
                                                                    } else {
                                                                      ScaffoldMessenger.of(
                                                                              context)
                                                                          .showSnackBar(
                                                                        SnackBar(
                                                                          content:
                                                                              Text(
                                                                            'Patient Update Failed. Cannot book slot for this Date and Time!',
                                                                            style:
                                                                                TextStyle(
                                                                              color: FlutterFlowTheme.of(context).secondary,
                                                                            ),
                                                                          ),
                                                                          duration:
                                                                              Duration(milliseconds: 4000),
                                                                          backgroundColor:
                                                                              FlutterFlowTheme.of(context).error,
                                                                        ),
                                                                      );
                                                                      FFAppState()
                                                                              .isDetailsSaved =
                                                                          false;
                                                                      safeSetState(
                                                                          () {});
                                                                    }
                                                                  } else {
                                                                    ScaffoldMessenger.of(
                                                                            context)
                                                                        .showSnackBar(
                                                                      SnackBar(
                                                                        content:
                                                                            Text(
                                                                          'First/Last Cannot Be Empty',
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).secondary,
                                                                          ),
                                                                        ),
                                                                        duration:
                                                                            Duration(milliseconds: 2000),
                                                                        backgroundColor:
                                                                            FlutterFlowTheme.of(context).error,
                                                                      ),
                                                                    );
                                                                  }
                                                                } else {
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(
                                                                    SnackBar(
                                                                      content:
                                                                          Text(
                                                                        'Please Add a Comment',
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).secondary,
                                                                        ),
                                                                      ),
                                                                      duration: Duration(
                                                                          milliseconds:
                                                                              2000),
                                                                      backgroundColor:
                                                                          FlutterFlowTheme.of(context)
                                                                              .error,
                                                                    ),
                                                                  );
                                                                }
                                                              }
                                                            } else {
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .showSnackBar(
                                                                SnackBar(
                                                                  content: Text(
                                                                    'Please Select Call Status',
                                                                    style:
                                                                        TextStyle(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .secondary,
                                                                    ),
                                                                  ),
                                                                  duration: Duration(
                                                                      milliseconds:
                                                                          2000),
                                                                  backgroundColor:
                                                                      FlutterFlowTheme.of(
                                                                              context)
                                                                          .error,
                                                                ),
                                                              );
                                                            }

                                                            safeSetState(() {});
                                                          },
                                                    text: 'Save',
                                                    options: FFButtonOptions(
                                                      width: 130.0,
                                                      height: 38.0,
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  24.0,
                                                                  0.0,
                                                                  24.0,
                                                                  0.0),
                                                      iconPadding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  0.0,
                                                                  0.0,
                                                                  0.0,
                                                                  0.0),
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .tertiary,
                                                      textStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .titleSmall
                                                              .override(
                                                                font: GoogleFonts
                                                                    .poppins(
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmall
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmall
                                                                      .fontStyle,
                                                                ),
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .buttonText,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .fontWeight,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .fontStyle,
                                                              ),
                                                      elevation: 3.0,
                                                      borderSide: BorderSide(
                                                        color:
                                                            Colors.transparent,
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                      disabledColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .alternate,
                                                    ),
                                                  ),
                                                ),
                                                FFButtonWidget(
                                                  onPressed: (FFAppState()
                                                              .transferPatient
                                                          ? ((FFAppState()
                                                                      .isDetailsSaved ==
                                                                  false) &&
                                                              (FFAppState()
                                                                          .acceptedTransferCSName ==
                                                                      ''))
                                                          : (FFAppState()
                                                                  .isDetailsSaved ==
                                                              false))
                                                      ? null
                                                      : () async {
                                                          _model.nextPatientCall =
                                                              await GQLgetByFunctionCall
                                                                  .call(
                                                            hasuraToken:
                                                                FFAppState()
                                                                    .hasuraToken,
                                                            requestBody: functions
                                                                .getNextPatientInGroup(
                                                                    int.parse(
                                                                        FFAppState()
                                                                            .loginProfileID),
                                                                    FFAppState()
                                                                        .searchByAssignedGroupID)
                                                                .toString(),
                                                          );

                                                          if (GQLgetByFunctionCall
                                                                  .currentPatient(
                                                                (_model.nextPatientCall
                                                                        ?.jsonBody ??
                                                                    ''),
                                                              ) !=
                                                              null) {
                                                            FFAppState()
                                                                    .currentPatient =
                                                                GQLgetByFunctionCall
                                                                    .currentPatient(
                                                              (_model.nextPatientCall
                                                                      ?.jsonBody ??
                                                                  ''),
                                                            )!;
                                                            FFAppState()
                                                                    .currentPatientGroupID =
                                                                GQLgetByFunctionCall
                                                                    .currentPatientGroupID(
                                                              (_model.nextPatientCall
                                                                      ?.jsonBody ??
                                                                  ''),
                                                            )!;
                                                            FFAppState()
                                                                .appointmentDateSelectFlag = 0;
                                                            safeSetState(() {});
                                                            FFAppState()
                                                                .clearVpePatientDetailsCacheCache();
                                                            FFAppState()
                                                                .clearCcmStatusUpdatesVPECache();
                                                            FFAppState()
                                                                    .isDetailsSaved =
                                                                false;
                                                            safeSetState(() {});
                                                            FFAppState()
                                                                    .timerState =
                                                                FFAppState()
                                                                    .timerState;
                                                            safeSetState(() {});
                                                            FFAppState()
                                                                    .timerState =
                                                                _model
                                                                    .sessionTimerMilliseconds1;
                                                            safeSetState(() {});
                                                            _model.patientTimerState =
                                                                _model
                                                                    .patientTimerState;
                                                            safeSetState(() {});
                                                            _model.patientTimerState =
                                                                _model
                                                                    .sessionTimerMilliseconds2;
                                                            safeSetState(() {});
                                                            _model
                                                                .sessionTimerController1
                                                                .onStopTimer();
                                                            _model
                                                                .sessionTimerController2
                                                                .onStopTimer();
                                                            FFAppState()
                                                                    .isPaused =
                                                                !(FFAppState()
                                                                        .isPaused ??
                                                                    true);
                                                            safeSetState(() {});
                                                            if (FFAppState()
                                                                    .transferPatient ==
                                                                true) {
                                                              _model.isTransferPatientExecuted =
                                                                  false;
                                                              _model.transferredPatientId =
                                                                  null;
                                                              safeSetState(
                                                                  () {});
                                                              await actions
                                                                  .startCountdownTimer(
                                                                false,
                                                              );
                                                            }
                                                            if (_model
                                                                .instantTimer
                                                                .isActive) {
                                                              _model
                                                                  .instantTimer
                                                                  ?.cancel();
                                                            } else {
                                                              _model
                                                                  .instantTimerNested
                                                                  ?.cancel();
                                                              _model
                                                                  .patientInstantTimerNested
                                                                  ?.cancel();
                                                            }
                                                          } else {
                                                            FFAppState()
                                                                .appointmentDateSelectFlag = 0;
                                                            safeSetState(() {});
                                                            FFAppState()
                                                                    .isDetailsSaved =
                                                                false;
                                                            safeSetState(() {});
                                                            _model.currentPatient =
                                                                await GQLgetByFunctionCall
                                                                    .call(
                                                              hasuraToken:
                                                                  FFAppState()
                                                                      .hasuraToken,
                                                              requestBody: functions
                                                                  .getNextPatient(
                                                                      int.parse(
                                                                          FFAppState()
                                                                              .loginProfileID))
                                                                  .toString(),
                                                            );

                                                            if (GQLgetByFunctionCall
                                                                    .currentPatient(
                                                                  (_model.currentPatient
                                                                          ?.jsonBody ??
                                                                      ''),
                                                                ) !=
                                                                null) {
                                                              if (GQLgetByFunctionCall
                                                                      .currentPatientGroupID(
                                                                    (_model.currentPatient
                                                                            ?.jsonBody ??
                                                                        ''),
                                                                  ) !=
                                                                  FFAppState()
                                                                      .currentPatientGroupID) {
                                                                await showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (alertDialogContext) {
                                                                    return AlertDialog(
                                                                      title: Text(
                                                                          'Group Information'),
                                                                      content: Text(
                                                                          'Current Group Has Been Completed, Switching to Next Available Group'),
                                                                      actions: [
                                                                        TextButton(
                                                                          onPressed: () =>
                                                                              Navigator.pop(alertDialogContext),
                                                                          child:
                                                                              Text('Ok'),
                                                                        ),
                                                                      ],
                                                                    );
                                                                  },
                                                                );
                                                              }
                                                              FFAppState()
                                                                      .currentPatient =
                                                                  GQLgetByFunctionCall
                                                                      .currentPatient(
                                                                (_model.currentPatient
                                                                        ?.jsonBody ??
                                                                    ''),
                                                              )!;
                                                              FFAppState()
                                                                      .currentPatientGroupID =
                                                                  GQLgetByFunctionCall
                                                                      .currentPatientGroupID(
                                                                (_model.currentPatient
                                                                        ?.jsonBody ??
                                                                    ''),
                                                              )!;
                                                              safeSetState(
                                                                  () {});
                                                              FFAppState()
                                                                      .timerState =
                                                                  FFAppState()
                                                                      .timerState;
                                                              safeSetState(
                                                                  () {});
                                                              FFAppState()
                                                                      .timerState =
                                                                  _model
                                                                      .sessionTimerMilliseconds1;
                                                              safeSetState(
                                                                  () {});
                                                              _model.patientTimerState =
                                                                  _model
                                                                      .patientTimerState;
                                                              safeSetState(
                                                                  () {});
                                                              _model.patientTimerState =
                                                                  _model
                                                                      .sessionTimerMilliseconds2;
                                                              safeSetState(
                                                                  () {});
                                                              _model
                                                                  .sessionTimerController1
                                                                  .onStopTimer();
                                                              _model
                                                                  .sessionTimerController2
                                                                  .onStopTimer();
                                                              FFAppState()
                                                                      .isPaused =
                                                                  !(FFAppState()
                                                                          .isPaused ??
                                                                      true);
                                                              safeSetState(
                                                                  () {});
                                                              if (_model
                                                                  .instantTimer
                                                                  .isActive) {
                                                                _model
                                                                    .instantTimer
                                                                    ?.cancel();
                                                              } else {
                                                                _model
                                                                    .instantTimerNested
                                                                    ?.cancel();
                                                                _model
                                                                    .patientInstantTimerNested
                                                                    ?.cancel();
                                                              }
                                                            } else {
                                                              FFAppState()
                                                                      .noPatientsAvailable =
                                                                  true;
                                                              safeSetState(
                                                                  () {});
                                                              FFAppState()
                                                                      .timerState =
                                                                  FFAppState()
                                                                      .timerState;
                                                              safeSetState(
                                                                  () {});
                                                              _model.patientTimerState =
                                                                  _model
                                                                      .patientTimerState;
                                                              safeSetState(
                                                                  () {});
                                                              FFAppState()
                                                                      .timerState =
                                                                  _model
                                                                      .sessionTimerMilliseconds1;
                                                              safeSetState(
                                                                  () {});
                                                              _model.patientTimerState =
                                                                  _model
                                                                      .sessionTimerMilliseconds2;
                                                              safeSetState(
                                                                  () {});
                                                              _model
                                                                  .sessionTimerController1
                                                                  .onStopTimer();
                                                              _model
                                                                  .sessionTimerController2
                                                                  .onStopTimer();
                                                              FFAppState()
                                                                      .isPaused =
                                                                  !(FFAppState()
                                                                          .isPaused ??
                                                                      true);
                                                              safeSetState(
                                                                  () {});
                                                              if (_model
                                                                  .instantTimer
                                                                  .isActive) {
                                                                _model
                                                                    .instantTimer
                                                                    ?.cancel();
                                                              } else {
                                                                _model
                                                                    .instantTimerNested
                                                                    ?.cancel();
                                                                _model
                                                                    .patientInstantTimerNested
                                                                    ?.cancel();
                                                              }
                                                            }
                                                          }

                                                          FFAppState()
                                                                  .transferPatient =
                                                              false;
                                                          FFAppState()
                                                              .acceptedTransferCSName = '';
                                                          FFAppState()
                                                                  .isDetailsSaved =
                                                              false;
                                                          safeSetState(() {});

                                                          context.goNamed(
                                                            ReloadPageWidget
                                                                .routeName,
                                                            queryParameters: {
                                                              'vpeReload':
                                                                  serializeParam(
                                                                true,
                                                                ParamType.bool,
                                                              ),
                                                            }.withoutNulls,
                                                          );

                                                          safeSetState(() {});
                                                        },
                                                  text: 'Next Patient',
                                                  options: FFButtonOptions(
                                                    width: 160.0,
                                                    height: 38.0,
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(24.0, 0.0,
                                                                24.0, 0.0),
                                                    iconPadding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 0.0,
                                                                0.0, 0.0),
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .accent3,
                                                    textStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .titleSmall
                                                            .override(
                                                              font: GoogleFonts
                                                                  .poppins(
                                                                fontWeight: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .fontWeight,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .fontStyle,
                                                              ),
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .buttonText,
                                                              letterSpacing:
                                                                  0.0,
                                                              fontWeight:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmall
                                                                      .fontWeight,
                                                              fontStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmall
                                                                      .fontStyle,
                                                            ),
                                                    elevation: 3.0,
                                                    borderSide: BorderSide(
                                                      color: Colors.transparent,
                                                      width: 1.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                    disabledColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .accent4,
                                                    disabledTextColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .buttonText,
                                                  ),
                                                ),
                                              ].divide(SizedBox(width: 20.0)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  if (FFAppState().noPatientsAvailable)
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Align(
                          alignment: AlignmentDirectional(0.0, 0.0),
                          child: Text(
                            'Congrats!',
                            style: FlutterFlowTheme.of(context)
                                .displayMedium
                                .override(
                                  font: GoogleFonts.poppins(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .displayMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .displayMedium
                                        .fontStyle,
                                  ),
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .displayMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .displayMedium
                                      .fontStyle,
                                ),
                          ),
                        ),
                        Align(
                          alignment: AlignmentDirectional(0.0, 0.0),
                          child: Text(
                            'You\'ve completed all the assigned patients for this week.',
                            style: FlutterFlowTheme.of(context)
                                .headlineSmall
                                .override(
                                  font: GoogleFonts.poppins(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .headlineSmall
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .headlineSmall
                                        .fontStyle,
                                  ),
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .headlineSmall
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .headlineSmall
                                      .fontStyle,
                                ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ));
  }
}
