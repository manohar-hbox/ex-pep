import '/backend/api_requests/api_calls.dart';
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
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'g_s_list_view_model.dart';
export 'g_s_list_view_model.dart';

class GSListViewWidget extends StatefulWidget {
  const GSListViewWidget({super.key});

  static String routeName = 'GSListView';
  static String routePath = 'GSListView';

  @override
  State<GSListViewWidget> createState() => _GSListViewWidgetState();
}

class _GSListViewWidgetState extends State<GSListViewWidget> {
  late GSListViewModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => GSListViewModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (FFAppState().loginToken != '') {
        _model.sessionTimerController.timer.setPresetTime(
          mSec: FFAppState().timerState,
          add: false,
        );
        _model.sessionTimerController.onResetTimer();

        _model.sessionTimerController.onStartTimer();
        _model.patientList = null;
        safeSetState(() {});
        safeSetState(() {
          _model.patientSearchTextController?.clear();
        });
        _model.getGsOnLoad = await GQLgetByFunctionCall.call(
          hasuraToken: FFAppState().hasuraToken,
          requestBody: functions.dropDownGlobalSearch('1', 'A').toString(),
        );

        _model.patientList = getJsonField(
          (_model.getGsOnLoad?.jsonBody ?? ''),
          r'''$.data.pep_vw_consolidated_data''',
        );
        safeSetState(() {});
        FFAppState().isPaused = true;
        safeSetState(() {});
        await Future.delayed(const Duration(milliseconds: 500));
        _model.dataTableGroupListController.paginatorController
            .setRowsPerPage(10);
        _model.instantTimer = InstantTimer.periodic(
          duration: Duration(milliseconds: 1000),
          callback: (timer) async {
            if ((FFAppState().usertype != FFAppConstants.UserTypeGA) &&
                (FFAppState().usertype != FFAppConstants.UserTypeEA) &&
                (FFAppState().usertype != FFAppConstants.UserTypeCA) &&
                (FFAppState().usertype != FFAppConstants.UserTypePA)) {
              if (((_model.sessionTimerMilliseconds ~/ 1000) % 60) == 0) {
                _model.updateTimerPageLoad =
                    await PEPAPIsGroup.updateTimerLogCall.call(
                  duration: _model.sessionTimerMilliseconds ~/ 1000,
                  userId: FFAppState().loginProfileID,
                  timelogId: FFAppState().timerlogId,
                  authToken: FFAppState().loginToken,
                );
              }
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

    _model.patientSearchTextController ??= TextEditingController();
    _model.patientSearchFocusNode ??= FocusNode();

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
                            'Global Search',
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
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
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
                    if ((FFAppState().usertype != FFAppConstants.UserTypeGA) &&
                        (FFAppState().usertype != FFAppConstants.UserTypeEA) &&
                        (FFAppState().usertype != FFAppConstants.UserTypeCA) &&
                        (FFAppState().usertype != FFAppConstants.UserTypePA))
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
                                  onChanged:
                                      (value, displayTime, shouldUpdate) {
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
                                    _model.sessionTimerController
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

                          safeSetState(() {});
                          safeSetState(() {
                            _model.patientSearchTextController?.clear();
                          });
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
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(20.0, 32.0, 20.0, 0.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          FlutterFlowIconButton(
                            borderRadius: 8.0,
                            buttonSize: 40.0,
                            fillColor: FlutterFlowTheme.of(context).primary,
                            icon: Icon(
                              Icons.arrow_back,
                              color: FlutterFlowTheme.of(context).info,
                              size: 24.0,
                            ),
                            onPressed: () async {
                              FFAppState().timerState = FFAppState().timerState;
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

                              if (FFAppState().usertype ==
                                  FFAppConstants.UserTypeGA) {
                                FFAppState().filterApplied = false;
                                safeSetState(() {});

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
                              } else if (FFAppState().usertype ==
                                  FFAppConstants.UserTypeEA) {
                                FFAppState().filterApplied = false;
                                safeSetState(() {});

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
                              } else if (FFAppState().usertype ==
                                  FFAppConstants.UserTypeES) {
                                context.goNamed(VPEDashboardWidget.routeName);
                              } else if (FFAppState().usertype ==
                                  FFAppConstants.UserTypeCA) {
                                context.goNamed(
                                  ViewCSWidget.routeName,
                                  extra: <String, dynamic>{
                                    kTransitionInfoKey: TransitionInfo(
                                      hasTransition: true,
                                      transitionType: PageTransitionType.fade,
                                      duration: Duration(milliseconds: 400),
                                    ),
                                  },
                                );
                              } else if (FFAppState().usertype ==
                                  FFAppConstants.UserTypeCS) {
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
                              } else if (FFAppState().usertype ==
                                  FFAppConstants.UserTypePA) {
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
                              } else if (FFAppState().usertype ==
                                  FFAppConstants.UserTypePE) {
                                FFAppState().filterApplied = false;
                                safeSetState(() {});

                                context.goNamed(
                                  PESPatientListWidget.routeName,
                                  extra: <String, dynamic>{
                                    kTransitionInfoKey: TransitionInfo(
                                      hasTransition: true,
                                      transitionType: PageTransitionType.fade,
                                      duration: Duration(milliseconds: 400),
                                    ),
                                  },
                                );
                              }
                            },
                          ),
                          FlutterFlowDropDown<int>(
                            controller: _model.dropDownValueController ??=
                                FormFieldController<int>(
                              _model.dropDownValue ??= 1,
                            ),
                            options: List<int>.from([1, 2, 3, 4, 5, 6]),
                            optionLabels: [
                              'Name',
                              'DOB',
                              'EMR',
                              'Home  Phone Number',
                              'Mobile Phone Number',
                              'Clinic Name'
                            ],
                            onChanged: (val) async {
                              safeSetState(() => _model.dropDownValue = val);
                              safeSetState(() {
                                _model.patientSearchTextController?.clear();
                              });
                              _model.dropDown = _model.dropDownValue;
                              safeSetState(() {});
                            },
                            width: 200.0,
                            height: 56.0,
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
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                            hintText: 'Search By',
                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: FlutterFlowTheme.of(context).secondaryText,
                              size: 24.0,
                            ),
                            fillColor: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            elevation: 2.0,
                            borderColor:
                                FlutterFlowTheme.of(context).borderColor,
                            borderWidth: 1.0,
                            borderRadius: 8.0,
                            margin: EdgeInsetsDirectional.fromSTEB(
                                12.0, 0.0, 12.0, 0.0),
                            hidesUnderline: true,
                            isOverButton: false,
                            isSearchable: false,
                            isMultiSelect: false,
                          ),
                          if (_model.dropDownValue != (2))
                            Container(
                              width: 360.0,
                              height: 56.0,
                              decoration: BoxDecoration(),
                              child: Container(
                                width: 360.0,
                                child: TextFormField(
                                  controller:
                                      _model.patientSearchTextController,
                                  focusNode: _model.patientSearchFocusNode,
                                  onChanged: (_) => EasyDebounce.debounce(
                                    '_model.patientSearchTextController',
                                    Duration(milliseconds: 2000),
                                    () => safeSetState(() {}),
                                  ),
                                  autofocus: true,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    labelText:
                                        'Search Patient by Name, EMR, DOB, Phone/Home Number..',
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
                                          fontSize: 14.0,
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
                                    suffixIcon: _model
                                            .patientSearchTextController!
                                            .text
                                            .isNotEmpty
                                        ? InkWell(
                                            onTap: () async {
                                              _model.patientSearchTextController
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
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                  cursorColor:
                                      FlutterFlowTheme.of(context).tertiary,
                                  validator: _model
                                      .patientSearchTextControllerValidator
                                      .asValidator(context),
                                ),
                              ),
                            ),
                          if (_model.dropDownValue == (2))
                            FFButtonWidget(
                              onPressed: () async {
                                _model.dropDown = _model.dropDownValue;
                                safeSetState(() {});
                                // Last Seen Date
                                final _datePickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: (null ?? DateTime.now()),
                                  firstDate: DateTime(1900),
                                  lastDate: (null ?? DateTime.now()),
                                  builder: (context, child) {
                                    return wrapInMaterialDatePickerTheme(
                                      context,
                                      child!,
                                      headerBackgroundColor:
                                          FlutterFlowTheme.of(context).primary,
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
                                                  FlutterFlowTheme.of(context)
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
                                          FlutterFlowTheme.of(context).primary,
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
                                dateTimeFormat(
                                  "d/M/y",
                                  _model.datePicked,
                                  locale:
                                      FFLocalizations.of(context).languageCode,
                                ),
                                'Select Date of Birth',
                              ),
                              icon: Icon(
                                Icons.date_range,
                                size: 24.0,
                              ),
                              options: FFButtonOptions(
                                width: 250.0,
                                height: 56.0,
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    24.0, 0.0, 24.0, 0.0),
                                iconPadding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 0.0),
                                iconColor:
                                    FlutterFlowTheme.of(context).primaryText,
                                color: FlutterFlowTheme.of(context).accent4,
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
                                          .primaryText,
                                      fontSize: 16.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .titleMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
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
                          FFButtonWidget(
                            onPressed: (((_model.dropDownValue == null) &&
                                        (_model.patientSearchTextController
                                                    .text ==
                                                '')) ||
                                    ((_model.dropDownValue == null) &&
                                        (_model.datePicked == null)))
                                ? null
                                : () async {
                                    _model.patientList = null;
                                    safeSetState(() {});
                                    FFAppState().filterApplied = true;
                                    safeSetState(() {});
                                    _model.dropDownGlobalSearch =
                                        await GQLgetByFunctionCall.call(
                                      hasuraToken: FFAppState().hasuraToken,
                                      requestBody: valueOrDefault<String>(
                                        functions
                                            .dropDownGlobalSearch(
                                                _model.dropDownValue!
                                                    .toString(),
                                                _model.dropDown == (2)
                                                    ? _model.datePicked!
                                                        .toString()
                                                    : _model
                                                        .patientSearchTextController
                                                        .text)
                                            .toString(),
                                        'A',
                                      ),
                                    );

                                    _model.patientList = getJsonField(
                                      (_model.dropDownGlobalSearch?.jsonBody ??
                                          ''),
                                      r'''$.data.pep_vw_consolidated_data''',
                                    );
                                    safeSetState(() {});

                                    safeSetState(() {});
                                  },
                            text: 'Search',
                            options: FFButtonOptions(
                              width: 100.0,
                              height: 46.0,
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
                                    color:
                                        FlutterFlowTheme.of(context).buttonText,
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
                              disabledColor:
                                  FlutterFlowTheme.of(context).alternate,
                            ),
                          ),
                        ].divide(SizedBox(width: 20.0)),
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional(0.0, 1.0),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            0.0, 32.0, 20.0, 0.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: AlignmentDirectional(0.0, -1.0),
                              child: FlutterFlowIconButton(
                                borderColor: Colors.transparent,
                                borderRadius: 20.0,
                                borderWidth: 1.0,
                                buttonSize: 40.0,
                                fillColor:
                                    FlutterFlowTheme.of(context).tertiary,
                                icon: Icon(
                                  Icons.refresh_sharp,
                                  color:
                                      FlutterFlowTheme.of(context).buttonText,
                                  size: 24.0,
                                ),
                                onPressed: () async {
                                  _model.patientList = null;
                                  safeSetState(() {});
                                  FFAppState().filterApplied = false;
                                  safeSetState(() {});
                                  safeSetState(() {
                                    _model.patientSearchTextController?.clear();
                                  });
                                  _model.getGsOnReload =
                                      await GQLgetByFunctionCall.call(
                                    hasuraToken: FFAppState().hasuraToken,
                                    requestBody: functions
                                        .dropDownGlobalSearch('1', 'A')
                                        .toString(),
                                  );

                                  _model.patientList = getJsonField(
                                    (_model.getGsOnReload?.jsonBody ?? ''),
                                    r'''$.data.pep_vw_consolidated_data''',
                                  );
                                  safeSetState(() {});

                                  safeSetState(() {});
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (_model.patientList != null)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Builder(
                        builder: (context) {
                          final gSList = _model.patientList?.toList() ?? [];

                          return FlutterFlowDataTable<dynamic>(
                            controller: _model.dataTableGroupListController,
                            data: gSList,
                            columnsBuilder: (onSortChanged) => [
                              DataColumn2(
                                label: DefaultTextStyle.merge(
                                  softWrap: true,
                                  child: Text(
                                    'Full Name',
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
                                    MediaQuery.sizeOf(context).width * 0.2,
                              ),
                              DataColumn2(
                                label: DefaultTextStyle.merge(
                                  softWrap: true,
                                  child: Text(
                                    'DOB',
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
                                    MediaQuery.sizeOf(context).width * 0.08,
                              ),
                              DataColumn2(
                                label: DefaultTextStyle.merge(
                                  softWrap: true,
                                  child: Text(
                                    'Mobile Number',
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
                                    MediaQuery.sizeOf(context).width * 0.12,
                              ),
                              DataColumn2(
                                label: DefaultTextStyle.merge(
                                  softWrap: true,
                                  child: Text(
                                    'Home Number',
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
                                    MediaQuery.sizeOf(context).width * 0.12,
                              ),
                              DataColumn2(
                                label: DefaultTextStyle.merge(
                                  softWrap: true,
                                  child: Text(
                                    'Email',
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
                                    MediaQuery.sizeOf(context).width * 0.12,
                              ),
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
                                    MediaQuery.sizeOf(context).width * 0.16,
                              ),
                              DataColumn2(
                                label: DefaultTextStyle.merge(
                                  softWrap: true,
                                  child: Text(
                                    'EMR',
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
                                    MediaQuery.sizeOf(context).width * 0.06,
                              ),
                              DataColumn2(
                                label: DefaultTextStyle.merge(
                                  softWrap: true,
                                  child: Align(
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    child: Text(
                                      'Action',
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
                                ),
                                fixedWidth:
                                    MediaQuery.sizeOf(context).width * 0.08,
                              ),
                            ],
                            dataRowBuilder: (gSListItem, gSListIndex, selected,
                                    onSelectChanged) =>
                                DataRow(
                              color: WidgetStateProperty.all(
                                gSListIndex % 2 == 0
                                    ? FlutterFlowTheme.of(context)
                                        .secondaryBackground
                                    : FlutterFlowTheme.of(context).alternateRow,
                              ),
                              cells: [
                                Text(
                                  getJsonField(
                                    gSListItem,
                                    r'''$.full_name''',
                                  ).toString(),
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
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                ),
                                Text(
                                  valueOrDefault<String>(
                                    dateTimeFormat(
                                      "MM/dd/yy",
                                      functions.returnDT(getJsonField(
                                        gSListItem,
                                        r'''$.dob''',
                                      ).toString()),
                                      locale: FFLocalizations.of(context)
                                          .languageCode,
                                    ),
                                    'DOB',
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
                                    gSListItem,
                                    r'''$.mobile_phone_number''',
                                  ).toString(),
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
                                    gSListItem,
                                    r'''$.home_phone_number''',
                                  ).toString(),
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
                                    gSListItem,
                                    r'''$.email''',
                                  ).toString(),
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
                                    gSListItem,
                                    r'''$.clinic_name''',
                                  ).toString(),
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
                                    gSListItem,
                                    r'''$.emr_id''',
                                  ).toString(),
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
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Align(
                                      alignment: AlignmentDirectional(0.0, 0.0),
                                      child: FlutterFlowIconButton(
                                        borderColor:
                                            FlutterFlowTheme.of(context)
                                                .tertiary,
                                        borderRadius: 20.0,
                                        borderWidth: 1.0,
                                        buttonSize: 38.0,
                                        fillColor: FlutterFlowTheme.of(context)
                                            .secondary,
                                        icon: Icon(
                                          Icons.open_in_new,
                                          color: FlutterFlowTheme.of(context)
                                              .tertiary,
                                          size: 22.0,
                                        ),
                                        onPressed: () async {
                                          FFAppState()
                                              .clearPatientDetailsCacheCache();
                                          FFAppState().clearProviderListCache();
                                          FFAppState().clearFacilityListCache();
                                          FFAppState().timerState =
                                              FFAppState().timerState;
                                          safeSetState(() {});
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

                                          context.goNamed(
                                            GSPatientViewWidget.routeName,
                                            queryParameters: {
                                              'patientClinicDataID':
                                                  serializeParam(
                                                getJsonField(
                                                  gSListItem,
                                                  r'''$.patient_clinic_data_id''',
                                                ),
                                                ParamType.int,
                                              ),
                                              'clinicID': serializeParam(
                                                getJsonField(
                                                  gSListItem,
                                                  r'''$.clinic_id''',
                                                ),
                                                ParamType.int,
                                              ),
                                            }.withoutNulls,
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ].map((c) => DataCell(c)).toList(),
                            ),
                            paginated: true,
                            selectable: false,
                            hidePaginator: false,
                            showFirstLastButtons: false,
                            width: MediaQuery.sizeOf(context).width * 1.0,
                            headingRowHeight: 56.0,
                            dataRowHeight: 48.0,
                            columnSpacing: 1.0,
                            headingRowColor:
                                FlutterFlowTheme.of(context).primary,
                            borderRadius: BorderRadius.circular(8.0),
                            addHorizontalDivider: true,
                            addTopAndBottomDivider: false,
                            hideDefaultHorizontalDivider: true,
                            horizontalDividerColor:
                                FlutterFlowTheme.of(context).alternateRow,
                            horizontalDividerThickness: 1.0,
                            addVerticalDivider: false,
                          );
                        },
                      ),
                    ),
                  ),
                if (_model.patientList == null)
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional(0.0, 0.0),
                      child: Lottie.asset(
                        'assets/jsons/progress.json',
                        width: 100.0,
                        height: 100.0,
                        fit: BoxFit.contain,
                        frameRate: FrameRate(120.0),
                        animate: true,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
