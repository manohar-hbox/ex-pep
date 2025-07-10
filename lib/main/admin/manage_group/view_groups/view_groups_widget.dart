import 'package:patient_enrollment_program/custom_code/services/twilio_client_manager.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_data_table.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/main/components/create_group_by_dialog/create_group_by_dialog_widget.dart';
import '/main/components/send_email/send_email_widget.dart';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:aligned_dialog/aligned_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'view_groups_model.dart';
export 'view_groups_model.dart';

class ViewGroupsWidget extends StatefulWidget {
  const ViewGroupsWidget({super.key});

  static String routeName = 'ViewGroups';
  static String routePath = 'viewGroups';

  @override
  State<ViewGroupsWidget> createState() => _ViewGroupsWidgetState();
}

class _ViewGroupsWidgetState extends State<ViewGroupsWidget> {
  late ViewGroupsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ViewGroupsModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await actions.checkAndStoreRedirectURL();
      await actions.loadHasuraAndLoginToken();
      if (FFAppState().loginToken != '') {
        _model.groupDetails = [];
        _model.groupDetailsFiltered = [];
        safeSetState(() {});
        safeSetState(() {
          _model.groupFilterDropDownValueController?.reset();
        });
        safeSetState(() {
          _model.searchStringTextController?.clear();
        });

        // Initialization Twilio for Inbound and Outbound Calls
        final twilioClientManager = TwilioClientManager();
        String identity = FFAppState().loginEmail;  // This should come from your user's session

        // Register to receive incoming calls
        final success = await twilioClientManager.registerForIncomingCalls(identity, false);

        if (success) {
          print("Token Generated");
        } else {
          print("Failed to register Token");
        }

        _model.groupDetailsAPICallPageLoad = await GQLgetByFunctionCall.call(
          hasuraToken: FFAppState().hasuraToken,
          requestBody: functions.getGroupDetails().toString(),
        );

        _model.groupDetails = GQLgetByFunctionCall.groupDetails(
          (_model.groupDetailsAPICallPageLoad?.jsonBody ?? ''),
        )!
            .toList()
            .cast<dynamic>();
        safeSetState(() {});
        if (FFAppState().redirectURL != '') {
          await actions.redirectToURL(
            context,
          );
          FFAppState().deleteRedirectURL();
          FFAppState().redirectURL = '';

          safeSetState(() {});
        }
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
                          'Virtual Patient Enrollment(VPE) Admin',
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
                FFButtonWidget(
                  onPressed: () async {
                    var confirmDialogResponse = await showDialog<bool>(
                          context: context,
                          builder: (alertDialogContext) {
                            return AlertDialog(
                              content:
                                  Text('Are you sure you want to sign out?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(alertDialogContext, false),
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
                    width: 120.0,
                    height: 40.0,
                    padding:
                        EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                    iconPadding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                    color: FlutterFlowTheme.of(context).accent3,
                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
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
                          fontStyle:
                              FlutterFlowTheme.of(context).titleSmall.fontStyle,
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: AlignmentDirectional(1.0, -1.0),
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 12.0, 10.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              context.pushNamed(GSListViewWidget.routeName);
                            },
                            onDoubleTap: () async {
                              context.pushNamed(GSListViewWidget.routeName);
                            },
                            child: Container(
                              width: 190.0,
                              height: 42.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).tertiary,
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    10.0, 0.0, 15.0, 0.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Align(
                                      alignment:
                                          AlignmentDirectional(-1.0, 0.0),
                                      child: Icon(
                                        Icons.search,
                                        color: FlutterFlowTheme.of(context)
                                            .buttonText,
                                        size: 24.0,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          10.0, 0.0, 0.0, 0.0),
                                      child: Text(
                                        'Search Patients',
                                        style: FlutterFlowTheme.of(context)
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
                                              color:
                                                  FlutterFlowTheme.of(context)
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
                                      ),
                                    ),
                                  ],
                                ),
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
                                FFAppState().filteredPatients = [];
                                FFAppState().filteredPatientsList = [];
                                FFAppState().filteredPatientsCount = 0;
                                safeSetState(() {});
                                await showAlignedDialog(
                                  barrierColor: Color(0x0D000000),
                                  context: context,
                                  isGlobal: false,
                                  avoidOverflow: false,
                                  targetAnchor: AlignmentDirectional(1.0, 1.0)
                                      .resolve(Directionality.of(context)),
                                  followerAnchor:
                                      AlignmentDirectional(1.0, -1.0)
                                          .resolve(Directionality.of(context)),
                                  builder: (dialogContext) {
                                    return Material(
                                      color: Colors.transparent,
                                      child: GestureDetector(
                                        onTap: () {
                                          FocusScope.of(dialogContext)
                                              .unfocus();
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();
                                        },
                                        child: Container(
                                          height: 185.0,
                                          width: 150.0,
                                          child: CreateGroupByDialogWidget(),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Container(
                                width: 230.0,
                                height: 42.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).tertiary,
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Align(
                                  alignment: AlignmentDirectional(0.0, 0.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Icon(
                                        Icons.group_add,
                                        color: FlutterFlowTheme.of(context)
                                            .buttonText,
                                        size: 24.0,
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            8.0, 0.0, 8.0, 1.0),
                                        child: Text(
                                          'Create Group by',
                                          style: FlutterFlowTheme.of(context)
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
                                                    FlutterFlowTheme.of(context)
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
                                        ),
                                      ),
                                      Icon(
                                        Icons.keyboard_arrow_down,
                                        color: FlutterFlowTheme.of(context)
                                            .buttonText,
                                        size: 24.0,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              FFAppState().filteredPatients = [];
                              FFAppState().filteredPatientsList = [];
                              FFAppState().filteredPatientsCount = 0;
                              safeSetState(() {});

                              context.pushNamed(ArchivedGroupsWidget.routeName);
                            },
                            child: Container(
                              width: 200.0,
                              height: 42.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).tertiary,
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    10.0, 0.0, 10.0, 0.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.archive_outlined,
                                      color: FlutterFlowTheme.of(context)
                                          .buttonText,
                                      size: 24.0,
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          10.0, 0.0, 0.0, 0.0),
                                      child: Text(
                                        'Archived Groups',
                                        style: FlutterFlowTheme.of(context)
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
                                              color:
                                                  FlutterFlowTheme.of(context)
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
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              context.pushNamed(ViewVPEWidget.routeName);
                            },
                            child: Container(
                              width: 180.0,
                              height: 42.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).tertiary,
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    10.0, 0.0, 10.0, 0.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.manage_accounts_rounded,
                                      color: FlutterFlowTheme.of(context)
                                          .buttonText,
                                      size: 25.0,
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          10.0, 0.0, 0.0, 0.0),
                                      child: Text(
                                        'Manage VPE',
                                        style: FlutterFlowTheme.of(context)
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
                                              color:
                                                  FlutterFlowTheme.of(context)
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
                Padding(
                  padding:
                      EdgeInsetsDirectional.fromSTEB(12.0, 12.0, 12.0, 0.0),
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
                            controller:
                                _model.groupFilterDropDownValueController ??=
                                    FormFieldController<String>(
                              _model.groupFilterDropDownValue ??= 'group_name',
                            ),
                            options: List<String>.from([
                              'group_name',
                              'group_type',
                              'es_name',
                              'clinic_name'
                            ]),
                            optionLabels: [
                              'Group Name',
                              'Group Type',
                              'Assigned VPE',
                              'Clinic Name'
                            ],
                            onChanged: (val) async {
                              safeSetState(
                                  () => _model.groupFilterDropDownValue = val);
                              safeSetState(() {
                                _model.searchStringTextController?.clear();
                              });
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
                            hintText: 'Filter By',
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
                            borderWidth: 0.0,
                            borderRadius: 8.0,
                            margin: EdgeInsetsDirectional.fromSTEB(
                                12.0, 0.0, 12.0, 0.0),
                            hidesUnderline: true,
                            isOverButton: false,
                            isSearchable: false,
                            isMultiSelect: false,
                          ),
                          Container(
                            width: 360.0,
                            height: 56.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(0.0),
                              shape: BoxShape.rectangle,
                            ),
                            child: Container(
                              width: 360.0,
                              child: TextFormField(
                                controller: _model.searchStringTextController,
                                focusNode: _model.searchStringFocusNode,
                                onFieldSubmitted: (_) async {
                                  if ((_model.groupFilterDropDownValue !=
                                              null &&
                                          _model.groupFilterDropDownValue !=
                                              '') &&
                                      ((String? searchString) {
                                        return searchString == null
                                            ? false
                                            : (searchString.length >= 3
                                                ? true
                                                : false);
                                      }(_model
                                          .searchStringTextController.text))) {
                                    _model.groupDetailsFiltered = functions
                                        .filterGroupLocally(
                                            _model.groupDetails.toList(),
                                            _model.groupFilterDropDownValue,
                                            _model.searchStringTextController
                                                .text)!
                                        .toList()
                                        .cast<dynamic>();
                                    safeSetState(() {});
                                    _model.groupDetailsFiltered = functions
                                        .filterGroupLocally(
                                            _model.groupDetails.toList(),
                                            _model.groupFilterDropDownValue,
                                            _model.searchStringTextController
                                                .text)!
                                        .toList()
                                        .cast<dynamic>();
                                    safeSetState(() {});
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Enter a minimum of three characters for search operation',
                                          style: TextStyle(
                                            color: FlutterFlowTheme.of(context)
                                                .primaryText,
                                          ),
                                        ),
                                        duration: Duration(milliseconds: 4000),
                                        backgroundColor:
                                            FlutterFlowTheme.of(context).error,
                                      ),
                                    );
                                  }
                                },
                                autofocus: false,
                                obscureText: false,
                                decoration: InputDecoration(
                                  isDense: false,
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
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontStyle,
                                      ),
                                  hintText: 'Search',
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
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontStyle,
                                      ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context)
                                          .borderColor,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context)
                                          .borderColor,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).error,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).error,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  filled: true,
                                  fillColor: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                ),
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
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                cursorColor:
                                    FlutterFlowTheme.of(context).primaryText,
                                validator: _model
                                    .searchStringTextControllerValidator
                                    .asValidator(context),
                              ),
                            ),
                          ),
                          FFButtonWidget(
                            onPressed: (_model.groupFilterDropDownValue ==
                                        null ||
                                    _model.groupFilterDropDownValue == '')
                                ? null
                                : () async {
                                    if ((_model.groupFilterDropDownValue !=
                                                null &&
                                            _model.groupFilterDropDownValue !=
                                                '') &&
                                        ((String? searchString) {
                                          return searchString == null
                                              ? false
                                              : (searchString.length >= 3
                                                  ? true
                                                  : false);
                                        }(_model.searchStringTextController
                                            .text))) {
                                      FFAppState().filterApplied = true;
                                      safeSetState(() {});
                                      _model.groupDetailsFiltered = functions
                                          .filterGroupLocally(
                                              _model.groupDetails.toList(),
                                              _model.groupFilterDropDownValue,
                                              _model.searchStringTextController
                                                  .text)!
                                          .toList()
                                          .cast<dynamic>();
                                      safeSetState(() {});
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Enter a minimum of three characters for search operation',
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
                                  },
                            text: 'Search',
                            options: FFButtonOptions(
                              height: 46.0,
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  16.0, 0.0, 16.0, 0.0),
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
                              elevation: 0.0,
                              borderRadius: BorderRadius.circular(8.0),
                              disabledColor:
                                  FlutterFlowTheme.of(context).alternate,
                            ),
                          ),
                        ].divide(SizedBox(width: 20.0)),
                      ),
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
                          _model.groupDetails = [];
                          _model.groupDetailsFiltered = [];
                          safeSetState(() {});
                          FFAppState().filterApplied = false;
                          safeSetState(() {});
                          safeSetState(() {
                            _model.groupFilterDropDownValueController?.reset();
                          });
                          _model.groupDetailsFiltered = functions
                              .filterGroupLocally(
                                  _model.groupDetails.toList(),
                                  _model.groupFilterDropDownValue,
                                  _model.searchStringTextController.text)!
                              .toList()
                              .cast<dynamic>();
                          safeSetState(() {});
                          safeSetState(() {
                            _model.searchStringTextController?.clear();
                          });
                          _model.groupDetailsAPICallReloadButton =
                              await GQLgetByFunctionCall.call(
                            hasuraToken: FFAppState().hasuraToken,
                            requestBody: functions.getGroupDetails().toString(),
                          );

                          _model.groupDetails =
                              GQLgetByFunctionCall.groupDetails(
                            (_model.groupDetailsAPICallReloadButton?.jsonBody ??
                                ''),
                          )!
                                  .toList()
                                  .cast<dynamic>();
                          safeSetState(() {});

                          safeSetState(() {});
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      if (_model.groupDetails.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Builder(
                            builder: (context) {
                              final tableData =
                                  ((FFAppState().filterApplied == false) &&
                                              !(_model.groupDetailsFiltered
                                                  .isNotEmpty)
                                          ? _model.groupDetails
                                          : _model.groupDetailsFiltered)
                                      .toList();

                              return FlutterFlowDataTable<dynamic>(
                                controller: _model.dataTableGroupListController,
                                data: tableData,
                                columnsBuilder: (onSortChanged) => [
                                  DataColumn2(
                                    label: DefaultTextStyle.merge(
                                      softWrap: true,
                                      child: Align(
                                        alignment:
                                            AlignmentDirectional(-1.0, 0.0),
                                        child: Text(
                                          'Group ID',
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
                                        MediaQuery.sizeOf(context).width * 0.07,
                                  ),
                                  DataColumn2(
                                    label: DefaultTextStyle.merge(
                                      softWrap: true,
                                      child: Text(
                                        'Group Name',
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
                                        MediaQuery.sizeOf(context).width *
                                            0.175,
                                  ),
                                  DataColumn2(
                                    label: DefaultTextStyle.merge(
                                      softWrap: true,
                                      child: Text(
                                        'Type',
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
                                        MediaQuery.sizeOf(context).width * 0.1,
                                  ),
                                  DataColumn2(
                                    label: DefaultTextStyle.merge(
                                      softWrap: true,
                                      child: Text(
                                        'Assigned VPE',
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
                                        MediaQuery.sizeOf(context).width * 0.25,
                                  ),
                                  DataColumn2(
                                    label: DefaultTextStyle.merge(
                                      softWrap: true,
                                      child: Align(
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0),
                                        child: Text(
                                          'Actions',
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
                                        MediaQuery.sizeOf(context).width * 0.21,
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
                                            .alternateRow,
                                  ),
                                  cells: [
                                    Align(
                                      alignment:
                                          AlignmentDirectional(-1.0, 0.0),
                                      child: Text(
                                        getJsonField(
                                          tableDataItem,
                                          r'''$.group_id''',
                                        ).toString(),
                                        textAlign: TextAlign.center,
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
                                    Text(
                                      getJsonField(
                                        tableDataItem,
                                        r'''$.group_name''',
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
                                      getJsonField(
                                        tableDataItem,
                                        r'''$.group_type''',
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
                                          r'''$.es_name''',
                                        )?.toString(),
                                        'Unassigned',
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
                                      getJsonField(
                                        tableDataItem,
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
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Align(
                                          alignment:
                                              AlignmentDirectional(-1.0, 0.0),
                                          child: Builder(
                                            builder: (context) =>
                                                FlutterFlowIconButton(
                                              borderColor:
                                                  FlutterFlowTheme.of(context)
                                                      .tertiary,
                                              borderRadius: 20.0,
                                              borderWidth: 1.0,
                                              buttonSize: 38.0,
                                              fillColor:
                                                  FlutterFlowTheme.of(context)
                                                      .secondary,
                                              icon: Icon(
                                                Icons.email_outlined,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .tertiary,
                                                size: 22.0,
                                              ),
                                              onPressed: () async {
                                                FFAppState()
                                                    .clearListOfESCache();
                                                FFAppState()
                                                    .clearDuplicateGroupDetailsCache();
                                                _model.getPatientList =
                                                    await GQLgetByFunctionCall
                                                        .call(
                                                  hasuraToken:
                                                      FFAppState().hasuraToken,
                                                  requestBody: functions
                                                      .getGroupPatientList(
                                                          getJsonField(
                                                        tableDataItem,
                                                        r'''$.group_id''',
                                                      ))
                                                      .toString(),
                                                );

                                                FFAppState()
                                                        .filteredPatientsList =
                                                    functions
                                                        .getPatientList(
                                                            getJsonField(
                                                          (_model.getPatientList
                                                                  ?.jsonBody ??
                                                              ''),
                                                          r'''$.data.pep_vw_group_patient_list[:].patient_list''',
                                                          true,
                                                        )!)
                                                        .toList()
                                                        .cast<int>();
                                                safeSetState(() {});
                                                await showDialog(
                                                  barrierColor:
                                                      Color(0x3F000000),
                                                  context: context,
                                                  builder: (dialogContext) {
                                                    return Dialog(
                                                      elevation: 0,
                                                      insetPadding:
                                                          EdgeInsets.zero,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      alignment:
                                                          AlignmentDirectional(
                                                                  0.0, 0.0)
                                                              .resolve(
                                                                  Directionality.of(
                                                                      context)),
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          FocusScope.of(
                                                                  dialogContext)
                                                              .unfocus();
                                                          FocusManager.instance
                                                              .primaryFocus
                                                              ?.unfocus();
                                                        },
                                                        child: Container(
                                                          height: 350.0,
                                                          width: 600.0,
                                                          child:
                                                              SendEmailWidget(
                                                            groupId:
                                                                getJsonField(
                                                              tableDataItem,
                                                              r'''$.group_id''',
                                                            ).toString(),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );

                                                safeSetState(() {});
                                              },
                                            ),
                                          ),
                                        ),
                                        Align(
                                          alignment:
                                              AlignmentDirectional(-1.0, 0.0),
                                          child: FlutterFlowIconButton(
                                            borderColor:
                                                FlutterFlowTheme.of(context)
                                                    .tertiary,
                                            borderRadius: 20.0,
                                            borderWidth: 1.0,
                                            buttonSize: 38.0,
                                            fillColor:
                                                FlutterFlowTheme.of(context)
                                                    .secondary,
                                            icon: Icon(
                                              Icons.file_copy_rounded,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .tertiary,
                                              size: 22.0,
                                            ),
                                            onPressed: () async {
                                              FFAppState().clearListOfESCache();
                                              FFAppState()
                                                  .clearDuplicateGroupDetailsCache();
                                              _model.getPatientListDuplicateIcon =
                                                  await GQLgetByFunctionCall
                                                      .call(
                                                hasuraToken:
                                                    FFAppState().hasuraToken,
                                                requestBody: functions
                                                    .getGroupPatientList(
                                                        getJsonField(
                                                      tableDataItem,
                                                      r'''$.group_id''',
                                                    ))
                                                    .toString(),
                                              );

                                              FFAppState()
                                                      .filteredPatientsList =
                                                  functions
                                                      .getPatientList(
                                                          getJsonField(
                                                        (_model.getPatientListDuplicateIcon
                                                                ?.jsonBody ??
                                                            ''),
                                                        r'''$.data.pep_vw_group_patient_list[:].patient_list''',
                                                        true,
                                                      )!)
                                                      .toList()
                                                      .cast<int>();
                                              safeSetState(() {});
                                              FFAppState()
                                                      .filteredPatientsCount =
                                                  functions
                                                      .generateFilteredPatientsListCount(
                                                          FFAppState()
                                                              .filteredPatientsList
                                                              .toList());
                                              safeSetState(() {});

                                              context.pushNamed(
                                                DuplicateGroupWidget.routeName,
                                                queryParameters: {
                                                  'groupID': serializeParam(
                                                    getJsonField(
                                                      tableDataItem,
                                                      r'''$.group_id''',
                                                    ),
                                                    ParamType.int,
                                                  ),
                                                  'clinicID': serializeParam(
                                                    getJsonField(
                                                      tableDataItem,
                                                      r'''$.clinic_id''',
                                                    ),
                                                    ParamType.int,
                                                  ),
                                                }.withoutNulls,
                                              );

                                              safeSetState(() {});
                                            },
                                          ),
                                        ),
                                        Align(
                                          alignment:
                                              AlignmentDirectional(1.0, 0.0),
                                          child: FlutterFlowIconButton(
                                            borderColor:
                                                FlutterFlowTheme.of(context)
                                                    .tertiary,
                                            borderRadius: 20.0,
                                            borderWidth: 1.0,
                                            buttonSize: 38.0,
                                            fillColor:
                                                FlutterFlowTheme.of(context)
                                                    .secondary,
                                            icon: Icon(
                                              Icons.edit,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .tertiary,
                                              size: 22.0,
                                            ),
                                            onPressed: () async {
                                              FFAppState().clearListOfESCache();

                                              context.goNamed(
                                                EditGroupWidget.routeName,
                                                queryParameters: {
                                                  'groupId': serializeParam(
                                                    getJsonField(
                                                      tableDataItem,
                                                      r'''$.group_id''',
                                                    ),
                                                    ParamType.int,
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
                                            },
                                          ),
                                        ),
                                        Align(
                                          alignment:
                                              AlignmentDirectional(1.0, 0.0),
                                          child: FlutterFlowIconButton(
                                            borderColor:
                                                FlutterFlowTheme.of(context)
                                                    .tertiary,
                                            borderRadius: 20.0,
                                            borderWidth: 1.0,
                                            buttonSize: 38.0,
                                            fillColor:
                                                FlutterFlowTheme.of(context)
                                                    .secondary,
                                            icon: Icon(
                                              Icons.archive,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .tertiary,
                                              size: 20.0,
                                            ),
                                            onPressed: () async {
                                              var confirmDialogResponse =
                                                  await showDialog<bool>(
                                                        context: context,
                                                        builder:
                                                            (alertDialogContext) {
                                                          return AlertDialog(
                                                            content: Text(
                                                                'Are you sure you want to archive group?'),
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
                                                _model.archiveGroupResult =
                                                    await PEPAPIsGroup
                                                        .archiveGroupCall
                                                        .call(
                                                  archive: true,
                                                  authToken:
                                                      FFAppState().loginToken,
                                                  groupId: getJsonField(
                                                    tableDataItem,
                                                    r'''$.group_id''',
                                                  ),
                                                  enrollmentAdminId:
                                                      FFAppState()
                                                          .loginProfileID,
                                                );

                                                if ((_model.archiveGroupResult
                                                        ?.succeeded ??
                                                    true)) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Group Archived Succesfully.',
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
                                                  _model.groupDetails = [];
                                                  _model.groupDetailsFiltered =
                                                      [];
                                                  safeSetState(() {});
                                                  _model.groupDetailsAPICallArchiveButton =
                                                      await GQLgetByFunctionCall
                                                          .call(
                                                    hasuraToken: FFAppState()
                                                        .hasuraToken,
                                                    requestBody: functions
                                                        .getGroupDetails()
                                                        .toString(),
                                                  );

                                                  if ((_model.groupFilterDropDownValue !=
                                                              null &&
                                                          _model.groupFilterDropDownValue !=
                                                              '') &&
                                                      ((String? searchString) {
                                                        return searchString ==
                                                                null
                                                            ? false
                                                            : (searchString
                                                                        .length >=
                                                                    3
                                                                ? true
                                                                : false);
                                                      }(_model
                                                          .searchStringTextController
                                                          .text))) {
                                                    _model.groupDetailsFiltered =
                                                        functions
                                                            .filterGroupLocally(
                                                                GQLgetByFunctionCall
                                                                    .groupDetails(
                                                                  (_model.groupDetailsAPICallArchiveButton
                                                                          ?.jsonBody ??
                                                                      ''),
                                                                )?.toList(),
                                                                _model
                                                                    .groupFilterDropDownValue,
                                                                _model
                                                                    .searchStringTextController
                                                                    .text)!
                                                            .toList()
                                                            .cast<dynamic>();
                                                    safeSetState(() {});
                                                  }
                                                  _model.groupDetails =
                                                      GQLgetByFunctionCall
                                                              .groupDetails(
                                                    (_model.groupDetailsAPICallArchiveButton
                                                            ?.jsonBody ??
                                                        ''),
                                                  )!
                                                          .toList()
                                                          .cast<dynamic>();
                                                  safeSetState(() {});
                                                } else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Group Archived Failed. Please Try Again!',
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
                                        Align(
                                          alignment:
                                              AlignmentDirectional(1.0, 0.0),
                                          child: FlutterFlowIconButton(
                                            borderColor:
                                                FlutterFlowTheme.of(context)
                                                    .error,
                                            borderRadius: 20.0,
                                            borderWidth: 1.0,
                                            buttonSize: 38.0,
                                            fillColor:
                                                FlutterFlowTheme.of(context)
                                                    .secondary,
                                            icon: Icon(
                                              Icons.delete,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .error,
                                              size: 22.0,
                                            ),
                                            onPressed: () async {
                                              var confirmDialogResponse =
                                                  await showDialog<bool>(
                                                        context: context,
                                                        builder:
                                                            (alertDialogContext) {
                                                          return AlertDialog(
                                                            content: Text(
                                                                'Are you sure you want to delete group?'),
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
                                                _model.deleteGroupResult =
                                                    await PEPAPIsGroup
                                                        .deleteGroupCall
                                                        .call(
                                                  authToken:
                                                      FFAppState().loginToken,
                                                  groupId: getJsonField(
                                                    tableDataItem,
                                                    r'''$.group_id''',
                                                  ),
                                                  enrollmentAdminId:
                                                      FFAppState()
                                                          .loginProfileID,
                                                );

                                                if ((_model.deleteGroupResult
                                                        ?.succeeded ??
                                                    true)) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Group Deleted Succesfully.',
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
                                                  _model.groupDetails = [];
                                                  _model.groupDetailsFiltered =
                                                      [];
                                                  safeSetState(() {});
                                                  _model.groupDetailsAPICallDeleteButton =
                                                      await GQLgetByFunctionCall
                                                          .call(
                                                    hasuraToken: FFAppState()
                                                        .hasuraToken,
                                                    requestBody: functions
                                                        .getGroupDetails()
                                                        .toString(),
                                                  );

                                                  if ((_model.groupFilterDropDownValue !=
                                                              null &&
                                                          _model.groupFilterDropDownValue !=
                                                              '') &&
                                                      ((String? searchString) {
                                                        return searchString ==
                                                                null
                                                            ? false
                                                            : (searchString
                                                                        .length >=
                                                                    3
                                                                ? true
                                                                : false);
                                                      }(_model
                                                          .searchStringTextController
                                                          .text))) {
                                                    _model.groupDetailsFiltered =
                                                        functions
                                                            .filterGroupLocally(
                                                                GQLgetByFunctionCall
                                                                    .groupDetails(
                                                                  (_model.groupDetailsAPICallDeleteButton
                                                                          ?.jsonBody ??
                                                                      ''),
                                                                )?.toList(),
                                                                _model
                                                                    .groupFilterDropDownValue,
                                                                _model
                                                                    .searchStringTextController
                                                                    .text)!
                                                            .toList()
                                                            .cast<dynamic>();
                                                    safeSetState(() {});
                                                  }
                                                  _model.groupDetails =
                                                      GQLgetByFunctionCall
                                                              .groupDetails(
                                                    (_model.groupDetailsAPICallDeleteButton
                                                            ?.jsonBody ??
                                                        ''),
                                                  )!
                                                          .toList()
                                                          .cast<dynamic>();
                                                  safeSetState(() {});
                                                } else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Group Deleted Failed.Please Try Again!',
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
                                      ].divide(SizedBox(width: 12.0)),
                                    ),
                                  ].map((c) => DataCell(c)).toList(),
                                ),
                                paginated: true,
                                selectable: false,
                                hidePaginator: false,
                                showFirstLastButtons: false,
                                width: MediaQuery.sizeOf(context).width * 1.0,
                                height: double.infinity,
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
                      if (!(_model.groupDetailsFiltered.isNotEmpty) &&
                          (FFAppState().filterApplied == true))
                        Align(
                          alignment: AlignmentDirectional(0.0, 0.0),
                          child: Text(
                            'No Group Found!',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
