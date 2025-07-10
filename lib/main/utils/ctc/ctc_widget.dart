import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'ctc_model.dart';
export 'ctc_model.dart';

class CtcWidget extends StatefulWidget {
  const CtcWidget({super.key});

  static String routeName = 'CTC';
  static String routePath = 'CallingPatient';

  @override
  State<CtcWidget> createState() => _CtcWidgetState();
}

class _CtcWidgetState extends State<CtcWidget> {
  late CtcModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CtcModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (FFAppState().loginToken != '') {
        FFAppState().update(() {});
        _model.pesPatientList = [];
        _model.pesPatientListFiltered = [];
        _model.dateSearch = null;
        _model.pageLoad = false;
        safeSetState(() {});
        _model.pESAssignedTasksResponse = await GQLgetByFunctionCall.call(
          hasuraToken: FFAppState().hasuraToken,
          requestBody: functions
              .checkPESAssignedTasks(
                  (int.parse(FFAppState().loginProfileID)).toString())
              .toString(),
        );

        _model.checkDeferredTaskAssigned = getJsonField(
          (_model.pESAssignedTasksResponse?.jsonBody ?? ''),
          r'''$.data.pep_vw_patient_enroller_list[:].deferred_task''',
        );
        _model.checkFollowUpTaskAssigned = getJsonField(
          (_model.pESAssignedTasksResponse?.jsonBody ?? ''),
          r'''$.data.pep_vw_patient_enroller_list[:].follow_up''',
        );
        safeSetState(() {});
        if (FFAppState().viewerClinicIDS.isNotEmpty) {
          _model.pesPatientListAPICallPageLoad =
              await GQLgetByFunctionCall.call(
            hasuraToken: FFAppState().hasuraToken,
            requestBody: functions
                .getPatientEnrollerPatientList(
                    FFAppState().viewerClinicIDS.toList())
                .toString(),
          );

          _model.pesPatientList = functions
              .enrichClinicTime(getJsonField(
                (_model.pesPatientListAPICallPageLoad?.jsonBody ?? ''),
                r'''$.data.pep_vw_patient_enroller_patient_list''',
                true,
              )!)
              .toList()
              .cast<dynamic>();
          safeSetState(() {});
          _model.pageLoad = true;
          safeSetState(() {});
          await Future.delayed(const Duration(milliseconds: 100));
        } else {
          _model.pesPatientList = [];
          safeSetState(() {});
          _model.pageLoad = true;
          safeSetState(() {});
        }
      } else {
        await actions.checkAndStoreRedirectURL();

        context.goNamed(LoginWidget.routeName);

        await actions.clearCacheAndReloadHbox();
      }
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
        backgroundColor: FlutterFlowTheme.of(context).secondary,
        body: SafeArea(
          top: true,
          child: Align(
            alignment: AlignmentDirectional(-1.0, -1.0),
            child: Container(
              width: MediaQuery.sizeOf(context).width * 1.0,
              height: MediaQuery.sizeOf(context).height * 1.0,
              child: custom_widgets.TwilioCallWidget(
                width: MediaQuery.sizeOf(context).width * 1.0,
                height: MediaQuery.sizeOf(context).height * 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
