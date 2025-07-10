import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'login_model.dart';
export 'login_model.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  static String routeName = 'Login';
  static String routePath = 'Login';

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  late LoginModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LoginModel());

    _model.emailAddressTextController ??= TextEditingController();
    _model.emailAddressFocusNode ??= FocusNode();

    _model.passwordTextController ??= TextEditingController();
    _model.passwordFocusNode ??= FocusNode();

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
        body: SafeArea(
          top: true,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              if (responsiveVisibility(
                context: context,
                phone: false,
                tablet: false,
              ))
                Expanded(
                  flex: 6,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Container(
                      width: 100.0,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondary,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Align(
                              alignment: AlignmentDirectional(0.0, 0.0),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    20.0, 0.0, 0.0, 0.0),
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Align(
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0),
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 0.0, 0.0, 8.0),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: Image.asset(
                                              'assets/images/hbox_logo.png',
                                              width: 200.0,
                                              fit: BoxFit.fitWidth,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0),
                                        child: Text(
                                          'Patient Enrollment Platform',
                                          style: FlutterFlowTheme.of(context)
                                              .headlineMedium
                                              .override(
                                                font: GoogleFonts.poppins(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .headlineMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .headlineMedium
                                                          .fontStyle,
                                                ),
                                                letterSpacing: 0.0,
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .headlineMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .headlineMedium
                                                        .fontStyle,
                                              ),
                                        ),
                                      ),
                                      Align(
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0),
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 0.0, 0.0, 90.0),
                                          child: Text(
                                            'V1.2.0',
                                            style: FlutterFlowTheme.of(context)
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
                                                  color: Color(0xFFA9A9A9),
                                                  fontSize: 14.0,
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
                                        ),
                                      ),
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: Image.asset(
                                          'assets/images/login_image.png',
                                          width: 800.0,
                                          height: 390.0,
                                          fit: BoxFit.fitHeight,
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
                  ),
                ),
              Expanded(
                flex: 8,
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(30.0, 0.0, 0.0, 0.0),
                  child: Container(
                    width: 100.0,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondary,
                    ),
                    alignment: AlignmentDirectional(0.0, 0.0),
                    child: Form(
                      key: _model.formKey,
                      autovalidateMode: AutovalidateMode.disabled,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Align(
                              alignment: AlignmentDirectional(0.0, 0.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Align(
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    child: Text(
                                      'Welcome Back',
                                      style: FlutterFlowTheme.of(context)
                                          .displaySmall
                                          .override(
                                            font: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w500,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .displaySmall
                                                      .fontStyle,
                                            ),
                                            color: FlutterFlowTheme.of(context)
                                                .primaryText,
                                            fontSize: 32.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w500,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .displaySmall
                                                    .fontStyle,
                                          ),
                                    ),
                                  ),
                                  Align(
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 12.0, 0.0, 24.0),
                                      child: Text(
                                        'Please enter your details',
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
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
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
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 30.0, 0.0, 16.0),
                                      child: Container(
                                        width: 400.0,
                                        child: TextFormField(
                                          controller:
                                              _model.emailAddressTextController,
                                          focusNode:
                                              _model.emailAddressFocusNode,
                                          onChanged: (_) =>
                                              EasyDebounce.debounce(
                                            '_model.emailAddressTextController',
                                            Duration(milliseconds: 2000),
                                            () => safeSetState(() {}),
                                          ),
                                          autofocus: true,
                                          autofillHints: [
                                            AutofillHints.username
                                          ],
                                          textInputAction: TextInputAction.next,
                                          obscureText: false,
                                          decoration: InputDecoration(
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
                                                      fontSize: 16.0,
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
                                            hintText: 'Email Address',
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                                width: 1.0,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
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
                                                    .secondary,
                                            prefixIcon: Icon(
                                              Icons.email,
                                            ),
                                            suffixIcon: _model
                                                    .emailAddressTextController!
                                                    .text
                                                    .isNotEmpty
                                                ? InkWell(
                                                    onTap: () async {
                                                      _model
                                                          .emailAddressTextController
                                                          ?.clear();
                                                      safeSetState(() {});
                                                    },
                                                    child: Icon(
                                                      Icons.clear,
                                                      color: Color(0xFF757575),
                                                      size: 22.0,
                                                    ),
                                                  )
                                                : null,
                                          ),
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.normal,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.normal,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          cursorColor:
                                              FlutterFlowTheme.of(context)
                                                  .secondaryText,
                                          validator: _model
                                              .emailAddressTextControllerValidator
                                              .asValidator(context),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 18.0, 0.0, 16.0),
                                      child: Container(
                                        width: 400.0,
                                        child: TextFormField(
                                          controller:
                                              _model.passwordTextController,
                                          focusNode: _model.passwordFocusNode,
                                          onFieldSubmitted: (_) async {
                                            _model.loginResponseEnterKey =
                                                await LoginAPICall.call(
                                              email: _model
                                                  .emailAddressTextController
                                                  .text,
                                              password: _model
                                                  .passwordTextController.text,
                                            );

                                            FFAppState().loginEmail = _model
                                                .emailAddressTextController
                                                .text;
                                            safeSetState(() {});

                                            FFAppState().update(() {});
                                            if ((_model.loginResponseEnterKey
                                                    ?.succeeded ??
                                                true)) {
                                              FFAppState().loginToken =
                                                  LoginAPICall.getToken(
                                                (_model.loginResponseEnterKey
                                                        ?.jsonBody ??
                                                    ''),
                                              )!;
                                              safeSetState(() {});
                                              _model.getProfileResponseEnterKey =
                                                  await GetProfileCall.call(
                                                email: FFAppState().loginEmail,
                                                authToken:
                                                    FFAppState().loginToken,
                                              );

                                              FFAppState().username =
                                                  GetProfileCall.username(
                                                (_model.getProfileResponseEnterKey
                                                        ?.jsonBody ??
                                                    ''),
                                              )!;
                                              FFAppState().usertype =
                                                  GetProfileCall.usertype(
                                                (_model.getProfileResponseEnterKey
                                                        ?.jsonBody ??
                                                    ''),
                                              )!;
                                              FFAppState().loginProfileID =
                                                  GetProfileCall.profileID(
                                                (_model.getProfileResponseEnterKey
                                                        ?.jsonBody ??
                                                    ''),
                                              )!
                                                      .toString();
                                              safeSetState(() {});
                                              _model.getHasuraEnterKey =
                                                  await GetHasuraTokenCall.call(
                                                profileID:
                                                    FFAppState().loginProfileID,
                                                authToken:
                                                    FFAppState().loginToken,
                                              );

                                              FFAppState().hasuraToken =
                                                  GetHasuraTokenCall
                                                      .hasuraToken(
                                                (_model.getHasuraEnterKey
                                                        ?.jsonBody ??
                                                    ''),
                                              )!;
                                              safeSetState(() {});
                                              await actions
                                                  .storeHasuraAndLoginToken(
                                                FFAppState().loginToken,
                                                GetHasuraTokenCall.hasuraToken(
                                                  (_model.getHasura?.jsonBody ??
                                                      ''),
                                                )!,
                                              );
                                              _model.usernamesEnterKey =
                                                  await GQLgetByFunctionCall
                                                      .call(
                                                hasuraToken:
                                                    FFAppState().hasuraToken,
                                                requestBody:
                                                    '{\"query\":\"query MyQuery { api_hboxuser(where: {type: {_in: [EA, ES, CA, CS, PA, PE]}}) { id first_name last_name type } }\"}',
                                              );

                                              FFAppState().usernames =
                                                  GQLgetByFunctionCall
                                                          .usernames(
                                                (_model.usernamesEnterKey
                                                        ?.jsonBody ??
                                                    ''),
                                              )!
                                                      .toList()
                                                      .cast<dynamic>();
                                              safeSetState(() {});
                                              if (FFAppState().usertype ==
                                                  FFAppConstants.UserTypeGA) {
                                                context.goNamed(
                                                  ViewGroupsWidget.routeName,
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
                                              } else if (FFAppState()
                                                      .usertype ==
                                                  FFAppConstants.UserTypeEA) {
                                                context.goNamed(
                                                  ViewGroupsWidget.routeName,
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
                                              } else if (FFAppState()
                                                      .usertype ==
                                                  FFAppConstants.UserTypeES) {
                                                _model.currentPatientEnterKey =
                                                    await GQLgetByFunctionCall
                                                        .call(
                                                  hasuraToken:
                                                      FFAppState().hasuraToken,
                                                  requestBody: functions
                                                      .getNextPatient(int.parse(
                                                          FFAppState()
                                                              .loginProfileID))
                                                      .toString(),
                                                );

                                                await PEPAPIsGroup
                                                    .lockPatientByGroupCall
                                                    .call(
                                                  loginID: int.parse(
                                                      FFAppState()
                                                          .loginProfileID),
                                                  authToken:
                                                      FFAppState().loginToken,
                                                  groupId: valueOrDefault<int>(
                                                    GQLgetByFunctionCall
                                                        .currentPatientGroupID(
                                                      (_model.currentPatient
                                                              ?.jsonBody ??
                                                          ''),
                                                    ),
                                                    0,
                                                  ),
                                                );

                                                if (GQLgetByFunctionCall
                                                        .currentPatient(
                                                      (_model.currentPatientEnterKey
                                                              ?.jsonBody ??
                                                          ''),
                                                    ) !=
                                                    null) {
                                                  FFAppState().currentPatient =
                                                      GQLgetByFunctionCall
                                                          .currentPatient(
                                                    (_model.currentPatientEnterKey
                                                            ?.jsonBody ??
                                                        ''),
                                                  )!;
                                                  FFAppState()
                                                          .currentPatientGroupID =
                                                      GQLgetByFunctionCall
                                                          .currentPatientGroupID(
                                                    (_model.currentPatientEnterKey
                                                            ?.jsonBody ??
                                                        ''),
                                                  )!;
                                                  safeSetState(() {});
                                                  _model.createTimeEnterESLog =
                                                      await PEPAPIsGroup
                                                          .createTimerLogCall
                                                          .call(
                                                    userId: FFAppState()
                                                        .loginProfileID,
                                                    authToken:
                                                        FFAppState().loginToken,
                                                  );

                                                  if ((_model
                                                          .createTimeEnterESLog
                                                          ?.succeeded ??
                                                      true)) {
                                                    FFAppState().timerlogId =
                                                        PEPAPIsGroup
                                                            .createTimerLogCall
                                                            .timelogId(
                                                              (_model.createTimeEnterESLog
                                                                      ?.jsonBody ??
                                                                  ''),
                                                            )!
                                                            .toString();
                                                    safeSetState(() {});

                                                    context.goNamed(
                                                        VPEDashboardWidget
                                                            .routeName);
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          'Creating Timelog Failed',
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .titleMedium
                                                              .override(
                                                                font: GoogleFonts
                                                                    .poppins(
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleMedium
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleMedium
                                                                      .fontStyle,
                                                                ),
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryText,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleMedium
                                                                    .fontWeight,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleMedium
                                                                    .fontStyle,
                                                              ),
                                                        ),
                                                        duration: Duration(
                                                            milliseconds: 750),
                                                        backgroundColor:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                      ),
                                                    );
                                                  }
                                                } else {
                                                  FFAppState()
                                                          .noPatientsAvailable =
                                                      true;
                                                  safeSetState(() {});
                                                  _model.createTimeEnterESEmptyLog =
                                                      await PEPAPIsGroup
                                                          .createTimerLogCall
                                                          .call(
                                                    userId: FFAppState()
                                                        .loginProfileID,
                                                    authToken:
                                                        FFAppState().loginToken,
                                                  );

                                                  if ((_model
                                                          .createTimeEnterESEmptyLog
                                                          ?.succeeded ??
                                                      true)) {
                                                    FFAppState().timerlogId =
                                                        PEPAPIsGroup
                                                            .createTimerLogCall
                                                            .timelogId(
                                                              (_model.createTimeEnterESEmptyLog
                                                                      ?.jsonBody ??
                                                                  ''),
                                                            )!
                                                            .toString();
                                                    safeSetState(() {});

                                                    context.goNamed(
                                                        VPEDashboardWidget
                                                            .routeName);
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          'Creating Timelog Failed',
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .titleMedium
                                                              .override(
                                                                font: GoogleFonts
                                                                    .poppins(
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleMedium
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleMedium
                                                                      .fontStyle,
                                                                ),
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryText,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleMedium
                                                                    .fontWeight,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleMedium
                                                                    .fontStyle,
                                                              ),
                                                        ),
                                                        duration: Duration(
                                                            milliseconds: 750),
                                                        backgroundColor:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                      ),
                                                    );
                                                  }
                                                }
                                              } else if (FFAppState()
                                                      .usertype ==
                                                  FFAppConstants.UserTypeCA) {
                                                context.goNamed(
                                                  ViewCSWidget.routeName,
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

                                                await Future.delayed(
                                                    const Duration(
                                                        milliseconds: 1000));
                                                await actions
                                                    .notificationPermission();
                                              } else if (FFAppState()
                                                      .usertype ==
                                                  FFAppConstants.UserTypeCS) {
                                                _model.getCSClinicsEnterKey =
                                                    await GQLgetByFunctionCall
                                                        .call(
                                                  hasuraToken:
                                                      FFAppState().hasuraToken,
                                                  requestBody: functions
                                                      .getCareSpecialistClinics(
                                                          int.parse(FFAppState()
                                                              .loginProfileID))
                                                      .toString(),
                                                );

                                                FFAppState()
                                                    .deleteViewerClinicIDS();
                                                FFAppState().viewerClinicIDS =
                                                    [];

                                                safeSetState(() {});
                                                FFAppState().viewerClinicIDS =
                                                    functions
                                                        .getClinicIDList(
                                                            getJsonField(
                                                          (_model.getCSClinicsEnterKey
                                                                  ?.jsonBody ??
                                                              ''),
                                                          r'''$.data.pep_care_specialist_active_assignments[:].clinic_ids''',
                                                          true,
                                                        ))
                                                        .toList()
                                                        .cast<int>();
                                                safeSetState(() {});
                                                _model.createTimeEnterCSLog =
                                                    await PEPAPIsGroup
                                                        .createTimerLogCall
                                                        .call(
                                                  userId: FFAppState()
                                                      .loginProfileID,
                                                  authToken:
                                                      FFAppState().loginToken,
                                                );

                                                if ((_model.createTimeEnterCSLog
                                                        ?.succeeded ??
                                                    true)) {
                                                  FFAppState().timerlogId =
                                                      PEPAPIsGroup
                                                          .createTimerLogCall
                                                          .timelogId(
                                                            (_model.createTimeEnterCSLog
                                                                    ?.jsonBody ??
                                                                ''),
                                                          )!
                                                          .toString();
                                                  safeSetState(() {});

                                                  context.goNamed(
                                                    CSPatientListWidget
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

                                                  await Future.delayed(
                                                      const Duration(
                                                          milliseconds: 1000));
                                                  await actions
                                                      .notificationPermission();
                                                } else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Creating Timelog Failed',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleMedium
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .poppins(
                                                                    fontWeight: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleMedium
                                                                        .fontWeight,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleMedium
                                                                        .fontStyle,
                                                                  ),
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryText,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleMedium
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleMedium
                                                                      .fontStyle,
                                                                ),
                                                      ),
                                                      duration: Duration(
                                                          milliseconds: 750),
                                                      backgroundColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primary,
                                                    ),
                                                  );
                                                }
                                              } else if (FFAppState()
                                                      .usertype ==
                                                  FFAppConstants.UserTypePA) {
                                                context.goNamed(
                                                  ViewPESWidget.routeName,
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
                                              } else if (FFAppState()
                                                      .usertype ==
                                                  FFAppConstants.UserTypePE) {
                                                _model.getPESClinicsEnterKey =
                                                    await GQLgetByFunctionCall
                                                        .call(
                                                  hasuraToken:
                                                      FFAppState().hasuraToken,
                                                  requestBody: functions
                                                      .getPatientEnrollerClinics(
                                                          int.parse(FFAppState()
                                                              .loginProfileID))
                                                      .toString(),
                                                );

                                                FFAppState()
                                                    .deleteViewerClinicIDS();
                                                FFAppState().viewerClinicIDS =
                                                    [];

                                                safeSetState(() {});
                                                FFAppState().viewerClinicIDS =
                                                    functions
                                                        .getClinicIDList(
                                                            getJsonField(
                                                          (_model.getPESClinicsEnterKey
                                                                  ?.jsonBody ??
                                                              ''),
                                                          r'''$.data.pep_patient_enroller_active_assignments[:].clinic_ids''',
                                                          true,
                                                        ))
                                                        .toList()
                                                        .cast<int>();
                                                safeSetState(() {});
                                                _model.createTimeEnterPELog =
                                                    await PEPAPIsGroup
                                                        .createTimerLogCall
                                                        .call(
                                                  userId: FFAppState()
                                                      .loginProfileID,
                                                  authToken:
                                                      FFAppState().loginToken,
                                                );

                                                if ((_model.createTimeEnterPELog
                                                        ?.succeeded ??
                                                    true)) {
                                                  FFAppState().timerlogId =
                                                      PEPAPIsGroup
                                                          .createTimerLogCall
                                                          .timelogId(
                                                            (_model.createTimeEnterPELog
                                                                    ?.jsonBody ??
                                                                ''),
                                                          )!
                                                          .toString();
                                                  safeSetState(() {});

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
                                                } else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Creating Timelog Failed',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleMedium
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .poppins(
                                                                    fontWeight: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleMedium
                                                                        .fontWeight,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleMedium
                                                                        .fontStyle,
                                                                  ),
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryText,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleMedium
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleMedium
                                                                      .fontStyle,
                                                                ),
                                                      ),
                                                      duration: Duration(
                                                          milliseconds: 750),
                                                      backgroundColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primary,
                                                    ),
                                                  );
                                                }
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Invalid User! Please try again.',
                                                      style: TextStyle(
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .secondaryBackground,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 24.0,
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

                                              _model.storedRedirectEnterURL =
                                                  await actions
                                                      .getStoredRedirectURL();
                                              if (FFAppState().redirectURL !=
                                                      '') {
                                                await actions.redirectToURL(
                                                  context,
                                                );
                                              }
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'LOGIN FAILED',
                                                    style: TextStyle(
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryText,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 24.0,
                                                    ),
                                                  ),
                                                  duration: Duration(
                                                      milliseconds: 4000),
                                                  backgroundColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .secondary,
                                                ),
                                              );
                                            }

                                            safeSetState(() {});
                                          },
                                          autofocus: false,
                                          autofillHints: [
                                            AutofillHints.password
                                          ],
                                          textInputAction: TextInputAction.done,
                                          obscureText:
                                              !_model.passwordVisibility,
                                          decoration: InputDecoration(
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
                                                      fontSize: 16.0,
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
                                            hintText: '***********',
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                                width: 1.0,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
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
                                                    .secondary,
                                            prefixIcon: Icon(
                                              Icons.password,
                                            ),
                                            suffixIcon: InkWell(
                                              onTap: () => safeSetState(
                                                () => _model
                                                        .passwordVisibility =
                                                    !_model.passwordVisibility,
                                              ),
                                              focusNode: FocusNode(
                                                  skipTraversal: true),
                                              child: Icon(
                                                _model.passwordVisibility
                                                    ? Icons.visibility_outlined
                                                    : Icons
                                                        .visibility_off_outlined,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                                size: 24.0,
                                              ),
                                            ),
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
                                                  .secondaryText,
                                          validator: _model
                                              .passwordTextControllerValidator
                                              .asValidator(context),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 16.0, 0.0, 16.0),
                                      child: FFButtonWidget(
                                        onPressed: () async {
                                          _model.loginResponse =
                                              await LoginAPICall.call(
                                            email: _model
                                                .emailAddressTextController
                                                .text,
                                            password: _model
                                                .passwordTextController.text,
                                          );

                                          FFAppState().loginEmail = _model
                                              .emailAddressTextController.text;
                                          safeSetState(() {});

                                          FFAppState().update(() {});
                                          if ((_model
                                                  .loginResponse?.succeeded ??
                                              true)) {
                                            FFAppState().loginToken =
                                                LoginAPICall.getToken(
                                              (_model.loginResponse?.jsonBody ??
                                                  ''),
                                            )!;
                                            safeSetState(() {});
                                            _model.getProfileResponse =
                                                await GetProfileCall.call(
                                              email: FFAppState().loginEmail,
                                              authToken:
                                                  FFAppState().loginToken,
                                            );

                                            FFAppState().username =
                                                GetProfileCall.username(
                                              (_model.getProfileResponse
                                                      ?.jsonBody ??
                                                  ''),
                                            )!;
                                            FFAppState().usertype =
                                                GetProfileCall.usertype(
                                              (_model.getProfileResponse
                                                      ?.jsonBody ??
                                                  ''),
                                            )!;
                                            FFAppState().loginProfileID =
                                                GetProfileCall.profileID(
                                              (_model.getProfileResponse
                                                      ?.jsonBody ??
                                                  ''),
                                            )!
                                                    .toString();
                                            safeSetState(() {});
                                            _model.getHasura =
                                                await GetHasuraTokenCall.call(
                                              profileID:
                                                  FFAppState().loginProfileID,
                                              authToken:
                                                  FFAppState().loginToken,
                                            );

                                            FFAppState().hasuraToken =
                                                GetHasuraTokenCall.hasuraToken(
                                              (_model.getHasura?.jsonBody ??
                                                  ''),
                                            )!;
                                            safeSetState(() {});
                                            await actions
                                                .storeHasuraAndLoginToken(
                                              FFAppState().loginToken,
                                              GetHasuraTokenCall.hasuraToken(
                                                (_model.getHasura?.jsonBody ??
                                                    ''),
                                              )!,
                                            );
                                            _model.usernames =
                                                await GQLgetByFunctionCall.call(
                                              hasuraToken:
                                                  FFAppState().hasuraToken,
                                              requestBody:
                                                  '{\"query\":\"query MyQuery { api_hboxuser(where: {type: {_in: [EA, ES, CA, CS, PA, PE]}}) { id first_name last_name type } }\"}',
                                            );

                                            FFAppState().usernames =
                                                GQLgetByFunctionCall.usernames(
                                              (_model.usernames?.jsonBody ??
                                                  ''),
                                            )!
                                                    .toList()
                                                    .cast<dynamic>();
                                            safeSetState(() {});
                                            if (FFAppState().usertype ==
                                                FFAppConstants.UserTypeGA) {
                                              context.goNamed(
                                                ViewGroupsWidget.routeName,
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
                                            } else if (FFAppState().usertype ==
                                                FFAppConstants.UserTypeEA) {
                                              context.goNamed(
                                                ViewGroupsWidget.routeName,
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
                                            } else if (FFAppState().usertype ==
                                                FFAppConstants.UserTypeES) {
                                              _model.currentPatient =
                                                  await GQLgetByFunctionCall
                                                      .call(
                                                hasuraToken:
                                                    FFAppState().hasuraToken,
                                                requestBody: functions
                                                    .getNextPatient(int.parse(
                                                        FFAppState()
                                                            .loginProfileID))
                                                    .toString(),
                                              );

                                              await PEPAPIsGroup
                                                  .lockPatientByGroupCall
                                                  .call(
                                                loginID: int.parse(FFAppState()
                                                    .loginProfileID),
                                                authToken:
                                                    FFAppState().loginToken,
                                                groupId: valueOrDefault<int>(
                                                  GQLgetByFunctionCall
                                                      .currentPatientGroupID(
                                                    (_model.currentPatient
                                                            ?.jsonBody ??
                                                        ''),
                                                  ),
                                                  0,
                                                ),
                                              );

                                              FFAppState().currentPatient =
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
                                              safeSetState(() {});
                                              _model.createTimeBtnESLog =
                                                  await PEPAPIsGroup
                                                      .createTimerLogCall
                                                      .call(
                                                userId: FFAppState()
                                                    .loginProfileID,
                                                authToken:
                                                    FFAppState().loginToken,
                                              );

                                              if ((_model.createTimeBtnESLog
                                                      ?.succeeded ??
                                                  true)) {
                                                FFAppState().timerlogId =
                                                    PEPAPIsGroup
                                                        .createTimerLogCall
                                                        .timelogId(
                                                          (_model.createTimeBtnESLog
                                                                  ?.jsonBody ??
                                                              ''),
                                                        )!
                                                        .toString();
                                                safeSetState(() {});

                                                context.goNamed(
                                                    VPEDashboardWidget
                                                        .routeName);
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Creating Timelog Failed',
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .titleMedium
                                                              .override(
                                                                font: GoogleFonts
                                                                    .poppins(
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleMedium
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleMedium
                                                                      .fontStyle,
                                                                ),
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryText,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleMedium
                                                                    .fontWeight,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleMedium
                                                                    .fontStyle,
                                                              ),
                                                    ),
                                                    duration: Duration(
                                                        milliseconds: 750),
                                                    backgroundColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primary,
                                                  ),
                                                );
                                              }
                                                                                        } else if (FFAppState().usertype ==
                                                FFAppConstants.UserTypeCA) {
                                              context.goNamed(
                                                ViewCSWidget.routeName,
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

                                              await Future.delayed(
                                                  const Duration(
                                                      milliseconds: 1000));
                                              await actions
                                                  .notificationPermission();
                                            } else if (FFAppState().usertype ==
                                                FFAppConstants.UserTypeCS) {
                                              _model.getCSClinics =
                                                  await GQLgetByFunctionCall
                                                      .call(
                                                hasuraToken:
                                                    FFAppState().hasuraToken,
                                                requestBody: functions
                                                    .getCareSpecialistClinics(
                                                        int.parse(FFAppState()
                                                            .loginProfileID))
                                                    .toString(),
                                              );

                                              FFAppState()
                                                  .deleteViewerClinicIDS();
                                              FFAppState().viewerClinicIDS = [];

                                              safeSetState(() {});
                                              FFAppState().viewerClinicIDS =
                                                  functions
                                                      .getClinicIDList(
                                                          getJsonField(
                                                        (_model.getCSClinics
                                                                ?.jsonBody ??
                                                            ''),
                                                        r'''$.data.pep_care_specialist_active_assignments[:].clinic_ids''',
                                                        true,
                                                      ))
                                                      .toList()
                                                      .cast<int>();
                                              safeSetState(() {});
                                              _model.createTimeBtnCSLog =
                                                  await PEPAPIsGroup
                                                      .createTimerLogCall
                                                      .call(
                                                userId:
                                                    FFAppState().loginProfileID,
                                                authToken:
                                                    FFAppState().loginToken,
                                              );

                                              if ((_model.createTimeBtnCSLog
                                                      ?.succeeded ??
                                                  true)) {
                                                FFAppState().timerlogId =
                                                    PEPAPIsGroup
                                                        .createTimerLogCall
                                                        .timelogId(
                                                          (_model.createTimeBtnCSLog
                                                                  ?.jsonBody ??
                                                              ''),
                                                        )!
                                                        .toString();
                                                safeSetState(() {});

                                                context.goNamed(
                                                  CSPatientListWidget.routeName,
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

                                                await Future.delayed(
                                                    const Duration(
                                                        milliseconds: 1000));
                                                await actions
                                                    .notificationPermission();
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Creating Timelog Failed',
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .titleMedium
                                                              .override(
                                                                font: GoogleFonts
                                                                    .poppins(
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleMedium
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleMedium
                                                                      .fontStyle,
                                                                ),
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryText,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleMedium
                                                                    .fontWeight,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleMedium
                                                                    .fontStyle,
                                                              ),
                                                    ),
                                                    duration: Duration(
                                                        milliseconds: 750),
                                                    backgroundColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primary,
                                                  ),
                                                );
                                              }
                                            } else if (FFAppState().usertype ==
                                                FFAppConstants.UserTypePA) {
                                              context.goNamed(
                                                ViewPESWidget.routeName,
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
                                            } else if (FFAppState().usertype ==
                                                FFAppConstants.UserTypePE) {
                                              _model.getPESClinics =
                                                  await GQLgetByFunctionCall
                                                      .call(
                                                hasuraToken:
                                                    FFAppState().hasuraToken,
                                                requestBody: functions
                                                    .getPatientEnrollerClinics(
                                                        int.parse(FFAppState()
                                                            .loginProfileID))
                                                    .toString(),
                                              );

                                              FFAppState()
                                                  .deleteViewerClinicIDS();
                                              FFAppState().viewerClinicIDS = [];

                                              safeSetState(() {});
                                              FFAppState().viewerClinicIDS =
                                                  functions
                                                      .getClinicIDList(
                                                          getJsonField(
                                                        (_model.getPESClinics
                                                                ?.jsonBody ??
                                                            ''),
                                                        r'''$.data.pep_patient_enroller_active_assignments[:].clinic_ids''',
                                                        true,
                                                      ))
                                                      .toList()
                                                      .cast<int>();
                                              safeSetState(() {});
                                              _model.createTimeBtnPESLog =
                                                  await PEPAPIsGroup
                                                      .createTimerLogCall
                                                      .call(
                                                userId:
                                                    FFAppState().loginProfileID,
                                                authToken:
                                                    FFAppState().loginToken,
                                              );

                                              if ((_model.createTimeBtnPESLog
                                                      ?.succeeded ??
                                                  true)) {
                                                FFAppState().timerlogId =
                                                    PEPAPIsGroup
                                                        .createTimerLogCall
                                                        .timelogId(
                                                          (_model.createTimeBtnPESLog
                                                                  ?.jsonBody ??
                                                              ''),
                                                        )!
                                                        .toString();
                                                safeSetState(() {});

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
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Creating Timelog Failed',
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .titleMedium
                                                              .override(
                                                                font: GoogleFonts
                                                                    .poppins(
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleMedium
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleMedium
                                                                      .fontStyle,
                                                                ),
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryText,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleMedium
                                                                    .fontWeight,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleMedium
                                                                    .fontStyle,
                                                              ),
                                                    ),
                                                    duration: Duration(
                                                        milliseconds: 750),
                                                    backgroundColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primary,
                                                  ),
                                                );
                                              }
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Invalid User! Please try again.',
                                                    style: TextStyle(
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .buttonText,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 24.0,
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

                                            _model.storedRedirectURL =
                                                await actions
                                                    .getStoredRedirectURL();
                                            if (FFAppState().redirectURL !=
                                                    '') {
                                              await actions.redirectToURL(
                                                context,
                                              );
                                            }
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'LOGIN FAILED',
                                                  style: TextStyle(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .buttonText,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 24.0,
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
                                        text: 'Submit',
                                        options: FFButtonOptions(
                                          width: 400.0,
                                          height: 54.0,
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 0.0, 0.0, 0.0),
                                          iconPadding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 0.0, 0.0, 0.0),
                                          color: Color(0xFF0D6D4F),
                                          textStyle: FlutterFlowTheme.of(
                                                  context)
                                              .titleSmall
                                              .override(
                                                font: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.normal,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .titleSmall
                                                          .fontStyle,
                                                ),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .buttonText,
                                                fontSize: 18.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.normal,
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
                                          borderRadius:
                                              BorderRadius.circular(8.0),
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
