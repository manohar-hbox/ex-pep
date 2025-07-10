import '/backend/api_requests/api_calls.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_data_table.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
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
import '/index.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'p_e_s_patient_detail_model.dart';
export 'p_e_s_patient_detail_model.dart';

class PESPatientDetailWidget extends StatefulWidget {
  const PESPatientDetailWidget({
    super.key,
    required this.patientClinicDataID,
    required this.clinicID,
    required this.pesScreenType,
  });

  final int? patientClinicDataID;
  final int? clinicID;
  final PESScreenType? pesScreenType;

  static String routeName = 'PESPatientDetail';
  static String routePath = 'PESPatientDetail';

  @override
  State<PESPatientDetailWidget> createState() => _PESPatientDetailWidgetState();
}

class _PESPatientDetailWidgetState extends State<PESPatientDetailWidget> {
  late PESPatientDetailModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PESPatientDetailModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (FFAppState().loginToken != '') {
        _model.createPatientTimeButtonPESLog =
            await PEPAPIsGroup.createPatientTimerLogCall.call(
          userId: FFAppState().loginProfileID,
          authToken: FFAppState().loginToken,
          pepPatientId: widget.patientClinicDataID,
        );

        if ((_model.createPatientTimeButtonPESLog?.succeeded ?? true)) {
          _model.patientTimerLogId = PEPAPIsGroup.createPatientTimerLogCall
              .timeLogId(
                (_model.createPatientTimeButtonPESLog?.jsonBody ?? ''),
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
        FFAppState().clearRpmStatusUpdatesPESCache();
        FFAppState().isDetailsSaved = false;
        safeSetState(() {});
        _model.getPatientDetails = await GQLgetByFunctionCall.call(
          hasuraToken: FFAppState().hasuraToken,
          requestBody: functions
              .getPatientDetails(widget.patientClinicDataID!)
              .toString(),
        );

        _model.ccmStatus = getJsonField(
          (_model.getPatientDetails?.jsonBody ?? ''),
          r'''$.data.pep_vw_consolidated_data[:].ccm_status''',
        );
        _model.rpmStatus = getJsonField(
          (_model.getPatientDetails?.jsonBody ?? ''),
          r'''$.data.pep_vw_consolidated_data[:].rpm_status''',
        );
        safeSetState(() {});
        FFAppState().clearApptDateCache();

        safeSetState(() {});
        _model.getIfPatientCanMakeOutgoingCallResponse =
            await GQLgetByFunctionCall.call(
          hasuraToken: FFAppState().hasuraToken,
          requestBody: functions
              .getIfClinicCanMakeOutgoingCall(widget.clinicID!, 2)
              .toString(),
        );

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
                _model.updateTimerPageLoad =
                    await PEPAPIsGroup.updateTimerLogCall.call(
                  duration: _model.sessionTimerMilliseconds1 ~/ 1000,
                  userId: FFAppState().loginProfileID,
                  timelogId: FFAppState().timerlogId,
                  authToken: FFAppState().loginToken,
                );

                FFAppState().timerState = FFAppState().timerState;
                safeSetState(() {});
              } else if (((_model.sessionTimerMilliseconds2 ~/ 1000) % 60) ==
                  0) {
                _model.patientTimerUpdatePageLoad =
                    await PEPAPIsGroup.updatePatientTimerLogCall.call(
                  duration: _model.sessionTimerMilliseconds2 ~/ 1000,
                  userId: FFAppState().loginProfileID,
                  timelogId: _model.patientTimerLogId,
                  authToken: FFAppState().loginToken,
                  pepPatientId: widget.patientClinicDataID,
                );

                _model.patientTimerState = _model.patientTimerState;
                safeSetState(() {});
              }

              FFAppState().isPaused = false;
              safeSetState(() {});
              FFAppState().isAppMinimized = false;
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
        title: 'PES: Patient Details',
        color: FlutterFlowTheme.of(context).primary.withAlpha(0XFF),
        child: GestureDetector(
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
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 8.0, 0.0, 0.0),
                            child: Text(
                              'Patient Enrollment Specialist (PES) - Patient Details',
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
                                            FFAppState().timerState = _model
                                                .sessionTimerMilliseconds1;
                                            safeSetState(() {});
                                            _model.patientTimerState = _model
                                                .sessionTimerMilliseconds2;
                                            safeSetState(() {});
                                            FFAppState().timerState =
                                                FFAppState().timerState;
                                            safeSetState(() {});
                                            _model.patientTimerState =
                                                _model.patientTimerState;
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
                                                      _model.updateTimerPlayButton =
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
                                                      _model.patientTimerUpdatePlayButton =
                                                          await PEPAPIsGroup
                                                              .updatePatientTimerLogCall
                                                              .call(
                                                        duration: _model
                                                                .sessionTimerMilliseconds2 ~/
                                                            1000,
                                                        userId: FFAppState()
                                                            .loginProfileID,
                                                        timelogId: _model
                                                            .patientTimerLogId,
                                                        authToken: FFAppState()
                                                            .loginToken,
                                                        pepPatientId: widget
                                                            .patientClinicDataID,
                                                      );

                                                      _model.patientTimerState =
                                                          _model
                                                              .patientTimerState;
                                                      safeSetState(() {});
                                                    }

                                                    FFAppState().isPaused =
                                                        false;
                                                    safeSetState(() {});
                                                    FFAppState()
                                                        .isAppMinimized = false;
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
                                  _model.sessionTimerMilliseconds2;
                              safeSetState(() {});
                              _model.patientTimerState =
                                  _model.patientTimerState;
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
                  FutureBuilder<ApiCallResponse>(
                    future: FFAppState().patientDetailsCache(
                      requestFn: () => GQLgetByFunctionCall.call(
                        hasuraToken: FFAppState().hasuraToken,
                        requestBody: functions
                            .getPatientDetails(widget.patientClinicDataID!)
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
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
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
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 10.0, 0.0, 0.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    10.0, 0.0, 16.0, 0.0),
                                            child: Container(
                                              width: 110.0,
                                              height: 40.0,
                                              decoration: BoxDecoration(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .tertiary,
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                              child: Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    if (!FFAppState().isPaused)
                                                      Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    0.0,
                                                                    0.0,
                                                                    4.0,
                                                                    0.0),
                                                        child:
                                                            FlutterFlowIconButton(
                                                          borderColor: Colors
                                                              .transparent,
                                                          borderRadius: 20.0,
                                                          buttonSize: 40.0,
                                                          icon: Icon(
                                                            Icons.pause_sharp,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondary,
                                                            size: 24.0,
                                                          ),
                                                          onPressed: () async {
                                                            if (FFAppState()
                                                                        .loginToken !=
                                                                    '') {
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
                                                          },
                                                        ),
                                                      ),
                                                    if (FFAppState().isPaused)
                                                      Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    0.0,
                                                                    0.0,
                                                                    4.0,
                                                                    0.0),
                                                        child:
                                                            FlutterFlowIconButton(
                                                          borderColor: Colors
                                                              .transparent,
                                                          borderRadius: 20.0,
                                                          buttonSize: 40.0,
                                                          icon: Icon(
                                                            Icons.play_arrow,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondary,
                                                            size: 24.0,
                                                          ),
                                                          onPressed: () async {
                                                            if (FFAppState()
                                                                        .loginToken !=
                                                                    '') {
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
                                                              _model
                                                                  .sessionTimerController2
                                                                  .onStartTimer();
                                                              _model
                                                                  .sessionTimerController1
                                                                  .onStartTimer();
                                                              FFAppState()
                                                                      .isPaused =
                                                                  !(FFAppState()
                                                                          .isPaused ??
                                                                      true);
                                                              safeSetState(
                                                                  () {});
                                                              if (!_model
                                                                  .instantTimer
                                                                  .isActive) {
                                                                _model.patientInstantTimerNested =
                                                                    InstantTimer
                                                                        .periodic(
                                                                  duration: Duration(
                                                                      milliseconds:
                                                                          1000),
                                                                  callback:
                                                                      (timer) async {
                                                                    _model.isTabMinimizedNestedPatient =
                                                                        await actions
                                                                            .isTabMinimized();
                                                                    if (_model
                                                                        .isTabMinimizedNested!) {
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
                                                                              .isAppMinimized =
                                                                          true;
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
                                                                          true;
                                                                      safeSetState(
                                                                          () {});
                                                                    } else {
                                                                      _model
                                                                          .sessionTimerController1
                                                                          .onStartTimer();
                                                                      _model
                                                                          .sessionTimerController2
                                                                          .onStartTimer();
                                                                      if (((_model.sessionTimerMilliseconds1 ~/ 1000) %
                                                                              60) ==
                                                                          0) {
                                                                        _model.updatePatientTimerPlayButton = await PEPAPIsGroup
                                                                            .updateTimerLogCall
                                                                            .call(
                                                                          duration:
                                                                              _model.sessionTimerMilliseconds1 ~/ 1000,
                                                                          userId:
                                                                              FFAppState().loginProfileID,
                                                                          timelogId:
                                                                              FFAppState().timerlogId,
                                                                          authToken:
                                                                              FFAppState().loginToken,
                                                                        );

                                                                        FFAppState().timerState =
                                                                            FFAppState().timerState;
                                                                        safeSetState(
                                                                            () {});
                                                                      } else if (((_model.sessionTimerMilliseconds2 ~/ 1000) %
                                                                              60) ==
                                                                          0) {
                                                                        _model.updatePatientTimerPlayBtn = await PEPAPIsGroup
                                                                            .updatePatientTimerLogCall
                                                                            .call(
                                                                          duration:
                                                                              _model.sessionTimerMilliseconds2 ~/ 1000,
                                                                          userId:
                                                                              FFAppState().loginProfileID,
                                                                          authToken:
                                                                              FFAppState().loginToken,
                                                                          timelogId:
                                                                              _model.patientTimerLogId,
                                                                          pepPatientId:
                                                                              widget.patientClinicDataID,
                                                                        );

                                                                        _model.patientTimerState =
                                                                            _model.patientTimerState;
                                                                        safeSetState(
                                                                            () {});
                                                                      }

                                                                      FFAppState()
                                                                              .isAppMinimized =
                                                                          false;
                                                                      safeSetState(
                                                                          () {});
                                                                      FFAppState()
                                                                              .isPaused =
                                                                          false;
                                                                      safeSetState(
                                                                          () {});
                                                                    }
                                                                  },
                                                                  startImmediately:
                                                                      false,
                                                                );
                                                              }
                                                            }

                                                            safeSetState(() {});
                                                          },
                                                        ),
                                                      ),
                                                    FlutterFlowTimer(
                                                      initialTime: _model
                                                          .sessionTimerInitialTimeMs2,
                                                      getDisplayTime: (value) =>
                                                          StopWatchTimer
                                                              .getDisplayTime(
                                                        value,
                                                        hours: false,
                                                        milliSecond: false,
                                                      ),
                                                      controller: _model
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
                                                          safeSetState(() {});
                                                      },
                                                      onEnded: () async {
                                                        _model
                                                            .sessionTimerController2
                                                            .onStartTimer();
                                                      },
                                                      textAlign:
                                                          TextAlign.start,
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
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
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondary,
                                                                fontSize: 18.0,
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
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Align(
                                      alignment: AlignmentDirectional(0.0, 0.0),
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0.0, 20.0, 0.0, 0.0),
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    -1.0, 0.0),
                                                child: Container(
                                                  width:
                                                      MediaQuery.sizeOf(context)
                                                              .width *
                                                          0.47,
                                                  height: 340.0,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            0.0),
                                                    shape: BoxShape.rectangle,
                                                  ),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Expanded(
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              children: [
                                                                Text(
                                                                  'First Name:',
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
                                                                Expanded(
                                                                  child: Text(
                                                                    valueOrDefault<
                                                                        String>(
                                                                      getJsonField(
                                                                        mainContainerGQLgetByFunctionResponse
                                                                            .jsonBody,
                                                                        r'''$.data.pep_vw_consolidated_data[:].first_name''',
                                                                      )?.toString(),
                                                                      'EMR',
                                                                    ),
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.poppins(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).secondaryText,
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
                                                                ),
                                                              ].divide(SizedBox(
                                                                  width: 10.0)),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              children: [
                                                                Align(
                                                                  alignment:
                                                                      AlignmentDirectional(
                                                                          -1.0,
                                                                          0.0),
                                                                  child: Text(
                                                                    'Last Name:',
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelMedium
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.poppins(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primaryText,
                                                                          fontSize:
                                                                              16.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontStyle,
                                                                        ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child: Text(
                                                                    getJsonField(
                                                                      mainContainerGQLgetByFunctionResponse
                                                                          .jsonBody,
                                                                      r'''$.data.pep_vw_consolidated_data[:].last_name''',
                                                                    ).toString(),
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.poppins(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).secondaryText,
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
                                                                ),
                                                              ].divide(SizedBox(
                                                                  width: 10.0)),
                                                            ),
                                                          ),
                                                        ].divide(SizedBox(
                                                            width: 20.0)),
                                                      ),
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Expanded(
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  'Date of Birth:',
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
                                                                Expanded(
                                                                  child: Text(
                                                                    dateTimeFormat(
                                                                      "MM/dd/yy",
                                                                      functions
                                                                          .returnDT(
                                                                              getJsonField(
                                                                        mainContainerGQLgetByFunctionResponse
                                                                            .jsonBody,
                                                                        r'''$.data.pep_vw_consolidated_data[:].dob''',
                                                                      ).toString()),
                                                                      locale: FFLocalizations.of(
                                                                              context)
                                                                          .languageCode,
                                                                    ),
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelMedium
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.poppins(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                          ),
                                                                          fontSize:
                                                                              16.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontStyle,
                                                                        ),
                                                                  ),
                                                                ),
                                                              ].divide(SizedBox(
                                                                  width: 10.0)),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
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
                                                                          1.0,
                                                                          0.0),
                                                                  child: Text(
                                                                    'Gender:',
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.poppins(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
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
                                                                ),
                                                                Expanded(
                                                                  child: Text(
                                                                    (String
                                                                        gender) {
                                                                      return gender ==
                                                                              'M'
                                                                          ? 'Male'
                                                                          : gender == 'F'
                                                                              ? 'Female'
                                                                              : 'Unknown';
                                                                    }(valueOrDefault<
                                                                        String>(
                                                                      getJsonField(
                                                                        mainContainerGQLgetByFunctionResponse
                                                                            .jsonBody,
                                                                        r'''$.data.pep_vw_consolidated_data[:].gender''',
                                                                      )?.toString(),
                                                                      'N/A',
                                                                    )),
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelMedium
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.poppins(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                          ),
                                                                          fontSize:
                                                                              16.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontStyle,
                                                                        ),
                                                                  ),
                                                                ),
                                                              ].divide(SizedBox(
                                                                  width: 10.0)),
                                                            ),
                                                          ),
                                                        ].divide(SizedBox(
                                                            width: 20.0)),
                                                      ),
                                                      SingleChildScrollView(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Align(
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                      0.0, 0.0),
                                                              child: Text(
                                                                'Mobile No:',
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .override(
                                                                      font: GoogleFonts
                                                                          .poppins(
                                                                        fontWeight: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .fontWeight,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .labelMedium
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
                                                                          .labelMedium
                                                                          .fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelMedium
                                                                          .fontStyle,
                                                                    ),
                                                              ),
                                                            ),
                                                            Text(
                                                              getJsonField(
                                                                mainContainerGQLgetByFunctionResponse
                                                                    .jsonBody,
                                                                r'''$.data.pep_vw_consolidated_data[:].mobile_phone_number''',
                                                              ).toString(),
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
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondaryText,
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
                                                            FlutterFlowIconButton(
                                                              borderColor:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary,
                                                              borderRadius:
                                                                  20.0,
                                                              buttonSize: 40.0,
                                                              fillColor:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondary,
                                                              icon: Icon(
                                                                Icons
                                                                    .content_copy,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .textColor,
                                                                size: 20.0,
                                                              ),
                                                              onPressed:
                                                                  () async {
                                                                await Clipboard.setData(
                                                                    ClipboardData(
                                                                        text:
                                                                            getJsonField(
                                                                  mainContainerGQLgetByFunctionResponse
                                                                      .jsonBody,
                                                                  r'''$.data.pep_vw_consolidated_data[:].mobile_phone_number''',
                                                                ).toString()));
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                  SnackBar(
                                                                    content:
                                                                        Text(
                                                                      'Mobile Number copied to Clipboard ',
                                                                      style:
                                                                          TextStyle(
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .primaryText,
                                                                      ),
                                                                    ),
                                                                    duration: Duration(
                                                                        milliseconds:
                                                                            4000),
                                                                    backgroundColor:
                                                                        FlutterFlowTheme.of(context)
                                                                            .secondary,
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                            Builder(
                                                              builder: (context) =>
                                                                  FlutterFlowIconButton(
                                                                borderColor:
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary,
                                                                borderRadius:
                                                                    20.0,
                                                                buttonSize:
                                                                    40.0,
                                                                fillColor: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondary,
                                                                hoverColor: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryBackground,
                                                                icon: Icon(
                                                                  Icons
                                                                      .sms_outlined,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .textColor,
                                                                  size: 20.0,
                                                                ),
                                                                onPressed:
                                                                    () async {
                                                                  await showDialog(
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (dialogContext) {
                                                                      return Dialog(
                                                                        elevation:
                                                                            0,
                                                                        insetPadding:
                                                                            EdgeInsets.zero,
                                                                        backgroundColor:
                                                                            Colors.transparent,
                                                                        alignment:
                                                                            AlignmentDirectional(0.0, 0.0).resolve(Directionality.of(context)),
                                                                        child:
                                                                            GestureDetector(
                                                                          onTap:
                                                                              () {
                                                                            FocusScope.of(dialogContext).unfocus();
                                                                            FocusManager.instance.primaryFocus?.unfocus();
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            height:
                                                                                620.0,
                                                                            width:
                                                                                700.0,
                                                                            child:
                                                                                SendSMSWidget(
                                                                              phoneNumber: (String mobilePhoneNumber) {
                                                                                return mobilePhoneNumber == 'n/a';
                                                                              }(getJsonField(
                                                                                mainContainerGQLgetByFunctionResponse.jsonBody,
                                                                                r'''$.data.pep_vw_consolidated_data[:].mobile_phone_number''',
                                                                              ).toString())
                                                                                  ? ''
                                                                                  : getJsonField(
                                                                                      mainContainerGQLgetByFunctionResponse.jsonBody,
                                                                                      r'''$.data.pep_vw_consolidated_data[:].mobile_phone_number''',
                                                                                    ).toString(),
                                                                              patientId: widget.patientClinicDataID!.toString(),
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
                                                              future:
                                                                  FFAppState()
                                                                      .canCall(
                                                                requestFn: () =>
                                                                    GQLgetByFunctionCall
                                                                        .call(
                                                                  hasuraToken:
                                                                      FFAppState()
                                                                          .hasuraToken,
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
                                                              builder: (context,
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
                                                                        valueColor:
                                                                            AlwaysStoppedAnimation<Color>(
                                                                          FlutterFlowTheme.of(context)
                                                                              .primary,
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
                                                                    visible:
                                                                        getJsonField(
                                                                              (_model.getIfPatientCanMakeOutgoingCallResponse?.jsonBody ?? ''),
                                                                              r'''$.data.api_origin_number_master[:]''',
                                                                            ) !=
                                                                            null,
                                                                    child:
                                                                        Builder(
                                                                      builder:
                                                                          (context) =>
                                                                              FlutterFlowIconButton(
                                                                        borderColor:
                                                                            FlutterFlowTheme.of(context).primary,
                                                                        borderRadius:
                                                                            20.0,
                                                                        buttonSize:
                                                                            40.0,
                                                                        fillColor:
                                                                            FlutterFlowTheme.of(context).secondary,
                                                                        hoverColor:
                                                                            FlutterFlowTheme.of(context).secondaryBackground,
                                                                        icon:
                                                                            Icon(
                                                                          Icons
                                                                              .call,
                                                                          color:
                                                                              FlutterFlowTheme.of(context).textColor,
                                                                          size:
                                                                              20.0,
                                                                        ),
                                                                        onPressed:
                                                                            () async {
                                                                          _model.lisOfOutboundNumbers =
                                                                              await GQLgetByFunctionCall.call(
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
                                                                          );

                                                                          if (_model.lisOfOutboundNumbers !=
                                                                              null) {
                                                                            _model.listOfProcessedOutboundNo =
                                                                                await actions.getOutboundNumbersFromResponse(
                                                                              getJsonField(
                                                                                (_model.lisOfOutboundNumbers?.jsonBody ?? ''),
                                                                                r'''$.data.api_origin_number_master[:]''',
                                                                                true,
                                                                              )!,
                                                                            );
                                                                            _model.outboundNumbers =
                                                                                _model.listOfProcessedOutboundNo!.toList().cast<String>();
                                                                            safeSetState(() {});
                                                                          } else {
                                                                            _model.outboundNumbers =
                                                                                [];
                                                                            safeSetState(() {});
                                                                          }

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
                                                                                    height: 400.0,
                                                                                    width: 600.0,
                                                                                    child: CallPatientWidget(
                                                                                      parentContext: context,
                                                                                      primaryPhoneNumber: getJsonField(
                                                                                        mainContainerGQLgetByFunctionResponse.jsonBody,
                                                                                        r'''$.data.pep_vw_consolidated_data[:].mobile_phone_number''',
                                                                                      ).toString(),
                                                                                      emergencyPhoneNumber: getJsonField(
                                                                                        mainContainerGQLgetByFunctionResponse.jsonBody,
                                                                                        r'''$.data.pep_vw_consolidated_data[:].home_phone_number''',
                                                                                      ).toString(),
                                                                                      clinicId: getJsonField(
                                                                                        mainContainerGQLgetByFunctionResponse.jsonBody,
                                                                                        r'''$.data.pep_vw_consolidated_data[:].clinic_id''',
                                                                                      ).toString(),
                                                                                      patientId: widget.patientClinicDataID!.toString(),
                                                                                      callerId: FFAppState().loginProfileID,
                                                                                      originNumberType: OriginNumberType.Enrollment.name,
                                                                                      patientFirstName: valueOrDefault<String>(
                                                                                        getJsonField(
                                                                                          mainContainerGQLgetByFunctionResponse.jsonBody,
                                                                                          r'''$.data.pep_vw_consolidated_data[:].first_name''',
                                                                                        )?.toString(),
                                                                                        'EMR',
                                                                                      ),
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

                                                                          await actions
                                                                              .warnBeforeUnload(
                                                                            FFAppState().isPatientCallInProgress,
                                                                          );

                                                                          safeSetState(
                                                                              () {});
                                                                        },
                                                                      ),
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                            Text(
                                                              'Home No:',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelMedium
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .poppins(
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelMedium
                                                                          .fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelMedium
                                                                          .fontStyle,
                                                                    ),
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryText,
                                                                    fontSize:
                                                                        16.0,
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelMedium
                                                                        .fontWeight,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelMedium
                                                                        .fontStyle,
                                                                  ),
                                                            ),
                                                            Text(
                                                              getJsonField(
                                                                mainContainerGQLgetByFunctionResponse
                                                                    .jsonBody,
                                                                r'''$.data.pep_vw_consolidated_data[:].home_phone_number''',
                                                              ).toString(),
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
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondaryText,
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
                                                            FlutterFlowIconButton(
                                                              borderColor:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary,
                                                              borderRadius:
                                                                  20.0,
                                                              buttonSize: 40.0,
                                                              fillColor:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondary,
                                                              icon: Icon(
                                                                Icons
                                                                    .content_copy,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .textColor,
                                                                size: 20.0,
                                                              ),
                                                              onPressed:
                                                                  () async {
                                                                await Clipboard.setData(
                                                                    ClipboardData(
                                                                        text:
                                                                            getJsonField(
                                                                  mainContainerGQLgetByFunctionResponse
                                                                      .jsonBody,
                                                                  r'''$.data.pep_vw_consolidated_data[:].home_phone_number''',
                                                                ).toString()));
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                  SnackBar(
                                                                    content:
                                                                        Text(
                                                                      'Home Number copied to Clipboard ',
                                                                      style:
                                                                          TextStyle(
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .primaryText,
                                                                      ),
                                                                    ),
                                                                    duration: Duration(
                                                                        milliseconds:
                                                                            4000),
                                                                    backgroundColor:
                                                                        FlutterFlowTheme.of(context)
                                                                            .secondary,
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ].divide(SizedBox(
                                                              width: 16.0)),
                                                        ),
                                                      ),
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            'Email Address:',
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
                                                          Expanded(
                                                            child: Text(
                                                              getJsonField(
                                                                mainContainerGQLgetByFunctionResponse
                                                                    .jsonBody,
                                                                r'''$.data.pep_vw_consolidated_data[:].email''',
                                                              ).toString(),
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
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondaryText,
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
                                                        ].divide(SizedBox(
                                                            width: 10.0)),
                                                      ),
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            'Address:',
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
                                                          Expanded(
                                                            child: Text(
                                                              getJsonField(
                                                                mainContainerGQLgetByFunctionResponse
                                                                    .jsonBody,
                                                                r'''$.data.pep_vw_consolidated_data[:].address_line_1''',
                                                              ).toString(),
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
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondaryText,
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
                                                        ].divide(SizedBox(
                                                            width: 10.0)),
                                                      ),
                                                      Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                -1.0, 0.0),
                                                        child:
                                                            SingleChildScrollView(
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
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
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      'City:',
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
                                                                        r'''$.data.pep_vw_consolidated_data[:].city''',
                                                                      ).toString(),
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                            color:
                                                                                FlutterFlowTheme.of(context).secondaryText,
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
                                                                  ].divide(SizedBox(
                                                                      width:
                                                                          10.0)),
                                                                ),
                                                              ),
                                                              SingleChildScrollView(
                                                                scrollDirection:
                                                                    Axis.horizontal,
                                                                child: Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      'State:',
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
                                                                        r'''$.data.pep_vw_consolidated_data[:].state''',
                                                                      ).toString(),
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                            color:
                                                                                FlutterFlowTheme.of(context).secondaryText,
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
                                                                  ].divide(SizedBox(
                                                                      width:
                                                                          10.0)),
                                                                ),
                                                              ),
                                                              SingleChildScrollView(
                                                                scrollDirection:
                                                                    Axis.horizontal,
                                                                child: Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      'Zip Code: ',
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
                                                                        r'''$.data.pep_vw_consolidated_data[:].zip_code''',
                                                                      ).toString(),
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                            color:
                                                                                FlutterFlowTheme.of(context).secondaryText,
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
                                                                  ].divide(SizedBox(
                                                                      width:
                                                                          10.0)),
                                                                ),
                                                              ),
                                                            ].divide(SizedBox(
                                                                width: 20.0)),
                                                          ),
                                                        ),
                                                      ),
                                                    ].divide(
                                                        SizedBox(height: 20.0)),
                                                  ),
                                                ),
                                              ),
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    1.0, 0.0),
                                                child: Container(
                                                  width:
                                                      MediaQuery.sizeOf(context)
                                                              .width *
                                                          0.47,
                                                  height: 340.0,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Expanded(
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  'Clinic Name:',
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
                                                                Expanded(
                                                                  child: Text(
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
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                          ),
                                                                          fontSize:
                                                                              16.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontStyle,
                                                                        ),
                                                                  ),
                                                                ),
                                                              ].divide(SizedBox(
                                                                  width: 10.0)),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  'Provider Name:',
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
                                                                Expanded(
                                                                  child: Text(
                                                                    getJsonField(
                                                                      mainContainerGQLgetByFunctionResponse
                                                                          .jsonBody,
                                                                      r'''$.data.pep_vw_consolidated_data[:].provider_name''',
                                                                    ).toString(),
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelMedium
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.poppins(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                          ),
                                                                          fontSize:
                                                                              16.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontStyle,
                                                                        ),
                                                                  ),
                                                                ),
                                                              ].divide(SizedBox(
                                                                  width: 10.0)),
                                                            ),
                                                          ),
                                                        ].divide(SizedBox(
                                                            width: 20.0)),
                                                      ),
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Expanded(
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  'Primary Dx:',
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
                                                                Expanded(
                                                                  child: Text(
                                                                    getJsonField(
                                                                      mainContainerGQLgetByFunctionResponse
                                                                          .jsonBody,
                                                                      r'''$.data.pep_vw_consolidated_data[:].primary_dx''',
                                                                    ).toString(),
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelMedium
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.poppins(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                          ),
                                                                          fontSize:
                                                                              16.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontStyle,
                                                                        ),
                                                                  ),
                                                                ),
                                                              ].divide(SizedBox(
                                                                  width: 10.0)),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  'Secondary Dx:',
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
                                                                Expanded(
                                                                  child: Text(
                                                                    getJsonField(
                                                                      mainContainerGQLgetByFunctionResponse
                                                                          .jsonBody,
                                                                      r'''$.data.pep_vw_consolidated_data[:].secondary_dx''',
                                                                    ).toString(),
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelMedium
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.poppins(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                          ),
                                                                          fontSize:
                                                                              16.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontStyle,
                                                                        ),
                                                                  ),
                                                                ),
                                                              ].divide(SizedBox(
                                                                  width: 10.0)),
                                                            ),
                                                          ),
                                                        ].divide(SizedBox(
                                                            width: 20.0)),
                                                      ),
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Expanded(
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
                                                                Text(
                                                                  'Primary Insurance\nProvider: ',
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
                                                                Expanded(
                                                                  child: Text(
                                                                    getJsonField(
                                                                      mainContainerGQLgetByFunctionResponse
                                                                          .jsonBody,
                                                                      r'''$.data.pep_vw_consolidated_data[:].primary_insurance_provider''',
                                                                    ).toString(),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .start,
                                                                    maxLines: 4,
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.poppins(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).secondaryText,
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
                                                                ),
                                                              ].divide(SizedBox(
                                                                  width: 10.0)),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Text(
                                                                  'Primary Insurance\nNumber: ',
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
                                                                Expanded(
                                                                  child: Text(
                                                                    getJsonField(
                                                                      mainContainerGQLgetByFunctionResponse
                                                                          .jsonBody,
                                                                      r'''$.data.pep_vw_consolidated_data[:].primary_insurance_id''',
                                                                    ).toString(),
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.poppins(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).secondaryText,
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
                                                                ),
                                                              ].divide(SizedBox(
                                                                  width: 10.0)),
                                                            ),
                                                          ),
                                                        ].divide(SizedBox(
                                                            width: 20.0)),
                                                      ),
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Expanded(
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  'Secondary Insurance\nProvider: ',
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
                                                                Expanded(
                                                                  child: Text(
                                                                    getJsonField(
                                                                      mainContainerGQLgetByFunctionResponse
                                                                          .jsonBody,
                                                                      r'''$.data.pep_vw_consolidated_data[:].secondary_insurance_provider''',
                                                                    ).toString(),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .start,
                                                                    maxLines: 4,
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.poppins(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).secondaryText,
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
                                                                ),
                                                              ].divide(SizedBox(
                                                                  width: 10.0)),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  'Secondary Insurance\nNumber: ',
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
                                                                Expanded(
                                                                  child: Text(
                                                                    getJsonField(
                                                                      mainContainerGQLgetByFunctionResponse
                                                                          .jsonBody,
                                                                      r'''$.data.pep_vw_consolidated_data[:].secondary_insurance_id''',
                                                                    ).toString(),
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.poppins(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).secondaryText,
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
                                                                ),
                                                              ].divide(SizedBox(
                                                                  width: 10.0)),
                                                            ),
                                                          ),
                                                        ].divide(SizedBox(
                                                            width: 20.0)),
                                                      ),
                                                      SingleChildScrollView(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              children: [
                                                                Text(
                                                                  'EMR:',
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
                                                                Text(
                                                                  getJsonField(
                                                                    mainContainerGQLgetByFunctionResponse
                                                                        .jsonBody,
                                                                    r'''$.data.pep_vw_consolidated_data[:].emr_id''',
                                                                  ).toString(),
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
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .secondaryText,
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
                                                              ].divide(SizedBox(
                                                                  width: 10.0)),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          40.0,
                                                                          0.0,
                                                                          0.0,
                                                                          0.0),
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Text(
                                                                    'Program Eligibilty:',
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.poppins(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
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
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelMedium
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.poppins(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                          ),
                                                                          fontSize:
                                                                              16.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontStyle,
                                                                        ),
                                                                  ),
                                                                ].divide(SizedBox(
                                                                    width:
                                                                        10.0)),
                                                              ),
                                                            ),
                                                            Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              children: [
                                                                Text(
                                                                  'Assigned Vitals:',
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
                                                                Text(
                                                                  (List<String>
                                                                      ccmVitals) {
                                                                    return ccmVitals !=
                                                                            []
                                                                        ? ccmVitals
                                                                            .join(', ')
                                                                        : "N/A";
                                                                  }((getJsonField(
                                                                    mainContainerGQLgetByFunctionResponse
                                                                        .jsonBody,
                                                                    r'''$.data.pep_vw_consolidated_data[:].ccm_vitals''',
                                                                    true,
                                                                  ) as List)
                                                                      .map<String>((s) => s.toString())
                                                                      .toList()),
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
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .secondaryText,
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
                                                              ].divide(SizedBox(
                                                                  width: 10.0)),
                                                            ),
                                                          ].divide(SizedBox(
                                                              width: 20.0)),
                                                        ),
                                                      ),
                                                    ].divide(
                                                        SizedBox(height: 20.0)),
                                                  ),
                                                ),
                                              ),
                                            ].divide(SizedBox(width: 20.0)),
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (true /* Warning: Trying to access variable not yet defined. */)
                                      Align(
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0),
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 12.0, 0.0, 0.0),
                                          child: FutureBuilder<ApiCallResponse>(
                                            future: FFAppState()
                                                .rpmStatusUpdatesPES(
                                              requestFn: () =>
                                                  GQLgetByFunctionCall.call(
                                                hasuraToken:
                                                    FFAppState().hasuraToken,
                                                requestBody: functions
                                                    .getRPMStatusUpdates(widget
                                                        .patientClinicDataID!)
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
                                                height: 240.0,
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
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    if (GQLgetByFunctionCall
                                                                .rpmStatusUpdates(
                                                              containerGQLgetByFunctionResponse
                                                                  .jsonBody,
                                                            ) !=
                                                            null &&
                                                        (GQLgetByFunctionCall
                                                                .rpmStatusUpdates(
                                                          containerGQLgetByFunctionResponse
                                                              .jsonBody,
                                                        ))!
                                                            .isNotEmpty)
                                                      Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                -1.0, -1.0),
                                                        child: Text(
                                                          'RPM Enrollment Attempts:',
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
                                                                fontSize: 16.0,
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
                                                    if (functions
                                                        .isPatientAlreadyEnrolled(
                                                            GQLgetByFunctionCall
                                                                    .rpmStatusUpdates(
                                                      containerGQLgetByFunctionResponse
                                                          .jsonBody,
                                                    )!
                                                                .toList()))
                                                      Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                -1.0, 0.0),
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      0.0,
                                                                      4.0,
                                                                      0.0,
                                                                      0.0),
                                                          child: Text(
                                                            'Note: This Patient is already enrolled once for RPM.',
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
                                                      ),
                                                    if (GQLgetByFunctionCall
                                                                .rpmStatusUpdates(
                                                              containerGQLgetByFunctionResponse
                                                                  .jsonBody,
                                                            ) !=
                                                            null &&
                                                        (GQLgetByFunctionCall
                                                                .rpmStatusUpdates(
                                                          containerGQLgetByFunctionResponse
                                                              .jsonBody,
                                                        ))!
                                                            .isNotEmpty)
                                                      Expanded(
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      0.0,
                                                                      12.0,
                                                                      20.0,
                                                                      0.0),
                                                          child: Builder(
                                                            builder: (context) {
                                                              final rpmStatusUpdates = functions
                                                                  .sortAttemptsToDesc(functions
                                                                      .sortAttemptsToDesc(getJsonField(
                                                                        containerGQLgetByFunctionResponse
                                                                            .jsonBody,
                                                                        r'''$.data.pep_vw_consolidated_data[:].rpm_status_updates''',
                                                                        true,
                                                                      )!)
                                                                      .toList())
                                                                  .toList();

                                                              return FlutterFlowDataTable<
                                                                  dynamic>(
                                                                controller: _model
                                                                    .paginatedDataTableController,
                                                                data:
                                                                    rpmStatusUpdates,
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
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .titleLarge
                                                                            .override(
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
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .titleLarge
                                                                            .override(
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
                                                                        'RPM Status',
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .titleLarge
                                                                            .override(
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
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .titleLarge
                                                                            .override(
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
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .titleLarge
                                                                            .override(
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
                                                                dataRowBuilder: (rpmStatusUpdatesItem,
                                                                        rpmStatusUpdatesIndex,
                                                                        selected,
                                                                        onSelectChanged) =>
                                                                    DataRow(
                                                                  cells: [
                                                                    Align(
                                                                      alignment:
                                                                          AlignmentDirectional(
                                                                              -1.0,
                                                                              0.0),
                                                                      child:
                                                                          Text(
                                                                        getJsonField(
                                                                          rpmStatusUpdatesItem,
                                                                          r'''$.id''',
                                                                        ).toString(),
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
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
                                                                      alignment:
                                                                          AlignmentDirectional(
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
                                                                                rpmStatusUpdatesItem,
                                                                                r'''$.timestamp''',
                                                                              ).toString()),
                                                                              getJsonField(
                                                                                containerGQLgetByFunctionResponse.jsonBody,
                                                                                r'''$.data.pep_vw_consolidated_data[:].patient_clinic_timezone''',
                                                                              ).toString())),
                                                                          locale:
                                                                              FFLocalizations.of(context).languageCode,
                                                                        ),
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodySmall
                                                                            .override(
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
                                                                      alignment:
                                                                          AlignmentDirectional(
                                                                              -1.0,
                                                                              0.0),
                                                                      child:
                                                                          Text(
                                                                        getJsonField(
                                                                          rpmStatusUpdatesItem,
                                                                          r'''$.status''',
                                                                        ).toString(),
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
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
                                                                      alignment:
                                                                          AlignmentDirectional(
                                                                              -1.0,
                                                                              0.0),
                                                                      child:
                                                                          Builder(
                                                                        builder:
                                                                            (context) =>
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
                                                                                        rpmStatusUpdatesItem,
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
                                                                            decoration:
                                                                                BoxDecoration(),
                                                                            child:
                                                                                Text(
                                                                              getJsonField(
                                                                                rpmStatusUpdatesItem,
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
                                                                    ),
                                                                    Align(
                                                                      alignment:
                                                                          AlignmentDirectional(
                                                                              -1.0,
                                                                              0.0),
                                                                      child:
                                                                          Text(
                                                                        functions.returnUsername(
                                                                            FFAppState().usernames.toList(),
                                                                            getJsonField(
                                                                              rpmStatusUpdatesItem,
                                                                              r'''$.user_id''',
                                                                            )),
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
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
                                                                          DataCell(
                                                                              c))
                                                                      .toList(),
                                                                ),
                                                                paginated: true,
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
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
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
                                                      ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    Align(
                                      alignment:
                                          AlignmentDirectional(-1.0, 0.0),
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0.0, 20.0, 0.0, 0.0),
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
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
                                                            MainAxisSize.max,
                                                        children: [
                                                          Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    0.0, 0.0),
                                                            child: Text(
                                                              'RPM Status:',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
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
                                                          Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    0.0, 0.0),
                                                            child: FutureBuilder<
                                                                ApiCallResponse>(
                                                              future: FFAppState()
                                                                  .rpmStatusListPES(
                                                                requestFn: () =>
                                                                    GQLgetByFunctionCall
                                                                        .call(
                                                                  hasuraToken:
                                                                      FFAppState()
                                                                          .hasuraToken,
                                                                  requestBody:
                                                                      '{\"query\":\"query MyQuery {pep_v2_status_mapping_rpm(where: {pes: {_eq: true}}, order_by: {id: asc}) { id status }}\"}',
                                                                ),
                                                              ),
                                                              builder: (context,
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
                                                                        valueColor:
                                                                            AlwaysStoppedAnimation<Color>(
                                                                          FlutterFlowTheme.of(context)
                                                                              .primary,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  );
                                                                }
                                                                final rpmStatusGQLgetByFunctionResponse =
                                                                    snapshot
                                                                        .data!;

                                                                return FlutterFlowDropDown<
                                                                    int>(
                                                                  controller: _model
                                                                          .rpmStatusValueController ??=
                                                                      FormFieldController<
                                                                              int>(
                                                                          null),
                                                                  options: List<
                                                                          int>.from(
                                                                      getJsonField(
                                                                    rpmStatusGQLgetByFunctionResponse
                                                                        .jsonBody,
                                                                    r'''$.data.pep_v2_status_mapping_rpm[:].id''',
                                                                    true,
                                                                  )!),
                                                                  optionLabels:
                                                                      (getJsonField(
                                                                    rpmStatusGQLgetByFunctionResponse
                                                                        .jsonBody,
                                                                    r'''$.data.pep_v2_status_mapping_rpm[:].status''',
                                                                    true,
                                                                  ) as List)
                                                                          .map<String>((s) =>
                                                                              s.toString())
                                                                          .toList(),
                                                                  onChanged:
                                                                      (val) async {
                                                                    safeSetState(() =>
                                                                        _model.rpmStatusValue =
                                                                            val);
                                                                    _model.rpmStatus =
                                                                        _model
                                                                            .rpmStatusValue!;
                                                                    safeSetState(
                                                                        () {});
                                                                  },
                                                                  width: 300.0,
                                                                  height: 50.0,
                                                                  textStyle: FlutterFlowTheme.of(
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
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .textColor,
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
                                                                  hintText:
                                                                      'Select RPM Status',
                                                                  icon: Icon(
                                                                    Icons
                                                                        .keyboard_arrow_down_rounded,
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondaryText,
                                                                    size: 24.0,
                                                                  ),
                                                                  fillColor: FlutterFlowTheme.of(
                                                                          context)
                                                                      .accent1,
                                                                  elevation:
                                                                      2.0,
                                                                  borderColor:
                                                                      FlutterFlowTheme.of(
                                                                              context)
                                                                          .borderColor,
                                                                  borderWidth:
                                                                      1.0,
                                                                  borderRadius:
                                                                      8.0,
                                                                  margin: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          16.0,
                                                                          0.0,
                                                                          16.0,
                                                                          0.0),
                                                                  hidesUnderline:
                                                                      true,
                                                                  isOverButton:
                                                                      true,
                                                                  isSearchable:
                                                                      false,
                                                                  isMultiSelect:
                                                                      false,
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                          if ((_model.rpmStatus ==
                                                                  (2)) &&
                                                              (functions
                                                                      .returnInt(
                                                                          getJsonField(
                                                                        mainContainerGQLgetByFunctionResponse
                                                                            .jsonBody,
                                                                        r'''$.data.pep_vw_consolidated_data[:].rpm_status''',
                                                                      ))
                                                                      .toString() ==
                                                                  ("2")))
                                                            Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
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
                                                                      'Current Appointment Date & Time:',
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
                                                          if ((_model.rpmStatus ==
                                                                  (2)) &&
                                                              (functions
                                                                      .returnInt(
                                                                          getJsonField(
                                                                        mainContainerGQLgetByFunctionResponse
                                                                            .jsonBody,
                                                                        r'''$.data.pep_vw_consolidated_data[:].rpm_status''',
                                                                      ))
                                                                      .toString() ==
                                                                  ("2")))
                                                            Align(
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                      0.0, 0.0),
                                                              child: Text(
                                                                dateTimeFormat(
                                                                  "MM/dd/yy h:mm a",
                                                                  functions.returnDT(
                                                                      (String?
                                                                          inputString) {
                                                                    return (inputString ==
                                                                                "null" ||
                                                                            inputString ==
                                                                                null)
                                                                        ? ""
                                                                        : inputString;
                                                                  }(getJsonField(
                                                                    mainContainerGQLgetByFunctionResponse
                                                                        .jsonBody,
                                                                    r'''$.data.pep_vw_consolidated_data[:].rpm_appointment_dt''',
                                                                  ).toString())),
                                                                  locale: FFLocalizations.of(
                                                                          context)
                                                                      .languageCode,
                                                                ),
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
                                                        ].divide(SizedBox(
                                                            width: 20.0)),
                                                      ),
                                                      if ((_model.rpmStatus ==
                                                              (2)) ||
                                                          (_model.rpmStatus ==
                                                              (7)))
                                                        Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
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
                                                                      'Next Appointment Date & Time:',
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
                                                                if ((_model.rpmStatus ==
                                                                        (2)) &&
                                                                    (functions
                                                                            .returnInt(getJsonField(
                                                                              mainContainerGQLgetByFunctionResponse.jsonBody,
                                                                              r'''$.data.pep_vw_consolidated_data[:].rpm_status''',
                                                                            ))
                                                                            .toString() ==
                                                                        ("2")))
                                                                  Text(
                                                                    'Set only if wish to update current RPM appointment date and time',
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelMedium
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.poppins(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                          ),
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontStyle,
                                                                        ),
                                                                  ),
                                                              ],
                                                            ),
                                                            Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          0.0,
                                                                          0.0,
                                                                          4.0),
                                                                  child: Text(
                                                                    'Select Facility',
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.poppins(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                          ),
                                                                          fontSize:
                                                                              12.0,
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
                                                                ),
                                                                FutureBuilder<
                                                                    ApiCallResponse>(
                                                                  future: FFAppState()
                                                                      .facilityList(
                                                                    requestFn: () =>
                                                                        GQLgetFacilityNamesCall
                                                                            .call(
                                                                      hasuraToken:
                                                                          FFAppState()
                                                                              .hasuraToken,
                                                                      clinicID: widget
                                                                          .clinicID
                                                                          ?.toString(),
                                                                    ),
                                                                  ),
                                                                  builder: (context,
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
                                                                            valueColor:
                                                                                AlwaysStoppedAnimation<Color>(
                                                                              FlutterFlowTheme.of(context).primary,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      );
                                                                    }
                                                                    final facilityGQLgetFacilityNamesResponse =
                                                                        snapshot
                                                                            .data!;

                                                                    return FlutterFlowDropDown<
                                                                        int>(
                                                                      controller: _model
                                                                              .facilityValueController ??=
                                                                          FormFieldController<
                                                                              int>(
                                                                        _model.facilityValue ??=
                                                                            0,
                                                                      ),
                                                                      options: List<
                                                                              int>.from(
                                                                          getJsonField(
                                                                        facilityGQLgetFacilityNamesResponse
                                                                            .jsonBody,
                                                                        r'''$.data.pep_vw_consolidated_data[:].facility_id''',
                                                                        true,
                                                                      )!),
                                                                      optionLabels: (getJsonField(
                                                                        facilityGQLgetFacilityNamesResponse
                                                                            .jsonBody,
                                                                        r'''$.data.pep_vw_consolidated_data[:].facility_name''',
                                                                        true,
                                                                      ) as List)
                                                                          .map<String>((s) => s.toString())
                                                                          .toList(),
                                                                      onChanged:
                                                                          (val) async {
                                                                        safeSetState(() =>
                                                                            _model.facilityValue =
                                                                                val);
                                                                        FFAppState()
                                                                            .clearApptDateCache();
                                                                        safeSetState(
                                                                            () {
                                                                          _model
                                                                              .rPMAppDateValueController
                                                                              ?.reset();
                                                                          _model
                                                                              .rPMAppTimeValueController
                                                                              ?.reset();
                                                                        });
                                                                        FFAppState()
                                                                            .clearApptTimeCache();
                                                                      },
                                                                      width:
                                                                          300.0,
                                                                      height:
                                                                          48.0,
                                                                      textStyle: FlutterFlowTheme.of(
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
                                                                      hintText:
                                                                          'Select Facility',
                                                                      icon:
                                                                          Icon(
                                                                        Icons
                                                                            .keyboard_arrow_down_rounded,
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .secondaryText,
                                                                        size:
                                                                            24.0,
                                                                      ),
                                                                      fillColor:
                                                                          FlutterFlowTheme.of(context)
                                                                              .accent1,
                                                                      elevation:
                                                                          2.0,
                                                                      borderColor:
                                                                          FlutterFlowTheme.of(context)
                                                                              .borderColor,
                                                                      borderWidth:
                                                                          1.0,
                                                                      borderRadius:
                                                                          8.0,
                                                                      margin: EdgeInsetsDirectional.fromSTEB(
                                                                          16.0,
                                                                          0.0,
                                                                          16.0,
                                                                          4.0),
                                                                      hidesUnderline:
                                                                          true,
                                                                      isOverButton:
                                                                          true,
                                                                      isSearchable:
                                                                          false,
                                                                      isMultiSelect:
                                                                          false,
                                                                    );
                                                                  },
                                                                ),
                                                              ],
                                                            ),
                                                            if (_model
                                                                    .facilityValue !=
                                                                null)
                                                              Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                children: [
                                                                  FutureBuilder<
                                                                      ApiCallResponse>(
                                                                    future: FFAppState()
                                                                        .apptDate(
                                                                      requestFn:
                                                                          () =>
                                                                              GQLgetByFunctionCall.call(
                                                                        hasuraToken:
                                                                            FFAppState().hasuraToken,
                                                                        requestBody: functions
                                                                            .getAppointmentDates(_model.facilityValue!)
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
                                                                      final rowGQLgetByFunctionResponse =
                                                                          snapshot
                                                                              .data!;

                                                                      return Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.max,
                                                                        children: [
                                                                          if (getJsonField(
                                                                                rowGQLgetByFunctionResponse.jsonBody,
                                                                                r'''$.data.pep_vw_available_clinic_appointments[:].appointment_date''',
                                                                              ) !=
                                                                              null)
                                                                            Align(
                                                                              alignment: AlignmentDirectional(0.0, 0.0),
                                                                              child: FlutterFlowDropDown<String>(
                                                                                controller: _model.rPMAppDateValueController ??= FormFieldController<String>(
                                                                                  _model.rPMAppDateValue ??= '',
                                                                                ),
                                                                                options: List<String>.from((getJsonField(
                                                                                  rowGQLgetByFunctionResponse.jsonBody,
                                                                                  r'''$.data.pep_vw_available_clinic_appointments[:].appointment_date''',
                                                                                  true,
                                                                                ) as List)
                                                                                    .map<String>((s) => s.toString())
                                                                                    .toList()),
                                                                                optionLabels: (getJsonField(
                                                                                  rowGQLgetByFunctionResponse.jsonBody,
                                                                                  r'''$.data.pep_vw_available_clinic_appointments[:].fmt_appointment_date''',
                                                                                  true,
                                                                                ) as List)
                                                                                    .map<String>((s) => s.toString())
                                                                                    .toList(),
                                                                                onChanged: (val) async {
                                                                                  safeSetState(() => _model.rPMAppDateValue = val);
                                                                                  FFAppState().clearApptTimeCache();
                                                                                  safeSetState(() {
                                                                                    _model.rPMAppTimeValueController?.reset();
                                                                                  });
                                                                                },
                                                                                width: 160.0,
                                                                                height: 50.0,
                                                                                textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                      font: GoogleFonts.poppins(
                                                                                        fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                      ),
                                                                                      fontSize: 16.0,
                                                                                      letterSpacing: 0.0,
                                                                                      fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                    ),
                                                                                hintText: 'Select Date',
                                                                                icon: Icon(
                                                                                  Icons.keyboard_arrow_down_rounded,
                                                                                  color: FlutterFlowTheme.of(context).textColor,
                                                                                  size: 24.0,
                                                                                ),
                                                                                fillColor: FlutterFlowTheme.of(context).accent1,
                                                                                elevation: 2.0,
                                                                                borderColor: FlutterFlowTheme.of(context).borderColor,
                                                                                borderWidth: 1.2,
                                                                                borderRadius: 8.0,
                                                                                margin: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                                                hidesUnderline: true,
                                                                                isOverButton: true,
                                                                                isSearchable: false,
                                                                                isMultiSelect: false,
                                                                              ),
                                                                            ),
                                                                          if (getJsonField(
                                                                                rowGQLgetByFunctionResponse.jsonBody,
                                                                                r'''$.data.pep_vw_available_clinic_appointments[:].appointment_date''',
                                                                              ) ==
                                                                              null)
                                                                            Text(
                                                                              'No Slots Available',
                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                    font: GoogleFonts.poppins(
                                                                                      fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                    ),
                                                                                    letterSpacing: 0.0,
                                                                                    fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                  ),
                                                                            ),
                                                                        ],
                                                                      );
                                                                    },
                                                                  ),
                                                                  if (_model.rPMAppDateValue !=
                                                                          null &&
                                                                      _model.rPMAppDateValue !=
                                                                          '')
                                                                    Align(
                                                                      alignment:
                                                                          AlignmentDirectional(
                                                                              0.0,
                                                                              0.0),
                                                                      child: FutureBuilder<
                                                                          ApiCallResponse>(
                                                                        future:
                                                                            FFAppState().apptTime(
                                                                          requestFn: () =>
                                                                              GQLgetByFunctionCall.call(
                                                                            hasuraToken:
                                                                                FFAppState().hasuraToken,
                                                                            requestBody:
                                                                                functions.getAppointmentTimes(_model.facilityValue!, _model.rPMAppDateValue!).toString(),
                                                                          ),
                                                                        ),
                                                                        builder:
                                                                            (context,
                                                                                snapshot) {
                                                                          // Customize what your widget looks like when it's loading.
                                                                          if (!snapshot
                                                                              .hasData) {
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
                                                                          final rPMAppTimeGQLgetByFunctionResponse =
                                                                              snapshot.data!;

                                                                          return FlutterFlowDropDown<
                                                                              String>(
                                                                            controller: _model.rPMAppTimeValueController ??=
                                                                                FormFieldController<String>(
                                                                              _model.rPMAppTimeValue ??= '',
                                                                            ),
                                                                            options: List<String>.from((getJsonField(
                                                                              rPMAppTimeGQLgetByFunctionResponse.jsonBody,
                                                                              r'''$.data.pep_vw_available_clinic_appointments[:].appointment_hour''',
                                                                              true,
                                                                            ) as List)
                                                                                .map<String>((s) => s.toString())
                                                                                .toList()),
                                                                            optionLabels: (getJsonField(
                                                                              rPMAppTimeGQLgetByFunctionResponse.jsonBody,
                                                                              r'''$.data.pep_vw_available_clinic_appointments[:].fmt_appointment_hour''',
                                                                              true,
                                                                            ) as List)
                                                                                .map<String>((s) => s.toString())
                                                                                .toList(),
                                                                            onChanged: (val) =>
                                                                                safeSetState(() => _model.rPMAppTimeValue = val),
                                                                            width:
                                                                                160.0,
                                                                            height:
                                                                                50.0,
                                                                            textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                  font: GoogleFonts.poppins(
                                                                                    fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                  ),
                                                                                  fontSize: 16.0,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                ),
                                                                            hintText:
                                                                                'Select Time',
                                                                            icon:
                                                                                Icon(
                                                                              Icons.keyboard_arrow_down_rounded,
                                                                              color: FlutterFlowTheme.of(context).textColor,
                                                                              size: 24.0,
                                                                            ),
                                                                            fillColor:
                                                                                FlutterFlowTheme.of(context).accent1,
                                                                            elevation:
                                                                                2.0,
                                                                            borderColor:
                                                                                FlutterFlowTheme.of(context).borderColor,
                                                                            borderWidth:
                                                                                1.2,
                                                                            borderRadius:
                                                                                8.0,
                                                                            margin: EdgeInsetsDirectional.fromSTEB(
                                                                                16.0,
                                                                                0.0,
                                                                                16.0,
                                                                                0.0),
                                                                            hidesUnderline:
                                                                                true,
                                                                            isOverButton:
                                                                                true,
                                                                            isSearchable:
                                                                                false,
                                                                            isMultiSelect:
                                                                                false,
                                                                          );
                                                                        },
                                                                      ),
                                                                    ),
                                                                ].divide(SizedBox(
                                                                    width:
                                                                        20.0)),
                                                              ),
                                                          ].divide(SizedBox(
                                                              width: 20.0)),
                                                        ),
                                                    ].divide(
                                                        SizedBox(height: 10.0)),
                                                  ),
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                -1.0, 0.0),
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
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
                                                            Padding(
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          10.0,
                                                                          0.0,
                                                                          0.0),
                                                              child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .accent1,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8.0),
                                                                  border: Border
                                                                      .all(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .borderColor,
                                                                  ),
                                                                ),
                                                                child:
                                                                    Container(
                                                                  width: 650.0,
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
                                                                      hintStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelSmall
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FlutterFlowTheme.of(context).labelSmall.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelSmall.fontStyle,
                                                                            ),
                                                                            color:
                                                                                FlutterFlowTheme.of(context).secondaryText,
                                                                            fontSize:
                                                                                14.0,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelSmall.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelSmall.fontStyle,
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
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).textColor,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontStyle,
                                                                        ),
                                                                    maxLines: 2,
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
                                                    ],
                                                  ),
                                                ].divide(
                                                    SizedBox(height: 20.0)),
                                              ),
                                            ].divide(SizedBox(width: 20.0)),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: AlignmentDirectional(0.0, 0.0),
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0.0, 20.0, 0.0, 20.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Align(
                                              alignment: AlignmentDirectional(
                                                  1.0, 0.0),
                                              child: FFButtonWidget(
                                                onPressed: (FFAppState()
                                                            .isDetailsSaved ==
                                                        true)
                                                    ? null
                                                    : () async {
                                                        if ((_model.rpmStatus !=
                                                                null) &&
                                                            (_model.rpmStatusValue !=
                                                                (0))) {
                                                          if (_model.commentTextController
                                                                      .text !=
                                                                  '') {
                                                            if (((_model.rpmStatusValue ==
                                                                        (2)) &&
                                                                    ((_model.facilityValue !=
                                                                            null) &&
                                                                        (_model.rPMAppDateValue !=
                                                                                null &&
                                                                            _model.rPMAppDateValue !=
                                                                                '') &&
                                                                        (_model.rPMAppTimeValue !=
                                                                                null &&
                                                                            _model.rPMAppTimeValue !=
                                                                                ''))) ||
                                                                (_model.rpmStatusValue !=
                                                                    (2))) {
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
                                                                    widget
                                                                        .patientClinicDataID,
                                                                requestBody: functions.patientUpdateGlobal(
                                                                    null,
                                                                    null,
                                                                    (null)
                                                                        ?.toList(),
                                                                    _model
                                                                        .rpmStatusValue,
                                                                    _model
                                                                        .rPMAppDateValue,
                                                                    _model
                                                                        .rPMAppTimeValue,
                                                                    _model
                                                                        .facilityValue,
                                                                    (null)
                                                                        ?.toList(),
                                                                    null,
                                                                    (null)
                                                                        ?.toList(),
                                                                    null,
                                                                    null,
                                                                    null,
                                                                    null,
                                                                    null,
                                                                    null,
                                                                    null,
                                                                    null,
                                                                    null,
                                                                    null,
                                                                    null,
                                                                    null,
                                                                    null,
                                                                    null,
                                                                    null,
                                                                    null,
                                                                    null,
                                                                    null,
                                                                    false,
                                                                    _model
                                                                        .commentTextController
                                                                        .text,
                                                                    null,
                                                                    null,
                                                                    FFAppState()
                                                                        .currentPatientGroupID,
                                                                    false,
                                                                    false),
                                                              );

                                                              if ((_model
                                                                      .updatePatient
                                                                      ?.succeeded ??
                                                                  true)) {
                                                                FFAppState()
                                                                        .isDetailsSaved =
                                                                    true;
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

                                                                context.goNamed(
                                                                  ReloadPageWidget
                                                                      .routeName,
                                                                  queryParameters:
                                                                      {
                                                                    'patientClinicDataID':
                                                                        serializeParam(
                                                                      widget
                                                                          .patientClinicDataID,
                                                                      ParamType
                                                                          .int,
                                                                    ),
                                                                    'clinicID':
                                                                        serializeParam(
                                                                      widget
                                                                          .clinicID,
                                                                      ParamType
                                                                          .int,
                                                                    ),
                                                                    'pesReload':
                                                                        serializeParam(
                                                                      true,
                                                                      ParamType
                                                                          .bool,
                                                                    ),
                                                                    'pesScreenType':
                                                                        serializeParam(
                                                                      widget
                                                                          .pesScreenType,
                                                                      ParamType
                                                                          .Enum,
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
                                                                      'Patient Update Failed',
                                                                      style:
                                                                          TextStyle(
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .secondary,
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
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .showSnackBar(
                                                                SnackBar(
                                                                  content: Text(
                                                                    'Appointment details has to be set before saving',
                                                                    style: GoogleFonts
                                                                        .poppins(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .secondary,
                                                                    ),
                                                                  ),
                                                                  duration: Duration(
                                                                      milliseconds:
                                                                          4000),
                                                                  backgroundColor:
                                                                      FlutterFlowTheme.of(
                                                                              context)
                                                                          .error,
                                                                ),
                                                              );
                                                            }
                                                          } else {
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              SnackBar(
                                                                content: Text(
                                                                  'Please add a comment',
                                                                  style: GoogleFonts
                                                                      .poppins(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondary,
                                                                  ),
                                                                ),
                                                                duration: Duration(
                                                                    milliseconds:
                                                                        4000),
                                                                backgroundColor:
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .error,
                                                              ),
                                                            );
                                                          }
                                                        } else {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                'The CCM/RPM status need to be selected/updated',
                                                                style:
                                                                    GoogleFonts
                                                                        .poppins(
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondary,
                                                                ),
                                                              ),
                                                              duration: Duration(
                                                                  milliseconds:
                                                                      4000),
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
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          24.0, 0.0, 24.0, 0.0),
                                                  iconPadding:
                                                      EdgeInsetsDirectional
                                                          .fromSTEB(0.0, 0.0,
                                                              0.0, 0.0),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .tertiary,
                                                  textStyle: FlutterFlowTheme
                                                          .of(context)
                                                      .titleSmall
                                                      .override(
                                                        font:
                                                            GoogleFonts.poppins(
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
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .buttonText,
                                                        letterSpacing: 0.0,
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
                                                          .alternate,
                                                ),
                                              ),
                                            ),
                                            FFButtonWidget(
                                              onPressed: () async {
                                                FFAppState()
                                                    .clearPatientDetailsCacheCache();
                                                FFAppState()
                                                    .clearRpmStatusUpdatesPESCache();
                                                FFAppState()
                                                    .clearFacilityListCache();
                                                FFAppState().isDetailsSaved =
                                                    false;
                                                safeSetState(() {});
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
                                                if (_model
                                                    .instantTimer.isActive) {
                                                  _model.instantTimer?.cancel();
                                                } else {
                                                  _model.instantTimerNested
                                                      ?.cancel();
                                                  _model
                                                      .patientInstantTimerNested
                                                      ?.cancel();
                                                }

                                                if (widget.pesScreenType ==
                                                    PESScreenType.PatientList) {
                                                  context.goNamed(
                                                    PESPatientListWidget
                                                        .routeName,
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
                                                } else if (widget
                                                        .pesScreenType ==
                                                    PESScreenType
                                                        .DeferredList) {
                                                  context.goNamed(
                                                    PESDeferredPatientListWidget
                                                        .routeName,
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
                                                } else if (widget
                                                        .pesScreenType ==
                                                    PESScreenType
                                                        .FollowUpList) {
                                                  context.goNamed(
                                                    PESFollowUpPatientListWidget
                                                        .routeName,
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
                                                }
                                              },
                                              text: 'Cancel',
                                              options: FFButtonOptions(
                                                width: 130.0,
                                                height: 38.0,
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        24.0, 0.0, 24.0, 0.0),
                                                iconPadding:
                                                    EdgeInsetsDirectional
                                                        .fromSTEB(
                                                            0.0, 0.0, 0.0, 0.0),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .accent3,
                                                textStyle: FlutterFlowTheme.of(
                                                        context)
                                                    .titleSmall
                                                    .override(
                                                      font: GoogleFonts.poppins(
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
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .buttonText,
                                                      letterSpacing: 0.0,
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
                                                    BorderRadius.circular(8.0),
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
                ],
              ),
            ),
          ),
        ));
  }
}
