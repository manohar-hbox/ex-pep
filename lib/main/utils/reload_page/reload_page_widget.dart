import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'reload_page_model.dart';
export 'reload_page_model.dart';

class ReloadPageWidget extends StatefulWidget {
  const ReloadPageWidget({
    super.key,
    bool? csReload,
    this.patientClinicDataID,
    this.clinicID,
    bool? pesReload,
    bool? groupListReload,
    bool? globalReload,
    bool? appointmentReload,
    bool? csList,
    bool? vpeDeferredReload,
    bool? vpeReload,
    bool? csAdminReload,
    this.csScreenType,
    this.pesScreenType,
  })  : this.csReload = csReload ?? false,
        this.pesReload = pesReload ?? false,
        this.groupListReload = groupListReload ?? false,
        this.globalReload = globalReload ?? false,
        this.appointmentReload = appointmentReload ?? false,
        this.csList = csList ?? false,
        this.vpeDeferredReload = vpeDeferredReload ?? false,
        this.vpeReload = vpeReload ?? false,
        this.csAdminReload = csAdminReload ?? false;

  final bool csReload;
  final int? patientClinicDataID;
  final int? clinicID;
  final bool pesReload;
  final bool groupListReload;
  final bool globalReload;
  final bool appointmentReload;
  final bool csList;
  final bool vpeDeferredReload;
  final bool vpeReload;
  final bool csAdminReload;
  final CSScreenType? csScreenType;
  final PESScreenType? pesScreenType;

  static String routeName = 'ReloadPage';
  static String routePath = 'reloadPage';

  @override
  State<ReloadPageWidget> createState() => _ReloadPageWidgetState();
}

class _ReloadPageWidgetState extends State<ReloadPageWidget> {
  late ReloadPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ReloadPageModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 500));
      if (widget.csAdminReload) {
        FFAppState().clearPatientDetailsCacheCache();
        FFAppState().clearCcmStatusUpdatesCSCache();
        FFAppState().clearRpmStatusUpdatesCSCache();
        await Future.delayed(const Duration(milliseconds: 500));

        context.goNamed(
          CSAdminPatientDetailSavedWidget.routeName,
          queryParameters: {
            'patientClinicDataID': serializeParam(
              widget.patientClinicDataID,
              ParamType.int,
            ),
            'clinicID': serializeParam(
              widget.clinicID,
              ParamType.int,
            ),
          }.withoutNulls,
        );
      } else if (widget.csReload) {
        FFAppState().clearPatientDetailsCacheCache();
        FFAppState().clearCcmStatusUpdatesCSCache();
        FFAppState().clearRpmStatusUpdatesCSCache();
        await Future.delayed(const Duration(milliseconds: 500));

        context.goNamed(
          CSPatientDetailSavedWidget.routeName,
          queryParameters: {
            'patientClinicDataID': serializeParam(
              widget.patientClinicDataID,
              ParamType.int,
            ),
            'clinicID': serializeParam(
              widget.clinicID,
              ParamType.int,
            ),
            'csScreenType': serializeParam(
              widget.csScreenType,
              ParamType.Enum,
            ),
          }.withoutNulls,
        );
      } else if (widget.pesReload) {
        FFAppState().clearPatientDetailsCacheCache();
        FFAppState().clearRpmStatusUpdatesPESCache();
        await Future.delayed(const Duration(milliseconds: 500));

        context.goNamed(
          PESPatientDetailSavedWidget.routeName,
          queryParameters: {
            'patientClinicDataID': serializeParam(
              widget.patientClinicDataID,
              ParamType.int,
            ),
            'clinicID': serializeParam(
              widget.clinicID,
              ParamType.int,
            ),
            'pesScreenType': serializeParam(
              widget.pesScreenType,
              ParamType.Enum,
            ),
          }.withoutNulls,
        );
      } else if (widget.groupListReload) {
        context.goNamed(ViewGroupsWidget.routeName);
      } else if (widget.globalReload) {
        FFAppState().clearPatientDetailsCacheCache();
        FFAppState().clearCcmStatusUpdatesGSCache();
        FFAppState().clearRpmStatusUpdatesGSCache();
        await Future.delayed(const Duration(milliseconds: 500));

        context.goNamed(
          GSPatientViewSavedWidget.routeName,
          queryParameters: {
            'patientClinicDataID': serializeParam(
              widget.patientClinicDataID,
              ParamType.int,
            ),
            'clinicID': serializeParam(
              widget.clinicID,
              ParamType.int,
            ),
          }.withoutNulls,
        );
      } else if (widget.appointmentReload) {
        context.goNamed(ManageClinicTimeSlotsWidget.routeName);
      } else if (widget.vpeReload) {
        FFAppState().clearVpePatientDetailsCacheCache();
        FFAppState().clearCcmStatusUpdatesVPECache();
        await Future.delayed(const Duration(milliseconds: 500));

        context.goNamed(
          VPEDashboardWidget.routeName,
          extra: <String, dynamic>{
            kTransitionInfoKey: TransitionInfo(
              hasTransition: true,
              transitionType: PageTransitionType.fade,
              duration: Duration(milliseconds: 100),
            ),
          },
        );
      } else if (widget.vpeDeferredReload) {
        FFAppState().clearVpeDeferredPatientsCacheCache();
        FFAppState().clearCcmStatusUpdateDeferredVpeCache();
        await Future.delayed(const Duration(milliseconds: 500));

        context.goNamed(VPEDeferredPatientsWidget.routeName);
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
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      ),
    );
  }
}
