import '/backend/api_requests/api_calls.dart';
import '/backend/schema/enums/enums.dart';
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
import '/index.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'g_s_patient_view_model.dart';
export 'g_s_patient_view_model.dart';

class GSPatientViewWidget extends StatefulWidget {
  const GSPatientViewWidget({
    super.key,
    required this.patientClinicDataID,
    required this.clinicID,
  });

  final int? patientClinicDataID;
  final int? clinicID;

  static String routeName = 'GSPatientView';
  static String routePath = 'GSPatientView';

  @override
  State<GSPatientViewWidget> createState() => _GSPatientViewWidgetState();
}

class _GSPatientViewWidgetState extends State<GSPatientViewWidget>
    with TickerProviderStateMixin {
  late GSPatientViewModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => GSPatientViewModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (FFAppState().loginToken != '') {
        _model.createPatientTimeButtongGSLog =
            await PEPAPIsGroup.createPatientTimerLogCall.call(
          userId: FFAppState().loginProfileID,
          authToken: FFAppState().loginToken,
          pepPatientId: widget.patientClinicDataID,
        );

        if ((_model.createPatientTimeButtongGSLog?.succeeded ?? true)) {
          _model.patientTimerLogId = PEPAPIsGroup.createPatientTimerLogCall
              .timeLogId(
                (_model.createPatientTimeButtongGSLog?.jsonBody ?? ''),
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
        FFAppState().clearCcmStatusUpdatesGSCache();
        FFAppState().clearRpmStatusUpdatesGSCache();
        FFAppState().transferPatient = false;
        safeSetState(() {});

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
        _model.isTransferPatientExecuted = false;
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
            if ((FFAppState().usertype != FFAppConstants.UserTypeGA) &&
                (FFAppState().usertype != FFAppConstants.UserTypeEA) &&
                (FFAppState().usertype != FFAppConstants.UserTypeCA) &&
                (FFAppState().usertype != FFAppConstants.UserTypePA)) {
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

    _model.firstNameFocusNode ??= FocusNode();

    _model.lastNameFocusNode ??= FocusNode();

    _model.tfMobilePhoneNumberFocusNode ??= FocusNode();

    _model.tfHomePhoneNumberFocusNode ??= FocusNode();

    _model.emailFocusNode ??= FocusNode();

    _model.addressFocusNode ??= FocusNode();

    _model.cityFocusNode ??= FocusNode();

    _model.stateFocusNode ??= FocusNode();

    _model.zipcodeFocusNode ??= FocusNode();

    _model.emrFocusNode ??= FocusNode();

    _model.primaryInsFocusNode ??= FocusNode();

    _model.primaryInsNumberFocusNode ??= FocusNode();

    _model.secondaryInsFocusNode ??= FocusNode();

    _model.secondaryInsNumberFocusNode ??= FocusNode();

    _model.tabBarController = TabController(
      vsync: this,
      length: 2,
      initialIndex: 0,
    )..addListener(() => safeSetState(() {}));

    _model.txtFieldCommentTextController ??= TextEditingController();
    _model.txtFieldCommentFocusNode ??= FocusNode();

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
        title: 'GSPatientView',
        color: FlutterFlowTheme.of(context).primary.withAlpha(0XFF),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).primary,
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
                      child: Row(
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
                                'Global Search - Patient Details',
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
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        if ((FFAppState().usertype !=
                                FFAppConstants.UserTypeGA) &&
                            (FFAppState().usertype !=
                                FFAppConstants.UserTypeEA) &&
                            (FFAppState().usertype !=
                                FFAppConstants.UserTypeCA) &&
                            (FFAppState().usertype !=
                                FFAppConstants.UserTypePA))
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
                                              FFAppState().timerState =
                                                  FFAppState().timerState;
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
                                                _model.InstantTimerNested
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
                                              if (!_model
                                                  .instantTimer.isActive) {
                                                _model.InstantTimerNested =
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
                                                          FFAppState()
                                                              .timerState;
                                                      safeSetState(() {});
                                                      _model.patientTimerState =
                                                          _model
                                                              .patientTimerState;
                                                      safeSetState(() {});
                                                      FFAppState()
                                                              .isAppMinimized =
                                                          true;
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
                                                          timelogId:
                                                              FFAppState()
                                                                  .timerlogId,
                                                          authToken:
                                                              FFAppState()
                                                                  .loginToken,
                                                        );

                                                        FFAppState()
                                                                .timerState =
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
                                                          authToken:
                                                              FFAppState()
                                                                  .loginToken,
                                                          timelogId: _model
                                                              .patientTimerLogId,
                                                          pepPatientId: widget
                                                              .patientClinicDataID,
                                                        );

                                                        _model.patientTimerState =
                                                            _model
                                                                .patientTimerState;
                                                        safeSetState(() {});
                                                      }

                                                      FFAppState()
                                                              .isAppMinimized =
                                                          false;
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
                                      controller:
                                          _model.sessionTimerController1,
                                      updateStateInterval:
                                          Duration(milliseconds: 1000),
                                      onChanged:
                                          (value, displayTime, shouldUpdate) {
                                        _model.sessionTimerMilliseconds1 =
                                            value;
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

                              safeSetState(() {});
                              FFAppState().timerState = FFAppState().timerState;
                              safeSetState(() {});
                              _model.patientTimerState =
                                  _model.patientTimerState;
                              safeSetState(() {});
                              FFAppState().timerState =
                                  _model.sessionTimerMilliseconds1;
                              safeSetState(() {});
                              _model.patientTimerState =
                                  _model.sessionTimerMilliseconds2;
                              safeSetState(() {});
                              _model.sessionTimerController1.onResetTimer();

                              if (_model.InstantTimerNested.isActive) {
                                _model.instantTimer?.cancel();
                              } else {
                                _model.InstantTimerNested?.cancel();
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
                      final mainGQLgetByFunctionResponse = snapshot.data!;

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
                            Padding(
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
                                      mainAxisAlignment: MainAxisAlignment.end,
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
                                                mainAxisSize: MainAxisSize.max,
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
                                                        borderColor:
                                                            Colors.transparent,
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
                                                            safeSetState(() {});
                                                            _model.patientTimerState =
                                                                _model
                                                                    .sessionTimerMilliseconds2;
                                                            safeSetState(() {});
                                                            FFAppState()
                                                                    .timerState =
                                                                FFAppState()
                                                                    .timerState;
                                                            safeSetState(() {});
                                                            _model.patientTimerState =
                                                                _model
                                                                    .patientTimerState;
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
                                                              _model
                                                                  .instantTimer
                                                                  ?.cancel();
                                                            } else {
                                                              _model.InstantTimerNested
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
                                                        borderColor:
                                                            Colors.transparent,
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
                                                            safeSetState(() {});
                                                            _model.patientTimerState =
                                                                _model
                                                                    .patientTimerState;
                                                            safeSetState(() {});
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
                                                            safeSetState(() {});
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
                                                                    if (((_model.sessionTimerMilliseconds1 ~/
                                                                                1000) %
                                                                            60) ==
                                                                        0) {
                                                                      _model.updatePatientTimerPlayButton = await PEPAPIsGroup
                                                                          .updateTimerLogCall
                                                                          .call(
                                                                        duration:
                                                                            _model.sessionTimerMilliseconds1 ~/
                                                                                1000,
                                                                        userId:
                                                                            FFAppState().loginProfileID,
                                                                        timelogId:
                                                                            FFAppState().timerlogId,
                                                                        authToken:
                                                                            FFAppState().loginToken,
                                                                      );

                                                                      FFAppState()
                                                                              .timerState =
                                                                          FFAppState()
                                                                              .timerState;
                                                                      safeSetState(
                                                                          () {});
                                                                    } else if (((_model.sessionTimerMilliseconds2 ~/
                                                                                1000) %
                                                                            60) ==
                                                                        0) {
                                                                      _model.updatePatientTimerPlayBtn = await PEPAPIsGroup
                                                                          .updatePatientTimerLogCall
                                                                          .call(
                                                                        duration:
                                                                            _model.sessionTimerMilliseconds2 ~/
                                                                                1000,
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
                                                                          _model
                                                                              .patientTimerState;
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
                                                            milliseconds: 1000),
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
                                                    textAlign: TextAlign.start,
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .poppins(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondary,
                                                          fontSize: 18.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
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
                                              MainAxisAlignment.spaceBetween,
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
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          0.0),
                                                  shape: BoxShape.rectangle,
                                                ),
                                                child: Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          -1.0, 0.0),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    0.0,
                                                                    0.0,
                                                                    0.0,
                                                                    15.0),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
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
                                                                  controller: _model
                                                                          .firstNameTextController ??=
                                                                      TextEditingController(
                                                                    text: (String?
                                                                        inputString) {
                                                                      return (inputString == "null" ||
                                                                              inputString == null)
                                                                          ? ""
                                                                          : inputString;
                                                                    }(getJsonField(
                                                                      mainGQLgetByFunctionResponse
                                                                          .jsonBody,
                                                                      r'''$.data.pep_vw_consolidated_data[:].first_name''',
                                                                    ).toString()),
                                                                  ),
                                                                  focusNode: _model
                                                                      .firstNameFocusNode,
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
                                                                    hintText:
                                                                        'Enter First Name',
                                                                    hintStyle: FlutterFlowTheme.of(
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
                                                                    enabledBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .borderColor,
                                                                        width:
                                                                            1.0,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0),
                                                                    ),
                                                                    focusedBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .tertiary,
                                                                        width:
                                                                            1.0,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0),
                                                                    ),
                                                                    errorBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                        color: Color(
                                                                            0x00000000),
                                                                        width:
                                                                            1.0,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0),
                                                                    ),
                                                                    focusedErrorBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                        color: Color(
                                                                            0x00000000),
                                                                        width:
                                                                            1.0,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0),
                                                                    ),
                                                                    filled:
                                                                        true,
                                                                    fillColor: FlutterFlowTheme.of(
                                                                            context)
                                                                        .accent1,
                                                                    contentPadding:
                                                                        EdgeInsetsDirectional.fromSTEB(
                                                                            10.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                  ),
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMedium
                                                                      .override(
                                                                        font: GoogleFonts
                                                                            .readexPro(
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontStyle,
                                                                        ),
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .textColor,
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
                                                                  maxLength:
                                                                      128,
                                                                  buildCounter: (context,
                                                                          {required currentLength,
                                                                          required isFocused,
                                                                          maxLength}) =>
                                                                      null,
                                                                  cursorColor:
                                                                      FlutterFlowTheme.of(
                                                                              context)
                                                                          .tertiary,
                                                                  validator: _model
                                                                      .firstNameTextControllerValidator
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
                                                                  controller: _model
                                                                          .lastNameTextController ??=
                                                                      TextEditingController(
                                                                    text: (String?
                                                                        inputString) {
                                                                      return (inputString == "null" ||
                                                                              inputString == null)
                                                                          ? ""
                                                                          : inputString;
                                                                    }(getJsonField(
                                                                      mainGQLgetByFunctionResponse
                                                                          .jsonBody,
                                                                      r'''$.data.pep_vw_consolidated_data[:].last_name''',
                                                                    ).toString()),
                                                                  ),
                                                                  focusNode: _model
                                                                      .lastNameFocusNode,
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
                                                                    hintText:
                                                                        'Enter Last Name',
                                                                    hintStyle: FlutterFlowTheme.of(
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
                                                                    enabledBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .borderColor,
                                                                        width:
                                                                            1.0,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0),
                                                                    ),
                                                                    focusedBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .tertiary,
                                                                        width:
                                                                            1.0,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0),
                                                                    ),
                                                                    errorBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                        color: Color(
                                                                            0x00000000),
                                                                        width:
                                                                            1.0,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0),
                                                                    ),
                                                                    focusedErrorBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                        color: Color(
                                                                            0x00000000),
                                                                        width:
                                                                            1.0,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0),
                                                                    ),
                                                                    filled:
                                                                        true,
                                                                    fillColor: FlutterFlowTheme.of(
                                                                            context)
                                                                        .accent1,
                                                                    contentPadding:
                                                                        EdgeInsetsDirectional.fromSTEB(
                                                                            10.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                  ),
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMedium
                                                                      .override(
                                                                        font: GoogleFonts
                                                                            .readexPro(
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontStyle,
                                                                        ),
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .textColor,
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
                                                                  maxLength:
                                                                      128,
                                                                  buildCounter: (context,
                                                                          {required currentLength,
                                                                          required isFocused,
                                                                          maxLength}) =>
                                                                      null,
                                                                  cursorColor:
                                                                      FlutterFlowTheme.of(
                                                                              context)
                                                                          .tertiary,
                                                                  validator: _model
                                                                      .lastNameTextControllerValidator
                                                                      .asValidator(
                                                                          context),
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
                                                                    0.0,
                                                                    0.0,
                                                                    15.0),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Expanded(
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
                                                                          .center,
                                                                  children: [
                                                                    Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      children:
                                                                          [
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
                                                                          (String?
                                                                              inputString) {
                                                                            return (inputString == "null" || inputString == null)
                                                                                ? ""
                                                                                : inputString;
                                                                          }(dateTimeFormat(
                                                                            "MM/dd/yy",
                                                                            functions.returnDT(getJsonField(
                                                                              mainGQLgetByFunctionResponse.jsonBody,
                                                                              r'''$.data.pep_vw_consolidated_data[:].dob''',
                                                                            ).toString()),
                                                                            locale:
                                                                                FFLocalizations.of(context).languageCode,
                                                                          )),
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
                                                                        Align(
                                                                          alignment: AlignmentDirectional(
                                                                              1.0,
                                                                              0.0),
                                                                          child:
                                                                              FFButtonWidget(
                                                                            onPressed:
                                                                                () async {
                                                                              // DOB
                                                                              final _datePicked1Date = await showDatePicker(
                                                                                context: context,
                                                                                initialDate: (functions.returnDT(getJsonField(
                                                                                      mainGQLgetByFunctionResponse.jsonBody,
                                                                                      r'''$.data.pep_vw_consolidated_data[:].dob''',
                                                                                    ).toString()) ??
                                                                                    DateTime.now()),
                                                                                firstDate: DateTime(1900),
                                                                                lastDate: DateTime(2050),
                                                                                builder: (context, child) {
                                                                                  return wrapInMaterialDatePickerTheme(
                                                                                    context,
                                                                                    child!,
                                                                                    headerBackgroundColor: FlutterFlowTheme.of(context).primary,
                                                                                    headerForegroundColor: FlutterFlowTheme.of(context).info,
                                                                                    headerTextStyle: FlutterFlowTheme.of(context).headlineLarge.override(
                                                                                          font: GoogleFonts.poppins(
                                                                                            fontWeight: FontWeight.w600,
                                                                                            fontStyle: FlutterFlowTheme.of(context).headlineLarge.fontStyle,
                                                                                          ),
                                                                                          fontSize: 32.0,
                                                                                          letterSpacing: 0.0,
                                                                                          fontWeight: FontWeight.w600,
                                                                                          fontStyle: FlutterFlowTheme.of(context).headlineLarge.fontStyle,
                                                                                        ),
                                                                                    pickerBackgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                    pickerForegroundColor: FlutterFlowTheme.of(context).primaryText,
                                                                                    selectedDateTimeBackgroundColor: FlutterFlowTheme.of(context).primary,
                                                                                    selectedDateTimeForegroundColor: FlutterFlowTheme.of(context).info,
                                                                                    actionButtonForegroundColor: FlutterFlowTheme.of(context).primaryText,
                                                                                    iconSize: 24.0,
                                                                                  );
                                                                                },
                                                                              );

                                                                              if (_datePicked1Date != null) {
                                                                                safeSetState(() {
                                                                                  _model.datePicked1 = DateTime(
                                                                                    _datePicked1Date.year,
                                                                                    _datePicked1Date.month,
                                                                                    _datePicked1Date.day,
                                                                                  );
                                                                                });
                                                                              } else if (_model.datePicked1 != null) {
                                                                                safeSetState(() {
                                                                                  _model.datePicked1 = functions.returnDT(getJsonField(
                                                                                    mainGQLgetByFunctionResponse.jsonBody,
                                                                                    r'''$.data.pep_vw_consolidated_data[:].dob''',
                                                                                  ).toString());
                                                                                });
                                                                              }
                                                                            },
                                                                            text:
                                                                                valueOrDefault<String>(
                                                                              dateTimeFormat(
                                                                                "d MMM, y",
                                                                                _model.datePicked1,
                                                                                locale: FFLocalizations.of(context).languageCode,
                                                                              ),
                                                                              'Select to Update',
                                                                            ),
                                                                            icon:
                                                                                Icon(
                                                                              Icons.date_range,
                                                                              size: 24.0,
                                                                            ),
                                                                            options:
                                                                                FFButtonOptions(
                                                                              width: 200.0,
                                                                              height: 45.0,
                                                                              padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                                                                              iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                              iconColor: FlutterFlowTheme.of(context).primaryText,
                                                                              color: FlutterFlowTheme.of(context).accent4,
                                                                              textStyle: FlutterFlowTheme.of(context).titleMedium.override(
                                                                                    font: GoogleFonts.poppins(
                                                                                      fontWeight: FlutterFlowTheme.of(context).titleMedium.fontWeight,
                                                                                      fontStyle: FlutterFlowTheme.of(context).titleMedium.fontStyle,
                                                                                    ),
                                                                                    color: FlutterFlowTheme.of(context).primaryText,
                                                                                    fontSize: 16.0,
                                                                                    letterSpacing: 0.0,
                                                                                    fontWeight: FlutterFlowTheme.of(context).titleMedium.fontWeight,
                                                                                    fontStyle: FlutterFlowTheme.of(context).titleMedium.fontStyle,
                                                                                  ),
                                                                              elevation: 1.0,
                                                                              borderSide: BorderSide(
                                                                                color: Colors.transparent,
                                                                                width: 1.0,
                                                                              ),
                                                                              borderRadius: BorderRadius.circular(8.0),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ].divide(SizedBox(
                                                                              width: 10.0)),
                                                                    ),
                                                                    Align(
                                                                      alignment:
                                                                          AlignmentDirectional(
                                                                              -1.0,
                                                                              0.0),
                                                                      child: FlutterFlowDropDown<
                                                                          String>(
                                                                        controller:
                                                                            _model.genderValueController ??=
                                                                                FormFieldController<String>(
                                                                          _model.genderValue ??=
                                                                              (String? inputString) {
                                                                            return (inputString == "null" || inputString == null)
                                                                                ? ""
                                                                                : inputString;
                                                                          }(getJsonField(
                                                                            mainGQLgetByFunctionResponse.jsonBody,
                                                                            r'''$.data.pep_vw_consolidated_data[:].gender''',
                                                                          ).toString()),
                                                                        ),
                                                                        options:
                                                                            List<String>.from([
                                                                          'M',
                                                                          'F'
                                                                        ]),
                                                                        optionLabels: [
                                                                          'Male',
                                                                          'Female'
                                                                        ],
                                                                        onChanged:
                                                                            (val) =>
                                                                                safeSetState(() => _model.genderValue = val),
                                                                        width:
                                                                            200.0,
                                                                        height:
                                                                            48.0,
                                                                        textStyle: FlutterFlowTheme.of(context)
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
                                                                        hintText:
                                                                            'Select Gender',
                                                                        icon:
                                                                            Icon(
                                                                          Icons
                                                                              .keyboard_arrow_down_rounded,
                                                                          color:
                                                                              FlutterFlowTheme.of(context).secondaryText,
                                                                          size:
                                                                              24.0,
                                                                        ),
                                                                        fillColor:
                                                                            FlutterFlowTheme.of(context).accent1,
                                                                        elevation:
                                                                            2.0,
                                                                        borderColor:
                                                                            FlutterFlowTheme.of(context).borderColor,
                                                                        borderWidth:
                                                                            1.0,
                                                                        borderRadius:
                                                                            8.0,
                                                                        margin: EdgeInsetsDirectional.fromSTEB(
                                                                            10.0,
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
                                                                      ),
                                                                    ),
                                                                  ].divide(SizedBox(
                                                                      width:
                                                                          10.0)),
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
                                                                    0.0,
                                                                    0.0,
                                                                    15.0),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
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
                                                                Container(
                                                                  width: 200.0,
                                                                  child: Align(
                                                                    alignment:
                                                                        AlignmentDirectional(
                                                                            0.0,
                                                                            0.0),
                                                                    child:
                                                                        TextFormField(
                                                                      controller:
                                                                          _model.tfMobilePhoneNumberTextController ??=
                                                                              TextEditingController(
                                                                        text: (String?
                                                                            inputString) {
                                                                          return (inputString == "null" || inputString == null)
                                                                              ? ""
                                                                              : inputString;
                                                                        }(getJsonField(
                                                                          mainGQLgetByFunctionResponse
                                                                              .jsonBody,
                                                                          r'''$.data.pep_vw_consolidated_data[:].mobile_phone_number''',
                                                                        ).toString()),
                                                                      ),
                                                                      focusNode:
                                                                          _model
                                                                              .tfMobilePhoneNumberFocusNode,
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
                                                                      textAlign:
                                                                          TextAlign
                                                                              .justify,
                                                                      maxLength:
                                                                          12,
                                                                      buildCounter: (context,
                                                                              {required currentLength,
                                                                              required isFocused,
                                                                              maxLength}) =>
                                                                          null,
                                                                      keyboardType:
                                                                          TextInputType
                                                                              .number,
                                                                      cursorColor:
                                                                          FlutterFlowTheme.of(context)
                                                                              .tertiary,
                                                                      validator: _model
                                                                          .tfMobilePhoneNumberTextControllerValidator
                                                                          .asValidator(
                                                                              context),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Builder(
                                                                  builder:
                                                                      (context) =>
                                                                          Padding(
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            10.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                    child:
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
                                                                                    }(_model.tfMobilePhoneNumberTextController.text)
                                                                                        ? ''
                                                                                        : _model.tfMobilePhoneNumberTextController.text,
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
                                                                ),
                                                                Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          10.0,
                                                                          0.0,
                                                                          0.0,
                                                                          0.0),
                                                                  child:
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
                                                                              .tfMobilePhoneNumberTextController
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
                                                                                mainGQLgetByFunctionResponse.jsonBody,
                                                                                r'''$.data.pep_vw_consolidated_data[:].clinic_id''',
                                                                              ),
                                                                              getJsonField(
                                                                                mainGQLgetByFunctionResponse.jsonBody,
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
                                                                              (_model.getIfPatientCanMakeOutgoingCallResponse?.jsonBody ?? ''),
                                                                              r'''$.data.api_origin_number_master[:]''',
                                                                            ) !=
                                                                            null,
                                                                        child:
                                                                            Builder(
                                                                          builder: (context) =>
                                                                              Padding(
                                                                            padding: EdgeInsetsDirectional.fromSTEB(
                                                                                10.0,
                                                                                0.0,
                                                                                0.0,
                                                                                0.0),
                                                                            child:
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
                                                                                            mainGQLgetByFunctionResponse.jsonBody,
                                                                                            r'''$.data.pep_vw_consolidated_data[:].clinic_id''',
                                                                                          ),
                                                                                          getJsonField(
                                                                                            mainGQLgetByFunctionResponse.jsonBody,
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
                                                                                  _model.outboundNumbers = [];
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
                                                                                            primaryPhoneNumber: _model.tfMobilePhoneNumberTextController.text,
                                                                                            emergencyPhoneNumber: _model.tfHomePhoneNumberTextController.text,
                                                                                            clinicId: getJsonField(
                                                                                              mainGQLgetByFunctionResponse.jsonBody,
                                                                                              r'''$.data.pep_vw_consolidated_data[:].clinic_id''',
                                                                                            ).toString(),
                                                                                            patientId: widget.patientClinicDataID!.toString(),
                                                                                            callerId: FFAppState().loginProfileID,
                                                                                            originNumberType: OriginNumberType.Enrollment.name,
                                                                                            patientFirstName: getJsonField(
                                                                                              mainGQLgetByFunctionResponse.jsonBody,
                                                                                              r'''$.data.pep_vw_consolidated_data[:].first_name''',
                                                                                            ).toString(),
                                                                                            patientLastName: getJsonField(
                                                                                              mainGQLgetByFunctionResponse.jsonBody,
                                                                                              r'''$.data.pep_vw_consolidated_data[:].last_name''',
                                                                                            ).toString(),
                                                                                            patientClinicTimeZone: getJsonField(
                                                                                              mainGQLgetByFunctionResponse.jsonBody,
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
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              children: [
                                                                Container(
                                                                  width: 200.0,
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
                                                                            _model.tfHomePhoneNumberTextController ??=
                                                                                TextEditingController(
                                                                          text: (String?
                                                                              inputString) {
                                                                            return (inputString == "null" || inputString == null)
                                                                                ? ""
                                                                                : inputString;
                                                                          }(getJsonField(
                                                                            mainGQLgetByFunctionResponse.jsonBody,
                                                                            r'''$.data.pep_vw_consolidated_data[:].home_phone_number''',
                                                                          ).toString()),
                                                                        ),
                                                                        focusNode:
                                                                            _model.tfHomePhoneNumberFocusNode,
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
                                                                            .tfHomePhoneNumberTextControllerValidator
                                                                            .asValidator(context),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          10.0,
                                                                          0.0,
                                                                          0.0,
                                                                          0.0),
                                                                  child:
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
                                                                              .tfHomePhoneNumberTextController
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
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    0.0,
                                                                    0.0,
                                                                    0.0,
                                                                    15.0),
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
                                                            Expanded(
                                                              child: Align(
                                                                alignment:
                                                                    AlignmentDirectional(
                                                                        -1.0,
                                                                        0.0),
                                                                child:
                                                                    Container(
                                                                  width: MediaQuery.sizeOf(
                                                                              context)
                                                                          .width *
                                                                      1.0,
                                                                  child:
                                                                      TextFormField(
                                                                    controller:
                                                                        _model.emailTextController ??=
                                                                            TextEditingController(
                                                                      text: (String?
                                                                          inputString) {
                                                                        return (inputString == "null" ||
                                                                                inputString == null)
                                                                            ? ""
                                                                            : inputString;
                                                                      }(getJsonField(
                                                                        mainGQLgetByFunctionResponse
                                                                            .jsonBody,
                                                                        r'''$.data.pep_vw_consolidated_data[:].email''',
                                                                      ).toString()),
                                                                    ),
                                                                    focusNode:
                                                                        _model
                                                                            .emailFocusNode,
                                                                    autofocus:
                                                                        true,
                                                                    obscureText:
                                                                        false,
                                                                    decoration:
                                                                        InputDecoration(
                                                                      labelText:
                                                                          'Email  Address',
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
                                                                          'Enter Email Address',
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
                                                                        .labelSmall
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.poppins(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelSmall.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelSmall.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).textColor,
                                                                          fontSize:
                                                                              14.0,
                                                                          letterSpacing:
                                                                              1.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .labelSmall
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .labelSmall
                                                                              .fontStyle,
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
                                                                        .emailTextControllerValidator
                                                                        .asValidator(
                                                                            context),
                                                                  ),
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
                                                                    0.0,
                                                                    0.0,
                                                                    15.0),
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
                                                            Expanded(
                                                              child: Align(
                                                                alignment:
                                                                    AlignmentDirectional(
                                                                        0.0,
                                                                        0.0),
                                                                child:
                                                                    TextFormField(
                                                                  controller: _model
                                                                          .addressTextController ??=
                                                                      TextEditingController(
                                                                    text: (String?
                                                                        inputString) {
                                                                      return (inputString == "null" ||
                                                                              inputString == null)
                                                                          ? ""
                                                                          : inputString;
                                                                    }(getJsonField(
                                                                      mainGQLgetByFunctionResponse
                                                                          .jsonBody,
                                                                      r'''$.data.pep_vw_consolidated_data[:].address_line_1''',
                                                                    ).toString()),
                                                                  ),
                                                                  focusNode: _model
                                                                      .addressFocusNode,
                                                                  autofocus:
                                                                      true,
                                                                  obscureText:
                                                                      false,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    labelText:
                                                                        'Address',
                                                                    labelStyle: FlutterFlowTheme.of(
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
                                                                    hintText:
                                                                        'Enter Address',
                                                                    hintStyle: FlutterFlowTheme.of(
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
                                                                    enabledBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .borderColor,
                                                                        width:
                                                                            1.0,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0),
                                                                    ),
                                                                    focusedBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .tertiary,
                                                                        width:
                                                                            1.0,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0),
                                                                    ),
                                                                    errorBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                        color: Color(
                                                                            0x00000000),
                                                                        width:
                                                                            1.0,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0),
                                                                    ),
                                                                    focusedErrorBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                        color: Color(
                                                                            0x00000000),
                                                                        width:
                                                                            1.0,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0),
                                                                    ),
                                                                    filled:
                                                                        true,
                                                                    fillColor: FlutterFlowTheme.of(
                                                                            context)
                                                                        .accent1,
                                                                    contentPadding:
                                                                        EdgeInsetsDirectional.fromSTEB(
                                                                            10.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                  ),
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelSmall
                                                                      .override(
                                                                        font: GoogleFonts
                                                                            .poppins(
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .labelSmall
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .labelSmall
                                                                              .fontStyle,
                                                                        ),
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .textColor,
                                                                        fontSize:
                                                                            14.0,
                                                                        letterSpacing:
                                                                            1.0,
                                                                        fontWeight: FlutterFlowTheme.of(context)
                                                                            .labelSmall
                                                                            .fontWeight,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .labelSmall
                                                                            .fontStyle,
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
                                                                      FlutterFlowTheme.of(
                                                                              context)
                                                                          .tertiary,
                                                                  validator: _model
                                                                      .addressTextControllerValidator
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
                                                                    0.0,
                                                                    0.0,
                                                                    15.0),
                                                        child: Row(
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
                                                              child: Align(
                                                                alignment:
                                                                    AlignmentDirectional(
                                                                        0.0,
                                                                        0.0),
                                                                child:
                                                                    TextFormField(
                                                                  controller: _model
                                                                          .cityTextController ??=
                                                                      TextEditingController(
                                                                    text: (String?
                                                                        inputString) {
                                                                      return (inputString == "null" ||
                                                                              inputString == null)
                                                                          ? ""
                                                                          : inputString;
                                                                    }(getJsonField(
                                                                      mainGQLgetByFunctionResponse
                                                                          .jsonBody,
                                                                      r'''$.data.pep_vw_consolidated_data[:].city''',
                                                                    ).toString()),
                                                                  ),
                                                                  focusNode: _model
                                                                      .cityFocusNode,
                                                                  autofocus:
                                                                      true,
                                                                  obscureText:
                                                                      false,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    labelText:
                                                                        'City',
                                                                    labelStyle: FlutterFlowTheme.of(
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
                                                                    hintText:
                                                                        'Enter City',
                                                                    hintStyle: FlutterFlowTheme.of(
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
                                                                    enabledBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .borderColor,
                                                                        width:
                                                                            1.0,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0),
                                                                    ),
                                                                    focusedBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .tertiary,
                                                                        width:
                                                                            1.0,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0),
                                                                    ),
                                                                    errorBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                        color: Color(
                                                                            0x00000000),
                                                                        width:
                                                                            1.0,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0),
                                                                    ),
                                                                    focusedErrorBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                        color: Color(
                                                                            0x00000000),
                                                                        width:
                                                                            1.0,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0),
                                                                    ),
                                                                    filled:
                                                                        true,
                                                                    fillColor: FlutterFlowTheme.of(
                                                                            context)
                                                                        .accent1,
                                                                    contentPadding:
                                                                        EdgeInsetsDirectional.fromSTEB(
                                                                            10.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                  ),
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelSmall
                                                                      .override(
                                                                        font: GoogleFonts
                                                                            .poppins(
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .labelSmall
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .labelSmall
                                                                              .fontStyle,
                                                                        ),
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .textColor,
                                                                        fontSize:
                                                                            14.0,
                                                                        letterSpacing:
                                                                            1.0,
                                                                        fontWeight: FlutterFlowTheme.of(context)
                                                                            .labelSmall
                                                                            .fontWeight,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .labelSmall
                                                                            .fontStyle,
                                                                      ),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .justify,
                                                                  maxLength: 64,
                                                                  buildCounter: (context,
                                                                          {required currentLength,
                                                                          required isFocused,
                                                                          maxLength}) =>
                                                                      null,
                                                                  cursorColor:
                                                                      FlutterFlowTheme.of(
                                                                              context)
                                                                          .tertiary,
                                                                  validator: _model
                                                                      .cityTextControllerValidator
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
                                                                  controller: _model
                                                                          .stateTextController ??=
                                                                      TextEditingController(
                                                                    text: (String?
                                                                        inputString) {
                                                                      return (inputString == "null" ||
                                                                              inputString == null)
                                                                          ? ""
                                                                          : inputString;
                                                                    }(getJsonField(
                                                                      mainGQLgetByFunctionResponse
                                                                          .jsonBody,
                                                                      r'''$.data.pep_vw_consolidated_data[:].state''',
                                                                    ).toString()),
                                                                  ),
                                                                  focusNode: _model
                                                                      .stateFocusNode,
                                                                  autofocus:
                                                                      true,
                                                                  obscureText:
                                                                      false,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    labelText:
                                                                        'State',
                                                                    labelStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelSmall
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.poppins(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelSmall.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelSmall.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).textColor,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .labelSmall
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .labelSmall
                                                                              .fontStyle,
                                                                        ),
                                                                    hintText:
                                                                        'Enter State',
                                                                    hintStyle: FlutterFlowTheme.of(
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
                                                                    enabledBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .borderColor,
                                                                        width:
                                                                            1.0,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0),
                                                                    ),
                                                                    focusedBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .tertiary,
                                                                        width:
                                                                            1.0,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0),
                                                                    ),
                                                                    errorBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                        color: Color(
                                                                            0x00000000),
                                                                        width:
                                                                            1.0,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0),
                                                                    ),
                                                                    focusedErrorBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                        color: Color(
                                                                            0x00000000),
                                                                        width:
                                                                            1.0,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0),
                                                                    ),
                                                                    filled:
                                                                        true,
                                                                    fillColor: FlutterFlowTheme.of(
                                                                            context)
                                                                        .accent1,
                                                                    contentPadding:
                                                                        EdgeInsetsDirectional.fromSTEB(
                                                                            10.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                  ),
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelSmall
                                                                      .override(
                                                                        font: GoogleFonts
                                                                            .poppins(
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .labelSmall
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .labelSmall
                                                                              .fontStyle,
                                                                        ),
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .textColor,
                                                                        fontSize:
                                                                            14.0,
                                                                        letterSpacing:
                                                                            1.0,
                                                                        fontWeight: FlutterFlowTheme.of(context)
                                                                            .labelSmall
                                                                            .fontWeight,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .labelSmall
                                                                            .fontStyle,
                                                                      ),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .justify,
                                                                  maxLength: 2,
                                                                  buildCounter: (context,
                                                                          {required currentLength,
                                                                          required isFocused,
                                                                          maxLength}) =>
                                                                      null,
                                                                  cursorColor:
                                                                      FlutterFlowTheme.of(
                                                                              context)
                                                                          .tertiary,
                                                                  validator: _model
                                                                      .stateTextControllerValidator
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
                                                                  controller: _model
                                                                          .zipcodeTextController ??=
                                                                      TextEditingController(
                                                                    text: (String?
                                                                        inputString) {
                                                                      return (inputString == "null" ||
                                                                              inputString == null)
                                                                          ? ""
                                                                          : inputString;
                                                                    }(getJsonField(
                                                                      mainGQLgetByFunctionResponse
                                                                          .jsonBody,
                                                                      r'''$.data.pep_vw_consolidated_data[:].zip_code''',
                                                                    ).toString()),
                                                                  ),
                                                                  focusNode: _model
                                                                      .zipcodeFocusNode,
                                                                  autofocus:
                                                                      true,
                                                                  obscureText:
                                                                      false,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    labelText:
                                                                        'Zip Code',
                                                                    labelStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelSmall
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.poppins(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelSmall.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelSmall.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).textColor,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .labelSmall
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .labelSmall
                                                                              .fontStyle,
                                                                        ),
                                                                    hintText:
                                                                        'Enter Zip Code',
                                                                    hintStyle: FlutterFlowTheme.of(
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
                                                                    enabledBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .borderColor,
                                                                        width:
                                                                            1.0,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0),
                                                                    ),
                                                                    focusedBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .tertiary,
                                                                        width:
                                                                            1.0,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0),
                                                                    ),
                                                                    errorBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                        color: Color(
                                                                            0x00000000),
                                                                        width:
                                                                            1.0,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0),
                                                                    ),
                                                                    focusedErrorBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                        color: Color(
                                                                            0x00000000),
                                                                        width:
                                                                            1.0,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0),
                                                                    ),
                                                                    filled:
                                                                        true,
                                                                    fillColor: FlutterFlowTheme.of(
                                                                            context)
                                                                        .accent1,
                                                                    contentPadding:
                                                                        EdgeInsetsDirectional.fromSTEB(
                                                                            10.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                  ),
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelSmall
                                                                      .override(
                                                                        font: GoogleFonts
                                                                            .poppins(
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .labelSmall
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .labelSmall
                                                                              .fontStyle,
                                                                        ),
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .textColor,
                                                                        fontSize:
                                                                            14.0,
                                                                        letterSpacing:
                                                                            1.0,
                                                                        fontWeight: FlutterFlowTheme.of(context)
                                                                            .labelSmall
                                                                            .fontWeight,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .labelSmall
                                                                            .fontStyle,
                                                                      ),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .justify,
                                                                  maxLength: 10,
                                                                  buildCounter: (context,
                                                                          {required currentLength,
                                                                          required isFocused,
                                                                          maxLength}) =>
                                                                      null,
                                                                  cursorColor:
                                                                      FlutterFlowTheme.of(
                                                                              context)
                                                                          .tertiary,
                                                                  validator: _model
                                                                      .zipcodeTextControllerValidator
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
                                            ),
                                            Align(
                                              alignment: AlignmentDirectional(
                                                  1.0, 0.0),
                                              child: Container(
                                                width:
                                                    MediaQuery.sizeOf(context)
                                                            .width *
                                                        0.47,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                                child: Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          1.0, 0.0),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    0.0,
                                                                    0.0,
                                                                    0.0,
                                                                    15.0),
                                                        child: Row(
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
                                                                        .min,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
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
                                                                  Expanded(
                                                                    child:
                                                                        Align(
                                                                      alignment:
                                                                          AlignmentDirectional(
                                                                              1.0,
                                                                              0.0),
                                                                      child:
                                                                          Text(
                                                                        getJsonField(
                                                                          mainGQLgetByFunctionResponse
                                                                              .jsonBody,
                                                                          r'''$.data.pep_vw_consolidated_data[:].clinic_name''',
                                                                        ).toString(),
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
                                                                    ),
                                                                  ),
                                                                ].divide(SizedBox(
                                                                    width:
                                                                        20.0)),
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
                                                                  controller: _model
                                                                          .emrTextController ??=
                                                                      TextEditingController(
                                                                    text: (String?
                                                                        inputString) {
                                                                      return (inputString == "null" ||
                                                                              inputString == null)
                                                                          ? ""
                                                                          : inputString;
                                                                    }(getJsonField(
                                                                      mainGQLgetByFunctionResponse
                                                                          .jsonBody,
                                                                      r'''$.data.pep_vw_consolidated_data[:].emr_id''',
                                                                    ).toString()),
                                                                  ),
                                                                  focusNode: _model
                                                                      .emrFocusNode,
                                                                  autofocus:
                                                                      true,
                                                                  obscureText:
                                                                      false,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    labelText:
                                                                        'EMR',
                                                                    labelStyle: FlutterFlowTheme.of(
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
                                                                    hintText:
                                                                        'EMR',
                                                                    hintStyle: FlutterFlowTheme.of(
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
                                                                    enabledBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .borderColor,
                                                                        width:
                                                                            1.0,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0),
                                                                    ),
                                                                    focusedBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .tertiary,
                                                                        width:
                                                                            1.0,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0),
                                                                    ),
                                                                    errorBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                        color: Color(
                                                                            0x00000000),
                                                                        width:
                                                                            1.0,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0),
                                                                    ),
                                                                    focusedErrorBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                        color: Color(
                                                                            0x00000000),
                                                                        width:
                                                                            1.0,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0),
                                                                    ),
                                                                    filled:
                                                                        true,
                                                                    fillColor: FlutterFlowTheme.of(
                                                                            context)
                                                                        .accent1,
                                                                    contentPadding:
                                                                        EdgeInsetsDirectional.fromSTEB(
                                                                            10.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                  ),
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMedium
                                                                      .override(
                                                                        font: GoogleFonts
                                                                            .readexPro(
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontStyle,
                                                                        ),
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .textColor,
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
                                                                  maxLength:
                                                                      128,
                                                                  buildCounter: (context,
                                                                          {required currentLength,
                                                                          required isFocused,
                                                                          maxLength}) =>
                                                                      null,
                                                                  cursorColor:
                                                                      FlutterFlowTheme.of(
                                                                              context)
                                                                          .tertiary,
                                                                  validator: _model
                                                                      .emrTextControllerValidator
                                                                      .asValidator(
                                                                          context),
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
                                                                    0.0,
                                                                    0.0,
                                                                    15.0),
                                                        child: FutureBuilder<
                                                            ApiCallResponse>(
                                                          future: FFAppState()
                                                              .conditionList(
                                                            requestFn: () =>
                                                                GQLgetByFunctionCall
                                                                    .call(
                                                              hasuraToken:
                                                                  FFAppState()
                                                                      .hasuraToken,
                                                              requestBody:
                                                                  '{\"query\": \"query MyQuery { api_prescriptioncauselist(where: {active: {_eq: true}}, order_by: {id: asc}) { id cause } }\"}',
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
                                                            final rowGQLgetByFunctionResponse =
                                                                snapshot.data!;

                                                            return Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Expanded(
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
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .center,
                                                                      children:
                                                                          [
                                                                        Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text(
                                                                              'Primary Dx:',
                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
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
                                                                            Align(
                                                                              alignment: AlignmentDirectional(0.0, 0.0),
                                                                              child: FlutterFlowDropDown<int>(
                                                                                controller: _model.primaryDxSelectValueController ??= FormFieldController<int>(
                                                                                  _model.primaryDxSelectValue ??= getJsonField(
                                                                                    mainGQLgetByFunctionResponse.jsonBody,
                                                                                    r'''$.data.pep_vw_consolidated_data[:].primary_dx_id''',
                                                                                  ),
                                                                                ),
                                                                                options: List<int>.from(getJsonField(
                                                                                  rowGQLgetByFunctionResponse.jsonBody,
                                                                                  r'''$.data.api_prescriptioncauselist[:].id''',
                                                                                  true,
                                                                                )!),
                                                                                optionLabels: (getJsonField(
                                                                                  rowGQLgetByFunctionResponse.jsonBody,
                                                                                  r'''$.data.api_prescriptioncauselist[:].cause''',
                                                                                  true,
                                                                                ) as List)
                                                                                    .map<String>((s) => s.toString())
                                                                                    .toList(),
                                                                                onChanged: (val) async {
                                                                                  safeSetState(() => _model.primaryDxSelectValue = val);
                                                                                  if (_model.primaryDxSelectValue == _model.secondaryDxSelectValue) {
                                                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                                                      SnackBar(
                                                                                        content: Text(
                                                                                          'Warning: Primary and Secondary Dx cannot be the same!',
                                                                                          style: TextStyle(
                                                                                            color: FlutterFlowTheme.of(context).primaryText,
                                                                                          ),
                                                                                        ),
                                                                                        duration: Duration(milliseconds: 4000),
                                                                                        backgroundColor: FlutterFlowTheme.of(context).warning,
                                                                                      ),
                                                                                    );
                                                                                  }
                                                                                },
                                                                                width: 300.0,
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
                                                                                hintText: 'Select Condition',
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
                                                                          ],
                                                                        ),
                                                                      ].divide(SizedBox(
                                                                              width: 10.0)),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
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
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .center,
                                                                      children:
                                                                          [
                                                                        Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text(
                                                                              'Secondary Dx:',
                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
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
                                                                            Align(
                                                                              alignment: AlignmentDirectional(0.0, 0.0),
                                                                              child: FlutterFlowDropDown<int>(
                                                                                controller: _model.secondaryDxSelectValueController ??= FormFieldController<int>(
                                                                                  _model.secondaryDxSelectValue ??= getJsonField(
                                                                                    mainGQLgetByFunctionResponse.jsonBody,
                                                                                    r'''$.data.pep_vw_consolidated_data[:].secondary_dx_id''',
                                                                                  ),
                                                                                ),
                                                                                options: List<int>.from(getJsonField(
                                                                                  rowGQLgetByFunctionResponse.jsonBody,
                                                                                  r'''$.data.api_prescriptioncauselist[:].id''',
                                                                                  true,
                                                                                )!),
                                                                                optionLabels: (getJsonField(
                                                                                  rowGQLgetByFunctionResponse.jsonBody,
                                                                                  r'''$.data.api_prescriptioncauselist[:].cause''',
                                                                                  true,
                                                                                ) as List)
                                                                                    .map<String>((s) => s.toString())
                                                                                    .toList(),
                                                                                onChanged: (val) async {
                                                                                  safeSetState(() => _model.secondaryDxSelectValue = val);
                                                                                  if (_model.primaryDxSelectValue == _model.secondaryDxSelectValue) {
                                                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                                                      SnackBar(
                                                                                        content: Text(
                                                                                          'Warning: Primary and Secondary Dx cannot be the same!',
                                                                                          style: TextStyle(
                                                                                            color: FlutterFlowTheme.of(context).primaryText,
                                                                                          ),
                                                                                        ),
                                                                                        duration: Duration(milliseconds: 4000),
                                                                                        backgroundColor: FlutterFlowTheme.of(context).warning,
                                                                                      ),
                                                                                    );
                                                                                  }
                                                                                },
                                                                                width: 300.0,
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
                                                                                hintText: 'Select Condition',
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
                                                                          ],
                                                                        ),
                                                                      ].divide(SizedBox(
                                                                              width: 10.0)),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ].divide(SizedBox(
                                                                  width: 20.0)),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                      if (false)
                                                        Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      0.0,
                                                                      0.0,
                                                                      0.0,
                                                                      15.0),
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
                                                                    Text(
                                                                      'Primary Dx: ',
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
                                                                    Expanded(
                                                                      child:
                                                                          Align(
                                                                        alignment: AlignmentDirectional(
                                                                            1.0,
                                                                            0.0),
                                                                        child:
                                                                            Text(
                                                                          valueOrDefault<
                                                                              String>(
                                                                            getJsonField(
                                                                              mainGQLgetByFunctionResponse.jsonBody,
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
                                                                      ),
                                                                    ),
                                                                  ].divide(SizedBox(
                                                                      width:
                                                                          20.0)),
                                                                ),
                                                              ),
                                                              Expanded(
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
                                                                    Text(
                                                                      'Secondary Dx:',
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
                                                                    Expanded(
                                                                      child:
                                                                          Align(
                                                                        alignment: AlignmentDirectional(
                                                                            1.0,
                                                                            0.0),
                                                                        child:
                                                                            Text(
                                                                          valueOrDefault<
                                                                              String>(
                                                                            getJsonField(
                                                                              mainGQLgetByFunctionResponse.jsonBody,
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
                                                                      ),
                                                                    ),
                                                                  ].divide(SizedBox(
                                                                      width:
                                                                          20.0)),
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
                                                                    0.0,
                                                                    0.0,
                                                                    15.0),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Expanded(
                                                              child: Column(
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
                                                                      'Program Eligibilty:',
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
                                                                  ),
                                                                  Align(
                                                                    alignment:
                                                                        AlignmentDirectional(
                                                                            -1.0,
                                                                            0.0),
                                                                    child: FlutterFlowDropDown<
                                                                        String>(
                                                                      multiSelectController: _model
                                                                          .programEligibiltyValueController ??= FormListFieldController<
                                                                              String>(
                                                                          _model.programEligibiltyValue ??=
                                                                              List<String>.from(
                                                                        functions.returnProgramEligibility(
                                                                                getJsonField(
                                                                                  mainGQLgetByFunctionResponse.jsonBody,
                                                                                  r'''$.data.pep_vw_consolidated_data[:].rpm_flag''',
                                                                                ),
                                                                                getJsonField(
                                                                                  mainGQLgetByFunctionResponse.jsonBody,
                                                                                  r'''$.data.pep_vw_consolidated_data[:].ccm_flag''',
                                                                                ),
                                                                                getJsonField(
                                                                                  mainGQLgetByFunctionResponse.jsonBody,
                                                                                  r'''$.data.pep_vw_consolidated_data[:].pcm_flag''',
                                                                                )) ??
                                                                            [],
                                                                      )),
                                                                      options: [
                                                                        'CCM',
                                                                        'PCM',
                                                                        'RPM'
                                                                      ],
                                                                      width:
                                                                          350.0,
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
                                                                          'Select Program Eligibilty:',
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
                                                                          10.0,
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
                                                                          true,
                                                                      onMultiSelectChanged:
                                                                          (val) =>
                                                                              safeSetState(() => _model.programEligibiltyValue = val),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Expanded(
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
                                                                  ),
                                                                  FutureBuilder<
                                                                      ApiCallResponse>(
                                                                    future: FFAppState()
                                                                        .providerList(
                                                                      requestFn:
                                                                          () =>
                                                                              GQLgetProviderListCall.call(
                                                                        hasuraToken:
                                                                            FFAppState().hasuraToken,
                                                                        clinicID: widget
                                                                            .clinicID
                                                                            ?.toString(),
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
                                                                      final providerGQLgetProviderListResponse =
                                                                          snapshot
                                                                              .data!;

                                                                      return FlutterFlowDropDown<
                                                                          int>(
                                                                        controller:
                                                                            _model.providerValueController ??=
                                                                                FormFieldController<int>(
                                                                          _model.providerValue ??=
                                                                              functions.returnInt(getJsonField(
                                                                            mainGQLgetByFunctionResponse.jsonBody,
                                                                            r'''$.data.pep_vw_consolidated_data[:].provider_id''',
                                                                          )),
                                                                        ),
                                                                        options:
                                                                            List<int>.from(getJsonField(
                                                                          providerGQLgetProviderListResponse
                                                                              .jsonBody,
                                                                          r'''$.data.pep_vw_consolidated_data[:].provider_id''',
                                                                          true,
                                                                        )!),
                                                                        optionLabels: (getJsonField(
                                                                          providerGQLgetProviderListResponse
                                                                              .jsonBody,
                                                                          r'''$.data.pep_vw_consolidated_data[:].provider_name''',
                                                                          true,
                                                                        ) as List)
                                                                            .map<String>((s) => s.toString())
                                                                            .toList(),
                                                                        onChanged:
                                                                            (val) =>
                                                                                safeSetState(() => _model.providerValue = val),
                                                                        width:
                                                                            350.0,
                                                                        height:
                                                                            48.0,
                                                                        textStyle: FlutterFlowTheme.of(context)
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
                                                                        hintText:
                                                                            'Select Provider',
                                                                        icon:
                                                                            Icon(
                                                                          Icons
                                                                              .keyboard_arrow_down_rounded,
                                                                          color:
                                                                              FlutterFlowTheme.of(context).secondaryText,
                                                                          size:
                                                                              24.0,
                                                                        ),
                                                                        fillColor:
                                                                            FlutterFlowTheme.of(context).accent1,
                                                                        elevation:
                                                                            2.0,
                                                                        borderColor:
                                                                            FlutterFlowTheme.of(context).borderColor,
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
                                                                    0.0,
                                                                    0.0,
                                                                    15.0),
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
                                                            Expanded(
                                                              child: Align(
                                                                alignment:
                                                                    AlignmentDirectional(
                                                                        0.0,
                                                                        0.0),
                                                                child:
                                                                    TextFormField(
                                                                  controller: _model
                                                                          .primaryInsTextController ??=
                                                                      TextEditingController(
                                                                    text: (String?
                                                                        inputString) {
                                                                      return (inputString == "null" ||
                                                                              inputString == null)
                                                                          ? ""
                                                                          : inputString;
                                                                    }(getJsonField(
                                                                      mainGQLgetByFunctionResponse
                                                                          .jsonBody,
                                                                      r'''$.data.pep_vw_consolidated_data[:].primary_insurance_provider''',
                                                                    ).toString()),
                                                                  ),
                                                                  focusNode: _model
                                                                      .primaryInsFocusNode,
                                                                  autofocus:
                                                                      true,
                                                                  obscureText:
                                                                      false,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    labelText:
                                                                        'Primary Insurance Provider',
                                                                    labelStyle: FlutterFlowTheme.of(
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
                                                                    hintText:
                                                                        'Enter Primary Insurance Provider',
                                                                    hintStyle: FlutterFlowTheme.of(
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
                                                                    enabledBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .borderColor,
                                                                        width:
                                                                            1.0,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0),
                                                                    ),
                                                                    focusedBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .tertiary,
                                                                        width:
                                                                            1.0,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0),
                                                                    ),
                                                                    errorBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                        color: Color(
                                                                            0x00000000),
                                                                        width:
                                                                            1.0,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0),
                                                                    ),
                                                                    focusedErrorBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                        color: Color(
                                                                            0x00000000),
                                                                        width:
                                                                            1.0,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0),
                                                                    ),
                                                                    filled:
                                                                        true,
                                                                    fillColor: FlutterFlowTheme.of(
                                                                            context)
                                                                        .accent1,
                                                                    contentPadding:
                                                                        EdgeInsetsDirectional.fromSTEB(
                                                                            10.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                  ),
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMedium
                                                                      .override(
                                                                        font: GoogleFonts
                                                                            .readexPro(
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontStyle,
                                                                        ),
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .textColor,
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
                                                                  maxLength:
                                                                      128,
                                                                  buildCounter: (context,
                                                                          {required currentLength,
                                                                          required isFocused,
                                                                          maxLength}) =>
                                                                      null,
                                                                  cursorColor:
                                                                      FlutterFlowTheme.of(
                                                                              context)
                                                                          .tertiary,
                                                                  validator: _model
                                                                      .primaryInsTextControllerValidator
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
                                                                  controller: _model
                                                                          .primaryInsNumberTextController ??=
                                                                      TextEditingController(
                                                                    text: (String?
                                                                        inputString) {
                                                                      return (inputString == "null" ||
                                                                              inputString == null)
                                                                          ? ""
                                                                          : inputString;
                                                                    }(getJsonField(
                                                                      mainGQLgetByFunctionResponse
                                                                          .jsonBody,
                                                                      r'''$.data.pep_vw_consolidated_data[:].primary_insurance_id''',
                                                                    ).toString()),
                                                                  ),
                                                                  focusNode: _model
                                                                      .primaryInsNumberFocusNode,
                                                                  autofocus:
                                                                      true,
                                                                  obscureText:
                                                                      false,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    labelText:
                                                                        'Primary Insurance Number',
                                                                    labelStyle: FlutterFlowTheme.of(
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
                                                                    hintText:
                                                                        'Enter Primary Insurance Number',
                                                                    hintStyle: FlutterFlowTheme.of(
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
                                                                    enabledBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .borderColor,
                                                                        width:
                                                                            1.0,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0),
                                                                    ),
                                                                    focusedBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .tertiary,
                                                                        width:
                                                                            1.0,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0),
                                                                    ),
                                                                    errorBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                        color: Color(
                                                                            0x00000000),
                                                                        width:
                                                                            1.0,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0),
                                                                    ),
                                                                    focusedErrorBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                        color: Color(
                                                                            0x00000000),
                                                                        width:
                                                                            1.0,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0),
                                                                    ),
                                                                    filled:
                                                                        true,
                                                                    fillColor: FlutterFlowTheme.of(
                                                                            context)
                                                                        .accent1,
                                                                    contentPadding:
                                                                        EdgeInsetsDirectional.fromSTEB(
                                                                            10.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                  ),
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMedium
                                                                      .override(
                                                                        font: GoogleFonts
                                                                            .readexPro(
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontStyle,
                                                                        ),
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .textColor,
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
                                                                  maxLength:
                                                                      128,
                                                                  buildCounter: (context,
                                                                          {required currentLength,
                                                                          required isFocused,
                                                                          maxLength}) =>
                                                                      null,
                                                                  cursorColor:
                                                                      FlutterFlowTheme.of(
                                                                              context)
                                                                          .tertiary,
                                                                  validator: _model
                                                                      .primaryInsNumberTextControllerValidator
                                                                      .asValidator(
                                                                          context),
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
                                                                    0.0,
                                                                    0.0,
                                                                    15.0),
                                                        child: Row(
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
                                                              child: Align(
                                                                alignment:
                                                                    AlignmentDirectional(
                                                                        0.0,
                                                                        0.0),
                                                                child:
                                                                    TextFormField(
                                                                  controller: _model
                                                                          .secondaryInsTextController ??=
                                                                      TextEditingController(
                                                                    text: (String?
                                                                        inputString) {
                                                                      return (inputString == "null" ||
                                                                              inputString == null)
                                                                          ? ""
                                                                          : inputString;
                                                                    }(getJsonField(
                                                                      mainGQLgetByFunctionResponse
                                                                          .jsonBody,
                                                                      r'''$.data.pep_vw_consolidated_data[:].secondary_insurance_provider''',
                                                                    ).toString()),
                                                                  ),
                                                                  focusNode: _model
                                                                      .secondaryInsFocusNode,
                                                                  autofocus:
                                                                      true,
                                                                  obscureText:
                                                                      false,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    labelText:
                                                                        'Secondary Insurance Provider',
                                                                    labelStyle: FlutterFlowTheme.of(
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
                                                                    hintText:
                                                                        'Enter Secondary Insurance Provider',
                                                                    hintStyle: FlutterFlowTheme.of(
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
                                                                    enabledBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .borderColor,
                                                                        width:
                                                                            1.0,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0),
                                                                    ),
                                                                    focusedBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .tertiary,
                                                                        width:
                                                                            1.0,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0),
                                                                    ),
                                                                    errorBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                        color: Color(
                                                                            0x00000000),
                                                                        width:
                                                                            1.0,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0),
                                                                    ),
                                                                    focusedErrorBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                        color: Color(
                                                                            0x00000000),
                                                                        width:
                                                                            1.0,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0),
                                                                    ),
                                                                    filled:
                                                                        true,
                                                                    fillColor: FlutterFlowTheme.of(
                                                                            context)
                                                                        .accent1,
                                                                    contentPadding:
                                                                        EdgeInsetsDirectional.fromSTEB(
                                                                            10.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                  ),
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMedium
                                                                      .override(
                                                                        font: GoogleFonts
                                                                            .readexPro(
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontStyle,
                                                                        ),
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .textColor,
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
                                                                  maxLength:
                                                                      128,
                                                                  buildCounter: (context,
                                                                          {required currentLength,
                                                                          required isFocused,
                                                                          maxLength}) =>
                                                                      null,
                                                                  cursorColor:
                                                                      FlutterFlowTheme.of(
                                                                              context)
                                                                          .tertiary,
                                                                  validator: _model
                                                                      .secondaryInsTextControllerValidator
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
                                                                  controller: _model
                                                                          .secondaryInsNumberTextController ??=
                                                                      TextEditingController(
                                                                    text: (String?
                                                                        inputString) {
                                                                      return (inputString == "null" ||
                                                                              inputString == null)
                                                                          ? ""
                                                                          : inputString;
                                                                    }(getJsonField(
                                                                      mainGQLgetByFunctionResponse
                                                                          .jsonBody,
                                                                      r'''$.data.pep_vw_consolidated_data[:].secondary_insurance_id''',
                                                                    ).toString()),
                                                                  ),
                                                                  focusNode: _model
                                                                      .secondaryInsNumberFocusNode,
                                                                  autofocus:
                                                                      true,
                                                                  obscureText:
                                                                      false,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    labelText:
                                                                        'Secondary Insurance Number',
                                                                    labelStyle: FlutterFlowTheme.of(
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
                                                                    hintText:
                                                                        'Enter Secondary Insurance Number',
                                                                    hintStyle: FlutterFlowTheme.of(
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
                                                                    enabledBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .borderColor,
                                                                        width:
                                                                            1.0,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0),
                                                                    ),
                                                                    focusedBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .tertiary,
                                                                        width:
                                                                            1.0,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0),
                                                                    ),
                                                                    errorBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                        color: Color(
                                                                            0x00000000),
                                                                        width:
                                                                            1.0,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0),
                                                                    ),
                                                                    focusedErrorBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                        color: Color(
                                                                            0x00000000),
                                                                        width:
                                                                            1.0,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0),
                                                                    ),
                                                                    filled:
                                                                        true,
                                                                    fillColor: FlutterFlowTheme.of(
                                                                            context)
                                                                        .accent1,
                                                                    contentPadding:
                                                                        EdgeInsetsDirectional.fromSTEB(
                                                                            10.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                  ),
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMedium
                                                                      .override(
                                                                        font: GoogleFonts
                                                                            .readexPro(
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontStyle,
                                                                        ),
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .textColor,
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
                                                                  maxLength:
                                                                      128,
                                                                  buildCounter: (context,
                                                                          {required currentLength,
                                                                          required isFocused,
                                                                          maxLength}) =>
                                                                      null,
                                                                  cursorColor:
                                                                      FlutterFlowTheme.of(
                                                                              context)
                                                                          .tertiary,
                                                                  validator: _model
                                                                      .secondaryInsNumberTextControllerValidator
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
                                            ),
                                          ].divide(SizedBox(width: 20.0)),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 320.0,
                                    decoration: BoxDecoration(),
                                    child: Column(
                                      children: [
                                        Align(
                                          alignment: Alignment(-1.0, 0),
                                          child: TabBar(
                                            isScrollable: true,
                                            labelColor:
                                                FlutterFlowTheme.of(context)
                                                    .primaryText,
                                            unselectedLabelColor:
                                                FlutterFlowTheme.of(context)
                                                    .secondaryText,
                                            labelStyle:
                                                FlutterFlowTheme.of(context)
                                                    .titleMedium
                                                    .override(
                                                      font: GoogleFonts.poppins(
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleMedium
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleMedium
                                                                .fontStyle,
                                                      ),
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .titleMedium
                                                              .fontWeight,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .titleMedium
                                                              .fontStyle,
                                                    ),
                                            unselectedLabelStyle:
                                                FlutterFlowTheme.of(context)
                                                    .titleMedium
                                                    .override(
                                                      font: GoogleFonts.poppins(
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleMedium
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleMedium
                                                                .fontStyle,
                                                      ),
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .titleMedium
                                                              .fontWeight,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .titleMedium
                                                              .fontStyle,
                                                    ),
                                            indicatorColor:
                                                FlutterFlowTheme.of(context)
                                                    .tertiary,
                                            tabs: [
                                              Tab(
                                                text: 'CCM Enrollment Attempts',
                                              ),
                                              Tab(
                                                text: 'RPM Enrollment Attempts',
                                              ),
                                            ],
                                            controller: _model.tabBarController,
                                            onTap: (i) async {
                                              [() async {}, () async {}][i]();
                                            },
                                          ),
                                        ),
                                        Expanded(
                                          child: TabBarView(
                                            controller: _model.tabBarController,
                                            children: [
                                              FutureBuilder<ApiCallResponse>(
                                                future: FFAppState()
                                                    .ccmStatusUpdatesGS(
                                                  requestFn: () =>
                                                      GQLgetByFunctionCall.call(
                                                    hasuraToken: FFAppState()
                                                        .hasuraToken,
                                                    requestBody: functions
                                                        .getCCMStatusUpdates(widget
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
                                                    decoration: BoxDecoration(),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        if (functions
                                                            .isPatientAlreadyEnrolled(
                                                                GQLgetByFunctionCall
                                                                        .ccmStatusUpdates(
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
                                                                          4.0,
                                                                          8.0,
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
                                                          ),
                                                        if (true /* Warning: Trying to access variable not yet defined. */)
                                                          Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    -1.0, 0.0),
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          8.0,
                                                                          0.0,
                                                                          0.0),
                                                              child: FutureBuilder<
                                                                  ApiCallResponse>(
                                                                future: FFAppState()
                                                                    .ccmStatusUpdatesGS(
                                                                  requestFn: () =>
                                                                      GQLgetByFunctionCall
                                                                          .call(
                                                                    hasuraToken:
                                                                        FFAppState()
                                                                            .hasuraToken,
                                                                    requestBody: functions
                                                                        .getCCMStatusUpdates(
                                                                            widget.patientClinicDataID!)
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
                                                                            FlutterFlowTheme.of(context).primary,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  }
                                                                  final containerGQLgetByFunctionResponse =
                                                                      snapshot
                                                                          .data!;

                                                                  return Container(
                                                                    height:
                                                                        200.0,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      boxShadow: [
                                                                        BoxShadow(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).secondaryBackground,
                                                                          offset:
                                                                              Offset(
                                                                            0.0,
                                                                            2.0,
                                                                          ),
                                                                        )
                                                                      ],
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0),
                                                                    ),
                                                                    child:
                                                                        Stack(
                                                                      children: [
                                                                        if (GQLgetByFunctionCall.ccmStatusUpdates(
                                                                                  containerGQLgetByFunctionResponse.jsonBody,
                                                                                ) !=
                                                                                null &&
                                                                            (GQLgetByFunctionCall.ccmStatusUpdates(
                                                                              containerGQLgetByFunctionResponse.jsonBody,
                                                                            ))!
                                                                                .isNotEmpty)
                                                                          Builder(
                                                                            builder:
                                                                                (context) {
                                                                              final ccmStatusUpdates = functions
                                                                                  .sortAttemptsToDesc(getJsonField(
                                                                                    containerGQLgetByFunctionResponse.jsonBody,
                                                                                    r'''$.data.pep_vw_consolidated_data[:].ccm_status_updates''',
                                                                                    true,
                                                                                  )!)
                                                                                  .toList();

                                                                              return FlutterFlowDataTable<dynamic>(
                                                                                controller: _model.paginatedDataTableController1,
                                                                                data: ccmStatusUpdates,
                                                                                columnsBuilder: (onSortChanged) => [
                                                                                  DataColumn2(
                                                                                    label: DefaultTextStyle.merge(
                                                                                      softWrap: true,
                                                                                      child: Text(
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
                                                                                    fixedWidth: 180.0,
                                                                                  ),
                                                                                  DataColumn2(
                                                                                    label: DefaultTextStyle.merge(
                                                                                      softWrap: true,
                                                                                      child: Text(
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
                                                                                    fixedWidth: 200.0,
                                                                                  ),
                                                                                  DataColumn2(
                                                                                    label: DefaultTextStyle.merge(
                                                                                      softWrap: true,
                                                                                      child: Text(
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
                                                                                    fixedWidth: 250.0,
                                                                                  ),
                                                                                  DataColumn2(
                                                                                    label: DefaultTextStyle.merge(
                                                                                      softWrap: true,
                                                                                      child: Text(
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
                                                                                    label: DefaultTextStyle.merge(
                                                                                      softWrap: true,
                                                                                      child: Text(
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
                                                                                    fixedWidth: 250.0,
                                                                                  ),
                                                                                ],
                                                                                dataRowBuilder: (ccmStatusUpdatesItem, ccmStatusUpdatesIndex, selected, onSelectChanged) => DataRow(
                                                                                  cells: [
                                                                                    Align(
                                                                                      alignment: AlignmentDirectional(-1.0, 0.0),
                                                                                      child: Text(
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
                                                                                      alignment: AlignmentDirectional(-1.0, 0.0),
                                                                                      child: Text(
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
                                                                                      alignment: AlignmentDirectional(-1.0, 0.0),
                                                                                      child: Text(
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
                                                                                      builder: (context) => InkWell(
                                                                                        splashColor: Colors.transparent,
                                                                                        focusColor: Colors.transparent,
                                                                                        hoverColor: Colors.transparent,
                                                                                        highlightColor: Colors.transparent,
                                                                                        onTap: () async {
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
                                                                                        child: Container(
                                                                                          decoration: BoxDecoration(),
                                                                                          child: Text(
                                                                                            getJsonField(
                                                                                              ccmStatusUpdatesItem,
                                                                                              r'''$.comment''',
                                                                                            ).toString().maybeHandleOverflow(
                                                                                                  maxChars: 105,
                                                                                                  replacement: '…',
                                                                                                ),
                                                                                            maxLines: 2,
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
                                                                                      alignment: AlignmentDirectional(-1.0, 0.0),
                                                                                      child: Text(
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
                                                                                  ].map((c) => DataCell(c)).toList(),
                                                                                ),
                                                                                paginated: true,
                                                                                selectable: false,
                                                                                hidePaginator: true,
                                                                                showFirstLastButtons: false,
                                                                                headingRowHeight: 40.0,
                                                                                dataRowHeight: 32.0,
                                                                                headingRowColor: FlutterFlowTheme.of(context).primary,
                                                                                borderRadius: BorderRadius.circular(8.0),
                                                                                addHorizontalDivider: false,
                                                                                addTopAndBottomDivider: false,
                                                                                hideDefaultHorizontalDivider: true,
                                                                                addVerticalDivider: true,
                                                                                verticalDividerColor: Color(0x6957636C),
                                                                                verticalDividerThickness: 1.0,
                                                                              );
                                                                            },
                                                                          ),
                                                                        if (!(GQLgetByFunctionCall.ccmStatusUpdates(
                                                                                  containerGQLgetByFunctionResponse.jsonBody,
                                                                                ) !=
                                                                                null &&
                                                                            (GQLgetByFunctionCall.ccmStatusUpdates(
                                                                              containerGQLgetByFunctionResponse.jsonBody,
                                                                            ))!
                                                                                .isNotEmpty))
                                                                          Align(
                                                                            alignment:
                                                                                AlignmentDirectional(0.0, 0.0),
                                                                            child:
                                                                                Text(
                                                                              'No CCM Enrollment Attemps were made',
                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
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
                                                                          ),
                                                                      ],
                                                                    ),
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
                                              FutureBuilder<ApiCallResponse>(
                                                future: FFAppState()
                                                    .rpmStatusUpdatesGS(
                                                  requestFn: () =>
                                                      GQLgetByFunctionCall.call(
                                                    hasuraToken: FFAppState()
                                                        .hasuraToken,
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
                                                    decoration: BoxDecoration(),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
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
                                                                          4.0,
                                                                          8.0,
                                                                          0.0,
                                                                          0.0),
                                                              child: Text(
                                                                'Note: This Patient is already enrolled once for RPM.',
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
                                                          ),
                                                        if (true /* Warning: Trying to access variable not yet defined. */)
                                                          Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    -1.0, 0.0),
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          8.0,
                                                                          0.0,
                                                                          0.0),
                                                              child: FutureBuilder<
                                                                  ApiCallResponse>(
                                                                future: FFAppState()
                                                                    .rpmStatusUpdatesGS(
                                                                  requestFn: () =>
                                                                      GQLgetByFunctionCall
                                                                          .call(
                                                                    hasuraToken:
                                                                        FFAppState()
                                                                            .hasuraToken,
                                                                    requestBody: functions
                                                                        .getRPMStatusUpdates(
                                                                            widget.patientClinicDataID!)
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
                                                                            FlutterFlowTheme.of(context).primary,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  }
                                                                  final containerGQLgetByFunctionResponse =
                                                                      snapshot
                                                                          .data!;

                                                                  return Container(
                                                                    height:
                                                                        220.0,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      boxShadow: [
                                                                        BoxShadow(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).secondaryBackground,
                                                                          offset:
                                                                              Offset(
                                                                            0.0,
                                                                            2.0,
                                                                          ),
                                                                        )
                                                                      ],
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0),
                                                                    ),
                                                                    child:
                                                                        Stack(
                                                                      children: [
                                                                        if (GQLgetByFunctionCall.rpmStatusUpdates(
                                                                                  containerGQLgetByFunctionResponse.jsonBody,
                                                                                ) !=
                                                                                null &&
                                                                            (GQLgetByFunctionCall.rpmStatusUpdates(
                                                                              containerGQLgetByFunctionResponse.jsonBody,
                                                                            ))!
                                                                                .isNotEmpty)
                                                                          Builder(
                                                                            builder:
                                                                                (context) {
                                                                              final rpmStatusUpdates = functions
                                                                                  .sortAttemptsToDesc(getJsonField(
                                                                                    containerGQLgetByFunctionResponse.jsonBody,
                                                                                    r'''$.data.pep_vw_consolidated_data[:].rpm_status_updates''',
                                                                                    true,
                                                                                  )!)
                                                                                  .toList();

                                                                              return FlutterFlowDataTable<dynamic>(
                                                                                controller: _model.paginatedDataTableController2,
                                                                                data: rpmStatusUpdates,
                                                                                columnsBuilder: (onSortChanged) => [
                                                                                  DataColumn2(
                                                                                    label: DefaultTextStyle.merge(
                                                                                      softWrap: true,
                                                                                      child: Text(
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
                                                                                    fixedWidth: 180.0,
                                                                                  ),
                                                                                  DataColumn2(
                                                                                    label: DefaultTextStyle.merge(
                                                                                      softWrap: true,
                                                                                      child: Text(
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
                                                                                    fixedWidth: 200.0,
                                                                                  ),
                                                                                  DataColumn2(
                                                                                    label: DefaultTextStyle.merge(
                                                                                      softWrap: true,
                                                                                      child: Text(
                                                                                        'RPM Status',
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
                                                                                    fixedWidth: 250.0,
                                                                                  ),
                                                                                  DataColumn2(
                                                                                    label: DefaultTextStyle.merge(
                                                                                      softWrap: true,
                                                                                      child: Text(
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
                                                                                    label: DefaultTextStyle.merge(
                                                                                      softWrap: true,
                                                                                      child: Text(
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
                                                                                    fixedWidth: 250.0,
                                                                                  ),
                                                                                ],
                                                                                dataRowBuilder: (rpmStatusUpdatesItem, rpmStatusUpdatesIndex, selected, onSelectChanged) => DataRow(
                                                                                  cells: [
                                                                                    Align(
                                                                                      alignment: AlignmentDirectional(-1.0, 0.0),
                                                                                      child: Text(
                                                                                        getJsonField(
                                                                                          rpmStatusUpdatesItem,
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
                                                                                      alignment: AlignmentDirectional(-1.0, 0.0),
                                                                                      child: Text(
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
                                                                                      alignment: AlignmentDirectional(-1.0, 0.0),
                                                                                      child: Text(
                                                                                        getJsonField(
                                                                                          rpmStatusUpdatesItem,
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
                                                                                    Align(
                                                                                      alignment: AlignmentDirectional(-1.0, 0.0),
                                                                                      child: Builder(
                                                                                        builder: (context) => InkWell(
                                                                                          splashColor: Colors.transparent,
                                                                                          focusColor: Colors.transparent,
                                                                                          hoverColor: Colors.transparent,
                                                                                          highlightColor: Colors.transparent,
                                                                                          onTap: () async {
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
                                                                                          child: Container(
                                                                                            decoration: BoxDecoration(),
                                                                                            child: Text(
                                                                                              getJsonField(
                                                                                                rpmStatusUpdatesItem,
                                                                                                r'''$.comment''',
                                                                                              ).toString().maybeHandleOverflow(
                                                                                                    maxChars: 105,
                                                                                                    replacement: '…',
                                                                                                  ),
                                                                                              maxLines: 2,
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
                                                                                      alignment: AlignmentDirectional(-1.0, 0.0),
                                                                                      child: Text(
                                                                                        functions.returnUsername(
                                                                                            FFAppState().usernames.toList(),
                                                                                            getJsonField(
                                                                                              rpmStatusUpdatesItem,
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
                                                                                  ].map((c) => DataCell(c)).toList(),
                                                                                ),
                                                                                paginated: true,
                                                                                selectable: false,
                                                                                hidePaginator: true,
                                                                                showFirstLastButtons: false,
                                                                                headingRowHeight: 40.0,
                                                                                dataRowHeight: 32.0,
                                                                                headingRowColor: FlutterFlowTheme.of(context).primary,
                                                                                borderRadius: BorderRadius.circular(8.0),
                                                                                addHorizontalDivider: false,
                                                                                addTopAndBottomDivider: false,
                                                                                hideDefaultHorizontalDivider: true,
                                                                                addVerticalDivider: true,
                                                                                verticalDividerColor: Color(0x6957636C),
                                                                                verticalDividerThickness: 1.0,
                                                                              );
                                                                            },
                                                                          ),
                                                                        if (!(GQLgetByFunctionCall.rpmStatusUpdates(
                                                                                  containerGQLgetByFunctionResponse.jsonBody,
                                                                                ) !=
                                                                                null &&
                                                                            (GQLgetByFunctionCall.rpmStatusUpdates(
                                                                              containerGQLgetByFunctionResponse.jsonBody,
                                                                            ))!
                                                                                .isNotEmpty))
                                                                          Align(
                                                                            alignment:
                                                                                AlignmentDirectional(0.0, 0.0),
                                                                            child:
                                                                                Text(
                                                                              'No RPM Enrollment Attemps were made',
                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
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
                                                                          ),
                                                                      ],
                                                                    ),
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
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
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
                                              alignment: AlignmentDirectional(
                                                  0.0, 0.0),
                                              child: Text(
                                                'CCM Status:',
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyLarge
                                                    .override(
                                                      font: GoogleFonts.poppins(
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyLarge
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyLarge
                                                                .fontStyle,
                                                      ),
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyLarge
                                                              .fontWeight,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyLarge
                                                              .fontStyle,
                                                    ),
                                              ),
                                            ),
                                            Align(
                                              alignment: AlignmentDirectional(
                                                  0.0, 0.0),
                                              child: FutureBuilder<
                                                  ApiCallResponse>(
                                                future: FFAppState()
                                                    .ccmStatusListGS(
                                                  requestFn: () =>
                                                      GQLgetByFunctionCall.call(
                                                    hasuraToken: FFAppState()
                                                        .hasuraToken,
                                                    requestBody:
                                                        '{\"query\":\"query MyQuery {pep_v2_status_mapping_ccm(where: {global: {_eq: true}}, order_by: {id: asc}) { id status }}\"}',
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
                                                  final ccmStatusGQLgetByFunctionResponse =
                                                      snapshot.data!;

                                                  return FlutterFlowDropDown<
                                                      int>(
                                                    controller: _model
                                                            .ccmStatusValueController ??=
                                                        FormFieldController<
                                                            int>(null),
                                                    options: List<int>.from(
                                                        getJsonField(
                                                      ccmStatusGQLgetByFunctionResponse
                                                          .jsonBody,
                                                      r'''$.data.pep_v2_status_mapping_ccm[:].id''',
                                                      true,
                                                    )!),
                                                    optionLabels: (getJsonField(
                                                      ccmStatusGQLgetByFunctionResponse
                                                          .jsonBody,
                                                      r'''$.data.pep_v2_status_mapping_ccm[:].status''',
                                                      true,
                                                    ) as List)
                                                        .map<String>(
                                                            (s) => s.toString())
                                                        .toList(),
                                                    onChanged: (val) async {
                                                      safeSetState(() => _model
                                                              .ccmStatusValue =
                                                          val);
                                                      _model.ccmStatus =
                                                          _model.ccmStatusValue;
                                                      safeSetState(() {});

                                                      safeSetState(() {});
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
                                                                fontWeight: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontWeight,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                              ),
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .textColor,
                                                              fontSize: 16.0,
                                                              letterSpacing:
                                                                  0.0,
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
                                                    hintText:
                                                        'Select CCM Status',
                                                    icon: Icon(
                                                      Icons
                                                          .keyboard_arrow_down_rounded,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
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
                                                            .fromSTEB(16.0, 0.0,
                                                                16.0, 0.0),
                                                    hidesUnderline: true,
                                                    isOverButton: true,
                                                    isSearchable: false,
                                                    isMultiSelect: false,
                                                  );
                                                },
                                              ),
                                            ),
                                            if (((_model.ccmStatus == (1)) ||
                                                    (_model.ccmStatus ==
                                                        (3))) &&
                                                ((functions
                                                            .returnInt(
                                                                getJsonField(
                                                              mainGQLgetByFunctionResponse
                                                                  .jsonBody,
                                                              r'''$.data.pep_vw_consolidated_data[:].ccm_status''',
                                                            ))
                                                            .toString() ==
                                                        ("1")) ||
                                                    (functions
                                                            .returnInt(
                                                                getJsonField(
                                                              mainGQLgetByFunctionResponse
                                                                  .jsonBody,
                                                              r'''$.data.pep_vw_consolidated_data[:].ccm_status''',
                                                            ))
                                                            .toString() ==
                                                        ("3"))) &&
                                                (((String? inputString) {
                                                          return (inputString ==
                                                                      "null" ||
                                                                  inputString ==
                                                                      null)
                                                              ? ""
                                                              : inputString;
                                                        }(getJsonField(
                                                          mainGQLgetByFunctionResponse
                                                              .jsonBody,
                                                          r'''$.data.pep_vw_consolidated_data[:].ccm_appointment_dt''',
                                                        ).toString())) !=
                                                        ''))
                                              Column(
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      Text(
                                                        'Current Appointment Date & Time:',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
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
                                                    ],
                                                  ),
                                                  Text(
                                                    valueOrDefault<String>(
                                                      getJsonField(
                                                        mainGQLgetByFunctionResponse
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
                                                ],
                                              ),
                                            if (((_model.ccmStatus == (1)) ||
                                                    (_model.ccmStatus ==
                                                        (3))) &&
                                                ((functions
                                                            .returnInt(
                                                                getJsonField(
                                                              mainGQLgetByFunctionResponse
                                                                  .jsonBody,
                                                              r'''$.data.pep_vw_consolidated_data[:].ccm_status''',
                                                            ))
                                                            .toString() ==
                                                        ("1")) ||
                                                    (functions
                                                            .returnInt(
                                                                getJsonField(
                                                              mainGQLgetByFunctionResponse
                                                                  .jsonBody,
                                                              r'''$.data.pep_vw_consolidated_data[:].ccm_status''',
                                                            ))
                                                            .toString() ==
                                                        ("3"))) &&
                                                (((String? inputString) {
                                                          return (inputString ==
                                                                      "null" ||
                                                                  inputString ==
                                                                      null)
                                                              ? ""
                                                              : inputString;
                                                        }(getJsonField(
                                                          mainGQLgetByFunctionResponse
                                                              .jsonBody,
                                                          r'''$.data.pep_vw_consolidated_data[:].ccm_appointment_dt''',
                                                        ).toString())) !=
                                                        ''))
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: Text(
                                                  dateTimeFormat(
                                                    "MM/dd/yy h:mm a",
                                                    functions.returnDT(functions
                                                        .dtReturnFormatter(
                                                            (String?
                                                                inputString) {
                                                              return (inputString ==
                                                                          "null" ||
                                                                      inputString ==
                                                                          null)
                                                                  ? ""
                                                                  : inputString;
                                                            }(getJsonField(
                                                              mainGQLgetByFunctionResponse
                                                                  .jsonBody,
                                                              r'''$.data.pep_vw_consolidated_data[:].ccm_appointment_dt''',
                                                            ).toString()),
                                                            (String?
                                                                inputString) {
                                                              return (inputString ==
                                                                          "null" ||
                                                                      inputString ==
                                                                          null)
                                                                  ? ""
                                                                  : inputString;
                                                            }(getJsonField(
                                                              mainGQLgetByFunctionResponse
                                                                  .jsonBody,
                                                              r'''$.data.pep_vw_consolidated_data[:].patient_clinic_timezone''',
                                                            ).toString()))
                                                        .toString()),
                                                    locale: FFLocalizations.of(
                                                            context)
                                                        .languageCode,
                                                  ),
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyLarge
                                                      .override(
                                                        font:
                                                            GoogleFonts.poppins(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyLarge
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyLarge
                                                                  .fontStyle,
                                                        ),
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyLarge
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyLarge
                                                                .fontStyle,
                                                      ),
                                                ),
                                              ),
                                          ].divide(SizedBox(width: 20.0)),
                                        ),
                                        if (((_model.ccmStatus == (1)) &&
                                                !FFAppState()
                                                    .transferPatient) ||
                                            (_model.ccmStatus == (3)))
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              if (((_model.ccmStatus == (1)) ||
                                                      (_model.ccmStatus ==
                                                          (3))) &&
                                                  ((functions
                                                              .returnInt(
                                                                  getJsonField(
                                                                mainGQLgetByFunctionResponse
                                                                    .jsonBody,
                                                                r'''$.data.pep_vw_consolidated_data[:].ccm_status''',
                                                              ))
                                                              .toString() ==
                                                          ("1")) ||
                                                      (functions
                                                              .returnInt(
                                                                  getJsonField(
                                                                mainGQLgetByFunctionResponse
                                                                    .jsonBody,
                                                                r'''$.data.pep_vw_consolidated_data[:].ccm_status''',
                                                              ))
                                                              .toString() ==
                                                          ("3"))))
                                                Text(
                                                  'Set only if wish to update current CCM appointment date and time',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .labelMedium
                                                      .override(
                                                        font:
                                                            GoogleFonts.poppins(
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
                                                ),
                                              Column(
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      Text(
                                                        'Book Appointment Date & Time:',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
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
                                                    ],
                                                  ),
                                                  Text(
                                                    valueOrDefault<String>(
                                                      getJsonField(
                                                        mainGQLgetByFunctionResponse
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
                                                ],
                                              ),
                                              FFButtonWidget(
                                                onPressed: () async {
                                                  // Date Time Picker
                                                  final _datePicked2Date =
                                                      await showDatePicker(
                                                    context: context,
                                                    initialDate: (null ??
                                                        DateTime.now()),
                                                    firstDate: DateTime(1900),
                                                    lastDate: DateTime(2050),
                                                    builder: (context, child) {
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
                                                        headerTextStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .headlineLarge
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .poppins(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .headlineLarge
                                                                        .fontStyle,
                                                                  ),
                                                                  fontSize:
                                                                      32.0,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
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
                                                        iconSize: 24.0,
                                                      );
                                                    },
                                                  );

                                                  TimeOfDay? _datePicked2Time;
                                                  if (_datePicked2Date !=
                                                      null) {
                                                    _datePicked2Time =
                                                        await showTimePicker(
                                                      context: context,
                                                      initialTime: TimeOfDay
                                                          .fromDateTime((null ??
                                                              DateTime.now())),
                                                      builder:
                                                          (context, child) {
                                                        return wrapInMaterialTimePickerTheme(
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
                                                          headerTextStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .headlineLarge
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .poppins(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .headlineLarge
                                                                          .fontStyle,
                                                                    ),
                                                                    fontSize:
                                                                        32.0,
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
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
                                                          iconSize: 24.0,
                                                        );
                                                      },
                                                    );
                                                  }

                                                  if (_datePicked2Date !=
                                                          null &&
                                                      _datePicked2Time !=
                                                          null) {
                                                    safeSetState(() {
                                                      _model.datePicked2 =
                                                          DateTime(
                                                        _datePicked2Date.year,
                                                        _datePicked2Date.month,
                                                        _datePicked2Date.day,
                                                        _datePicked2Time!.hour,
                                                        _datePicked2Time.minute,
                                                      );
                                                    });
                                                  } else if (_model
                                                          .datePicked2 !=
                                                      null) {
                                                    safeSetState(() {
                                                      _model.datePicked2 = null;
                                                    });
                                                  }
                                                },
                                                text: valueOrDefault<String>(
                                                  dateTimeFormat(
                                                    "d MMM, y - h:mm a",
                                                    _model.datePicked2,
                                                    locale: FFLocalizations.of(
                                                            context)
                                                        .languageCode,
                                                  ),
                                                  'Set CCM Appointment',
                                                ),
                                                options: FFButtonOptions(
                                                  width: 250.0,
                                                  height: 50.0,
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          24.0, 0.0, 24.0, 0.0),
                                                  iconPadding:
                                                      EdgeInsetsDirectional
                                                          .fromSTEB(0.0, 0.0,
                                                              0.0, 0.0),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .accent1,
                                                  textStyle: FlutterFlowTheme
                                                          .of(context)
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
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .textColor,
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
                                                  elevation: 0.0,
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .borderColor,
                                                    width: 1.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                              ),
                                            ].divide(SizedBox(width: 20.0)),
                                          ),
                                        Column(
                                          mainAxisSize: MainAxisSize.max,
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
                                                    'RPM Status:',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyLarge
                                                        .override(
                                                          font: GoogleFonts
                                                              .poppins(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyLarge
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyLarge
                                                                    .fontStyle,
                                                          ),
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyLarge
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
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
                                                        .rpmStatusListGS(
                                                      requestFn: () =>
                                                          GQLgetByFunctionCall
                                                              .call(
                                                        hasuraToken:
                                                            FFAppState()
                                                                .hasuraToken,
                                                        requestBody:
                                                            '{\"query\":\"query MyQuery {pep_v2_status_mapping_rpm(where: {global: {_eq: true}}, order_by: {id: asc}) { id status }}\"}',
                                                      ),
                                                    ),
                                                    builder:
                                                        (context, snapshot) {
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
                                                      final rpmStatusGQLgetByFunctionResponse =
                                                          snapshot.data!;

                                                      return FlutterFlowDropDown<
                                                          int>(
                                                        controller: _model
                                                                .rpmStatusValueController ??=
                                                            FormFieldController<
                                                                int>(null),
                                                        options: List<int>.from(
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
                                                        onChanged: (val) async {
                                                          safeSetState(() =>
                                                              _model.rpmStatusValue =
                                                                  val);
                                                          _model.rpmStatus =
                                                              _model
                                                                  .rpmStatusValue;
                                                          safeSetState(() {});
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
                                                            'Select RPM Status',
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
                                                        hidesUnderline: true,
                                                        isOverButton: true,
                                                        isSearchable: false,
                                                        isMultiSelect: false,
                                                      );
                                                    },
                                                  ),
                                                ),
                                                if ((_model.rpmStatus == (2)) &&
                                                    (functions
                                                            .returnInt(
                                                                getJsonField(
                                                              mainGQLgetByFunctionResponse
                                                                  .jsonBody,
                                                              r'''$.data.pep_vw_consolidated_data[:].rpm_status''',
                                                            ))
                                                            .toString() ==
                                                        ("2")))
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
                                                          Text(
                                                            'Current Appointment Date & Time:',
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
                                                        ],
                                                      ),
                                                      Text(
                                                        valueOrDefault<String>(
                                                          getJsonField(
                                                            mainGQLgetByFunctionResponse
                                                                .jsonBody,
                                                            r'''$.data.pep_vw_consolidated_data[:].patient_clinic_timezone''',
                                                          )?.toString(),
                                                          'Standard UTC',
                                                        ),
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
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
                                                if ((_model.rpmStatus == (2)) &&
                                                    (functions
                                                            .returnInt(
                                                                getJsonField(
                                                              mainGQLgetByFunctionResponse
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
                                                          mainGQLgetByFunctionResponse
                                                              .jsonBody,
                                                          r'''$.data.pep_vw_consolidated_data[:].rpm_appointment_dt''',
                                                        ).toString())),
                                                        locale:
                                                            FFLocalizations.of(
                                                                    context)
                                                                .languageCode,
                                                      ),
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
                                              ].divide(SizedBox(width: 20.0)),
                                            ),
                                            if ((_model.rpmStatus == (2)) ||
                                                (_model.rpmStatus == (7)))
                                              Row(
                                                mainAxisSize: MainAxisSize.max,
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
                                                          Text(
                                                            'Next Appointment Date & Time:',
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
                                                        ],
                                                      ),
                                                      Text(
                                                        valueOrDefault<String>(
                                                          getJsonField(
                                                            mainGQLgetByFunctionResponse
                                                                .jsonBody,
                                                            r'''$.data.pep_vw_consolidated_data[:].patient_clinic_timezone''',
                                                          )?.toString(),
                                                          'Standard UTC',
                                                        ),
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
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
                                                      if ((_model.rpmStatus ==
                                                              (2)) &&
                                                          (functions
                                                                  .returnInt(
                                                                      getJsonField(
                                                                    mainGQLgetByFunctionResponse
                                                                        .jsonBody,
                                                                    r'''$.data.pep_vw_consolidated_data[:].rpm_status''',
                                                                  ))
                                                                  .toString() ==
                                                              ("2")))
                                                        Text(
                                                          'Set only if wish to update current RPM appointment date and time',
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
                                                    ],
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
                                                    builder:
                                                        (context, snapshot) {
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
                                                      final facilityGQLgetFacilityNamesResponse =
                                                          snapshot.data!;

                                                      return FlutterFlowDropDown<
                                                          int>(
                                                        controller: _model
                                                                .facilityValueController ??=
                                                            FormFieldController<
                                                                int>(
                                                          _model.facilityValue ??=
                                                              0,
                                                        ),
                                                        options: List<int>.from(
                                                            getJsonField(
                                                          facilityGQLgetFacilityNamesResponse
                                                              .jsonBody,
                                                          r'''$.data.pep_vw_consolidated_data[:].facility_id''',
                                                          true,
                                                        )!),
                                                        optionLabels:
                                                            (getJsonField(
                                                          facilityGQLgetFacilityNamesResponse
                                                              .jsonBody,
                                                          r'''$.data.pep_vw_consolidated_data[:].facility_name''',
                                                          true,
                                                        ) as List)
                                                                .map<String>((s) =>
                                                                    s.toString())
                                                                .toList(),
                                                        onChanged: (val) async {
                                                          safeSetState(() =>
                                                              _model.facilityValue =
                                                                  val);
                                                          FFAppState()
                                                              .clearApptDateCache();
                                                          safeSetState(() {
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
                                                        width: 300.0,
                                                        height: 48.0,
                                                        textStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
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
                                                        hintText:
                                                            'Select Facility',
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
                                                                    4.0),
                                                        hidesUnderline: true,
                                                        isOverButton: true,
                                                        isSearchable: false,
                                                        isMultiSelect: false,
                                                      );
                                                    },
                                                  ),
                                                  if (_model.facilityValue !=
                                                      null)
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        FutureBuilder<
                                                            ApiCallResponse>(
                                                          future: FFAppState()
                                                              .apptDate(
                                                            requestFn: () =>
                                                                GQLgetByFunctionCall
                                                                    .call(
                                                              hasuraToken:
                                                                  FFAppState()
                                                                      .hasuraToken,
                                                              requestBody: functions
                                                                  .getAppointmentDates(
                                                                      _model
                                                                          .facilityValue!)
                                                                  .toString(),
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
                                                            final rowGQLgetByFunctionResponse =
                                                                snapshot.data!;

                                                            return Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              children: [
                                                                if (getJsonField(
                                                                      rowGQLgetByFunctionResponse
                                                                          .jsonBody,
                                                                      r'''$.data.pep_vw_available_clinic_appointments[:].appointment_date''',
                                                                    ) !=
                                                                    null)
                                                                  Align(
                                                                    alignment:
                                                                        AlignmentDirectional(
                                                                            0.0,
                                                                            0.0),
                                                                    child: FlutterFlowDropDown<
                                                                        String>(
                                                                      controller: _model
                                                                              .rPMAppDateValueController ??=
                                                                          FormFieldController<
                                                                              String>(
                                                                        _model.rPMAppDateValue ??=
                                                                            '',
                                                                      ),
                                                                      options: List<
                                                                          String>.from((getJsonField(
                                                                        rowGQLgetByFunctionResponse
                                                                            .jsonBody,
                                                                        r'''$.data.pep_vw_available_clinic_appointments[:].appointment_date''',
                                                                        true,
                                                                      ) as List)
                                                                          .map<String>((s) => s.toString())
                                                                          .toList()),
                                                                      optionLabels: (getJsonField(
                                                                        rowGQLgetByFunctionResponse
                                                                            .jsonBody,
                                                                        r'''$.data.pep_vw_available_clinic_appointments[:].fmt_appointment_date''',
                                                                        true,
                                                                      ) as List)
                                                                          .map<String>((s) => s.toString())
                                                                          .toList(),
                                                                      onChanged:
                                                                          (val) async {
                                                                        safeSetState(() =>
                                                                            _model.rPMAppDateValue =
                                                                                val);
                                                                        FFAppState()
                                                                            .clearApptTimeCache();
                                                                        safeSetState(
                                                                            () {
                                                                          _model
                                                                              .rPMAppTimeValueController
                                                                              ?.reset();
                                                                        });
                                                                      },
                                                                      width:
                                                                          160.0,
                                                                      height:
                                                                          50.0,
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
                                                                          'Select Date',
                                                                      icon:
                                                                          Icon(
                                                                        Icons
                                                                            .keyboard_arrow_down_rounded,
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .textColor,
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
                                                                    ),
                                                                  ),
                                                                if (getJsonField(
                                                                      rowGQLgetByFunctionResponse
                                                                          .jsonBody,
                                                                      r'''$.data.pep_vw_available_clinic_appointments[:].appointment_date''',
                                                                    ) ==
                                                                    null)
                                                                  Text(
                                                                    'No Slots Available',
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
                                                                    0.0, 0.0),
                                                            child: FutureBuilder<
                                                                ApiCallResponse>(
                                                              future:
                                                                  FFAppState()
                                                                      .apptTime(
                                                                requestFn: () =>
                                                                    GQLgetByFunctionCall
                                                                        .call(
                                                                  hasuraToken:
                                                                      FFAppState()
                                                                          .hasuraToken,
                                                                  requestBody: functions
                                                                      .getAppointmentTimes(
                                                                          _model
                                                                              .facilityValue!,
                                                                          _model
                                                                              .rPMAppDateValue!)
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
                                                                final rPMAppTimeGQLgetByFunctionResponse =
                                                                    snapshot
                                                                        .data!;

                                                                return FlutterFlowDropDown<
                                                                    String>(
                                                                  controller: _model
                                                                          .rPMAppTimeValueController ??=
                                                                      FormFieldController<
                                                                          String>(
                                                                    _model.rPMAppTimeValue ??=
                                                                        '',
                                                                  ),
                                                                  options: List<
                                                                          String>.from(
                                                                      (getJsonField(
                                                                    rPMAppTimeGQLgetByFunctionResponse
                                                                        .jsonBody,
                                                                    r'''$.data.pep_vw_available_clinic_appointments[:].appointment_hour''',
                                                                    true,
                                                                  ) as List)
                                                                          .map<String>((s) =>
                                                                              s.toString())
                                                                          .toList()),
                                                                  optionLabels:
                                                                      (getJsonField(
                                                                    rPMAppTimeGQLgetByFunctionResponse
                                                                        .jsonBody,
                                                                    r'''$.data.pep_vw_available_clinic_appointments[:].fmt_appointment_hour''',
                                                                    true,
                                                                  ) as List)
                                                                          .map<String>((s) =>
                                                                              s.toString())
                                                                          .toList(),
                                                                  onChanged: (val) =>
                                                                      safeSetState(() =>
                                                                          _model.rPMAppTimeValue =
                                                                              val),
                                                                  width: 160.0,
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
                                                                      'Select Time',
                                                                  icon: Icon(
                                                                    Icons
                                                                        .keyboard_arrow_down_rounded,
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .textColor,
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
                                                                      1.2,
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
                                                      ].divide(SizedBox(
                                                          width: 20.0)),
                                                    ),
                                                ].divide(SizedBox(width: 20.0)),
                                              ),
                                          ].divide(SizedBox(height: 10.0)),
                                        ),
                                        Container(
                                          width:
                                              MediaQuery.sizeOf(context).width *
                                                  0.97,
                                          decoration: BoxDecoration(),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        0.0, 0.0, 20.0, 0.0),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
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
                                                                    0.0,
                                                                    20.0,
                                                                    0.0),
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
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
                                                                            .txtFieldCommentTextController,
                                                                    focusNode:
                                                                        _model
                                                                            .txtFieldCommentFocusNode,
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
                                                                        .txtFieldCommentTextControllerValidator
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
                                                                        font: GoogleFonts
                                                                            .poppins(
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .labelLarge
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .labelLarge
                                                                              .fontStyle,
                                                                        ),
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .primaryText,
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
                                                                        font: GoogleFonts
                                                                            .poppins(
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyLarge
                                                                              .fontStyle,
                                                                        ),
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .tertiary,
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
                                                                      FlutterFlowTheme.of(
                                                                              context)
                                                                          .tertiary,
                                                                  inactiveRadioButtonColor:
                                                                      FlutterFlowTheme.of(
                                                                              context)
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
                                                  ],
                                                ),
                                              ),
                                              if (FFAppState()
                                                      .transferPatient ==
                                                  true)
                                                Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          20.0, 0.0, 2.0, 0.0),
                                                  child: Container(
                                                    width: 550.0,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .secondary,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          blurRadius: 1.0,
                                                          color:
                                                              Color(0x33000000),
                                                          offset: Offset(
                                                            0.0,
                                                            1.0,
                                                          ),
                                                        )
                                                      ],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                      border: Border.all(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                      ),
                                                    ),
                                                    child: Align(
                                                      alignment:
                                                          AlignmentDirectional(
                                                              -1.0, -1.0),
                                                      child: Container(
                                                        width: double.infinity,
                                                        height: 170.0,
                                                        child: Stack(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  1.0, -1.0),
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  EdgeInsetsDirectional
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
                                                                    child: Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
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
                                                                  if (FFAppState()
                                                                              .acceptedTransferCSName ==
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
                                                                          percent:
                                                                              valueOrDefault<double>(
                                                                            FFAppState().countdownProgressBarValue,
                                                                            1.0,
                                                                          ),
                                                                          width:
                                                                              455.0,
                                                                          lineHeight:
                                                                              6.0,
                                                                          animation:
                                                                              true,
                                                                          animateFromLastPercent:
                                                                              true,
                                                                          progressColor:
                                                                              FlutterFlowTheme.of(context).tertiary,
                                                                          backgroundColor:
                                                                              FlutterFlowTheme.of(context).primary,
                                                                          barRadius:
                                                                              Radius.circular(20.0),
                                                                          padding:
                                                                              EdgeInsets.zero,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  Align(
                                                                    alignment:
                                                                        AlignmentDirectional(
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
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyLarge
                                                                            .override(
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
                                                                  if (FFAppState()
                                                                              .acceptedTransferCSName !=
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
                                                                            alignment:
                                                                                AlignmentDirectional(-1.0, 0.0),
                                                                            child:
                                                                                Text(
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
                                                                            alignment:
                                                                                AlignmentDirectional(-1.0, 0.0),
                                                                            child:
                                                                                Text(
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
                                                                  if (FFAppState()
                                                                              .acceptedTransferCSName !=
                                                                          '')
                                                                    Align(
                                                                      alignment:
                                                                          AlignmentDirectional(
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
                                                                          'Click on \"Okay\" Button to Proceed',
                                                                          maxLines:
                                                                              2,
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyLarge
                                                                              .override(
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
                                                            Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(1.0),
                                                              child:
                                                                  FlutterFlowIconButton(
                                                                borderRadius:
                                                                    2.0,
                                                                buttonSize:
                                                                    40.0,
                                                                fillColor: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondary,
                                                                icon: Icon(
                                                                  Icons.clear,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .error,
                                                                  size: 24.0,
                                                                ),
                                                                onPressed:
                                                                    () async {
                                                                  _model.invalidateTransferPatientDetailsFromCancel =
                                                                      await PEPAPIsGroup
                                                                          .invalidateTransferredPatientCall
                                                                          .call(
                                                                    loginID: int.parse(
                                                                        FFAppState()
                                                                            .loginProfileID),
                                                                    authToken:
                                                                        FFAppState()
                                                                            .loginToken,
                                                                    transferID:
                                                                        _model
                                                                            .transferredPatientId,
                                                                  );

                                                                  if ((_model
                                                                          .invalidateTransferPatientDetailsFromCancel
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
                                        ),
                                      ].divide(SizedBox(height: 20.0)),
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
                                          if ((_model.ccmStatusValue == (1)) &&
                                              (FFAppState().usertype ==
                                                  FFAppConstants.UserTypeES))
                                            Align(
                                              alignment: AlignmentDirectional(
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
                                                            safeSetState(() {});
                                                            FFAppState()
                                                                    .transferPatient =
                                                                false;
                                                            safeSetState(() {});
                                                            await actions
                                                                .startCountdownTimer(
                                                              false,
                                                            );
                                                            _model.isTransferPatientExecuted =
                                                                false;
                                                            safeSetState(() {});
                                                          } else {
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              SnackBar(
                                                                content: Text(
                                                                  'Invalidate Transfer Patient Failed. Please try again later!',
                                                                  style:
                                                                      TextStyle(
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
                                                            FFAppState()
                                                                    .isDetailsSaved =
                                                                false;
                                                            safeSetState(() {});
                                                          }
                                                        } else {
                                                          if (_model.txtFieldCommentTextController
                                                                      .text !=
                                                                  '') {
                                                            _model.saveTransferPatientDetails =
                                                                await PEPAPIsGroup
                                                                    .updateTransferredPatientCall
                                                                    .call(
                                                              requestBody: functions
                                                                  .patientUpdateGlobal(
                                                                      _model
                                                                          .ccmStatusValue,
                                                                      functions
                                                                          .dtFormatterNew(
                                                                              _model
                                                                                  .datePicked2,
                                                                              getJsonField(
                                                                                mainGQLgetByFunctionResponse.jsonBody,
                                                                                r'''$.data.pep_vw_consolidated_data[:].patient_clinic_timezone''',
                                                                              )
                                                                                  .toString()),
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
                                                                      _model
                                                                          .emrTextController
                                                                          .text,
                                                                      _model
                                                                          .programEligibiltyValue
                                                                          ?.toList(),
                                                                      _model
                                                                          .providerValue,
                                                                      int.parse(
                                                                          getJsonField(
                                                                        mainGQLgetByFunctionResponse
                                                                            .jsonBody,
                                                                        r'''$.data.pep_vw_consolidated_data[:].pep_patient_id''',
                                                                      )
                                                                              .toString()),
                                                                      _model
                                                                          .firstNameTextController
                                                                          .text,
                                                                      _model
                                                                          .lastNameTextController
                                                                          .text,
                                                                      _model
                                                                          .datePicked1,
                                                                      _model
                                                                          .genderValue,
                                                                      _model
                                                                          .addressTextController
                                                                          .text,
                                                                      _model
                                                                          .cityTextController
                                                                          .text,
                                                                      _model
                                                                          .stateTextController
                                                                          .text,
                                                                      _model
                                                                          .zipcodeTextController
                                                                          .text,
                                                                      _model
                                                                          .tfHomePhoneNumberTextController
                                                                          .text,
                                                                      _model
                                                                          .tfMobilePhoneNumberTextController
                                                                          .text,
                                                                      _model
                                                                          .emailTextController
                                                                          .text,
                                                                      null,
                                                                      _model
                                                                          .primaryInsTextController
                                                                          .text,
                                                                      _model
                                                                          .secondaryInsTextController
                                                                          .text,
                                                                      _model
                                                                          .primaryInsNumberTextController
                                                                          .text,
                                                                      _model
                                                                          .secondaryInsNumberTextController
                                                                          .text,
                                                                      true,
                                                                      _model
                                                                          .txtFieldCommentTextController
                                                                          .text,
                                                                      _model
                                                                          .primaryDxSelectValue,
                                                                      _model
                                                                          .secondaryDxSelectValue,
                                                                      null,
                                                                      false,
                                                                      true),
                                                              loginID: int.parse(
                                                                  FFAppState()
                                                                      .loginProfileID),
                                                              patientClinicDataID:
                                                                  widget
                                                                      .patientClinicDataID,
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
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .showSnackBar(
                                                                SnackBar(
                                                                  content: Text(
                                                                    'Transfer Patient Failed. Please try again later!',
                                                                    style:
                                                                        TextStyle(
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
                                                                  'Please Add a Comment',
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
                                                        }

                                                        safeSetState(() {});
                                                      },
                                                text: 'Transfer Patient',
                                                options: FFButtonOptions(
                                                  width: 170.0,
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
                                                      .warning,
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
                                                                .primaryText,
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
                                          if (FFAppState().transferPatient ==
                                              false)
                                            Align(
                                              alignment: AlignmentDirectional(
                                                  1.0, 0.0),
                                              child: FFButtonWidget(
                                                onPressed: (FFAppState()
                                                            .isDetailsSaved ==
                                                        true)
                                                    ? null
                                                    : () async {
                                                        if (_model
                                                                .primaryDxSelectValue !=
                                                            _model
                                                                .secondaryDxSelectValue) {
                                                          if ((_model.ccmStatusValue !=
                                                                  null) ||
                                                              (_model.rpmStatusValue !=
                                                                  null)) {
                                                            if (_model.txtFieldCommentTextController
                                                                        .text !=
                                                                    '') {
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
                                                                    _model.ccmStatusValue,
                                                                    functions.dtFormatterNew(
                                                                        _model.datePicked2,
                                                                        getJsonField(
                                                                          mainGQLgetByFunctionResponse
                                                                              .jsonBody,
                                                                          r'''$.data.pep_vw_consolidated_data[:].patient_clinic_timezone''',
                                                                        ).toString()),
                                                                    (null)?.toList(),
                                                                    _model.rpmStatusValue,
                                                                    _model.rPMAppDateValue,
                                                                    _model.rPMAppTimeValue,
                                                                    _model.facilityValue,
                                                                    (null)?.toList(),
                                                                    _model.emrTextController.text,
                                                                    _model.programEligibiltyValue?.toList(),
                                                                    _model.providerValue,
                                                                    int.parse(getJsonField(
                                                                      mainGQLgetByFunctionResponse
                                                                          .jsonBody,
                                                                      r'''$.data.pep_vw_consolidated_data[:].pep_patient_id''',
                                                                    ).toString()),
                                                                    _model.firstNameTextController.text,
                                                                    _model.lastNameTextController.text,
                                                                    _model.datePicked1,
                                                                    _model.genderValue,
                                                                    _model.addressTextController.text,
                                                                    _model.cityTextController.text,
                                                                    _model.stateTextController.text,
                                                                    _model.zipcodeTextController.text,
                                                                    _model.tfHomePhoneNumberTextController.text,
                                                                    _model.tfMobilePhoneNumberTextController.text,
                                                                    _model.emailTextController.text,
                                                                    null,
                                                                    _model.primaryInsTextController.text,
                                                                    _model.secondaryInsTextController.text,
                                                                    _model.primaryInsNumberTextController.text,
                                                                    _model.secondaryInsNumberTextController.text,
                                                                    true,
                                                                    _model.txtFieldCommentTextController.text,
                                                                    _model.primaryDxSelectValue,
                                                                    _model.secondaryDxSelectValue,
                                                                    null,
                                                                    false,
                                                                    false),
                                                              );

                                                              if ((_model
                                                                      .updatePatient
                                                                      ?.succeeded ??
                                                                  true)) {
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
                                                                  _model.InstantTimerNested
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
                                                                    'globalReload':
                                                                        serializeParam(
                                                                      true,
                                                                      ParamType
                                                                          .bool,
                                                                    ),
                                                                  }.withoutNulls,
                                                                );
                                                              } else {
                                                                if (functions
                                                                        .returnString(
                                                                            getJsonField(
                                                                      (_model.updatePatient
                                                                              ?.jsonBody ??
                                                                          ''),
                                                                      r'''$.message''',
                                                                    )) ==
                                                                    ("Slot Booked for this Date and Time")) {
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(
                                                                    SnackBar(
                                                                      content:
                                                                          Text(
                                                                        'Patient Update Failed. Cannot book slot for this Date and Time!',
                                                                        style: GoogleFonts
                                                                            .poppins(
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
                                                                } else {
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(
                                                                    SnackBar(
                                                                      content:
                                                                          Text(
                                                                        'Update Failed',
                                                                        style: GoogleFonts
                                                                            .poppins(
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
                                                                }
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
                                                            _model.updatePatientWithoutStatus =
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
                                                              requestBody: functions
                                                                  .patientUpdateGlobal(
                                                                      _model
                                                                          .ccmStatusValue,
                                                                      functions
                                                                          .dtFormatterNew(
                                                                              _model
                                                                                  .datePicked2,
                                                                              getJsonField(
                                                                                mainGQLgetByFunctionResponse.jsonBody,
                                                                                r'''$.data.pep_vw_consolidated_data[:].patient_clinic_timezone''',
                                                                              )
                                                                                  .toString()),
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
                                                                      _model
                                                                          .emrTextController
                                                                          .text,
                                                                      _model
                                                                          .programEligibiltyValue
                                                                          ?.toList(),
                                                                      _model
                                                                          .providerValue,
                                                                      int.parse(
                                                                          getJsonField(
                                                                        mainGQLgetByFunctionResponse
                                                                            .jsonBody,
                                                                        r'''$.data.pep_vw_consolidated_data[:].pep_patient_id''',
                                                                      )
                                                                              .toString()),
                                                                      _model
                                                                          .firstNameTextController
                                                                          .text,
                                                                      _model
                                                                          .lastNameTextController
                                                                          .text,
                                                                      _model
                                                                          .datePicked1,
                                                                      _model
                                                                          .genderValue,
                                                                      _model
                                                                          .addressTextController
                                                                          .text,
                                                                      _model
                                                                          .cityTextController
                                                                          .text,
                                                                      _model
                                                                          .stateTextController
                                                                          .text,
                                                                      _model
                                                                          .zipcodeTextController
                                                                          .text,
                                                                      _model
                                                                          .tfHomePhoneNumberTextController
                                                                          .text,
                                                                      _model
                                                                          .tfMobilePhoneNumberTextController
                                                                          .text,
                                                                      _model
                                                                          .emailTextController
                                                                          .text,
                                                                      null,
                                                                      _model
                                                                          .primaryInsTextController
                                                                          .text,
                                                                      _model
                                                                          .secondaryInsTextController
                                                                          .text,
                                                                      _model
                                                                          .primaryInsNumberTextController
                                                                          .text,
                                                                      _model
                                                                          .secondaryInsNumberTextController
                                                                          .text,
                                                                      true,
                                                                      _model
                                                                          .txtFieldCommentTextController
                                                                          .text,
                                                                      _model
                                                                          .primaryDxSelectValue,
                                                                      _model
                                                                          .secondaryDxSelectValue,
                                                                      null,
                                                                      false,
                                                                      false),
                                                            );

                                                            if ((_model
                                                                    .updatePatientWithoutStatus
                                                                    ?.succeeded ??
                                                                true)) {
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
                                                                _model.InstantTimerNested
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
                                                                  'globalReload':
                                                                      serializeParam(
                                                                    true,
                                                                    ParamType
                                                                        .bool,
                                                                  ),
                                                                }.withoutNulls,
                                                              );
                                                            } else {
                                                              if (functions
                                                                      .returnString(
                                                                          getJsonField(
                                                                    (_model.updatePatientWithoutStatus
                                                                            ?.jsonBody ??
                                                                        ''),
                                                                    r'''$.message''',
                                                                  )) ==
                                                                  ("Slot Booked for this Date and Time")) {
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                  SnackBar(
                                                                    content:
                                                                        Text(
                                                                      'Patient Update Failed. Cannot book slot for this Date and Time!',
                                                                      style: GoogleFonts
                                                                          .poppins(
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
                                                              } else {
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                  SnackBar(
                                                                    content:
                                                                        Text(
                                                                      'Update Failed',
                                                                      style: GoogleFonts
                                                                          .poppins(
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
                                                              }
                                                            }
                                                          }
                                                        } else {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                'Primary and Secondary Dx cannot be the same!',
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
                                          if (FFAppState()
                                                      .acceptedTransferCSName !=
                                                  '')
                                            FFButtonWidget(
                                              onPressed: () async {
                                                FFAppState()
                                                    .clearPatientDetailsCacheCache();
                                                FFAppState()
                                                    .clearCcmStatusUpdatesCache();
                                                FFAppState()
                                                    .clearRpmStatusUpdatesCache();
                                                FFAppState()
                                                    .clearProviderListCache();
                                                FFAppState()
                                                    .clearFacilityListCache();
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
                                                  _model.InstantTimerNested
                                                      ?.cancel();
                                                  _model
                                                      .patientInstantTimerNested
                                                      ?.cancel();
                                                }

                                                FFAppState().transferPatient =
                                                    false;
                                                FFAppState()
                                                    .acceptedTransferCSName = '';
                                                FFAppState().isDetailsSaved =
                                                    false;
                                                safeSetState(() {});

                                                context.goNamed(
                                                    GSListViewWidget.routeName);
                                              },
                                              text: 'Okay',
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
                                          if (FFAppState()
                                                      .acceptedTransferCSName ==
                                                  '')
                                            FFButtonWidget(
                                              onPressed: () async {
                                                if (FFAppState()
                                                    .transferPatient) {
                                                  safeSetState(() {
                                                    _model
                                                        .txtFieldCommentTextController
                                                        ?.clear();
                                                  });
                                                  _model.invalidateCancelBtnTransferPatientDetails =
                                                      await PEPAPIsGroup
                                                          .invalidateTransferredPatientCall
                                                          .call(
                                                    loginID: int.parse(
                                                        FFAppState()
                                                            .loginProfileID),
                                                    authToken:
                                                        FFAppState().loginToken,
                                                    transferID: _model
                                                        .transferredPatientId,
                                                  );

                                                  if ((_model
                                                          .invalidateCancelBtnTransferPatientDetails
                                                          ?.succeeded ??
                                                      true)) {
                                                    _model.transferredPatientId =
                                                        null;
                                                    safeSetState(() {});
                                                    FFAppState()
                                                            .transferPatient =
                                                        false;
                                                    safeSetState(() {});
                                                    await actions
                                                        .startCountdownTimer(
                                                      false,
                                                    );
                                                    _model.isTransferPatientExecuted =
                                                        false;
                                                    safeSetState(() {});
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          'Invalidate Transfer Patient Failed. Please try again later!',
                                                          style: TextStyle(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondary,
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
                                                    FFAppState()
                                                        .isDetailsSaved = false;
                                                    safeSetState(() {});
                                                  }
                                                } else {
                                                  FFAppState()
                                                      .clearPatientDetailsCacheCache();
                                                  FFAppState()
                                                      .clearCcmStatusUpdatesCache();
                                                  FFAppState()
                                                      .clearRpmStatusUpdatesCache();
                                                  FFAppState()
                                                      .clearProviderListCache();
                                                  FFAppState()
                                                      .clearFacilityListCache();
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
                                                    _model.instantTimer
                                                        ?.cancel();
                                                  } else {
                                                    _model.InstantTimerNested
                                                        ?.cancel();
                                                    _model
                                                        .patientInstantTimerNested
                                                        ?.cancel();
                                                  }

                                                  context.goNamed(
                                                      GSListViewWidget
                                                          .routeName);
                                                }

                                                safeSetState(() {});
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
