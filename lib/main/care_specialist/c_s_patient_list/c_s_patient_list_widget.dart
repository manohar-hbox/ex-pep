import 'package:patient_enrollment_program/custom_code/services/twilio_client_manager.dart';
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
import 'c_s_patient_list_model.dart';
export 'c_s_patient_list_model.dart';

class CSPatientListWidget extends StatefulWidget {
  const CSPatientListWidget({super.key});

  static String routeName = 'CSPatientList';
  static String routePath = 'CSPatientList';

  @override
  State<CSPatientListWidget> createState() => _CSPatientListWidgetState();
}

class _CSPatientListWidgetState extends State<CSPatientListWidget> {
  late CSPatientListModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CSPatientListModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await actions.checkAndStoreRedirectURL();
      await actions.loadHasuraAndLoginToken();
      if (FFAppState().loginToken != '') {
        _model.sessionTimerController.timer.setPresetTime(
          mSec: FFAppState().timerState,
          add: false,
        );
        _model.sessionTimerController.onResetTimer();

        _model.sessionTimerController.onStartTimer();
        _model.csPatientList = [];
        _model.csPatientListFiltered = [];
        _model.dateSearch = null;
        _model.pageLoad = false;
        _model.ccmStaus = [];
        _model.rpmStatus = [];
        safeSetState(() {});
        safeSetState(() {
          _model.searchStringTextController?.clear();
        });
        FFAppState().isCSView = true;
        safeSetState(() {});
        _model.cSAssignedTasksResponse = await GQLgetByFunctionCall.call(
          hasuraToken: FFAppState().hasuraToken,
          requestBody: functions
              .checkCSAssignedTasks(
                  (int.parse(FFAppState().loginProfileID)).toString())
              .toString(),
        );

        // Initialization Twilio for Inbound and Outbound Calls
        final twilioClientManager = TwilioClientManager();
        String identity = FFAppState().loginEmail;  // This should come from your user's session

        // Register to receive incoming calls
        final success = await twilioClientManager.registerForIncomingCalls(identity, true);

        if (success) {
          print("Token Generated");
        } else {
          print("Failed to register Token");
        }

        _model.checkDeferredTaskAssigned = getJsonField(
          (_model.cSAssignedTasksResponse?.jsonBody ?? ''),
          r'''$.data.pep_vw_care_specialist_list[:].deferred_task''',
        );
        _model.checkFollowUpTaskAssigned = getJsonField(
          (_model.cSAssignedTasksResponse?.jsonBody ?? ''),
          r'''$.data.pep_vw_care_specialist_list[:].follow_up''',
        );
        safeSetState(() {});
        _model.getTransferUpdatedListSubscriptionCount =
            await actions.getTransferredPatientListSubscription(
          context,
          FFAppState().hasuraToken,
          int.parse(FFAppState().loginProfileID),
        );
        if (FFAppState().viewerClinicIDS.isNotEmpty) {
          _model.csPatientListAPICallPageLoad = await GQLgetByFunctionCall.call(
            hasuraToken: FFAppState().hasuraToken,
            requestBody: functions
                .getCareSpecialistPatientList(
                    FFAppState().viewerClinicIDS.toList())
                .toString(),
          );

          _model.csPatientList = functions
              .enrichClinicTime(GQLgetByFunctionCall.careSpecialistList(
                (_model.csPatientListAPICallPageLoad?.jsonBody ?? ''),
              )!
                  .toList())
              .toList()
              .cast<dynamic>();
          safeSetState(() {});
          _model.pageLoad = true;
          safeSetState(() {});
          await Future.delayed(const Duration(milliseconds: 100));
          safeSetState(() {
            _model.csFilterDropDownValueController?.value =
                (FFAppState().csFilterDropDownIndex == ''
                    ? 'full_name'
                    : FFAppState().csFilterDropDownIndex);
          });
          if (FFAppState().csFilterDropDownContent != '') {
            if ((FFAppState().csFilterDropDownIndex == 'dob') ||
                (FFAppState().csFilterDropDownIndex ==
                    'clinic_time_appointment')) {
              _model.dateSearch = functions
                  .datetimeStringToDate(FFAppState().csFilterDropDownContent);
              safeSetState(() {});
              _model.csPatientListFiltered = functions
                  .filterCSListLocally(
                      _model.csPatientList.toList(),
                      _model.csFilterDropDownValue,
                      functions.returnDate(functions.datetimeStringToDate(
                          FFAppState().csFilterDropDownContent)!))!
                  .toList()
                  .cast<dynamic>();
              safeSetState(() {});
            } else {
              safeSetState(() {
                _model.searchStringTextController?.text =
                    FFAppState().csFilterDropDownContent;
              });
              _model.csPatientListFiltered = functions
                  .filterCSListLocally(
                      _model.csPatientList.toList(),
                      _model.csFilterDropDownValue,
                      _model.searchStringTextController.text)!
                  .toList()
                  .cast<dynamic>();
              safeSetState(() {});
            }
          } else if ((FFAppState().csFilterDropdownContentListCCM.isNotEmpty) ||
              (FFAppState().csFilterDropdownContentListRPM.isNotEmpty)) {
            if (FFAppState().csFilterDropDownIndex == 'ccm_status_value') {
              safeSetState(() {
                _model.csFilterDropDownCCMValueController?.value =
                    FFAppState().csSelectedStatusesCCM;
              });
              FFAppState().csSelectedStatusesCCM = [];
              safeSetState(() {});
              _model.csPatientListFiltered = functions
                  .filterCSListByCCMOrRPMLocally(
                      _model.csPatientList.toList(),
                      _model.csFilterDropDownValue,
                      FFAppState().csFilterDropdownContentListCCM.toList())!
                  .toList()
                  .cast<dynamic>();
              safeSetState(() {});
            } else if (FFAppState().csFilterDropDownIndex ==
                'rpm_status_value') {
              safeSetState(() {
                _model.csFilterDropDownRPMValueController?.value =
                    FFAppState().csSelectedStatusesRPM;
              });
              FFAppState().csSelectedStatusesRPM = [];
              safeSetState(() {});
              _model.csPatientListFiltered = functions
                  .filterCSListByCCMOrRPMLocally(
                      _model.csPatientList.toList(),
                      _model.csFilterDropDownValue,
                      FFAppState().csFilterDropdownContentListRPM.toList())!
                  .toList()
                  .cast<dynamic>();
              safeSetState(() {});
            } else if (FFAppState().csFilterDropDownIndex ==
                'ccm_rpm_status_value') {
              safeSetState(() {
                _model.csFilterDropDownCCMValueController?.value =
                    FFAppState().csSelectedStatusesCCM;
              });
              FFAppState().csSelectedStatusesCCM = [];
              safeSetState(() {});
              safeSetState(() {
                _model.csFilterDropDownRPMValueController?.value =
                    FFAppState().csSelectedStatusesRPM;
              });
              FFAppState().csSelectedStatusesRPM = [];
              safeSetState(() {});
              _model.csPatientListFiltered = functions
                  .filterCSListByCCMAndRPMLocally(
                      _model.csPatientList.toList(),
                      FFAppState().csFilterDropdownContentListCCM.toList(),
                      FFAppState().csFilterDropdownContentListRPM.toList())!
                  .toList()
                  .cast<dynamic>();
              safeSetState(() {});
            }
          }

          _model.dataTableGroupListController.paginatorController
              .setRowsPerPage(FFAppState().csTableRowCount);
          _model.dataTableGroupListController.paginatorController
              .goToPageWithRow(FFAppState().csTableRowIndex);
        } else {
          _model.csPatientList = [];
          safeSetState(() {});
          _model.pageLoad = true;
          safeSetState(() {});
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
        context.goNamed(LoginWidget.routeName);
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
                          'Care Specialist (CS)',
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

                          safeSetState(() {});
                          FFAppState().timerState = FFAppState().timerState;
                          safeSetState(() {});
                          FFAppState().deleteTimerState();
                          FFAppState().timerState = 0;

                          FFAppState().isCSView = false;
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
            child: Visibility(
              visible: _model.pageLoad,
              child: Align(
                alignment: AlignmentDirectional(1.0, 1.0),
                child: Stack(
                  alignment: AlignmentDirectional(1.0, 1.0),
                  children: [
                    if (!(_model.csPatientList.isNotEmpty))
                      Align(
                        alignment: AlignmentDirectional(0.0, 0.0),
                        child: Text(
                          'Congrats! You\'ve cleared all the assigned patients for today.',
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
                                20.0, 32.0, 20.0, 0.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (_model.checkFollowUpTaskAssigned == true)
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 20.0, 0.0),
                                    child: FFButtonWidget(
                                      onPressed: () async {
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
                                            CSFollowUpPatientListWidget
                                                .routeName);
                                      },
                                      text: 'Follow up Patients',
                                      options: FFButtonOptions(
                                        height: 42.0,
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            16.0, 0.0, 16.0, 0.0),
                                        iconPadding:
                                            EdgeInsetsDirectional.fromSTEB(
                                                0.0, 0.0, 0.0, 0.0),
                                        color: FlutterFlowTheme.of(context)
                                            .tertiary,
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
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                    ),
                                  ),
                                if (_model.checkDeferredTaskAssigned == true)
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 20.0, 0.0),
                                    child: FFButtonWidget(
                                      onPressed: () async {
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
                                            CSDeferredPatientListWidget
                                                .routeName);
                                      },
                                      text: 'Deferred Patients',
                                      options: FFButtonOptions(
                                        height: 42.0,
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            16.0, 0.0, 16.0, 0.0),
                                        iconPadding:
                                            EdgeInsetsDirectional.fromSTEB(
                                                0.0, 0.0, 0.0, 0.0),
                                        color: FlutterFlowTheme.of(context)
                                            .tertiary,
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
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                    ),
                                  ),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
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
                                              GSListViewWidget.routeName);
                                        },
                                        child: Container(
                                          width: 190.0,
                                          height: 42.0,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .tertiary,
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          child: Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    10.0, 0.0, 15.0, 0.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          -1.0, 0.0),
                                                  child: Icon(
                                                    Icons.search,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .buttonText,
                                                    size: 24.0,
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          10.0, 0.0, 0.0, 0.0),
                                                  child: Text(
                                                    'Search Patients',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .titleSmall
                                                        .override(
                                                          font: GoogleFonts
                                                              .poppins(
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
                                                          color: FlutterFlowTheme
                                                                  .of(context)
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
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      12.0, 0.0, 0.0, 0.0),
                                  child: Stack(
                                    alignment: AlignmentDirectional(1.0, -1.0),
                                    children: [
                                      FlutterFlowIconButton(
                                        borderRadius: 8.0,
                                        buttonSize: 60.0,
                                        fillColor: FlutterFlowTheme.of(context)
                                            .secondary,
                                        icon: Icon(
                                          Icons.notifications_active,
                                          color:
                                              FlutterFlowTheme.of(context).info,
                                          size: 42.0,
                                        ),
                                        onPressed: () async {
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
                                              CSTransferPatientListWidget
                                                  .routeName);
                                        },
                                      ),
                                      Align(
                                        alignment:
                                            AlignmentDirectional(1.0, -1.0),
                                        child: Container(
                                          width: 24.0,
                                          height: 24.0,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .error,
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            border: Border.all(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .error,
                                            ),
                                          ),
                                          child: Align(
                                            alignment:
                                                AlignmentDirectional(0.0, 0.0),
                                            child: Text(
                                              valueOrDefault<String>(
                                                FFAppState()
                                                    .transferCSRequestCount
                                                    .toString(),
                                                '0',
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
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondary,
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
                                            .csFilterDropDownValueController ??=
                                        FormFieldController<String>(
                                      _model
                                          .csFilterDropDownValue ??= (FFAppState()
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
                                      'clinic_name',
                                      'ccm_status_value',
                                      'rpm_status_value',
                                      'ccm_rpm_status_value'
                                    ]),
                                    optionLabels: [
                                      'Name',
                                      'DOB',
                                      'Phone Number',
                                      'Provider Name',
                                      'Appointment Date',
                                      'Clinic Name',
                                      'CCM Status',
                                      'RPM Status',
                                      'CCM and RPM Status'
                                    ],
                                    onChanged: (val) async {
                                      safeSetState(() =>
                                          _model.csFilterDropDownValue = val);
                                      safeSetState(() {
                                        _model.searchStringTextController
                                            ?.clear();
                                      });
                                      safeSetState(() {
                                        _model
                                            .csFilterDropDownRPMValueController
                                            ?.reset();
                                        _model
                                            .csFilterDropDownCCMValueController
                                            ?.reset();
                                      });
                                      FFAppState().csFilterDropDownIndex =
                                          _model.csFilterDropDownValue!;
                                      safeSetState(() {});
                                      if ((_model.csFilterDropDownValue ==
                                              'ccm_status_value') &&
                                          (_model.ccmMapping == null)) {
                                        _model.ccmMappingQuery =
                                            await GQLgetByFunctionCall.call(
                                          hasuraToken: FFAppState().hasuraToken,
                                          requestBody:
                                              '{  \"query\": \"query MyQuery { pep_v2_status_mapping_ccm(where: {status: {_nin: [\\\"Deferred (CS)\\\", \\\"Follow Up\\\"]}, cs: {_eq: true}}, order_by: {id: asc}) { id status } }\"}',
                                        );

                                        _model.ccmMapping =
                                            (_model.ccmMappingQuery?.jsonBody ??
                                                '');
                                        safeSetState(() {});
                                      } else if ((_model
                                                  .csFilterDropDownValue ==
                                              'rpm_status_value') &&
                                          (_model.rpmMapping == null)) {
                                        _model.rpmMappingQuery =
                                            await GQLgetByFunctionCall.call(
                                          hasuraToken: FFAppState().hasuraToken,
                                          requestBody:
                                              '{  \"query\": \"query MyQuery { pep_v2_status_mapping_rpm(where: {status: {_nin: [\\\"Deferred\\\", \\\"Follow Up\\\"]}, pes: {_eq: true}}, order_by: {id: asc}) { id status } }\"}',
                                        );

                                        _model.rpmMapping =
                                            (_model.rpmMappingQuery?.jsonBody ??
                                                '');
                                        safeSetState(() {});
                                      } else {
                                        _model.ccmElseMappingQuery =
                                            await GQLgetByFunctionCall.call(
                                          hasuraToken: FFAppState().hasuraToken,
                                          requestBody:
                                              '{\"query\":\"query MyQuery {pep_v2_status_mapping_ccm(where: {cs: {_eq: true}}, order_by: {id: asc}) { id status }}\"}',
                                        );

                                        _model.ccmMapping = (_model
                                                .ccmElseMappingQuery
                                                ?.jsonBody ??
                                            '');
                                        safeSetState(() {});
                                        FFAppState()
                                            .csFilterDropdownContentListCCM = [];
                                        FFAppState().csSelectedStatusesCCM = [];
                                        safeSetState(() {});
                                        safeSetState(() {
                                          _model
                                              .csFilterDropDownCCMValueController
                                              ?.reset();
                                          _model
                                              .csFilterDropDownRPMValueController
                                              ?.reset();
                                        });
                                        _model.rpmElseMappingQuery =
                                            await GQLgetByFunctionCall.call(
                                          hasuraToken: FFAppState().hasuraToken,
                                          requestBody:
                                              '{\"query\":\"query MyQuery {pep_v2_status_mapping_rpm(where: {pes: {_eq: true}}, order_by: {id: asc}) { id status }}\"}',
                                        );

                                        _model.rpmMapping = (_model
                                                .rpmElseMappingQuery
                                                ?.jsonBody ??
                                            '');
                                        safeSetState(() {});
                                        FFAppState()
                                            .csFilterDropdownContentListRPM = [];
                                        FFAppState().csSelectedStatusesRPM = [];
                                        safeSetState(() {});
                                      }

                                      safeSetState(() {});
                                    },
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
                                  if (!((_model.csFilterDropDownValue ==
                                          'dob') ||
                                      (_model.csFilterDropDownValue ==
                                          'clinic_time_appointment') ||
                                      (_model.csFilterDropDownValue ==
                                          'ccm_status_value') ||
                                      (_model.csFilterDropDownValue ==
                                          'rpm_status_value') ||
                                      (_model.csFilterDropDownValue ==
                                          'ccm_rpm_status_value')))
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
                                                        .csFilterDropDownValue ==
                                                    'dob') ||
                                                (_model.csFilterDropDownValue ==
                                                    'clinic_time_appointment') ||
                                                (_model.csFilterDropDownValue ==
                                                    'ccm_status_value') ||
                                                (_model.csFilterDropDownValue ==
                                                    'rpm_status_value') ||
                                                (_model.csFilterDropDownValue ==
                                                    'ccm_rpm_status_value'))) {
                                              if ((String? searchString) {
                                                return searchString == null
                                                    ? false
                                                    : (searchString.length >= 3
                                                        ? true
                                                        : false);
                                              }(_model
                                                  .searchStringTextController
                                                  .text)) {
                                                _model.csPatientListFiltered = functions
                                                    .filterCSListLocally(
                                                        _model.csPatientList
                                                            .toList(),
                                                        _model
                                                            .csFilterDropDownValue,
                                                        _model
                                                            .searchStringTextController
                                                            .text)!
                                                    .toList()
                                                    .cast<dynamic>();
                                                safeSetState(() {});
                                                FFAppState()
                                                        .csFilterDropDownContent =
                                                    _model
                                                        .searchStringTextController
                                                        .text;
                                                safeSetState(() {});
                                                FFAppState()
                                                        .csFilterDropDownIndex =
                                                    _model
                                                        .csFilterDropDownValue!;
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
                                  if (((_model.csFilterDropDownValue ==
                                              'ccm_status_value') &&
                                          (_model.ccmMapping != null)) ||
                                      ((_model.csFilterDropDownValue ==
                                              'ccm_rpm_status_value') &&
                                          (_model.ccmMapping != null)))
                                    Align(
                                      alignment: AlignmentDirectional(0.0, 0.0),
                                      child: FlutterFlowDropDown<String>(
                                        multiSelectController: _model
                                                .csFilterDropDownCCMValueController ??=
                                            FormListFieldController<
                                                String>(_model
                                                    .csFilterDropDownCCMValue ??=
                                                List<String>.from(
                                          FFAppState()
                                                  .csFilterDropdownContentListCCM ??
                                              [],
                                        )),
                                        options: List<String>.from(
                                            (getJsonField(
                                          _model.ccmMapping,
                                          r'''$.data.pep_v2_status_mapping_ccm[:].status''',
                                          true,
                                        ) as List)
                                                .map<String>(
                                                    (s) => s.toString())
                                                .toList()),
                                        optionLabels: (getJsonField(
                                          _model.ccmMapping,
                                          r'''$.data.pep_v2_status_mapping_ccm[:].status''',
                                          true,
                                        ) as List)
                                            .map<String>((s) => s.toString())
                                            .toList(),
                                        width: 220.3,
                                        height: 50.0,
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
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .textColor,
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
                                        hintText: 'Select CCM Status',
                                        icon: Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                          size: 24.0,
                                        ),
                                        fillColor: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        elevation: 2.0,
                                        borderColor:
                                            FlutterFlowTheme.of(context)
                                                .borderColor,
                                        borderWidth: 1.0,
                                        borderRadius: 8.0,
                                        margin: EdgeInsetsDirectional.fromSTEB(
                                            16.0, 0.0, 16.0, 0.0),
                                        hidesUnderline: true,
                                        isOverButton: true,
                                        isSearchable: false,
                                        isMultiSelect: true,
                                        onMultiSelectChanged: (val) async {
                                          safeSetState(() => _model
                                              .csFilterDropDownCCMValue = val);
                                          FFAppState()
                                                  .csFilterDropdownContentListCCM =
                                              _model.csFilterDropDownCCMValue!
                                                  .toList()
                                                  .cast<String>();
                                          FFAppState().csSelectedStatusesCCM =
                                              _model.csFilterDropDownCCMValue!
                                                  .toList()
                                                  .cast<String>();
                                          safeSetState(() {});
                                        },
                                      ),
                                    ),
                                  if (((_model.csFilterDropDownValue ==
                                              'rpm_status_value') &&
                                          (_model.rpmMapping != null)) ||
                                      ((_model.csFilterDropDownValue ==
                                              'ccm_rpm_status_value') &&
                                          (_model.rpmMapping != null)))
                                    Align(
                                      alignment: AlignmentDirectional(0.0, 0.0),
                                      child: FlutterFlowDropDown<String>(
                                        multiSelectController: _model
                                                .csFilterDropDownRPMValueController ??=
                                            FormListFieldController<
                                                String>(_model
                                                    .csFilterDropDownRPMValue ??=
                                                List<String>.from(
                                          FFAppState()
                                                  .csFilterDropdownContentListRPM ??
                                              [],
                                        )),
                                        options: List<String>.from(
                                            (getJsonField(
                                          _model.rpmMapping,
                                          r'''$.data.pep_v2_status_mapping_rpm[:].status''',
                                          true,
                                        ) as List)
                                                .map<String>(
                                                    (s) => s.toString())
                                                .toList()),
                                        optionLabels: (getJsonField(
                                          _model.rpmMapping,
                                          r'''$.data.pep_v2_status_mapping_rpm[:].status''',
                                          true,
                                        ) as List)
                                            .map<String>((s) => s.toString())
                                            .toList(),
                                        width: 218.9,
                                        height: 50.0,
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
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .textColor,
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
                                        hintText: 'Select RPM Status',
                                        icon: Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                          size: 24.0,
                                        ),
                                        fillColor: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        elevation: 2.0,
                                        borderColor:
                                            FlutterFlowTheme.of(context)
                                                .borderColor,
                                        borderWidth: 1.0,
                                        borderRadius: 8.0,
                                        margin: EdgeInsetsDirectional.fromSTEB(
                                            16.0, 0.0, 16.0, 0.0),
                                        hidesUnderline: true,
                                        isOverButton: true,
                                        isSearchable: false,
                                        isMultiSelect: true,
                                        onMultiSelectChanged: (val) async {
                                          safeSetState(() => _model
                                              .csFilterDropDownRPMValue = val);
                                          FFAppState()
                                                  .csFilterDropdownContentListRPM =
                                              _model.csFilterDropDownRPMValue!
                                                  .toList()
                                                  .cast<String>();
                                          FFAppState().csSelectedStatusesRPM =
                                              _model.csFilterDropDownRPMValue!
                                                  .toList()
                                                  .cast<String>();
                                          safeSetState(() {});
                                        },
                                      ),
                                    ),
                                  if ((_model.csFilterDropDownValue == 'dob') ||
                                      (_model.csFilterDropDownValue ==
                                          'clinic_time_appointment'))
                                    FFButtonWidget(
                                      onPressed: () async {
                                        // Date Time Picker
                                        final _datePickedDate =
                                            await showDatePicker(
                                          context: context,
                                          initialDate: (null ?? DateTime.now()),
                                          firstDate: DateTime(1900),
                                          lastDate: DateTime(2050),
                                          builder: (context, child) {
                                            return wrapInMaterialDatePickerTheme(
                                              context,
                                              child!,
                                              headerBackgroundColor:
                                                  FlutterFlowTheme.of(context)
                                                      .tertiary,
                                              headerForegroundColor:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
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
                                                      .tertiary,
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
                                        _model.dateSearch = _model.datePicked;
                                        safeSetState(() {});
                                        FFAppState().csFilterDropDownContent =
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
                                            24.0, 0.0, 24.0, 0.0),
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
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .textColor,
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
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                    ),
                                  FFButtonWidget(
                                    onPressed: (_model.csFilterDropDownValue ==
                                                null ||
                                            _model.csFilterDropDownValue == '')
                                        ? null
                                        : () async {
                                            if (!((_model
                                                        .csFilterDropDownValue ==
                                                    'dob') ||
                                                (_model.csFilterDropDownValue ==
                                                    'clinic_time_appointment') ||
                                                (_model.csFilterDropDownValue ==
                                                    'ccm_status_value') ||
                                                (_model.csFilterDropDownValue ==
                                                    'rpm_status_value') ||
                                                (_model.csFilterDropDownValue ==
                                                    'ccm_rpm_status_value'))) {
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
                                                _model.csPatientListFiltered = functions
                                                    .filterCSListLocally(
                                                        _model.csPatientList
                                                            .toList(),
                                                        _model
                                                            .csFilterDropDownValue,
                                                        _model
                                                            .searchStringTextController
                                                            .text)!
                                                    .toList()
                                                    .cast<dynamic>();
                                                safeSetState(() {});
                                                FFAppState()
                                                        .csFilterDropDownContent =
                                                    _model
                                                        .searchStringTextController
                                                        .text;
                                                safeSetState(() {});
                                                FFAppState()
                                                        .csFilterDropDownIndex =
                                                    _model
                                                        .csFilterDropDownValue!;
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
                                                        .csFilterDropDownValue ==
                                                    'dob') ||
                                                (_model.csFilterDropDownValue ==
                                                    'clinic_time_appointment')) {
                                              if (_model.dateSearch != null) {
                                                FFAppState().filterApplied =
                                                    true;
                                                safeSetState(() {});
                                                _model.csPatientListFiltered = functions
                                                    .filterCSListLocally(
                                                        _model.csPatientList
                                                            .toList(),
                                                        _model
                                                            .csFilterDropDownValue,
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
                                            } else if (_model
                                                    .csFilterDropDownValue ==
                                                'ccm_status_value') {
                                              if (_model.csFilterDropDownCCMValue !=
                                                      null &&
                                                  (_model.csFilterDropDownCCMValue)!
                                                      .isNotEmpty) {
                                                FFAppState().filterApplied =
                                                    true;
                                                safeSetState(() {});
                                                _model.csPatientListFiltered = functions
                                                    .filterCSListByCCMOrRPMLocally(
                                                        _model.csPatientList
                                                            .toList(),
                                                        _model
                                                            .csFilterDropDownValue,
                                                        _model
                                                            .csFilterDropDownCCMValue
                                                            ?.toList())!
                                                    .toList()
                                                    .cast<dynamic>();
                                                safeSetState(() {});
                                                FFAppState()
                                                        .csFilterDropDownIndex =
                                                    _model
                                                        .csFilterDropDownValue!;
                                                FFAppState()
                                                        .csSelectedStatusesCCM =
                                                    _model
                                                        .csFilterDropDownCCMValue!
                                                        .toList()
                                                        .cast<String>();
                                                safeSetState(() {});
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Select CCM Status',
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
                                            } else if (_model
                                                    .csFilterDropDownValue ==
                                                'rpm_status_value') {
                                              if (_model.csFilterDropDownRPMValue !=
                                                      null &&
                                                  (_model.csFilterDropDownRPMValue)!
                                                      .isNotEmpty) {
                                                FFAppState().filterApplied =
                                                    true;
                                                safeSetState(() {});
                                                _model.csPatientListFiltered = functions
                                                    .filterCSListByCCMOrRPMLocally(
                                                        _model.csPatientList
                                                            .toList(),
                                                        _model
                                                            .csFilterDropDownValue,
                                                        _model
                                                            .csFilterDropDownRPMValue
                                                            ?.toList())!
                                                    .toList()
                                                    .cast<dynamic>();
                                                safeSetState(() {});
                                                FFAppState()
                                                        .csFilterDropDownIndex =
                                                    _model
                                                        .csFilterDropDownValue!;
                                                FFAppState()
                                                        .csSelectedStatusesRPM =
                                                    _model
                                                        .csFilterDropDownRPMValue!
                                                        .toList()
                                                        .cast<String>();
                                                safeSetState(() {});
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Select RPM Status',
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
                                            } else if (_model
                                                    .csFilterDropDownValue ==
                                                'ccm_rpm_status_value') {
                                              if ((_model.csFilterDropDownCCMValue !=
                                                          null &&
                                                      (_model.csFilterDropDownCCMValue)!
                                                          .isNotEmpty) ||
                                                  (_model.csFilterDropDownRPMValue !=
                                                          null &&
                                                      (_model.csFilterDropDownRPMValue)!
                                                          .isNotEmpty)) {
                                                FFAppState().filterApplied =
                                                    true;
                                                safeSetState(() {});
                                                _model.csPatientListFiltered = functions
                                                    .filterCSListByCCMAndRPMLocally(
                                                        _model.csPatientList
                                                            .toList(),
                                                        _model
                                                            .csFilterDropDownCCMValue
                                                            ?.toList(),
                                                        _model
                                                            .csFilterDropDownRPMValue
                                                            ?.toList())!
                                                    .toList()
                                                    .cast<dynamic>();
                                                safeSetState(() {});
                                                FFAppState()
                                                        .csFilterDropDownIndex =
                                                    _model
                                                        .csFilterDropDownValue!;
                                                FFAppState()
                                                        .csSelectedStatusesCCM =
                                                    _model
                                                        .csFilterDropDownCCMValue!
                                                        .toList()
                                                        .cast<String>();
                                                FFAppState()
                                                        .csSelectedStatusesRPM =
                                                    _model
                                                        .csFilterDropDownRPMValue!
                                                        .toList()
                                                        .cast<String>();
                                                safeSetState(() {});
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
                                      _model.csPatientList = [];
                                      _model.csPatientListFiltered = [];
                                      _model.dateSearch = null;
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
                                        _model.csFilterDropDownValueController
                                            ?.reset();
                                        _model
                                            .csFilterDropDownCCMValueController
                                            ?.reset();
                                        _model
                                            .csFilterDropDownRPMValueController
                                            ?.reset();
                                      });
                                      safeSetState(() {
                                        _model.searchStringTextController
                                            ?.clear();
                                      });
                                      safeSetState(() {
                                        _model.csFilterDropDownValueController
                                            ?.value = 'full_name';
                                      });
                                      _model.csPatientListAPICallReloadButton =
                                          await GQLgetByFunctionCall.call(
                                        hasuraToken: FFAppState().hasuraToken,
                                        requestBody: functions
                                            .getCareSpecialistPatientList(
                                                FFAppState()
                                                    .viewerClinicIDS
                                                    .toList())
                                            .toString(),
                                      );

                                      _model.csPatientList = functions
                                          .enrichClinicTime(getJsonField(
                                            (_model.csPatientListAPICallReloadButton
                                                    ?.jsonBody ??
                                                ''),
                                            r'''$.data.pep_vw_care_specialist_patient_list''',
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
                              if (_model.csPatientList.isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: Builder(
                                    builder: (context) {
                                      final tableData = ((FFAppState()
                                                          .filterApplied ==
                                                      false) &&
                                                  !(_model.csPatientListFiltered
                                                      .isNotEmpty)
                                              ? _model.csPatientList
                                              : _model.csPatientListFiltered)
                                          .toList();

                                      return FlutterFlowDataTable<dynamic>(
                                        controller:
                                            _model.dataTableGroupListController,
                                        data: tableData,
                                        columnsBuilder: (onSortChanged) => [
                                          DataColumn2(
                                            label: DefaultTextStyle.merge(
                                              softWrap: true,
                                              child: Text(
                                                'Appointment in\nClinic Time',
                                                textAlign: TextAlign.start,
                                                style: FlutterFlowTheme.of(
                                                        context)
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
                                                'Appointment in\nLocal Time',
                                                textAlign: TextAlign.start,
                                                style: FlutterFlowTheme.of(
                                                        context)
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
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: Text(
                                                  'Actions',
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
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .override(
                                                        font:
                                                            GoogleFonts.poppins(
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
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .override(
                                                        font:
                                                            GoogleFonts.poppins(
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
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .override(
                                                        font:
                                                            GoogleFonts.poppins(
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
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .override(
                                                        font:
                                                            GoogleFonts.poppins(
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
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .override(
                                                        font:
                                                            GoogleFonts.poppins(
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
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .override(
                                                        font:
                                                            GoogleFonts.poppins(
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
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .override(
                                                        font:
                                                            GoogleFonts.poppins(
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
                                                            .fromSTEB(10.0, 0.0,
                                                                0.0, 0.0),
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
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
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
                                                        FFAppState().isPaused =
                                                            !(FFAppState()
                                                                    .isPaused ??
                                                                true);
                                                        safeSetState(() {});
                                                        if (_model.instantTimer
                                                            .isActive) {
                                                          _model.instantTimer
                                                              ?.cancel();
                                                        } else {
                                                          _model
                                                              .instantTimerNested
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
                                                                  .PatientList,
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
                                        onPageChanged: (currentRowIndex) async {
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
                              if (!(_model.csPatientListFiltered.isNotEmpty) &&
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
